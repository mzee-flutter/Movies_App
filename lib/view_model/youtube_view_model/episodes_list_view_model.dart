import 'package:flutter/foundation.dart';
import '../../model/tvShow_season_model.dart';
import '../../repository/youtube_repository/episodes_list_repository.dart';

class EpisodesListViewModel with ChangeNotifier {
  final EpisodesListRepository _episodesRepo = EpisodesListRepository();

  final List<Episode> _episodesList = [];
  bool _isLoading = false;

  List<Episode> get episodesList => _episodesList;
  bool get isLoading => _isLoading;

  Future<void> fetchSeasonEpisodes(int showId, int seasonNumber) async {
    _isLoading = true;
    notifyListeners();
    try {
      final season =
          await _episodesRepo.fetchSeasonEpisodes(showId, seasonNumber);
      _episodesList.clear();
      _episodesList.addAll(season.episodes);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
