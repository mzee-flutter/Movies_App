import 'package:flutter/material.dart';
import 'package:movies/resources/genre_ids_converter.dart';
import 'package:movies/view/episodes_screen.dart';
import 'package:movies/view/trailer_screen.dart';
import 'package:movies/view_model/youtube_view_model/youtube_videos_view_model.dart';
import 'package:provider/provider.dart';

import '../model/tvShow_season_model.dart';
import '../model/tvshowsList_model.dart';
import '../utilities/app_color.dart';
import '../utilities/youtube_match.dart';
import '../view_model/youtube_view_model/tvshow_season_view_model.dart';

class FullTvShowInfoScreen extends StatefulWidget {
  const FullTvShowInfoScreen({super.key, required this.tvShow});

  final TvShow tvShow;

  @override
  State<FullTvShowInfoScreen> createState() => FullTvShowInfoScreenState();
}

class FullTvShowInfoScreenState extends State<FullTvShowInfoScreen> {
  final GenreIdsConverter _converter = GenreIdsConverter();
  bool _fetchingTrailer = false;

  @override
  void initState() {
    super.initState();
    final seasonProvider =
        Provider.of<TvShowSeasonViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // Same defensive clear as EpisodesScreen, and the same caveat: this
      // protects the normal "open a different show" path, but a slower
      // fetch from a previous show resolving after this one starts still
      // needs a fix inside TvShowSeasonViewModel itself — see the note at
      // the end of this file.
      seasonProvider.seasonList.clear();
      seasonProvider.fetchTvShowSeason(widget.tvShow.id ?? 0);
    });
  }

  void _openOverview() {
    final overview = widget.tvShow.overview;
    if (overview == null || overview.isEmpty) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: appColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.tvShow.name ?? '',
                style: const TextStyle(
                  color: whiteColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                overview,
                style: TextStyle(
                    color: Colors.grey.shade300, fontSize: 14, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // "Watch Now" was previously wired to nothing (`onPressed: () {}`). A
  // whole series doesn't have one canonical trailer the way a single movie
  // does, but a general "<show name> trailer" search against the same
  // YoutubeVideosViewModel the movie screen and EpisodesScreen already use
  // gives it real behaviour without introducing a second YouTube
  // integration to maintain.
  Future<void> _watchTrailer() async {
    if (_fetchingTrailer) return;
    setState(() => _fetchingTrailer = true);

    final youtubeProvider =
        Provider.of<YoutubeVideosViewModel>(context, listen: false);
    youtubeProvider.clearTrailerList();
    await youtubeProvider
        .fetchYoutubeVideos('${widget.tvShow.name ?? ''} trailer');

    if (!mounted) return;
    setState(() => _fetchingTrailer = false);

    final match = pickBestYoutubeMatch(
        youtubeProvider.trailers, widget.tvShow.name ?? '');
    if (match == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No trailer found for this show.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrailerScreen(
          id: match.id.videoId,
          title: widget.tvShow.name,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: whiteColor),
          onPressed: () {
            // NOTE: kept as a direct call into the ViewModel's list, same
            // as your original — I don't have TvShowSeasonViewModel's
            // source to change it safely. The cleaner fix is a `reset()`
            // method on the ViewModel that clears its state *and* calls
            // notifyListeners() (this direct `.clear()` doesn't notify,
            // it just happens to not matter here because the screen is
            // being popped in the same breath).
            context.read<TvShowSeasonViewModel>().seasonList.clear();
            Navigator.pop(context);
          },
        ),
        actions: const [
          Icon(Icons.cast, color: Colors.white24),
          SizedBox(width: 16),
          Icon(Icons.visibility, color: Colors.white24),
          SizedBox(width: 16),
          Icon(Icons.search_rounded, color: whiteColor),
          SizedBox(width: 12),
        ],
      ),
      // SafeArea was missing here — same fix already applied to the movie
      // detail screen.
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: height * 0.23,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: widget.tvShow.backdropPath != null &&
                          widget.tvShow.backdropPath!.isNotEmpty
                      ? Image.network(
                          'https://image.tmdb.org/t/p/w500${widget.tvShow.backdropPath}',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child:
                                  CircularProgressIndicator(color: whiteColor),
                            );
                          },
                          errorBuilder: (context, error, child) => const Center(
                            child:
                                Icon(Icons.error, size: 40, color: whiteColor),
                          ),
                        )
                      // The original fallback here pointed at
                      // 'asset/images/placeholder.png', while the poster
                      // fallback further down used 'images/placeholder.png'
                      // (no 'asset/' prefix) — two different paths for what
                      // looks like the same intended asset, and neither is
                      // confirmed registered in pubspec.yaml. An icon
                      // fallback sidesteps depending on either.
                      : Container(
                          color: Colors.grey.shade900,
                          child: const Center(
                            child: Icon(Icons.tv_outlined, color: Colors.grey),
                          ),
                        ),
                ),
              ),
              SizedBox(height: height * .011),
              Text(
                widget.tvShow.name ?? 'Untitled',
                style: const TextStyle(
                  color: whiteColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: height * 0.008),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: _converter
                    .getGenreNames(widget.tvShow.genreIds ?? [])
                    .map((genre) => _GenreChip(label: genre))
                    .toList(),
              ),
              SizedBox(height: height * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.yellow, size: 15),
                      const SizedBox(width: 4),
                      Text(
                        (widget.tvShow.voteAverage ?? 0.0).toStringAsFixed(1),
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.tvShow.firstAirDate ?? '—',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                  MaterialButton(
                    height: height * .05,
                    minWidth: height * .15,
                    color: _fetchingTrailer ? Colors.grey.shade700 : whiteColor,
                    onPressed: _fetchingTrailer ? null : _watchTrailer,
                    child: _fetchingTrailer
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: whiteColor),
                          )
                        : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.play_arrow, color: blackColor),
                              Text('Watch Now',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                  ),
                ],
              ),
              // Overview was fully commented out in the version you pasted
              // — restored, same truncate-then-tap-to-expand pattern as the
              // movie screen.
              if (widget.tvShow.overview != null &&
                  widget.tvShow.overview!.isNotEmpty) ...[
                SizedBox(height: height * 0.012),
                GestureDetector(
                  onTap: _openOverview,
                  child: Text(
                    widget.tvShow.overview!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.grey.shade300, fontSize: 13, height: 1.3),
                  ),
                ),
              ],
              SizedBox(height: height * 0.01),
              SizedBox(
                height: height * .05,
                width: height * .37,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconsAndTitles(
                      height: height,
                      icon: Icons.live_tv,
                      title: 'Trailer',
                      color: whiteColor,
                    ),
                    const Spacer(),
                    IconsAndTitles(
                      height: height,
                      icon: Icons.collections_bookmark,
                      title: 'WatchList',
                      color: Colors.grey,
                    ),
                    const Spacer(),
                    IconsAndTitles(
                      height: height,
                      icon: Icons.archive,
                      title: 'Collection',
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.012),
              const Text(
                'Seasons',
                style: TextStyle(
                  color: whiteColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: height * 0.005),
              Consumer<TvShowSeasonViewModel>(
                builder: (context, seasonProvider, child) {
                  if (seasonProvider.isLoading &&
                      seasonProvider.seasonList.isEmpty) {
                    return const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(color: whiteColor),
                      ),
                    );
                  }
                  // Was `seasonProvider.show == null` — that checks the
                  // wrong thing for an empty-list message. `show` and
                  // `seasonList` are two different pieces of state; the
                  // list actually being rendered below is `seasonList`, so
                  // that's what the empty-state check needs to look at.
                  if (!seasonProvider.isLoading &&
                      seasonProvider.seasonList.isEmpty) {
                    return const Expanded(
                      child: Center(
                        child: Text(
                          'No seasons available at the moment.',
                          style: TextStyle(
                            color: whiteColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }

                  // The old itemBuilder had a dead trailing branch (an
                  // `else if (isLoading)` that built a spinner but never
                  // returned it, plus an `index <=` bound that could never
                  // actually be false) left over from a paginated-list
                  // pattern that doesn't apply here — fetchTvShowSeason
                  // loads the whole season list in one shot, so there's
                  // nothing to paginate.
                  return Expanded(
                    child: ListView.builder(
                      itemCount: seasonProvider.seasonList.length,
                      itemBuilder: (context, index) {
                        final season = seasonProvider.seasonList[index];
                        final show = seasonProvider.show;
                        return InkWell(
                          // splashColor: Colors.transparent,
                          onTap: show == null
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EpisodesScreen(
                                        show: show,
                                        season: season,
                                      ),
                                    ),
                                  );
                                },
                          child: TvShowSeason(height: height, season: season),
                        );
                      },
                    ),
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

class TvShowSeason extends StatelessWidget {
  const TvShowSeason({super.key, required this.height, required this.season});

  final double height;
  final Season season;

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
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: season.posterPath != null &&
                        season.posterPath!.isNotEmpty
                    ? Image.network(
                        'https://image.tmdb.org/t/p/w500${season.posterPath}',
                        height: 70,
                        width: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, child) => Container(
                          height: 70,
                          width: 100,
                          color: Colors.grey.shade900,
                          child: const Icon(Icons.error, color: whiteColor),
                        ),
                      )
                    : Container(
                        height: 70,
                        width: 100,
                        color: Colors.grey.shade900,
                        child:
                            const Icon(Icons.tv_outlined, color: Colors.grey),
                      ),
              ),
              SizedBox(width: height * .01),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      season.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: whiteColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      season.airDate,
                      style: const TextStyle(
                        color: whiteColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Episodes: ${season.episodeCount}',
                      style: const TextStyle(
                        color: whiteColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
          // Was a Container with a conditional height (`height * .08` or
          // `0`) wrapping the overview Text — a zero-height box still
          // tightly constrains its child rather than removing it, which is
          // exactly the kind of hairline overflow that's shown up
          // elsewhere in this app. Conditionally including the Text itself
          // avoids that risk entirely instead of trying to zero-size it.
          if (season.overview.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              season.overview,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }
}

class IconsAndTitles extends StatelessWidget {
  const IconsAndTitles({
    super.key,
    required this.height,
    required this.icon,
    required this.title,
    required this.color,
  });

  final IconData icon;
  final String title;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 23),
        SizedBox(width: height * 0.005),
        Text(title, style: const TextStyle(color: whiteColor)),
      ],
    );
  }
}

class _GenreChip extends StatelessWidget {
  const _GenreChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.grey.shade300, fontSize: 11),
      ),
    );
  }
}

// NOTE — same deeper fix needed here as in episodes_screen.dart: the
// clear-before-fetch in initState() handles opening a different show
// sequentially, but a slower fetch from a previous show resolving after a
// newer one has started can still land its stale seasons on top. The real
// fix is a request-id guard inside TvShowSeasonViewModel.fetchTvShowSeason
// (see the comment at the end of episodes_screen.dart for the exact
// pattern) — I don't have that file, so I can't apply it directly.
