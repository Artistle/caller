import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter_app/animations/fade_animation.dart';
import 'package:flutter_app/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/localization/localization.dart';
import 'package:flutter_app/ui_screens/6_groups_screen/create_group.dart';

import 'package:flutter_app/ui_screens/6_groups_screen/group_chat_screen.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../screens.dart';

class GroupsScreen extends StatefulWidget {
  @override
  _GroupsScreenState createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  // bool createGroup = false;
  bool stateValid = false;

  @override
  void initState() {
    super.initState();
    setState(() {});
  }

  String searchSrting;
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;
    final String uid = user.phoneNumber;
    var sizeX = MediaQuery.of(context).size;
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Container(),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: FadeAnimation(
          0.1,
          Text(
            AppLocalization.of(context).getTranslatedValue("groups_title"),
            style: TextStyle(color: Colors.black),
          ),
        ),
        centerTitle: true,
      ),
      body: FadeAnimation(
        0.2,
        SafeArea(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('userData')
                .doc(uid)
                .snapshots(),
            builder: (context, snapshot) {
              DocumentSnapshot documentSnap = snapshot.data;
              Future addGroupToUser() async {
                final User user = auth.currentUser;
                final userId = user.phoneNumber;
                final List<String> groupReques = [
                  documentSnap['request'][0].toString()
                ];

                if (userId.isNotEmpty) {
                  // ignore: unused_local_variable
                  final documentReference = FirebaseFirestore.instance
                      .collection('userData')
                      .doc(userId)
                      .update({
                    "groupId": FieldValue.arrayUnion(groupReques),
                  });
                }
              }

              Future addUserToGroup() async {
                final User user = auth.currentUser;
                final userId = user.phoneNumber;
                final List<String> groupId = [userId];

                final documentReference = FirebaseFirestore.instance;
                documentReference
                    .collection('Groups')
                    .doc(documentSnap['request'][0].toString())
                    .update({
                  'members': FieldValue.arrayUnion(groupId),
                });
              }

              Future addAdminParam() async {
                final User user = auth.currentUser;
                final userId = user.phoneNumber;
                final String uid = userId;

                final documentReference = FirebaseFirestore.instance;
                documentReference.collection('userData').doc(uid).update({
                  documentSnap['request'][0].toString() + 'admin': false,
                });
              }

              Future addAdminParamToGroup() async {
                final User user = auth.currentUser;
                final userId = user.phoneNumber;
                final String uid = userId;

                final documentReference = FirebaseFirestore.instance;
                documentReference
                    .collection('Groups')
                    .doc(documentSnap['request'][0].toString())
                    .update({
                  uid + 'admin': false,
                });
              }

              Future addDateAddUserToGroup() async {
                final User user = auth.currentUser;
                final userId = user.phoneNumber;
                // ignore: unused_local_variable
                final String uid = userId;

                final documentReference = FirebaseFirestore.instance;
                documentReference.collection('userData').doc(userId).update({
                  documentSnap['request'][0].toString(): DateTime.now(),
                });
              }

              Future deleteRequest() async {
                final User user = auth.currentUser;
                final userId = user.phoneNumber;
                final List<String> groupRequest = [
                  documentSnap['request'][0].toString()
                ];

                if (userId.isNotEmpty) {
                  // ignore: unused_local_variable
                  final documentReference = FirebaseFirestore.instance
                      .collection('userData')
                      .doc(userId)
                      .update(
                          {"request": FieldValue.arrayRemove(groupRequest)});
                }
              }

              if (snapshot.hasData) {
                return Stack(
                  children: <Widget>[
                    Positioned(
                      top: 10.0,
                      left: 0.0,
                      right: 0.0,
                      child: Center(
                        child: Material(
                          elevation: 3.0,
                          borderRadius: BorderRadius.circular(25.0),
                          child: Container(
                            height: 50,
                            width: sizeX.width / 1.1,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    color: ConstColors.lightBlue,
                                    spreadRadius: 4,
                                    blurRadius: 7)
                              ],
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(left: 10.0, right: 10.0),
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 10.0,
                                    top: 0.0,
                                    bottom: 0.0,
                                    child: Center(
                                      child: Container(
                                        decoration: BoxDecoration(),
                                        height: 45,
                                        width: sizeX.width,
                                        child: TextField(
                                          onChanged: (value) {
                                            setState(() {
                                              searchSrting = value.trim();
                                            });
                                          },
                                          cursorColor:
                                              ConstColors.registerTextColor,
                                          decoration: InputDecoration(
                                            hintStyle: TextStyle(
                                                fontSize: sizeX.height / 55,
                                                color: Colors.grey[600]),
                                            contentPadding: EdgeInsets.only(
                                                top: 10.0,
                                                right: HomeScreenState.docSnap[
                                                            'appLang'] ==
                                                        'English'
                                                    ? 0.0
                                                    : 75.0),
                                            hintText:
                                                AppLocalization.of(context)
                                                    .getTranslatedValue(
                                                        "write_to_search"),
                                            focusedBorder:
                                                new OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                            enabledBorder:
                                                new OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                            errorBorder:
                                                const UnderlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                            border: const UnderlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: HomeScreenState.docSnap['appLang'] ==
                                            'English'
                                        ? 5.0
                                        : null,
                                    left: HomeScreenState.docSnap['appLang'] ==
                                            'English'
                                        ? null
                                        : 5.0,
                                    top: 0.0,
                                    bottom: 0.0,
                                    child: Center(
                                      child: IconButton(
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.search,
                                          color: ConstColors.registerTextColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0.0,
                      right: 0.0,
                      top: sizeX.height / 9,
                      child: Center(
                        child: SafeArea(
                          child: Container(
                            height: sizeX.height / 1.4,
                            child: StreamBuilder(
                              stream: (searchSrting == null ||
                                      searchSrting.trim() == '')
                                  ? FirebaseFirestore.instance
                                      .collection('Groups')
                                      .orderBy('groupCreateTime',
                                          descending: true)
                                      .where('members', arrayContains: uid)
                                      .snapshots()
                                  : FirebaseFirestore.instance
                                      .collection('Groups')
                                      .orderBy('groupCreateTime',
                                          descending: true)
                                      .where('members', arrayContains: uid)
                                      .where('groupName',
                                          isEqualTo: searchSrting)
                                      .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return ListView.builder(
                                      physics: BouncingScrollPhysics(),
                                      itemCount: snapshot.data.docs.length,
                                      itemBuilder: (context, index) {
                                        DocumentSnapshot documentSnapshot =
                                            snapshot.data.docs[index];
                                        Future
                                            addGroupToUserWhenCreate() async {
                                          final User user = auth.currentUser;
                                          final userId = user.phoneNumber;
                                          final List<String> groupId = [
                                            documentSnapshot.id
                                          ];

                                          if (userId.isNotEmpty) {
                                            // ignore: unused_local_variable
                                            final documentReference =
                                                FirebaseFirestore.instance
                                                    .collection('userData')
                                                    .doc(userId)
                                                    .update({
                                              "groupId": FieldValue.arrayUnion(
                                                  groupId),
                                            });
                                          }
                                        }

                                        return Stack(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10.0),
                                              child: Material(
                                                elevation: 2.0,
                                                child: Container(
                                                  height: sizeX.height / 9,
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                          color: ConstColors
                                                              .lightBlue,
                                                          spreadRadius: 4,
                                                          blurRadius: 7)
                                                    ],
                                                    color: Colors.white,
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
                                                    // ignore: deprecated_member_use
                                                    child: FlatButton(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15.0)),
                                                      onPressed: () {
                                                        addGroupToUserWhenCreate();
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        GroupChatScreen(
                                                                          groupSnapshot:
                                                                              documentSnapshot,
                                                                        )));
                                                      },
                                                      child: Stack(
                                                        children: <Widget>[
                                                          Positioned(
                                                            left: HomeScreenState
                                                                            .docSnap[
                                                                        'appLang'] ==
                                                                    'English'
                                                                ? 0.0
                                                                : null,
                                                            right: HomeScreenState
                                                                            .docSnap[
                                                                        'appLang'] ==
                                                                    'English'
                                                                ? null
                                                                : 0.0,
                                                            top: 0.0,
                                                            bottom: 0.0,
                                                            child: CircleAvatar(
                                                              backgroundColor:
                                                                  Colors
                                                                      .transparent,
                                                              radius:
                                                                  sizeX.height /
                                                                      25,
                                                              child: ClipOval(
                                                                child: Image
                                                                    .network(
                                                                  documentSnapshot[
                                                                      'groupImage'],
                                                                  fit: BoxFit
                                                                      .fill,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Positioned(
                                                            top: 0.0,
                                                            bottom: 0.0,
                                                            left: HomeScreenState
                                                                            .docSnap[
                                                                        'appLang'] ==
                                                                    'English'
                                                                ? sizeX.width /
                                                                    4.5
                                                                : null,
                                                            right: HomeScreenState
                                                                            .docSnap[
                                                                        'appLang'] ==
                                                                    'English'
                                                                ? null
                                                                : sizeX.width /
                                                                    4.5,
                                                            child: Center(
                                                              child: Text(
                                                                documentSnapshot[
                                                                    'groupName'],
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        sizeX.height /
                                                                            55,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700),
                                                              ),
                                                            ),
                                                          ),
                                                          Positioned(
                                                            right: HomeScreenState
                                                                            .docSnap[
                                                                        'appLang'] ==
                                                                    'English'
                                                                ? 0.0
                                                                : null,
                                                            left: HomeScreenState
                                                                            .docSnap[
                                                                        'appLang'] ==
                                                                    'English'
                                                                ? null
                                                                : 0.0,
                                                            top: 0.0,
                                                            bottom: 0.0,
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Container(
                                                                  height: sizeX
                                                                          .height /
                                                                      17,
                                                                  width: sizeX
                                                                          .width /
                                                                      3,
                                                                  child:
                                                                      StreamBuilder(
                                                                    stream: FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            'userData')
                                                                        .where(
                                                                            'groupId',
                                                                            arrayContains:
                                                                                documentSnapshot.id)
                                                                        .snapshots(),
                                                                    builder: (BuildContext
                                                                            context,
                                                                        AsyncSnapshot
                                                                            snapshot) {
                                                                      if (snapshot
                                                                          .hasData) {
                                                                        return Container(
                                                                          height:
                                                                              sizeX.height / 17,
                                                                          width:
                                                                              sizeX.width / 3,
                                                                          child:
                                                                              ListView.builder(
                                                                            physics:
                                                                                NeverScrollableScrollPhysics(),
                                                                            scrollDirection:
                                                                                Axis.horizontal,
                                                                            itemCount: snapshot.data.docs.length > 2
                                                                                ? 3
                                                                                : snapshot.data.docs.length,
                                                                            itemBuilder:
                                                                                (BuildContext context, int index) {
                                                                              DocumentSnapshot userSnapshot = snapshot.data.docs[index];
                                                                              return Padding(
                                                                                padding: const EdgeInsets.only(left: .0),
                                                                                child: Center(
                                                                                  child: Material(
                                                                                    borderRadius: BorderRadius.circular(20.0),
                                                                                    elevation: 2.0,
                                                                                    child: ClipOval(
                                                                                      child: Container(
                                                                                        decoration: BoxDecoration(shape: BoxShape.circle),
                                                                                        height: 35.0,
                                                                                        width: 35.0,
                                                                                        child: CircleAvatar(
                                                                                          radius: 20.0,
                                                                                          backgroundColor: index != 2 ? Colors.white : Colors.black,
                                                                                          child: index != 2
                                                                                              ? Image.network(userSnapshot['userImage'])
                                                                                              : Text(
                                                                                                  '+${snapshot.data.docs.length - 2}',
                                                                                                  style: TextStyle(color: Colors.white),
                                                                                                ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            },
                                                                          ),
                                                                        );
                                                                      } else if (snapshot
                                                                              .hasError ||
                                                                          !snapshot
                                                                              .hasData) {
                                                                        return Container();
                                                                      }
                                                                      return Container();
                                                                    },
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      });
                                } else if (snapshot.hasError) {
                                  Container();
                                }
                                return Center(
                                  child: Container(),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    documentSnap['request'].isNotEmpty ||
                            documentSnap['request'] == null
                        ? AlertDialog(
                            contentPadding: EdgeInsets.all(0.0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0)),
                            content: Container(
                              height: sizeX.height,
                              child: Center(
                                child: ListView(
                                  physics: BouncingScrollPhysics(),
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: <Widget>[
                                                IconButton(
                                                    icon: Icon(
                                                      MdiIcons.close,
                                                      color: Colors.black,
                                                    ),
                                                    onPressed: null)
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 10.0,
                                              ),
                                              child: Text(
                                                AppLocalization.of(context)
                                                    .getTranslatedValue(
                                                        "new_invite"),
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: sizeX.height / 40,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 10.0,
                                              ),
                                              child: Text(
                                                AppLocalization.of(context)
                                                    .getTranslatedValue(
                                                        "new_invite_desc"),
                                                softWrap: true,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: sizeX.height / 65,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 20.0),
                                          child: StreamBuilder(
                                            stream: FirebaseFirestore.instance
                                                .collection('Groups')
                                                .doc(documentSnap['request'][0]
                                                    .toString())
                                                .snapshots(),
                                            builder: (BuildContext context,
                                                AsyncSnapshot snapshot) {
                                              DocumentSnapshot gSnap =
                                                  snapshot.data;
                                              if (snapshot.hasData) {
                                                return Column(
                                                  children: [
                                                    CircleAvatar(
                                                      backgroundColor:
                                                          Colors.white,
                                                      radius: 45.0,
                                                      child: ClipOval(
                                                        child: Image.network(
                                                            gSnap[
                                                                'groupImage']),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 10.0,
                                                          left: 10.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Text(gSnap[
                                                              'groupName']),
                                                          gSnap['privateState'] ==
                                                                  true
                                                              ? Padding(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              5.0),
                                                                  child: Icon(
                                                                    MdiIcons
                                                                        .lock,
                                                                    color: Colors
                                                                        .black,
                                                                    size: 18.0,
                                                                  ))
                                                              : Container(),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 20.0),
                                                      child: Text(
                                                        AppLocalization.of(
                                                                context)
                                                            .getTranslatedValue(
                                                                "following_people"),
                                                        softWrap: true,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize:
                                                              sizeX.height / 65,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              } else if (snapshot.hasError ||
                                                  !snapshot.hasData) {
                                                return Container();
                                              }
                                              return Container();
                                            },
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              height: sizeX.height / 6,
                                              width: sizeX.width / 2,
                                              child: StreamBuilder(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection('userData')
                                                    .where('groupId',
                                                        arrayContains:
                                                            documentSnap[
                                                                    'request'][0]
                                                                .toString())
                                                    .snapshots(),
                                                builder: (BuildContext context,
                                                    AsyncSnapshot snapshot) {
                                                  if (snapshot.hasData) {
                                                    return ListView.builder(
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount: snapshot.data
                                                                  .docs.length >
                                                              2
                                                          ? 3
                                                          : snapshot
                                                              .data.docs.length,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        DocumentSnapshot uSnap =
                                                            snapshot.data
                                                                .docs[index];
                                                        return Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            CircleAvatar(
                                                              backgroundColor:
                                                                  index != 2
                                                                      ? Colors
                                                                          .white
                                                                      : Colors
                                                                          .black,
                                                              radius: 25.0,
                                                              child: ClipOval(
                                                                child: index !=
                                                                        2
                                                                    ? Image.network(
                                                                        uSnap[
                                                                            'userImage'])
                                                                    : Text(
                                                                        '+${snapshot.data.docs.length - 2}',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white),
                                                                      ),
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  } else if (snapshot
                                                          .hasError ||
                                                      !snapshot.hasData) {
                                                    return Container();
                                                  }
                                                  return Container();
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Material(
                                              elevation: 3.0,
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              child: Container(
                                                height: sizeX.height / 20,
                                                width: sizeX.width / 2.5,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                  color: ConstColors.mainColor,
                                                ),
                                                // ignore: deprecated_member_use
                                                child: FlatButton(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20.0),
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        addAdminParam();
                                                        addAdminParamToGroup();
                                                        addGroupToUser();
                                                        addUserToGroup();

                                                        addDateAddUserToGroup();
                                                        deleteRequest();
                                                      });
                                                    },
                                                    child: Text(
                                                      AppLocalization.of(
                                                              context)
                                                          .getTranslatedValue(
                                                              "accept"),
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        fontSize:
                                                            sizeX.height / 55,
                                                      ),
                                                    )),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10.0),
                                              child: Material(
                                                elevation: 3.0,
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                                child: Container(
                                                  height: sizeX.height / 20,
                                                  width: sizeX.width / 2.5,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0),
                                                    border: Border.all(
                                                      width: 1.0,
                                                      color: Colors.black,
                                                    ),
                                                    color: Colors.white,
                                                  ),
                                                  // ignore: deprecated_member_use
                                                  child: FlatButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          deleteRequest();
                                                        });
                                                      },
                                                      child: Text(
                                                        AppLocalization.of(
                                                                context)
                                                            .getTranslatedValue(
                                                                "decline"),
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          fontSize:
                                                              sizeX.height / 55,
                                                        ),
                                                      )),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                );
              } else if (snapshot.hasError || !snapshot.hasData) {
                Container();
              }
              return Container();
            },
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 45.0),
        child: Container(
          child: FloatingActionButton(
            backgroundColor: ConstColors.mainColor,
            child: Center(
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
            onPressed: () {
              setState(() {
                // _selectedFile = null;
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => CreateGroupe()));
              });
            },
          ),
        ),
      ),
    );
  }
}
