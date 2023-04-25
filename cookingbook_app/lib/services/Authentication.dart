import 'dart:async';

import 'package:cookingbook_app/screens/EmailVerificationDemo.dart';
import 'package:cookingbook_app/services/FireStoreService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';

class Authentication with ChangeNotifier {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirestoreService firestoreService = FirestoreService();

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
      UserCredential userCredential = await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

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

  Future<User?> signUp(
      {required String userEmail,
      required String password,
      required BuildContext context}) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: userEmail, password: password);

      if (!(await firestoreService
          .doesProfileExist(userCredential.user!.uid))) {
        await firestoreService.addProfile();
      }
      // if (!(await firestoreService
      //     .isProfileExistWithId(userCredential.user!.uid))) {
      //   print("vao thang duoiiiiiiiiiiiiiiiiiiiiiiii");
      //   //firestoreService.addProfile();
      // }
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

  //create an account
  // Future<UserCredential> createAccount(String email, String password) async {
  //   UserCredential userCredential = await firebaseAuth
  //       .createUserWithEmailAndPassword(email: email, password: password);

  //   User? user = userCredential.user;
  //   userUid = user!.uid;

  //   print("Created account Uid => $userUid");
  //   if (!(await firestoreService.doesProfileExist(userUid))) {
  //     firestoreService.addProfile();
  //   }
  //   notifyListeners();
  //   await userCredential.user!.sendEmailVerification();
  //   return userCredential;
  // }

  // sign with google
  Future signInWithGoogle() async {
    if (kIsWeb) {
      // sign in with Google on web
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();

      try {
        final UserCredential userCredential =
            await firebaseAuth.signInWithPopup(googleProvider);

        final User? user = userCredential.user;
        assert(user!.uid != null);

        userUid = user!.uid;

        print('Google User Uid => $userUid');
        if (!(await firestoreService.doesProfileExist(userUid))) {
          firestoreService.addProfile();
        }
      } catch (e) {
        print('Error signing in with Google on web: $e');
      }
    } else {
      // sign in with Google on Android
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      final AuthCredential authCredential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken);

      try {
        final UserCredential userCredential =
            await firebaseAuth.signInWithCredential(authCredential);

        final User? user = userCredential.user;
        assert(user!.uid != null);

        userUid = user!.uid;

        print('Google User Uid => $userUid');
        if (!(await firestoreService.doesProfileExist(userUid))) {
          firestoreService.addProfile();
        }
      } catch (e) {
        print('Error signing in with Google on Android: $e');
      }
    }

    notifyListeners();
  }

  // Future signInWithGoogle() async {
  //   final GoogleSignInAccount? googleSignInAccount =
  //       await googleSignIn.signIn();

  //   final GoogleSignInAuthentication googleSignInAuthentication =
  //       await googleSignInAccount!.authentication;

  //   final AuthCredential authCredential = GoogleAuthProvider.credential(
  //       accessToken: googleSignInAuthentication.accessToken,
  //       idToken: googleSignInAuthentication.idToken);

  //   final UserCredential userCredential =
  //       await firebaseAuth.signInWithCredential(authCredential);
  //   final User? user = userCredential.user;
  //   assert(user!.uid != null);

  //   userUid = user!.uid;

  //   print('Google User Uid => $userUid');

  //   notifyListeners();
  // }

  Future onLogout(String signInMethod) async {
    signInMethod = signInMethod.trim();
    // print("this is signInMethode in onLogout $signInMethod");
    if (signInMethod == "emailPassword") {
      // print("logout by email password");
      return firebaseAuth.signOut();
    } else if (signInMethod == "google") {
      // print("logout by google");
      return googleSignIn.signOut();
    } else {
      print("error onLogout Methode Authentication.dart");
    }
  }
}
