import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter_app/constants/constants.dart';

void showCustomFlushbar(BuildContext context, String message) {
  Flushbar(
    message: message,
    flushbarPosition: FlushbarPosition.TOP,
    margin: EdgeInsets.fromLTRB(15, 15, 15, 15),
    borderRadius: 8,
    duration: Duration(seconds: 2),
    backgroundGradient: ConstColors.saveUserStateInGroup,
    boxShadows: [
      BoxShadow(
        color: Colors.black45,
        offset: Offset(3, 3),
        blurRadius: 3,
      )
    ],
  )
    ..message
    ..show(context);
}
