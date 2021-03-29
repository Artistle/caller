import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/animations/fade_animation.dart';
import 'package:flutter_app/constants/constants.dart';
import 'package:flutter_app/custom_widgets/Custom_CheckBox.dart';
import 'package:flutter_app/database/database_service.dart';
import 'package:flutter_app/localization/localization.dart';
import 'package:flutter_app/register/phone_number/phone_number.dart';
import 'package:flutter_app/ui_screens/9_speech_to_text/FirestoreSpeechApi.dart';
import 'package:flutter_app/ui_screens/screens.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_app/register/verify_code/verification_code.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  static bool stateValid = false;
  final _formKey = GlobalKey<FormState>();
  File _selectedFile;
  bool _inProcess = false;
  static String uploadedFileURL;
  @override
  void initState() {
    super.initState();
    userEmailState = false;
    userNameSate = false;
    checkValid = false;
    stateValid = false;
    DatabaseService.userImage = uploadedFileURL;
    WelcomThirdHelperState.login = false;
  }

  Future uploadFile() async {
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('profile_imanges/${Path.basename(_selectedFile.path)}}');
    UploadTask uploadTask = storageReference.putFile(_selectedFile);
    await uploadTask.whenComplete(() => () {});

    storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        uploadedFileURL = fileURL;
      });
      setState(() {
        DatabaseService.userImage = uploadedFileURL;
        print(uploadedFileURL);
      });
    });
  }

  getImage(ImageSource source) async {
    this.setState(() {
      _inProcess = true;
    });
    // ignore: deprecated_member_use
    // ignore: invalid_use_of_visible_for_testing_member
    PickedFile image = await ImagePicker.platform.pickImage(source: source);
    if (image != null) {
      File cropped = await ImageCropper.cropImage(
          cropStyle: CropStyle.circle,
          sourcePath: image.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          compressQuality: 100,
          maxWidth: 1080,
          maxHeight: 1920,
          compressFormat: ImageCompressFormat.png,
          androidUiSettings: AndroidUiSettings(
            toolbarColor: Colors.transparent,
            toolbarTitle: "",
            statusBarColor: Colors.transparent,
            backgroundColor: Colors.white,
          ));

      this.setState(() {
        _selectedFile = cropped;
        _inProcess = false;
        uploadFile();
      });
    } else {
      this.setState(() {
        _inProcess = false;

        uploadFile();
      });
    }
  }

  static bool authButton = false;
  static String verificationID;
  static Future<bool> loginUser(String phone, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async {},
        verificationFailed: (FirebaseException exception) {
          print(exception);
        },
        codeSent: (String verificationId, [int forceResendingToken]) {
          verificationID = verificationId;
          print(verificationID);

          Timer(Duration(seconds: 1), () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => VerificationCode()));
          });
        },
        codeAutoRetrievalTimeout: null);
  }

  var loginPageMethods = PhoneNumberState();
  static bool check = false;
  static bool checkValid = false;

  static bool userNameSate = false;
  static bool userEmailState = false;

  @override
  Widget build(BuildContext context) {
    var sizeX = MediaQuery.of(context).size;
    return Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          leading: FadeAnimation(
            0.5,
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Container(
            height: sizeX.height,
            width: sizeX.width,
            child: Padding(
              padding: EdgeInsets.only(top: sizeX.height / 150),
              child: ListView(
                physics: BouncingScrollPhysics(),
                children: <Widget>[
                  ListTile(
                    title: Padding(
                      padding: EdgeInsets.only(bottom: sizeX.height / 60),
                      child: Center(
                        child: Text(
                            AppLocalization.of(context)
                                .getTranslatedValue("create_an_acc"),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                            )),
                      ),
                    ),
                    subtitle: Padding(
                      padding: EdgeInsets.only(bottom: sizeX.height / 150),
                      child: Center(
                        child: Column(
                          children: <Widget>[
                            Container(
                              height: 90,
                              width: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: GestureDetector(
                                  onTap: () => getImage(ImageSource.gallery),
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.grey[300],
                                    child: _selectedFile != null
                                        ? ClipOval(
                                            child: Container(
                                              height: 90,
                                              width: 90,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.grey,
                                                border: Border.all(
                                                    color: Colors.grey[400]),
                                              ),
                                              child: Image.file(
                                                _selectedFile,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          )
                                        : Container(
                                            height: 90,
                                            width: 90,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.grey[300],
                                            ),
                                            child: Center(
                                              child: SvgPicture.asset(
                                                  'assets/icons/icon_place_photo.svg'),
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
                  Padding(
                    padding: EdgeInsets.only(top: sizeX.height / 40),
                    child: Center(
                      child: Container(
                        height: sizeX.height / 16,
                        width: 290,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                color: userNameSate == false
                                    ? Colors.grey[400]
                                    : Colors.red),
                            borderRadius: BorderRadius.circular(12.0)),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: TextFormField(
                            textAlignVertical: TextAlignVertical.top,
                            onChanged: (value) {
                              DatabaseService.userName = value;
                            },
                            validator: (value) =>
                                value.length < 2 ? null : null,
                            cursorColor: Colors.black,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp("[a-zA-Z -]")),
                            ],
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                            ),
                            textInputAction: TextInputAction.next,
                            textAlign: TextAlign.start,
                            decoration: InputDecoration(
                              hintText: AppLocalization.of(context)
                                  .getTranslatedValue("hint_full_name"),
                              hintStyle: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(bottom: 5.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: sizeX.height / 40),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          PhoneNumber(),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: sizeX.height / 40),
                    child: Center(
                      child: Container(
                        height: sizeX.height / 16,
                        width: 290,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                color: userEmailState == false
                                    ? Colors.grey[400]
                                    : Colors.red),
                            borderRadius: BorderRadius.circular(12.0)),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: TextFormField(
                            textAlignVertical: TextAlignVertical.top,
                            onChanged: (value) {
                              DatabaseService.userEmail = value;
                            },
                            validator: (value) =>
                                !value.contains('@') ? null : null,
                            cursorColor: Colors.black,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp("[a-zA-Z.@ 0-9]")),
                            ],
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                            ),
                            textInputAction: TextInputAction.next,
                            textAlign: TextAlign.start,
                            decoration: InputDecoration(
                              hintText: AppLocalization.of(context)
                                  .getTranslatedValue("hint_email"),
                              hintStyle: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey,
                              ),
                              contentPadding: EdgeInsets.only(bottom: 5.0),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: sizeX.height / 40),
                    child: Center(
                      child: Container(
                        height: sizeX.height / 16,
                        width: 290,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey[400]),
                            borderRadius: BorderRadius.circular(12.0)),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: TextFormField(
                              textAlignVertical: TextAlignVertical.top,
                              onChanged: (value) {
                                DatabaseService.companyName = value;
                              },
                              // validator: (value) =>
                              //     value.length < 2 ? 'Input company' : null,
                              cursorColor: Colors.black,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp("[a-zA-Z -]")),
                              ],
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                              ),
                              textInputAction: TextInputAction.done,
                              textAlign: TextAlign.start,
                              decoration: InputDecoration(
                                hintText: AppLocalization.of(context)
                                    .getTranslatedValue("hint_company"),
                                hintStyle: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.grey,
                                ),
                                contentPadding: EdgeInsets.only(bottom: 5.0),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(top: 20.0, left: 20.0, right: 30.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CustomCheckbox(
                              onTap: () {
                                setState(() {
                                  CustomCheckboxState.isSelected =
                                      !CustomCheckboxState.isSelected;
                                  checkValid = false;
                                  check = true;
                                });
                              },
                              size: 20,
                              selectedColor: ConstColors.mainColor,
                            )),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalization.of(context)
                                  .getTranslatedValue("confirm_text"),
                              softWrap: true,
                              style: TextStyle(fontSize: sizeX.height / 65),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                InkWell(
                                  onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) => Rules())),
                                  child: Text(
                                    AppLocalization.of(context)
                                        .getTranslatedValue("terms_of_service"),
                                    softWrap: true,
                                    style: TextStyle(
                                      fontSize: sizeX.height / 65,
                                      color: ConstColors.registerTextColor,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                Text(
                                  ' & ',
                                  softWrap: true,
                                  style: TextStyle(
                                      fontSize: sizeX.height / 65,
                                      color: ConstColors.registerTextColor),
                                ),
                                InkWell(
                                  onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) => Rules())),
                                  child: Text(
                                    AppLocalization.of(context)
                                        .getTranslatedValue("privacy_policy"),
                                    softWrap: true,
                                    style: TextStyle(
                                      fontSize: sizeX.height / 65,
                                      color: ConstColors.registerTextColor,
                                      fontWeight: FontWeight.w800,
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
                  Padding(
                    padding: EdgeInsets.only(top: sizeX.height / 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ((authButton == true) && (checkValid == false))
                            ? CircularProgressIndicator(
                                backgroundColor: ConstColors.mainColor,
                              )
                            : Material(
                                elevation: 3.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                child: Container(
                                  height: 45,
                                  width: 190,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30.0),
                                    color: ConstColors.mainColor,
                                  ),
                                  child:
                                      // ignore: deprecated_member_use
                                      FlatButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0)),
                                    onPressed: () {
                                      setState(() {
                                        print(authButton);
                                        DatabaseService.userName.length > 2
                                            ? userNameSate = false
                                            : userNameSate = true;
                                        (DatabaseService.userEmail
                                                    .contains('@') &&
                                                DatabaseService
                                                        .userEmail.length >
                                                    1)
                                            ? userEmailState = false
                                            : userEmailState = true;
                                      });
                                      if (check == false) {
                                        setState(() {
                                          checkValid = true;
                                        });
                                      } else {
                                        authButton = true;
                                      }
                                      DatabaseService.userImage =
                                          uploadedFileURL;
                                      if (PhoneNumberState.phoneNumber ==
                                              null ||
                                          PhoneNumberState.phoneNumber == '') {
                                        setState(() {
                                          stateValid = true;
                                        });
                                      }
                                      if (_formKey.currentState.validate()) {
                                        if (check == true &&
                                            PhoneNumberState.phoneNumber !=
                                                '') {
                                          DatabaseService.userImage =
                                              uploadedFileURL;

                                          loginUser(
                                              PhoneNumberState.phoneNumber,
                                              context);
                                        }
                                      }
                                    },
                                    child: Text(
                                      AppLocalization.of(context)
                                          .getTranslatedValue("next_button"),
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
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: sizeX.height / 25),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => LoginScreen()));
                          });
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
                        ),
                      ),
                    ),
                  ),
                  (_inProcess)
                      ? Container(
                          color: Colors.white,
                          height: MediaQuery.of(context).size.height * 0.95,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Center()
                ],
              ),
            ),
          ),
        ));
  }

  void checkBoxState(bool newCheck) => setState(() {
        uploadFile();
        check = newCheck;
        checkValid = false;
      });
}
