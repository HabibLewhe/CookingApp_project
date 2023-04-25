import 'dart:io';
import 'package:cookingbook_app/models/Commentaire.dart';
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
  final CollectionReference commentaireCollection =
      FirebaseFirestore.instance.collection('commentaire');

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

//'https://firebasestorage.googleapis.com/v0/b/multidev-cookingbook.appspot.com/o/profileImages%2Fno-avatar.png?alt=media&token=d89cbaf6-494d-48cb-a7e2-55fe72412e4c'
  Future<void> addProfile(String nom, String image) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await profileCollection.doc(user.uid).set({
        'imageAvatar': image,
        'pseudo': nom,
        'likedRecette': [],
      });
    }
  }

  Future<bool> doesProfileExist(String idUser) async {
    DocumentSnapshot profileSnapshot =
        await profileCollection.doc(idUser).get();
    return profileSnapshot.exists;
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
          commentaires: [],
        );
        recettes.add(recette);
      }
    }

    return recettes;
  }

  Future<List<Commentaire>> getCommentaire(String idRecette) async {
    User? user = FirebaseAuth.instance.currentUser;
    List<Commentaire> commentaire = [];
    List<String> commentaireIds = [];
    if (user != null) {
      DocumentSnapshot documentSnapshot =
          await recetteCollection.doc(idRecette).get();
      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;
      commentaireIds = (data['commentaires'] != null)
          ? List<String>.from(data['commentaires'])
          : [];

      for (String id in commentaireIds) {
        DocumentSnapshot documentSnapshotCmt =
            (await commentaireCollection.doc(id).get());
        Map<String, dynamic> data =
            documentSnapshotCmt.data() as Map<String, dynamic>;

        Timestamp timestamp = data['dateTime'];
        Commentaire cmt = Commentaire(
            idUser: data['idUser'],
            content: data['content'],
            idRecette: data['idRecette'],
            idCommentaire: id,
            dateTime: timestamp.toDate());
        commentaire.add(cmt);
      }
    }

    return commentaire;
  }

  Future<Profile> getCurrentUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    late Profile profile;

    if (user != null) {
      DocumentSnapshot profileSnapshot =
          await profileCollection.doc(user.uid).get();

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

  Future<List<String>> getPseudosById(List<String> idsProfile) async {
    List<String> pseudos = [];
    for (String id in idsProfile) {
      DocumentSnapshot profileSnapshot = await profileCollection.doc(id).get();
      Map<String, dynamic> data =
          profileSnapshot.data() as Map<String, dynamic>;
      pseudos.add(data['pseudo']);
    }

    return pseudos;
  }

  Future<List<Recette>> getFavoritesRecettes() async {
    User? user = FirebaseAuth.instance.currentUser;
    List<Recette> favRecettes = [];

    List<String> likedRecette = [];

    if (user != null) {
      // on récupère le profile par son identifiant
      // l'identifiant étant le même que l'utilisateur actuellement connecté
      DocumentSnapshot querySnapshot =
          (await profileCollection.doc(user.uid).get());

      // on transforme le document en un map pour
      // pouvoir parcourir les éléments
      Map<String, dynamic> data = querySnapshot.data() as Map<String, dynamic>;

      // on récupère la liste des recettes likées par l'utilisateur
      // chaque recette étant représentée par son identifiant
      likedRecette = (data['likedRecette'] != null)
          ? List<String>.from(data['likedRecette'])
          : [];

      // on parcoures la liste
      for (String likedRecetteId in likedRecette) {
        // on récupère la recette par son identifiant
        // on la formate en une instance de recette
        DocumentSnapshot querySnapshot =
            (await recetteCollection.doc(likedRecetteId).get());

        Map<String, dynamic> data =
            querySnapshot.data() as Map<String, dynamic>;
        Recette recette = Recette(
          idUser: data['idUser'],
          idRecette: querySnapshot.id,
          image: data['image'],
          categorie: data['categorie'],
          nom: data['nom'],
          tempsPreparation: Duration(minutes: data['tempsPreparation']),
          nbPersonne: data['nbPersonne'],
          instruction: data['instruction'],
          ingredients: Map<String, String>.from(data['ingredients']),
          likeur:
              (data['likeur'] != null) ? List<String>.from(data['likeur']) : [],
          commentaires: (data['commentaires'] != null)
              ? List<String>.from(data['commentaires'])
              : [],
        );
        favRecettes.add(recette);
      }
    }

    return favRecettes;
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

// crUd
  Future<void> updateRecetteLikeur(String idRecette, bool like) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference recetteRef = recetteCollection.doc(idRecette);
      DocumentSnapshot recetteSnapshot = await recetteRef.get();

      if (recetteSnapshot.exists) {
        Map<String, dynamic>? data =
            recetteSnapshot.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('likeur')) {
          List<String> likeur = List.from(data['likeur']);
          if (like) {
            // Add user ID to 'likeur' list
            if (!likeur.contains(user.uid)) {
              likeur.add(user.uid);
            }
          } else {
            // Remove user ID from 'likeur' list
            if (likeur.contains(user.uid)) {
              likeur.remove(user.uid);
            }
          }

          // Update 'likeur' field in Firestore
          await recetteRef.update({'likeur': likeur});
        }
      }
    }
  }

// crUd
  Future<void> updateProfileLikedRecette(
      String idProfile, String idRecette, bool like) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference profileRef = profileCollection.doc(idProfile);
      DocumentSnapshot profileSnapshot = await profileRef.get();

      if (profileSnapshot.exists) {
        Map<String, dynamic>? data =
            profileSnapshot.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('likedRecette')) {
          List<String> likedRecette = List.from(data['likedRecette']);
          if (like) {
            // Add recette ID to 'likedRecette' list
            if (!likedRecette.contains(idRecette)) {
              likedRecette.add(idRecette);
            }
          } else {
            // Remove recette ID from 'likedRecette' list
            if (likedRecette.contains(idRecette)) {
              likedRecette.remove(idRecette);
            }
          }

          // Update 'likedRecette' field in Firestore
          await profileRef.update({'likedRecette': likedRecette});
        }
      }
    }
  }

  Future<bool> isLike(String idProfile, String idRecette) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot profileSnapshot =
          await profileCollection.doc(idProfile).get();

      if (profileSnapshot.exists) {
        Map<String, dynamic>? data =
            profileSnapshot.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('likedRecette')) {
          List<String> likedRecette = List.from(data['likedRecette']);
          return likedRecette.contains(idRecette);
        }
      }
    }

    return false;
  }

  // search
  Future<List<Profile>> getAllProfiles() async {
    List<Profile> profiles = [];

    QuerySnapshot querySnapshot = await profileCollection.get();

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      Profile profile = Profile(
        idProfile: doc.id,
        imageAvatar: data['imageAvatar'],
        pseudo: data['pseudo'],
        likedRecette: (data['likedRecette'] != null)
            ? List<String>.from(data['likedRecette'])
            : [],
      );
      profiles.add(profile);
    }

    return profiles;
  }

  Future<List<Recette>> getAllRecettes() async {
    List<Recette> recettes = [];

    QuerySnapshot querySnapshot = await recetteCollection.get();

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
        commentaires: (data['commentaires'] != null)
            ? List<String>.from(data['likeur'])
            : [],
      );
      recettes.add(recette);
    }

    return recettes;
  }

  Future<void> addCommentaire(Commentaire commentaire, Recette recette) async {
    Uuid uuid = Uuid();

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      commentaire.idUser = user.uid;
      commentaire.idCommentaire = uuid.v4();
      String idCommentaire = commentaire.idCommentaire;
      await commentaireCollection
          .doc(commentaire.idCommentaire.toString())
          .set({
        'idUser': commentaire.idUser,
        'content': commentaire.content,
        'idRecette': commentaire.idRecette,
        'dateTime': commentaire.dateTime,
      });
      await recetteCollection.doc(recette.idRecette).update({
        'commentaires': FieldValue.arrayUnion([idCommentaire])
      });
    }
  }
}
