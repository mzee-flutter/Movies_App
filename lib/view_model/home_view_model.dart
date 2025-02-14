import 'package:flutter/foundation.dart';

class HomeViewModel with ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  Future<void> loadHomeData({
    required Future Function() fetchMoviesList,
    required Future<void> Function() fetchTvShowsList,
    required Future<void> Function() fetchPersonList,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await Future.wait([
        fetchMoviesList(),
        fetchTvShowsList(),
        fetchPersonList(),
      ]);
    } catch (e) {
      _isLoading = false;

      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
