import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('غير مسجل الدخول')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('ملفي الشخصي')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.data() as Map<String, dynamic>?;
          final name = data?['name'] ?? 'مستخدم';
          final email = user.email ?? 'لا يوجد بريد';

          return Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                const CircleAvatar(radius: 44, child: Icon(Icons.person, size: 44)),
                const SizedBox(height: 14),
                Text(name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(email, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 18),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text('معلومات الحساب',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text('تم تسجيل الدخول باستخدام Firebase.'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
