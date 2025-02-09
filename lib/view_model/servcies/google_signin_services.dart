import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../../utilities/utils/utils.dart';
import '../auth_view_model.dart';

class GoogleSignInServices {
  ValueNotifier<bool> isProcess = ValueNotifier<bool>(false);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  Future<User?> signInWithGoogle(context) async {
    final authProvider = Provider.of<AuthViewModel>(context, listen: false);
    isProcess.value = true;
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final token = googleAuth.idToken;
      authProvider.saveToken(token ?? '');

      return userCredential.user;
    } catch (e) {
      isProcess.value = false;
      if (kDebugMode) {
        print(e.toString());
        Utils.flutterFlushBar(context, 'Google account not found');
      }
    } finally {
      isProcess.value = false;
    }
    return null;
  }
}
