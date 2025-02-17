import 'package:flutter/foundation.dart';
import 'package:movies/repository/youtube_repository/tvShow_season_repository.dart';
import '../../model/tvShow_season_model.dart';

class TvShowSeasonViewModel with ChangeNotifier {
  final TvShowSeasonRepository seasonRepo = TvShowSeasonRepository();
  TvShowSeason? show;
  bool _isLoading = false;
  final List<Season> _seasonList = [];

  bool get isLoading => _isLoading;

  List<Season> get seasonList => _seasonList;

  Future<void> fetchTvShowSeason(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      show = await seasonRepo.fetchTvShowSeasons(id);

      _seasonList.addAll(show?.seasons ?? []);
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
