import 'package:flutter/material.dart';
import 'package:movies/resources/components/custom_buttons.dart';
import 'package:movies/utilities/utils/utils.dart';
import 'package:movies/view_model/auth_view_model.dart';
import 'package:provider/provider.dart';
import '../utilities/app_color.dart';
import '../utilities/routes/routes_name.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  FocusNode emailNode = FocusNode();
  FocusNode passwordNode = FocusNode();
  FocusNode nameNode = FocusNode();

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
                    'Create account',
                    style: TextStyle(
                      color: whiteColor,
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    height: height * .065,
                    child: TextFormField(
                      focusNode: nameNode,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: whiteColor,
                        hintText: 'Name',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none),
                      ),
                      onFieldSubmitted: (value) {
                        Utils.changeFocusTo(context, nameNode, emailNode);
                      },
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
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none),
                        prefixIcon: const Icon(
                          Icons.alternate_email,
                        ),
                      ),
                      onFieldSubmitted: (value) {
                        Utils.changeFocusTo(context, emailNode, passwordNode);
                      },
                    ),
                  ),
                  SizedBox(
                    height: height * .02,
                  ),
                  Container(
                    height: height * .065,
                    child: TextFormField(
                      focusNode: passwordNode,
                      controller: passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: authProvider.isVisible,
                      obscuringCharacter: '*',
                      decoration: InputDecoration(
                        hintText: 'Password',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none),
                        prefixIcon: const Icon(
                          Icons.lock,
                        ),
                        suffixIcon: InkWell(
                          onTap: () {
                            authProvider.isPasswordVisible();
                          },
                          child: authProvider.isVisible
                              ? const Icon(
                                  Icons.visibility_off,
                                )
                              : const Icon(Icons.visibility),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height * .05,
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
                        authProvider.register(
                          context,
                          emailController.text.toString(),
                          passwordController.text.toString(),
                        );
                      }
                    },
                    buttonColor: redColor,
                    height: height * .07,
                    width: width,
                    isLoading: authProvider.isLoading,
                    child: const Text(
                      'SIGN UP',
                      style: TextStyle(
                        color: blackColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height * .2,
                  ),
                  Center(
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, RoutesName.loginScreen);
                      },
                      child: const Text(
                        'Already have an account? Sign In',
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
