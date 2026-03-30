import 'package:flutter/material.dart';
import 'package:rick_and_morty/core/local/local_db.dart';

class FavoriteProvider extends ChangeNotifier {
  final LocalDb _db = LocalDb();
  List _favoriteList = [];

  List get favoriteList => _favoriteList;

  void initiateFavoriteCharctersListProvider() async {
    // 1. Reset the list to avoid duplicates on refresh
    _favoriteList = [];

    // 2. Get the list of IDs: e.g., [56, 3, 1]
    List favoriteIdList = _db.getFavoritesFromDB();

    for (var id in favoriteIdList) {
      // 3. Apply your formula: (56 ~/ 20) + 1 = 3
      // We use ~/ (truncate division) in Dart for integer results
      int listIndex = (id ~/ 20) + 1;
      String listKey = 'character_list_$listIndex';

      // 4. Fetch that specific page from the DB
      List pageData = _db.getCharactersFromDB(listKey);

      // 5. Find the specific character object in that page
      // .firstWhere is fast for small lists of 20 items
      var character = pageData.firstWhere(
        (char) => char['id'] == id,
        orElse: () => null,
      );
      Map editedCharacter = getUpdatedCharacter(character);
      if (character != null) {
        _favoriteList.add(editedCharacter);
      }
    }

    // 6. Update the UI once all processing is done
    notifyListeners();
  }

  Map getUpdatedCharacter(Map character) {
    // 1. Get the ID from the current map
    int id = character['id'];

    // 2. Check your LocalDb for any user-saved edits
    Map? editedData = _db.getEditedCharacterById(id);

    // 3. If no edits exist, return the original character as-is
    if (editedData == null) {
      return character;
    }

    // 4. If edits exist, return a NEW map with the updated values
    // Use the spread operator (...) to keep original fields (like 'image' or 'url')
    return {
      ...character,
      'name': editedData['name'] ?? character['name'],
      'status': editedData['status'] ?? character['status'],
      'species': editedData['species'] ?? character['species'],
      'gender': editedData['gender'] ?? character['gender'],
      'type': editedData['type'] ?? character['type'],
      'origin': editedData['origin'] ?? character['origin']['name'],
      'location': editedData['location'] ?? character['location']['name'],
    };
  }

  Map getCharacterById(int id) {
    // 1. Search the _favoriteList for the matching ID
    return _favoriteList.firstWhere(
      (character) => character['id'] == id,
      // 2. Safety: If the character isn't found (e.g. just unfavorited)
      // return an empty map to prevent "StateError: No element"
      orElse: () => {},
    );
  }

  void modifyCharacterAfterEdit(int id) {
    // 1. Find the index of the character in your current UI list (_content)
    int index = _favoriteList.indexWhere((char) => char['id'] == id);

    // 2. If the character exists in the current list
    if (index != -1) {
      // 3. Fetch the latest edited data from Hive
      Map? editedData = _db.getEditedCharacterById(id);

      if (editedData != null) {
        // 4. Update the character in memory
        // We merge the existing character data with the new edits
        _favoriteList[index] = {
          ..._favoriteList[index],
          'name': editedData['name'],
          'status': editedData['status'],
          'species': editedData['species'],
          'gender': editedData['gender'],
          'type': editedData['type'],
          'origin': editedData['origin'],
          'location': editedData['location'],
        };

        // 5. Notify the UI to rebuild only this specific card
        notifyListeners();
      }
    }
  }
}
