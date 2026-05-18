import 'package:flutter/material.dart';
import '../../../screens/auth/login_page.dart';
import '../../../screens/auth/signup_page.dart';
import '../../../screens/auth/role_selection_page.dart';
import '../../../screens/patient/doctor_list_page.dart';
import '../../../screens/doctor/dashboard_page.dart';
import '../../../screens/doctor/appointment_screen.dart';
import '../../../screens/patient/doctor_profile_page.dart';
import '../../../screens/patient/appointment_booking_page.dart';
import '../../../screens/patient/my_appointments_page.dart';
import '../../../screens/settings/settings_page.dart';
import '../../../screens/patient/patient_profile_page.dart';
import '../../../screens/patient/specialties_grid_page.dart';
import '../../../screens/admin/admin_dashboard_page.dart';

class AppRoutes {
  static const login = '/login';
  static const signup = '/signup';
  static const role = '/role';
  static const patientHome = '/patient';
  static const doctorHome = '/doctor';
  static const doctorAppointments = '/doctor/appointments';
  static const doctorProfile = '/patient/doctor_profile';
  static const bookAppointment = '/patient/book';
  static const myAppointments = '/patient/my_appointments';
  static const settings = '/settings';
  static const patientProfile = '/patient/profile';

  static Map<String, WidgetBuilder> routes = {
    login: (_) => const LoginPage(),
    signup: (_) => const SignUpPage(),
    role: (_) => const RoleSelectionPage(),
    patientHome: (_) => const SpecialtiesGridPage(),
    '/patient/doctors_list': (_) => const DoctorListPage(),
    '/admin/dashboard': (_) => const AdminDashboardPage(),
    doctorHome: (_) => const DashboardPage(),
    doctorAppointments: (ctx) {
      final args = ModalRoute.of(ctx)!.settings.arguments;
      if (args != null && args is String) {
        return AppointmentScreen(appointmentId: args);
      }
      return const DashboardPage();
    },
    doctorProfile: (ctx) {
      final args = ModalRoute.of(ctx)!.settings.arguments;
      if (args != null) {
        return DoctorProfilePage(doctor: args as dynamic);
      }
      return const DoctorListPage();
    },
    bookAppointment: (ctx) {
      final args = ModalRoute.of(ctx)!.settings.arguments;
      return AppointmentBookingPage(doctor: args as dynamic);
    },
    myAppointments: (_) => const MyAppointmentsPage(),
    settings: (_) => const SettingsPage(),
    patientProfile: (_) => const PatientProfilePage(),
  };
}
