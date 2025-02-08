import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/tvShow_season_model.dart';
import '../utilities/app_color.dart';
import '../view_model/youtube_view_model/episodes_list_view_model.dart';

class EpisodesScreen extends StatefulWidget {
  const EpisodesScreen({
    super.key,
    required this.show,
    required this.season,
  });
  final TvShowSeason show;
  final Season season;

  @override
  State<EpisodesScreen> createState() => EpisodesScreenState();
}

class EpisodesScreenState extends State<EpisodesScreen> {
  late EpisodesListViewModel episodeProvider;

  @override
  void initState() {
    super.initState();

    episodeProvider =
        Provider.of<EpisodesListViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      episodeProvider.fetchSeasonEpisodes(
          widget.show.id, widget.season.seasonNumber);
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: appColor,
      appBar: AppBar(
        backgroundColor: appColor,
        iconTheme: const IconThemeData(color: whiteColor),
        centerTitle: true,
        title: Text(
          '${widget.show.name}: ${widget.season.name}',
          style: const TextStyle(color: whiteColor),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Column(
            children: [
              Consumer<EpisodesListViewModel>(
                builder: (context, seasonProvider, child) {
                  if (seasonProvider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: whiteColor,
                      ),
                    );
                  }
                  if (!seasonProvider.isLoading &&
                      seasonProvider.episodesList.isEmpty) {
                    return const Center(
                      child: Text(
                        'No episodes available.',
                        style: TextStyle(color: whiteColor),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    itemCount: seasonProvider.episodesList.length,
                    itemBuilder: (context, index) {
                      final episode = seasonProvider.episodesList[index];

                      return SingleEpisode(height: height, episode: episode);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SingleEpisode extends StatelessWidget {
  const SingleEpisode({super.key, required this.height, required this.episode});

  final double height;
  final Episode episode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: height * 0.02),
      child: Container(
        alignment: Alignment.centerLeft,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image(
                    alignment: Alignment.center,
                    image: episode.stillPath != null &&
                            episode.stillPath!.isNotEmpty
                        ? NetworkImage(
                            'https://image.tmdb.org/t/p/w500/${episode.stillPath}',
                          )
                        : const AssetImage('images/placeholder.png')
                            as ImageProvider,
                    height: 70,
                    width: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, child) {
                      return const Center(
                        child: Icon(
                          Icons.error,
                          color: whiteColor,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: height * .01,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${episode.episodeNumber}. ${episode.name}',
                        style: const TextStyle(
                          color: whiteColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        episode.airDate,
                        style: const TextStyle(
                          color: whiteColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              height: episode.overview.isNotEmpty ? height * .08 : 0,
              width: double.infinity,
              child: Text(
                episode.overview,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
