import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();

    return Scaffold(
      appBar: AppBar(title: const Text('ملفي الشخصي')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: apiService.getMe(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          }

          final data = snapshot.data;
          final name = data?['name'] ?? 'مستخدم';
          final email = data?['email'] ?? 'لا يوجد بريد';

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
                  child: Text('تم تسجيل الدخول باستخدام النظام الموحد MongoDB.'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
