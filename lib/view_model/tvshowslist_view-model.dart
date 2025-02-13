import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:movies/model/tvshowsList_model.dart';
import 'package:movies/repository/tvshow_list_repository.dart';

class TvShowsListViewModel with ChangeNotifier {
  final TvShowsRepository showsRepo = TvShowsRepository();

  int currentPage = 1;
  List<TvShow> allTvShows = [];
  int totalPages = 1;
  bool _isFetching = false;

  bool get isFetching => _isFetching;

  Future<void> fetchTvShowsList() async {
    if (_isFetching || currentPage > totalPages) return;
    _isFetching = true;
    notifyListeners();

    try {
      TvShowsListModel tvShow = await showsRepo.fetchTvShowsList(currentPage);
      totalPages = tvShow.totalPages ?? 1;
      allTvShows.addAll(tvShow.tvShows ?? []);

      currentPage++;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }
}
