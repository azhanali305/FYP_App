import 'package:flutter/material.dart';
import 'package:my_fyp/services/auth_service.dart';
import 'package:my_fyp/pages/splash_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome!",
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            IconButton(
              icon: const Icon(Icons.logout, size: 30),
              onPressed: () async {
                // Logout user
                await AuthService().logout();

                // Navigate back to SplashPage
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SplashPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}