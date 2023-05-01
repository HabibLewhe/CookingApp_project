import 'dart:async';

import 'package:cookingbook_app/screens/OtherAccountPage.dart';
import 'package:cookingbook_app/services/FireStoreService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:velocity_x/velocity_x.dart';

import '../Utils/color.dart';
import '../models/Commentaire.dart';
import '../models/Profile.dart';
import '../models/Recette.dart';
import '../utiles/commantaireW.dart';
import 'UserAccountPage.dart';

class CommentairesPage extends StatefulWidget {
  Recette recette;
  String idProfileCreeRecette; // qui a cree la recette
  CommentairesPage({
    Key? key,
    required this.recette,
    required this.idProfileCreeRecette,
  }) : super(key: key);

  @override
  _CommentairesPageState createState() => _CommentairesPageState();
}

class _CommentairesPageState extends State<CommentairesPage> {
  late Recette recette;
  late String idProfileCreeRecette;
  late Profile myCurrentProfile;
  late List<Recette> sesRecetteRealTime;
  StreamSubscription<Profile>? _myProfileRealTimeSubscription;
  StreamSubscription<Map<Profile, Commentaire>>? _commentaireMapSubscription;
  StreamSubscription<List<Recette>>? myRecetteSubcription;
  FirestoreService firestoreService = FirestoreService();
  StreamSubscription<List<Recette>>? _sesRecetteRealTimeSubscription;
  TextEditingController _commentaireController = TextEditingController();
  late List<Recette> myRecette;
  late Map<Profile, Commentaire> commentaireMap;

  Future<void> getCommentaireMap() async {
    Stream<Map<Profile, Commentaire>> stream =
        firestoreService.getCommentaires(recette.idRecette);
    _commentaireMapSubscription =
        stream.listen((Map<Profile, Commentaire> commentaires) {
      setState(() {
        commentaireMap = commentaires;
      });
    });
  }

  Future<void> getMyProfileRealTime() async {
    Stream<Profile> stream = firestoreService.getCurrentUserProfileRealTime();
    _myProfileRealTimeSubscription = stream.listen((Profile profile) {
      setState(() {
        myCurrentProfile = profile;
      });
    });
  }

  Future<void> getSesRecettesRealTime() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user!.uid != idProfileCreeRecette) {
      Stream<List<Recette>> stream =
          firestoreService.getSesRecettesRealTime(idProfileCreeRecette);
      _sesRecetteRealTimeSubscription = stream.listen((List<Recette> recettes) {
        setState(() {
          sesRecetteRealTime = recettes;
        });
      });
    } else {
      setState(() {
        sesRecetteRealTime = [];
      });
    }
  }

  Future<void> getMyRecettes() async {
    Stream<List<Recette>> stream = firestoreService.getRecettesRealTime();
    myRecetteSubcription = stream.listen((List<Recette> recettes) {
      setState(() {
        myRecette = recettes;
      });
    });
  }

  @override
  void initState() {
    recette = widget.recette;
    idProfileCreeRecette = widget.idProfileCreeRecette;
    commentaireMap = {};
    getMyProfileRealTime();
    getSesRecettesRealTime();
    getCommentaireMap();
    getMyRecettes();
    super.initState();
  }

  @override
  void dispose() {
    _commentaireMapSubscription?.cancel();
    _myProfileRealTimeSubscription?.cancel();
    _sesRecetteRealTimeSubscription?.cancel();
    myRecetteSubcription?.cancel();
    super.dispose();
  }

  AlertDialog showAlertDialog(BuildContext context, String idCommentaire) {
    AlertDialog alert = AlertDialog(
      title: const Text('Confirmation', style: TextStyle(color: primary, fontWeight: FontWeight.bold)),
      content: const Text('Voulez-vous supprimer ce commentaire ?'),
      //make corners with radius of 40
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),

      actions: [
        TextButton(
          child: const Text(
            'Annuler',
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text(
            'Confirmer',
            style: TextStyle(color: Colors.green),
          ),
          onPressed: () async {
            firestoreService.deleteCommentaire(idCommentaire);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
    return alert;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bottomBarColor,
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text('Commentaires'),
        centerTitle: true,
      ),
      body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder<Map<Profile, Commentaire>>(
                    stream: firestoreService.getCommentaires(recette.idRecette),
                    builder: (context, snapshot) {

                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator(
                          color: primary,
                        );
                      }

                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      final commentList = snapshot.data!.entries.toList();

                      return Expanded(
                        child: ListView.builder(
                          itemCount: commentList.length,
                          itemBuilder: (BuildContext context, int index) {
                            Profile profileCmt = commentList[index].key;
                            Commentaire cmt = commentList[index].value;
                            DateTime now = DateTime.now(); // Get the current time
                            Duration difference = now.difference(cmt.dateTime); // Calculate the difference
                            String timeDiff = "";
                            if (difference.inHours == 0) {
                              timeDiff = "${difference.inMinutes}m";
                            } else if (difference.inHours >= 24) {
                              timeDiff = "${difference.inDays}j";
                            } else {
                              timeDiff = "${difference.inHours}h";
                            }
                            return GestureDetector(
                              onLongPress: () {
                                //si le commentaire est de moi, je peux le supprimer
                                if(myCurrentProfile.idProfile == profileCmt.idProfile){
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return showAlertDialog(context, cmt.idCommentaire);
                                    },
                                  );
                                }
                              },
                              child: CommentaireW(
                                profil: profileCmt,
                                commentaire: cmt,
                                date: timeDiff,
                              ),

                            );
                          },
                        ),
                      );
                    }),
                Container(
                  //Commentaire
                  width: 450,
                  height: 50,
                  decoration: BoxDecoration(
                    //thikness: 1,
                      border: Border.all(color: primary,width: 2),
                      borderRadius: BorderRadius.circular(25)
                  ),
                  child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                              controller: _commentaireController,
                              decoration: const InputDecoration.collapsed(hintText: "ajouter un commentaire ...")
                          ),
                        ),
                        IconButton(
                            onPressed: (){
                                  Commentaire cmt = Commentaire(
                                  idUser: myCurrentProfile.idProfile,
                                  content: _commentaireController.text,
                                  idRecette: recette.idRecette,
                                  idCommentaire: '',
                                  dateTime: DateTime.now());
                                  firestoreService.addCommentaire(cmt, recette);
                                  _commentaireController.clear();
                                },
                            icon: const Icon(Icons.send, color: primary, size: 30,)
                        )
                      ]
                  ).px16(),
                ),
              ],
            ),
    );
  }
}
