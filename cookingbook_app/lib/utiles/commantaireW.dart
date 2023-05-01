import 'package:cookingbook_app/models/Commentaire.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import '../color.dart';
import '../models/Profile.dart';
import '../screens/OtherAccountPage.dart';
import '../screens/UserAccountPage.dart';

class CommentaireW extends StatelessWidget {
  final Profile profil;
  final String date;
  final Commentaire commentaire;
  const CommentaireW({Key? key, required this.profil, required this.date, required this.commentaire}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: SizedBox(
            height: 80,
            width: MediaQuery.of(context).size.width ,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: GestureDetector(
                    onTap: () {
                      User? user = FirebaseAuth.instance.currentUser;
                      if (user!.uid == profil.idProfile) {
                        Navigator.pushReplacement(context, PageTransition(child: UserAccountPage(), type: PageTransitionType.leftToRight));
                      } else {
                        Navigator.pushReplacement(context, PageTransition(child: OtherAccountPage(idProfile: profil.idProfile,), type: PageTransitionType.leftToRight));
                      }
                    },
                    child: Container(
                    height: 100,
                    width: 90,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        image:  DecorationImage(
                            image: NetworkImage(profil.imageAvatar),
                            fit: BoxFit.cover)),
                  )),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:  [
                          Text(
                            profil.pseudo,
                            style: const TextStyle(color: textColor, fontSize: 16),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              commentaire.content,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w300,
                                  color: inActiveColor,
                                  fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 25,
                        width: 50,
                        decoration: BoxDecoration(
                            color: primary,
                            borderRadius: BorderRadius.circular(6)),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:  [
                              Icon(
                                Icons.calendar_month,
                                size: 15,
                                color: Colors.black,
                              ),
                              Text(date, style: const TextStyle(color: textColor, fontSize: 12),)
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
