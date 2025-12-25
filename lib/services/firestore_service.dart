import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// ➕ إضافة حجز
  Future<void> addBooking(Booking booking) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    await _firestore.collection('appointments').add({
      ...booking.toMap(),
      'patientId': user.uid, // ربط الحجز بالمريض الحالي
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// ✏️ تحديث دور المستخدم (doctor / patient)
  Future<void> updateUserRole(String role) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("No authenticated user found.");
    }

    await _firestore.collection('users').doc(user.uid).update({
      'role': role,
    });
  }

  /// 👤 إنشاء مستخدم
  Future<void> createUser(User user, String name) async {
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': name,
      'email': user.email,
      'role': 'patient',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// 📥 جلب كل الحجوزات
  Stream<List<Booking>> getBookings() {
    return _firestore
        .collection('appointments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Booking.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// 📥 جلب حجوزات دكتور
  Stream<List<Booking>> getDoctorBookings(String doctorId) {
    return _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Booking.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// 🔄 تحديث حالة الحجز
  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    await _firestore.collection('appointments').doc(appointmentId).update({
      'status': status,
    });
  }

  /// 🔍 جلب تفاصيل حجز معين
  Future<DocumentSnapshot> getAppointmentById(String appointmentId) {
    return _firestore.collection('appointments').doc(appointmentId).get();
  }
}
