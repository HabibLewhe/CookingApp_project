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

  // List<Commentaire> commentaires;
  // List<String> likeur;

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
