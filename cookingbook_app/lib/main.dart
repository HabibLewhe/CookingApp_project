import 'package:cookingbook_app/screens/SplashScreenDemo.dart';
import 'package:cookingbook_app/Utils/FirebaseConstants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/firebase_options.dart';

import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await firebaseInitialization;
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        accentColor: Colors.blue,
        fontFamily: 'Poppins',
        canvasColor: Colors.transparent,
        primarySwatch: Colors.blue,
      ),
      home: Splashscreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
