import 'package:flutter/material.dart';
import 'package:movies/view/login_screen.dart';
import 'package:movies/view_model/auth_view_model.dart';
import 'package:provider/provider.dart';
import '../utilities/app_color.dart';
import '../utilities/routes/routes_name.dart';

class DrawerView extends StatelessWidget {
  const DrawerView({
    super.key,
    required this.height,
  });
  final double height;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: appColor,
      child: Padding(
        padding: EdgeInsets.only(top: height * .05),
        child: Column(
          children: [
            Container(
              height: height * .2,
              width: double.infinity,
              color: Colors.blue,
              child: const Image(
                image: AssetImage('images/movielogo.png'),
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    DrawerFields(
                      onTap: () {},
                      icon: Icons.rocket_launch_rounded,
                      title: 'Discover',
                    ),
                    DrawerFields(
                      onTap: () {
                        Navigator.pushNamed(
                            context, RoutesName.moviesCategoryScreen);
                      },
                      icon: Icons.local_movies,
                      title: 'Movies',
                    ),
                    DrawerFields(
                      onTap: () {
                        Navigator.pushNamed(
                            context, RoutesName.tvShowsCategoryScreen);
                      },
                      icon: Icons.tv,
                      title: 'Tv Shows',
                    ),
                    DrawerFields(
                      onTap: () {},
                      icon: Icons.collections_bookmark,
                      title: 'Watchlist',
                    ),
                    DrawerFields(
                      onTap: () {},
                      icon: Icons.archive,
                      title: 'Collection',
                    ),
                    DrawerFields(
                      onTap: () {},
                      icon: Icons.history,
                      title: 'Recent',
                    ),
                    DrawerFields(
                      onTap: () {},
                      icon: Icons.settings_outlined,
                      title: 'Setting',
                    ),
                    Consumer<AuthViewModel>(
                      builder: (context, authProvider, child) {
                        return DrawerFields(
                          onTap: () {
                            authProvider.logout();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          icon: Icons.logout,
                          title: 'Log out',
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DrawerFields extends StatelessWidget {
  const DrawerFields({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return InkWell(
      splashColor: Colors.transparent,
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: whiteColor,
              ),
              SizedBox(
                width: height * .05,
              ),
              Text(
                title,
                style: const TextStyle(
                  color: whiteColor,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          SizedBox(
            height: height * .04,
          ),
        ],
      ),
    );
  }
}
