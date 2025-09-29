// features/auth/data/services/google_sign_in_service.dart
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
 final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '871727759193-un865a51acfobga2nbua4k1j5p9k1nst.apps.googleusercontent.com', // Web Client ID
    scopes: ['email', 'profile'],
  );

  Future<String?> getIdToken() async {
    try {
      print('Starting Google Sign-In');
      await _googleSignIn.signOut();
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
       print('Google Sign-In cancelled by user');
        return null;
      }
      print('Google Sign-In successful, getting authentication');
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        print('ID Token is null');
        return null;
      }
      print('ID Token retrieved: $idToken');
      return idToken;
    } catch (e) {
      print('Google Sign-In Error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}