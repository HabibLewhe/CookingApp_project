import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import '../color.dart';
import '../models/Profile.dart';
import '../models/Recette.dart';
import '../screens/OtherAccountPage.dart';
import '../screens/UserAccountPage.dart';


class Popularcart extends StatelessWidget {
  final Recette recette;
  final Profile profile;
  final VoidCallback onTap;

  Popularcart(
      {Key? key,
        required this.recette,
        required this.profile,
        required this.onTap})
      : super(key: key);


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap  ,
        child:        Padding(
        padding: const EdgeInsets.all(7.0),
    child:Stack(
      alignment: Alignment.center,
      children: [

        Container(
          height: 250,
          width: MediaQuery.of(context).size.width * 0.56,
          decoration: BoxDecoration(
           
            borderRadius: BorderRadius.circular(15),
            image:  DecorationImage(
                image: NetworkImage(recette.image),
                fit: BoxFit.cover),
          ),
        ),

        Positioned(
            bottom: 10,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(left:8.0,right: 8),
                child: Container(
                  height: 90,
                  width: MediaQuery.of(context).size.width * 0.52,
                  decoration: BoxDecoration(
                      color: cardColor, borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                           [
                             Text(recette.nom,style: const TextStyle(fontSize: 16,),),
                            const SizedBox(height: 7,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children:  [
                                Row(
                                  children: [GestureDetector(
                                    onTap: () {
                                      User? user = FirebaseAuth.instance.currentUser;
                                      if (user!.uid ==profile.idProfile) {
                                        Navigator.push(context, PageTransition(child: UserAccountPage(), type: PageTransitionType.leftToRight));
                                      } else {
                                        Navigator.push(context, PageTransition(child: OtherAccountPage(idProfile: profile.idProfile,), type: PageTransitionType.leftToRight));
                                      }
                                    },
                                    child: CircleAvatar(
                                      radius: 16,
                                      backgroundImage: NetworkImage(profile.imageAvatar),
                                    )),
                                    Padding(
                                      padding: const EdgeInsets.only(left:8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children:  [
                                          Text(profile.pseudo,style: TextStyle(fontSize: 14,color: textColor),),
                                          Text("Chef",style: TextStyle(fontSize: 12,color: labelColor),)
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  height: 25,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: primary,
                                    borderRadius: BorderRadius.circular(6)

                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children:  [
                                        Icon(Icons.star,size: 15,color: Colors.black,),
                                        Text(recette.nbPersonne.toString(),style: TextStyle(fontSize: 12,color: Colors.black),)
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                ),
              ),
            ))
      ],
    )));
  }
}
