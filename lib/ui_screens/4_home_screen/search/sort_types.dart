import 'package:flutter/material.dart';
import 'package:flutter_app/constants/constants.dart';
import 'package:flutter_app/localization/localization.dart';
import 'package:flutter_app/ui_screens/4_home_screen/filtered_calls/phone_logs.dart';
import '../../screens.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

class SortTypes extends StatefulWidget {
  @override
  SortTypesState createState() => SortTypesState();
}

class SortTypesState extends State<SortTypes> {
  int selectedDate = 0;
  int selectedCalls = 0;
  int selectedContacts = 0;
  int selectedLabel = 0;
  int selectedGroup = 0;

  static bool allDate = true;
  static bool todayDate = false;
  static bool thisWeekDate = false;
  static bool thisMonthDate = false;
  var endCallTime = DateFormat('yyyy-MM-dd 00:00:00.000');

  static bool saved = false;
  static bool unsaved = false;
  static bool allCont = true;

  static bool allCalls = true;
  static bool incoming = false;
  static bool outgoing = false;
  DateTime now = DateTime.now();
  bool select;
  static String groupIdd = '';
  String groupColor = '';

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    User user = auth.currentUser;
    final uid = user.phoneNumber;

    var sizeX = MediaQuery.of(context).size;
    return Stack(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: sizeX.height / 7),
          child: SafeArea(
            child: ListView(
              physics: BouncingScrollPhysics(),
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ListTile(
                      title: Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: Text(
                          AppLocalization.of(context)
                              .getTranslatedValue("date_sort_title"),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: sizeX.height / 55,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      subtitle: Container(
                        height: sizeX.height / 20,
                        child: ListView(
                          physics: BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 12.0, top: 5),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    allDate = true;
                                    todayDate = false;
                                    thisWeekDate = false;
                                    thisMonthDate = false;
                                    PhonelogsScreenState.searchDateParam =
                                        'searchAll';
                                    PhonelogsScreenState.dateState = 'all';
                                    print(PhonelogsScreenState.dateState);
                                  });
                                },
                                child: Material(
                                  elevation: 3.0,
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        color: allDate == true
                                            ? ConstColors.search
                                            : ConstColors.searchTypesColor),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15.0, right: 15.0),
                                        child: Text(
                                          AppLocalization.of(context)
                                              .getTranslatedValue("all_type"),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: sizeX.height / 55,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0, top: 5),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    allDate = false;
                                    todayDate = true;
                                    thisWeekDate = false;
                                    thisMonthDate = false;
                                    PhonelogsScreenState.searchDateParam =
                                        'searchTime';
                                    PhonelogsScreenState.dateState =
                                        endCallTime.format(now);
                                    print(PhonelogsScreenState.dateState);
                                  });
                                },
                                child: Material(
                                  elevation: 3.0,
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        color: todayDate == true
                                            ? ConstColors.search
                                            : ConstColors.searchTypesColor),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15.0, right: 15.0),
                                        child: Text(
                                          AppLocalization.of(context)
                                              .getTranslatedValue("today_type"),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: sizeX.height / 55,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0, top: 5),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    allDate = false;
                                    todayDate = false;
                                    thisWeekDate = true;
                                    thisMonthDate = false;
                                    PhonelogsScreenState.searchDateParam =
                                        'searchWeek';
                                    PhonelogsScreenState.dateState =
                                        Jiffy().week.toString();
                                    print(PhonelogsScreenState.dateState);
                                  });
                                },
                                child: Material(
                                  elevation: 3.0,
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        color: thisWeekDate == true
                                            ? ConstColors.search
                                            : ConstColors.searchTypesColor),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15.0, right: 15.0),
                                        child: Text(
                                          AppLocalization.of(context)
                                              .getTranslatedValue(
                                                  "this_week_type"),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: sizeX.height / 55,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0, top: 5),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    allDate = false;
                                    todayDate = false;
                                    thisWeekDate = false;
                                    thisMonthDate = true;
                                    PhonelogsScreenState.searchDateParam =
                                        'searchMonth';
                                    PhonelogsScreenState.dateState = endCallTime
                                        .format(DateTime(now.year, now.month));
                                    print(PhonelogsScreenState.dateState);
                                  });
                                },
                                child: Material(
                                  elevation: 3.0,
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        color: thisMonthDate == true
                                            ? ConstColors.search
                                            : ConstColors.searchTypesColor),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15.0, right: 15.0),
                                        child: Text(
                                          AppLocalization.of(context)
                                              .getTranslatedValue(
                                                  "this_month_type"),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: sizeX.height / 55,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ListTile(
                      title: Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: Text(
                          AppLocalization.of(context)
                              .getTranslatedValue("calls_sort_title"),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: sizeX.height / 55,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      subtitle: Container(
                        height: sizeX.height / 22,
                        child: ListView(
                          physics: BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 12.0, top: 5),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    allCalls = true;
                                    incoming = false;
                                    outgoing = false;
                                    PhonelogsScreenState.callAll = 'all';
                                    PhonelogsScreenState.callType = '';
                                    print(PhonelogsScreenState.callType);
                                  });
                                },
                                child: Material(
                                  elevation: 3.0,
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        color: allCalls == true
                                            ? ConstColors.search
                                            : ConstColors.searchTypesColor),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15.0, right: 15.0),
                                        child: Text(
                                          AppLocalization.of(context)
                                              .getTranslatedValue("all_type"),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: sizeX.height / 55,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0, top: 5),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    incoming = true;
                                    outgoing = false;
                                    allCalls = false;
                                    print(incoming);
                                    PhonelogsScreenState.callType = 'Incoming';
                                    PhonelogsScreenState.callAll = 'Incoming';
                                    print(PhonelogsScreenState.callType);
                                  });
                                },
                                child: Material(
                                  elevation: 3.0,
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        color: incoming == true
                                            ? ConstColors.search
                                            : ConstColors.searchTypesColor),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15.0, right: 15.0),
                                        child: Text(
                                          AppLocalization.of(context)
                                              .getTranslatedValue(
                                                  "incoming_type"),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: sizeX.height / 55,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0, top: 5),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    allCalls = false;
                                    outgoing = true;
                                    incoming = false;
                                    PhonelogsScreenState.callType = 'Outgoing';
                                    PhonelogsScreenState.callAll = 'Outgoing';
                                    print(PhonelogsScreenState.callType);
                                  });
                                },
                                child: Material(
                                  elevation: 3.0,
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        color: outgoing == true
                                            ? ConstColors.search
                                            : ConstColors.searchTypesColor),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15.0, right: 15.0),
                                        child: Text(
                                          AppLocalization.of(context)
                                              .getTranslatedValue(
                                                  "outgoing_type"),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: sizeX.height / 55,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ListTile(
                      title: Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: Text(
                          AppLocalization.of(context)
                              .getTranslatedValue("contacts_sort_title"),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: sizeX.height / 55,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      subtitle: Container(
                        height: sizeX.height / 22,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: ListView(
                            physics: BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 12.0),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      allCont = true;
                                      unsaved = false;
                                      saved = false;
                                    });
                                  },
                                  child: Material(
                                    elevation: 3.0,
                                    borderRadius: BorderRadius.circular(15.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          color: allCont == true
                                              ? ConstColors.search
                                              : ConstColors.searchTypesColor),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 15.0, right: 15.0),
                                          child: Text(
                                            AppLocalization.of(context)
                                                .getTranslatedValue("all_type"),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: sizeX.height / 55,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      unsaved = false;
                                      saved = true;
                                      allCont = false;
                                    });
                                  },
                                  child: Material(
                                    elevation: 3.0,
                                    borderRadius: BorderRadius.circular(15.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          color: saved == true
                                              ? ConstColors.search
                                              : ConstColors.searchTypesColor),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 15.0, right: 15.0),
                                          child: Text(
                                            AppLocalization.of(context)
                                                .getTranslatedValue(
                                                    "saved_type"),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: sizeX.height / 55,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 5.0,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      allCont = false;
                                      unsaved = true;
                                      saved = false;
                                    });
                                  },
                                  child: Material(
                                    elevation: 3.0,
                                    borderRadius: BorderRadius.circular(15.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          color: unsaved == true
                                              ? ConstColors.search
                                              : ConstColors.searchTypesColor),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 15.0, right: 15.0),
                                          child: Text(
                                            AppLocalization.of(context)
                                                .getTranslatedValue(
                                                    "unsaved_type"),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: sizeX.height / 55,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                        title: Padding(
                          padding: const EdgeInsets.only(
                            left: 12.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalization.of(context)
                                    .getTranslatedValue("groups_title"),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: sizeX.height / 55,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Container(
                                height: 20,
                                width: 20,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: Colors.black,
                                  size: 14,
                                ),
                              )
                            ],
                          ),
                        ),
                        subtitle: Container(
                          height: sizeX.height / 22,
                          child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('Groups')
                                .where('members', arrayContains: uid)
                                .snapshots(),
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              DocumentSnapshot documentSnapG;
                              if (snapshot.hasData) {
                                Future groupSearchUpdate() async {
                                  FirebaseAuth auth = FirebaseAuth.instance;
                                  User user = auth.currentUser;
                                  final uid = user.phoneNumber;
                                  try {
                                    final docRef = FirebaseFirestore.instance
                                        .collection('CallLogs')
                                        .where('logOwner', isEqualTo: uid)
                                        .where('groupId',
                                            arrayContains: documentSnapG.id);
                                    docRef.get().then((QuerySnapshot snapsnot) {
                                      snapsnot.docs
                                          .forEach((DocumentSnapshot doc) {
                                        doc.reference.update({
                                          'groupSearch':
                                              selectedGroup.toString(),
                                        });
                                        print(documentSnapG.id);
                                      });
                                    });
                                  } catch (e) {}
                                }

                                Future groupSearchUpdateAll() async {
                                  FirebaseAuth auth = FirebaseAuth.instance;
                                  User user = auth.currentUser;
                                  final uid = user.phoneNumber;
                                  try {
                                    final docRef = FirebaseFirestore.instance
                                        .collection('CallLogs')
                                        .where('logOwner', isEqualTo: uid);
                                    docRef.get().then((QuerySnapshot snapsnot) {
                                      snapsnot.docs
                                          .forEach((DocumentSnapshot doc) {
                                        doc.reference.update({
                                          'groupSearch':
                                              PhonelogsScreenState.groupSearch,
                                        });
                                      });
                                    });
                                  } catch (e) {}
                                }

                                Future groupColorUpd() async {
                                  FirebaseAuth auth = FirebaseAuth.instance;
                                  User user = auth.currentUser;
                                  final uid = user.phoneNumber;
                                  try {
                                    final docRef = FirebaseFirestore.instance
                                        .collection('Groups')
                                        .where('members', arrayContains: uid);
                                    docRef.get().then((QuerySnapshot snapsnot) {
                                      snapsnot.docs
                                          .forEach((DocumentSnapshot doc) {
                                        doc.reference.update({
                                          'groupColor' + uid: '0',
                                        });
                                      });
                                    });
                                  } catch (e) {}
                                }

                                Future groupColorUpdSingle() async {
                                  FirebaseAuth auth = FirebaseAuth.instance;
                                  User user = auth.currentUser;
                                  final uid = user.phoneNumber;
                                  try {
                                    final docRef = FirebaseFirestore.instance
                                        .collection('Groups')
                                        .where('members', arrayContains: uid)
                                        .where('groupID', isEqualTo: groupIdd);
                                    docRef.get().then((QuerySnapshot snapsnot) {
                                      snapsnot.docs
                                          .forEach((DocumentSnapshot doc) {
                                        doc.reference.update({
                                          'groupColor' + uid: '1',
                                          'groupID': groupIdd,
                                        });
                                      });
                                    });
                                  } catch (e) {}
                                }

                                return Row(
                                  children: [
                                    Padding(
                                      padding:
                                          EdgeInsets.only(left: 12.0, top: 5.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            PhonelogsScreenState.groupSearch =
                                                'all';
                                            groupSearchUpdateAll();
                                            groupColorUpd();
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: PhonelogsScreenState
                                                        .groupSearch ==
                                                    'all'
                                                ? ConstColors.search
                                                : ConstColors.searchTypesColor,
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 15.0,
                                                right: 15.0,
                                                top: 5.0,
                                                bottom: 5.0),
                                            child: Text(
                                              AppLocalization.of(context)
                                                  .getTranslatedValue(
                                                      "all_type"),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: sizeX.height / 55,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: ListView.builder(
                                          physics: BouncingScrollPhysics(),
                                          scrollDirection: Axis.horizontal,
                                          itemCount: snapshot.data.docs.length,
                                          itemBuilder: (context, index) {
                                            Future addGroupId() async {
                                              final User user =
                                                  auth.currentUser;
                                              final userId = user.phoneNumber;

                                              if (userId.isNotEmpty) {
                                                // ignore: unused_local_variable
                                                final documentReference =
                                                    FirebaseFirestore.instance
                                                        .collection('Groups')
                                                        .doc(groupIdd)
                                                        .update({
                                                  "groupID": groupIdd
                                                });
                                              }
                                            }

                                            DocumentSnapshot documentSnapshot =
                                                snapshot.data.docs[index];
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 5.0, left: 6.0),
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    groupColor =
                                                        documentSnapshot.id;
                                                    documentSnapG =
                                                        documentSnapshot;
                                                    select = true;
                                                    selectedGroup = index;
                                                    PhonelogsScreenState
                                                            .groupSearch =
                                                        selectedGroup
                                                            .toString();
                                                    groupSearchUpdate();
                                                    groupIdd =
                                                        documentSnapshot.id;
                                                    addGroupId()
                                                        .whenComplete(() {
                                                      groupColorUpd();
                                                      groupColorUpdSingle();
                                                    });
                                                  });
                                                },
                                                child: Material(
                                                  elevation: 3.0,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15.0),
                                                        color: documentSnapshot[
                                                                    'groupColor' +
                                                                        uid] ==
                                                                '1'
                                                            ? ConstColors.search
                                                            : ConstColors
                                                                .searchTypesColor),
                                                    child: Center(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 15.0,
                                                                right: 15.0),
                                                        child: Text(
                                                          documentSnapshot[
                                                              'groupName'],
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize:
                                                                sizeX.height /
                                                                    55,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
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
                        )),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
