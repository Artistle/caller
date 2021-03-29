// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import '../screens.dart';

// class SplashScreen extends StatefulWidget {
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Timer(Duration(seconds: 3), () {
//       Navigator.of(context).push(
//         MaterialPageRoute(
//           builder: (context) => LoginStateCheck(),
//         ),
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     var sizeX = MediaQuery.of(context).size;
//     return
//         // ignore: missing_return

//         Scaffold(
//       body: Container(
//           color: Colors.white,
//           height: sizeX.height,
//           // child: Padding(
//           //     padding: const EdgeInsets.all(40.0),
//           child: Center(child: SvgPicture.asset('assets/images/Logo.svg'))),
//       // ),
//     );
//   }
// }
