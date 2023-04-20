import 'dart:math';

import 'package:cookingbook_app/screens/EmailVerificationDemo.dart';
import 'package:cookingbook_app/screens/HomeScreenDemo.dart';
import 'package:cookingbook_app/screens/LoginSuccessTest.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cookingbook_app/services/Authentication.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cookingbook_app/Utils/FirebaseConstants.dart';

class LoginScreenDemo extends StatefulWidget {
  @override
  _LoginScreenDemoState createState() => _LoginScreenDemoState();
}

class _LoginScreenDemoState extends State<LoginScreenDemo> {
  TextEditingController userEmailController = TextEditingController();
  TextEditingController userPassWordConfirmController = TextEditingController();
  TextEditingController userPasswordController = TextEditingController();
  Authentication auth = Authentication();
  late String signInMethod;

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: userEmailController,
                decoration: InputDecoration(
                  hintText: 'Enter email',
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: userPasswordController,
                decoration: InputDecoration(
                  hintText: 'Enter password',
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
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
                                child: LoginSuccessTest(
                                    signInMethod: signInMethod),
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
              SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to sign up page
                  signInSheet(context);
                },
                child: Text('Sign Up'),
              ),
              SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {
                  auth.signInWithGoogle().whenComplete(() {
                    setState(() {
                      signInMethod = "google";
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
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
                            child: LoginSuccessTest(signInMethod: signInMethod),
                            type: PageTransitionType.leftToRight));
                  });
                },
                child: Icon(
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
                decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.0),
                        topRight: Radius.circular(12.0))),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 150.0),
                      child: Divider(
                        thickness: 4.0,
                        color: Colors.white,
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 60.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: TextField(
                        controller: userEmailController,
                        decoration: InputDecoration(
                            hintText: 'Enter email...',
                            hintStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0)),
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: TextField(
                        controller: userPasswordController,
                        decoration: InputDecoration(
                            hintText: 'Enter password...',
                            hintStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0)),
                        style: TextStyle(
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
                        decoration: InputDecoration(
                          hintText: 'Re-type password...',
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                        obscureText: true,
                      ),
                    ),
                    _isLoading
                        ? CircularProgressIndicator()
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
                                      userEmail: userEmailController.text,
                                      password: userPasswordController.text,
                                      context: context);
                                  if (authFirebase.currentUser != null) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (ctx) =>
                                                const EmailVerificationScreen()));
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
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold)),
            ),
          );
        });
  }
}
