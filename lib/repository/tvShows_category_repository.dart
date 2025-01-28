import 'package:flutter/foundation.dart';
import 'package:movies/data/network/network_api_services.dart';
import '../data/network/base_api_services.dart';
import '../model/tvshowsList_model.dart';
import '../resources/api_url.dart';

class TvShowsCategoryRepository {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<TvShowsListModel> fetchDifferentTvShowsCategory(
      String category, int page) async {
    try {
      dynamic response = await _apiServices.getGetApiRequest(
        'https://api.themoviedb.org/3/tv/$category?api_key=${ApiUrls.moviesDatabaseApiKey}&page=$page',
      );
      final TvShowsListModel showsList = TvShowsListModel.fromJson(response);
      return showsList;
    } catch (e) {
      if (kDebugMode) {
        print('error from the repository-class');
        print(e.toString());
      }
      rethrow;
    }
  }
}
