import 'package:flutter/foundation.dart';
import 'package:movies/repository/youtube_repository/youtube_videos_repository.dart';
import '../../model/youtube_videos_model.dart';

class YoutubeVideosViewModel with ChangeNotifier {
  final youTubeVideoRepo = YoutubeVideosRepository();
  YoutubeSearchResponse? response;
  String? nextPageToken;
  bool isLoading = false;
  final List<VideoItem> _trailers = [];

  List<VideoItem> get trailers => _trailers;

  Future<void> fetchYoutubeVideos(String movieTitle,
      {String? pageToken}) async {
    if (isLoading || pageToken == null && _trailers.isNotEmpty) return;

    isLoading = true;
    notifyListeners();
    try {
      response = await youTubeVideoRepo.fetchYoutubeVideos(movieTitle,
          pageToken: pageToken);

      ///The below code means that add the trailer but the where-function check that
      ///any if there videoItem videoID is same then don't add it again.

      _trailers.addAll(response?.items.where((item) => !_trailers
              .any((trailer) => trailer.id.videoId == item.id.videoId)) ??
          []);

      nextPageToken = response?.nextPageToken;

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNextPage(String movieTitle) async {
    if (nextPageToken != null && !isLoading) {
      await fetchYoutubeVideos(movieTitle, pageToken: nextPageToken);
    }
  }

  void clearTrailerList() {
    _trailers.clear();
    notifyListeners();
  }
}
