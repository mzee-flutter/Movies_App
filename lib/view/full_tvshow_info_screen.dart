import 'package:flutter/material.dart';
import 'package:movies/resources/genre_ids_converter.dart';
import 'package:movies/view/episodes_screen.dart';
import 'package:provider/provider.dart';
import '../model/tvShow_season_model.dart';
import '../model/tvshowsList_model.dart';
import '../utilities/app_color.dart';
import '../view_model/youtube_view_model/tvshow_season_view_model.dart';

class FullTvShowInfoScreen extends StatefulWidget {
  const FullTvShowInfoScreen({super.key, required this.tvShow});

  final TvShow tvShow;

  @override
  State<FullTvShowInfoScreen> createState() => FullTvShowInfoScreenState();
}

class FullTvShowInfoScreenState extends State<FullTvShowInfoScreen> {
  late TvShowSeasonViewModel seasonProvider;
  final GenreIdsConverter _converter = GenreIdsConverter();

  @override
  void initState() {
    super.initState();

    final seasonProvider =
        Provider.of<TvShowSeasonViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      seasonProvider.fetchTvShowSeason(widget.tvShow.id ?? 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    return Scaffold(
      backgroundColor: appColor,
      appBar: AppBar(
        backgroundColor: appColor,
        automaticallyImplyLeading: true,
        leading: Consumer<TvShowSeasonViewModel>(
          builder: (context, seasonProvider, child) {
            return IconButton(
              onPressed: () {
                seasonProvider.seasonList.clear();

                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: whiteColor,
              ),
            );
          },
        ),
        actions: [
          const Icon(Icons.cast, color: Colors.white24),
          SizedBox(width: height * 0.02),
          const Icon(Icons.visibility, color: Colors.white24),
          SizedBox(width: height * 0.02),
          const Icon(Icons.search_rounded, color: whiteColor),
          SizedBox(width: height * 0.02),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: height * 0.23,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image(
                  image: NetworkImage(
                    widget.tvShow.backdropPath != null &&
                            widget.tvShow.backdropPath!.isNotEmpty
                        ? 'https://image.tmdb.org/t/p/w500/${widget.tvShow.backdropPath}'
                        : 'asset/images/placeholder.png',
                  ),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, child) {
                    return const Center(
                      child: Icon(
                        Icons.error,
                        size: 40,
                        color: whiteColor,
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(
              height: height * .011,
            ),
            Text(
              widget.tvShow.name.toString(),
              style: const TextStyle(
                color: whiteColor,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(
              height: height * 0.015,
            ),
            Text(
              'Show ID: ${widget.tvShow.id}',
              style: const TextStyle(color: Colors.grey),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: height * .25,
                      child: Text(
                        _converter
                            .getGenreNames(widget.tvShow.genreIds ?? [])
                            .toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    SizedBox(
                      height: height * .004,
                    ),
                    MovieProperty(
                      'Release Date: ${widget.tvShow.firstAirDate}',
                    ),
                  ],
                ),
                MaterialButton(
                  height: height * .05,
                  minWidth: height * .15,
                  color: whiteColor,
                  onPressed: () {},
                  child: const Row(
                    children: [
                      Icon(
                        Icons.play_arrow,
                        color: blackColor,
                      ),
                      Text(
                        'Watch Now',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: height * 0.001),
            Row(
              children: [
                const Text('Rating:', style: TextStyle(color: Colors.grey)),
                SizedBox(width: height * 0.01),
                const Icon(Icons.star, color: Colors.yellow, size: 15),
                SizedBox(width: height * 0.006),
                Text(
                  widget.tvShow.voteAverage.toString(),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: height * 0.001),
            MovieProperty('Popularity: ${widget.tvShow.popularity}'),
            MovieProperty('Original Title: ${widget.tvShow.originalName}'),
            MovieProperty(
                'Original Language: ${widget.tvShow.originalLanguage}'),
            MovieProperty('Adult: ${widget.tvShow.adult}'),
            MovieProperty('Video: ${widget.tvShow.originCountry}'),
            SizedBox(height: height * 0.01),
            Container(
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
            SizedBox(
              height: height * 0.01,
            ),
            Consumer<TvShowSeasonViewModel>(
                builder: (context, seasonProvider, child) {
              if (seasonProvider.isLoading &&
                  seasonProvider.seasonList.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: whiteColor,
                  ),
                );
              }
              if (!seasonProvider.isLoading && seasonProvider.show == null) {
                return const Center(
                  child: Text(
                    'No seasons available at the moment.',
                    style: TextStyle(
                      color: whiteColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: seasonProvider.seasonList.length,
                          itemBuilder: (context, index) {
                            if (index <= seasonProvider.seasonList.length) {
                              final season = seasonProvider.seasonList[index];
                              final show = seasonProvider.show;

                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EpisodesScreen(
                                        show: show!,
                                        season: season,
                                      ),
                                    ),
                                  );
                                },
                                child: TvShowSeason(
                                  height: height,
                                  season: season,
                                ),
                              );
                            } else if (seasonProvider.isLoading) {
                              const Center(
                                child: CircularProgressIndicator(
                                    color: whiteColor),
                              );
                            }
                            return null;
                          },
                        ),
                      )
                    ],
                  ),
                ),
              );
            }),
            // Expanded(
            //   child: Container(
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(5),
            //     ),
            //     child: Stack(
            //       children: [
            //         SingleChildScrollView(
            //           child: Text(
            //             widget.movie.overview.toString(),
            //             style: const TextStyle(color: Colors.grey),
            //           ),
            //         ),
            //         Positioned(
            //           bottom: 0,
            //           left: 0,
            //           right: 0,
            //           child: Container(
            //             height: height * .06,
            //             decoration: BoxDecoration(
            //               color: Colors.blue,
            //               gradient: LinearGradient(
            //                 begin: Alignment.topCenter,
            //                 end: Alignment.bottomCenter,
            //                 colors: [
            //                   appColor.withOpacity(0.2),
            //                   appColor,
            //                 ],
            //               ),
            //             ),
            //           ),
            //         )
            //       ],
            //     ),
            //   ),
            // )
          ],
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
                    image: season.posterPath != null &&
                            season.posterPath!.isNotEmpty
                        ? NetworkImage(
                            'https://image.tmdb.org/t/p/w500/${season.posterPath}',
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
                        'Episodes: ${season.episodeCount.toString()}',
                        style: const TextStyle(
                          color: whiteColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              height: season.overview.isNotEmpty ? height * .08 : 0,
              width: double.infinity,
              child: Text(
                season.overview,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MovieProperty extends StatelessWidget {
  const MovieProperty(this.property, {super.key});

  final String property;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    return Column(
      children: [
        SizedBox(
          height: height * 0.001,
        ),
        Text(
          property,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
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
        Icon(
          icon,
          color: color,
          size: 23,
        ),
        SizedBox(
          width: height * 0.005,
        ),
        Text(
          title,
          style: const TextStyle(
            color: whiteColor,
          ),
        ),
      ],
    );
  }
}
