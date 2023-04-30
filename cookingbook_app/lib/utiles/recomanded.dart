import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../color.dart';
import '../models/Recette.dart';

class Recommended extends StatelessWidget {
  final Recette recette;
  final VoidCallback onTap;

  Recommended(
      {Key? key,
        required this.recette,
        required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap  ,
    child:Stack(
      children: [
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: SizedBox(
            height: 120,
            width: MediaQuery.of(context).size.width * 0.7,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    height: 100,
                    width: 90,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image:  DecorationImage(
                            image: NetworkImage(
                                recette.image),
                            fit: BoxFit.cover)),
                  ),
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
                            recette.nom,
                            style: const TextStyle(color: textColor, fontSize: 16),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              recette.categorie,
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
                                Icons.star,
                                size: 15,
                                color: Colors.black,
                              ),
                              Text(recette.likeur.length.toString())
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
    ));
  }
}
