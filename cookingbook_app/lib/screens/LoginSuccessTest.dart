import 'package:cookingbook_app/screens/HomeScreenDemo.dart';
import 'package:flutter/material.dart';

import 'package:cookingbook_app/screens/LoginScreenDemo.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class LoginSuccessTest extends StatefulWidget {
  @override
  _LoginSuccessTestState createState() => _LoginSuccessTestState();
}

class _LoginSuccessTestState extends State<LoginSuccessTest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Center(
          child: GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (ctx) => HomeScreenDemo()));
            },
            child: Text("click to log out"),
          ),
        ),
      ),
    );
  }
}
