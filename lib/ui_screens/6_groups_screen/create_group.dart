import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_app/constants/constants.dart';
import 'package:flutter_app/localization/localization.dart';
import 'package:path/path.dart' as Path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_app/database/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../screens.dart';

class CreateGroupe extends StatefulWidget {
  CreateGroupe({Key key}) : super(key: key);

  @override
  _CreateGroupeState createState() => _CreateGroupeState();
}

class _CreateGroupeState extends State<CreateGroupe> {
  File _selectedFile;
  // ignore: unused_field
  bool _inProcess = false;
  String _uploadedFileURL = '';
  num counter = 1;
  bool switchState1;
  bool switchState2;
  bool switchState3;

  bool focus = false;
  @override
  void initState() {
    super.initState();
  }

  getImage(ImageSource source) async {
    this.setState(() {
      _inProcess = true;
    });
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
        focus = true;
        uploadFile();
        setState(() {});
      });
      setState(() {
        uploadFile();
        setState(() {
          uploadFile();
        });
      });
    } else {
      setState(() {
        uploadFile();
      });
      this.setState(() {
        uploadFile();
        _inProcess = false;
      });
    }
  }

  Future uploadFile() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;
    final String uid = user.phoneNumber;
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('profile_imanges/$uid/${Path.basename(_selectedFile.path)}}');
    UploadTask uploadTask = storageReference.putFile(_selectedFile);
    await uploadTask;

    storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        _uploadedFileURL = fileURL;
      });
      setState(() {
        DatabaseService.groupImage = _uploadedFileURL;
      });
    });
  }

  bool stateValid = false;
  @override
  Widget build(BuildContext context) {
    var sizeX = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalization.of(context).getTranslatedValue("create_group"),
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: sizeX.height / 40,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          splashRadius: 20.0,
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          Container(
            height: sizeX.height,
            child: Padding(
              padding: EdgeInsets.only(top: sizeX.height / 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: sizeX.height / 100),
                    child: Container(
                      height: 95,
                      width: 95,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              getImage(ImageSource.gallery);
                              focus = true;
                            });
                          },
                          child: _selectedFile != null
                              ? ClipOval(
                                  child: Container(
                                    height: 95,
                                    width: 95,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey,
                                    ),
                                    child: Image.file(
                                      _selectedFile,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 95,
                                  width: 95,
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
                  Padding(
                    padding: EdgeInsets.only(bottom: sizeX.height / 20),
                    child: Text(
                      AppLocalization.of(context)
                          .getTranslatedValue("add_group_pic"),
                      style: TextStyle(
                        color: Colors.grey[60],
                        fontWeight: FontWeight.w300,
                        fontSize: sizeX.height / 75,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: sizeX.height / 20),
                    child: Container(
                      height: 35,
                      width: sizeX.width / 1.2,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1.2, color: Colors.grey[300]),
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            left: 20.0,
                            top: 0.0,
                            bottom: 0.0,
                            child: Center(
                              child: Container(
                                height: 45,
                                width: sizeX.width,
                                child: TextField(
                                  onTap: () {
                                    setState(() {
                                      uploadFile();
                                    });
                                  },
                                  onChanged: (name) {
                                    setState(() {
                                      DatabaseService.groupName = name;
                                    });
                                  },
                                  cursorColor: ConstColors.registerTextColor,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(
                                        top: 5.0,
                                        right: HomeScreenState
                                                    .docSnap['appLang'] ==
                                                'English'
                                            ? 0.0
                                            : 95.0),
                                    hintText: AppLocalization.of(context)
                                        .getTranslatedValue("group_name"),
                                    hintStyle: TextStyle(
                                        fontSize: sizeX.height / 70,
                                        color: Colors.grey[400]),
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
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: sizeX.height / 100),
                    child: Text(
                      AppLocalization.of(context)
                          .getTranslatedValue("settings"),
                      style: TextStyle(
                          fontSize: sizeX.height / 55,
                          color: Colors.black,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: sizeX.height / 30,
                        right: sizeX.height / 30,
                        bottom: 15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              AppLocalization.of(context)
                                  .getTranslatedValue("private_state"),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: sizeX.height / 60,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Switch(
                              inactiveTrackColor: Colors.grey[300],
                              activeTrackColor: ConstColors.mainColor,
                              activeColor: Colors.white,
                              value: DatabaseService.privateState,
                              onChanged: (value) {
                                setState(() {
                                  DatabaseService.privateState = value;
                                });
                              },
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              AppLocalization.of(context)
                                  .getTranslatedValue("temporary_state"),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: sizeX.height / 60,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Switch(
                              inactiveTrackColor: Colors.grey[300],
                              activeTrackColor: ConstColors.mainColor,
                              activeColor: Colors.white,
                              value: DatabaseService.temporarySate,
                              onChanged: (value) {
                                setState(() {
                                  DatabaseService.temporarySate = value;
                                });
                              },
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              AppLocalization.of(context)
                                  .getTranslatedValue("days_count"),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: sizeX.height / 60,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (counter > 1) counter--;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: ConstColors.mainColor,
                                    ),
                                    height: 20,
                                    width: 20,
                                    child: Center(
                                      child: Icon(
                                        Icons.remove,
                                        color: Colors.white,
                                        size: 16.0,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 7.0),
                                  child: Text(
                                    '$counter',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: sizeX.height / 60,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      counter++;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: ConstColors.mainColor,
                                    ),
                                    height: 20,
                                    width: 20,
                                    child: Center(
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 16.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              AppLocalization.of(context)
                                  .getTranslatedValue("auto_record_state"),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: sizeX.height / 60,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Switch(
                              inactiveTrackColor: Colors.grey[300],
                              activeTrackColor: ConstColors.mainColor,
                              activeColor: Colors.white,
                              value: DatabaseService.autoRecState,
                              onChanged: (value) {
                                setState(() {
                                  DatabaseService.autoRecState = value;
                                });
                              },
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 50.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Material(
                                borderRadius: BorderRadius.circular(25.0),
                                elevation: 3.0,
                                child: Container(
                                  height: 40,
                                  width: 200,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25.0),
                                      color: ConstColors.mainColor),
                                  // ignore: deprecated_member_use
                                  child: FlatButton(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                    ),
                                    onPressed: () {
                                      if (DatabaseService.groupName != '') {
                                        setState(() {
                                          DatabaseService.daysCount = counter;
                                          DatabaseService.groupImage =
                                              _uploadedFileURL;

                                          DatabaseService()
                                              .createGroup()
                                              .whenComplete(() {
                                            DatabaseService.groupName = '';
                                            DatabaseService.daysCount = 1;
                                            DatabaseService.groupImage = '';

                                            Navigator.pop(context);
                                          });
                                        });
                                      }
                                    },
                                    child: Text(
                                      AppLocalization.of(context)
                                          .getTranslatedValue("next_button"),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
