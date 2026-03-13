import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '1049630213063-eum06jfp8t62ej7fb7gdh23l252qcj8p.apps.googleusercontent.com',
  );

  final String _emailJsServiceId = dotenv.env['EMAILJS_SERVICE_ID'] ?? '';
  final String _emailJsTemplateId = dotenv.env['EMAILJS_TEMPLATE_ID'] ?? '';
  final String _emailJsUserId = dotenv.env['EMAILJS_USER_ID'] ?? '';
  final String _emailJsPrivateKey = dotenv.env['EMAILJS_PRIVATE_KEY'] ?? '';

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      debugPrint('Password reset error: $e');
      return false;
    }
  }

  Future<bool> sendOtpEmail(String email, String otp) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    try {
      final Map<String, dynamic> requestBody = {
        'service_id': _emailJsServiceId,
        'template_id': _emailJsTemplateId,
        'user_id': _emailJsUserId,
        'template_params': {
          'to_email': email,
          'otp': otp,
        }
      };

      if (_emailJsPrivateKey.isNotEmpty) {
        requestBody['accessToken'] = _emailJsPrivateKey;
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('EmailJS Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending OTP: $e');
      return false;
    }
  }

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email,
          password: password
      );
    } catch (e) {
      debugPrint('Email sign in error: $e');
      return null;
    }
  }

  Future<UserCredential?> registerWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      debugPrint('Email registration error: $e');
      return null;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Google sign in error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }
}