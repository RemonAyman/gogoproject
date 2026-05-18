import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config.dart';
import '../data/fake_data.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Helper headers
  Map<String, String> _headers({bool requireAuth = true}) {
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (requireAuth && gAuthToken != null) {
      headers['Authorization'] = 'Bearer $gAuthToken';
    }
    return headers;
  }

  // Handle Response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      Map<String, dynamic>? errorData;
      try {
        errorData = jsonDecode(response.body);
      } catch (_) {}
      
      final errorMessage = errorData != null && errorData.containsKey('message')
          ? errorData['message']
          : 'حدث خطأ ما (كود: ${response.statusCode})';
      throw Exception(errorMessage);
    }
  }

  // --- AUTH ENDPOINTS ---

  // Register Patient
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$kApiBaseUrl/api/auth/register'),
      headers: _headers(requireAuth: false),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );
    final data = _handleResponse(response);
    
    // Cache details globally
    gAuthToken = data['token'];
    gCurrentUserName = data['user']['name'];
    gCurrentUserEmail = data['user']['email'];
    gCurrentUserPassword = password;

    return data;
  }

  // Unified Login (Patient, Doctor, Admin)
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$kApiBaseUrl/api/auth/login'),
      headers: _headers(requireAuth: false),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    final data = _handleResponse(response);

    // Cache details globally
    gAuthToken = data['token'];
    gCurrentUserName = data['user']['name'];
    gCurrentUserEmail = data['user']['email'];
    gCurrentUserPassword = password;

    return data;
  }

  // Get current user details
  Future<Map<String, dynamic>> getMe() async {
    final response = await http.get(
      Uri.parse('$kApiBaseUrl/api/auth/me'),
      headers: _headers(),
    );
    return _handleResponse(response);
  }

  // Patient Complete Profile
  Future<Map<String, dynamic>> completePatientProfile({
    required String age,
    required String painLocation,
    required String description,
  }) async {
    final response = await http.post(
      Uri.parse('$kApiBaseUrl/api/auth/complete-profile'),
      headers: _headers(),
      body: jsonEncode({
        'age': age,
        'painLocation': painLocation,
        'description': description,
      }),
    );
    return _handleResponse(response);
  }

  // Doctor Edit Profile
  Future<Map<String, dynamic>> completeDoctorProfile({
    required String name,
    required String specialty,
    required String price,
    required String bio,
    required String workplaceType,
    required String governorate,
    required String address,
  }) async {
    final response = await http.post(
      Uri.parse('$kApiBaseUrl/api/auth/edit-profile'),
      headers: _headers(),
      body: jsonEncode({
        'name': name,
        'specialty': specialty,
        'price': price,
        'bio': bio,
        'workplaceType': workplaceType,
        'governorate': governorate,
        'address': address,
      }),
    );
    return _handleResponse(response);
  }

  // --- SPECIALTY ENDPOINTS ---

  // Get all specialties
  Future<List<dynamic>> getSpecialties() async {
    final response = await http.get(
      Uri.parse('$kApiBaseUrl/api/specialties'),
      headers: _headers(requireAuth: false),
    );
    return _handleResponse(response) as List<dynamic>;
  }

  // Create Specialty (Admin only)
  Future<Map<String, dynamic>> addSpecialty(String name) async {
    final response = await http.post(
      Uri.parse('$kApiBaseUrl/api/specialties'),
      headers: _headers(),
      body: jsonEncode({'name': name}),
    );
    return _handleResponse(response);
  }

  // --- DOCTOR ENDPOINTS ---

  // Get doctors (optionally filtered by specialty)
  Future<List<dynamic>> getDoctors({String? specialty}) async {
    String url = '$kApiBaseUrl/api/doctors';
    if (specialty != null && specialty.isNotEmpty) {
      url += '?specialty=${Uri.encodeComponent(specialty)}';
    }
    final response = await http.get(
      Uri.parse(url),
      headers: _headers(requireAuth: false),
    );
    return _handleResponse(response) as List<dynamic>;
  }

  // --- ADMIN PORTAL ENDPOINTS ---

  // Admin registers a Doctor account
  Future<Map<String, dynamic>> adminAddDoctor({
    required String name,
    required String email,
    required String password,
    required String specialty,
    required String price,
    required String bio,
    required String workplaceType,
    required String governorate,
    required String address,
  }) async {
    final response = await http.post(
      Uri.parse('$kApiBaseUrl/api/admin/doctors'),
      headers: _headers(),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'specialty': specialty,
        'price': price,
        'bio': bio,
        'workplaceType': workplaceType,
        'governorate': governorate,
        'address': address,
      }),
    );
    return _handleResponse(response);
  }

  // Admin gets all booking requests
  Future<List<dynamic>> adminGetAllBookings() async {
    final response = await http.get(
      Uri.parse('$kApiBaseUrl/api/admin/bookings'),
      headers: _headers(),
    );
    return _handleResponse(response) as List<dynamic>;
  }

  // --- BOOKING ENDPOINTS ---

  // Patient creates booking
  Future<Map<String, dynamic>> createBooking({
    required String doctorId,
    required String doctorName,
    required String date,
    required String description,
    required String price,
  }) async {
    final response = await http.post(
      Uri.parse('$kApiBaseUrl/api/bookings'),
      headers: _headers(),
      body: jsonEncode({
        'doctorId': doctorId,
        'doctorName': doctorName,
        'date': date,
        'description': description,
        'price': price,
      }),
    );
    return _handleResponse(response);
  }

  // Patient gets their bookings
  Future<List<dynamic>> getPatientBookings() async {
    final response = await http.get(
      Uri.parse('$kApiBaseUrl/api/bookings/patient'),
      headers: _headers(),
    );
    return _handleResponse(response) as List<dynamic>;
  }

  // Doctor gets their appointments
  Future<List<dynamic>> getDoctorBookings() async {
    final response = await http.get(
      Uri.parse('$kApiBaseUrl/api/bookings/doctor'),
      headers: _headers(),
    );
    return _handleResponse(response) as List<dynamic>;
  }

  // Doctor updates status
  Future<Map<String, dynamic>> updateBookingStatus(String bookingId, String status) async {
    final response = await http.put(
      Uri.parse('$kApiBaseUrl/api/bookings/$bookingId/status'),
      headers: _headers(),
      body: jsonEncode({'status': status}),
    );
    return _handleResponse(response);
  }

  // Logout clear token
  void logout() {
    gAuthToken = null;
    gCurrentUserName = null;
    gCurrentUserEmail = null;
    gCurrentUserPassword = null;
  }

  // Update role placeholder
  Future<void> updateUserRole(String role) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }
}

