import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '1049630213063-eum06jfp8t62ej7fb7gdh23l252qcj8p.apps.googleusercontent.com',
  );

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String> _getDeviceName() async {
    try {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return '${androidInfo.brand} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return iosInfo.name;
      }
    } catch (e) {
      debugPrint('Erro ao obter nome do dispositivo: $e');
    }
    return 'Dispositivo Desconhecido';
  }

  Future<void> _saveUserToFirestore(User user) async {
    try {
      final userRef = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await userRef.get();

      if (!docSnapshot.exists) {
        final String deviceName = await _getDeviceName();

        await userRef.set({
          'email': user.email ?? '',
          'deviceName': deviceName,
          'createdAt': FieldValue.serverTimestamp(),
          'isPremium': false,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Erro ao salvar dados no Firestore: $e');
    }
  }

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
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('sendOtpEmail');

      final response = await callable.call(<String, dynamic>{
        'email': email,
        'otp': otp,
      });

      if (response.data['success'] == true) {
        return true;
      }
      return false;

    } catch (e) {
      debugPrint('Error calling Cloud Function to send OTP: $e');
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
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );

      if (credential.user != null) {
        await _saveUserToFirestore(credential.user!);
      }

      return credential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      debugPrint('Email registration error: $e');
      return null;
    }
  }

  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  Future<UserCredential?> signInWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final nonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final OAuthProvider oAuthProvider = OAuthProvider('apple.com');
      final AuthCredential credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        await _saveUserToFirestore(userCredential.user!);
      }

      return userCredential;
    } catch (e) {
      debugPrint('Apple sign in error: $e');
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

      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        await _saveUserToFirestore(userCredential.user!);
      }

      return userCredential;
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