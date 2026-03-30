import 'package:hive/hive.dart';
import 'package:rick_and_morty/util/constants.dart';

class LocalDb {
  // Access the box once
  final Box _charactersBox = Hive.box(charactersBoxLocalDb);
  final Box _favoriteBox = Hive.box(charactersBoxLocalDb);
  final String _favoriteKey = "favorite_list";
  final Box _editedCharactersBox = Hive.box(editedCharactersBoxLocalDb);
  final String _editedCharactersKey = "edited_list";

  //saved characters local db
  void saveCharactersToDB({required String key, required List content}) {
    _charactersBox.delete(key);
    _charactersBox.put(key, content);
  }

  List getCharactersFromDB(String key) {
    return _charactersBox.get(key, defaultValue: []);
  }

  // Favorite charcters local DB
  void saveOrDeleteFavoriteToDB({required int id, required bool isFavorite}) {
    List favoritesList = getFavoritesFromDB();
    if (isFavorite) {
      favoritesList.add(id);
    } else {
      favoritesList.remove(id);
    }
    _charactersBox.put(_favoriteKey, favoritesList);
  }

  List getFavoritesFromDB() {
    return _favoriteBox.get(_favoriteKey, defaultValue: []);
  }

  // edited characters local db
  // Save or Update an edited character
  void saveEditedCharacter({
    required int id,
    required String name,
    required String status,
    required String species,
    required String gender,
    required String type,
    required String origin,
    required String location,
  }) {
    // 1. Get the current list of edits (or an empty list if it's the first time)
    List<dynamic> editedList = _editedCharactersBox.get(
      _editedCharactersKey,
      defaultValue: [],
    );
    print('editedList: $editedList');

    // Create the new data map
    Map<String, dynamic> updatedData = {
      "id": id,
      "name": name,
      "status": status,
      "species": species,
      "gender": gender,
      "type": type,
      "origin": {"name": origin}, // Keeping structure consistent with API
      "location": {"name": location},
    };

    // 2. Find if this ID already exists in the edited list
    int existingIndex = editedList.indexWhere((char) => char['id'] == id);

    if (existingIndex != -1) {
      // Update existing edit
      editedList[existingIndex] = updatedData;
    } else {
      // Add new edit
      editedList.add(updatedData);
    }

    // 3. Save the updated list back to Hive
    _editedCharactersBox.put(_editedCharactersKey, editedList);
  }

  Map? getEditedCharacterById(int id) {
    List<dynamic> editedList = _editedCharactersBox.get(
      _editedCharactersKey,
      defaultValue: [],
    );

    try {
      // Find the first map where the ID matches
      var result = editedList.firstWhere((char) => char['id'] == id);
      return Map<String, dynamic>.from(result);
    } catch (e) {
      return null; // No edits found for this character
    }
  }
}
