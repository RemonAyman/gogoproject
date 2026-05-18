import 'package:flutter/material.dart';
import '../../core/config/routes/routes.dart';
import '../../services/api_service.dart';
import '../patient/patient_complete_profile_page.dart';
import '../doctor/doctor_edit_profile_page.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  Future<void> _selectRole(BuildContext context, String role, String route) async {
    final apiService = ApiService();
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      await apiService.updateUserRole(role);

      if (context.mounted) {
        Navigator.pop(context); // Close progress dialog
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
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close progress dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تحديد الدور: ${e.toString().replaceAll('Exception: ', '')}')),
        );
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