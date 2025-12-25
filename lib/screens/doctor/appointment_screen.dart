import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';

class AppointmentScreen extends StatelessWidget {
  final String appointmentId;
  AppointmentScreen({super.key, required this.appointmentId});

  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _updateStatus(
      BuildContext context, String status) async {
    try {
      await _firestoreService.updateAppointmentStatus(
        appointmentId,
        status,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تغيير الحالة إلى: $status')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء التحديث')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الموعد')),
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestoreService.getAppointmentById(appointmentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('الموعد غير موجود'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final Timestamp timestamp = data['date'];
          final DateTime date = timestamp.toDate();

          final String status = data['status'] ?? 'pending';

          Color statusColor;
          switch (status) {
            case 'confirmed':
              statusColor = Colors.green;
              break;
            case 'cancelled':
              statusColor = Colors.red;
              break;
            default:
              statusColor = Colors.orange;
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المريض: ${data['patientEmail'] ?? 'غير معروف'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text('التاريخ: ${date.year}-${date.month}-${date.day}', style: const TextStyle(fontSize: 16)),
                Text(
                    'الوقت: ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 12),
                if (data['price'] != null && data['price'].isNotEmpty)
                  Text('سعر الكشف: ${data['price']}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                const SizedBox(height: 12),
                const Text('وصف الشكوى:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(data['description'] ?? 'لا يوجد وصف', style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 20),
                Text(
                  'الحالة الحالية: $status',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () =>
                          _updateStatus(context, 'cancelled'),
                      child: const Text(
                        'رفض الموعد',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      onPressed: () =>
                          _updateStatus(context, 'confirmed'),
                      child: const Text(
                        'قبول الموعد',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
