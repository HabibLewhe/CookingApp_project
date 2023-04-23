class Commentaire {
  String idUser; // idPrfile
  String content;
  String idRecette;
  String idCommentaire;
  DateTime dateTime;

  Commentaire(
      {required this.idUser,
      required this.content,
      required this.idRecette,
      required this.idCommentaire,
      required this.dateTime});
}
