// features/auth/data/services/google_sign_in_service.dart
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '871727759193-un865a51acfobga2nbua4k1j5p9k1nst.apps.googleusercontent.com', // Web Client ID
    scopes: ['email', 'profile'],
  );

  Future<String?> getIdToken() async {
    try {
      await _googleSignIn.signOut();
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        return null;
      }

      return idToken;
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
