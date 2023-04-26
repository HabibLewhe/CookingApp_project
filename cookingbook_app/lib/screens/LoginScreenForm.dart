import 'package:cookingbook_app/screens/EmailVerification.dart';
import 'package:cookingbook_app/screens/UserAccountPage.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:cookingbook_app/services/Authentication.dart';
import 'package:page_transition/page_transition.dart';
import 'package:cookingbook_app/Utils/FirebaseConstants.dart';

import '../models/Profile.dart';
import '../services/FireStoreService.dart';
import 'Home.dart';

class LoginScreenForm extends StatefulWidget {
  @override
  _LoginScreenFormState createState() => _LoginScreenFormState();
}

class _LoginScreenFormState extends State<LoginScreenForm> {
  TextEditingController userEmailController = TextEditingController();
  TextEditingController pseudoNomController = TextEditingController();
  TextEditingController userPassWordConfirmController = TextEditingController();
  TextEditingController userPasswordController = TextEditingController();
  Authentication auth = Authentication();
  late String signInMethod;

  bool _isLoading = false;

  FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: userEmailController,
                decoration: const InputDecoration(
                  hintText: 'Enter email',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: userPasswordController,
                decoration: const InputDecoration(
                  hintText: 'Enter password',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  if (userEmailController.text.isNotEmpty &&
                      userPasswordController.text.isNotEmpty) {
                    auth
                        .logIntoAccount(userEmailController.text,
                            userPasswordController.text)
                        .then((success) {
                      if (success) {
                        setState(() {
                          signInMethod = "emailPassword";
                        });
                        Navigator.pushReplacement(
                            context,
                            PageTransition(
                                child:
                                    UserAccountPage(signInMethod: signInMethod),
                                type: PageTransitionType.bottomToTop));
                      }
                    }).catchError((error) {
                      if (error.code == 'user-not-found') {
                        warningText(context, "User not found");
                      } else if (error.code == 'wrong-password') {
                        warningText(context, "Wrong Password");
                      }
                    });
                  } else {
                    warningText(context, 'Fill all the champ !');
                  }
                },
                child: Text('Log In'),
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to sign up page
                  signInSheet(context);
                },
                child: const Text('Sign Up'),
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {
                  auth.signInWithGoogle().whenComplete(() async {
                    setState(() {
                      signInMethod = "google";
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Center(
                            child: Text(
                          "Login succes with Google Account ! ",
                          textAlign: TextAlign.center,
                        )),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );

                    Navigator.pushReplacement(
                        context,
                        PageTransition(
                            child: Home(
                                signInMethod: signInMethod),
                            type: PageTransitionType.leftToRight));
                  });
                },
                child: const Icon(
                  EvaIcons.google,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  signInSheet(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
                height: MediaQuery.of(context).size.height * 0.50,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.0),
                        topRight: Radius.circular(12.0))),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: TextField(
                        controller: pseudoNomController,
                        decoration: const InputDecoration(
                            hintText: 'Enter pseudo...',
                            hintStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0)),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: TextField(
                        controller: userEmailController,
                        decoration: const InputDecoration(
                            hintText: 'Enter email...',
                            hintStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0)),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: TextField(
                        controller: userPasswordController,
                        decoration: const InputDecoration(
                            hintText: 'Enter password...',
                            hintStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0)),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0),
                        obscureText: true,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: TextField(
                        controller: userPassWordConfirmController,
                        decoration: const InputDecoration(
                          hintText: 'Re-type password...',
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                        obscureText: true,
                      ),
                    ),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                _isLoading = true;
                              });
                              if (userEmailController.text.isNotEmpty &&
                                  userPasswordController.text.isNotEmpty &&
                                  userPassWordConfirmController
                                      .text.isNotEmpty) {
                                if (userPasswordController.text ==
                                    userPassWordConfirmController.text) {
                                  await auth.signUp(
                                    pseudoNom: pseudoNomController.text,
                                      userEmail: userEmailController.text,
                                      password: userPasswordController.text,
                                      context: context);
                                  if (authFirebase.currentUser != null) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                EmailVerificationScreen()));
                                  }
                                } else {
                                  warningText(context,
                                      "Passwords do not match , re-type please");
                                }
                              } else {
                                warningText(context, "Fill the champ");
                              }
                              setState(() {
                                _isLoading = false;
                              });
                            },
                            child: Text("Sign Up"),
                          ),
                  ],
                )),
          );
        });
  }

  warningText(BuildContext context, String warning) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
                color: Colors.black, borderRadius: BorderRadius.circular(15.0)),
            height: MediaQuery.of(context).size.height * 0.1,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Text(warning,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold)),
            ),
          );
        });
  }
}
