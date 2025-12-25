import 'package:flutter/material.dart';
import 'core/thema.dart';
import 'core/config/routes/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const DocLineApp());
}


class DocLineApp extends StatelessWidget {
  const DocLineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const SplashScreen(),
      routes: AppRoutes.routes,
    );
  }
}


