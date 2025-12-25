import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/config/routes/routes.dart';

class PatientCompleteProfilePage extends StatefulWidget {
  const PatientCompleteProfilePage({super.key});

  @override
  State<PatientCompleteProfilePage> createState() => _PatientCompleteProfilePageState();
}

class _PatientCompleteProfilePageState extends State<PatientCompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _painLocationController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Here we update the user doc which should already have role: 'patient'
        // We add the extra details.
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'age': _ageController.text.trim(),
          'painLocation': _painLocationController.text.trim(),
          'description': _descriptionController.text.trim(),
          'profileCompleted': true, // Flag to skip this page later
        }, SetOptions(merge: true));

        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.patientHome);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('استكمال بيانات المريض')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'السن'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _painLocationController,
                decoration: const InputDecoration(labelText: 'مكان الألم (مثال: الظهر، الرأس)'),
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'وصف الحالة'),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text('حفظ ومتابعة'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
