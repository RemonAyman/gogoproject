import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/screens/patient/patient_complete_profile_page.dart';
import '/screens/doctor/doctor_edit_profile_page.dart';
import '../../core/config/routes/routes.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  Future<void> _selectRole(BuildContext context, String role, String route) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Set role
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'role': role,
      }, SetOptions(merge: true));

      if (context.mounted) {
        if (role == 'patient') {
           Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PatientCompleteProfilePage()),
          );
        } else if (role == 'doctor') {
           Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DoctorEditProfilePage(isFirstTime: true)),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اختر نوع الحساب')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _selectRole(context, 'patient', AppRoutes.patientHome),
              child: const Text('أنا مريض'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectRole(context, 'doctor', AppRoutes.doctorHome),
              child: const Text('أنا طبيب'),
            ),
          ],
        ),
      ),
    );
  }
}