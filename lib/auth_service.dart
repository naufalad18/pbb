import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart'; // 1. Import Tambahan

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // --- FUNGSI LOGIN GOOGLE ---
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print("Error Login Google: $e");
      return null;
    }
  }

  // --- FUNGSI LOGIN FACEBOOK (BARU) ---
  Future<User?> signInWithFacebook() async {
    try {
      // 1. Memicu dialog login Facebook
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['public_profile', 'email'],
      );

      // 2. Cek status login
      if (result.status == LoginStatus.success) {
        // Dapat Access Token dari Facebook
        final AccessToken accessToken = result.accessToken!;

        // 3. Buat credential untuk Firebase
        final OAuthCredential credential = FacebookAuthProvider.credential(
          accessToken.tokenString,
        );

        // 4. Masuk ke Firebase
        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);

        return userCredential.user;
      } else if (result.status == LoginStatus.cancelled) {
        print("Login Facebook dibatalkan user");
        return null;
      } else {
        print("Login Facebook Gagal: ${result.message}");
        return null;
      }
    } catch (e) {
      print("Error Login Facebook: $e");
      return null;
    }
  }

  // --- FUNGSI LOGOUT (UPDATE) ---
  Future<void> signOut() async {
    await _googleSignIn.signOut(); // Keluar Google
    await FacebookAuth.instance.logOut(); // Keluar Facebook (Tambahan)
    await _auth.signOut(); // Keluar Firebase
  }

  // Cek status login secara real-time
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
