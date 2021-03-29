import 'package:flutter/material.dart';
import 'package:flutter_app/constants/constants.dart';
import 'package:flutter_app/localization/localization.dart';
import 'package:flutter_app/register/phone_number/phone_number.dart';
import 'package:flutter_app/register/verify_code/verification_code.dart';
import 'package:flutter_app/ui_screens/screens.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_app/register/verify_code/verification_code_login.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool stateValid = false;
  final _formKey = GlobalKey<FormState>();

  var loginPageMethods = PhoneNumberState();
  bool check = false;
  bool register = false;

  @override
  void initState() {
    register = false;
    RegisterScreenState.stateValid = false;
    RegisterScreenState.userEmailState = false;
    RegisterScreenState.userNameSate = false;
    RegisterScreenState.checkValid = false;
    super.initState();
  }

  bool authButtonState = false;
  @override
  Widget build(BuildContext context) {
    var sizeX = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          leading: Container(),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        body: register == false
            ? SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Column(
                  children: [
                    Form(
                      key: _formKey,
                      child: Container(
                        height: sizeX.height,
                        width: sizeX.width,
                        child: Stack(
                          children: [
                            Positioned(
                                left: 0.0,
                                top: 0.0,
                                right: 0.0,
                                child: SvgPicture.asset(
                                    'assets/icons/memobeez_logo_login.svg')),
                            Padding(
                              padding: EdgeInsets.only(top: sizeX.height / 5),
                              child: ListView(
                                physics: BouncingScrollPhysics(),
                                children: <Widget>[
                                  Text(
                                    AppLocalization.of(context)
                                        .getTranslatedValue("log_in"),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: sizeX.height / 35,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(top: sizeX.height / 15),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          stateValid == true
                                              ? Icon(
                                                  MdiIcons.exclamation,
                                                  color: Colors.redAccent,
                                                )
                                              : Container(),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                            ),
                                            child: PhoneNumber(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 80.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        authButtonState == true
                                            ? CircularProgressIndicator(
                                                backgroundColor:
                                                    ConstColors.mainColor,
                                              )
                                            : Material(
                                                elevation: 3.0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30.0),
                                                ),
                                                child: Container(
                                                  height: 45,
                                                  width: 200,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30.0),
                                                    color:
                                                        ConstColors.mainColor,
                                                  ),
                                                  // ignore: deprecated_member_use
                                                  child: FlatButton(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30.0)),
                                                    onPressed: () {
                                                      if (PhoneNumberState
                                                              .phoneNumber ==
                                                          '') {
                                                        setState(() {
                                                          RegisterScreenState
                                                                  .stateValid =
                                                              true;
                                                        });
                                                      } else {
                                                        setState(() {
                                                          authButtonState =
                                                              true;
                                                        });
                                                      }

                                                      if (_formKey.currentState
                                                          .validate()) {
                                                        if (PhoneNumberState
                                                                .phoneNumber !=
                                                            '') {
                                                          RegisterScreenState
                                                              .loginUser(
                                                                  PhoneNumberState
                                                                      .phoneNumber,
                                                                  context);
                                                        }
                                                      }
                                                    },
                                                    child: Text(
                                                      AppLocalization.of(
                                                              context)
                                                          .getTranslatedValue(
                                                              "next_button"),
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize:
                                                            sizeX.height / 55,
                                                        color: Colors.white,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              left: 0.0,
                              right: 0.0,
                              bottom: sizeX.height / 8,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 35.0, bottom: 50.0),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        WelcomThirdHelperState.login == true
                                            ? Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        RegisterScreen()))
                                            : Navigator.of(context).pop();
                                      });
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          AppLocalization.of(context)
                                              .getTranslatedValue(
                                                  "have_no_acc"),
                                          style: TextStyle(
                                            color: ConstColors.textColor,
                                            fontSize: sizeX.height / 60,
                                            decoration:
                                                TextDecoration.underline,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          AppLocalization.of(context)
                                              .getTranslatedValue("register"),
                                          style: TextStyle(
                                            color: ConstColors.mainColor,
                                            fontSize: sizeX.height / 60,
                                            decoration:
                                                TextDecoration.underline,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : RegisterScreen());
  }
}
