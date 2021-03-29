// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:memoobeez/constants/constants.dart';
// import 'package:memoobeez/database/database_service.dart';
// import 'package:memoobeez/localization/localization.dart';
// import 'package:memoobeez/ui_screens/screens.dart';
// import 'package:pin_code_fields/pin_code_fields.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:sms_autofill/sms_autofill.dart';

// import '../../database/database_service.dart';
// import '../../ui_screens/screens.dart';
// import '../phone_number/phone_number.dart';

// class VerificationCodeLogin extends StatefulWidget {
//   @override
//   VerificationCodeLoginState createState() => VerificationCodeLoginState();
// }

// class VerificationCodeLoginState extends State<VerificationCodeLogin>
//     with TickerProviderStateMixin {
//   var onTapRecognizer;
//   var loginPageMethods = PhoneNumberState();

//   TextEditingController textEditingController = TextEditingController();

//   // ignore: close_sinks
//   StreamController<ErrorAnimationType> errorController;
//   bool buttonState;

//   bool hasError = false;
//   final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
//   final formKey = GlobalKey<FormState>();
//   AnimationController controller;
//   static String otp = '';
//   // static Future<bool> checkExist() async {
//   //   final FirebaseAuth auth = FirebaseAuth.instance;
//   //   final User user = auth.currentUser;
//   //   final userId = user.phoneNumber;
//   //   bool exists = false;

//   //   try {
//   //     await FirebaseFirestore.instance
//   //         .collection('userData')
//   //         .doc(userId)
//   //         .get()
//   //         .then((doc) {
//   //       if (doc.exists) {
//   //         exists = true;
//   //       } else {
//   //         exists = false;
//   //         Timer(Duration(seconds: 3), () {
//   //           DatabaseService().createUser();
//   //         });
//   //       }
//   //     });
//   //     return exists;
//   //   } catch (e) {
//   //     return false;
//   //   }
//   // }

//   bool otpState = false;
//   @override
//   void initState() {
//     super.initState();
//     _listenOtp();
//     buttonState = false;
//     // otp != '' ? otpState = true : otpState = false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     var sizeX = MediaQuery.of(context).size;
//     return Scaffold(
//       body: Stack(
//         children: <Widget>[
//           Positioned(
//             left: 0.0,
//             right: 0.0,
//             bottom: 200.0,
//             top: 0.0,
//             child: Center(
//               child: Padding(
//                 padding: EdgeInsets.only(
//                   top: MediaQuery.of(context).size.height / 30,
//                   bottom: MediaQuery.of(context).size.height / 15,
//                 ),
//                 child: Text(
//                   AppLocalization.of(context)
//                       .getTranslatedValue("sms_protection"),
//                   style: TextStyle(
//                     fontSize: sizeX.height / 40,
//                     color: Colors.black,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//             left: 0.0,
//             right: 0.0,
//             bottom: 50.0,
//             top: 0.0,
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Container(
//                     height: 115,
//                     child: Padding(
//                       padding:
//                           const EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
//                       child: PinFieldAutoFill(
//                           decoration: UnderlineDecoration(
//                             textStyle: TextStyle(
//                               fontSize: 20,
//                               color: ConstColors.mainColor,
//                             ),
//                             colorBuilder: FixedColorBuilder(
//                               ConstColors.mainColor,
//                             ),
//                           ),
//                           codeLength: 6,
//                           onCodeChanged: (value) {
//                             otp = value;

//                             if (PhoneNumberState.phoneNumber != null ||
//                                 PhoneNumberState.phoneNumber != '') {
//                               if (otp != null) {
//                                 PhoneNumberState.verifyPhone(
//                                         PhoneNumberState.phoneNumber, context)
//                                     .whenComplete(() {
//                                   // final FirebaseAuth auth =
//                                   //     FirebaseAuth.instance;
//                                   // final User user = auth.currentUser;
//                                   // final userId = user.phoneNumber;
//                                   // if (userId != null) {
//                                   // checkExist().whenComplete(() {

//                                   // Timer(Duration(seconds: 4), () {
//                                   //   Navigator.of(context).push(
//                                   //       MaterialPageRoute(
//                                   //           builder: (context) =>
//                                   //               HomeScreen()));
//                                   //   DatabaseService().logInState(
//                                   //       PhoneNumberState.phoneNumber);
//                                   // });
//                                   // });
//                                   // }
//                                 });
//                               }
//                             }
//                           }),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Positioned(
//             left: 0.0,
//             right: 0.0,
//             bottom: 0.0,
//             child: Padding(
//               padding: const EdgeInsets.only(bottom: 50.0),
//               child: Center(
//                 child: InkWell(
//                   onTap: () {
//                     if (PhoneNumberState.phoneNumber != null) {
//                       PhoneNumberState.verifyPhone(
//                           PhoneNumberState.phoneNumber, context);
//                     }
//                   },
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             AppLocalization.of(context)
//                                 .getTranslatedValue("havent_code"),
//                             style: TextStyle(
//                               fontSize: sizeX.height / 55,
//                               color: Colors.black,
//                               decoration: TextDecoration.underline,
//                             ),
//                           ),
//                           Text(
//                             AppLocalization.of(context)
//                                 .getTranslatedValue("send_again"),
//                             style: TextStyle(
//                               fontSize: sizeX.height / 55,
//                               color: ConstColors.registerTextColor,
//                               decoration: TextDecoration.underline,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _listenOtp() async {
//     await SmsAutoFill().listenForCode;
//   }
// }
