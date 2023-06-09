import 'package:cookingbook_app/screens/LoginScreenForm.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class StartingScreen extends StatefulWidget {
  @override
  _StartingScreenState createState() => _StartingScreenState();
}

class _StartingScreenState extends State<StartingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 118, 117, 117),
      body: GestureDetector(
        onTap: () => {
          Navigator.pushReplacement(
              context,
              PageTransition(
                  child: LoginScreenForm(),
                  type: PageTransitionType.leftToRight))
        },
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
            ),
            child: const Icon(
              Icons.people,
              size: 60,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
