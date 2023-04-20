import 'package:cookingbook_app/screens/AllRecetteDemo.dart';
import 'package:cookingbook_app/screens/HomeScreenDemo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:cookingbook_app/screens/LoginScreenDemo.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../models/Recette.dart';
import '../services/Authentication.dart';
import '../services/FireStoreService.dart';
import 'package:uuid/uuid.dart';

import 'AddNewRecetteDemo.dart';

class LoginSuccessTest extends StatefulWidget {
  final String signInMethod;

  LoginSuccessTest({required this.signInMethod});
  @override
  _LoginSuccessTestState createState() => _LoginSuccessTestState();
}

class _LoginSuccessTestState extends State<LoginSuccessTest> {
  Authentication auth = Authentication();
  FirestoreService firestoreService = FirestoreService();
  Uuid uuid = Uuid();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Home page"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                print(
                    "this is signInMethode in LoginSucessTest ${widget.signInMethod}");
                auth.onLogout(widget.signInMethod);
                Navigator.push(context,
                    MaterialPageRoute(builder: (ctx) => HomeScreenDemo()));
              },
              child: Icon(Icons.logout),
            ),
          ),
        ],
      ),
      body: Container(
        child: Column(children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black, // Set the border color here
                width: 2, // Set the border width here
              ),
              borderRadius:
                  BorderRadius.circular(8), // Set the border radius here
            ),
            child: MaterialButton(
              child: Text(
                "add new recette",
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (ctx) => AddNewRecetteDemo()));
              },
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black, // Set the border color here
                width: 2, // Set the border width here
              ),
              borderRadius:
                  BorderRadius.circular(8), // Set the border radius here
            ),
            child: MaterialButton(
              child: Text(
                "my recette",
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (ctx) => const AllRecetteDemo()));
              },
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black, // Set the border color here
                width: 2, // Set the border width here
              ),
              borderRadius:
                  BorderRadius.circular(8), // Set the border radius here
            ),
            child: MaterialButton(
              child: Text(
                "my favoris",
              ),
              onPressed: () {
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (ctx) => AddNewRecetteDemo()));
              },
            ),
          ),
        ]),
      ),
    );
  }
}
