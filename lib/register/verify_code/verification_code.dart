import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/constants/constants.dart';
import 'package:flutter_app/database/database_service.dart';
import 'package:flutter_app/localization/localization.dart';
import 'package:flutter_app/register/new_register/new_register_screen.dart';
import 'package:flutter_app/register/phone_number/phone_number.dart';
import 'package:flutter_app/ui_screens/5_stream_builder_check_login_state/signgin_models/users.dart';
import 'package:flutter_app/ui_screens/screens.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../database/database_service.dart';

class VerificationCode extends StatefulWidget {
  @override
  VerificationCodeState createState() => VerificationCodeState();
}

class VerificationCodeState extends State<VerificationCode>
    with TickerProviderStateMixin {
  var onTapRecognizer;
  var loginPageMethods = PhoneNumberState();

  TextEditingController textEditingController = TextEditingController();

  // ignore: close_sinks
  StreamController<ErrorAnimationType> errorController;
  bool buttonState;

  bool hasError = false;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  AnimationController controller;
  static String otp = '';
  static Future<bool> checkExist() async {
    bool exists = false;

    try {
      await FirebaseFirestore.instance
          .collection('userData')
          .doc(PhoneNumberState.phoneNumber)
          .get()
          .then((doc) {
        print(doc.data());
        if (doc.exists) {
          exists = true;
          DatabaseService().logInState(PhoneNumberState.phoneNumber);
          print('User ${PhoneNumberState.phoneNumber} EXISTS');
        } else {
          print(doc.data());
          exists = false;
          DatabaseService().createUser();
          print('User ${PhoneNumberState.phoneNumber} does not EXIST');
        }
      });
      return exists;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> authStateCheck(BuildContext context) async {
    bool authState = false;

    try {
      await FirebaseFirestore.instance
          .collection('userData')
          .doc(PhoneNumberState.phoneNumber)
          .get()
          .then((doc) {
        if (doc.exists) {
          authState = true;
          print('doc ex');
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => HomeScreen()));
        } else {
          return WelcomeScreen();
        }
      });
      return authState;
    } catch (e) {
      return false;
    }
  }

  bool otpState = false;
  @override
  void initState() {
    super.initState();
    _listenOtp();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth _auth = FirebaseAuth.instance;
    var sizeX = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 200.0,
            top: 0.0,
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height / 30,
                  bottom: MediaQuery.of(context).size.height / 15,
                ),
                child: Text(
                  AppLocalization.of(context)
                      .getTranslatedValue("sms_protection"),
                  style: TextStyle(
                    fontSize: sizeX.height / 40,
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 50.0,
            top: 0.0,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 115,
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
                      child: PinFieldAutoFill(
                          decoration: UnderlineDecoration(
                            textStyle: TextStyle(
                              fontSize: 20,
                              color: ConstColors.mainColor,
                            ),
                            colorBuilder: FixedColorBuilder(
                              ConstColors.mainColor,
                            ),
                          ),
                          codeLength: 6,
                          onCodeChanged: (value) async {
                            otp = value;
                            print(RegisterScreenState.verificationID);
                            Timer(Duration(seconds: 3), () async {
                              AuthCredential credential =
                                  PhoneAuthProvider.credential(
                                      verificationId:
                                          RegisterScreenState.verificationID,
                                      smsCode: otp);

                              UserCredential result =
                                  await _auth.signInWithCredential(credential);

                              User user = result.user;

                              if (user != null) {
                                checkExist();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            LoginStateCheck()));
                              } else {
                                print("Error");
                              }
                            });
                          }),
                    ),
                  ),
                  progressIndicator()
                ],
              ),
            ),
          ),
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: Center(
                child: InkWell(
                  onTap: () {},
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalization.of(context)
                                .getTranslatedValue("havent_code"),
                            style: TextStyle(
                              fontSize: sizeX.height / 55,
                              color: Colors.black,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          Text(
                            AppLocalization.of(context)
                                .getTranslatedValue("send_again"),
                            style: TextStyle(
                              fontSize: sizeX.height / 55,
                              color: ConstColors.registerTextColor,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _listenOtp() async {
    await SmsAutoFill().listenForCode;
    setState(() {});
  }

  Widget progressIndicator() {
    return CircularProgressIndicator(
      backgroundColor: ConstColors.mainColor,
    );
  }
}
