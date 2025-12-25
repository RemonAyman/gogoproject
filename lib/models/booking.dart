import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String? id;
  final String doctorId;
  final String doctorName;
  final String patientId;
  final String? patientName;
  final String? patientEmail;
  final Timestamp date;        // 📅 موعد الحجز
  final String status;
  final Timestamp? createdAt;  // 🕒 وقت إنشاء الحجز

  Booking({
    this.id,
    required this.doctorId,
    required this.doctorName,
    required this.patientId,
    this.patientName,
    this.patientEmail,
    required this.date,
    this.status = 'pending',
    this.createdAt,
  });

  /// 📥 من Firestore
  factory Booking.fromMap(
      Map<String, dynamic> map, String documentId) {
    return Booking(
      id: documentId,
      doctorId: map['doctorId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'],
      patientEmail: map['patientEmail'],
      date: map['date'] as Timestamp,
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'],
    );
  }

  /// 📤 إلى Firestore
  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'doctorName': doctorName,
      'patientId': patientId,
      'patientName': patientName,
      'patientEmail': patientEmail,
      'date': date,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
