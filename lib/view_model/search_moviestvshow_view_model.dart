import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import '../model/search_moviestvshows_model.dart';
import '../repository/search_moviestvshows_repository.dart';

class SearchMoviesTvShowViewModel with ChangeNotifier {
  final SearchMoviesTvShowRepository searchRepo =
      SearchMoviesTvShowRepository();
  final TextEditingController _controller = TextEditingController();
  TextEditingController get controller => _controller;

  Timer? _debounce;

  int currentPage = 1;
  int totalPages = 1;

  bool get isPagesResultsEnd => currentPage > totalPages;

  bool _isFetching = false;
  bool get isFetching => _isFetching;

  final List<MovieOrTvShow> _allMoviesOrTvShows = [];
  List<MovieOrTvShow> get allMoviesOrTvShows => _allMoviesOrTvShows;

  bool _isTextFieldEmpty = false;
  bool get isTextFieldEmpty => _isTextFieldEmpty;

  /// here in the constructor of this class we call the updateSearchState-method
  /// and listen to the controller changes.
  SearchMoviesTvShowViewModel() {
    _controller.addListener(() {
      updateSearchState();
    });
  }

  ///In this method we call the dynamicSearch with the updated title
  void updateSearchState() {
    final title = _controller.text.trim();
    final wasTextFieldEmpty = _isTextFieldEmpty;
    _isTextFieldEmpty = title.isEmpty;

    if (!wasTextFieldEmpty || !_isTextFieldEmpty) {
      dynamicSearch(title);
    }
  }

  ///This method is used for the dynamic search means
  /// that every letter i enter in the text-field it fetch data accordingly
  /// if there is a 300 milliseconds time gap between letter entry
  void dynamicSearch(String title) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (title.isNotEmpty) {
        await fetchSearchResult(
          title,
          isNewSearch: true,
        );
      }
    });
  }

  /// this method is used in the arrow-back icon to clear and dispose everything
  void clearSearch({bool resetTextField = false}) {
    _debounce?.cancel();
    _allMoviesOrTvShows.clear();
    currentPage = 1;
    totalPages = 1;

    if (resetTextField) {
      _controller.clear();
    }
    notifyListeners();
  }

  ///this method is used in the suffix-close icon to clear the Text-field
  void closeIconClick() {
    clearSearch(resetTextField: true);
  }

  ///And this is main methode where we actually get the data from the api
  Future<void> fetchSearchResult(String title,
      {bool isNewSearch = false}) async {
    if (isNewSearch) {
      clearSearch();
    }
    if (_isFetching || isPagesResultsEnd) return;

    _isFetching = true;
    notifyListeners();

    try {
      final SearchMoviesTvShowsModel searchResult =
          await searchRepo.fetchSearchResult(title, currentPage);
      totalPages = searchResult.totalPages;
      _allMoviesOrTvShows.addAll(searchResult.results);
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
