import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:movies/utilities/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utilities/routes/routes_name.dart';

class AuthViewModel with ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool _isVisible = true;
  bool get isLoading => _isLoading;
  bool get isVisible => _isVisible;

  void toggleLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void isPasswordVisible() {
    _isVisible = !_isVisible;
    notifyListeners();
  }

  Future<String?> register(context, String email, String password) async {
    toggleLoading(true);
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      String? token = await userCredential.user?.getIdToken();
      if (token != null) {
        await saveToken(token);
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutesName.homeScreen,
          (route) => false,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
        Utils.flutterFlushBar(context, e.toString());
      }
    } finally {
      toggleLoading(false);
    }
    return null;
  }

  Future<String?> login(context, String email, String password) async {
    toggleLoading(true);
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      String? token = await userCredential.user?.getIdToken();
      if (token != null) {
        await saveToken(token);
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutesName.homeScreen,
          (route) => false,
        );

        return token;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }

      Utils.flutterFlushBar(context, e.toString());
    } finally {
      toggleLoading(false);
    }
    return null;
  }

  Future<void> saveToken(String token) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('auth_token', token);
    notifyListeners();
    if (kDebugMode) {
      print('token saved successfully');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    notifyListeners();
    print('logout successfully');
  }

  Future<bool> isUserLoggedIn() async {
    final pref = await SharedPreferences.getInstance();
    return pref.containsKey('auth_token') || _auth.currentUser != null;
  }
}
