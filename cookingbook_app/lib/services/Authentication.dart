import 'dart:async';
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
  }


  Future<User?> signUp(
      {required String userEmail,
        required String password,
        required String pseudoNom,
        required BuildContext context}) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: userEmail, password: password);
      String imageDefault =
          'https://firebasestorage.googleapis.com/v0/b/multidev-cookingbook.appspot.com/o/profileImages%2Fno-avatar.png?alt=media&token=d89cbaf6-494d-48cb-a7e2-55fe72412e4c';
      if (!(await firestoreService
          .doesProfileExist(userCredential.user!.uid))) {
        await firestoreService.addProfile(pseudoNom, imageDefault);
      }

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
  Future<User?> signInWithGoogle() async {
    User? user;
    if (kIsWeb) {
      // sign in with Google on web
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();

      try {
        final UserCredential userCredential =
        await firebaseAuth.signInWithPopup(googleProvider);

        user = userCredential.user;
        assert(user!.uid != null);

        userUid = user!.uid;

        print('Google User Uid => $userUid');
        if (!(await firestoreService.doesProfileExist(userUid))) {
          firestoreService.addProfile(user.displayName!, user.photoURL!);
        }
        return user;
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

        user = userCredential.user;
        assert(user!.uid != null);

        userUid = user!.uid;

        print('Google User Uid => $userUid');
        if (!(await firestoreService.doesProfileExist(userUid))) {
          firestoreService.addProfile(user.displayName!, user.photoURL!);
        }
      } catch (e) {
        print('Error signing in with Google on Android: $e');
      }
    }
    print(user);
    return user;

    notifyListeners();
  }


  Future onLogout(String signInMethod) async {
    print("LogOut successuffly ! ");
    return firebaseAuth.signOut();
  }
}
