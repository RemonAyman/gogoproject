import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/fake_data.dart';

class FirestoreSeeder {
  static Future<void> seedDoctors() async {
    final CollectionReference users =
        FirebaseFirestore.instance.collection('users');

    // Check if we already have doctors seeded
    final QuerySnapshot doctorSnapshot =
        await users.where('role', isEqualTo: 'doctor').limit(1).get();

    if (doctorSnapshot.docs.isNotEmpty) {
      // Data already exists, skip seeding
      return;
    }

    // Seed data
    for (var doctor in gDoctors) {
      // storing them with their specific IDs so we don't duplicate easily if ran again with different check
      await users.doc(doctor.id).set({
        'uid': doctor.id,
        'name': doctor.name,
        'email': 'doctor_${doctor.id}@demo.com', // Fake email for demo
        'role': 'doctor',
        'specialty': doctor.specialty,
        'price': doctor.price,
        'bio': doctor.bio,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
