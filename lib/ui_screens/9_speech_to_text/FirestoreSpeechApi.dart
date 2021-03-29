import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseAuth auth = FirebaseAuth.instance;
User user = auth.currentUser;

class FirestoreSpeechApi {
  final uPhone = user.phoneNumber;

  Future speechToTextUpd(String logPath, String text) async {
    // ignore: unused_local_variable
    var logRef = FirebaseFirestore.instance
        .collection('CallLogs')
        .doc(logPath)
        .update({'speechText': text});
  }
}
