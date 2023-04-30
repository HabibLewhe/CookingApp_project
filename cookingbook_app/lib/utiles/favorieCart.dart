import 'dart:async';

import 'package:cookingbook_app/models/Profile.dart';
import 'package:cookingbook_app/models/Recette.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../color.dart';
import '../services/FireStoreService.dart';




class FavorieCart extends StatefulWidget {
  final Recette recette;
  final Profile profile;
  final VoidCallback onTap;

  FavorieCart(
      {Key? key,
      required this.recette,
      required this.profile,
      required this.onTap})
      : super(key: key);

  FirestoreService _firestoreService = FirestoreService();
  User? user = FirebaseAuth.instance.currentUser;


  @override
  State<StatefulWidget> createState() {
    return _ExploreCartStat();
  }
}


class _ExploreCartStat extends State<FavorieCart> {

    @override
    void initState() {
      myProfileRealTime = null;
      getMyProfileRealTime();
      super.initState();
    }

    FirestoreService firestoreService = FirestoreService();
    late Profile? myProfileRealTime = null;
    StreamSubscription<Profile>? _myProfileRealTimeSubscription;
    StreamSubscription<List<Recette>>? _allRecettesRealTimeSubscription;

    Future<void> getMyProfileRealTime() async {
      Stream<Profile> stream = firestoreService.getCurrentUserProfileRealTime();
      _myProfileRealTimeSubscription = stream.listen((Profile profile) {
        setState(() {
          myProfileRealTime = profile;
        });
      });
    }





  @override
  Widget build(BuildContext context) {
    return  Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Stack(
                children: [
                  SizedBox(
                    height: 130,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 130,
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Container(
                                  height: 120,
                                  width: 110,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      image: DecorationImage(
                                          image: NetworkImage(
                                            widget.recette.image,
                                          ),
                                          fit: BoxFit.cover)),
                                ),
                                SizedBox(
                                  width:
                                  MediaQuery.of(context).size.width * 0.6,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.only(
                                                      top: 8.0, left: 8),
                                                  child: Text(
                                                    widget.recette.nom,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        color: textColor,
                                                        fontSize: 16),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.only(
                                                      left: 8.0),
                                                  child: Text(
                                                    widget.recette.categorie,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                        FontWeight.w500,
                                                        color: inActiveColor,
                                                        fontSize: 16),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 18,
                                        ),
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 16,
                                              backgroundImage: NetworkImage(
                                                  widget.profile.imageAvatar),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    "Chef",
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: textColor),
                                                  ),
                                                  Text(
                                                    widget.profile.pseudo,
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        color: labelColor),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                      top: 20,
                      right: 20,
                      child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              border: Border.all(color: primary ),
                              color: widget.recette.likeur.contains(myProfileRealTime?.idProfile) ?  primary : appBgColor    ,
                              borderRadius: BorderRadius.circular(30)),
                          child: IconButton(
                            onPressed: () {
                              widget.onTap();
                              if(widget.recette.likeur.contains(myProfileRealTime?.idProfile)) {
                                firestoreService.updateRecetteLikeur(
                                    widget.recette.idRecette, false);
                                firestoreService.updateProfileLikedRecette(
                                    myProfileRealTime!.idProfile,
                                    widget.recette.idRecette, false);
                                setState(() {
                                  widget.recette.likeur.remove(myProfileRealTime?.idProfile);
                                });
                              }else{
                                firestoreService.updateRecetteLikeur(
                                    widget.recette.idRecette, true);
                                firestoreService.updateProfileLikedRecette(
                                    myProfileRealTime!.idProfile,
                                    widget.recette.idRecette, true);
                                setState(() {
                                  String id = myProfileRealTime?.idProfile ?? "";
                                  widget.recette.likeur.add(id);
                                });
                              }
                            },
                            icon: SvgPicture.asset(
                              "assets/icons/bookmark.svg",
                              color: widget.recette.likeur.contains(myProfileRealTime?.idProfile) ?  appBgColor : primary      ,
                            ),
                          ))),


                  Positioned(
                      right: 20,
                      bottom: 20,
                      child: Container(
                        height: 25,
                        width: 50,
                        decoration: BoxDecoration(
                            color: primary,
                            borderRadius: BorderRadius.circular(6)),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.star,
                                size: 15,
                                color: Colors.black,
                              ),
                              Text(widget.recette.nbPersonne),
                            ],
                          ),
                        ),
                      ))
                ],
              ),
            ));
  }
}