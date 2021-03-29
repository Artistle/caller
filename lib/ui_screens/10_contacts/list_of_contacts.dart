import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/constants/constants.dart';
import 'package:flutter_app/custom_widgets/Custom_CheckBox.dart';
import 'package:flutter_app/custom_widgets/Custom_Flushbar.dart';
import 'package:flutter_app/localization/localization.dart';
import 'package:flutter_app/ui_screens/10_contacts/firestore_contacts_api.dart';
import 'package:permission_handler/permission_handler.dart';

import '../screens.dart';

class ContactsList extends StatefulWidget {
  final String groupId;

  ContactsList({
    Key key,
    this.groupId,
  }) : super(key: key);

  @override
  ContactsListState createState() => ContactsListState();
}

class ContactsListState extends State<ContactsList> {
  String userPhone;
  String checkString = '';
  String users = '';

  List<Contact> contacts = [];
  List<Contact> contactsFiltered = [];
  Map<String, Color> contactsColorMap = new Map();
  TextEditingController searchController = new TextEditingController();

  var phoneNum;
  var fullString = StringBuffer();

  bool inviteValue = false;
  DocumentSnapshot userS;

  @override
  void initState() {
    super.initState();
    getPermissions();
    getNumbers();
    // reversePhone();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getPermissions() async {
    if (await Permission.contacts.request().isGranted) {
      getAllContacts();
      searchController.addListener(() {
        filterContacts();
      });
    }
  }

  String flattenPhoneNumber(String phoneStr) {
    return phoneStr.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
      return m[0] == "+" ? "+" : "";
    });
  }

  getAllContacts() async {
    List colors = [Colors.green, Colors.indigo, Colors.yellow, Colors.orange];
    int colorIndex = 0;
    List<Contact> _contacts = (await ContactsService.getContacts()).toList();
    _contacts.forEach((contact) {
      Color baseColor = colors[colorIndex];
      contactsColorMap[contact.displayName] = baseColor;
      colorIndex++;
      if (colorIndex == colors.length) {
        colorIndex = 0;
      }
    });
    setState(() {
      contacts = _contacts;
    });
  }

  filterContacts() {
    List<Contact> _contacts = [];
    _contacts.addAll(contacts);
    if (searchController.text.isNotEmpty) {
      _contacts.retainWhere((contact) {
        String searchTerm = searchController.text.toLowerCase();
        String searchTermFlatten = flattenPhoneNumber(searchTerm);
        String contactName = contact.displayName.toLowerCase();
        bool nameMatches = contactName.contains(searchTerm);
        if (nameMatches == true) {
          return true;
        }

        if (searchTermFlatten.isEmpty) {
          return false;
        }

        var phone = contact.phones.firstWhere((phn) {
          String phnFlattened = flattenPhoneNumber(phn.value);
          return phnFlattened.contains(searchTermFlatten);
        }, orElse: () => null);

        return phone != null;
      });
    }
    setState(() {
      contactsFiltered = _contacts;
    });
  }

  Future getNumbers() async {
    final userResult = FirebaseFirestore.instance.collection('userData');
    userResult.get().then((snapshot) {
      snapshot.docs.forEach((doc) {
        phoneNum = doc.data()['userID'];
        fullString.write(phoneNum);
      });

      users = fullString.toString();
    });
  }

  void addUser() async {
    userS["${widget.groupId}" + "request"] == true
        ? FirestoreContactsApi().sendRequest(
            widget.groupId,
            userPhone,
          )
        : setState(() {});
  }

  String phoneNumberContact = '';

  String solution1(str) {
    return str.split('').reversed.join('');
  }

  @override
  Widget build(BuildContext context) {
    var sizeX = MediaQuery.of(context).size;
    bool isSearching = searchController.text.isNotEmpty;
    bool listItemsExist = (contactsFiltered.length > 0 || contacts.length > 0);
    return Container(
      height: sizeX.height / 1.4,
      width: sizeX.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Container(
              height: sizeX.height / 20,
              width: sizeX.width,
              child: TextField(
                cursorColor: ConstColors.mainColor,
                controller: searchController,
                decoration: InputDecoration(
                  hintText: AppLocalization.of(context)
                      .getTranslatedValue("write_to_search"),
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: sizeX.height / 60,
                  ),
                  focusedBorder: new OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: new BorderSide(color: ConstColors.mainColor),
                  ),
                  enabledBorder: new OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: new BorderSide(color: Colors.grey[300]),
                  ),
                  border: new OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: new BorderSide(color: Colors.grey[300]),
                  ),
                  suffixIcon: Icon(Icons.search, color: ConstColors.subColor),
                ),
              ),
            ),
          ),
          listItemsExist == true
              ? Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: sizeX.height / 1.85,
                        child: ListView.builder(
                          physics: BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: isSearching == true
                              ? contactsFiltered.length
                              : contacts.length,
                          itemBuilder: (context, index) {
                            Contact contact = isSearching == true
                                ? contactsFiltered[index]
                                : contacts[index];

                            return Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child:
                                      (contact.phones.length != 0 &&
                                              users.contains(((contact.phones
                                                      .elementAt(0)
                                                      .value)
                                                  .replaceAll(
                                                      RegExp(r'[^\w\*\#\\s+]'),
                                                      ""))))
                                          ? StreamBuilder(
                                              stream: FirebaseFirestore.instance
                                                  .collection('userData')
                                                  .doc(((contact.phones
                                                          .elementAt(0)
                                                          .value)
                                                      .replaceAll(
                                                          RegExp(
                                                              r'[^\w\*\#\\s+]'),
                                                          "")))
                                                  .snapshots(),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot snapshot) {
                                                DocumentSnapshot userSnapshot =
                                                    snapshot.data;
                                                userS = userSnapshot;
                                                phoneNumberContact = (contact
                                                        .phones
                                                        .elementAt(0)
                                                        .value)
                                                    .toString();
                                                if (snapshot.hasData) {
                                                  return Column(
                                                    children: [
                                                      Container(
                                                        child: ListTile(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12.0),
                                                          ),
                                                          trailing: Theme(
                                                            data: ThemeData(
                                                              primarySwatch:
                                                                  Colors.blue,
                                                              unselectedWidgetColor:
                                                                  Colors
                                                                      .white, // Your color
                                                            ),
                                                            child: Container(
                                                              height: 23,
                                                              width: 23,
                                                              decoration: BoxDecoration(
                                                                  color: userSnapshot[widget.groupId + 'request']
                                                                          // inviteValue
                                                                          ==
                                                                          true
                                                                      ? ConstColors.mainColor
                                                                      : Colors.white,
                                                                  border: Border.all(
                                                                    color: ConstColors
                                                                        .mainColor,
                                                                    width: 1,
                                                                  ),
                                                                  borderRadius: BorderRadius.circular(
                                                                    4.5,
                                                                  )),
                                                              child: Checkbox(
                                                                value: userSnapshot[
                                                                    widget.groupId +
                                                                        'request'],
                                                                tristate: false,
                                                                activeColor:
                                                                    ConstColors
                                                                        .mainColor,
                                                                checkColor:
                                                                    ConstColors
                                                                        .mainColor,
                                                                onChanged: (bool
                                                                    value) {
                                                                  setState(() {
                                                                    userPhone = (contact
                                                                            .phones
                                                                            .elementAt(
                                                                                0)
                                                                            .value)
                                                                        .replaceAll(
                                                                            RegExp(r'[^\w\*\#\\s+]'),
                                                                            "");

                                                                    inviteValue =
                                                                        value;
                                                                    FirestoreContactsApi()
                                                                        .inviteState(
                                                                      widget
                                                                          .groupId,
                                                                      userPhone,
                                                                      inviteValue,
                                                                      userSnapshot,
                                                                    );
                                                                  });
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                          onTap: () {
                                                            setState(() {
                                                              print(userPhone);
                                                            });
                                                          },
                                                          title: Text(
                                                            contact.displayName,
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                          subtitle: Text(
                                                            contact.phones.length !=
                                                                        0 &&
                                                                    HomeScreenState.docSnap[
                                                                            'appLang'] !=
                                                                        'עברית'
                                                                ? ((contact
                                                                        .phones
                                                                        .elementAt(
                                                                            0)
                                                                        .value)
                                                                    .replaceAll(
                                                                        RegExp(
                                                                            r'[^\w\*\#\\s+]'),
                                                                        ""))
                                                                : ((contact.phones
                                                                            .elementAt(
                                                                                0)
                                                                            .value)
                                                                        .replaceAll(
                                                                            RegExp(r'[^\w\*\#\\s+]'),
                                                                            "")) +
                                                                    '+',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 10,
                                                            ),
                                                          ),
                                                          leading: (contact
                                                                          .avatar !=
                                                                      null &&
                                                                  contact.avatar
                                                                          .length >
                                                                      0)
                                                              ? CircleAvatar(
                                                                  backgroundImage:
                                                                      MemoryImage(
                                                                          contact
                                                                              .avatar),
                                                                )
                                                              : Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: ConstColors
                                                                        .registerTextColor,
                                                                  ),
                                                                  child:
                                                                      CircleAvatar(
                                                                          child:
                                                                              Text(
                                                                            contact.initials(),
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.white,
                                                                            ),
                                                                          ),
                                                                          backgroundColor:
                                                                              Colors.transparent),
                                                                ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                } else if (snapshot.hasError ||
                                                    !snapshot.hasData) {
                                                  return Container();
                                                }
                                                return Container();
                                              },
                                            )
                                          : Container(),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      Material(
                        elevation: 2.0,
                        borderRadius: BorderRadius.circular(20.0),
                        child: Container(
                          height: 45,
                          width: 150,
                          decoration: BoxDecoration(
                              gradient: ConstColors.saveUserStateInGroup,
                              borderRadius: BorderRadius.circular(20.0)),
                          // ignore: deprecated_member_use
                          child: FlatButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0)),
                            onPressed: () {
                              Future sendRequest() async {
                                final List<String> groupReques = [
                                  widget.groupId
                                ];

                                // ignore: unused_local_variable
                                final documentReference = FirebaseFirestore
                                    .instance
                                    .collection('userData')
                                    .doc(userPhone)
                                    .update({
                                  "request": FieldValue.arrayUnion(groupReques),
                                });
                              }

                              sendRequest();
                              print(userPhone);
                              if (userPhone != '') {
                                setState(() {
                                  Navigator.pop(context);
                                  showCustomFlushbar(
                                    context,
                                    'Invite request sent!',
                                  );
                                });
                              }
                            },
                            child: Center(
                              child: Text(
                                AppLocalization.of(context)
                                    .getTranslatedValue("invite"),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              : Center(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      backgroundColor: ConstColors.mainColor,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
