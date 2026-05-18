import 'package:flutter/material.dart';
import '../../core/config/routes/routes.dart';
import '../../services/api_service.dart';

class DoctorEditProfilePage extends StatefulWidget {
  final bool isFirstTime;
  const DoctorEditProfilePage({super.key, this.isFirstTime = false});

  @override
  State<DoctorEditProfilePage> createState() => _DoctorEditProfilePageState();
}

class _DoctorEditProfilePageState extends State<DoctorEditProfilePage> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _priceController = TextEditingController();
  final _bioController = TextEditingController();
  final _governorateController = TextEditingController();
  final _addressController = TextEditingController();
  String _workplaceType = 'عيادة'; // Default value
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final data = await _apiService.getMe();
      setState(() {
        _nameController.text = data['name'] ?? '';
        _specialtyController.text = data['specialty'] ?? '';
        _priceController.text = data['price'] ?? '';
        _bioController.text = data['bio'] ?? '';
        _governorateController.text = data['governorate'] ?? '';
        _addressController.text = data['address'] ?? '';
        if (data['workplaceType'] != null) {
          _workplaceType = data['workplaceType'];
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await _apiService.completeDoctorProfile(
        name: _nameController.text.trim(),
        specialty: _specialtyController.text.trim(),
        price: _priceController.text.trim(),
        bio: _bioController.text.trim(),
        workplaceType: _workplaceType,
        governorate: _governorateController.text.trim(),
        address: _addressController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ البيانات بنجاح')),
        );
        if (widget.isFirstTime) {
          Navigator.pushReplacementNamed(context, AppRoutes.doctorHome);
        } else {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: ${e.toString().replaceAll('Exception: ', '')}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تعديل الملف الشخصي')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'الاسم الكامل'),
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _specialtyController,
                decoration: const InputDecoration(labelText: 'التخصص (مثال: أسنان، أطفال)'),
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'سعر الكشف (مثال: 300 EGP)'),
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _workplaceType,
                decoration: const InputDecoration(labelText: 'مكان العمل'),
                items: ['عيادة', 'مستشفى'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _workplaceType = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _governorateController,
                decoration: const InputDecoration(labelText: 'المحافظة'),
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'العنوان بالتفصيل'),
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(labelText: 'نبذة عنك'),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text('حفظ التعديلات'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
