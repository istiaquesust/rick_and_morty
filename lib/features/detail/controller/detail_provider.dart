import 'package:flutter/material.dart';
import 'package:rick_and_morty/core/local/local_db.dart';

class DetailProvider extends ChangeNotifier {
  final LocalDb _db = LocalDb();
  bool _isFavorite = false;

  bool get isfavorite => _isFavorite;

  void saveOrDeleteFavoriteProvider({
    required int id,
    required bool favoriteFlag,
  }) async {
    _db.saveOrDeleteFavoriteToDB(
      id: id,
      isFavorite: favoriteFlag,
    ); //store to local db
    _isFavorite = favoriteFlag;

    notifyListeners();
  }

  void checkIsFavoriteProvider({required int id}) async {
    List favoriteList = _db.getFavoritesFromDB(); // [2, 52,1, 6,]

    _isFavorite = favoriteList.toSet().contains(id);

    notifyListeners();
  }
}
