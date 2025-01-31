import 'package:flutter/foundation.dart';
import 'package:movies/data/network/network_api_services.dart';
import '../../data/network/base_api_services.dart';
import '../../model/youtube_videos_model.dart';
import '../../resources/api_url.dart';

class YoutubeVideosRepository {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<YoutubeSearchResponse> fetchYoutubeVideos(String movieTitle,
      {String? pageToken}) async {
    final query = Uri.encodeComponent('${movieTitle}trailer');

    try {
      dynamic response = await _apiServices.getGetApiRequest(
        'https://www.googleapis.com/youtube/v3/search?part=snippet&q=$query&type=video&key=${ApiUrls.youtubeApiKey}${pageToken != null ? '&pageToken=$pageToken' : ''}',
      );
      final YoutubeSearchResponse youtubeResponse =
          YoutubeSearchResponse.fromJson(response);
      return youtubeResponse;
    } catch (e) {
      if (kDebugMode) {
        print('Error from the repository class');
        print(e.toString());
      }
      rethrow;
    }
  }
}
