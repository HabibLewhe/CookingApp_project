import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/Recette.dart';
import 'package:uuid/uuid.dart';

class FirestoreService {
  final CollectionReference recetteCollection =
      FirebaseFirestore.instance.collection('recette');

  // Add a recette document to Firestore
  Future<void> addRecette(Recette recette) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      recette.idUser = user.uid;
      recette.idRecette = Uuid().v4();
      await recetteCollection.doc(recette.idRecette.toString()).set({
        'idUser': recette.idUser,
        'image': recette.image,
        'categorie': recette.categorie,
        'nom': recette.nom,
        'tempsPreparation': recette.tempsPreparation.inMinutes,
        'nbPersonne': recette.nbPersonne,
        'instruction': recette.instruction,
        'ingredients': recette.ingredients,
      });
    }
  }
}
