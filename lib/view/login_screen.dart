import 'package:flutter/material.dart';
import 'package:movies/resources/components/custom_buttons.dart';
import 'package:movies/utilities/utils/utils.dart';
import 'package:movies/view_model/auth_view_model.dart';
import 'package:movies/view_model/servcies/google_signin_services.dart';
import 'package:provider/provider.dart';
import '../utilities/app_color.dart';
import '../utilities/routes/routes_name.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final GoogleSignInServices _googleSignInServices = GoogleSignInServices();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  FocusNode emailNode = FocusNode();
  FocusNode passwordNode = FocusNode();

  @override
  void dispose() {
    super.dispose();

    emailController.dispose();
    passwordController.dispose();
    emailNode.dispose();
    passwordNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AuthViewModel authProvider = Provider.of<AuthViewModel>(context);
    final height = MediaQuery.of(context).size.height * 1;
    final width = MediaQuery.of(context).size.width * 1;
    return Scaffold(
      backgroundColor: appColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      height: 130,
                      width: 130,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: AssetImage(
                              'images/movielogin.png',
                            ),
                            fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height * .05,
                  ),
                  const Text(
                    'Login',
                    style: TextStyle(
                      color: whiteColor,
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Text(
                    'Welcome, please login to continue',
                    style: TextStyle(
                      color: whiteColor,
                    ),
                  ),
                  SizedBox(
                    height: height * .02,
                  ),
                  Container(
                    height: height * .065,
                    child: TextFormField(
                      focusNode: emailNode,
                      controller: emailController,
                      style: const TextStyle(
                        color: whiteColor,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Email or Phone',
                        labelStyle: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7),
                          borderSide: const BorderSide(color: whiteColor),
                        ),
                      ),
                      onFieldSubmitted: (value) {
                        Utils.changeFocusTo(context, emailNode, passwordNode);
                      },
                      cursorColor: whiteColor,
                    ),
                  ),
                  SizedBox(
                    height: height * .03,
                  ),
                  Container(
                    height: height * .065,
                    child: TextFormField(
                      focusNode: passwordNode,
                      controller: passwordController,
                      obscureText: authProvider.isVisible,
                      obscuringCharacter: '*',
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7),
                          borderSide: const BorderSide(
                            color: whiteColor,
                          ),
                        ),
                        suffixIcon: InkWell(
                          splashColor: Colors.transparent,
                          onTap: () {
                            authProvider.isPasswordVisible();
                          },
                          child: authProvider.isVisible
                              ? const Icon(
                                  Icons.visibility_off,
                                )
                              : const Icon(Icons.visibility),
                        ),
                        suffixIconColor: Colors.grey,
                      ),
                      cursorColor: whiteColor,
                    ),
                  ),
                  SizedBox(
                    height: height * .04,
                  ),
                  CustomButtons(
                    onPress: () {
                      if (emailController.text.isEmpty) {
                        Utils.flutterFlushBar(context, 'Enter your email');
                      } else if (passwordController.text.isEmpty) {
                        Utils.flutterToast('Enter your password');
                      } else if (passwordController.text.length < 6) {
                        Utils.scaffoldMessenger(
                            context, 'password must be at least 6-digit');
                      } else {
                        authProvider.login(
                          context,
                          emailController.text.toString(),
                          passwordController.text.toString(),
                        );
                      }
                    },
                    buttonColor: redColor,
                    height: height * .065,
                    width: width,
                    isLoading: authProvider.isLoading,
                    child: const Text(
                      'LOGIN',
                      style: TextStyle(
                        color: whiteColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey,
                          endIndent: 5,
                        ),
                      ),
                      Text(
                        'or',
                        style: TextStyle(
                          color: whiteColor,
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey,
                          indent: 5,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: height * .04,
                  ),
                  CustomButtons(
                    onPress: () async {
                      final user =
                          await _googleSignInServices.signInWithGoogle(context);
                      if (user != null) {
                        Navigator.pushNamed(context, RoutesName.homeScreen);
                      } else {
                        Utils.flutterFlushBar(context, 'Login failed');
                      }
                    },
                    buttonColor: Colors.white70,
                    height: height * .065,
                    width: width,
                    isLoading: false,
                    child: _googleSignInServices.isProcess.value == true
                        ? const CircularProgressIndicator(
                            color: Colors.grey,
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image(
                                image: const AssetImage(
                                  'images/google1.png',
                                ),
                                height: height * .06,
                                width: height * .06,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(
                                width: height * .01,
                              ),
                              const Text(
                                'Sign in with Google',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                  ),
                  SizedBox(
                    height: height * .1,
                  ),
                  Center(
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, RoutesName.signupScreen);
                      },
                      child: const Text(
                        'Don\'t have an account? Sign Up',
                        style: TextStyle(
                          color: whiteColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
