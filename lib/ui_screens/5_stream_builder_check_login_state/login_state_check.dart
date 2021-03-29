import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/ui_screens/2_welcome_screen/welcome_screen.dart';
import 'package:flutter_app/ui_screens/5_stream_builder_check_login_state/signgin_models/users.dart';
import 'package:flutter_app/ui_screens/screens.dart';
import 'package:provider/provider.dart';

class LoginStateCheck extends StatefulWidget {
  @override
  _LoginStateCheckState createState() => _LoginStateCheckState();
}

class _LoginStateCheckState extends State<LoginStateCheck> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<Users>(context);

    if (user == null) {
      return WelcomeScreen();
    } else {
      return HomeScreen();
    }
  }
}
