import 'package:flutter/material.dart';
import 'package:movies/view/trailer_screen.dart';
import 'package:movies/view_model/youtube_view_model/youtube_videos_view_model.dart';
import 'package:provider/provider.dart';

import '../model/tvShow_season_model.dart';
import '../utilities/app_color.dart';
import '../utilities/youtube_match.dart';
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

  // Tracks which specific episode is currently fetching a video, so only
  // that row shows a spinner instead of every row spinning together, and
  // so a second tap can't fire a second fetch while one's in flight.
  Episode? _loadingEpisode;

  @override
  void initState() {
    super.initState();

    episodeProvider =
        Provider.of<EpisodesListViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // Defensive clear before fetching: if EpisodesListViewModel is a
      // single shared instance (likely, given how it's provided) and its
      // fetch method appends rather than replacing episodesList, opening
      // a second season without this would leave the first season's
      // episodes sitting in the list alongside the new ones — which
      // matches what you're seeing. This guards the normal "open a
      // season" path; it can't protect against a still-in-flight fetch
      // from a previous season resolving late and landing after this
      // one — that needs a fix inside EpisodesListViewModel itself (see
      // the note at the bottom of this file).
      episodeProvider.episodesList.clear();
      episodeProvider.fetchSeasonEpisodes(
          widget.show.id, widget.season.seasonNumber);
    });
  }

  // This is the piece that was entirely missing — SingleEpisode had no
  // onTap at all. Reuses the exact same fetch-by-search-query-then-open-
  // TrailerScreen flow already used for the show's own trailer and the
  // movie screen, so there's still just one YouTube integration in the
  // app, not a third one.
  Future<void> _playEpisode(Episode episode) async {
    if (_loadingEpisode != null) return;
    setState(() => _loadingEpisode = episode);

    final youtubeProvider =
        Provider.of<YoutubeVideosViewModel>(context, listen: false);
    youtubeProvider.clearTrailerList();

    // Full episodes essentially never legitimately exist on YouTube, so a
    // query like "<show> Episode 1 Pilot" is asking it to guess at
    // something that mostly isn't there — and a generic title like
    // "Pilot" matches thousands of unrelated videos. Recaps/reviews
    // actually do commonly exist per-episode, and creators covering them
    // tend to title videos with the SxxEyy shorthand, so biasing toward
    // that pattern is a better bet for something real turning up.
    final seasonNum = widget.season.seasonNumber.toString().padLeft(2, '0');
    final episodeNum = episode.episodeNumber.toString().padLeft(2, '0');
    final query =
        '${widget.show.name} S${seasonNum}E$episodeNum ${episode.name} recap';
    await youtubeProvider.fetchYoutubeVideos(query);

    if (!mounted) return;
    setState(() => _loadingEpisode = null);

    final match =
        pickBestYoutubeMatch(youtubeProvider.trailers, widget.show.name);
    if (match == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No video found for this episode.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrailerScreen(
          id: match.id.videoId,
          title:
              '${widget.show.name} · ${widget.season.name} · Ep ${episode.episodeNumber}',
        ),
      ),
    );
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
      // Was SingleChildScrollView(child: Column(child: ListView.builder(
      // shrinkWrap: true, physics: const ScrollPhysics()))) — a scrollable
      // nested inside another scrollable, with shrinkWrap forcing the
      // inner list to build every item's layout upfront instead of lazily.
      // The Consumer is the only content, so it can just be the body
      // directly; Center below fills the available space on its own.
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Consumer<EpisodesListViewModel>(
            builder: (context, seasonProvider, child) {
              if (seasonProvider.isLoading &&
                  seasonProvider.episodesList.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: whiteColor),
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
                itemCount: seasonProvider.episodesList.length,
                itemBuilder: (context, index) {
                  final episode = seasonProvider.episodesList[index];
                  return InkWell(
                    splashColor: Colors.transparent,
                    onTap: _loadingEpisode != null
                        ? null
                        : () => _playEpisode(episode),
                    child: SingleEpisode(
                      height: height,
                      episode: episode,
                      isLoading: _loadingEpisode == episode,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class SingleEpisode extends StatelessWidget {
  const SingleEpisode({
    super.key,
    required this.height,
    required this.episode,
    this.isLoading = false,
  });

  final double height;
  final Episode episode;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: height * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Thumbnail with a play affordance layered on top — the
              // still image alone read as a generic list icon, not as
              // watchable content. Swaps to a spinner for whichever
              // episode is currently fetching.
              Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: episode.stillPath != null &&
                            episode.stillPath!.isNotEmpty
                        ? Image.network(
                            'https://image.tmdb.org/t/p/w300${episode.stillPath}',
                            height: 78,
                            width: 130,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, child) => Container(
                              height: 78,
                              width: 130,
                              color: Colors.grey.shade900,
                              child: const Icon(Icons.error, color: whiteColor),
                            ),
                          )
                        : Container(
                            height: 78,
                            width: 130,
                            color: Colors.grey.shade900,
                            child: const Icon(Icons.tv_outlined,
                                color: Colors.grey),
                          ),
                  ),
                  if (isLoading)
                    const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: whiteColor),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow,
                          color: whiteColor, size: 20),
                    ),
                ],
              ),
              SizedBox(width: height * .01),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${episode.episodeNumber}. ${episode.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: whiteColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          episode.airDate,
                          style: const TextStyle(
                            color: whiteColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (episode.runtime > 0) ...[
                          const Text(' · ',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(
                            '${episode.runtime}m',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                          ),
                        ],
                        if (episode.voteAverage > 0) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.star,
                              color: Colors.yellow, size: 12),
                          const SizedBox(width: 2),
                          Text(
                            episode.voteAverage.toStringAsFixed(1),
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                    // TMDB tags a handful of episodes as "finale" or
                    // "premiere" (episode_type) — surfacing that is a
                    // small, free bit of context that makes the list feel
                    // less like a flat dump of rows.
                    if (episode.episodeType.isNotEmpty &&
                        episode.episodeType != 'standard') ...[
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          episode.episodeType == 'finale'
                              ? 'SEASON FINALE'
                              : episode.episodeType == 'premiere'
                                  ? 'PREMIERE'
                                  : episode.episodeType.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          // Was a Container with a conditional height (`height * .08` or
          // `0`) — same hairline-overflow pattern already fixed on the
          // season tile and the movie/TV overview sections. Conditionally
          // including the Text avoids it here too.
          if (episode.overview.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              episode.overview,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

// NOTE — the deeper fix for stale/merged episode lists:
//
// The clear-before-fetch in initState() above handles the common case
// (open season, then open a different season) but can't protect against a
// slower fetch from a previous season resolving *after* a newer one and
// landing on top of it — that's a real race if someone taps between
// seasons quickly. The robust fix lives inside EpisodesListViewModel
// itself, something like:
//
//   int _requestId = 0;
//
//   Future<void> fetchSeasonEpisodes(int showId, int seasonNumber) async {
//     final requestId = ++_requestId;
//     isLoading = true;
//     notifyListeners();
//     final episodes = await api.getSeasonEpisodes(showId, seasonNumber);
//     if (requestId != _requestId) return; // a newer request has since started — discard this one
//     episodesList = episodes; // replace, not append
//     isLoading = false;
//     notifyListeners();
//   }
//
// The same pattern applies to TvShowSeasonViewModel.fetchTvShowSeason and
// YoutubeVideosViewModel.fetchYoutubeVideos, since all three showed the
// same symptom. I don't have any of those three files, so I can't apply
// this directly — paste them and I'll wire it in precisely rather than
// guess at their current structure.
