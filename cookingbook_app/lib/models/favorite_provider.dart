import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Recette.dart';

class FavoriteProvider extends ChangeNotifier {
  // liste qui contiendra les recettes lorsqu'elles seront basculées vers les favoris
  List<Recette> _recettesFav = [];
  List<Recette> get recettes => _recettesFav;

  void toggleFavorite(Recette recette) {
    final isExist = _recettesFav.contains(recette);
    if (isExist) {
      _recettesFav.remove(recette);
    } else {
      _recettesFav.add(recette);
    }
    notifyListeners();
  }

  bool isExist(Recette recette) {
    final isExist = _recettesFav.contains(recette);
    return isExist;
  }

  void clearFavorite() {
    _recettesFav = [];
    notifyListeners();
  }

  static FavoriteProvider of(
    BuildContext context, {
    bool listen = true,
  }) {
    return Provider.of<FavoriteProvider>(
      context,
      listen: listen,
    );
  }
}
