import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sign Up
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save email in SharedPreferences for auto-login
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email);

      return userCredential.user;
    } catch (e) {
      print("SignUp Error: $e");
      return null;
    }
  }

  /// Sign In
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save email in SharedPreferences for auto-login
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email);

      return userCredential.user;
    } catch (e) {
      print("SignIn Error: $e");
      return null;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      // Remove email from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('email');

      // Sign out from Firebase
      await _auth.signOut();
    } catch (e) {
      print("Logout Error: $e");
    }
  }

  /// Check if user is logged in (persistent login)
  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    return email != null;
  }

  /// Get current logged-in email
  Future<String?> getCurrentUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }
}