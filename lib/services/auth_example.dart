// Example usage of AuthService
import 'auth_service.dart';

class AuthExample {
  final AuthService _authService = AuthService();

  // Check if user is already logged in
  Future<bool> checkLoginStatus() async {
    return await _authService.isLoggedIn();
  }

  // Sign in with Google
  Future<void> signIn() async {
    final user = await _authService.signInWithGoogle();
    if (user != null) {
      print('Signed in: ${user.email}');
    }
  }

  // Auto login (silent)
  Future<void> tryAutoLogin() async {
    final user = await _authService.autoLogin();
    if (user != null) {
      print('Auto login successful: ${user.email}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _authService.signOut();
    print('Signed out successfully');
  }
}