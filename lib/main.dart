import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_fyp/Service/hive_service.dart';
import 'package:my_fyp/Pages/splash_page.dart';
import 'firebase_options.dart';
import 'package:my_fyp/Services/notification_service.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  await HiveService.init();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashPage(),
    );
  }
}