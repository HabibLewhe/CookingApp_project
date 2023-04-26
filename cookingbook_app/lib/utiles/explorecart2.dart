import 'package:cookingbook_app/models/Profile.dart';
import 'package:cookingbook_app/models/Recette.dart';
import 'package:flutter/material.dart';

import '../color.dart';

class ExploreCart2 extends StatelessWidget {
  final Recette recette;
  final Profile profile;
  final VoidCallback onTap;

  const ExploreCart2({Key? key, required this.recette, required this.profile,required this.onTap}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Padding(
      padding: const EdgeInsets.only(top:8.0),
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
                              image:  DecorationImage(
                                  image: NetworkImage(
                                    recette.image,
                                  ),
                                  fit: BoxFit.cover)),
                        ),
                        SizedBox(
                           width: MediaQuery.of(context).size.width*0.6
                           ,
                          child: Padding(
                            padding: const EdgeInsets.only(left:8.0),
                            child: Column(
                              
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children:  [
                                        Padding(
                                          padding: const EdgeInsets.only(top:8.0,left: 8),
                                          child: Text(
                                            recette.nom,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: textColor, fontSize: 16),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8.0),
                                          child: Text(
                                            recette.categorie,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: inActiveColor,
                                                fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height:18 ,),
                                Row(
                                  children: [
                                     CircleAvatar(
                                      radius: 16,
                                      backgroundImage: NetworkImage(
                                          profile.imageAvatar),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children:  [
                                          const Text(
                                            "Chef",
                                            style:
                                                const TextStyle(fontSize: 14, color: textColor),
                                          ),
                                           Text(
                                            profile.pseudo,
                                            style:
                                                TextStyle(fontSize: 13, color: labelColor),
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
            right: 10,
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
                              children:  [
                                Icon(
                                  Icons.star,
                                  size: 15,
                                  color: Colors.black,
                                ),
                                Text(recette.nbPersonne),
                              ],
                            ),
                          ),
                        ))
        ],
      ),
     )
    );
  }
}
