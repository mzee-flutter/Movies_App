import 'package:flutter/material.dart';
import 'package:movies/view_model/youtube_view_model/trailer_view_model.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../utilities/app_color.dart';

class TrailerScreen extends StatefulWidget {
  const TrailerScreen({super.key, required this.id});

  final String id;

  @override
  State<TrailerScreen> createState() => _TrailerScreenState();
}

class _TrailerScreenState extends State<TrailerScreen> {
  late TrailerViewModel trailerProvider;
  late Future<void> _initializeFuture;

  @override
  void initState() {
    super.initState();
    _initializeFuture = _initializeTrailer();
  }

  Future<void> _initializeTrailer() async {
    trailerProvider = Provider.of<TrailerViewModel>(context, listen: false);
    trailerProvider.initializeController(widget.id);
  }

  @override
  void dispose() {
    trailerProvider.disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColor,
      appBar: AppBar(
        backgroundColor: appColor,
        iconTheme: const IconThemeData(
          color: whiteColor,
        ),
      ),
      body: Consumer<TrailerViewModel>(
        builder: (context, trailerProvider, child) {
          final controller = trailerProvider.controller;
          if (controller == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: whiteColor,
              ),
            );
          } else if (controller.value.hasError) {
            return const Center(
              child: Text('Trailer not found'),
            );
          }
          return Center(
            child: YoutubePlayerBuilder(
              player: YoutubePlayer(
                controller: controller,
                showVideoProgressIndicator: true,
              ),
              builder: (context, player) => player,
            ),
          );
        },
      ),
    );
  }
}
