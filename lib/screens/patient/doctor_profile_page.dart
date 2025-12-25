import 'package:flutter/material.dart';
import 'appointment_booking_page.dart';

class DoctorProfilePage extends StatelessWidget {
  final dynamic doctor;
  const DoctorProfilePage({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ملف الطبيب')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50))),
            const SizedBox(height: 20),
            Text('الاسم: ${doctor['name'] ?? 'غير متوفر'}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('التخصص: ${doctor['specialization'] ?? 'عام'}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AppointmentBookingPage(doctor: doctor)),
                  );
                },
                child: const Text('حجز موعد'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}