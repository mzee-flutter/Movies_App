import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:movies/view_model/auth_view_model.dart';
import 'package:provider/provider.dart';
import '../../utilities/routes/routes_name.dart';

class UserSessionServices {
  Future<void> checkUserAuthentication(BuildContext context) async {
    final AuthViewModel authProvider =
        Provider.of<AuthViewModel>(context, listen: false);

    authProvider.isUserLoggedIn().then((isLoggedIn) async {
      if (context.mounted) {
        if (isLoggedIn) {
          await Future.delayed(const Duration(seconds: 3));
          Navigator.pushNamedAndRemoveUntil(
            context,
            RoutesName.homeScreen,
            (route) => false,
          );
        } else {
          await Future.delayed(const Duration(seconds: 3));
          Navigator.pushNamedAndRemoveUntil(
            context,
            RoutesName.loginScreen,
            (route) => false,
          );
        }
      }
    }).catchError((error) {
      if (kDebugMode) {
        print("Error checking authentication: $error");
      }
    });
  }
}
