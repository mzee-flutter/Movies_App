import 'package:flutter/foundation.dart';
import 'package:movies/data/network/network_api_services.dart';
import '../data/network/base_api_services.dart';
import '../model/person_model.dart';
import '../resources/api_url.dart';

class PersonListRepository {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<PersonModel> fetchPersonList(int page) async {
    try {
      final response = await _apiServices
          .getGetApiRequest('${ApiUrls.personListDatabaseApiUrl}&page=$page');

      PersonModel personList = PersonModel.fromJson(response);
      return personList;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      rethrow;
    }
  }
}
