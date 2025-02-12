import 'package:flutter/foundation.dart';
import 'package:movies/repository/movies_category_repository.dart';
import 'package:movies/view_model/movies_dropDown_view_model.dart';
import '../model/movieslist_model.dart';

class MoviesCategoryViewModel with ChangeNotifier {
  final MoviesDropDownViewModel dropDownProvider;
  final moviesCategoryRepo = MoviesCategoryRepository();
  int currentPage = 1;
  int totalPages = 1;
  List<Movies> allMovies = [];

  bool _isFetching = false;
  bool get isFetching => _isFetching;

  MoviesCategoryViewModel(this.dropDownProvider) {
    dropDownProvider.addListener(() {
      _resetAndFetchNewCategoryMovies();
    });
  }

  Future<void> _resetAndFetchNewCategoryMovies() async {
    currentPage = 1;
    totalPages = 1;
    allMovies.clear();
    await fetchDifferentMoviesCategory();
  }

  Future<void> fetchDifferentMoviesCategory() async {
    if (_isFetching || currentPage > totalPages) return;

    _isFetching = true;
    notifyListeners();
    try {
      final getMovieCategory =
          dropDownProvider.categoryMap[dropDownProvider.selectedCategory];
      final MoviesListModel moviesList = await moviesCategoryRepo
          .fetchDifferentMoviesCategory(getMovieCategory!, currentPage);

      totalPages = moviesList.totalPages ?? 1;
      allMovies.addAll(moviesList.movies ?? []);
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
