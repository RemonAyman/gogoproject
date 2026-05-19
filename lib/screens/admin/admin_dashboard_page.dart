import 'package:flutter/material.dart';
import '../../core/config/routes/routes.dart';
import '../../services/api_service.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;

  // Specialties State
  late Future<List<dynamic>> _specialtiesFuture;
  final _specialtyController = TextEditingController();

  // Add Doctor Form State
  final _formKey = GlobalKey<FormState>();
  final _docNameController = TextEditingController();
  final _docEmailController = TextEditingController();
  final _docPasswordController = TextEditingController();
  final _docPriceController = TextEditingController(text: '300 EGP');
  final _docBioController = TextEditingController();
  final _docAddressController = TextEditingController();
  final _docGovernorateController = TextEditingController(text: 'القاهرة');
  String _selectedWorkplace = 'عيادة';
  String? _selectedSpecialty;
  bool _isDocSubmitting = false;

  // Bookings State
  late Future<List<dynamic>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  void _loadData() {
    setState(() {
      _specialtiesFuture = _apiService.getSpecialties();
      _bookingsFuture = _apiService.adminGetAllBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _specialtyController.dispose();
    _docNameController.dispose();
    _docEmailController.dispose();
    _docPasswordController.dispose();
    _docPriceController.dispose();
    _docBioController.dispose();
    _docAddressController.dispose();
    _docGovernorateController.dispose();
    super.dispose();
  }

  // Add Specialty
  Future<void> _addSpecialty() async {
    final name = _specialtyController.text.trim();
    if (name.isEmpty) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      await _apiService.addSpecialty(name);
      
      if (mounted) {
        Navigator.pop(context); // Close progress dialog
        _specialtyController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إضافة التخصص بنجاح')),
        );
        _loadData(); // Reload specialties
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close progress dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل إضافة التخصص: ${e.toString().replaceAll('Exception: ', '')}')),
        );
      }
    }
  }

  // Register Doctor
  Future<void> _registerDoctor() async {
    if (!_formKey.currentState!.validate() || _selectedSpecialty == null) {
      if (_selectedSpecialty == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء اختيار تخصص الطبيب')),
        );
      }
      return;
    }

    setState(() => _isDocSubmitting = true);

    try {
      await _apiService.adminAddDoctor(
        name: _docNameController.text.trim(),
        email: _docEmailController.text.trim(),
        password: _docPasswordController.text.trim(),
        specialty: _selectedSpecialty!,
        price: _docPriceController.text.trim(),
        bio: _docBioController.text.trim(),
        workplaceType: _selectedWorkplace,
        governorate: _docGovernorateController.text.trim(),
        address: _docAddressController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إضافة الطبيب وإنشاء الحساب بنجاح')),
        );
        // Clear fields
        _docNameController.clear();
        _docEmailController.clear();
        _docPasswordController.clear();
        _docBioController.clear();
        _docAddressController.clear();
        setState(() {
          _selectedSpecialty = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل إضافة الطبيب: ${e.toString().replaceAll('Exception: ', '')}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDocSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم المسؤول (الأدمن)', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _apiService.logout();
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontSize: 14),
          tabs: const [
            Tab(icon: Icon(Icons.grid_view), text: 'التخصصات'),
            Tab(icon: Icon(Icons.person_add), text: 'إضافة طبيب'),
            Tab(icon: Icon(Icons.history), text: 'سجل الحجوزات'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Specialties Manager
          _buildSpecialtiesTab(),

          // Tab 2: Add Doctor Form
          _buildAddDoctorTab(),

          // Tab 3: All Bookings Log
          _buildBookingsTab(),
        ],
      ),
    );
  }

  // Specialties Tab Widget
  Widget _buildSpecialtiesTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _specialtyController,
                      decoration: const InputDecoration(
                        labelText: 'إضافة تخصص جديد',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.add_box_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _addSpecialty,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('إضافة'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'التخصصات المتاحة حالياً:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _specialtiesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('خطأ في تحميل التخصصات: ${snapshot.error}'));
                }
                final list = snapshot.data ?? [];
                if (list.isEmpty) {
                  return const Center(child: Text('لا يوجد تخصصات متاحة، برجاء الإضافة.'));
                }

                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                          child: Icon(Icons.category, color: Theme.of(context).primaryColor),
                        ),
                        title: Text(
                          item['name'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/patient/doctors_list',
                            arguments: item['name'],
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Add Doctor Tab Widget
  Widget _buildAddDoctorTab() {
    return FutureBuilder<List<dynamic>>(
      future: _specialtiesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final specialties = snapshot.data ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'تسجيل طبيب جديد بالنظام',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // Name
                    TextFormField(
                      controller: _docNameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم الطبيب',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'الرجاء إدخال اسم الطبيب' : null,
                    ),
                    const SizedBox(height: 12),

                    // Email
                    TextFormField(
                      controller: _docEmailController,
                      decoration: const InputDecoration(
                        labelText: 'البريد الإلكتروني للوجين',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => value == null || value.isEmpty ? 'الرجاء إدخال البريد الإلكتروني' : null,
                    ),
                    const SizedBox(height: 12),

                    // Password
                    TextFormField(
                      controller: _docPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'الباسورد المؤقت للطبيب',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) => value == null || value.length < 6 ? 'الباسورد يجب أن لا يقل عن 6 أحرف' : null,
                    ),
                    const SizedBox(height: 12),

                    // Specialty Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedSpecialty,
                      decoration: const InputDecoration(
                        labelText: 'اختر تخصص الطبيب',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(),
                      ),
                      items: specialties.map<DropdownMenuItem<String>>((spec) {
                        return DropdownMenuItem<String>(
                          value: spec['name'],
                          child: Text(spec['name'] ?? ''),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSpecialty = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Price
                    TextFormField(
                      controller: _docPriceController,
                      decoration: const InputDecoration(
                        labelText: 'سعر الكشف (مثال: 300 EGP)',
                        prefixIcon: Icon(Icons.monetization_on),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'الرجاء إدخال سعر الكشف' : null,
                    ),
                    const SizedBox(height: 12),

                    // Workplace Selection
                    Row(
                      children: [
                        const Text('مكان العمل:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 16),
                        ChoiceChip(
                          label: const Text('عيادة'),
                          selected: _selectedWorkplace == 'عيادة',
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedWorkplace = 'عيادة');
                          },
                        ),
                        const SizedBox(width: 12),
                        ChoiceChip(
                          label: const Text('مستشفى'),
                          selected: _selectedWorkplace == 'مستشفى',
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedWorkplace = 'مستشفى');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Governorate
                    TextFormField(
                      controller: _docGovernorateController,
                      decoration: const InputDecoration(
                        labelText: 'المحافظة',
                        prefixIcon: Icon(Icons.map),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Address
                    TextFormField(
                      controller: _docAddressController,
                      decoration: const InputDecoration(
                        labelText: 'العنوان التفصيلي للعيادة',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Bio
                    TextFormField(
                      controller: _docBioController,
                      decoration: const InputDecoration(
                        labelText: 'نبذة مختصرة عن الطبيب وخبراته',
                        prefixIcon: Icon(Icons.info),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isDocSubmitting ? null : _registerDoctor,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: _isDocSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('إنشاء حساب الطبيب وتفعيله', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Bookings Tab Widget
  Widget _buildBookingsTab() {
    return FutureBuilder<List<dynamic>>(
      future: _bookingsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('خطأ في تحميل سجل الحجوزات: ${snapshot.error}'));
        }

        final bookings = snapshot.data ?? [];
        if (bookings.isEmpty) {
          return const Center(child: Text('لا يوجد طلبات حجز مسجلة بالنظام بعد.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            final status = booking['status'] ?? 'pending';
            final dateStr = booking['date'] != null
                ? DateTime.parse(booking['date']).toLocal().toString().split('.')[0]
                : 'غير محدد';

            Color statusColor;
            IconData statusIcon;
            switch (status) {
              case 'confirmed':
                statusColor = Colors.green;
                statusIcon = Icons.check_circle;
                break;
              case 'cancelled':
                statusColor = Colors.red;
                statusIcon = Icons.cancel;
                break;
              default:
                statusColor = Colors.orange;
                statusIcon = Icons.hourglass_empty;
            }

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: statusColor.withOpacity(0.1),
                  child: Icon(statusIcon, color: statusColor),
                ),
                title: Text(
                  'المريض: ${booking['patientName'] ?? 'غير معروف'}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('الطبيب: ${booking['doctorName'] ?? ''}', style: const TextStyle(color: Colors.blue)),
                    const SizedBox(height: 4),
                    Text('التاريخ: $dateStr'),
                    const SizedBox(height: 4),
                    if (booking['description'] != null && booking['description'].isNotEmpty)
                      Text('الشكوى: ${booking['description']}', style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
                trailing: Text(
                  status == 'pending'
                      ? 'انتظار'
                      : status == 'confirmed'
                          ? 'مؤكد'
                          : 'ملغي',
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
