import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreContactsApi {
  Future sendRequest(
    String groupId,
    String userPhone,
  ) async {
    final List<String> groupReques = [groupId];

    // ignore: unused_local_variable
    final documentReference = FirebaseFirestore.instance
        .collection('userData')
        .doc(userPhone)
        .update({
      "request": FieldValue.arrayUnion(groupReques),
    });
  }

  Future deleteRequest(
    String groupId,
    String userPhone,
  ) async {
    final List<String> groupReques = [groupId];
    // ignore: unused_local_variable
    final documentReference = FirebaseFirestore.instance
        .collection('userData')
        .doc(userPhone)
        .update({
      "request": FieldValue.arrayRemove(groupReques),
    });
  }

  Future inviteState(
    String groupId,
    String userPhone,
    bool inviteState,
    DocumentSnapshot userSnap,
  ) async {
    // ignore: unused_local_variable
    final documentReference = FirebaseFirestore.instance
        .collection('userData')
        .doc(userPhone)
        .update({
      "$groupId" + "request":
          userSnap["$groupId" + "request"] == false ? true : false,
    });
  }
}
