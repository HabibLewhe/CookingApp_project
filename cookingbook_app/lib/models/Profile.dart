import 'package:cookingbook_app/models/Recette.dart';

class Profile {
  String idProfile; // = idUser = documentID sur firebase

  String imageAvatar;
  String pseudo;

  List<String> likedRecette;

  Profile(
      {required this.idProfile,
      required this.imageAvatar,
      required this.pseudo,
      required this.likedRecette});

  void likeContent(Recette recette) {
    if (!likedRecette.contains(recette.idRecette)) {
      recette.likeContent(recette.idRecette);
      likedRecette.add(recette.idRecette);
    }
  }

  void unlikeContent(Recette recette) {
    if (likedRecette.contains(recette.idRecette)) {
      recette.unlikeContent(recette.idRecette);
      likedRecette.remove(recette.idRecette);
    }
  }

  bool hasLikedContent(Recette recette) {
    return likedRecette.contains(recette.idRecette);
  }
}
