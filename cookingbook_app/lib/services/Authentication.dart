import 'dart:async';

import 'package:cookingbook_app/screens/EmailVerificationDemo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authentication with ChangeNotifier {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  static late bool isEmailVerifiedClone;

  late String userUid;
  String get getUserUid => userUid;

  //login account email
  Future<bool> logIntoAccount(String email, String password) async {
    // UserCredential userCredential = await firebaseAuth
    //     .signInWithEmailAndPassword(email: email, password: password);

    // User? user = userCredential.user;
    // userUid = user!.uid;
    // print("LOGIN SUCESSFULLY WITH Uid == $userUid");
    // notifyListeners();
    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;
      userUid = user!.uid;

      print("LOGIN SUCESSFULLY WITH Uid == $userUid");
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      throw e;
      // Handle other errors here
    }
    // catch (error, stackTrace) {

    //   throw error;if (error is FirebaseAuthException && error.code == 'user-not-found') {}
    // }
  }

  //sign out account email
  Future logoutViaEmail() {
    return firebaseAuth.signOut();
  }

  Future<User?> signUp(
      {required String userEmail,
      required String password,
      required BuildContext context}) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: userEmail, password: password);
      await Future.delayed(const Duration(seconds: 10));
      print('');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('The password provided is too weak.')));
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('The account already exists for that email.')));
      }
      return null;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  // Future<User?> signUp(
  //     {required String userEmail,
  //     required String password,
  //     required BuildContext context}) async {
  //   try {
  //     await EmailVerificationScreen.completer.future;
  //     UserCredential userCredential = await FirebaseAuth.instance
  //         .createUserWithEmailAndPassword(email: userEmail, password: password);
  //     return userCredential.user;

  //     // UserCredential userCredential = await FirebaseAuth.instance
  //     //     .createUserWithEmailAndPassword(email: userEmail, password: password);
  //     // return userCredential.user;
  //   } on FirebaseAuthException catch (e) {
  //     if (e.code == 'weak-password') {
  //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //           content: Text('The password provided is too weak.')));
  //     } else if (e.code == 'email-already-in-use') {
  //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //           content: Text('The account already exists for that email.')));
  //     }
  //     return null;
  //   } catch (e) {
  //     debugPrint(e.toString());
  //     return null;
  //   }
  // }

  //create an account
  Future<UserCredential> createAccount(String email, String password) async {
    UserCredential userCredential = await firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);

    User? user = userCredential.user;
    userUid = user!.uid;

    print("Created account Uid => $userUid");
    notifyListeners();
    await userCredential.user!.sendEmailVerification();
    return userCredential;
  }

  // sign with google
  Future signInWithGoogle() async {
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;

    final AuthCredential authCredential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken);

    final UserCredential userCredential =
        await firebaseAuth.signInWithCredential(authCredential);
    final User? user = userCredential.user;
    assert(user!.uid != null);

    userUid = user!.uid;

    print('Google User Uid => $userUid');
    notifyListeners();
  }

  Future signOutWithGoogle() async {
    return googleSignIn.signOut();
  }
}
