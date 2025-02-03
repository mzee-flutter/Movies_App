import 'package:flutter/foundation.dart';
import 'package:movies/data/network/network_api_services.dart';
import '../data/network/base_api_services.dart';
import 'package:movies/resources/api_url.dart';

class LoginRepository {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<dynamic> loginApi(dynamic data) async {
    try {
      dynamic response =
          await _apiServices.getPostApiRequest(ApiUrls.loginUrl, data);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      rethrow;
    }
  }

  Future<dynamic> registerApi(dynamic data) async {
    try {
      final response =
          await _apiServices.getPostApiRequest(ApiUrls.registrationUrl, data);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      rethrow;
    }
  }
}
