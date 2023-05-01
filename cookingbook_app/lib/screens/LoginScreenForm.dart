import 'package:cookingbook_app/screens/EmailVerification.dart';
import 'package:cookingbook_app/screens/UserAccountPage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cookingbook_app/services/Authentication.dart';
import 'package:page_transition/page_transition.dart';
import 'package:cookingbook_app/Utils/FirebaseConstants.dart';

import '../screens2/home.dart';


class LoginScreenForm extends StatefulWidget {
  @override
  _LoginScreenFormState createState() => _LoginScreenFormState();
}

class _LoginScreenFormState extends State<LoginScreenForm> {
  TextEditingController userEmailController = TextEditingController();
  TextEditingController pseudoNomController = TextEditingController();
  TextEditingController userPassWordConfirmController = TextEditingController();
  TextEditingController userPasswordController = TextEditingController();
  Authentication auth = Authentication();
  late String signInMethod;

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
        image: DecorationImage(
        image: AssetImage('assets/images/login.png'), fit: BoxFit.cover),
    ),
    child:Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50))),
                padding: const EdgeInsets.all(16.0),
                child: RichText(
                  text: const TextSpan(
                      text: 'the',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          fontSize: 30.0),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Cooking',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              fontSize: 34.0),
                        ),
                        TextSpan(
                          text: 'Book',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              fontSize: 34.0),
                        )
                      ]),
                ),
              ),
              const SizedBox(
                height: 26,
              ),
              TextFormField(
                controller: userEmailController,
                decoration: InputDecoration(
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepOrange),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.deepOrange,
                    ),
                  ),
                  prefixIcon: const Icon(
                    Icons.email,
                    color: Colors.deepOrange,
                  ),
                  labelStyle: const TextStyle(color: Colors.deepOrange),
                  labelText: 'Email',
                  fillColor: Colors.orange.shade50,
                  filled: true,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: userPasswordController,
                decoration: InputDecoration(
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepOrange),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.deepOrange,
                    ),
                  ),
                  prefixIcon: const Icon(
                    Icons.lock,
                    color: Colors.deepOrange,
                  ),
                  labelStyle: const TextStyle(color: Colors.deepOrange),
                  labelText: 'Mot de passe',
                  fillColor: Colors.orange.shade50,
                  filled: true,
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (userEmailController.text.isNotEmpty &&
                          userPasswordController.text.isNotEmpty) {
                        auth
                            .logIntoAccount(userEmailController.text,
                                userPasswordController.text)
                            .then((success) {
                          if (success) {
                            setState(() {
                              signInMethod = "emailPassword";
                            });
                            Navigator.pushReplacement(
                                context,
                                PageTransition(
                                    child:
                                      Home( signInMethod: signInMethod),
                                    type: PageTransitionType.bottomToTop));
                          }
                        }).catchError((error) {
                          if (error.code == 'user-not-found') {
                            warningText(context, "Utilisateur introuvable");
                          } else if (error.code == 'wrong-password') {
                            warningText(context, "Mot de passe erroné");
                          }
                        });
                      } else {
                        warningText(context, 'Veuillez remplir tous champs !');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange),
                    child: const Text('Se connecter'),
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              const Text(
                "Vous n'avez pas de compte ?",
              ),
              RichText(
                  text: TextSpan(
                      text: "S'inscrire",
                      style: const TextStyle(
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange),
                      recognizer: TapGestureRecognizer()..onTap = () {
                        // Navigate to sign up page
                        signInSheet(context);
                      })),
            ],
          ),
        ),
      ),
    ));
  }

  signInSheet(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom
            ),
            child: Expanded(
              child: Container(
                  height: MediaQuery.of(context).size.height * 0.60,
                  width: MediaQuery.of(context).size.width,
                  padding:
                      const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12.0),
                          topRight: Radius.circular(12.0))),
                  child: Column(
                    children: [
                      TextField(
                        controller: pseudoNomController,
                        decoration: InputDecoration(
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepOrange),
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.deepOrange,
                            ),
                          ),
                          prefixIcon: const Icon(
                            Icons.person,
                            color: Colors.deepOrange,
                          ),
                          fillColor: Colors.orange.shade50,
                          filled: true,
                          labelText: "Nom d'utilisateur",
                          labelStyle: const TextStyle(color: Colors.deepOrange),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: userEmailController,
                        decoration: InputDecoration(
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.deepOrange,
                            ),
                          ),
                          prefixIcon: const Icon(
                            Icons.email,
                            color: Colors.deepOrange,
                          ),
                          labelStyle: const TextStyle(color: Colors.deepOrange),
                          labelText: 'Email',
                          fillColor: Colors.orange.shade50,
                          filled: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: userPasswordController,
                        decoration: InputDecoration(
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepOrange),
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.deepOrange,
                            ),
                          ),
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Colors.deepOrange,
                          ),
                          labelStyle: const TextStyle(color: Colors.deepOrange),
                          labelText: 'Mot de passe',
                          fillColor: Colors.orange.shade50,
                          filled: true,
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: userPassWordConfirmController,
                        decoration: InputDecoration(
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepOrange),
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.deepOrange,
                            ),
                          ),
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Colors.deepOrange,
                          ),
                          labelStyle: const TextStyle(color: Colors.deepOrange),
                          labelText: 'Confirmer le mot de passe',
                          fillColor: Colors.orange.shade50,
                          filled: true,
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  _isLoading = true;
                                });
                                if (userEmailController.text.isNotEmpty &&
                                    userPasswordController.text.isNotEmpty &&
                                    userPassWordConfirmController.text.isNotEmpty) {
                                  if (userPasswordController.text ==
                                      userPassWordConfirmController.text) {
                                    await auth.signUp(
                                        pseudoNom: pseudoNomController.text,
                                        userEmail: userEmailController.text,
                                        password: userPasswordController.text,
                                        context: context);
                                    if (authFirebase.currentUser != null) {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  EmailVerificationScreen()));
                                    }
                                  } else {
                                    warningText(context,
                                        "Mots de passe incompatibles , recommencer");
                                  }
                                } else {
                                  warningText(context, "Veuillez remplir tous champs");
                                }
                                setState(() {
                                  _isLoading = false;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepOrange),
                              child: const Text("Valider"),
                            ),
                    ],
                  )),
            ),
          );
        });
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
