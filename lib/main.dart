import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'SplashScreen.dart';

void main() async {
  // تأكد من تهيئة Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase قبل تشغيل التطبيق
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // تشغيل التطبيق
  runApp(const HospitalApp());
}

class HospitalApp extends StatelessWidget {
  const HospitalApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Online Hospital',
      theme: ThemeData(
        primaryColor: const Color(0xFF1E88E5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          primary: const Color(0xFF1E88E5),
          secondary: const Color(0xFF26C6DA),
        ),
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
          displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
          bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF666666)),
          bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF666666)),
        ),
      ),
      home: SplashScreen(),
    );
  }
}
