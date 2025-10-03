import 'package:firebase_auth/firebase_auth.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential?> signInWithGoogle() async {
    final GoogleAuthProvider googleProvider = GoogleAuthProvider();
    
    googleProvider.addScope('https://www.googleapis.com/auth/contacts.readonly');
    googleProvider.setCustomParameters({
      'login_hint': 'user@example.com'
    });
    
    return await _auth.signInWithPopup(googleProvider);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}