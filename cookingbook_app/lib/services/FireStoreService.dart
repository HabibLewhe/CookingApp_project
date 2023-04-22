import 'dart:io';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../models/Profile.dart';
import '../models/Recette.dart';
import 'package:uuid/uuid.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirestoreService() {
    // Initialize Firestore
    _firestore.settings = Settings(persistenceEnabled: true);
  }

  final CollectionReference recetteCollection =
      FirebaseFirestore.instance.collection('recette');
  final CollectionReference profileCollection =
      FirebaseFirestore.instance.collection('profile');

  // Add a recette document to Firestore
  //Crud
  Future<void> addRecette(Recette recette) async {
    Uuid uuid = Uuid();

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      recette.idUser = user.uid;
      recette.idRecette = uuid.v4();
      await recetteCollection.doc(recette.idRecette.toString()).set({
        'idUser': recette.idUser,
        'image': recette.image,
        'categorie': recette.categorie,
        'nom': recette.nom,
        'tempsPreparation': recette.tempsPreparation.inMinutes,
        'nbPersonne': recette.nbPersonne,
        'instruction': recette.instruction,
        'ingredients': recette.ingredients,
        'likeur': [],
      });
    }
  }

  Future<void> addProfile(Profile profile) async {
    Uuid uuid = Uuid();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      profile.idProfile = user.uid;
      profile.idProfile = uuid.v4();
      await profileCollection.doc(profile.idProfile.toString()).set({
        'idUser': profile.idProfile,
        'imageAvatar':
            'https://firebasestorage.googleapis.com/v0/b/multidev-cookingbook.appspot.com/o/profileImages%2Fno-avatar.png?alt=media&token=d89cbaf6-494d-48cb-a7e2-55fe72412e4c',
        'pseudo': 'pseudo',
      });
    }
  }

  // Get all recettes belonging to current user
  // cRud
  Future<List<Recette>> getRecettes() async {
    User? user = FirebaseAuth.instance.currentUser;
    List<Recette> recettes = [];

    if (user != null) {
      QuerySnapshot querySnapshot =
          await recetteCollection.where('idUser', isEqualTo: user.uid).get();

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Recette recette = Recette(
          idUser: data['idUser'],
          idRecette: doc.id,
          image: data['image'],
          categorie: data['categorie'],
          nom: data['nom'],
          tempsPreparation: Duration(minutes: data['tempsPreparation']),
          nbPersonne: data['nbPersonne'],
          instruction: data['instruction'],
          ingredients: Map<String, String>.from(data['ingredients']),
          likeur:
              (data['likeur'] != null) ? List<String>.from(data['likeur']) : [],
        );
        recettes.add(recette);
      }
    }

    return recettes;
  }

  Future<Profile> getCurrentUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    late Profile profile;

    if (user != null) {
      DocumentSnapshot profileSnapshot =
          await profileCollection.doc(user.uid).get();
      // DocumentSnapshot profileSnapshot = await profileCollection
      //     .where('idUser', isEqualTo: user.uid)
      //     .limit(1)
      //     .get()
      //     .then((value) => value.docs.first);

      if (profileSnapshot.exists) {
        Map<String, dynamic> data =
            profileSnapshot.data() as Map<String, dynamic>;

        profile = Profile(
          idProfile: profileSnapshot.id,
          imageAvatar: data['imageAvatar'],
          pseudo: data['pseudo'],
          likedRecette: (data['likedRecette'] != null)
              ? List<String>.from(data['likedRecette'])
              : [],
        );
      }
    }
    return profile;
  }

  Future<String> uploadImageToFirebase(File imageFile, String folder) async {
    final now = DateTime.now();
    final formatter = DateFormat('yyyyMMdd_HHmmss');
    final String fileName = 'image_${formatter.format(now)}.jpg';

    // Create a Reference to the file location
    Reference ref =
        FirebaseStorage.instance.ref().child(folder).child(fileName);

    // Upload the file to Firebase Storage
    final UploadTask uploadTask = ref.putFile(imageFile);
    final TaskSnapshot taskSnapshot = await uploadTask;
    final String downloadUrl = await taskSnapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  //cruD
  Future<void> deleteRecette(String idRecette) async {
    await recetteCollection.doc(idRecette).delete();
  }

  //crUd
  Future<void> updateRecette(
    String idRecette, {
    String? image,
    String? categorie,
    String? nom,
    Duration? tempsPreparation,
    String? nbPersonne,
    String? instruction,
    Map<String, String>? ingredients,
  }) async {
    Map<String, dynamic> dataToUpdate = {};

    if (image != null) {
      dataToUpdate['image'] = image;
    }
    if (categorie != null) {
      dataToUpdate['categorie'] = categorie;
    }
    if (nom != null) {
      dataToUpdate['nom'] = nom;
    }
    if (tempsPreparation != null) {
      dataToUpdate['tempsPreparation'] = tempsPreparation.inMinutes;
    }
    if (nbPersonne != null) {
      dataToUpdate['nbPersonne'] = nbPersonne;
    }
    if (instruction != null) {
      dataToUpdate['instruction'] = instruction;
    }
    if (ingredients != null) {
      dataToUpdate['ingredients'] = ingredients;
    }

    await recetteCollection.doc(idRecette).update(dataToUpdate);
  }

  Future<void> updateProfile(String idUser,
      {String? imageAvatar, String? pseudo}) async {
    Map<String, dynamic> dataToUpdate = {};

    if (imageAvatar != null) {
      dataToUpdate['imageAvatar'] = imageAvatar;
    }
    if (pseudo != null) {
      dataToUpdate['pseudo'] = pseudo;
    }
    await profileCollection.doc(idUser).update(dataToUpdate);
  }
}
