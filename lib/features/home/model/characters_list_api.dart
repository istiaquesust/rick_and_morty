import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:rick_and_morty/core/remote/api_manager.dart';
import 'package:rick_and_morty/util/constants.dart';

class CharactersListApi {
  Future<Map<String, dynamic>?> getCharactersListApi({
    required int page,
  }) async {
    ApiManager apiManager = ApiManager();
    Map<String, dynamic> result = {};
    try {
      String apiEndPoint = '$getAllCharactersApiEndPoint?page=$page';
      dynamic response = await apiManager.getResponse(apiEndPoint: apiEndPoint);
      if (response != null) {
        var responseDecode = jsonDecode(response.body.toString());

        if (response.statusCode == 200) {
          result["statusCode"] = response.statusCode;
          result["data"] = responseDecode;
        } else {
          result["statusCode"] = response.statusCode;
          result["data"] = [];
        }
      } else {
        result["statusCode"] = 408;
        result["data"] = [];
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('exception: $e');
      }
      result["statusCode"] = 500;
      result["data"] = [];
    }
    return result;
  }
}
