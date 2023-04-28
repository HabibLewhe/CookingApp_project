import 'dart:async';

import 'package:cookingbook_app/screens/OtherAccountPage.dart';
import 'package:cookingbook_app/services/FireStoreService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../models/Commentaire.dart';
import '../models/Profile.dart';
import '../models/Recette.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
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
                          color: Colors.transparent,
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
                            DateTime now =
                                DateTime.now(); // Get the current time
                            Duration difference = now.difference(
                                cmt.dateTime); // Calculate the difference
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
                                //delete

                                myCurrentProfile.idProfile !=
                                        profileCmt.idProfile
                                    ? ""
                                    : showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Confirmation'),
                                            content: const Text(
                                                'Are you sure that you want to delete this comment?'),
                                            actions: [
                                              TextButton(
                                                child: const Text('Cancel'),
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                              ),
                                              TextButton(
                                                child: const Text('Confirm'),
                                                onPressed: () async {
                                                  firestoreService
                                                      .deleteCommentaire(
                                                          cmt.idCommentaire);
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                              },
                              child: Card(
                                child: ListTile(
                                    trailing: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        child: Row(children: [
                                          SizedBox(
                                            height: 35,
                                            width: 35,
                                            child: GestureDetector(
                                              onTap: () {
                                                User? user = FirebaseAuth
                                                    .instance.currentUser;
                                                if (user!.uid ==
                                                    profileCmt.idProfile) {
                                                  Navigator.pushReplacement(
                                                      context,
                                                      PageTransition(
                                                          child:
                                                              UserAccountPage(),
                                                          type:
                                                              PageTransitionType
                                                                  .leftToRight));
                                                } else {
                                                  Navigator.pushReplacement(
                                                      context,
                                                      PageTransition(
                                                          child:
                                                              OtherAccountPage(
                                                            idProfile:
                                                                profileCmt
                                                                    .idProfile,
                                                          ),
                                                          type:
                                                              PageTransitionType
                                                                  .leftToRight));
                                                }
                                              },
                                              child: Image.network(
                                                  profileCmt.imageAvatar),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 4,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "${profileCmt.pseudo}:",
                                                  style: const TextStyle(
                                                      color: Colors.blue,
                                                  fontSize: 20),
                                                ),
                                                Text(
                                                  timeDiff,
                                                  style:
                                                      const TextStyle(fontSize: 13),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 4,
                                          ),
                                          Flexible(
                                            flex: 10,
                                            fit: FlexFit.tight,
                                            child: Text(
                                              cmt.content,
                                              style: const TextStyle(
                                                  color: Colors.black87,
                                              fontSize: 18),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 20,
                                          )
                                        ]))),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                Container(
                  //Commentaire
                  width: 450,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.grey[300],
                  ),
                  child: Row(children: [
                    const SizedBox(
                      width: 16,
                    ),
                    SizedBox(
                      width: 300,
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'ajouter un commentaire ...',
                        ),
                        controller: _commentaireController,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    ),
                    const SizedBox(
                      width: 65,
                    ),
                    GestureDetector(
                      onTap: () {
                        Commentaire cmt = Commentaire(
                            idUser: myCurrentProfile.idProfile,
                            content: _commentaireController.text,
                            idRecette: recette.idRecette,
                            idCommentaire: '',
                            dateTime: DateTime.now());
                        firestoreService.addCommentaire(cmt, recette);
                        _commentaireController.clear();
                      },
                      child: const Icon(
                        Icons.send,
                        size: 25,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ]),
                ),
              ],
            ),
    );
  }
}
