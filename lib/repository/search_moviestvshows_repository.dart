import 'package:flutter/foundation.dart';
import 'package:movies/data/network/network_api_services.dart';
import '../data/network/base_api_services.dart';
import '../model/search_moviestvshows_model.dart';
import '../resources/api_url.dart';

class SearchMoviesTvShowRepository {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<SearchMoviesTvShowsModel> fetchSearchResult(
      String title, int page) async {
    String encodedTitle = Uri.encodeQueryComponent(title);
    try {
      dynamic response = await _apiServices.getGetApiRequest(
        'https://api.themoviedb.org/3/search/multi?api_key=${ApiUrls.moviesDatabaseApiKey}&page=$page&query=$encodedTitle',
      );
      final SearchMoviesTvShowsModel result =
          SearchMoviesTvShowsModel.fromJson(response);
      return result;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      rethrow;
    }
  }
}
