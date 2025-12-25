import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MyAppointmentsPage extends StatelessWidget {
  const MyAppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('مواعيدي')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('patientId', isEqualTo: user?.uid)
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('حدث خطأ'));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('لا توجد مواعيد محجوزة'));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final date = DateTime.parse(data['date']);
              final status = data['status'] ?? 'pending';

              String statusText = 'قيد الانتظار';
              Color statusColor = Colors.orange;

              if (status == 'confirmed') {
                statusText = 'مؤكد';
                statusColor = Colors.green;
              } else if (status == 'cancelled') {
                statusText = 'ملغي';
                statusColor = Colors.red;
              }

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: Icon(Icons.event_note, color: statusColor),
                  title: Text('د. ${data['doctorName'] ?? 'غير معروف'}'),
                  subtitle: Text(DateFormat('yyyy-MM-dd hh:mm a').format(date)),
                  trailing: Text(
                    statusText,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}