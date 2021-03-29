import 'package:flutter/material.dart';
import 'package:flutter_app/constants/constants.dart';
import 'package:flutter_app/database/database_service.dart';
import 'package:flutter_app/localization/localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDialog extends StatefulWidget {
  final DocumentSnapshot docSnapshot;
  final DocumentSnapshot groupSnapshot;
  final dateEngDate;
  final String uid;

  final Function(bool) onChanged;
  UserDialog(
      {Key key,
      this.docSnapshot,
      this.groupSnapshot,
      this.dateEngDate,
      this.uid,
      this.onChanged})
      : super(key: key);

  @override
  _UserDialogState createState() => _UserDialogState();
}

class _UserDialogState extends State<UserDialog> {
  @override
  Widget build(BuildContext context) {
    var sizeX = MediaQuery.of(context).size;
    return Center(
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0), color: Colors.white),
        height: sizeX.height / 1.3,
        width: sizeX.width / 1.25,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            10.0,
            0.0,
            10.0,
            0.0,
          ),
          child: Stack(
            children: [
              ListView(
                physics: BouncingScrollPhysics(),
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.black),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              ClipOval(
                                child: CircleAvatar(
                                  radius: 25.0,
                                  backgroundColor: ConstColors.mainColor,
                                  child: Image.network(widget
                                      .docSnapshot['userImage']
                                      .toString()),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      widget.docSnapshot['userName'].toString(),
                                      style: TextStyle(
                                          fontSize: sizeX.height / 55,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5.0),
                                      child: Text(
                                        'San Francisco, CA',
                                        style: TextStyle(
                                            fontSize: sizeX.height / 70,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w300),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 10.0),
                            child: Text(
                              widget.docSnapshot[
                                          widget.groupSnapshot.id + 'admin'] ==
                                      true
                                  ? 'Admin'
                                  : '',
                              style: TextStyle(
                                  fontSize: sizeX.height / 65,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w300),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10.0, right: 10.0, top: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalization.of(context)
                                  .getTranslatedValue("info"),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: sizeX.height / 60,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    AppLocalization.of(context)
                                        .getTranslatedValue("phone_number"),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: sizeX.height / 65,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    widget.docSnapshot['userPhone'],
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: sizeX.height / 65,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    AppLocalization.of(context)
                                        .getTranslatedValue("date_added"),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: sizeX.height / 65,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    widget.dateEngDate.format(DateTime.tryParse(
                                        widget.docSnapshot[
                                                widget.groupSnapshot.id]
                                            .toDate()
                                            .toString())),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: sizeX.height / 65,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            widget.groupSnapshot[widget.uid + 'admin'] == true
                                ? Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 20.0,
                                          bottom: 5.0,
                                        ),
                                        child: Text(
                                          AppLocalization.of(context)
                                              .getTranslatedValue("access"),
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: sizeX.height / 60,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10.0),
                                        child: Text(
                                          AppLocalization.of(context)
                                              .getTranslatedValue(
                                                  "edit_permission_desc"),
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: sizeX.height / 70,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            AppLocalization.of(context)
                                                .getTranslatedValue(
                                                    "set_as_admin"),
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: sizeX.height / 65,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Switch(
                                              inactiveTrackColor:
                                                  Colors.grey[300],
                                              activeTrackColor:
                                                  ConstColors.mainColor,
                                              activeColor:
                                                  ConstColors.registerTextColor,
                                              value: widget.docSnapshot[
                                                  widget.groupSnapshot.id +
                                                      'admin'],
                                              onChanged: (value) {
                                                setState(
                                                    () => widget.onChanged);
                                              }

                                              // updAdminParam();
                                              // updAdminParamInGroup();
                                              ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            AppLocalization.of(context)
                                                .getTranslatedValue("auto_rec"),
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: sizeX.height / 65,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Switch(
                                            inactiveTrackColor:
                                                Colors.grey[300],
                                            activeTrackColor:
                                                ConstColors.mainColor,
                                            activeColor:
                                                ConstColors.registerTextColor,
                                            value:
                                                DatabaseService.temporarySate,
                                            onChanged: (value) {
                                              setState(() {
                                                DatabaseService.temporarySate =
                                                    value;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            AppLocalization.of(context)
                                                .getTranslatedValue("edit_rec"),
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: sizeX.height / 65,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Switch(
                                            inactiveTrackColor:
                                                Colors.grey[300],
                                            activeTrackColor:
                                                ConstColors.mainColor,
                                            activeColor:
                                                ConstColors.registerTextColor,
                                            value:
                                                DatabaseService.temporarySate,
                                            onChanged: (value) {
                                              setState(() {
                                                DatabaseService.temporarySate =
                                                    value;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                : Container(),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
              Positioned(
                left: 0.0,
                right: 0.0,
                bottom: 20.0,
                child: Center(
                  child: Column(
                    children: [
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
                          // ignore: deprecated_member_use
                          child: FlatButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Center(
                              child: Text(
                                AppLocalization.of(context)
                                    .getTranslatedValue("save"),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: sizeX.height / 60),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: widget.groupSnapshot[widget.uid + 'admin'] ==
                                true
                            ? Material(
                                elevation: 1.0,
                                borderRadius: BorderRadius.circular(20.0),
                                child: Container(
                                  height: 35,
                                  width: 180,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1.0, color: Colors.grey[500]),
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
                                        // deleteUser();
                                        // deleteUserFromGroup()
                                        //     .whenComplete(() =>
                                        //         Navigator.of(
                                        //                 context)
                                        //             .pop());
                                      });
                                    },
                                    child: Center(
                                      child: Text(
                                        AppLocalization.of(context)
                                            .getTranslatedValue(
                                                "delete_from_group"),
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: sizeX.height / 65),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
