import 'dart:ui';

import 'package:flutter/material.dart';

class ConstColors {
  ConstColors._();

  static const Color mainColor = Color.fromRGBO(149, 221, 229, 1);
  static const Color welcomeIndicator = Color.fromRGBO(99, 240, 255, 1);
  static const Color registerTextColor = Color.fromRGBO(10, 200, 204, 1);
  static const Color phoneButtonTextColor = Color.fromRGBO(99, 240, 255, 1);
  static const Color searchColor = Color.fromRGBO(60, 60, 87, 0.8);
  static const Color searchTypesColor = Color.fromRGBO(112, 112, 112, 0.95);
  static const Color search = Color.fromRGBO(61, 201, 191, 1);
  static const Color textColor = Color.fromRGBO(61, 58, 83, 1);
  static const Color subColor = Color.fromRGBO(61, 201, 185, 1);
  static const Color groupsOnLogs = Color.fromRGBO(61, 58, 83, 1);
  static const Color lightBlue = Color.fromRGBO(240, 250, 255, 1);
  static const Color deepBlue = Color.fromRGBO(230, 250, 255, 1);

  static const LinearGradient saveUserStateInGroup = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.fromRGBO(154, 222, 231, 1),
      Color.fromRGBO(61, 201, 185, 1),
    ],
  );
}
