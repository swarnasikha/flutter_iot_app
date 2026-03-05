import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:iot_flutter_app/splash_screen.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(SteamProApp());
}

class SteamProApp extends StatelessWidget {
  const SteamProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SteamPRO',
      theme: ThemeData.dark(), // Dark theme
      // home: LoginScreen(), 
      home: SplashScreen()
    );
  }
}