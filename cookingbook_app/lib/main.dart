import 'package:cookingbook_app/login/login.dart';
import 'package:cookingbook_app/screens/LoginScreenForm.dart';
import 'package:cookingbook_app/screens/SplashScreen.dart';
import 'package:cookingbook_app/services/Authentication.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import '/firebase_options.dart';

import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    print("MyApp build");
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Authentication())
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          canvasColor: Colors.transparent,
          primarySwatch: Colors.blue,
        ),
        home: LoginScreenForm(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
