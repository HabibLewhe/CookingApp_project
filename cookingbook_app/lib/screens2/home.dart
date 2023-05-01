
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../color.dart';
import 'bookmark.dart';
import 'explore.dart';
import 'homescreen.dart';

class Home extends StatefulWidget {
  final String signInMethod ;
  const Home({Key? key, required this.signInMethod}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int index = 1;
  String signInMethodTemps = "";

  @override
  void initState() {
    pages.add( Explore());
    pages.add( Homescreen(signInMethod: signInMethodTemps));
    pages.add( Bookmark());
  }

  void select(int page) {
    setState(() {
     index=page;
    });
  }

  List<Widget> pages = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: index,
          onTap: select,
          selectedItemColor: primary,
          unselectedItemColor: inActiveColor,
          backgroundColor: bottomBarColor,
          items: [
            BottomNavigationBarItem(
              label: "Rechercher",
              
                icon: SvgPicture.asset(
              "assets/icons/search.svg",
            
              height: 25,
              width: 25,
            )),
            BottomNavigationBarItem(
                icon: SvgPicture.asset("assets/icons/home.svg", height: 25, width: 25),
                label: "Accueil",
            ),
            BottomNavigationBarItem(
              label: "Favoris",
                icon: SvgPicture.asset("assets/icons/bookmark.svg",
                    height: 25, width: 25)),
          ]),
    );
  }
}
