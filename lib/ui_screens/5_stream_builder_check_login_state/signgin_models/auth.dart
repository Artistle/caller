import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/ui_screens/5_stream_builder_check_login_state/signgin_models/users.dart';

class AuthService {
  Users _userFromFirebaseUser(User user) {
    return user != null ? Users(uid: user.phoneNumber) : null;
  }

  Stream<Users> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  //anonymus
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future singInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User user = result.user;
      return _userFromFirebaseUser(user);
    } catch (error) {
      return null;
    }
  }

//sing in with eamil & password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password);
      User user = result.user;
      return _userFromFirebaseUser(user);
    } catch (error) {
      return null;
    }
  }

  //with email & password
  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password);
      User user = result.user;
      return _userFromFirebaseUser(user);
    } catch (error) {
      return null;
    }
  }

  //Sing out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (error) {
      return null;
    }
  }
}
