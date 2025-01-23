import 'package:flutter/material.dart';
import 'package:movies/utilities/routes/routes_name.dart';

import 'package:movies/view/movies_category_screen.dart';
import 'package:movies/view/signup_screen.dart';
import 'package:movies/view/splash_screen.dart';
import 'package:movies/view/tvShows_category_screen.dart';
import '../../view/home_screen.dart';
import '../../view/login_screen.dart';

class Routes {
  static Route<dynamic> generateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.loginScreen:
        return MaterialPageRoute(
            builder: (BuildContext context) => const LoginScreen());

      case RoutesName.homeScreen:
        return MaterialPageRoute(
            builder: (BuildContext context) => const HomeScreen());

      case RoutesName.signupScreen:
        return MaterialPageRoute(
            builder: (BuildContext context) => const SignUpScreen());
      case RoutesName.splashScreen:
        return MaterialPageRoute(builder: (context) => const SplashScreen());

      case RoutesName.moviesCategoryScreen:
        return MaterialPageRoute(
            builder: (context) => const MoviesCategoryScreen());

      case RoutesName.tvShowsCategoryScreen:
        return MaterialPageRoute(
            builder: (context) => const TvShowsCategoryScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('no routes to this page'),
            ),
          ),
        );
    }
  }
}
