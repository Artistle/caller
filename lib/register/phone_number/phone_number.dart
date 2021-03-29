import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter_app/database/database_service.dart';
import 'package:flutter_app/ui_screens/3_register_screen/register_screen.dart';

class PhoneNumber extends StatefulWidget {
  @override
  PhoneNumberState createState() => PhoneNumberState();
}

// ignore: unused_element
class _ExampleMask {
  final TextEditingController textController = TextEditingController();
  final MaskTextInputFormatter formatter;
  final FormFieldValidator<String> validator;
  final String hint;
  _ExampleMask({@required this.formatter, this.validator, @required this.hint});
}

class PhoneNumberState extends State<PhoneNumber> {
  @override
  void initState() {
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();
  static String phoneNumber = '', verificationId;
  static String otp, authStatus = "";

  // static Future<bool> verifyPhone(String phone, BuildContext context) async {
  //   FirebaseAuth _auth = FirebaseAuth.instance;

  //   _auth.verifyPhoneNumber(
  //       phoneNumber: phone,
  //       timeout: Duration(seconds: 60),
  //       verificationCompleted: (AuthCredential credential) async {
  //         // Navigator.of(context).pop();

  //         UserCredential result = await _auth.signInWithCredential(credential);

  //         User user = result.user;

  //         if (user != null) {
  //           // Navigator.push(
  //           //     context, MaterialPageRoute(builder: (context) => HomeScreen()));
  //         } else {
  //           print("Error");
  //         }
  //       },
  //       verificationFailed: (Exception exception) {
  //         print(exception);
  //       },
  //       codeSent: (String verificationId, [int forceResendingToken]) {},
  //       codeAutoRetrievalTimeout: null);
  // }

  @override
  Widget build(BuildContext context) {
    var sizeX = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
              color: RegisterScreenState.stateValid == false
                  ? Colors.grey[400]
                  : Colors.redAccent)),
      height: sizeX.height / 16,
      width: 290,
      child: Form(
        key: _formKey,
        child: buildTextField(),
      ),
    );
  }

  Widget buildTextField() {
    return TextFormField(
      textInputAction: TextInputAction.next,
      onChanged: (value) {
        setState(() {
          RegisterScreenState.stateValid = false;
          phoneNumber = value;
          DatabaseService.userPhone = value;
        });
      },
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.normal,
      ),
      autocorrect: false,
      keyboardType: TextInputType.phone,
      autovalidateMode: AutovalidateMode.always,
      cursorColor: Colors.black,
      initialValue: '+1',
      decoration: InputDecoration(
        contentPadding: EdgeInsets.only(top: 10.0, left: 15.0),
        hintText: '+1',
        hintStyle: const TextStyle(color: Colors.grey),
        fillColor: Colors.white,
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
        errorMaxLines: 1,
      ),
    );
  }
}
