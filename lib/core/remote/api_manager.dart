import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:rick_and_morty/util/constants.dart';

class ApiManager {
  final int _loadingMaximumDurationInSeconds = 10;

  Future<dynamic> getResponse({required String apiEndPoint}) async {
    Uri requestUrl = Uri.parse(baseUrl + apiEndPoint);
    try {
      final response = await http
          .get(requestUrl, headers: {'Content-Type': 'application/json'})
          .timeout(Duration(seconds: _loadingMaximumDurationInSeconds));
      _printRequestResponse(
        requestUrl.toString(),
        response.statusCode,
        response.body.toString(),
      );
      return response;
    } on SocketException catch (e) {
      if (kDebugMode) {
        print('$apiEndPoint api socket exception: $e');
      }
      return null;
    } on Exception catch (e) {
      if (kDebugMode) {
        print('$apiEndPoint api exception: $e');
      }
      return null;
    }
  }

  void _printRequestResponse(
    String requestUrl,
    int statusCode,
    String response,
  ) {
    if (kDebugMode) {
       print('requestUrl: $requestUrl');
      // print('statusCode: $statusCode');
      // print('response: $response');
    }
  }
}
