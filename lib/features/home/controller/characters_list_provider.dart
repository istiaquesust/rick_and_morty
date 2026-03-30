import 'package:flutter/material.dart';
import 'package:rick_and_morty/core/local/local_db.dart';
import 'package:rick_and_morty/features/home/model/characters_list_api.dart';

class CharactersListProvider extends ChangeNotifier {
  final List _content = [];
  final CharactersListApi _api = CharactersListApi();
  final LocalDb _db = LocalDb();
  int totalPages = 0;
  int page = 1;
  bool isInitialLoading = false;
  bool isMoreLoading = false;
  bool isOffline = false;

  List get content => _content;

  Future<void> updateContent({required String loagingType}) async {
    //intiate loader.
    if (loagingType == 'moreLoading') {
      isMoreLoading = true;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 2000));
    } else if (loagingType == 'initialLoading') {
      isInitialLoading = true;
      notifyListeners();
      clearContent();
      page = 1;
    } else {
      clearContent();
      page = 1;
    }
    if (page == 1) {
      isOffline = false;
    }
    if (!isOffline) {
      //fetch data from api
      final result = await _api.getCharactersListApi(page: page);

      if (result?['statusCode'] == 200) {
        final List newContent = result?['data']['results'] ?? [];
        totalPages = result?['data']['info']['pages'] ?? 1;
        String key = 'character_list_$page';
        List editedList = modifyCharactersByEditedList(newContent);
        _db.saveCharactersToDB(
          key: key,
          content: editedList,
        ); //store to local db

        _content.addAll(_db.getCharactersFromDB(key)); //store from local db
        page++;
      } else if (result?['statusCode'] == 408) {
        isOffline = true;
        _handleOffline();
      }
    } else {
      _handleOffline();
    }

    // stop loader.
    if (loagingType == 'initialLoading') {
      isInitialLoading = false;

      page = 1;
    } else if (loagingType == 'moreLoading') {
      isMoreLoading = false;
    }
    notifyListeners();
  }

  List modifyCharactersByEditedList(List rawContent) {
    // 1. Map through the raw content from the API/DB
    return rawContent.map((character) {
      // 2. Extract the ID for the current character
      int id = character['id'];

      // 3. Check if there is an edited version in Hive
      Map? editedData = _db.getEditedCharacterById(id);

      // 4. If no edits exist, return the original character immediately
      if (editedData == null) {
        return character;
      }

      // 5. If edits ARE found, create a merged version
      // We spread the original first, then overwrite with edited fields
      return {
        ...character, // Keep original fields (like 'image', 'url', 'created')
        'name': editedData['name'] ?? character['name'],
        'status': editedData['status'] ?? character['status'],
        'species': editedData['species'] ?? character['species'],
        'gender': editedData['gender'] ?? character['gender'],
        'type': editedData['type'] ?? character['type'],
        'origin': editedData['origin'] ?? character['origin']['name'],
        'location': editedData['location'] ?? character['location']['name'],
      };
    }).toList(); // Convert the map iterable back into a List
  }

  void modifyCharacterAfterEdit(int id) {
    // 1. Find the index of the character in your current UI list (_content)
    int index = _content.indexWhere((char) => char['id'] == id);

    // 2. If the character exists in the current list
    if (index != -1) {
      // 3. Fetch the latest edited data from Hive
      Map? editedData = _db.getEditedCharacterById(id);

      if (editedData != null) {
        // 4. Update the character in memory
        // We merge the existing character data with the new edits
        _content[index] = {
          ..._content[index],
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

  Map getCharacterById(int id) {
    // 1. Search the _content list for the matching ID
    return _content.firstWhere(
      (character) => character['id'] == id,
      // 2. Safety: If the ID isn't in the list, return an empty Map to prevent crashes
      orElse: () => {},
    );
  }

  void _handleOffline() {
    String key = 'character_list_$page';
    List newContent = _db.getCharactersFromDB(key);
    //print('newContent: ${newContent.length}');
    if (newContent.isNotEmpty) {
      List editedList = modifyCharactersByEditedList(newContent);
      _content.addAll(editedList);
      page++;
    }

    notifyListeners();
  }

  void clearContent() {
    _content.clear();
    notifyListeners();
  }
}
