import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final GoogleSignIn _googleSignIn;
  
  GoogleAuthService() {
    _initializeGoogleSignIn();
  }

  void _initializeGoogleSignIn() async {
    _googleSignIn = GoogleSignIn.instance;
    await _googleSignIn.initialize(
      serverClientId: '52957570887-qmc89ibu0m6p1ud8rg4kdovnp0u8sjnj.apps.googleusercontent.com',
    );
  }

  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (_auth.currentUser != null) {
        return null; // Already signed in
      }
      
      UserCredential? userCredential;
      
      if (kIsWeb) {
        // Web implementation
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.setCustomParameters({'prompt': 'select_account'});
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        // Mobile implementation
        final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
        if (googleUser == null) return null;
        
        final GoogleSignInAuthentication googleAuth = googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );
        
        userCredential = await _auth.signInWithCredential(credential);
      }
      
      // Store user data to API
      if (userCredential?.user != null) {
        await _storeUserToApi(userCredential!.user!);
      }
      
      return userCredential;
    } catch (e) {
      print('Google Sign-In Error: $e');
      return null;
    }
  }
  
  Future<void> _storeUserToApi(User user) async {
    try {
      await ApiService.createUser({
        'full_name': user.displayName ?? '',
        'email': user.email ?? '',
      });
    } catch (e) {
      print('API Store Error: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
  }
}