import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import '../Utils/color.dart';
import '../models/Commentaire.dart';
import '../models/Profile.dart';
import '../models/Recette.dart';
import '../services/FireStoreService.dart';
import '../utiles/chatmessage.dart';

class ChatScreen extends StatefulWidget {
  Recette recette;
  String idProfileCreeRecette; // qui a cree la recette
  ChatScreen({
    Key? key,
    required this.recette,
    required this.idProfileCreeRecette,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  late Recette recette;
  late String idProfileCreeRecette;
  late Profile myCurrentProfile;
  late List<Recette> sesRecetteRealTime;
  StreamSubscription<Profile>? _myProfileRealTimeSubscription;
  StreamSubscription<Map<Profile, Commentaire>>? _commentaireMapSubscription;
  StreamSubscription<List<Recette>>? myRecetteSubcription;
  FirestoreService firestoreService = FirestoreService();
  StreamSubscription<List<Recette>>? _sesRecetteRealTimeSubscription;
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
    _subscription?.cancel();
    super.dispose();
    super.dispose();
  }


  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];

  StreamSubscription? _subscription;



  void _sendMessage(){
    ChatMessage message = ChatMessage(text: _controller.text, sender: "user");
    setState(() {
      _messages.insert(0, message);
    });
    _controller.clear();
  }

  Widget _buildTextComposer(){
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            onSubmitted: (value) => _sendMessage(),
            decoration: const InputDecoration.collapsed(hintText: "Send a message")
          ),
        ),
        IconButton(
            onPressed: () => _sendMessage(),
            icon: const Icon(Icons.send, color: primary,)
        )
      ]
    ).px16();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commentaires', style: TextStyle(color: primary),),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
                child: ListView.builder(
                  reverse: true,
                  padding: Vx.m8,
                  itemCount:_messages.length,
                  itemBuilder: (context, index){
                  return _messages[index];
                },)
            ),
           const Divider(
              height: 1.0,
            ),
            Container(
              decoration: BoxDecoration(
                color: context.cardColor,
              ),
              child: _buildTextComposer(),
            ),
          ]
        ),
      ),
    );
  }
}
