import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movies/view_model/youtube_view_model/trailer_view_model.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../utilities/app_color.dart';

class TrailerScreen extends StatefulWidget {
  const TrailerScreen({super.key, required this.id, this.title});

  final String id;

  /// Optional — shown in the top overlay when provided. Call sites that
  /// only pass `id` (there are a few already) keep compiling unchanged.
  final String? title;

  @override
  State<TrailerScreen> createState() => _TrailerScreenState();
}

class _TrailerScreenState extends State<TrailerScreen> {
  late TrailerViewModel trailerProvider;
  Timer? _hideTimer;
  bool _showControls = true;
  bool _isFullScreen = false;
  double _speed = 1.0;

  static const _speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  @override
  void initState() {
    super.initState();
    trailerProvider = Provider.of<TrailerViewModel>(context, listen: false);
    trailerProvider.initializeController(widget.id);
    // No AppBar, full-bleed video — matches what was asked for. Restored
    // in dispose() below so the rest of the app doesn't stay in immersive
    // mode after leaving this screen.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _resetHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    trailerProvider.disposeController();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  void _resetHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      final controller = trailerProvider.controller;
      if (mounted && (controller?.value.isPlaying ?? false)) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _resetHideTimer();
  }

  void _seekBy(Duration offset) {
    final controller = trailerProvider.controller;
    if (controller == null) return;
    final duration = controller.metadata.duration;
    var target = controller.value.position + offset;
    if (target < Duration.zero) target = Duration.zero;
    if (duration > Duration.zero && target > duration) target = duration;
    controller.seekTo(target);
    _resetHideTimer();
  }

  void _togglePlayPause() {
    final controller = trailerProvider.controller;
    if (controller == null) return;
    controller.value.isPlaying ? controller.pause() : controller.play();
    _resetHideTimer();
  }

  // "Fullscreen" here just means landscape — this screen is already
  // edge-to-edge with no AppBar in every orientation, so there's no
  // separate fullscreen route to manage. Handling it this way (instead of
  // controller.toggleFullScreenMode(), which hands off to the package's
  // own fullscreen route showing only the raw player) is what keeps our
  // GestureDetector and custom overlay working after rotating.
  void _toggleFullScreen() {
    setState(() => _isFullScreen = !_isFullScreen);
    SystemChrome.setPreferredOrientations(
      _isFullScreen
          ? [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]
          : [DeviceOrientation.portraitUp],
    );
    _resetHideTimer();
  }

  void _pickSpeed() {
    final controller = trailerProvider.controller;
    if (controller == null) return;
    _hideTimer?.cancel();
    showModalBottomSheet(
      context: context,
      backgroundColor: appColor,
      // Without this, a bottom sheet is capped at 9/16 of the screen
      // height by default — eight ListTiles comfortably exceed that,
      // which is exactly what caused the overflow. isScrollControlled
      // lets it use the full available height, and the ConstrainedBox +
      // ListView below make it scroll instead of overflow if it still
      // doesn't fit (e.g. a short landscape screen).
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: ListView(
            shrinkWrap: true,
            children: _speeds
                .map(
                  (speed) => ListTile(
                    title: Text(
                      '${speed}x',
                      style: TextStyle(
                        color: whiteColor,
                        fontWeight: speed == _speed
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: speed == _speed
                        ? const Icon(Icons.check, color: whiteColor)
                        : null,
                    onTap: () {
                      controller.setPlaybackRate(speed);
                      setState(() => _speed = speed);
                      Navigator.pop(context);
                      _resetHideTimer();
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return hours > 0
        ? '$hours:${two(minutes)}:${two(seconds)}'
        : '${two(minutes)}:${two(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TrailerViewModel>(
      builder: (context, trailerProvider, child) {
        final controller = trailerProvider.controller;

        if (controller == null) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator(color: whiteColor)),
          );
        }
        if (controller.value.hasError) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'This video is unavailable.',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Using YoutubePlayer directly (not wrapped in YoutubePlayerBuilder)
        // is deliberate: YoutubePlayerBuilder's fullscreen mode swaps to
        // showing the raw `player` alone on its own route, which is
        // exactly what left fullscreen with no working controls before.
        // Fullscreen is handled entirely by _toggleFullScreen() above
        // instead, so the same Stack/GestureDetector/overlay stays live
        // through rotation.
        final player = YoutubePlayer(
          controller: controller,
          showVideoProgressIndicator: false,
        );

        return Scaffold(
          backgroundColor: Colors.black,
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggleControls,
            onDoubleTapDown: (details) {
              final width = MediaQuery.of(context).size.width;
              _seekBy(Duration(
                  seconds: details.localPosition.dx < width / 2 ? -10 : 10));
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Center(child: player),
                IgnorePointer(
                  ignoring: !_showControls,
                  child: AnimatedOpacity(
                    opacity: _showControls ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: _ControlsOverlay(
                      controller: controller,
                      title: widget.title,
                      speed: _speed,
                      isFullScreen: _isFullScreen,
                      onBack: () => Navigator.pop(context),
                      onSpeedTap: _pickSpeed,
                      onPlayPause: _togglePlayPause,
                      onSeekBack: () => _seekBy(const Duration(seconds: -10)),
                      onSeekForward: () => _seekBy(const Duration(seconds: 10)),
                      onFullscreenToggle: _toggleFullScreen,
                      formatDuration: _formatDuration,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({
    required this.controller,
    required this.title,
    required this.speed,
    required this.isFullScreen,
    required this.onBack,
    required this.onSpeedTap,
    required this.onPlayPause,
    required this.onSeekBack,
    required this.onSeekForward,
    required this.onFullscreenToggle,
    required this.formatDuration,
  });

  final YoutubePlayerController controller;
  final String? title;
  final double speed;
  final bool isFullScreen;
  final VoidCallback onBack;
  final VoidCallback onSpeedTap;
  final VoidCallback onPlayPause;
  final VoidCallback onSeekBack;
  final VoidCallback onSeekForward;
  final VoidCallback onFullscreenToggle;
  final String Function(Duration) formatDuration;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.65),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.65),
          ],
          stops: const [0, 0.25, 0.65, 1],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: onBack,
                  ),
                  Expanded(
                    child: Text(
                      title ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onSpeedTap,
                    child: Text(
                      '${speed}x',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 34,
                  icon: const Icon(Icons.replay_10, color: Colors.white),
                  onPressed: onSeekBack,
                ),
                const SizedBox(width: 28),
                IconButton(
                  iconSize: 58,
                  icon: Icon(
                    controller.value.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    color: Colors.white,
                  ),
                  onPressed: onPlayPause,
                ),
                const SizedBox(width: 28),
                IconButton(
                  iconSize: 34,
                  icon: const Icon(Icons.forward_10, color: Colors.white),
                  onPressed: onSeekForward,
                ),
              ],
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  Text(
                    formatDuration(controller.value.position),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Expanded(
                    child: ProgressBar(
                      controller: controller,
                      colors: const ProgressBarColors(
                        playedColor: Colors.redAccent,
                        handleColor: Colors.redAccent,
                      ),
                    ),
                  ),
                  Text(
                    formatDuration(controller.metadata.duration),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  IconButton(
                    icon: Icon(
                      isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                      color: Colors.white,
                    ),
                    onPressed: onFullscreenToggle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
