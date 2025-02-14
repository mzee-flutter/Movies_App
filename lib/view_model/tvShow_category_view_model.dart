import 'package:flutter/foundation.dart';
import 'package:movies/repository/tvShows_category_repository.dart';
import 'package:movies/view_model/tvShows_dropDown_view_model.dart';
import '../model/tvshowsList_model.dart';

class TvShowsCategoryViewModel with ChangeNotifier {
  final TvShowsDropDownViewModel tvShowsDropDownProvider;

  final TvShowsCategoryRepository tvShowsCategoryRepo =
      TvShowsCategoryRepository();
  int currentPage = 1;
  int totalPages = 1;
  List<TvShow> allTvShows = [];

  bool _isFetching = false;
  bool get isFetching => _isFetching;

  TvShowsCategoryViewModel(this.tvShowsDropDownProvider) {
    tvShowsDropDownProvider.addListener(() {
      _resetAndFetchNewCategoryTvShows();
    });
  }

  Future<void> _resetAndFetchNewCategoryTvShows() async {
    currentPage = 1;
    totalPages = 1;
    allTvShows.clear();
    await fetchDifferentTvShowsCategory();
  }

  Future<void> fetchDifferentTvShowsCategory() async {
    if (_isFetching || currentPage > totalPages) return;

    _isFetching = true;
    notifyListeners();

    try {
      final tvShowCategory = tvShowsDropDownProvider
          .tvShowsCategory[tvShowsDropDownProvider.selectedCategory];
      final TvShowsListModel tvShowsList = await tvShowsCategoryRepo
          .fetchDifferentTvShowsCategory(tvShowCategory!, currentPage);
      totalPages = tvShowsList.totalPages ?? 1;
      allTvShows.addAll(tvShowsList.tvShows ?? []);
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
