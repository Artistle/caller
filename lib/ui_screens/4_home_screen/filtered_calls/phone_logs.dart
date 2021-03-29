import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/ui_screens/4_home_screen/search/sort_types.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/animations/fade_animation.dart';
import 'package:flutter_app/constants/constants.dart';
import 'package:flutter_app/custom_widgets/Custom_Flushbar.dart';
import 'package:flutter_app/database/database_service.dart';
import 'package:call_log/call_log.dart';
import 'package:flutter_app/localization/localization.dart';
import 'package:flutter_app/ui_screens/9_speech_to_text/Speech_To_Text_Widget.dart';
import '../../screens.dart';
import '../home_screen.dart';
import 'call_logs.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhonelogsScreen extends StatefulWidget {
  @override
  PhonelogsScreenState createState() => PhonelogsScreenState();
}

class PhonelogsScreenState extends State<PhonelogsScreen>
    with WidgetsBindingObserver {
  Iterable<CallLogEntry> entries;

  static Future<Iterable<CallLogEntry>> logs = CallLogs.getCallLogs();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    super.initState();
    unsavedContacnts = HomeScreenState.unsaved;
    setState(() {
      groupSearch = 'all';
      dateState = 'all';
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  static Future<bool> checkExist() async {
    bool exists = false;
    try {
      await FirebaseFirestore.instance
          .collection('CallLogs')
          .doc(DatabaseService.startCallTime.toString())
          .get()
          .then((doc) {
        if (doc.exists) {
          exists = true;
        } else {
          exists = false;
          Timer(Duration(milliseconds: 500), () {
            DatabaseService().createNewCallLog();
          });
        }
      });
      return exists;
    } catch (e) {
      return false;
    }
  }

  DateTime time;
  String searchTime;
  var endCallTime = DateFormat('yyyy-MM-dd 00:00:00.000');

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;
    final String uid = user.phoneNumber;

    setState(() {
      // ignore: unused_local_variable
      var regDate = FirebaseFirestore.instance
          .collection('userData')
          .doc(uid)
          .get()
          .then((docSnap) {
        super.didChangeAppLifecycleState(state);
        if (AppLifecycleState.resumed == state) {
          logs = CallLogs.getCallLogs();
          Timer(Duration(milliseconds: 500), () {
            // ignore: unused_local_variable
            var document = FirebaseFirestore.instance
                .collection("CallLogs")
                .where('logOwner', isEqualTo: uid)
                .get()
                .then((docSnapshot) {
              docSnapshot.docs.forEach((DocumentSnapshot doc) {
                time = doc.data()['endCallTime'].toDate();

                searchTime = time.toString();
                print(searchTime);
                print(endCallTime.format(now));
              });
            });

            DateTime.fromMillisecondsSinceEpoch(entries.elementAt(0).timestamp)
                    .isAfter(docSnap['registerDate'].toDate())
                ? logs = CallLogs.getCallLogs()
                : setState(() {});

            DateTime.fromMillisecondsSinceEpoch(entries.elementAt(0).timestamp)
                    .isAfter(docSnap['registerDate'].toDate())
                ? checkExist()
                : setState(() {});
          });
        } else if (AppLifecycleState.paused == state) {
          setState(() {
            DateTime.fromMillisecondsSinceEpoch(entries.elementAt(0).timestamp)
                    .isAfter(docSnap['registerDate'].toDate())
                ? logs = CallLogs.getCallLogs()
                : setState(() {});
          });

          setState(() {
            DateTime.fromMillisecondsSinceEpoch(entries.elementAt(0).timestamp)
                    .isAfter(docSnap['registerDate'].toDate())
                ? logs = CallLogs.getCallLogs()
                : setState(() {});
          });
        } else if (AppLifecycleState.detached == state) {
          DateTime.fromMillisecondsSinceEpoch(entries.elementAt(0).timestamp)
                  .isAfter(docSnap['registerDate'].toDate())
              ? setState(() {})
              // ignore: unnecessary_statements
              : () {};
        }
      });
    });
  }

  String logPath = '';
  String logNotes = '';
  Future updateLogNotes() async {
    DocumentReference logRef =
        FirebaseFirestore.instance.collection('CallLogs').doc(logPath);
    logRef.update({'logNotes': logNotes});
  }

  int selectedIndex = 0;
  bool contactCardState = false;
  // double _width = 200;
  DateTime now = DateTime.now();
  bool unsavedContacnts = false;
  static String groupSearch = 'all';

  static String callType = '';
  static String callAll = 'all';
  static String dateState = '';
  static String searchDateParam = 'searchAll';
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;
    final String uid = user.phoneNumber;
    final dateEngStartTime = new DateFormat().add_Hm();

    final String month = 'MMM';
    final dateEngDate = new DateFormat('dd ${month.toUpperCase()} yyyy');
    var sizeX = MediaQuery.of(context).size;

    return Scaffold(
      body: FutureBuilder(
          future: logs,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              entries = snapshot.data;

              DatabaseService.contactName =
                  CallLogs.getTitle(entries.elementAt(0));
              DatabaseService.contactPhoneNumber =
                  CallLogs.getNumber(entries.elementAt(0));
              if (DatabaseService.startCallTime !=
                  DateTime.fromMillisecondsSinceEpoch(
                      entries.elementAt(0).timestamp)) {
                DatabaseService.startCallTime =
                    DateTime.fromMillisecondsSinceEpoch(
                        entries.elementAt(0).timestamp);
              }
              DatabaseService.callType =
                  CallLogs.getCallType(entries.elementAt(0).callType)
                      .toString();

              return Container(
                height: sizeX.height / 1.57,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: Colors.transparent),
                child: StreamBuilder(
                  stream: callAll == 'all' &&
                          (HomeScreenState.searchString.trim() == '')
                      ? FirebaseFirestore.instance
                          .collection("CallLogs")
                          .where(searchDateParam, isEqualTo: dateState)
                          .orderBy('startCallTime', descending: true)
                          .where('groupSearch', isEqualTo: groupSearch)
                          .where('logOwner', isEqualTo: uid)
                          .snapshots()
                      : callAll != 'all' &&
                              (HomeScreenState.searchString == null ||
                                  HomeScreenState.searchString.trim() == '')
                          ? FirebaseFirestore.instance
                              .collection("CallLogs")
                              .where(searchDateParam, isEqualTo: dateState)
                              .orderBy('startCallTime', descending: true)
                              .where('logOwner', isEqualTo: uid)
                              .where('groupSearch', isEqualTo: groupSearch)
                              .where('callType', isEqualTo: callType)
                              .snapshots()
                          : callAll == 'all'
                              ? FirebaseFirestore.instance
                                  .collection("CallLogs")
                                  .where(searchDateParam, isEqualTo: dateState)
                                  .orderBy('startCallTime', descending: true)
                                  .where('logOwner', isEqualTo: uid)
                                  .where('groupSearch', isEqualTo: groupSearch)
                                  .where('contactName',
                                      isEqualTo: HomeScreenState.searchString)
                                  .snapshots()
                              : FirebaseFirestore.instance
                                  .collection("CallLogs")
                                  .where(searchDateParam, isEqualTo: dateState)
                                  .orderBy('startCallTime', descending: true)
                                  .where('logOwner', isEqualTo: uid)
                                  .where('groupSearch', isEqualTo: groupSearch)
                                  .where('callType', isEqualTo: callType)
                                  .where('contactName',
                                      isEqualTo: HomeScreenState.searchString)
                                  .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: (snapshot.data.docs.length >= 2 &&
                                groupSearch == 'all' &&
                                HomeScreenState.searchString == '' &&
                                (callAll == 'all' || callAll == 'Outgoing'))
                            ? snapshot.data.docs.length
                            : (snapshot.data.docs.length < 2 &&
                                    groupSearch != 'all')
                                ? snapshot.data.docs.length
                                : snapshot.data.docs.length == 1
                                    ? snapshot.data.docs.length
                                    : (snapshot.data.docs.length == 1 &&
                                            groupSearch == 'all' &&
                                            (HomeScreenState.searchString ==
                                                    '' ||
                                                HomeScreenState.searchString !=
                                                    '') &&
                                            (callAll == 'all' ||
                                                callAll == 'Outgoing' ||
                                                callAll == 'Incoming'))
                                        ? snapshot.data.docs.length
                                        : snapshot.data.docs.length <= 2 &&
                                                HomeScreenState.searchString !=
                                                    ''
                                            ? snapshot.data.docs.length
                                            : HomeScreenState.searchString !=
                                                        '' &&
                                                    snapshot.data.docs.length <
                                                        2
                                                ? snapshot.data.docs.length
                                                : snapshot.data.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot documentSnapshot =
                              snapshot.data.docs[index];
                          Timestamp timestamp =
                              documentSnapshot['startCallTime'];

                          String logImage = documentSnapshot['logImage'];

                          return Padding(
                              padding: const EdgeInsets.all(2.0),
                              child:
                                  SortTypesState.unsaved == true &&
                                          documentSnapshot['contactName'] ==
                                              documentSnapshot[
                                                  'contactPhoneNumber'] &&
                                          SortTypesState.allCont == false &&
                                          SortTypesState.saved == false
                                      ? Material(
                                          elevation: 2.0,
                                          child: AnimatedContainer(
                                            curve: Curves.fastOutSlowIn,
                                            height: 95,

                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                    color:
                                                        ConstColors.lightBlue,
                                                    spreadRadius: 4,
                                                    blurRadius: 7)
                                              ],
                                              color: Colors.white,
                                            ),
                                            duration: Duration(
                                              milliseconds: 300,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 5.0,
                                                  bottom: 5.0,
                                                  left: 5.0,
                                                  right: 5.0),
                                              // ignore: deprecated_member_use
                                              child: FlatButton(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15)),
                                                onPressed: () {
                                                  setState(() {
                                                    logPath =
                                                        documentSnapshot.id;
                                                  });

                                                  showDialog(
                                                      barrierDismissible: true,
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          contentPadding:
                                                              EdgeInsets.all(
                                                                  0.0),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12.0),
                                                          ),
                                                          content:
                                                              StatefulBuilder(
                                                            builder: (BuildContext
                                                                    context,
                                                                StateSetter
                                                                    setState) {
                                                              return Container(
                                                                height: sizeX
                                                                        .height /
                                                                    1.3,
                                                                width: sizeX
                                                                        .width /
                                                                    1.1,
                                                                child: Stack(
                                                                  children: [
                                                                    ListView(
                                                                      physics:
                                                                          BouncingScrollPhysics(),
                                                                      children: <
                                                                          Widget>[
                                                                        Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: <
                                                                              Widget>[
                                                                            Padding(
                                                                              padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                                                                              child: Row(
                                                                                children: <Widget>[
                                                                                  CircleAvatar(
                                                                                    radius: 25.0,
                                                                                    backgroundColor: ConstColors.mainColor,
                                                                                  ),
                                                                                  Padding(
                                                                                    padding: EdgeInsets.only(
                                                                                      left: 15.0,
                                                                                    ),
                                                                                    child: Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      children: <Widget>[
                                                                                        Text(
                                                                                          ((documentSnapshot['contactName'] == documentSnapshot['contactPhoneNumber']) && (HomeScreenState.docSnap['appLang'] == 'עברית')) ? documentSnapshot['contactPhoneNumber'].toString().replaceAll(RegExp(r'[+]'), '') + '+' : documentSnapshot['contactName'],
                                                                                          style: TextStyle(
                                                                                            fontSize: sizeX.height / 60,
                                                                                            fontWeight: FontWeight.w700,
                                                                                          ),
                                                                                        ),
                                                                                        Padding(
                                                                                          padding: EdgeInsets.only(top: 5.0),
                                                                                          child: Text(
                                                                                            HomeScreenState.docSnap['appLang'] == 'עברית' ? documentSnapshot['contactPhoneNumber'].toString().replaceAll(RegExp(r'[+]'), '') + '+' : documentSnapshot['contactPhoneNumber'],
                                                                                            style: TextStyle(
                                                                                              fontSize: sizeX.height / 75,
                                                                                              fontWeight: FontWeight.w700,
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Row(
                                                                                          children: [
                                                                                            Padding(
                                                                                              padding: EdgeInsets.only(top: 5.0),
                                                                                              child: Text(
                                                                                                dateEngStartTime.format(DateTime.tryParse(timestamp.toDate().toString())).toString(),
                                                                                                style: TextStyle(
                                                                                                  fontSize: sizeX.height / 75,
                                                                                                  fontWeight: FontWeight.w400,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            Padding(
                                                                                              padding: EdgeInsets.only(left: 15.0, top: 5.0),
                                                                                              child: Text(
                                                                                                dateEngDate.format(DateTime.tryParse(timestamp.toDate().toString())).toString(),
                                                                                                style: TextStyle(
                                                                                                  fontSize: sizeX.height / 75,
                                                                                                  fontWeight: FontWeight.w400,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            FadeAnimation(
                                                                              0.5,
                                                                              Padding(
                                                                                padding: EdgeInsets.only(top: 10.0),
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: <Widget>[
                                                                                    Container(
                                                                                      color: Colors.grey[100],
                                                                                      child: Padding(
                                                                                        padding: EdgeInsets.only(left: 10.0),
                                                                                        child: Column(
                                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                                          children: [
                                                                                            Padding(
                                                                                              padding: EdgeInsets.only(
                                                                                                top: 0.0,
                                                                                                bottom: 5.0,
                                                                                                left: 5.0,
                                                                                              ),
                                                                                              child: Text(
                                                                                                AppLocalization.of(context).getTranslatedValue("my_notes"),
                                                                                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                                                                                              ),
                                                                                            ),
                                                                                            TextFormField(
                                                                                              onChanged: (notes) {
                                                                                                logNotes = notes;
                                                                                                updateLogNotes();
                                                                                              },
                                                                                              initialValue: documentSnapshot['logNotes'],
                                                                                              decoration: InputDecoration(
                                                                                                contentPadding: EdgeInsets.all(0.0),
                                                                                                hintText: AppLocalization.of(context).getTranslatedValue("notes_text"),
                                                                                                hintStyle: TextStyle(color: Colors.grey[400], fontSize: sizeX.height / 65),
                                                                                                focusedBorder: new OutlineInputBorder(
                                                                                                  borderSide: BorderSide.none,
                                                                                                ),
                                                                                                enabledBorder: new OutlineInputBorder(
                                                                                                  borderSide: BorderSide.none,
                                                                                                ),
                                                                                                errorBorder: const UnderlineInputBorder(
                                                                                                  borderSide: BorderSide.none,
                                                                                                ),
                                                                                                border: const UnderlineInputBorder(
                                                                                                  borderSide: BorderSide.none,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            Container(
                                                                                              child: Row(
                                                                                                children: <Widget>[
                                                                                                  Expanded(
                                                                                                    child: Container(
                                                                                                      decoration: BoxDecoration(
                                                                                                        color: Colors.grey[300],
                                                                                                        borderRadius: BorderRadius.circular(20.0),
                                                                                                      ),
                                                                                                      child: Row(
                                                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                        children: <Widget>[
                                                                                                          Container(
                                                                                                            height: 35.0,
                                                                                                            width: 35.0,
                                                                                                            decoration: BoxDecoration(border: Border.all(width: 3, color: Colors.black), shape: BoxShape.circle),
                                                                                                            child: CircleAvatar(
                                                                                                              backgroundColor: Colors.grey[200],
                                                                                                              child: Icon(
                                                                                                                Icons.stop,
                                                                                                                color: Colors.black,
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                          Padding(
                                                                                                            padding: EdgeInsets.only(
                                                                                                              right: 15.0,
                                                                                                            ),
                                                                                                            child: Text(
                                                                                                              '10:04',
                                                                                                              style: TextStyle(
                                                                                                                color: Colors.black,
                                                                                                                fontSize: 10.0,
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                            SpeechToTextWidget(logPath: timestamp.toDate().toString(), speechText: documentSnapshot['speechText']),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: EdgeInsets.only(
                                                                                        top: 20.0,
                                                                                        bottom: 15.0,
                                                                                        left: 15.0,
                                                                                      ),
                                                                                      child: Column(
                                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: <Widget>[
                                                                                          Row(
                                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                            children: [
                                                                                              Text(
                                                                                                AppLocalization.of(context).getTranslatedValue("groups_sort_title"),
                                                                                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                                                                                              ),
                                                                                              Padding(
                                                                                                padding: EdgeInsets.only(right: 15.0),
                                                                                                child: GestureDetector(
                                                                                                  onTap: () {},
                                                                                                  child: Container(
                                                                                                    height: 20,
                                                                                                    width: 20,
                                                                                                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black),
                                                                                                    child: Center(
                                                                                                      child: Icon(
                                                                                                        Icons.add,
                                                                                                        color: Colors.white,
                                                                                                        size: 14,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              )
                                                                                            ],
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
                                                                                                              if (documentSnapshot['groupId'].contains(docSnap.id)) {
                                                                                                                showCustomFlushbar(context, 'Call log is already exists in ${docSnap['groupName']}!');
                                                                                                              } else {
                                                                                                                addGroupIdToLog();
                                                                                                                showCustomFlushbar(context, 'Call log added in ${docSnap['groupName']}!');
                                                                                                              }
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
                                                                                                                ),
                                                                                                              )),
                                                                                                            ),
                                                                                                          ),
                                                                                                        );
                                                                                                      }),
                                                                                                );
                                                                                              } else if (snapshot.hasError || !snapshot.hasData) {
                                                                                                return Container();
                                                                                              }
                                                                                              return Center(
                                                                                                child: Container(),
                                                                                              );
                                                                                            },
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Positioned(
                                                                        left:
                                                                            0.0,
                                                                        right:
                                                                            0.0,
                                                                        bottom:
                                                                            20.0,
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Material(
                                                                            elevation:
                                                                                3.0,
                                                                            borderRadius:
                                                                                BorderRadius.circular(
                                                                              25.0,
                                                                            ),
                                                                            child:
                                                                                Container(
                                                                              height: 45.0,
                                                                              width: 200.0,
                                                                              decoration: BoxDecoration(
                                                                                borderRadius: BorderRadius.circular(
                                                                                  25.0,
                                                                                ),
                                                                                color: ConstColors.mainColor,
                                                                              ),
                                                                              child:
                                                                                  // ignore: deprecated_member_use
                                                                                  FlatButton(
                                                                                shape: RoundedRectangleBorder(
                                                                                  borderRadius: BorderRadius.circular(
                                                                                    25.0,
                                                                                  ),
                                                                                ),
                                                                                onPressed: () {
                                                                                  Navigator.of(context).pop();
                                                                                },
                                                                                child: Text(
                                                                                  AppLocalization.of(context).getTranslatedValue("close"),
                                                                                  style: TextStyle(color: Colors.white),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ))
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        );
                                                      });
                                                },
                                                child: Stack(
                                                  children: [
                                                    Positioned(
                                                      left: 0.0,
                                                      top: 0.0,
                                                      right: 0.0,
                                                      bottom: 0.0,
                                                      child: Center(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            ClipOval(
                                                              child:
                                                                  CircleAvatar(
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                radius: 25.0,
                                                                child: Image.asset(
                                                                    logImage,
                                                                    fit: BoxFit
                                                                        .cover),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left:
                                                                          15.0),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: <
                                                                    Widget>[
                                                                  Text(
                                                                    ((documentSnapshot['contactName'] == documentSnapshot['contactPhoneNumber']) &&
                                                                            (HomeScreenState.docSnap['appLang'] ==
                                                                                'עברית'))
                                                                        ? documentSnapshot['contactPhoneNumber'].toString().replaceAll(RegExp(r'[+]'), '') +
                                                                            '+'
                                                                        : documentSnapshot[
                                                                            'contactName'],
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          sizeX.height /
                                                                              55,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                    ),
                                                                    softWrap:
                                                                        true,
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        top:
                                                                            5.0),
                                                                    child: Text(
                                                                      HomeScreenState.docSnap[
                                                                                  'appLang'] ==
                                                                              'עברית'
                                                                          ? documentSnapshot['contactPhoneNumber'].toString().replaceAll(RegExp(r'[+]'), '') +
                                                                              '+'
                                                                          : documentSnapshot[
                                                                              'contactPhoneNumber'],
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            sizeX.height /
                                                                                80,
                                                                        fontWeight:
                                                                            FontWeight.w700,
                                                                      ),
                                                                      softWrap:
                                                                          true,
                                                                    ),
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Padding(
                                                                        padding:
                                                                            EdgeInsets.only(top: 5.0),
                                                                        child:
                                                                            Text(
                                                                          dateEngStartTime
                                                                              .format(DateTime.tryParse(timestamp.toDate().toString()))
                                                                              .toString(),
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                sizeX.height / 75,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: EdgeInsets.only(
                                                                            left:
                                                                                15.0,
                                                                            top:
                                                                                5.0),
                                                                        child:
                                                                            Text(
                                                                          dateEngDate
                                                                              .format(DateTime.tryParse(timestamp.toDate().toString()))
                                                                              .toString(),
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                sizeX.height / 75,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                left: 30.0,
                                                              ),
                                                              child: Container(
                                                                height: 55,
                                                                width: 90,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: ConstColors
                                                                      .lightBlue,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              25.0),
                                                                ),
                                                                child: Padding(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              5.0),
                                                                  child: Row(
                                                                    children: [
                                                                      Container(
                                                                        height:
                                                                            30.0,
                                                                        width:
                                                                            30.0,
                                                                        decoration: BoxDecoration(
                                                                            border:
                                                                                Border.all(width: 3, color: Colors.black),
                                                                            shape: BoxShape.circle),
                                                                        child:
                                                                            CircleAvatar(
                                                                          backgroundColor:
                                                                              ConstColors.lightBlue,
                                                                          radius:
                                                                              20.0,
                                                                          child:
                                                                              Icon(
                                                                            Icons.play_arrow,
                                                                            color:
                                                                                Colors.black,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                          padding: const EdgeInsets.only(
                                                                              left:
                                                                                  5),
                                                                          child:
                                                                              Text(
                                                                            '10:04',
                                                                            style:
                                                                                TextStyle(fontSize: 12.0),
                                                                          )),
                                                                    ],
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
                                              ),
                                            ),
                                            // ),
                                          ),
                                        )
                                      : SortTypesState.unsaved == false &&
                                              documentSnapshot['contactName'] !=
                                                  documentSnapshot[
                                                      'contactPhoneNumber'] &&
                                              SortTypesState.allCont == false &&
                                              SortTypesState.saved == true
                                          ? Material(
                                              elevation: 2.0,
                                              child: AnimatedContainer(
                                                curve: Curves.fastOutSlowIn,
                                                height: 95,
                                                // width: _width,
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
                                                      const EdgeInsets.only(
                                                          top: 5.0,
                                                          bottom: 5.0,
                                                          left: 5.0,
                                                          right: 5.0),
                                                  // ignore: deprecated_member_use
                                                  child: FlatButton(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15)),
                                                    onPressed: () {
                                                      setState(() {
                                                        logPath =
                                                            documentSnapshot.id;
                                                      });
                                                      showDialog(
                                                          barrierDismissible:
                                                              true,
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .all(0.0),
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12.0),
                                                              ),
                                                              content:
                                                                  StatefulBuilder(
                                                                builder: (BuildContext
                                                                        context,
                                                                    StateSetter
                                                                        setState) {
                                                                  return Container(
                                                                    height:
                                                                        sizeX.height /
                                                                            1.3,
                                                                    width: sizeX
                                                                            .width /
                                                                        1.1,
                                                                    child:
                                                                        Stack(
                                                                      children: [
                                                                        ListView(
                                                                          physics:
                                                                              BouncingScrollPhysics(),
                                                                          children: <
                                                                              Widget>[
                                                                            Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: <Widget>[
                                                                                Padding(
                                                                                  padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                                                                                  child: Row(
                                                                                    children: <Widget>[
                                                                                      ClipOval(
                                                                                        child: CircleAvatar(
                                                                                          backgroundColor: Colors.white,
                                                                                          radius: 25.0,
                                                                                          child: Image.asset(logImage, fit: BoxFit.cover),
                                                                                        ),
                                                                                      ),
                                                                                      Padding(
                                                                                        padding: EdgeInsets.only(
                                                                                          left: 15.0,
                                                                                        ),
                                                                                        child: Column(
                                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                                          children: <Widget>[
                                                                                            Text(
                                                                                              ((documentSnapshot['contactName'] == documentSnapshot['contactPhoneNumber']) && (HomeScreenState.docSnap['appLang'] == 'עברית')) ? documentSnapshot['contactPhoneNumber'].toString().replaceAll(RegExp(r'[+]'), '') + '+' : documentSnapshot['contactName'],
                                                                                              style: TextStyle(
                                                                                                fontSize: sizeX.height / 60,
                                                                                                fontWeight: FontWeight.w700,
                                                                                              ),
                                                                                            ),
                                                                                            Padding(
                                                                                              padding: EdgeInsets.only(top: 5.0),
                                                                                              child: Text(
                                                                                                HomeScreenState.docSnap['appLang'] == 'עברית' ? documentSnapshot['contactPhoneNumber'].toString().replaceAll(RegExp(r'[+]'), '') + '+' : documentSnapshot['contactPhoneNumber'],
                                                                                                style: TextStyle(
                                                                                                  fontSize: sizeX.height / 75,
                                                                                                  fontWeight: FontWeight.w700,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            Row(
                                                                                              children: [
                                                                                                Padding(
                                                                                                  padding: EdgeInsets.only(top: 5.0),
                                                                                                  child: Text(
                                                                                                    dateEngStartTime.format(DateTime.tryParse(timestamp.toDate().toString())).toString(),
                                                                                                    style: TextStyle(
                                                                                                      fontSize: sizeX.height / 75,
                                                                                                      fontWeight: FontWeight.w400,
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                                Padding(
                                                                                                  padding: EdgeInsets.only(left: 15.0, top: 5.0),
                                                                                                  child: Text(
                                                                                                    dateEngDate.format(DateTime.tryParse(timestamp.toDate().toString())).toString(),
                                                                                                    style: TextStyle(
                                                                                                      fontSize: sizeX.height / 75,
                                                                                                      fontWeight: FontWeight.w400,
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                FadeAnimation(
                                                                                  0.5,
                                                                                  Padding(
                                                                                    padding: EdgeInsets.only(top: 10.0),
                                                                                    child: Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      children: <Widget>[
                                                                                        Container(
                                                                                          color: Colors.grey[100],
                                                                                          child: Padding(
                                                                                            padding: EdgeInsets.only(left: 10.0),
                                                                                            child: Column(
                                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                                              children: [
                                                                                                Padding(
                                                                                                  padding: EdgeInsets.only(
                                                                                                    top: 0.0,
                                                                                                    bottom: 5.0,
                                                                                                    left: 5.0,
                                                                                                  ),
                                                                                                  child: Text(
                                                                                                    AppLocalization.of(context).getTranslatedValue("my_notes"),
                                                                                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                                                                                                  ),
                                                                                                ),
                                                                                                TextFormField(
                                                                                                  onChanged: (notes) {
                                                                                                    logNotes = notes;
                                                                                                    updateLogNotes();
                                                                                                  },
                                                                                                  initialValue: documentSnapshot['logNotes'],
                                                                                                  decoration: InputDecoration(
                                                                                                    contentPadding: EdgeInsets.all(0.0),
                                                                                                    hintText: AppLocalization.of(context).getTranslatedValue("notes_text"),
                                                                                                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: sizeX.height / 65),
                                                                                                    focusedBorder: new OutlineInputBorder(
                                                                                                      borderSide: BorderSide.none,
                                                                                                    ),
                                                                                                    enabledBorder: new OutlineInputBorder(
                                                                                                      borderSide: BorderSide.none,
                                                                                                    ),
                                                                                                    errorBorder: const UnderlineInputBorder(
                                                                                                      borderSide: BorderSide.none,
                                                                                                    ),
                                                                                                    border: const UnderlineInputBorder(
                                                                                                      borderSide: BorderSide.none,
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                                Container(
                                                                                                  child: Row(
                                                                                                    children: <Widget>[
                                                                                                      Expanded(
                                                                                                        child: Container(
                                                                                                          decoration: BoxDecoration(
                                                                                                            color: Colors.grey[300],
                                                                                                            borderRadius: BorderRadius.circular(20.0),
                                                                                                          ),
                                                                                                          child: Row(
                                                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                            children: <Widget>[
                                                                                                              Container(
                                                                                                                height: 35.0,
                                                                                                                width: 35.0,
                                                                                                                decoration: BoxDecoration(border: Border.all(width: 3, color: Colors.black), shape: BoxShape.circle),
                                                                                                                child: CircleAvatar(
                                                                                                                  backgroundColor: Colors.grey[200],
                                                                                                                  child: Icon(
                                                                                                                    Icons.stop,
                                                                                                                    color: Colors.black,
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ),
                                                                                                              Padding(
                                                                                                                padding: EdgeInsets.only(
                                                                                                                  right: 15.0,
                                                                                                                ),
                                                                                                                child: Text(
                                                                                                                  '10:04',
                                                                                                                  style: TextStyle(
                                                                                                                    color: Colors.black,
                                                                                                                    fontSize: 10.0,
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ),
                                                                                                            ],
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),

                                                                                                      // ),
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                                SpeechToTextWidget(logPath: timestamp.toDate().toString(), speechText: documentSnapshot['speechText']),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Padding(
                                                                                          padding: EdgeInsets.only(
                                                                                            top: 20.0,
                                                                                            bottom: 15.0,
                                                                                            left: 15.0,
                                                                                          ),
                                                                                          child: Column(
                                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                            children: <Widget>[
                                                                                              Row(
                                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                children: [
                                                                                                  Text(
                                                                                                    AppLocalization.of(context).getTranslatedValue("groups_title"),
                                                                                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                                                                                                  ),
                                                                                                  Padding(
                                                                                                    padding: EdgeInsets.only(right: 15.0),
                                                                                                    child: GestureDetector(
                                                                                                      onTap: () {},
                                                                                                      child: Container(
                                                                                                        height: 20,
                                                                                                        width: 20,
                                                                                                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black),
                                                                                                        child: Center(
                                                                                                          child: Icon(
                                                                                                            Icons.add,
                                                                                                            color: Colors.white,
                                                                                                            size: 14,
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  )
                                                                                                ],
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
                                                                                                                  if (documentSnapshot['groupId'].contains(docSnap.id)) {
                                                                                                                    showCustomFlushbar(context, 'Call log is already exists in ${docSnap['groupName']}!');
                                                                                                                  } else {
                                                                                                                    addGroupIdToLog();
                                                                                                                    showCustomFlushbar(context, 'Call log added in ${docSnap['groupName']}!');
                                                                                                                  }
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
                                                                                                                    ),
                                                                                                                  )),
                                                                                                                ),
                                                                                                              ),
                                                                                                            );
                                                                                                          }),
                                                                                                    );
                                                                                                  } else if (snapshot.hasError || !snapshot.hasData) {
                                                                                                    return Container();
                                                                                                  }
                                                                                                  return Center(
                                                                                                    child: Container(),
                                                                                                  );
                                                                                                },
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        )
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Positioned(
                                                                            left:
                                                                                0.0,
                                                                            right:
                                                                                0.0,
                                                                            bottom:
                                                                                20.0,
                                                                            child:
                                                                                Center(
                                                                              child: Material(
                                                                                elevation: 3.0,
                                                                                borderRadius: BorderRadius.circular(
                                                                                  25.0,
                                                                                ),
                                                                                child: Container(
                                                                                  height: 45.0,
                                                                                  width: 200.0,
                                                                                  decoration: BoxDecoration(
                                                                                    borderRadius: BorderRadius.circular(
                                                                                      25.0,
                                                                                    ),
                                                                                    color: ConstColors.mainColor,
                                                                                  ),
                                                                                  child:
                                                                                      // ignore: deprecated_member_use
                                                                                      FlatButton(
                                                                                    shape: RoundedRectangleBorder(
                                                                                      borderRadius: BorderRadius.circular(
                                                                                        25.0,
                                                                                      ),
                                                                                    ),
                                                                                    onPressed: () {
                                                                                      Navigator.of(context).pop();
                                                                                    },
                                                                                    child: Text(
                                                                                      AppLocalization.of(context).getTranslatedValue("close"),
                                                                                      style: TextStyle(color: Colors.white),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ))
                                                                      ],
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            );
                                                          });
                                                    },
                                                    child: Stack(
                                                      children: [
                                                        Positioned(
                                                          left: 0.0,
                                                          top: 0.0,
                                                          right: 0.0,
                                                          bottom: 0.0,
                                                          child: Center(
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: <
                                                                  Widget>[
                                                                ClipOval(
                                                                  child:
                                                                      CircleAvatar(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .white,
                                                                    radius:
                                                                        25.0,
                                                                    child: Image.asset(
                                                                        logImage,
                                                                        fit: BoxFit
                                                                            .cover),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      left:
                                                                          15.0),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: <
                                                                        Widget>[
                                                                      Text(
                                                                        ((documentSnapshot['contactName'] == documentSnapshot['contactPhoneNumber']) && (HomeScreenState.docSnap['appLang'] == 'עברית'))
                                                                            ? documentSnapshot['contactPhoneNumber'].toString().replaceAll(RegExp(r'[+]'), '') +
                                                                                '+'
                                                                            : documentSnapshot['contactName'],
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.black,
                                                                          fontSize:
                                                                              sizeX.height / 55,
                                                                          fontWeight:
                                                                              FontWeight.w700,
                                                                        ),
                                                                        softWrap:
                                                                            true,
                                                                      ),
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.only(top: 5.0),
                                                                        child:
                                                                            Text(
                                                                          HomeScreenState.docSnap['appLang'] == 'עברית'
                                                                              ? documentSnapshot['contactPhoneNumber'].toString().replaceAll(RegExp(r'[+]'), '') + '+'
                                                                              : documentSnapshot['contactPhoneNumber'],
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                            fontSize:
                                                                                sizeX.height / 80,
                                                                            fontWeight:
                                                                                FontWeight.w700,
                                                                          ),
                                                                          softWrap:
                                                                              true,
                                                                        ),
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Padding(
                                                                            padding:
                                                                                EdgeInsets.only(top: 5.0),
                                                                            child:
                                                                                Text(
                                                                              dateEngStartTime.format(DateTime.tryParse(timestamp.toDate().toString())).toString(),
                                                                              style: TextStyle(
                                                                                fontSize: sizeX.height / 75,
                                                                                fontWeight: FontWeight.w400,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                EdgeInsets.only(left: 15.0, top: 5.0),
                                                                            child:
                                                                                Text(
                                                                              dateEngDate.format(DateTime.tryParse(timestamp.toDate().toString())).toString(),
                                                                              style: TextStyle(
                                                                                fontSize: sizeX.height / 75,
                                                                                fontWeight: FontWeight.w400,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                    left: 30.0,
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    height: 55,
                                                                    width: 90,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: ConstColors
                                                                          .lightBlue,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              25.0),
                                                                    ),
                                                                    child:
                                                                        Padding(
                                                                      padding: EdgeInsets.only(
                                                                          left:
                                                                              5.0),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Container(
                                                                            height:
                                                                                30.0,
                                                                            width:
                                                                                30.0,
                                                                            decoration:
                                                                                BoxDecoration(border: Border.all(width: 3, color: Colors.black), shape: BoxShape.circle),
                                                                            child:
                                                                                CircleAvatar(
                                                                              backgroundColor: ConstColors.lightBlue,
                                                                              radius: 20.0,
                                                                              child: Icon(
                                                                                Icons.play_arrow,
                                                                                color: Colors.black,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                              padding: const EdgeInsets.only(left: 5),
                                                                              child: Text(
                                                                                '10:04',
                                                                                style: TextStyle(fontSize: 12.0),
                                                                              )),
                                                                        ],
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
                                                  ),
                                                ),
                                                // ),
                                              ),
                                            )
                                          : SortTypesState.allCont == true
                                              ? Material(
                                                  elevation: 2.0,
                                                  child: AnimatedContainer(
                                                    curve: Curves.fastOutSlowIn,
                                                    height: 95,
                                                    // width: _width,
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
                                                          const EdgeInsets.only(
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
                                                          setState(() {
                                                            logPath =
                                                                documentSnapshot
                                                                    .id;
                                                          });
                                                          showDialog(
                                                              barrierDismissible:
                                                                  true,
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return AlertDialog(
                                                                  contentPadding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              0.0),
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12.0),
                                                                  ),
                                                                  content:
                                                                      StatefulBuilder(
                                                                    builder: (BuildContext
                                                                            context,
                                                                        StateSetter
                                                                            setState) {
                                                                      return Container(
                                                                        height: sizeX.height /
                                                                            1.3,
                                                                        width: sizeX.width /
                                                                            1.1,
                                                                        child:
                                                                            Stack(
                                                                          children: [
                                                                            ListView(
                                                                              physics: BouncingScrollPhysics(),
                                                                              children: <Widget>[
                                                                                Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: <Widget>[
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                                                                                      child: Row(
                                                                                        children: <Widget>[
                                                                                          ClipOval(
                                                                                            child: CircleAvatar(
                                                                                              backgroundColor: Colors.white,
                                                                                              radius: 25.0,
                                                                                              child: Image.asset(logImage, fit: BoxFit.cover),
                                                                                            ),
                                                                                          ),
                                                                                          Padding(
                                                                                            padding: EdgeInsets.only(
                                                                                              left: 15.0,
                                                                                            ),
                                                                                            child: Column(
                                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                                              children: <Widget>[
                                                                                                Text(
                                                                                                  ((documentSnapshot['contactName'] == documentSnapshot['contactPhoneNumber']) && (HomeScreenState.docSnap['appLang'] == 'עברית')) ? documentSnapshot['contactPhoneNumber'].toString().replaceAll(RegExp(r'[+]'), '') + '+' : documentSnapshot['contactName'],
                                                                                                  style: TextStyle(
                                                                                                    fontSize: sizeX.height / 60,
                                                                                                    fontWeight: FontWeight.w700,
                                                                                                  ),
                                                                                                ),
                                                                                                Padding(
                                                                                                  padding: EdgeInsets.only(top: 5.0),
                                                                                                  child: Text(
                                                                                                    HomeScreenState.docSnap['appLang'] == 'עברית' ? documentSnapshot['contactPhoneNumber'].toString().replaceAll(RegExp(r'[+]'), '') + '+' : documentSnapshot['contactPhoneNumber'],
                                                                                                    style: TextStyle(
                                                                                                      fontSize: sizeX.height / 75,
                                                                                                      fontWeight: FontWeight.w700,
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                                Row(
                                                                                                  children: [
                                                                                                    Padding(
                                                                                                      padding: EdgeInsets.only(top: 5.0),
                                                                                                      child: Text(
                                                                                                        dateEngStartTime.format(DateTime.tryParse(timestamp.toDate().toString())).toString(),
                                                                                                        style: TextStyle(
                                                                                                          fontSize: sizeX.height / 75,
                                                                                                          fontWeight: FontWeight.w400,
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                    Padding(
                                                                                                      padding: EdgeInsets.only(left: 15.0, top: 5.0),
                                                                                                      child: Text(
                                                                                                        dateEngDate.format(DateTime.tryParse(timestamp.toDate().toString())).toString(),
                                                                                                        style: TextStyle(
                                                                                                          fontSize: sizeX.height / 75,
                                                                                                          fontWeight: FontWeight.w400,
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                    FadeAnimation(
                                                                                      0.5,
                                                                                      Padding(
                                                                                        padding: EdgeInsets.only(top: 10.0),
                                                                                        child: Column(
                                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                                          children: <Widget>[
                                                                                            Container(
                                                                                              color: Colors.grey[100],
                                                                                              child: Padding(
                                                                                                padding: EdgeInsets.only(left: 10.0),
                                                                                                child: Column(
                                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                  children: [
                                                                                                    Padding(
                                                                                                      padding: EdgeInsets.only(
                                                                                                        top: 0.0,
                                                                                                        bottom: 5.0,
                                                                                                        left: 5.0,
                                                                                                      ),
                                                                                                      child: Text(
                                                                                                        AppLocalization.of(context).getTranslatedValue("my_notes"),
                                                                                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                                                                                                      ),
                                                                                                    ),
                                                                                                    Container(
                                                                                                      child: TextFormField(
                                                                                                        onChanged: (notes) {
                                                                                                          logNotes = notes;
                                                                                                          updateLogNotes();
                                                                                                        },
                                                                                                        initialValue: documentSnapshot['logNotes'],
                                                                                                        scrollPhysics: BouncingScrollPhysics(),
                                                                                                        decoration: InputDecoration(
                                                                                                          contentPadding: EdgeInsets.all(0.0),
                                                                                                          hintText: AppLocalization.of(context).getTranslatedValue("notes_text"),
                                                                                                          hintStyle: TextStyle(color: Colors.grey[400], fontSize: sizeX.height / 65),
                                                                                                          focusedBorder: new OutlineInputBorder(
                                                                                                            borderSide: BorderSide.none,
                                                                                                          ),
                                                                                                          enabledBorder: new OutlineInputBorder(
                                                                                                            borderSide: BorderSide.none,
                                                                                                          ),
                                                                                                          errorBorder: const UnderlineInputBorder(
                                                                                                            borderSide: BorderSide.none,
                                                                                                          ),
                                                                                                          border: const UnderlineInputBorder(
                                                                                                            borderSide: BorderSide.none,
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                    Container(
                                                                                                      child: Row(
                                                                                                        children: <Widget>[
                                                                                                          Expanded(
                                                                                                            child: Container(
                                                                                                              decoration: BoxDecoration(
                                                                                                                color: Colors.grey[300],
                                                                                                                borderRadius: BorderRadius.circular(20.0),
                                                                                                              ),
                                                                                                              child: Row(
                                                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                                children: <Widget>[
                                                                                                                  Container(
                                                                                                                    height: 35.0,
                                                                                                                    width: 35.0,
                                                                                                                    decoration: BoxDecoration(border: Border.all(width: 3, color: Colors.black), shape: BoxShape.circle),
                                                                                                                    child: CircleAvatar(
                                                                                                                      backgroundColor: Colors.grey[200],
                                                                                                                      child: Icon(
                                                                                                                        Icons.stop,
                                                                                                                        color: Colors.black,
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                  Padding(
                                                                                                                    padding: EdgeInsets.only(
                                                                                                                      right: 15.0,
                                                                                                                    ),
                                                                                                                    child: Text(
                                                                                                                      '10:04',
                                                                                                                      style: TextStyle(
                                                                                                                        color: Colors.black,
                                                                                                                        fontSize: 10.0,
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ],
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ),
                                                                                                    SpeechToTextWidget(logPath: timestamp.toDate().toString(), speechText: documentSnapshot['speechText']
                                                                                                        //  == '' ? 'Tap to speak' : documentSnapshot['speechText'],
                                                                                                        ),
                                                                                                  ],
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            Padding(
                                                                                              padding: EdgeInsets.only(
                                                                                                top: 20.0,
                                                                                                bottom: 15.0,
                                                                                                left: 15.0,
                                                                                              ),
                                                                                              child: Column(
                                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                children: <Widget>[
                                                                                                  Row(
                                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                    children: [
                                                                                                      Text(
                                                                                                        AppLocalization.of(context).getTranslatedValue("groups_sort_title"),
                                                                                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                                                                                                      ),
                                                                                                      Padding(
                                                                                                        padding: EdgeInsets.only(right: 15.0),
                                                                                                        child: GestureDetector(
                                                                                                          onTap: () {},
                                                                                                          child: Container(
                                                                                                            height: 20,
                                                                                                            width: 20,
                                                                                                            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black),
                                                                                                            child: Center(
                                                                                                              child: Icon(
                                                                                                                Icons.add,
                                                                                                                color: Colors.white,
                                                                                                                size: 14,
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                        ),
                                                                                                      )
                                                                                                    ],
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
                                                                                                                      if (documentSnapshot['groupId'].contains(docSnap.id)) {
                                                                                                                        showCustomFlushbar(context, 'Call log is already exists in ${docSnap['groupName']}!');
                                                                                                                      } else {
                                                                                                                        addGroupIdToLog();
                                                                                                                        showCustomFlushbar(context, 'Call log added in ${docSnap['groupName']}!');
                                                                                                                      }
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
                                                                                                                        ),
                                                                                                                      )),
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                );
                                                                                                              }),
                                                                                                        );
                                                                                                      } else if (snapshot.hasError || !snapshot.hasData) {
                                                                                                        return Container();
                                                                                                      }
                                                                                                      return Center(
                                                                                                        child: Container(),
                                                                                                      );
                                                                                                    },
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            )
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            Positioned(
                                                                                left: 0.0,
                                                                                right: 0.0,
                                                                                bottom: 20.0,
                                                                                child: Center(
                                                                                  child: Material(
                                                                                    elevation: 3.0,
                                                                                    borderRadius: BorderRadius.circular(
                                                                                      25.0,
                                                                                    ),
                                                                                    child: Container(
                                                                                      height: 45.0,
                                                                                      width: 200.0,
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
                                                                                        child: Text(
                                                                                          AppLocalization.of(context).getTranslatedValue("close"),
                                                                                          style: TextStyle(color: Colors.white),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ))
                                                                          ],
                                                                        ),
                                                                      );
                                                                    },
                                                                  ),
                                                                );
                                                              });
                                                        },
                                                        child: Stack(
                                                          children: [
                                                            Positioned(
                                                              left: 0.0,
                                                              top: 0.0,
                                                              right: 0.0,
                                                              bottom: 0.0,
                                                              child: Center(
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: <
                                                                      Widget>[
                                                                    ClipOval(
                                                                      child:
                                                                          CircleAvatar(
                                                                        backgroundColor:
                                                                            Colors.white,
                                                                        radius:
                                                                            25.0,
                                                                        child: Image.asset(
                                                                            logImage,
                                                                            fit:
                                                                                BoxFit.cover),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          left:
                                                                              15.0),
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: <
                                                                            Widget>[
                                                                          Text(
                                                                            ((documentSnapshot['contactName'] == documentSnapshot['contactPhoneNumber']) && (HomeScreenState.docSnap['appLang'] == 'עברית'))
                                                                                ? documentSnapshot['contactPhoneNumber'].toString().replaceAll(RegExp(r'[+]'), '') + '+'
                                                                                : documentSnapshot['contactName'],
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: sizeX.height / 55,
                                                                              fontWeight: FontWeight.w700,
                                                                            ),
                                                                            softWrap:
                                                                                true,
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(top: 5.0),
                                                                            child:
                                                                                Text(
                                                                              HomeScreenState.docSnap['appLang'] == 'עברית' ? documentSnapshot['contactPhoneNumber'].toString().replaceAll(RegExp(r'[+]'), '') + '+' : documentSnapshot['contactPhoneNumber'],
                                                                              style: TextStyle(
                                                                                color: Colors.black,
                                                                                fontSize: sizeX.height / 80,
                                                                                fontWeight: FontWeight.w700,
                                                                              ),
                                                                              softWrap: true,
                                                                            ),
                                                                          ),
                                                                          Row(
                                                                            children: [
                                                                              Padding(
                                                                                padding: EdgeInsets.only(top: 5.0),
                                                                                child: Text(
                                                                                  dateEngStartTime.format(DateTime.tryParse(timestamp.toDate().toString())).toString(),
                                                                                  style: TextStyle(
                                                                                    fontSize: sizeX.height / 75,
                                                                                    fontWeight: FontWeight.w400,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Padding(
                                                                                padding: EdgeInsets.only(left: 15.0, top: 5.0),
                                                                                child: Text(
                                                                                  dateEngDate.format(DateTime.tryParse(timestamp.toDate().toString())).toString(),
                                                                                  style: TextStyle(
                                                                                    fontSize: sizeX.height / 75,
                                                                                    fontWeight: FontWeight.w400,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding:
                                                                          const EdgeInsets
                                                                              .only(
                                                                        left:
                                                                            30.0,
                                                                      ),
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            55,
                                                                        width:
                                                                            90,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              ConstColors.lightBlue,
                                                                          borderRadius:
                                                                              BorderRadius.circular(25.0),
                                                                        ),
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              EdgeInsets.only(left: 5.0),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Container(
                                                                                height: 30.0,
                                                                                width: 30.0,
                                                                                decoration: BoxDecoration(border: Border.all(width: 3, color: Colors.black), shape: BoxShape.circle),
                                                                                child: CircleAvatar(
                                                                                  backgroundColor: ConstColors.lightBlue,
                                                                                  radius: 20.0,
                                                                                  child: Icon(
                                                                                    Icons.play_arrow,
                                                                                    color: Colors.black,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Padding(
                                                                                  padding: const EdgeInsets.only(left: 5),
                                                                                  child: Text(
                                                                                    '10:04',
                                                                                    style: TextStyle(fontSize: 12.0),
                                                                                  )),
                                                                            ],
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
                                                      ),
                                                    ),
                                                    // ),
                                                  ),
                                                )
                                              : Container());
                        },
                      );
                    } else if (snapshot.hasError || !snapshot.hasData) {
                      Center(
                        child: Container(),
                      );
                    }
                    return Center(child: FadeAnimation(0.5, Container()));
                  },
                ),
              );
            } else if (snapshot.connectionState == ConnectionState.none) {
              return Center(
                child: Container(),
              );
            }
            return Center(
              child: Container(),
            );
          }),
    );
  }
}
