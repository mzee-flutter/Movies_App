import 'package:flutter/foundation.dart';
import 'package:movies/repository/movieslist_repository.dart';
import '../model/movieslist_model.dart';

class MoviesListViewModel with ChangeNotifier {
  final MoviesRepository moviesRepo = MoviesRepository();
  int currentPage = 1;
  int totalPages = 1;
  List<Movies> allMovies = [];

  bool _isFetching = false;

  bool get isFetching => _isFetching;

  Future<void> fetchMoviesList() async {
    if (_isFetching || currentPage > totalPages) return;

    _isFetching = true;
    notifyListeners();

    try {
      final MoviesListModel moviesList =
          await moviesRepo.fetchMoviesList(currentPage);

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
