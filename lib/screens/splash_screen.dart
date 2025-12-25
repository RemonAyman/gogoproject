import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/config/routes/routes.dart';
import '../utils/firestore_seeder.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // Artificial delay for splash effect
    await Future.delayed(const Duration(seconds: 2));

    // Seed data if needed
    await FirestoreSeeder.seedDoctors();

    if (mounted) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Check Firestore for role
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data()!.containsKey('role')) {
          final role = doc.data()!['role'];
          if (role == 'patient') {
            Navigator.pushReplacementNamed(context, AppRoutes.patientHome);
          } else if (role == 'doctor') {
            Navigator.pushReplacementNamed(context, AppRoutes.doctorHome);
          } else {
            Navigator.pushReplacementNamed(context, AppRoutes.role);
          }
        } else {
          // No role found, go to selection
          Navigator.pushReplacementNamed(context, AppRoutes.role);
        }
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.medical_services_outlined,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            const Text(
              'DocLine',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Rعاية طبية متكاملة',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
