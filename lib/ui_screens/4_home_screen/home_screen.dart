import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app/animations/fade_animation.dart';
import 'package:flutter_app/constants/const_colors/const_colors.dart';
import 'package:flutter_app/constants/constants.dart';
import 'package:flutter_app/database/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/localization/localization.dart';
import 'package:flutter_app/ui_screens/4_home_screen/search/sort_types.dart';
import 'package:flutter_app/ui_screens/4_home_screen/settings_screen/settings_screen.dart';
import 'package:flutter_app/ui_screens/6_groups_screen/gruops_screen.dart';
import 'package:flutter_app/ui_screens/8_graph_screen/graph_screen.dart';
import '../screens.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:minimize_app/minimize_app.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'filtered_calls/phone_logs.dart';

class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    setState(() {
      PhonelogsScreenState.groupSearch = 'all';
    });
  }

  // ignore: unused_field
  bool _inProcess = false;
  double _height = 60;
  double _width = 80;
  double _posRight = 0.0;

  var _searchColor = ConstColors.mainColor;
  static String searchString = '';
  TextEditingController controllerText = TextEditingController();
  static bool groupState = false;
  static bool mainState = true;
  static bool graphState = false;
  static bool hideState = false;
  static bool unsaved = false;
  static bool searchState = false;

  static int selectedIndex = 1;

  static DocumentSnapshot docSnap;

  @override
  Widget build(BuildContext context) {
    var sizeX = MediaQuery.of(context).size;
    double _posTop = sizeX.height / 20;
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;
    final String uid = user.phoneNumber;

    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        MinimizeApp.minimizeApp();
      },
      child: Scaffold(
        bottomNavigationBar: SafeArea(
          child: Container(
            decoration: BoxDecoration(color: Colors.transparent, boxShadow: [
              BoxShadow(
                  color: ConstColors.deepBlue,
                  offset: Offset(-10, -2.5),
                  blurRadius: 15.0,
                  spreadRadius: 4.0)
            ]),
            child: CurvedNavigationBar(
              index: 1,
              animationDuration: Duration(
                milliseconds: 300,
              ),
              animationCurve: Curves.ease,
              color: Colors.white,
              height: searchState == false ? 50.0 : 0.0,
              buttonBackgroundColor: searchState == false
                  ? ConstColors.mainColor
                  : Colors.transparent,
              backgroundColor: Colors.transparent,
              items: <Widget>[
                Container(
                  height: 40.0,
                  width: 40.0,
                  decoration: BoxDecoration(
                    color: selectedIndex == 0
                        ? ConstColors.mainColor
                        : Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(11.0),
                        child: SvgPicture.asset(
                          'assets/icons/icon_group.svg',
                          color: selectedIndex == 0
                              ? Colors.white
                              : Colors.grey[400],
                        ),
                      ),
                      Positioned(
                        right: 12.0,
                        bottom: 16.0,
                        child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('userData')
                              .doc(uid)
                              .snapshots(),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            DocumentSnapshot documentSnapshot = snapshot.data;
                            if (snapshot.hasData) {
                              return documentSnapshot['request'].isNotEmpty
                                  ? CircleAvatar(
                                      radius: 3.0,
                                      backgroundColor: Colors.redAccent)
                                  : Container();
                            } else if (snapshot.hasError || !snapshot.hasData) {
                              return Container();
                            }
                            return Container();
                          },
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  height: 40.0,
                  width: 40.0,
                  decoration: BoxDecoration(
                    color: selectedIndex == 1 && searchState == false
                        ? ConstColors.mainColor
                        : Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: searchState == false
                      ? Icon(
                          CupertinoIcons.phone_fill,
                          size: selectedIndex == 1 ? 25.0 : null,
                          color: selectedIndex == 1
                              ? Colors.white
                              : Colors.grey[400],
                        )
                      : Container(),
                ),
                Container(
                  height: 40.0,
                  width: 40.0,
                  decoration: BoxDecoration(
                    color: selectedIndex == 2
                        ? ConstColors.mainColor
                        : Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(11.0),
                    child: SvgPicture.asset(
                      'assets/icons/icon_diagram_3.svg',
                      color:
                          selectedIndex == 2 ? Colors.white : Colors.grey[400],
                    ),
                  ),
                ),
              ],
              onTap: (index) {
                setState(() {
                  selectedIndex = index;

                  if (index == 0) {
                    setState(() {
                      groupState = true;
                      mainState = false;
                      graphState = false;
                    });
                  }
                  if (index == 1) {
                    setState(() {
                      PhonelogsScreenState.groupSearch = 'all';

                      groupState = false;
                      mainState = true;
                      graphState = false;
                    });
                  }
                  if (index == 2) {
                    setState(() {
                      groupState = false;
                      mainState = false;
                      graphState = true;
                    });
                  }
                });
              },
            ),
          ),
        ),
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: mainState
            ? FadeAnimation(
                0.2,
                SafeArea(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('userData')
                        .doc(uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      DocumentSnapshot documentSnapshot = snapshot.data;
                      docSnap = documentSnapshot;

                      if (snapshot.hasData) {
                        return Stack(
                          children: <Widget>[
                            documentSnapshot['allowButton'] == true
                                ? Positioned(
                                    top: sizeX.height / 3.9,
                                    left: 0.0,
                                    right: 0.0,
                                    child: Container(
                                      height: sizeX.height,
                                      child: PhonelogsScreen(),
                                    ),
                                  )
                                : Container(),
                            Positioned(
                              left: 0.0,
                              right: 0.0,
                              top: sizeX.height / 30,
                              child: searchState == false
                                  ? ListTile(
                                      title: CircleAvatar(
                                        backgroundColor: ConstColors.mainColor,
                                        radius: 40.0,
                                        child: ClipOval(
                                          child: Image.network(
                                            documentSnapshot['userImage'],
                                          ),
                                        ),
                                      ),
                                      subtitle: Padding(
                                        padding: EdgeInsets.only(
                                            top: sizeX.height / 55),
                                        child: Column(
                                          children: <Widget>[
                                            Text(
                                              documentSnapshot['userName'],
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: sizeX.height / 50,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: sizeX.height / 150),
                                              child: Text(
                                                documentSnapshot['companyName'],
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: sizeX.height / 65,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ),
                            Positioned(
                              left: documentSnapshot['appLang'] == 'English'
                                  ? _posRight
                                  : null,
                              right: documentSnapshot['appLang'] == 'עברית'
                                  ? _posRight
                                  : null,
                              top: _posTop,
                              child: searchState == false
                                  ? IconButton(
                                      splashRadius: 20.0,
                                      onPressed: () => Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) =>
                                                  SettingsScreen())),
                                      icon: Icon(
                                        Icons.settings,
                                        color: ConstColors.mainColor,
                                        size: sizeX.height / 32,
                                      ),
                                      // ),
                                    )
                                  : Container(),
                            ),
                            Positioned(
                              left: documentSnapshot['appLang'] == 'English'
                                  ? null
                                  : _posRight,
                              right: documentSnapshot['appLang'] == 'עברית'
                                  ? null
                                  : _posRight,
                              top: _posTop,
                              child: Material(
                                color: searchState == false
                                    ? ConstColors.mainColor
                                    : ConstColors.searchColor,
                                elevation: searchState == true ? 5.0 : 0.0,
                                borderRadius: documentSnapshot['appLang'] ==
                                        'עברית'
                                    ? BorderRadius.only(
                                        topRight: Radius.circular(30.0),
                                        bottomRight: Radius.circular(30.0),
                                      )
                                    : documentSnapshot['appLang'] == 'English'
                                        ? BorderRadius.only(
                                            topLeft: Radius.circular(30.0),
                                            bottomLeft: Radius.circular(30.0),
                                          )
                                        : BorderRadius.only(
                                            topLeft: Radius.circular(30.0),
                                            bottomLeft: Radius.circular(30.0),
                                          ),
                                child: AnimatedContainer(
                                  height: _height,
                                  width: _width,
                                  duration: Duration(
                                    milliseconds: 500,
                                  ),
                                  curve: Curves.fastOutSlowIn,
                                  decoration: BoxDecoration(
                                    color: _searchColor,
                                    borderRadius: documentSnapshot['appLang'] ==
                                            'עברית'
                                        ? BorderRadius.only(
                                            topRight: Radius.circular(30.0),
                                            bottomRight: Radius.circular(30.0),
                                          )
                                        : documentSnapshot['appLang'] ==
                                                'English'
                                            ? BorderRadius.only(
                                                topLeft: Radius.circular(30.0),
                                                bottomLeft:
                                                    Radius.circular(30.0),
                                              )
                                            : BorderRadius.only(
                                                topLeft: Radius.circular(30.0),
                                                bottomLeft:
                                                    Radius.circular(30.0),
                                              ),
                                  ),
                                  child: searchState == false
                                      ? IconButton(
                                          onPressed: () {
                                            documentSnapshot['allowButton'] ==
                                                    true
                                                ? setState(() {
                                                    searchState = true;
                                                    _height =
                                                        sizeX.height / 1.15;
                                                    _width = sizeX.width / 1.02;
                                                    _posTop = 0.0;
                                                    _searchColor =
                                                        ConstColors.searchColor;
                                                  })
                                                // ignore: unnecessary_statements
                                                : () {};
                                          },
                                          icon: Icon(
                                            CupertinoIcons.search,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Stack(
                                          children: <Widget>[
                                            searchState == true
                                                ? Positioned(
                                                    top: 80.0,
                                                    left: 0.0,
                                                    right: 0.0,
                                                    child: Column(
                                                      children: <Widget>[
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                            right: 10.0,
                                                            left: 25.0,
                                                          ),
                                                          child: Container(
                                                            height:
                                                                sizeX.height /
                                                                    20,
                                                            width:
                                                                sizeX.height /
                                                                    2.3,
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                20.0,
                                                              ),
                                                            ),
                                                            child: Stack(
                                                              children: <
                                                                  Widget>[
                                                                TextField(
                                                                  controller:
                                                                      controllerText,
                                                                  onChanged:
                                                                      (search) {
                                                                    setState(
                                                                        () {
                                                                      searchString =
                                                                          search;
                                                                    });
                                                                  },
                                                                  textInputAction:
                                                                      TextInputAction
                                                                          .done,
                                                                  cursorColor:
                                                                      ConstColors
                                                                          .registerTextColor,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    hintStyle:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          sizeX.height /
                                                                              55,
                                                                      color: Colors
                                                                              .grey[
                                                                          600],
                                                                    ),
                                                                    contentPadding: EdgeInsets.only(
                                                                        top:
                                                                            10.0,
                                                                        left:
                                                                            10.0),
                                                                    hintText: documentSnapshot['appLang'] ==
                                                                            'עברית'
                                                                        ? '   ${AppLocalization.of(context).getTranslatedValue("write_to_search")}'
                                                                        : AppLocalization.of(context)
                                                                            .getTranslatedValue("write_to_search"),
                                                                    focusedBorder:
                                                                        new OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide
                                                                              .none,
                                                                    ),
                                                                    enabledBorder:
                                                                        new OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide
                                                                              .none,
                                                                    ),
                                                                    errorBorder:
                                                                        const UnderlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide
                                                                              .none,
                                                                    ),
                                                                    border:
                                                                        const UnderlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide
                                                                              .none,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Positioned(
                                                                  right: SettingsScreenState
                                                                              .langName ==
                                                                          'עברית'
                                                                      ? null
                                                                      : 0.0,
                                                                  left: SettingsScreenState
                                                                              .langName ==
                                                                          'עברית'
                                                                      ? 0.0
                                                                      : null,
                                                                  top: 0.0,
                                                                  bottom: 0.0,
                                                                  child:
                                                                      IconButton(
                                                                    onPressed:
                                                                        () {},
                                                                    icon: Icon(
                                                                      CupertinoIcons
                                                                          .search,
                                                                      color: searchState ==
                                                                              true
                                                                          ? ConstColors
                                                                              .registerTextColor
                                                                          : Colors
                                                                              .white,
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
                                                : Container(),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 20.0),
                                              child: SortTypes(),
                                            ),
                                            Positioned(
                                              top: 15.0,
                                              left: SettingsScreenState
                                                          .langName ==
                                                      'עברית'
                                                  ? null
                                                  : 0.0,
                                              right: SettingsScreenState
                                                          .langName ==
                                                      'עברית'
                                                  ? 0.0
                                                  : null,
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: 25.0,
                                                    right: SettingsScreenState
                                                                .langName ==
                                                            'עברית'
                                                        ? 25.0
                                                        : 0.0),
                                                child: Text(
                                                  AppLocalization.of(context)
                                                      .getTranslatedValue(
                                                          "search"),
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              left: SettingsScreenState
                                                          .langName ==
                                                      'עברית'
                                                  ? 0.0
                                                  : null,
                                              right: SettingsScreenState
                                                          .langName ==
                                                      'עברית'
                                                  ? null
                                                  : 0.0,
                                              child: IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    searchState = false;
                                                    _height = 60;
                                                    _width = 80;
                                                    _searchColor =
                                                        ConstColors.mainColor;
                                                  });
                                                },
                                                icon: Icon(
                                                  Icons.arrow_forward_ios,
                                                  color: Colors.white,
                                                  size: 20.0,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                            documentSnapshot['allowButton'] == false
                                ? Positioned(
                                    top: sizeX.height / 3.8,
                                    left: 0.0,
                                    right: 0.0,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: sizeX.width / 15),
                                          child: Text(
                                            AppLocalization.of(context)
                                                .getTranslatedValue(
                                                    "usage_help_title"),
                                            style: TextStyle(
                                              fontSize: sizeX.height / 50,
                                              fontWeight: FontWeight.w800,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Container(
                                          height: sizeX.height / 2.5,
                                          width: 300,
                                          child: Center(
                                            child: SvgPicture.asset(
                                              'assets/images/main.svg',
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 0.0),
                                          child: Material(
                                            elevation: 1.0,
                                            borderRadius:
                                                BorderRadius.circular(25.0),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 15.0),
                                              height: 50,

                                              decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Colors.grey[200],
                                                      spreadRadius: 0.5,
                                                      blurRadius: 0.5,
                                                      offset: Offset(0, 6)),
                                                ],
                                                color: ConstColors.mainColor,
                                                borderRadius:
                                                    BorderRadius.circular(25.0),
                                              ),
                                              // ignore: deprecated_member_use
                                              child: FlatButton(
                                                onPressed: () {
                                                  DatabaseService()
                                                      .allowUpdate();
                                                },
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25.0),
                                                ),
                                                child: Text(
                                                  AppLocalization.of(context)
                                                      .getTranslatedValue(
                                                          "allow_button"),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                : Container(),
                          ],
                        );
                      } else if (snapshot.hasError || !snapshot.hasData) {
                        Center(child: Container());
                      }
                      return Container();
                    },
                  ),
                ),
              )
            : groupState == true
                ? GroupsScreen()
                : GraphScreen(),
      ),
    );
  }
}
