import 'package:flutter/cupertino.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class TrailerViewModel with ChangeNotifier {
  YoutubePlayerController? _controller;
  bool _isPlayerReady = false;

  YoutubePlayerController? get controller => _controller;
  bool get isPlayerReady => _isPlayerReady;

  void initializeController(String id) {
    disposeController();
    _controller = YoutubePlayerController(
      initialVideoId: id,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    )..addListener(() {
        if (_controller?.value.isReady == true && !_isPlayerReady) {
          _isPlayerReady = true;
          notifyListeners();
        }
      });
  }

  void disposeController() {
    _controller?.removeListener(_listener);
    _controller?.dispose();
    _controller = null;
    _isPlayerReady = false;
  }

  void _listener() {
    if (_controller?.value.isReady == true && !_isPlayerReady) {
      _isPlayerReady = true;
      notifyListeners();
    }
  }
}
