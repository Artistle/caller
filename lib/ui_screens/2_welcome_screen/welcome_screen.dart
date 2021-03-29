import 'package:flutter/material.dart';
import 'package:flutter_app/constants/constants.dart';
import 'package:flutter_app/localization/localization.dart';
import 'package:worm_indicator/worm_indicator.dart';
import 'package:worm_indicator/shape.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_app/register/new_register/new_register_screen.dart';

import '../screens.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  WelcomeScreenState createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
  static PageController pageController = PageController(initialPage: 0);
  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 0);
  }

  @override
  Widget build(BuildContext context) {
    var sizeX = MediaQuery.of(context).size;
    List<Widget> pages = [
      WelcomeFirstHelper(),
      WelcomeSecondHelper(),
      WelcomThirdHelper(),
    ];
    return
        // ignore: missing_return

        Scaffold(
      body: Container(
        height: sizeX.height,
        child: Center(
          child: Stack(
            children: [
              PageView(
                controller: pageController,
                children: pages,
              ),
              Positioned(
                left: 0.0,
                right: 0.0,
                bottom: 40.0,
                child: WormIndicator(
                  indicatorColor: ConstColors.welcomeIndicator,
                  color: Colors.grey[300],
                  length: 3,
                  controller: pageController,
                  shape: Shape(
                      size: 14,
                      spacing: 8,
                      shape: DotShape.Circle // Similar for Square
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WelcomeFirstHelper extends StatefulWidget {
  WelcomeFirstHelper({Key key}) : super(key: key);

  @override
  _WelcomeFirstHelperState createState() => _WelcomeFirstHelperState();
}

class _WelcomeFirstHelperState extends State<WelcomeFirstHelper> {
  @override
  @override
  Widget build(BuildContext context) {
    var sizeX = MediaQuery.of(context).size;
    return Container(
      child: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: sizeX.height / 4),
            child: Center(
              child: Container(
                child: Padding(
                    padding: EdgeInsets.all(sizeX.height / 17),
                    child: SvgPicture.asset('assets/images/helper1.svg')),
              ),
            ),
          ),
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: sizeX.height / 3.3,
            child: ListTile(
              title: Center(
                child: Text(
                  AppLocalization.of(context)
                      .getTranslatedValue("welcome_title"),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: sizeX.height / 35,
                    color: ConstColors.textColor,
                  ),
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Center(
                  child: Text(
                    AppLocalization.of(context)
                        .getTranslatedValue("helper_1_text"),
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: sizeX.height / 55,
                      color: ConstColors.textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 15.0,
            bottom: 30,
            // ignore: deprecated_member_use
            child: FlatButton(
                onPressed: () {
                  setState(() {
                    WelcomeScreenState.pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.ease);
                  });
                },
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Text(AppLocalization.of(context)
                          .getTranslatedValue("next_button")),
                    ),
                    SvgPicture.asset('assets/icons/icon_for_next_button.svg'),
                  ],
                )),
          )
        ],
      ),
    );
  }
}

class WelcomeSecondHelper extends StatefulWidget {
  WelcomeSecondHelper({Key key}) : super(key: key);

  @override
  _WelcomeSecondHelperState createState() => _WelcomeSecondHelperState();
}

class _WelcomeSecondHelperState extends State<WelcomeSecondHelper> {
  @override
  Widget build(BuildContext context) {
    var sizeX = MediaQuery.of(context).size;
    return Container(
      child: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: sizeX.height / 4),
            child: Center(
              child: Container(
                child: Padding(
                    padding: EdgeInsets.all(sizeX.height / 17),
                    child: SvgPicture.asset('assets/images/helper2.svg')),
              ),
            ),
          ),
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: sizeX.height / 3.3,
            child: ListTile(
              title: Center(
                child: Text(
                  AppLocalization.of(context)
                      .getTranslatedValue("welcome_title"),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: sizeX.height / 35,
                    color: ConstColors.textColor,
                  ),
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Center(
                  child: Text(
                    AppLocalization.of(context)
                        .getTranslatedValue("helper_2_text"),
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: sizeX.height / 55,
                      color: ConstColors.textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 15.0,
            bottom: 30,
            // ignore: deprecated_member_use
            child: FlatButton(
                onPressed: () {
                  setState(() {
                    WelcomeScreenState.pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.ease);
                  });
                },
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Text(AppLocalization.of(context)
                          .getTranslatedValue("next_button")),
                    ),
                    SvgPicture.asset('assets/icons/icon_for_next_button.svg'),
                  ],
                )),
          )
        ],
      ),
    );
  }
}

class WelcomThirdHelper extends StatefulWidget {
  WelcomThirdHelper({Key key}) : super(key: key);

  @override
  WelcomThirdHelperState createState() => WelcomThirdHelperState();
}

class WelcomThirdHelperState extends State<WelcomThirdHelper> {
  static bool login;
  @override
  void initState() {
    super.initState();
    login = false;
  }

  @override
  Widget build(BuildContext context) {
    var sizeX = MediaQuery.of(context).size;
    return Container(
      child: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: sizeX.height / 4),
            child: Center(
              child: Container(
                child: Padding(
                    padding: EdgeInsets.all(sizeX.height / 17),
                    child: SvgPicture.asset('assets/images/helper3.svg')),
              ),
            ),
          ),
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: sizeX.height / 3.5,
            child: ListTile(
              title: Center(
                child: Text(
                  AppLocalization.of(context)
                      .getTranslatedValue("welcome_title"),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: sizeX.height / 35,
                    color: ConstColors.textColor,
                  ),
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Center(
                  child: Text(
                    AppLocalization.of(context)
                        .getTranslatedValue("helper_3_text"),
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: sizeX.height / 55,
                      color: ConstColors.textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: sizeX.height / 9,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Material(
                      elevation: 3.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Container(
                        height: 45,
                        width: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                          color: ConstColors.mainColor,
                        ),
                        // ignore: deprecated_member_use
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => RegisterScreen())),
                          child: Text(
                            AppLocalization.of(context)
                                .getTranslatedValue("start_now_button"),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: sizeX.height / 55,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Center(
                    child: InkWell(
                        onTap: () {
                          setState(() {
                            login = true;
                          });
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => LoginScreen()));
                        },
                        child: Text(
                          AppLocalization.of(context)
                              .getTranslatedValue("have_an_acc"),
                          style: TextStyle(
                            color: ConstColors.textColor,
                            fontSize: sizeX.height / 60,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w600,
                          ),
                        )),
                  ),
                )
              ],
            ),
          ),
          // Positioned(
          //   right: 15.0,
          //   bottom: 30,
          //   // ignore: deprecated_member_use
          //   child: FlatButton(
          //       onPressed: () {
          //         Navigator.of(context).push(MaterialPageRoute(
          //             builder: (context) => TryLoginScreen()));
          //       },
          //       child: Row(
          //         children: [
          //           Padding(
          //             padding: const EdgeInsets.only(right: 10.0),
          //             child: Text(AppLocalization.of(context)
          //                 .getTranslatedValue("next_button")),
          //           ),
          //           SvgPicture.asset('assets/icons/icon_for_next_button.svg'),
          //         ],
          //       )),
          // ),
          Positioned(
            left: 15.0,
            bottom: 30,
            // ignore: deprecated_member_use
            child: FlatButton(
                onPressed: () {
                  setState(() {
                    WelcomeScreenState.pageController.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.ease);
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back_ios,
                      size: 20.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Text(AppLocalization.of(context)
                          .getTranslatedValue("back")),
                    ),
                  ],
                )),
          )
        ],
      ),
    );
  }
}
