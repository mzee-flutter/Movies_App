import 'package:flutter/foundation.dart';
import 'package:movies/data/network/base_api_services.dart';
import 'package:movies/data/network/network_api_services.dart';
import '../../model/tvShow_season_model.dart';
import '../../resources/api_url.dart';

class EpisodesListRepository {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<Season> fetchSeasonEpisodes(int showId, int seasonNumber) async {
    try {
      dynamic response = await _apiServices.getGetApiRequest(
        'https://api.themoviedb.org/3/tv/$showId/season/$seasonNumber?api_key=${ApiUrls.moviesDatabaseApiKey}',
      );
      final Season season = Season.fromJson(response);
      return season;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      rethrow;
    }
  }
}
