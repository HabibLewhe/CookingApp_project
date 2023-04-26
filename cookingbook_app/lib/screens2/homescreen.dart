import 'package:flutter/material.dart';
// import '../color.dart';
import '../color.dart';
import '../models/Profile.dart';
import '../models/Recette.dart';
import '../screens/EditProfileDemo.dart';
import '../screens/HomeScreenDemo.dart';
import '../services/Authentication.dart';
import '../services/FireStoreService.dart';
import '../utiles/catogories.dart';
import '../utiles/popular.dart';
import '../utiles/recomanded.dart';
import 'detailespage.dart';

class Homescreen extends StatefulWidget {
  final String signInMethod;
  const Homescreen({Key? key,required this.signInMethod}) : super(key: key);

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  Authentication auth = Authentication();
  late List<Recette> allMyRecettes = [];

  late Profile? thisProfile;
  FirestoreService firestoreService = FirestoreService();
  Future<void> getCurrentUserProfile() async {
    Profile profile = await firestoreService.getCurrentUserProfile();
    setState(() {
      thisProfile = profile;
    });
  }

  Future<void> fetchDataProfile() async {
    await getCurrentUserProfile();
  }

  Future<void> fetchDataMyRecettes() async {
    await getMyRecettes();
  }

  void refreshDataProfile() {
    setState(() {
      fetchDataProfile();
    });
  }

  void refreshDataMyRecettes() {
    setState(() {
      fetchDataMyRecettes();
    });
  }

  Future<void> getMyRecettes() async {
    List<Recette> recettes = await firestoreService.getRecettes();
    setState(() {
      allMyRecettes = recettes;
    });
  }

  @override
  void initState() {
    fetchDataProfile();
    fetchDataMyRecettes();
    super.initState();
  }
  void _rien(){
    print("rien");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: appBgColor,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: shadowColor.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 1,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child:  IconButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (ctx) => EditProfileDemo(
                                              profile: thisProfile!,
                                              refreshDataHomePage:
                                              refreshDataProfile)));
                                    },
                                icon: const Icon(Icons.person),
                            ),
                        ),
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          color: appBgColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: inActiveColor)),
                      child: Center(

                        child: IconButton(
                          onPressed: () {
                            auth.onLogout(widget.signInMethod);
                            Navigator.push(context,
                                MaterialPageRoute(builder: (ctx) => HomeScreenDemo()));
                          },
                          icon: const Icon(Icons.logout),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "Stay at home,",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: textColor),
                ),
                RichText(
                    text: const TextSpan(children: [
                  TextSpan(
                      text: "make your own ",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: textColor)),
                  TextSpan(
                      text: "food",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primary,
                          fontSize: 30))
                ])),
                Padding(
                  padding: const EdgeInsets.only(top: 13.0),
                  child: Row(
                    children:  [
                      Catogeries(
                          color: primary,
                          text: "Ramen",
                          images: "assets/images/ramen.png",
                          onTap: () => _rien()),
                        Catogeries(
                            color: cardColor,
                            text: "Salad",
                            images: "assets/images/salad.png",
                            onTap: () => _rien()),
                        Catogeries(
                            color: cardColor,
                            text: "Pizza",
                            images: "assets/images/pizza.png",
                            onTap: () => _rien()),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "Popular Recipes",
                  style: TextStyle(
                      fontSize: 25,
                      color: textColor,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 250,
                  child: ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    children:  [
                     InkWell (
                       onTap: () {
                         Navigator.push(context, MaterialPageRoute(builder: ((context) =>  const Detailspage(image: "https://images.unsplash.com/photo-1512058564366-18510be2db19?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=872&q=80",name: "Rice pot",userimage: "https://images.unsplash.com/photo-1557862921-37829c790f19?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8bWFufGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=500&q=60",username: "David",))));
                       },
                        child: const Popularcart(
                            images:
                                "https://images.unsplash.com/photo-1512058564366-18510be2db19?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=872&q=80",
                            name: "Rice pot",
                            userimage:
                                "https://images.unsplash.com/photo-1557862921-37829c790f19?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8bWFufGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=500&q=60"),
                      ),
                       Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: ((context) =>  const Detailspage(image:
                                  "https://images.unsplash.com/photo-1623595119708-26b1f7300075?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=383&q=80",
                              name: "Ice Cream",
                              userimage:
                                  "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=387&q=80",username: "Maya",))));
                          },
                          child: const Popularcart(
                              images:
                                  "https://images.unsplash.com/photo-1623595119708-26b1f7300075?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=383&q=80",
                              name: "Ice Cream",
                              userimage:
                                  "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=387&q=80"),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  "Recommended Recipes",
                  style: TextStyle(
                      fontSize: 25,
                      color: textColor,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  height: 10,
                ),
               SizedBox(
                  height: 120,
                  child: ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    children: const [
                      
                      Recommended(name: "Yellow curry", image: "https://images.unsplash.com/photo-1535400875775-0269e7a919af?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTh8fHllbGxvdyUyMGN1cnJ5fGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=500&q=60", subtitle: "Curry"),
                       Padding(
                         padding: EdgeInsets.only(left:8.0),
                         child: Recommended(name: "Mix-salad", image: "https://images.unsplash.com/photo-1623428187969-5da2dcea5ebf?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTJ8fHNhbGFkfGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=500&q=60", subtitle: "Salad"),
                       )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
