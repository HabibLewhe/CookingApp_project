class Recette {
  int idRecette;
  String image;
  String nom;
  Duration tempsPreparation;
  int nbPersonne;
  String instruction;
  Map<String, String> ingredients;

  Recette({
    required this.idRecette,
    required this.image,
    required this.nom,
    required this.tempsPreparation,
    required this.nbPersonne,
    required this.instruction,
    required this.ingredients,
  });
}
