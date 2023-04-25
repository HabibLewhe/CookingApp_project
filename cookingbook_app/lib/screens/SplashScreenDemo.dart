import 'dart:async';

import 'package:cookingbook_app/screens/HomeScreenDemo.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class SplashscreenDemo extends StatefulWidget {
  @override
  _SplashscreenState createState() => _SplashscreenState();
}

class _SplashscreenState extends State<SplashscreenDemo> {
  @override
  void initState() {
    Timer(
        Duration(seconds: 1),
        () => Navigator.pushReplacement(
            context,
            PageTransition(
                child: HomeScreenDemo(),
                type: PageTransitionType.leftToRight)));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
          child: RichText(
        text: TextSpan(
            text: 'the',
            style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 30.0),
            children: <TextSpan>[
              TextSpan(
                text: 'Cooking',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 34.0),
              ),
              TextSpan(
                text: 'Book',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 34.0),
              )
            ]),
      )),
    );
  }
}
