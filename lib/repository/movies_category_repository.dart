import 'package:flutter/foundation.dart';
import 'package:movies/data/network/network_api_services.dart';
import '../data/network/base_api_services.dart';
import '../model/movieslist_model.dart';
import '../resources/api_url.dart';

class MoviesCategoryRepository {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<MoviesListModel> fetchDifferentMoviesCategory(
      String category, int page) async {
    try {
      dynamic response = await _apiServices.getGetApiRequest(
        'https://api.themoviedb.org/3/movie/$category?api_key=${ApiUrls.moviesDatabaseApiKey}&page=$page',
      );
      final moviesList = MoviesListModel.fromJson(response);
      return moviesList;
    } catch (e) {
      if (kDebugMode) {
        print('error from the repository class');
        print(e.toString());
      }
      rethrow;
    }
  }
}
