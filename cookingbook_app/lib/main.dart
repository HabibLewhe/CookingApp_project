import 'package:cookingbook_app/screens/HomeScreenDemo.dart';
import 'package:firebase_core/firebase_core.dart';
import '/firebase_options.dart';

import 'package:flutter/material.dart';

import 'login/login.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await firebaseInitialization;
//   // await Firebase.initializeApp(
//   //   options: DefaultFirebaseOptions.currentPlatform,
//   // );
//   runApp(const MyApp());
// }
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // if (kIsWeb) {
  //   await Firebase.initializeApp(
  //       options: FirebaseOptions(
  //           apiKey: "AIzaSyCOBy3chI6rCGpHMoBCZKFRO4wPWm3n07I",
  //           appId: "1:139311884130:web:c2f22f5bb5914c44b3ee3b",
  //           messagingSenderId: "139311884130",
  //           projectId: "multidev-cookingbook",
  //           authDomain: "multidev-cookingbook.firebaseapp.com",
  //           storageBucket: "multidev-cookingbook.appspot.com",
  //           measurementId: "G-WE0532PT92"));
  // } else {
  //   await Firebase.initializeApp();
  // }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   //await firebaseInitialization;
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(MyApp());
// }

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
      home: MyLogin(),
      debugShowCheckedModeBanner: false,
    );
  }
}
