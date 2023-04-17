import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Recette {
  String idUser;
  String idRecette;
  String image;
  String nom;
  Duration tempsPreparation;
  String nbPersonne;
  String instruction;
  String categorie;
  Map<String, String> ingredients;

  Recette({
    required this.idUser,
    required this.idRecette,
    required this.image,
    required this.nom,
    required this.tempsPreparation,
    required this.nbPersonne,
    required this.instruction,
    required this.ingredients,
    required this.categorie,
  });
}
