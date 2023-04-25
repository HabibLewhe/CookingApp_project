import 'package:cookingbook_app/login/login.dart';
import 'package:cookingbook_app/screens/LoginScreenDemo.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class HomeScreenDemo extends StatefulWidget {
  @override
  _HomeScreenDemoState createState() => _HomeScreenDemoState();
}

class _HomeScreenDemoState extends State<HomeScreenDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 118, 117, 117),
      body: GestureDetector(
        onTap: () => {
          Navigator.pushReplacement(
              context,
              PageTransition(
                  child: MyLogin(),
                  type: PageTransitionType.leftToRight))
        },
        child: Center(
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
            ),
            child: Icon(
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
