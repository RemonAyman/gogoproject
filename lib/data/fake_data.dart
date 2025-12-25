import '../models/doctor.dart';
import '../models/booking.dart';

/* <-- UPDATED DOCTORS NAMES AS REQUESTED --> */
final List<Doctor> gDoctors = [
  Doctor(
    id: 'd1',
    name: 'Ali Abdelrahman',
    specialty: 'Cardiologist',
    price: '350 EGP',
    bio:
        'Heart diseases specialist.\n12 years experience.\nAdvanced ECG diagnosis.',
  ),
  Doctor(
    id: 'd2',
    name: 'Mohamed yamen',
    specialty: 'Dermatologist',
    price: '300 EGP',
    bio: 'Skin & hair expert.\nLaser treatment.\nModern aesthetic techniques.',
  ),
  Doctor(
    id: 'd3',
    name: 'Ahmad Ayman',
    specialty: 'Dentist',
    price: '250 EGP',
    bio: 'Cosmetic dentistry.\nRoot canal expert.\nPain-free procedures.',
  ),
  Doctor(
    id: 'd4',
    name: 'Menna Allah Ahmad',
    specialty: 'Pediatrician',
    price: '280 EGP',
    bio: 'Child health specialist.\n5 years experience.\nFriendly with kids.',
  ),
];

final List<Booking> gMyBookings = [];

// Simple current user storage (demo-only)
String? gCurrentUserName;
String? gCurrentUserEmail;
String? gAuthToken;
String? gCurrentUserPassword;

