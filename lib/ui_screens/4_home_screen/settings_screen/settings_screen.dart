import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/animations/fade_animation.dart';
import 'package:flutter_app/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/database/database_service.dart';
import 'package:flutter_app/localization/language_constants.dart';
import 'package:flutter_app/localization/localization.dart';
import 'package:flutter_app/ui_screens/4_home_screen/settings_screen/classes/language.dart';
import 'package:flutter_app/ui_screens/5_stream_builder_check_login_state/signgin_models/auth.dart';
import 'package:flutter_app/ui_screens/5_stream_builder_check_login_state/signgin_models/users.dart';
import 'package:provider/provider.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import '../../../main.dart';
import '../../screens.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SettingsScreen extends StatefulWidget {
  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  bool switchState = true;
  bool switchState2 = true;
  @override
  void initState() {
    super.initState();
    name = '';
    number = '';
  }

  String selectedLanguage;

  String name;
  String number;
  static Language language;
  static String langName = '';
  static DocumentSnapshot docSnap;
  @override
  Widget build(BuildContext context) {
    var sizeX = MediaQuery.of(context).size;

    final userState = Provider.of<Users>(context);
    if (userState == null) {
      return WelcomeScreen();
    } else {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User user = auth.currentUser;
      final String uid = user.phoneNumber;

      return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('userData')
              .doc(uid)
              .snapshots(),
          builder: (context, snapshot) {
            DocumentSnapshot documentSnapshot = snapshot.data;
            docSnap = documentSnapshot;
            if (snapshot.hasData) {
              Future allowContactsUpd() async {
                try {
                  DocumentReference documentReference = FirebaseFirestore
                      .instance
                      .collection('userData')
                      .doc(uid);
                  documentSnapshot['contactsAccess'] == false
                      ? documentReference.update({
                          'contactsAccess': true,
                        })
                      : documentReference.update({
                          'contactsAccess': false,
                        });
                } catch (e) {}
              }

              Future allowMicroUpd() async {
                final User user = auth.currentUser;
                final userId = user.phoneNumber;
                try {
                  DocumentReference documentReference = FirebaseFirestore
                      .instance
                      .collection('userData')
                      .doc(userId);
                  documentSnapshot['microAccess'] == false
                      ? documentReference.update({
                          'microAccess': true,
                        })
                      : documentReference.update({
                          'microAccess': false,
                        });
                } catch (e) {}
              }

              Future changeAppLang() async {
                final User user = auth.currentUser;
                final userId = user.phoneNumber;
                try {
                  DocumentReference documentReference = FirebaseFirestore
                      .instance
                      .collection('userData')
                      .doc(userId);
                  documentSnapshot['appLang'] == 'English'
                      ? documentReference.update({
                          'appLang': 'עברית',
                        })
                      : documentReference.update({
                          'appLang': 'English',
                        });
                } catch (e) {}
                print(documentSnapshot['appLang']);
              }

              void _changeLanguage(Language language) async {
                Locale _locale = await setLocale(language.languageCode);
                MemobeezApp.setLocale(context, _locale);
              }

              return Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  title: Text(
                    AppLocalization.of(context).getTranslatedValue("settings"),
                    style: TextStyle(
                        fontSize: sizeX.height / 45, color: Colors.black),
                  ),
                  elevation: 0.0,
                  backgroundColor: Colors.transparent,
                  leading: FadeAnimation(
                    0.5,
                    IconButton(
                      splashRadius: 20.0,
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                body: FadeAnimation(
                  0.5,
                  Stack(
                    children: <Widget>[
                      Positioned(
                        top: sizeX.height / 5,
                        left: 0.0,
                        right: 0.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                left: sizeX.width / 15,
                                right: sizeX.width / 15,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    AppLocalization.of(context)
                                        .getTranslatedValue(
                                            "allow_access_contacts"),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: sizeX.height / 55,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Switch(
                                    inactiveTrackColor: Colors.grey[300],
                                    activeTrackColor: ConstColors.mainColor,
                                    activeColor: Colors.white,
                                    value: documentSnapshot['contactsAccess'],
                                    onChanged: (value) {
                                      setState(() {
                                        allowContactsUpd();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: sizeX.width / 15,
                                right: sizeX.width / 15,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    AppLocalization.of(context)
                                        .getTranslatedValue("allow_micro"),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: sizeX.height / 55,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Switch(
                                    inactiveTrackColor: Colors.grey[300],
                                    activeTrackColor: ConstColors.mainColor,
                                    activeColor: Colors.white,
                                    value:
                                        //  switchState2,
                                        documentSnapshot['microAccess'],
                                    onChanged: (value) {
                                      setState(() {
                                        allowMicroUpd();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: sizeX.width / 15,
                                right: sizeX.width / 15,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    AppLocalization.of(context)
                                        .getTranslatedValue("switch_lang"),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: sizeX.height / 55,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  DropdownButton<Language>(
                                    hint: Text(
                                      documentSnapshot['appLang'],
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                    underline: SizedBox(),
                                    onChanged: (language) {
                                      _changeLanguage(language);
                                      setState(() {
                                        langName = language.name;
                                        changeAppLang();
                                      });
                                    },
                                    items: Language.languageList()
                                        .map<DropdownMenuItem<Language>>(
                                            (lang) => DropdownMenuItem(
                                                value: lang,
                                                child: Text(
                                                  lang.name,
                                                )))
                                        .toList(),
                                    icon: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 5.0, right: 10.0, bottom: 0.0),
                                      child: SvgPicture.asset(
                                        'assets/icons/icon_arrow_dropdown.svg',
                                        height: 15.0,
                                        width: 15.0,
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
                        bottom: sizeX.height / 10,
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Material(
                                  elevation: 3.0,
                                  borderRadius: BorderRadius.circular(25.0),
                                  child: Container(
                                    height: 45,
                                    width: 190,
                                    decoration: BoxDecoration(
                                      color: ConstColors.mainColor,
                                      borderRadius: BorderRadius.circular(25.0),
                                    ),
                                    // ignore: deprecated_member_use
                                    child: FlatButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                      ),
                                      child: Text(
                                        AppLocalization.of(context)
                                            .getTranslatedValue("log_out"),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: sizeX.height / 50,
                                        ),
                                      ),
                                      onPressed: () {
                                        DatabaseService().logOutState();
                                        setState(() {
                                          Timer(Duration(milliseconds: 500),
                                              () {
                                            AuthService().signOut();

                                            DatabaseService.userID = '';
                                            Phoenix.rebirth(context);
                                          });
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: sizeX.height / 50),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Material(
                                    elevation: 3.0,
                                    borderRadius: BorderRadius.circular(25.0),
                                    child: Container(
                                      height: 45,
                                      width: 190,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: ConstColors.mainColor,
                                        ),
                                        color: Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                      ),
                                      // ignore: deprecated_member_use
                                      child: FlatButton(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                        ),
                                        child: Text(
                                          AppLocalization.of(context)
                                              .getTranslatedValue("delete_acc"),
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: sizeX.height / 50,
                                          ),
                                        ),
                                        onPressed: () {},
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              Center(child: Container());
            }
            return Container();
          });
    }
  }
}
