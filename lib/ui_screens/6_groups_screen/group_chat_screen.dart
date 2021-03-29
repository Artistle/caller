import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/animations/fade_animation.dart';
import 'package:flutter_app/constants/constants.dart';
import 'package:flutter_app/custom_widgets/Custom_Flushbar.dart';
import 'package:flutter_app/database/database_service.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_app/localization/localization.dart';
import 'package:flutter_app/ui_screens/6_groups_screen/edit_group.dart';
import 'package:flutter_app/ui_screens/10_contacts/list_of_contacts.dart';

import '../screens.dart';

class GroupChatScreen extends StatefulWidget {
  final DocumentSnapshot groupSnapshot;

  GroupChatScreen({Key key, this.groupSnapshot}) : super(key: key);

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final dateEngStartTime = new DateFormat().add_Hm();

  final dateEngDate = new DateFormat('dd MMM yyyy');

  String month = 'MMM';
  double _width = 200;
  String invitedUser = '';
  String searchUserToAdd = '';
  String searchString;
  bool inviteState = false;
  bool saveState = true;
  bool admin = false;
  bool statusChanging = false;

  DocumentSnapshot userSnap;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;
    final uid = user.phoneNumber;

    var sizeX = MediaQuery.of(context).size;

    return Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            centerTitle: true,
            title: Text(widget.groupSnapshot['groupName'],
                style: TextStyle(color: Colors.black)),
            actions: <Widget>[
              Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: IconButton(
                      splashRadius: 20.0,
                      icon: SvgPicture.asset('assets/icons/icon_edit_pen.svg'),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => EditGroup(
                                image: widget.groupSnapshot['groupImage']
                                    .toString(),
                                groupName: widget.groupSnapshot['groupName'],
                                groupId: widget.groupSnapshot.id)));
                      }))
            ],
            leading: IconButton(
                splashRadius: 20.0,
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                ),
                onPressed: () => Navigator.of(context).pop())),
        floatingActionButton: Padding(
            padding: EdgeInsets.only(bottom: 40.0),
            child: Container(
                child: FloatingActionButton(
                    backgroundColor: ConstColors.mainColor,
                    onPressed: () {
                      addCollLogDialog(context);
                    },
                    child: Center(
                        child: Icon(
                      Icons.add,
                      color: Colors.white,
                    ))))),
        body: SafeArea(
            child: Stack(children: [
          Positioned(
              left: 0.0,
              right: 0.0,
              bottom: sizeX.height / 8,
              child: SvgPicture.asset('assets/icons/group_backg_trees.svg')),
          Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Column(children: <Widget>[
                Material(
                    elevation: 3.0,
                    borderRadius: BorderRadius.circular(20.0),
                    child: Container(
                        height: 45,
                        width: sizeX.width / 1.1,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                color: ConstColors.lightBlue,
                                spreadRadius: 4,
                                blurRadius: 7)
                          ],
                          borderRadius: BorderRadius.circular(20.0),
                          color: Colors.white,
                        ),
                        child: Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child: Stack(children: [
                              TextField(
                                  autofocus: false,
                                  onChanged: (log) {
                                    searchString = log;
                                  },
                                  cursorColor: ConstColors.registerTextColor,
                                  decoration: InputDecoration(
                                      hintStyle: TextStyle(
                                          fontSize: sizeX.height / 55,
                                          color: Colors.grey[500]),
                                      contentPadding: EdgeInsets.only(
                                          top: 10.0,
                                          right: HomeScreenState.docSnap['appLang'] == 'English'
                                              ? 0.0
                                              : 10.0),
                                      hintText: HomeScreenState.docSnap['appLang'] ==
                                              'English'
                                          ? AppLocalization.of(context)
                                              .getTranslatedValue(
                                                  "write_to_search")
                                          : '   ${AppLocalization.of(context).getTranslatedValue("write_to_search")}',
                                      focusedBorder: new OutlineInputBorder(
                                          borderSide: BorderSide.none),
                                      enabledBorder: new OutlineInputBorder(
                                          borderSide: BorderSide.none),
                                      errorBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide.none),
                                      border: const UnderlineInputBorder(borderSide: BorderSide.none))),
                              Positioned(
                                  right: HomeScreenState.docSnap['appLang'] ==
                                          'English'
                                      ? 15.0
                                      : null,
                                  left: HomeScreenState.docSnap['appLang'] ==
                                          'English'
                                      ? null
                                      : 15.0,
                                  top: 0.0,
                                  bottom: 0.0,
                                  child: Icon(
                                    Icons.search,
                                    color: ConstColors.subColor,
                                  ))
                            ])))),
                Padding(
                    padding: EdgeInsets.only(top: 10.0, bottom: 0.0),
                    child: Container(
                        height: sizeX.height / 7,
                        child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('userData')
                                .where('groupId',
                                    arrayContains: widget.groupSnapshot.id)
                                .snapshots(),
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              Future addDateAddUser() async {
                                final User user = auth.currentUser;
                                final userId = user.phoneNumber;
                                final documentReference =
                                    FirebaseFirestore.instance;
                                documentReference
                                    .collection('userData')
                                    .doc(userId)
                                    .update({
                                  widget.groupSnapshot.id: DateTime.now(),
                                });
                              }

                              Future addAdminParam() async {
                                final User user = auth.currentUser;
                                final userId = user.phoneNumber;
                                final String uid = userId;

                                final documentReference =
                                    FirebaseFirestore.instance;
                                documentReference
                                    .collection('userData')
                                    .doc(uid)
                                    .update({
                                  widget.groupSnapshot.id + 'admin': true,
                                });
                              }

                              Future addAdminParamToGroup() async {
                                final User user = auth.currentUser;
                                final userId = user.phoneNumber;
                                final String uid = userId;

                                final documentReference =
                                    FirebaseFirestore.instance;
                                documentReference
                                    .collection('Groups')
                                    .doc(widget.groupSnapshot.id)
                                    .update({
                                  uid + 'admin': true,
                                });
                              }

                              Future addUpdGroupSate() async {
                                final docRef = FirebaseFirestore.instance
                                    .collection('userData');
                                docRef.get().then((QuerySnapshot snapsnot) {
                                  snapsnot.docs.forEach((DocumentSnapshot doc) {
                                    print(doc.data());
                                    doc.reference.update({
                                      '${widget.groupSnapshot.id}request':
                                          false,
                                    });
                                  });
                                });
                              }

                              if (snapshot.hasData) {
                                return Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20.0),
                                        child: FloatingActionButton(
                                          backgroundColor:
                                              ConstColors.mainColor,
                                          onPressed: () {
                                            addUpdGroupSate();
                                            widget.groupSnapshot['leader'] ==
                                                    uid
                                                ? setState(() {
                                                    addAdminParam();
                                                    addAdminParamToGroup();
                                                    addDateAddUser();
                                                  })
                                                : setState(() {});
                                            setState(() {
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      12.0),
                                                        ),
                                                        contentPadding:
                                                            EdgeInsets.all(0.0),
                                                        content: StatefulBuilder(
                                                            builder: (context,
                                                                StateSetter
                                                                    setState) {
                                                          return Container(
                                                              height:
                                                                  sizeX.height /
                                                                      1.2,
                                                              width:
                                                                  sizeX.width,
                                                              child: Stack(
                                                                  children: [
                                                                    Positioned(
                                                                        right:
                                                                            5.0,
                                                                        top:
                                                                            10.0,
                                                                        child: IconButton(
                                                                            splashRadius: 20.0,
                                                                            onPressed: () {
                                                                              searchUserToAdd = '';
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                            icon: Icon(
                                                                              Icons.close,
                                                                              color: Colors.black,
                                                                            ))),
                                                                    Positioned(
                                                                        left:
                                                                            20.0,
                                                                        top:
                                                                            45.0,
                                                                        child: Text(
                                                                            AppLocalization.of(context).getTranslatedValue(
                                                                                "choose_contacts"),
                                                                            style: TextStyle(
                                                                                color: Colors.black,
                                                                                fontSize: sizeX.height / 55,
                                                                                fontWeight: FontWeight.w500))),
                                                                    Positioned(
                                                                        top:
                                                                            75.0,
                                                                        left:
                                                                            15.0,
                                                                        right:
                                                                            15.0,
                                                                        child: ContactsList(
                                                                            groupId:
                                                                                widget.groupSnapshot.id))
                                                                  ]));
                                                        }));
                                                  });
                                            });
                                          },
                                          child: Center(
                                            child: Icon(
                                              Icons.add,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                          child: Expanded(
                                              child: ListView.builder(
                                                  physics:
                                                      BouncingScrollPhysics(),
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      snapshot.data.docs.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    DocumentSnapshot
                                                        documentSnapshot =
                                                        snapshot
                                                            .data.docs[index];
                                                    userSnap = documentSnapshot;
                                                    Future
                                                        updAdminParam() async {
                                                      try {
                                                        DocumentReference
                                                            documentReference =
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'userData')
                                                                .doc(documentSnapshot[
                                                                    'userID']);
                                                        documentReference
                                                            .update({
                                                          widget.groupSnapshot
                                                                  .id +
                                                              'admin': admin,
                                                        });
                                                      } catch (e) {}
                                                    }

                                                    Future
                                                        updAdminParamInGroup() async {
                                                      try {
                                                        DocumentReference
                                                            documentReference =
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'Groups')
                                                                .doc(widget
                                                                    .groupSnapshot
                                                                    .id);
                                                        documentReference
                                                            .update({
                                                          documentSnapshot[
                                                                  'userID'] +
                                                              'admin': admin,
                                                        });
                                                      } catch (e) {}
                                                    }

                                                    Future deleteUser() async {
                                                      final User user =
                                                          auth.currentUser;
                                                      final userId =
                                                          user.phoneNumber;
                                                      final List<String>
                                                          groupID = [
                                                        widget.groupSnapshot.id
                                                      ];

                                                      if (userId.isNotEmpty) {
                                                        // ignore: unused_local_variable
                                                        final documentReference =
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'userData')
                                                                .doc(documentSnapshot[
                                                                    'userID'])
                                                                .update({
                                                          "groupId": FieldValue
                                                              .arrayRemove(
                                                                  groupID)
                                                        });
                                                      }
                                                    }

                                                    Future
                                                        deleteUserFromGroup() async {
                                                      final User user =
                                                          auth.currentUser;
                                                      final userId =
                                                          user.phoneNumber;
                                                      final List<String>
                                                          memberID = [
                                                        documentSnapshot[
                                                            'userID']
                                                      ];

                                                      if (userId.isNotEmpty) {
                                                        // ignore: unused_local_variable
                                                        final documentReference =
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'Groups')
                                                                .doc(widget
                                                                    .groupSnapshot
                                                                    .id)
                                                                .update({
                                                          "members": FieldValue
                                                              .arrayRemove(
                                                                  memberID)
                                                        });
                                                      }
                                                    }

                                                    Future addGroupId() async {
                                                      final User user =
                                                          auth.currentUser;
                                                      final userId =
                                                          user.phoneNumber;

                                                      if (userId.isNotEmpty) {
                                                        // ignore: unused_local_variable
                                                        final documentReference =
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'Groups')
                                                                .doc(widget
                                                                    .groupSnapshot
                                                                    .id)
                                                                .update({
                                                          "groupID": widget
                                                              .groupSnapshot.id
                                                        });
                                                      }
                                                    }

                                                    Future<void>
                                                        showUserInfoDialog() async {
                                                      return await showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return StatefulBuilder(
                                                                builder: (BuildContext
                                                                        context,
                                                                    StateSetter
                                                                        setState) {
                                                              return AlertDialog(
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              20.0)),
                                                                  contentPadding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              0.0),
                                                                  content: Container(
                                                                      height: sizeX.height / 1.3,
                                                                      width: sizeX.width,
                                                                      child: Padding(
                                                                          padding: const EdgeInsets.fromLTRB(
                                                                            10.0,
                                                                            0.0,
                                                                            10.0,
                                                                            0.0,
                                                                          ),
                                                                          child: Stack(children: [
                                                                            ListView(physics: BouncingScrollPhysics(), children: [
                                                                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                                                                                Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
                                                                                  IconButton(
                                                                                      splashRadius: 20.0,
                                                                                      icon: Icon(Icons.close, color: Colors.black),
                                                                                      onPressed: () {
                                                                                        Navigator.of(context).pop();
                                                                                      })
                                                                                ]),
                                                                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                                                  Row(children: [
                                                                                    ClipOval(
                                                                                      child: CircleAvatar(
                                                                                        radius: 25.0,
                                                                                        backgroundColor: ConstColors.mainColor,
                                                                                        child: Image.network(documentSnapshot['userImage'].toString()),
                                                                                      ),
                                                                                    ),
                                                                                    Padding(
                                                                                        padding: const EdgeInsets.only(left: 10.0),
                                                                                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                                                                                          Text(
                                                                                            documentSnapshot['userName'].toString(),
                                                                                            style: TextStyle(fontSize: sizeX.height / 55, color: Colors.black, fontWeight: FontWeight.w500),
                                                                                          ),
                                                                                          Padding(
                                                                                              padding: const EdgeInsets.only(top: 5.0),
                                                                                              child: Text(
                                                                                                'San Francisco, CA',
                                                                                                style: TextStyle(fontSize: sizeX.height / 70, color: Colors.black, fontWeight: FontWeight.w300),
                                                                                              ))
                                                                                        ]))
                                                                                  ]),
                                                                                  Padding(
                                                                                      padding: EdgeInsets.only(right: 10.0),
                                                                                      child: Text(
                                                                                        documentSnapshot[widget.groupSnapshot.id + 'admin'] == true ? 'Admin' : '',
                                                                                        style: TextStyle(fontSize: sizeX.height / 65, color: Colors.black, fontWeight: FontWeight.w300),
                                                                                      ))
                                                                                ]),
                                                                                Padding(
                                                                                    padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 20.0),
                                                                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                                                      Text(AppLocalization.of(context).getTranslatedValue("info"),
                                                                                          style: TextStyle(
                                                                                            color: Colors.black,
                                                                                            fontSize: sizeX.height / 60,
                                                                                            fontWeight: FontWeight.w700,
                                                                                          )),
                                                                                      Padding(
                                                                                          padding: const EdgeInsets.only(top: 15.0),
                                                                                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                                                                                            Text(AppLocalization.of(context).getTranslatedValue("phone_number"),
                                                                                                style: TextStyle(
                                                                                                  color: Colors.black,
                                                                                                  fontSize: sizeX.height / 65,
                                                                                                  fontWeight: FontWeight.w400,
                                                                                                )),
                                                                                            Text(HomeScreenState.docSnap['appLang'] == 'עברית' ? documentSnapshot['userPhone'].toString().replaceAll(RegExp(r'[+]'), '') + '+' : documentSnapshot['userPhone'],
                                                                                                style: TextStyle(
                                                                                                  color: Colors.black,
                                                                                                  fontSize: sizeX.height / 65,
                                                                                                  fontWeight: FontWeight.w400,
                                                                                                ))
                                                                                          ])),
                                                                                      Padding(
                                                                                          padding: const EdgeInsets.only(top: 15.0),
                                                                                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                                                                                            Text(AppLocalization.of(context).getTranslatedValue("date_added"),
                                                                                                style: TextStyle(
                                                                                                  color: Colors.black,
                                                                                                  fontSize: sizeX.height / 65,
                                                                                                  fontWeight: FontWeight.w400,
                                                                                                )),
                                                                                            Text(dateEngDate.format(DateTime.tryParse(documentSnapshot[widget.groupSnapshot.id].toDate().toString())),
                                                                                                style: TextStyle(
                                                                                                  color: Colors.black,
                                                                                                  fontSize: sizeX.height / 65,
                                                                                                  fontWeight: FontWeight.w400,
                                                                                                ))
                                                                                          ])),
                                                                                      widget.groupSnapshot[uid + 'admin'] == true
                                                                                          ? Column(children: [
                                                                                              Padding(
                                                                                                  padding: const EdgeInsets.only(
                                                                                                    top: 20.0,
                                                                                                    bottom: 5.0,
                                                                                                  ),
                                                                                                  child: Text(AppLocalization.of(context).getTranslatedValue("access"),
                                                                                                      style: TextStyle(
                                                                                                        color: Colors.black,
                                                                                                        fontSize: sizeX.height / 60,
                                                                                                        fontWeight: FontWeight.w700,
                                                                                                      ))),
                                                                                              Padding(
                                                                                                  padding: const EdgeInsets.only(bottom: 10.0),
                                                                                                  child: Text(
                                                                                                    AppLocalization.of(context).getTranslatedValue("edit_permission_desc"),
                                                                                                    style: TextStyle(
                                                                                                      color: Colors.grey[400],
                                                                                                      fontSize: sizeX.height / 70,
                                                                                                      fontWeight: FontWeight.w400,
                                                                                                    ),
                                                                                                    textAlign: TextAlign.start,
                                                                                                  )),
                                                                                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                                                                                                Text(AppLocalization.of(context).getTranslatedValue("set_as_admin"),
                                                                                                    style: TextStyle(
                                                                                                      color: Colors.black,
                                                                                                      fontSize: sizeX.height / 65,
                                                                                                      fontWeight: FontWeight.w400,
                                                                                                    )),
                                                                                                Switch(
                                                                                                    inactiveTrackColor: Colors.grey[300],
                                                                                                    activeTrackColor: ConstColors.mainColor,
                                                                                                    activeColor: ConstColors.registerTextColor,
                                                                                                    value: saveState == false ? documentSnapshot[widget.groupSnapshot.id + 'admin'] : admin,
                                                                                                    onChanged: (value) {
                                                                                                      setState(() {
                                                                                                        saveState = true;
                                                                                                        statusChanging = true;
                                                                                                        admin = value;
                                                                                                      });
                                                                                                    })
                                                                                              ]),
                                                                                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                                                                                                Text(AppLocalization.of(context).getTranslatedValue("auto_rec"),
                                                                                                    style: TextStyle(
                                                                                                      color: Colors.black,
                                                                                                      fontSize: sizeX.height / 65,
                                                                                                      fontWeight: FontWeight.w400,
                                                                                                    )),
                                                                                                Switch(
                                                                                                    inactiveTrackColor: Colors.grey[300],
                                                                                                    activeTrackColor: ConstColors.mainColor,
                                                                                                    activeColor: ConstColors.registerTextColor,
                                                                                                    value: DatabaseService.temporarySate,
                                                                                                    onChanged: (value) {
                                                                                                      setState(() {
                                                                                                        DatabaseService.temporarySate = value;
                                                                                                      });
                                                                                                    })
                                                                                              ]),
                                                                                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                                                                                                Text(
                                                                                                  AppLocalization.of(context).getTranslatedValue("edit_rec"),
                                                                                                  style: TextStyle(
                                                                                                    color: Colors.black,
                                                                                                    fontSize: sizeX.height / 65,
                                                                                                    fontWeight: FontWeight.w400,
                                                                                                  ),
                                                                                                ),
                                                                                                Switch(
                                                                                                    inactiveTrackColor: Colors.grey[300],
                                                                                                    activeTrackColor: ConstColors.mainColor,
                                                                                                    activeColor: ConstColors.registerTextColor,
                                                                                                    value: DatabaseService.temporarySate,
                                                                                                    onChanged: (value) {
                                                                                                      setState(() {
                                                                                                        DatabaseService.temporarySate = value;
                                                                                                      });
                                                                                                    })
                                                                                              ])
                                                                                            ])
                                                                                          : Container(),
                                                                                    ]))
                                                                              ])
                                                                            ]),
                                                                            Positioned(
                                                                                left: 0.0,
                                                                                right: 0.0,
                                                                                bottom: 20.0,
                                                                                child: Center(
                                                                                    child: Column(children: [
                                                                                  Material(
                                                                                      elevation: 3.0,
                                                                                      borderRadius: BorderRadius.circular(20.0),
                                                                                      child: Container(
                                                                                          height: 35,
                                                                                          width: 180,
                                                                                          decoration: BoxDecoration(
                                                                                            gradient: ConstColors.saveUserStateInGroup,
                                                                                            borderRadius: BorderRadius.circular(20.0),
                                                                                          ),
                                                                                          child:
                                                                                              // ignore: deprecated_member_use
                                                                                              FlatButton(
                                                                                                  shape: RoundedRectangleBorder(
                                                                                                    borderRadius: BorderRadius.circular(20.0),
                                                                                                  ),
                                                                                                  onPressed: () {
                                                                                                    setState(() {
                                                                                                      saveState = false;
                                                                                                      updAdminParam();
                                                                                                      updAdminParamInGroup();
                                                                                                      Navigator.pop(context);
                                                                                                    });
                                                                                                    ((statusChanging == true) && (admin == true))
                                                                                                        ? showCustomFlushbar(
                                                                                                            context,
                                                                                                            '${documentSnapshot["userName"]} is an admin now!',
                                                                                                          )
                                                                                                        : ((statusChanging == true) && (admin == false))
                                                                                                            ? showCustomFlushbar(
                                                                                                                context,
                                                                                                                '${documentSnapshot["userName"]} is not an admin now!',
                                                                                                              )
                                                                                                            : setState(() {});
                                                                                                    setState(() => {});
                                                                                                  },
                                                                                                  child: Center(
                                                                                                      child: Text(
                                                                                                    AppLocalization.of(context).getTranslatedValue("save"),
                                                                                                    style: TextStyle(color: Colors.white, fontSize: sizeX.height / 60),
                                                                                                  ))))),
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.only(top: 10.0),
                                                                                    child: widget.groupSnapshot[uid + 'admin'] == true
                                                                                        ? Material(
                                                                                            elevation: 1.0,
                                                                                            borderRadius: BorderRadius.circular(20.0),
                                                                                            child: Container(
                                                                                                height: 35,
                                                                                                width: 180,
                                                                                                decoration: BoxDecoration(
                                                                                                  border: Border.all(width: 1.0, color: Colors.grey[500]),
                                                                                                  color: Colors.white,
                                                                                                  borderRadius: BorderRadius.circular(20.0),
                                                                                                ),
                                                                                                // ignore: deprecated_member_use
                                                                                                child: FlatButton(
                                                                                                    shape: RoundedRectangleBorder(
                                                                                                      borderRadius: BorderRadius.circular(20.0),
                                                                                                    ),
                                                                                                    onPressed: () {
                                                                                                      setState(() {
                                                                                                        deleteUser();
                                                                                                        deleteUserFromGroup().whenComplete(() => Navigator.pop(context));
                                                                                                      });
                                                                                                    },
                                                                                                    child: Center(
                                                                                                        child: Text(
                                                                                                      AppLocalization.of(context).getTranslatedValue("delete_from_group"),
                                                                                                      style: TextStyle(color: Colors.black, fontSize: sizeX.height / 65),
                                                                                                      textAlign: TextAlign.center,
                                                                                                    )))))
                                                                                        : Container(),
                                                                                  )
                                                                                ])))
                                                                          ]))));
                                                            });
                                                          });
                                                    }

                                                    return snapshot.data.docs
                                                                .length ==
                                                            1
                                                        ? Center(
                                                            child: Container(
                                                              child: Text(
                                                                AppLocalization.of(
                                                                        context)
                                                                    .getTranslatedValue(
                                                                        "you_are_only_one"),
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        sizeX.height /
                                                                            55,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                            ),
                                                          )
                                                        : Stack(children: [
                                                            Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        vertical:
                                                                            10.0,
                                                                        horizontal:
                                                                            5.0),
                                                                child: GestureDetector(
                                                                    onTap: () {
                                                                      setState(
                                                                          () async {
                                                                        statusChanging =
                                                                            false;
                                                                        saveState =
                                                                            false;
                                                                        addGroupId();
                                                                        await showUserInfoDialog();
                                                                      });
                                                                    },
                                                                    child: Container(
                                                                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [
                                                                          BoxShadow(
                                                                            blurRadius:
                                                                                1.0,
                                                                            spreadRadius:
                                                                                1.0,
                                                                            offset:
                                                                                Offset(1, 4),
                                                                            color:
                                                                                Colors.grey[200],
                                                                          )
                                                                        ]),
                                                                        height: sizeX.height / 2,
                                                                        width: sizeX.width / 4,
                                                                        child: CircleAvatar(
                                                                            backgroundColor: documentSnapshot['userImage'] != null || documentSnapshot['userImage'] != '' ? ConstColors.registerTextColor : Colors.transparent,
                                                                            child: Stack(children: <Widget>[
                                                                              Center(
                                                                                  child: ClipOval(
                                                                                      child: Image.network(
                                                                                documentSnapshot['userImage'],
                                                                              ))),
                                                                              Positioned(
                                                                                  right: 10.0,
                                                                                  bottom: 7.0,
                                                                                  child: CircleAvatar(
                                                                                    radius: 5.0,
                                                                                    backgroundColor: documentSnapshot['authState'] == true ? Colors.green : Colors.transparent,
                                                                                  )),
                                                                              Positioned(
                                                                                left: 0.0,
                                                                                bottom: 2.0,
                                                                                child: documentSnapshot['deleteFromGroup'] == true
                                                                                    ? CircleAvatar(
                                                                                        radius: 13.0,
                                                                                        backgroundColor: Colors.redAccent,
                                                                                        child: Center(
                                                                                            child: IconButton(
                                                                                                splashRadius: 15.0,
                                                                                                onPressed: () {},
                                                                                                icon: Icon(
                                                                                                  Icons.remove,
                                                                                                  color: Colors.white,
                                                                                                  size: 10,
                                                                                                ))))
                                                                                    : Container(),
                                                                              )
                                                                            ])))))
                                                          ]);
                                                  })))
                                    ]);
                              } else if (snapshot.hasError) {
                                Container();
                              }
                              return Container();
                            }))),
                Expanded(
                    child: Container(
                        height: sizeX.height / 1.7,
                        child: StreamBuilder(
                            stream: (searchString == null ||
                                    searchString.trim() == '')
                                ? FirebaseFirestore.instance
                                    .collection('CallLogs')
                                    .where('groupId',
                                        arrayContains: widget.groupSnapshot.id)
                                    .snapshots()
                                : FirebaseFirestore.instance
                                    .collection('CallLogs')
                                    .where('groupId',
                                        arrayContains: widget.groupSnapshot.id)
                                    .where('contactName',
                                        isEqualTo: searchString)
                                    .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return snapshot.data.docs.length == 0
                                    ? Padding(
                                        padding: EdgeInsets.only(
                                            top: sizeX.height / 4),
                                        child: Container(
                                            child: Text(
                                          AppLocalization.of(context)
                                              .getTranslatedValue(
                                                  "no_recordings_yet"),
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: sizeX.height / 55,
                                              fontWeight: FontWeight.w500),
                                        )))
                                    : ListView.builder(
                                        physics: BouncingScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: snapshot.data.docs.length,
                                        itemBuilder: (context, index) {
                                          FirebaseAuth auth =
                                              FirebaseAuth.instance;
                                          User user = auth.currentUser;
                                          final uid = user.phoneNumber;
                                          DocumentSnapshot documentSnapshot =
                                              snapshot.data.docs[index];
                                          Timestamp timestamp =
                                              documentSnapshot['startCallTime'];

                                          return Padding(
                                              padding: EdgeInsets.only(
                                                top: 10.0,
                                              ),
                                              child: Material(
                                                  elevation: 2.0,
                                                  child: AnimatedContainer(
                                                      curve:
                                                          Curves.fastOutSlowIn,
                                                      height: 95,
                                                      width: _width,
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
                                                      duration: Duration(
                                                        milliseconds: 300,
                                                      ),
                                                      child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 5.0,
                                                                  bottom: 5.0,
                                                                  left: 5.0,
                                                                  right: 5.0),
                                                          // ignore: deprecated_member_use
                                                          child: FlatButton(
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              15)),
                                                              onPressed: () {
                                                                showDialog(
                                                                    barrierDismissible:
                                                                        true,
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (BuildContext
                                                                            context) {
                                                                      return AlertDialog(
                                                                          contentPadding: EdgeInsets.all(
                                                                              0.0),
                                                                          shape:
                                                                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                                                                          content: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                                                                            return Container(
                                                                                height: sizeX.height / 1.3,
                                                                                width: sizeX.width / 1.1,
                                                                                child: Stack(children: [
                                                                                  ListView(physics: BouncingScrollPhysics(), children: <Widget>[
                                                                                    Stack(children: [
                                                                                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                                                                                        Padding(
                                                                                            padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                                                                                            child: Row(children: <Widget>[
                                                                                              ClipOval(
                                                                                                child: CircleAvatar(
                                                                                                  radius: 30.0,
                                                                                                  backgroundColor: Colors.white,
                                                                                                  child: Image.asset(documentSnapshot['logImage'], fit: BoxFit.cover),
                                                                                                ),
                                                                                              ),
                                                                                              Padding(
                                                                                                  padding: EdgeInsets.only(
                                                                                                    left: 15.0,
                                                                                                  ),
                                                                                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                                                                                                    Text(((documentSnapshot['contactName'] == documentSnapshot['contactPhoneNumber']) && (HomeScreenState.docSnap['appLang'] == 'עברית')) ? documentSnapshot['contactPhoneNumber'].toString().replaceAll(RegExp(r'[+]'), '') + '+' : documentSnapshot['contactName'],
                                                                                                        style: TextStyle(
                                                                                                          fontSize: sizeX.height / 60,
                                                                                                          fontWeight: FontWeight.w700,
                                                                                                        )),
                                                                                                    Padding(
                                                                                                        padding: EdgeInsets.only(top: 5.0),
                                                                                                        child: Text(HomeScreenState.docSnap['appLang'] == 'עברית' ? documentSnapshot['contactPhoneNumber'].toString().replaceAll(RegExp(r'[+]'), '') + '+' : documentSnapshot['contactPhoneNumber'],
                                                                                                            style: TextStyle(
                                                                                                              fontSize: sizeX.height / 75,
                                                                                                              fontWeight: FontWeight.w700,
                                                                                                            ))),
                                                                                                    Row(children: [
                                                                                                      Padding(
                                                                                                          padding: EdgeInsets.only(top: 5.0),
                                                                                                          child: Text(dateEngStartTime.format(DateTime.tryParse(timestamp.toDate().toString())).toString(),
                                                                                                              style: TextStyle(
                                                                                                                fontSize: sizeX.height / 75,
                                                                                                                fontWeight: FontWeight.w400,
                                                                                                              ))),
                                                                                                      Padding(
                                                                                                          padding: EdgeInsets.only(left: 15.0, top: 5.0),
                                                                                                          child: Text(dateEngDate.format(DateTime.tryParse(timestamp.toDate().toString())).toString(),
                                                                                                              style: TextStyle(
                                                                                                                fontSize: sizeX.height / 75,
                                                                                                                fontWeight: FontWeight.w400,
                                                                                                              )))
                                                                                                    ])
                                                                                                  ]))
                                                                                            ])),
                                                                                        FadeAnimation(
                                                                                            0.5,
                                                                                            Padding(
                                                                                                padding: EdgeInsets.only(top: 10.0),
                                                                                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                                                                                                  Padding(
                                                                                                      padding: const EdgeInsets.only(
                                                                                                        left: 10.0,
                                                                                                        bottom: 10.0,
                                                                                                      ),
                                                                                                      child: Container(
                                                                                                          child: Row(
                                                                                                        children: <Widget>[],
                                                                                                      ))),
                                                                                                  Container(
                                                                                                      color: Colors.grey[100],
                                                                                                      child: Padding(
                                                                                                          padding: EdgeInsets.only(left: 10.0),
                                                                                                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                                                                            Padding(
                                                                                                                padding: EdgeInsets.only(
                                                                                                                  top: 5.0,
                                                                                                                  bottom: 10.0,
                                                                                                                  left: 5.0,
                                                                                                                ),
                                                                                                                child: Text(
                                                                                                                  AppLocalization.of(context).getTranslatedValue("my_notes"),
                                                                                                                  style: TextStyle(
                                                                                                                    color: Colors.black,
                                                                                                                    fontWeight: FontWeight.w600,
                                                                                                                  ),
                                                                                                                )),
                                                                                                            Padding(
                                                                                                                padding: const EdgeInsets.only(left: 10.0, bottom: 10.0),
                                                                                                                child: Text(
                                                                                                                  documentSnapshot['logNotes'],
                                                                                                                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                                                                                                                )),
                                                                                                            Container(
                                                                                                                child: Row(children: <Widget>[
                                                                                                              Expanded(
                                                                                                                  child: Container(
                                                                                                                      decoration: BoxDecoration(
                                                                                                                        color: Colors.grey[300],
                                                                                                                        borderRadius: BorderRadius.circular(20.0),
                                                                                                                      ),
                                                                                                                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                                                                                                                        Container(
                                                                                                                            height: 35.0,
                                                                                                                            width: 35.0,
                                                                                                                            decoration: BoxDecoration(
                                                                                                                              border: Border.all(width: 3, color: Colors.black),
                                                                                                                              shape: BoxShape.circle,
                                                                                                                            ),
                                                                                                                            child: CircleAvatar(
                                                                                                                                backgroundColor: Colors.grey[200],
                                                                                                                                child: Icon(
                                                                                                                                  Icons.stop,
                                                                                                                                  color: Colors.black,
                                                                                                                                ))),
                                                                                                                        Padding(
                                                                                                                            padding: EdgeInsets.only(
                                                                                                                              right: 15.0,
                                                                                                                            ),
                                                                                                                            child: Text('10:04',
                                                                                                                                style: TextStyle(
                                                                                                                                  color: Colors.black,
                                                                                                                                  fontSize: 10.0,
                                                                                                                                )))
                                                                                                                      ]))),
                                                                                                              Padding(
                                                                                                                  padding: EdgeInsets.only(right: 15.0, left: 8.0),
                                                                                                                  child: CircleAvatar(
                                                                                                                      backgroundColor: ConstColors.registerTextColor,
                                                                                                                      child: Image.asset(
                                                                                                                        'assets/icons/icon_speach_to_text.png',
                                                                                                                      )))
                                                                                                            ]))
                                                                                                          ]))),
                                                                                                  Padding(
                                                                                                      padding: EdgeInsets.only(
                                                                                                        top: 20.0,
                                                                                                        bottom: 15.0,
                                                                                                        left: 15.0,
                                                                                                      ),
                                                                                                      child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                                                                                                        Text(
                                                                                                          AppLocalization.of(context).getTranslatedValue("groups_sort_title"),
                                                                                                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                                                                                                        ),
                                                                                                        StreamBuilder(
                                                                                                            stream: FirebaseFirestore.instance.collection('Groups').where('members', arrayContains: uid).snapshots(),
                                                                                                            builder: (BuildContext context, AsyncSnapshot snapshot) {
                                                                                                              if (snapshot.hasData) {
                                                                                                                return Container(
                                                                                                                    height: sizeX.height / 14,
                                                                                                                    child: ListView.builder(
                                                                                                                        physics: BouncingScrollPhysics(),
                                                                                                                        scrollDirection: Axis.horizontal,
                                                                                                                        itemCount: snapshot.data.docs.length,
                                                                                                                        itemBuilder: (context, index) {
                                                                                                                          DocumentSnapshot docSnap = snapshot.data.docs[index];

                                                                                                                          Future addGroupIdToLog() async {
                                                                                                                            final List<String> groupId = [docSnap.id];

                                                                                                                            final documentReference = FirebaseFirestore.instance;
                                                                                                                            documentReference.collection('CallLogs').doc(timestamp.toDate().toString()).update({
                                                                                                                              'groupId': FieldValue.arrayUnion(groupId),
                                                                                                                            });
                                                                                                                          }

                                                                                                                          return Padding(
                                                                                                                              padding: const EdgeInsets.only(
                                                                                                                                top: 15.0,
                                                                                                                                right: 10.0,
                                                                                                                              ),
                                                                                                                              child: GestureDetector(
                                                                                                                                  onTap: () {
                                                                                                                                    addGroupIdToLog();
                                                                                                                                  },
                                                                                                                                  child: Container(
                                                                                                                                      decoration: BoxDecoration(
                                                                                                                                        borderRadius: BorderRadius.circular(20.0),
                                                                                                                                        color: ConstColors.groupsOnLogs,
                                                                                                                                      ),
                                                                                                                                      child: Center(
                                                                                                                                          child: Padding(
                                                                                                                                              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                                                                                                                                              child: Text(
                                                                                                                                                docSnap['groupName'],
                                                                                                                                                style: TextStyle(color: Colors.white),
                                                                                                                                              ))))));
                                                                                                                        }));
                                                                                                              } else if (snapshot.hasError || !snapshot.hasData) {
                                                                                                                return Container();
                                                                                                              }
                                                                                                              return Center(
                                                                                                                child: Container(),
                                                                                                              );
                                                                                                            })
                                                                                                      ]))
                                                                                                ])))
                                                                                      ])
                                                                                    ])
                                                                                  ]),
                                                                                  Positioned(
                                                                                      left: 0.0,
                                                                                      right: 0.0,
                                                                                      bottom: 10.0,
                                                                                      child: Center(
                                                                                          child: Material(
                                                                                              elevation: 3.0,
                                                                                              borderRadius: BorderRadius.circular(
                                                                                                25.0,
                                                                                              ),
                                                                                              child: Container(
                                                                                                  height: 45.0,
                                                                                                  width: 150.0,
                                                                                                  decoration: BoxDecoration(
                                                                                                    borderRadius: BorderRadius.circular(
                                                                                                      25.0,
                                                                                                    ),
                                                                                                    color: ConstColors.mainColor,
                                                                                                  ),
                                                                                                  // ignore: deprecated_member_use
                                                                                                  child: FlatButton(
                                                                                                      shape: RoundedRectangleBorder(
                                                                                                        borderRadius: BorderRadius.circular(
                                                                                                          25.0,
                                                                                                        ),
                                                                                                      ),
                                                                                                      onPressed: () {
                                                                                                        Navigator.of(context).pop();
                                                                                                      },
                                                                                                      child: Text(AppLocalization.of(context).getTranslatedValue("close"),
                                                                                                          style: TextStyle(
                                                                                                            color: Colors.white,
                                                                                                          )))))))
                                                                                ]));
                                                                          }));
                                                                    });
                                                              },
                                                              child: Stack(
                                                                  children: [
                                                                    Positioned(
                                                                        left:
                                                                            0.0,
                                                                        top:
                                                                            0.0,
                                                                        right:
                                                                            0.0,
                                                                        bottom:
                                                                            0.0,
                                                                        child: Center(
                                                                            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
                                                                          ClipOval(
                                                                            child:
                                                                                CircleAvatar(
                                                                              radius: 25.0,
                                                                              backgroundColor: Colors.white,
                                                                              child: Image.asset(documentSnapshot['logImage'], fit: BoxFit.cover),
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                              padding: const EdgeInsets.only(left: 15.0),
                                                                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                                                                                Text(
                                                                                  ((documentSnapshot['contactName'] == documentSnapshot['contactPhoneNumber']) && (HomeScreenState.docSnap['appLang'] == 'עברית')) ? documentSnapshot['contactPhoneNumber'].toString().replaceAll(RegExp(r'[+]'), '') + '+' : documentSnapshot['contactName'],
                                                                                  style: TextStyle(
                                                                                    color: Colors.black,
                                                                                    fontSize: sizeX.height / 55,
                                                                                    fontWeight: FontWeight.w700,
                                                                                  ),
                                                                                  softWrap: true,
                                                                                ),
                                                                                Padding(
                                                                                    padding: const EdgeInsets.only(top: 5.0),
                                                                                    child: Text(
                                                                                      HomeScreenState.docSnap['appLang'] == 'עברית' ? documentSnapshot['contactPhoneNumber'].toString().replaceAll(RegExp(r'[+]'), '') + '+' : documentSnapshot['contactPhoneNumber'],
                                                                                      style: TextStyle(
                                                                                        color: Colors.black,
                                                                                        fontSize: sizeX.height / 80,
                                                                                        fontWeight: FontWeight.w700,
                                                                                      ),
                                                                                      softWrap: true,
                                                                                    )),
                                                                                Row(children: [
                                                                                  Padding(
                                                                                      padding: EdgeInsets.only(top: 5.0),
                                                                                      child: Text(dateEngStartTime.format(DateTime.tryParse(timestamp.toDate().toString())).toString(),
                                                                                          style: TextStyle(
                                                                                            fontSize: sizeX.height / 75,
                                                                                            fontWeight: FontWeight.w400,
                                                                                          ))),
                                                                                  Padding(
                                                                                      padding: EdgeInsets.only(left: 15.0, top: 5.0),
                                                                                      child: Text(dateEngDate.format(DateTime.tryParse(timestamp.toDate().toString())).toString(),
                                                                                          style: TextStyle(
                                                                                            fontSize: sizeX.height / 75,
                                                                                            fontWeight: FontWeight.w400,
                                                                                          )))
                                                                                ])
                                                                              ])),
                                                                          Padding(
                                                                              padding: const EdgeInsets.only(
                                                                                left: 30.0,
                                                                              ),
                                                                              child: Container(
                                                                                  height: 55,
                                                                                  width: 90,
                                                                                  decoration: BoxDecoration(color: ConstColors.lightBlue, borderRadius: BorderRadius.circular(25.0)),
                                                                                  child: Padding(
                                                                                      padding: EdgeInsets.only(left: 5.0),
                                                                                      child: Row(children: [
                                                                                        Container(
                                                                                            height: 30.0,
                                                                                            width: 30.0,
                                                                                            decoration: BoxDecoration(
                                                                                              border: Border.all(width: 3, color: Colors.black),
                                                                                              shape: BoxShape.circle,
                                                                                            ),
                                                                                            child: CircleAvatar(
                                                                                                backgroundColor: ConstColors.lightBlue,
                                                                                                radius: 20.0,
                                                                                                child: Icon(
                                                                                                  Icons.play_arrow,
                                                                                                  color: Colors.black,
                                                                                                ))),
                                                                                        Padding(padding: const EdgeInsets.only(left: 5), child: Text('10:04', style: TextStyle(fontSize: 12.0)))
                                                                                      ]))))
                                                                        ])))
                                                                  ]))))));
                                        });
                              } else if (snapshot.hasError ||
                                  !snapshot.hasData) {
                                return Container();
                              }
                              return Container();
                            })))
              ]))
        ])));
  }

  addCollLogDialog(BuildContext context) {
    var sizeX = MediaQuery.of(context).size;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            contentPadding: EdgeInsets.all(0.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                12.0,
              ),
            ),
            content: Container(
                height: sizeX.height / 1.2,
                width: sizeX.width,
                child: Column(children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      IconButton(
                          splashRadius: 20.0,
                          icon: Icon(
                            Icons.close,
                            color: Colors.black,
                          ),
                          onPressed: () => Navigator.pop(context))
                    ],
                  ),
                  Text(
                      AppLocalization.of(context)
                          .getTranslatedValue("choose_call_logs"),
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: sizeX.height / 50,
                      )),
                  Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: StatefulBuilder(builder:
                          (BuildContext context, StateSetter setState) {
                        final FirebaseAuth auth = FirebaseAuth.instance;
                        final User user = auth.currentUser;
                        final String uid = user.phoneNumber;
                        return StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('CallLogs')
                                .orderBy('startCallTime', descending: true)
                                .where('logOwner', isEqualTo: uid)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Stack(children: [
                                  Container(
                                      width: sizeX.width,
                                      height: sizeX.height / 1.4,
                                      child: ListView.builder(
                                          physics: BouncingScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: snapshot.data.docs.length,
                                          itemBuilder: (context, index) {
                                            DocumentSnapshot documentSnapshot =
                                                snapshot.data.docs[index];
                                            Timestamp timestamp =
                                                documentSnapshot[
                                                    'startCallTime'];
                                            Future addSatateUpdate() async {
                                              try {
                                                DocumentReference
                                                    documentReference =
                                                    FirebaseFirestore.instance
                                                        .collection('CallLogs')
                                                        .doc(timestamp
                                                            .toDate()
                                                            .toString());
                                                documentReference.update({
                                                  'addToGroup': DatabaseService
                                                              .addToGroup ==
                                                          false
                                                      ? false
                                                      : true,
                                                });
                                              } catch (e) {}
                                            }

                                            return Padding(
                                                padding: EdgeInsets.only(
                                                  bottom: 5.0,
                                                  top: 5.0,
                                                ),
                                                child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 5.0,
                                                            right: 5.0),
                                                    child: Material(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15.0),
                                                        ),
                                                        elevation: 3.0,
                                                        child: Container(
                                                            height: 60,
                                                            width:
                                                                sizeX.width / 2,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15.0),
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            10.0),
                                                                child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Row(
                                                                          mainAxisAlignment: MainAxisAlignment
                                                                              .start,
                                                                          children: <
                                                                              Widget>[
                                                                            Padding(
                                                                              padding: EdgeInsets.only(
                                                                                left: 10.0,
                                                                              ),
                                                                              child: ClipOval(
                                                                                child: CircleAvatar(
                                                                                  radius: 20.0,
                                                                                  backgroundColor: Colors.white,
                                                                                  child: Image.asset(documentSnapshot['logImage'], fit: BoxFit.cover),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Padding(
                                                                                padding: EdgeInsets.only(left: 15.0),
                                                                                child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                                                                                  Text(
                                                                                    ((documentSnapshot['contactName'] == documentSnapshot['contactPhoneNumber']) && (HomeScreenState.docSnap['appLang'] == 'עברית')) ? documentSnapshot['contactPhoneNumber'].toString().replaceAll(RegExp(r'[+]'), '') + '+' : documentSnapshot['contactName'],
                                                                                    style: TextStyle(
                                                                                      color: Colors.black,
                                                                                      fontWeight: FontWeight.w800,
                                                                                      fontSize: sizeX.height / 75,
                                                                                    ),
                                                                                  ),
                                                                                  Padding(
                                                                                      padding: EdgeInsets.only(top: 5.0),
                                                                                      child: Text(dateEngStartTime.format(DateTime.tryParse(timestamp.toDate().toString())).toString(),
                                                                                          style: TextStyle(
                                                                                            color: Colors.black,
                                                                                            fontSize: sizeX.height / 75,
                                                                                          )))
                                                                                ]))
                                                                          ]),
                                                                      Checkbox(
                                                                          activeColor: ConstColors
                                                                              .registerTextColor,
                                                                          value: documentSnapshot[
                                                                              'addToGroup'],
                                                                          tristate:
                                                                              false,
                                                                          onChanged:
                                                                              (value) {
                                                                            setState(() {
                                                                              DatabaseService.addToGroup = value;
                                                                              addSatateUpdate();
                                                                            });
                                                                          })
                                                                    ]))))));
                                          })),
                                  Positioned(
                                      bottom: 20.0,
                                      left: 0.0,
                                      right: 0.0,
                                      child: Center(
                                          child: StreamBuilder(
                                              stream: FirebaseFirestore.instance
                                                  .collection('CallLogs')
                                                  .where('addToGroup',
                                                      isEqualTo: true)
                                                  .snapshots(),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot snapshot) {
                                                Future addGroupIdToLog() async {
                                                  final List<String> groupId = [
                                                    widget.groupSnapshot.id
                                                  ];
                                                  // ignore: unused_local_variable
                                                  var snap = FirebaseFirestore
                                                      .instance
                                                      .collection('CallLogs')
                                                      .where('addToGroup',
                                                          isEqualTo: true)
                                                      .get()
                                                      .then((snapShot) {
                                                    snapShot.docs
                                                        .forEach((doc) {
                                                      print(doc.id);
                                                      doc.reference.update({
                                                        'groupId': FieldValue
                                                            .arrayUnion(groupId)
                                                      });
                                                    });
                                                  });
                                                }

                                                Future stateRevome() async {
                                                  // ignore: unused_local_variable
                                                  var snap = FirebaseFirestore
                                                      .instance
                                                      .collection('CallLogs')
                                                      .where('addToGroup',
                                                          isEqualTo: true)
                                                      .get()
                                                      .then((snapShot) {
                                                    snapShot.docs
                                                        .forEach((doc) {
                                                      print(doc.id);
                                                      doc.reference.update({
                                                        'addToGroup': false
                                                      });
                                                    });
                                                  });
                                                }

                                                if (snapshot.hasData) {
                                                  return Material(
                                                      elevation: 3.0,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20.0),
                                                      ),
                                                      child: Container(
                                                          height: 40,
                                                          width:
                                                              sizeX.width / 2,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: ConstColors
                                                                .mainColor,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20.0),
                                                          ),
                                                          // ignore: deprecated_member_use
                                                          child: FlatButton(
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20.0),
                                                              ),
                                                              onPressed: () {
                                                                setState(() {
                                                                  addGroupIdToLog()
                                                                      .whenComplete(() =>
                                                                          setState(
                                                                              () {
                                                                            stateRevome();
                                                                          }));
                                                                });

                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: Text(
                                                                AppLocalization.of(
                                                                        context)
                                                                    .getTranslatedValue(
                                                                        "add"),
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        sizeX.height /
                                                                            60),
                                                              ))));
                                                } else if (snapshot.hasError ||
                                                    !snapshot.hasData) {
                                                  return Container();
                                                }
                                                return Container();
                                              })))
                                ]);
                              } else if (snapshot.hasError ||
                                  !snapshot.hasData) {
                                return Container();
                              }
                              return Container();
                            });
                      }))
                ])));
      },
    );
  }
}
