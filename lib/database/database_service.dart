import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jiffy/jiffy.dart';

class DatabaseService {
//
//auth
  final FirebaseAuth auth = FirebaseAuth.instance;

//user parameters
  static String userImage = '';
  static String userName = '';
  static String userID = '';
  static String userEmail = '';
  static String companyName = '';
  static String userPhone = '';
  static bool allowButton;
  static bool authState;
  static bool contactsAccess;
  static bool microAccess;

//new call log
  static String contactPhoneNumber = '';
  static String contactName = '';
  static String callType = '';
  static bool addToGroup = false;
  static DateTime startCallTime;
  Random imageNum = Random();

//new group
  static String groupImage = '';
  static String groupName = '';
  static bool temporarySate = true;
  static bool privateState = true;
  static num daysCount = 1;
  static bool autoRecState = true;

//create new user
  Future createUser() async {
    final User user = auth.currentUser;
    final userId = user.phoneNumber;
    final List<String> groupReques = [];

    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('userData').doc(userId);
    Map<String, dynamic> userDATA = {
      'userID': userId,
      'userName': userName,
      'userPhone': userPhone,
      'userEmail': userEmail,
      'companyName': companyName,
      'userImage': userImage,
      'contactsAccess': true,
      'microAccess': true,
      'allowButton': false,
      'authState': true,
      'deleteFromGroup': false,
      "request": groupReques,
      'registerDate': DateTime.now(),
      'appLang': 'English',
    };
    documentReference.set(userDATA);
  }

//user log out state
  Future logOutState() async {
    final User user = auth.currentUser;
    final userId = user.phoneNumber;
    try {
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection('userData').doc(userId);
      documentReference.update({'authState': false});
    } catch (e) {}
  }

//user log in state
  Future logInState(String userPhone) async {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('userData').doc(userPhone);
    documentReference.update({'authState': true});
  }

//allow intro helper button state
  Future allowUpdate() async {
    final User user = auth.currentUser;
    final userId = user.phoneNumber;
    try {
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection('userData').doc(userId);
      documentReference.update({'allowButton': true});
    } catch (e) {}
  }

//update user image
  Future imageUpdate() async {
    final User user = auth.currentUser;
    final userId = user.phoneNumber;
    try {
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection('userData').doc(userId);
      documentReference.update({'userImage': userImage});
    } catch (e) {}
  }

//create new call log
  Future createNewCallLog() async {
    int min = 1;
    int imageRand = min + imageNum.nextInt(6);
    final User user = auth.currentUser;
    final userId = user.phoneNumber;
    final List<String> groupID = [];

    List<String> searchIndex = ['any'];
    DateTime now = DateTime.now();

    if (userId.isNotEmpty) {
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection('CallLogs')
          .doc(startCallTime.toString());

      Map<String, dynamic> callLog = {
        'contactName': contactName,
        'contactPhoneNumber': contactPhoneNumber,
        'logOwner': userId,
        'startCallTime': startCallTime,
        'searchTime': DateTime(now.year, now.month, now.day).toString(),
        'searchMonth': DateTime(now.year, now.month).toString(),
        'searchWeek': Jiffy().week.toString(),
        'groupId': groupID,
        'addToGroup': false,
        'searchList': contactName,
        'searchIndex': searchIndex,
        'callType': callType,
        'groupSearch': 'all',
        'searchAll': 'all',
        'logNotes': '',
        'speechText': '',
        'logImage': 'assets/call_logs_images/call_log_image$imageRand.png',
      };
      documentReference.set(callLog);
    }
  }

//create group
  Future createGroup() async {
    final User user = auth.currentUser;
    final uid = user.phoneNumber;
    final List<String> userId = [user.phoneNumber];

    if (userId.isNotEmpty) {
      final documentReference = FirebaseFirestore.instance;
      documentReference.collection('Groups').add({
        'groupImage': groupImage,
        'groupName': groupName,
        'privateState': true,
        'daysCount': daysCount,
        'autoRecState': true,
        'temporarySate': true,
        'members': userId,
        'leader': uid,
        'groupColor' + uid: '0',
        'groupCreateTime': DateTime.now()
      });
    }
  }

//group private state
  Future privateGruop() async {
    final User user = auth.currentUser;
    final userId = user.phoneNumber;
    try {
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection('Groups')
          .doc(userId)
          .collection('Groups')
          .doc(DatabaseService.groupName);
      documentReference.update({'privateState': false});
    } catch (e) {}
  }
}
