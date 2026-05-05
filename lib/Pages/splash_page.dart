import 'package:flutter/material.dart';
import 'package:my_fyp/Caregiver/Screens/setup_hub_screen.dart';
import 'package:my_fyp/Pages/sign_up_page.dart';
import 'package:my_fyp/Patient/patient_home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  int _tapCount = 0;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _startFlow();
  }

  Future<void> _startFlow() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted || _hasNavigated) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');

    _hasNavigated = true;

    if (email != null) {
      _navigate(const PatientHomePage());
    } else {
      _navigate(const SignupPage());
    }
  }

  void _navigate(Widget page) {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  void _handleTap() {
    if (_hasNavigated) return;

    _tapCount++;

    // Reset taps after short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _tapCount = 0;
    });

    if (_tapCount == 3) {
      _hasNavigated = true;
      _navigate(const SetupHubScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: GestureDetector(
        onTap: _handleTap,
        behavior: HitTestBehavior.opaque, // 👈 important
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.black),
              SizedBox(height: 20),
              Text(
                "Calm Mind",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}