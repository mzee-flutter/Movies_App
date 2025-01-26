import 'package:flutter/foundation.dart';
import 'package:movies/data/network/base_api_services.dart';
import 'package:movies/data/network/network_api_services.dart';
import 'package:movies/model/tvshowsList_model.dart';
import '../resources/api_url.dart';

class TvShowsRepository {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<TvShowsListModel> fetchTvShowsList(int page) async {
    try {
      dynamic response = await _apiServices
          .getGetApiRequest('${ApiUrls.onTheAirTvDatabaseApiUrl}&page=$page');
      final tvShowsList = TvShowsListModel.fromJson(response);
      return tvShowsList;
    } catch (e) {
      if (kDebugMode) {
        print('tv shows repo class error');
      }
      rethrow;
    }
  }
}
