import 'package:cookingbook_app/screens/_AddNewRecetteDemoOld.dart';
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

  // Define the addRecetteToFirestore function
  Future<void> addRecetteToFirestore(Recette recette) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      recette.idUser = user.uid;
      recette.idRecette = uuid.v4();
      await firestoreService.addRecette(recette);
    }
  }

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
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black, // Set the border color here
            width: 4, // Set the border width here
          ),
          borderRadius: BorderRadius.circular(8), // Set the border radius here
        ),
        child: MaterialButton(
          child: Text(
            "add new recette",
          ),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (ctx) => AddNewRecetteDemo()));

            // Recette pizza = Recette(
            //   idUser:
            //       '', // This will be set by the addRecetteToFirestore function
            //   idRecette:
            //       '', // This will be set by the addRecetteToFirestore function
            //   image:
            //       'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxleHBsb3JlLWZlZWR8NXx8fGVufDB8fHx8&w=1000&q=80',
            //   nom: 'Pizza',
            //   tempsPreparation: Duration(minutes: 30),
            //   nbPersonne: 4,
            //   instruction:
            //       '1. Preheat oven to 450 degrees F (230 degrees C).\n2. Roll out dough, add sauce and toppings.\n3. Bake for 15-20 minutes.',
            //   ingredients: {
            //     'dough': '1 lb pizza dough',
            //     'sauce': '1 cup tomato sauce',
            //     'cheese': '2 cups shredded mozzarella cheese',
            //     'toppings': 'pepperoni, mushrooms, onions, bell peppers'
            //   },
            // );

            // addRecetteToFirestore(pizza);
          },
        ),
      ),
    );
  }
}
