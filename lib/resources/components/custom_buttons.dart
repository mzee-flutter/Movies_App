import 'package:flutter/material.dart';

class CustomButtons extends StatelessWidget {
  const CustomButtons({
    super.key,
    required this.onPress,
    required this.buttonColor,
    required this.height,
    required this.width,
    required this.child,
    required this.isLoading,
  });

  final Function() onPress;
  final Color buttonColor;
  final double height;
  final double width;
  final Widget child;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator(
                  color: Colors.white,
                )
              : child,
        ),
      ),
    );
  }
}
