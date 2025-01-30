import 'package:flutter/foundation.dart';
import 'package:movies/data/network/network_api_services.dart';
import '../../data/network/base_api_services.dart';
import '../../model/tvShow_season_model.dart';

class TvShowSeasonRepository {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<TvShowSeason> fetchTvShowSeasons(int id) async {
    try {
      dynamic response = await _apiServices.getGetApiRequest(
          'https://api.themoviedb.org/3/tv/$id?api_key=0b35a24599b873bd58ae9b29f4ba51a2&language=en-US');
      final TvShowSeason seasonList = TvShowSeason.fromJson(response);
      return seasonList;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }

      rethrow;
    }
  }
}
