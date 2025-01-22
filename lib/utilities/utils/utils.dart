import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Utils {
  static void changeFocusTo(
      BuildContext context, FocusNode currentNode, FocusNode nextNode) {
    currentNode.unfocus();
    FocusScope.of(context).requestFocus(nextNode);
  }

  ///FlutterToast, FlutterFlushBar and ScaffoldMessenger are used for the same purpose displaying pop-up.
  static flutterToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  static flutterFlushBar(BuildContext context, String message) {
    Flushbar(
      backgroundColor: Colors.red,
      titleColor: Colors.white,
      // message: message,
      messageText: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      messageColor: Colors.white,
      icon: const Icon(
        Icons.error,
        color: Colors.white,
      ),
      duration: const Duration(seconds: 2),
      borderRadius: BorderRadius.circular(10),
    ).show(context);
  }

  static scaffoldMessenger(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        content: Center(
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
