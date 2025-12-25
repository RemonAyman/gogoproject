import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/config/routes/routes.dart';
import 'appointment_screen.dart';
import 'doctor_edit_profile_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم الطبيب'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DoctorEditProfilePage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('doctorId', isEqualTo: user?.uid) // نفترض أن uid الطبيب محفوظ في الحجز
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('حدث خطأ'));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('لا توجد مواعيد قادمة'));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final date = DateTime.parse(data['date']);
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(data['patientEmail'] ?? 'مريض'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${date.year}-${date.month}-${date.day} | ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'),
                      if (data['description'] != null && data['description'].isNotEmpty)
                         Text(
                          data['description'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      Text('الحالة: ${data['status'] ?? 'pending'}',
                          style: TextStyle(
                            color: data['status'] == 'confirmed'
                                ? Colors.green
                                : data['status'] == 'cancelled'
                                    ? Colors.red
                                    : Colors.orange,
                          )),
                    ],
                  ),
                  trailing: data['status'] == 'pending'
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check_circle, color: Colors.green),
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('appointments')
                                    .doc(docs[index].id)
                                    .update({'status': 'confirmed'});
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('appointments')
                                    .doc(docs[index].id)
                                    .update({'status': 'cancelled'});
                              },
                            ),
                          ],
                        )
                      : const Icon(Icons.info, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}