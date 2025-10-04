import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userEmailKey = 'user_email';
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final GoogleSignIn _googleSignIn;
  
  AuthService() {
    _googleSignIn = GoogleSignIn.instance;
    _initializeGoogleSignIn();
  }

  void _initializeGoogleSignIn() async {
    await _googleSignIn.initialize(
      serverClientId: '52957570887-qmc89ibu0m6p1ud8rg4kdovnp0u8sjnj.apps.googleusercontent.com',
    );
  }

  // Check if user is logged in from local storage
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Get stored user email
  Future<String?> getStoredEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  // Google Sign In
  Future<User?> signInWithGoogle() async {
    try {
      UserCredential? userCredential;
      
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.setCustomParameters({'prompt': 'select_account'});
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
        if (googleUser == null) return null;
        
        final GoogleSignInAuthentication googleAuth = googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );
        
        userCredential = await _auth.signInWithCredential(credential);
      }
      
      final User? user = userCredential?.user;
      if (user != null) {
        await _saveLoginState(user.email!);
      }

      return user;
    } catch (e) {
      print('Google Sign-In Error: $e');
      return null;
    }
  }

  // Save login state to local storage
  Future<void> _saveLoginState(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_userEmailKey, email);
  }

  // Auto login (check Firebase auth state)
  Future<User?> autoLogin() async {
    try {
      if (await isLoggedIn() && _auth.currentUser != null) {
        return _auth.currentUser;
      }
      return null;
    } catch (e) {
      print('Auto login error: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
    await prefs.remove(_userEmailKey);
  }

  // Get current user
  User? get currentUser => _auth.currentUser;
}