import 'dart:convert';
import 'dart:io';
import 'package:movies/Data/app_exception.dart';
import 'base_api_services.dart';
import 'package:http/http.dart' as http;

class NetworkApiServices extends BaseApiServices {
  @override
  Future getGetApiRequest(String url) async {
    dynamic apiResponse;
    try {
      http.Response response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
      apiResponse = returnResponse(response);
    } on SocketException {
      throw FetchDataException('No internet connection');
    }
    return apiResponse;
  }

  @override
  Future getPostApiRequest(String url, var data) async {
    dynamic apiResponse;
    try {
      http.Response response = await http.post(Uri.parse(url), body: data);
      apiResponse = returnResponse(response);
    } on SocketException {
      throw FetchDataException('No internet connection');
    }

    return apiResponse;
  }
}

dynamic returnResponse(http.Response response) {
  switch (response.statusCode) {
    case 200:
      var responseJson = jsonDecode(response.body);
      return responseJson;
    case 400:
      throw Exception('Bad request: ${response.body}');
    case 401:
    case 403:
      throw Exception('Unauthorized request: ${response.body}');
    case 500:
    default:
      throw Exception(
          'Error during Communication with statusCode: ${response.statusCode}, Response: ${response.body}');
  }
}
