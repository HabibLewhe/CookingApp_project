import 'package:cookingbook_app/screens2/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import '../screens2/home.dart';
import '../services/Authentication.dart';
import 'register.dart';

class MyLogin extends StatefulWidget {
  const MyLogin({Key? key}) : super(key: key);
  @override
  _MyLoginState createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  Authentication auth = Authentication();
  TextEditingController userEmailController = TextEditingController();
  TextEditingController userPasswordController = TextEditingController();
  late String signInMethod;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/images/login.png'), fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(children: [
          Container(
            padding: const EdgeInsets.only(left: 35, top: 80),
            child: const Text(
              "Welcome\nBack",
              style: TextStyle(color: Colors.white, fontSize: 33),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                  right: 35,
                  left: 35,
                  top: MediaQuery.of(context).size.height * 0.5),
              child: Column(children: [
                TextField(
                  controller: this.userEmailController,
                  decoration: InputDecoration(
                    fillColor: Colors.grey.shade100,
                    filled: true,
                    hintText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                TextField(
                  obscureText: true,
                  controller: userPasswordController,
                  decoration: InputDecoration(
                    fillColor: Colors.grey.shade100,
                    filled: true,
                    hintText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sign In',
                      style: TextStyle(
                        color: Color(0xff4c505b),
                        fontSize: 27,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color(0xff4c505b),
                      child: IconButton(
                        color: Colors.white,
                        onPressed: () {
                        if (userEmailController.text.isNotEmpty && userPasswordController.text.isNotEmpty) {

                          auth.logIntoAccount(userEmailController.text,userPasswordController.text).then((success) {
                          if (success) {
                            setState(() {
                            signInMethod = "emailPassword";
                            });
                            Navigator.pushReplacement(
                            context,PageTransition(
                            child: Home(signInMethod: signInMethod),
                            type: PageTransitionType.bottomToTop));}
                          }).catchError((error) {
                              if (error.code == 'user-not-found') {
                                    warningText(context, "Utilisateur introuvable");
                              } else if (error.code == 'wrong-password') {
                                      warningText(context, "Mot de passe erroné");
                              } else {
                                      warningText(context, "Erreur de connexion");
                              }
                          });
                           } else {
                                    warningText(context, 'Veuillez remplir tous champs !');}
                        },
                        icon: const Icon(Icons.arrow_forward),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              PageTransition(
                                  child:  MyRegister(),
                                  type: PageTransitionType.leftToRightJoined,
                                  childCurrent: this.widget,
                                  duration: const Duration(milliseconds: 1000)));

                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 18,
                            color: Color(0xff4c505b),
                          ),
                        ),
                      ),

                    ]),
              ]),
            ),
          ),
        ]),
      ),
    );
  }



  warningText(BuildContext context, String warning) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(15.0)),
            height: MediaQuery.of(context).size.height * 0.1,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Text(warning,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold)),
            ),
          );
        });
  }
}
