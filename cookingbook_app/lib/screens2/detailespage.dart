import 'package:cookingbook_app/screens/CommentairesPage.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:tuple/tuple.dart';
import '../color.dart';
import '../models/Profile.dart';
import '../models/Recette.dart';

class Detailspage extends StatefulWidget {
  final Recette recette;
  final Profile profile;

  Detailspage(
      {Key? key,
        required this.recette,
        required this.profile})
      : super(key: key);

  @override
  State<Detailspage> createState() => _DetailspageState();
}

class _DetailspageState extends State<Detailspage> {
  List<Tuple2<String, String>> ingre = [];

  @override
  void initState() {
    super.initState();
    ingre =  widget.recette.ingredients.entries.map((entry) => Tuple2<String, String>(entry.key, entry.value)).toList();
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: SizedBox(
        height: 50,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.only(left:8.0,right: 8),
          child: Row(
            children:  [

              const SizedBox(width: 30,),
               Container(
                height: 40,
                width: MediaQuery.of(context).size.width*0.8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: primary
                ),
                child: IconButton(
                  onPressed: (){
                    Navigator.push(
                        context,
                        PageTransition(
                            child:  CommentairesPage(recette: widget.recette,idProfileCreeRecette: widget.recette.idUser,),
                            type: PageTransitionType.bottomToTop,
                            duration: const Duration(milliseconds: 800)));

                  },
                  icon: const Icon(Icons.comment,color: Colors.black,),
                ),
              ),
            ],
          ),
        ),
      ),
        body: Stack(
            children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
         
        ),
            Positioned(
              top:0,
              child: Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height*0.6,
                    decoration:   BoxDecoration(
                       image: DecorationImage(image: NetworkImage(widget.recette.image),fit: BoxFit.cover)
                       ),
                    ),
                  ],
                ),
              ),
            Positioned(
              bottom: 0,
              child: Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height*0.5,
                    decoration: const BoxDecoration(
                         color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        )),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 30,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children:  [
                                 Text(
                                  widget.recette.nom,
                                  style: const TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold
                                  ),
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
                                          Text(widget.recette.nbPersonne.toString())
                                        ],
                                      ),
                                    ),
                                  )
                              ],
                            ),
                            const Text("Salad",style: TextStyle(color: inActiveColor,),),
                            const SizedBox(height: 25,),
                            Container(
                              height:60,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                 border: Border.all(color:labelColor,width: 0.1 )
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children:  [
                                    Row(
                                      children: [
                                         CircleAvatar(
                                          radius: 20,
                                          backgroundImage: NetworkImage(widget.profile.imageAvatar),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left:8.0,top: 8),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children:  [
                                              Text(widget.profile.pseudo,style: const TextStyle(fontSize: 14,color: textColor),),
                                              const Text("Chef",style: TextStyle(fontSize: 12,color: labelColor),)
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                  ],
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top:20.0),
                              child: Text("Ingredients",style: TextStyle(fontSize: 16),),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top:20.0),
                              child: DottedBorder(
                                borderType: BorderType.Rect,
                                strokeWidth: 0.8,
                                dashPattern: const [1,],
                                color: inActiveColor,
                                child: SizedBox(
                                height: 80,
                                width: MediaQuery.of(context).size.width,
                                child:Column(
                                  children: [
                                    for(int i=0;i<ingre.length;i++)
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children:  [
                                              Icon(Icons.trip_origin, color: primary, size: 20,),
                                              SizedBox(width: 4,),
                                              Text(ingre[i].item1),
                                              Text(ingre[i].item2)
                                            ],
                                          ),
                                         if(i+1<ingre.length)
                                              Row(
                                              children:  [
                                                Icon(Icons.trip_origin, color: primary, size: 20,),
                                                SizedBox(width: 4,),
                                                Text(ingre[i+1].item1),
                                                Text(ingre[i+1].item2)
                                              ],
                                          ),
                                        ],
                                      ),
                                    ),

                                  ],
                                ),
                              ) ),
                            ),
                           const Padding(
                              padding: EdgeInsets.only(top:20.0),
                              child: Text("instructions",style: TextStyle(fontSize: 16))),
                               Text(widget.recette.instruction,style: TextStyle(color: inActiveColor),),
                            const SizedBox(height: 40,)
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 14,
              left: 5,
              child: IconButton(onPressed: (){
                Navigator.pop(context);
              }, icon: const Icon(Icons.arrow_back)))
            ],
          ));
  }
}
