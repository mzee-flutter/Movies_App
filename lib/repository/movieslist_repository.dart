import 'package:flutter/foundation.dart';
import 'package:movies/data/network/network_api_services.dart';
import 'package:movies/model/movieslist_model.dart';
import '../data/network/base_api_services.dart';
import '../resources/api_url.dart';

class MoviesRepository {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<MoviesListModel> fetchMoviesList(int page) async {
    try {
      dynamic response = await _apiServices.getGetApiRequest(
          '${ApiUrls.trendingMoviesDatabaseApiUrl}&page=$page');

      final moviesList = MoviesListModel.fromJson(response);
      return moviesList;
    } catch (e) {
      if (kDebugMode) {
        print('Error from the Repository class');
        print(e.toString());
      }
      rethrow;
    }
  }
}
