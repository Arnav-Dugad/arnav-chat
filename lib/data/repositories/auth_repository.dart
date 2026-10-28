import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/config/env.dart';

class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;
  @override
  String toString() => message;
}

class AuthRepository {
  AuthRepository(this._auth);

  final FirebaseAuth _auth;
  bool _googleReady = false;

  Stream<User?> authState() => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        await _auth.signInWithPopup(GoogleAuthProvider());
        return;
      }
      final google = GoogleSignIn.instance;
      if (!_googleReady) {
        await google.initialize(serverClientId: Env.googleServerClientId.isEmpty ? null : Env.googleServerClientId);
        _googleReady = true;
      }
      final account = await google.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) throw const AuthFailure('Google sign-in failed');
      await _auth.signInWithCredential(GoogleAuthProvider.credential(idToken: idToken));
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) throw const AuthFailure('Cancelled');
      throw AuthFailure(e.description ?? 'Google sign-in failed');
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_message(e));
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        // Unknown email → create the account (single "Continue" flow).
        try {
          await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
          return;
        } on FirebaseAuthException catch (e2) {
          if (e2.code == 'email-already-in-use') throw const AuthFailure('Wrong password');
          throw AuthFailure(_message(e2));
        }
      }
      throw AuthFailure(_message(e));
    }
  }

  Future<void> sendPasswordReset(String email) => _auth.sendPasswordResetEmail(email: email.trim());

  Future<void> signOut() async {
    if (!kIsWeb && _googleReady) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}
    }
    await _auth.signOut();
  }

  static String _message(FirebaseAuthException e) => switch (e.code) {
    'invalid-email' => 'Invalid email',
    'weak-password' => 'Password too short',
    'wrong-password' || 'invalid-credential' => 'Wrong password',
    'too-many-requests' => 'Try again later',
    'network-request-failed' => 'No connection',
    'user-disabled' => 'Account disabled',
    _ => e.message ?? 'Sign-in failed',
  };
}
