import 'dart:io';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../models/Commentaire.dart';
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
          commentaires: (data['commentaires'] != null)
              ? List<String>.from(data['commentaires'])
              : [],
        );
        recettes.add(recette);
      }
    }

    return recettes;
  }

  Stream<List<Recette>> getRecettesRealTime() async* {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Stream<QuerySnapshot> snapshots =
          recetteCollection.where('idUser', isEqualTo: user.uid).snapshots();

      await for (QuerySnapshot querySnapshot in snapshots) {
        List<Recette> recettes = [];

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
            likeur: (data['likeur'] != null)
                ? List<String>.from(data['likeur'])
                : [],
            commentaires: (data['commentaires'] != null)
                ? List<String>.from(data['commentaires'])
                : [],
          );
          recettes.add(recette);
        }

        yield recettes;
      }
    }
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

  Stream<Profile> getCurrentUserProfileRealTime() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return profileCollection.doc(user.uid).snapshots().map((snapshot) {
        if (snapshot.exists) {
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

          return Profile(
            idProfile: snapshot.id,
            imageAvatar: data['imageAvatar'],
            pseudo: data['pseudo'],
            likedRecette: (data['likedRecette'] != null)
                ? List<String>.from(data['likedRecette'])
                : [],
          );
        } else {
          // Return null if the document does not exist
          return Profile(
            idProfile: '',
            imageAvatar: '',
            pseudo: '',
            likedRecette: [],
          );
        }
      });
    } else {
      // Return an empty stream if the user is not logged in
      return const Stream.empty();
    }
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

  Future<Profile> getProfile(String idProfile) async {
    DocumentSnapshot documentSnapshot =
        await profileCollection.doc(idProfile).get();
    Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
    return Profile(
      idProfile: idProfile,
      imageAvatar: data['imageAvatar'],
      pseudo: data['pseudo'],
      likedRecette: List<String>.from(data['likedRecette']),
    );
  }

  Stream<Map<Profile, Commentaire>> getCommentaires(String recipeId) async* {
    // Get the recipe document from Firebase
    final recipeDoc =
    FirebaseFirestore.instance.collection('recette').doc(recipeId);
    final recipeSnap = await recipeDoc.get();

    // Get the list of comment IDs from the recipe document
    final commentIds = List<String>.from(recipeSnap.data()!['commentaires']);

    // Get the comment documents from Firebase and build a map of Profile to Commentaire
    final commentMap = Map<Profile, Commentaire>();
    await Future.forEach(commentIds, (String commentId) async {
      final commentDoc =
      FirebaseFirestore.instance.collection('commentaire').doc(commentId);
      final commentSnap = await commentDoc.get();
      final commentData = commentSnap.data();
      final comment = Commentaire(
        idUser: commentData!['idUser'],
        content: commentData['content'],
        idRecette: commentData['idRecette'],
        idCommentaire: commentId,
        dateTime: commentData['dateTime'].toDate(),
      );

      final profileDoc =
      FirebaseFirestore.instance.collection('profile').doc(comment.idUser);
      final profileSnap = await profileDoc.get();
      final profileData = profileSnap.data();
      final profile = Profile(
        idProfile: comment.idUser,
        imageAvatar: profileData!['imageAvatar'],
        pseudo: profileData['pseudo'],
        likedRecette: List<String>.from(profileData['likedRecette']),
      );
      commentMap[profile] = comment;
    });

    // Return the map of Profile to Commentaire

    yield commentMap;
  }

  Future<void> deleteCommentaire(String idCommentaire) async {
    try {
      final QuerySnapshot querySnapshot =
      await _firestore.collection('recette').get();

      final WriteBatch batch = _firestore.batch();

      querySnapshot.docs.forEach((doc) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('commentaires') &&
            List<String>.from(data['commentaires']).contains(idCommentaire)) {
          batch.update(doc.reference, {
            'commentaires': FieldValue.arrayRemove([idCommentaire])
          });
        }
      });

      await batch.commit();
      print('Successfully removed  idCommentaire commentaires Recette.');
    } catch (e) {
      print('Error removing  idCommentaire commentaires Recett: $e');
    }

    try {
      await commentaireCollection.doc(idCommentaire).delete();
      print("Successfully deleted commentaire ! ");
    } catch (e) {
      print('Error deleting commentaire : $e');
    }
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
    //detele commentaire qui dans la recette
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('commentaire')
          .where('idRecette', isEqualTo: idRecette)
          .get();

      final List<QueryDocumentSnapshot> documents = querySnapshot.docs;
      for (final document in documents) {
        await _firestore.collection('commentaire').doc(document.id).delete();
      }
      print("Successfully deleted all comment ! ");
    } catch (e) {
      print('Error deleting comments by recette: $e');
    }

    //delete idRecette dans field "idRecetteLiked" dans profile
    try {
      final QuerySnapshot querySnapshot =
          await _firestore.collection('profile').get();

      final WriteBatch batch = _firestore.batch();

      querySnapshot.docs.forEach((doc) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('likedRecette') &&
            List<String>.from(data['likedRecette']).contains(idRecette)) {
          batch.update(doc.reference, {
            'likedRecette': FieldValue.arrayRemove([idRecette])
          });
        }
      });

      await batch.commit();
      print('Successfully removed liked recette from all profiles.');
    } catch (e) {
      print('Error removing liked recette from all profiles: $e');
    }

    // delete recette

    try {
      await recetteCollection.doc(idRecette).delete();
      print("Successfully deleted recette ! ");
    } catch (e) {
      print('Error deleting recette : $e');
    }
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

  // Update the 'likeur' field of a recette document in Firestore
// You can pass a 'like' boolean flag to indicate whether to add or remove the user's ID from the 'likeur' list
// crUd
  // Update the 'likeur' field of a recette document in Firestore
// You can pass a 'like' boolean flag to indicate whether to add or remove the user's ID from the 'likeur' list
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

// Update the 'likedRecette' field of a profile document in Firestore
// You can pass a 'like' boolean flag to indicate whether to add or remove the recette ID from the 'likedRecette' list
// crUd
// Update the 'likedRecette' field of a profile document in Firestore
// You can pass a 'like' boolean flag to indicate whether to add or remove a recette ID from the 'likedRecette' list
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

  Stream<List<Recette>> getAllRecettesRealTime() async* {
    Stream<QuerySnapshot> snapshots = recetteCollection.snapshots();

    await for (QuerySnapshot querySnapshot in snapshots) {
      List<Recette> recettes = [];

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
              ? List<String>.from(data['commentaires'])
              : [],
        );
        recettes.add(recette);
      }

      yield recettes;
    }
  }
}
