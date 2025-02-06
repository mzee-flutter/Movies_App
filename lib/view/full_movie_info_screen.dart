import 'package:flutter/material.dart';
import 'package:movies/model/youtube_videos_model.dart';
import 'package:movies/resources/genre_ids_converter.dart';
import 'package:movies/view/trailer_screen.dart';
import 'package:movies/view_model/youtube_view_model/youtube_videos_view_model.dart';
import 'package:provider/provider.dart';
import '../model/movieslist_model.dart';
import '../utilities/app_color.dart';
import 'package:timeago/timeago.dart' as timeago;

class FullMovieInfoScreen extends StatefulWidget {
  const FullMovieInfoScreen({super.key, required this.movie});
  final Movies movie;
  @override
  State<FullMovieInfoScreen> createState() => FullMovieInfoScreenState();
}

class FullMovieInfoScreenState extends State<FullMovieInfoScreen> {
  final GenreIdsConverter _converter = GenreIdsConverter();
  late YoutubeVideosViewModel youtubeVideosProvider;
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    final youtubeVideosProvider =
        Provider.of<YoutubeVideosViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      youtubeVideosProvider.fetchYoutubeVideos(widget.movie.title ?? 'unknown');
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          !youtubeVideosProvider.isLoading &&
          youtubeVideosProvider.nextPageToken != null) {
        youtubeVideosProvider.fetchYoutubeVideos(
          widget.movie.title ?? 'unknown',
          pageToken: youtubeVideosProvider.nextPageToken,
        );
      }
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
        leading: Consumer<YoutubeVideosViewModel>(
          builder: (context, youtubeVideosProvider, child) {
            return IconButton(
              onPressed: () {
                youtubeVideosProvider.clearTrailerList();
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
                  image: NetworkImage(widget.movie.backdropPath != null &&
                          widget.movie.backdropPath!.isNotEmpty
                      ? 'https://image.tmdb.org/t/p/w500/${widget.movie.backdropPath}'
                      : 'images/placeholder.png'),
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
            ),
            SizedBox(
              height: height * .011,
            ),
            Text(
              widget.movie.title.toString(),
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
              'Movie ID: ${widget.movie.id}',
              style: const TextStyle(color: Colors.grey),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: height * .25,
                      child: Text(
                        _converter
                            .getGenreNames(widget.movie.genreIds ?? [])
                            .toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    SizedBox(
                      height: height * .004,
                    ),
                    MovieProperty('Release Date: ${widget.movie.releaseDate}',
                        height: height),
                  ],
                ),
                Consumer<YoutubeVideosViewModel>(
                  builder: (context, youtubeVideosProvider, child) {
                    String firstVideoId = '';
                    if (youtubeVideosProvider.trailers.isNotEmpty) {
                      firstVideoId =
                          youtubeVideosProvider.trailers[0].id.videoId;
                    }

                    return MaterialButton(
                      height: height * .05,
                      minWidth: height * .15,
                      color: whiteColor,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TrailerScreen(id: firstVideoId),
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
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
                    );
                  },
                ),
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
                  widget.movie.voteAverage.toString(),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: height * 0.001),
            MovieProperty('Popularity: ${widget.movie.popularity}',
                height: height),
            MovieProperty('Original Title: ${widget.movie.originalTitle}',
                height: height),
            MovieProperty('Original Language: ${widget.movie.originalLanguage}',
                height: height),
            MovieProperty('Adult: ${widget.movie.adult}', height: height),
            MovieProperty('Video: ${widget.movie.video}', height: height),
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

            Consumer<YoutubeVideosViewModel>(
                builder: (context, youtubeVideosProvider, child) {
              if (youtubeVideosProvider.isLoading &&
                  youtubeVideosProvider.trailers.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: whiteColor,
                  ),
                );
              }
              if (!youtubeVideosProvider.isLoading &&
                  youtubeVideosProvider.response == null) {
                return const Center(
                  child: Text(
                    'Something went wrong, please try again.',
                    style: TextStyle(
                      color: whiteColor,
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
                            itemCount: youtubeVideosProvider.trailers.length +
                                (youtubeVideosProvider.isLoading ? 1 : 0),
                            controller: _scrollController,
                            itemBuilder: (context, index) {
                              if (index <
                                  youtubeVideosProvider.trailers.length) {
                                final video =
                                    youtubeVideosProvider.trailers[index];
                                final videoID = video.id.videoId;

                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TrailerScreen(
                                          id: videoID,
                                        ),
                                      ),
                                    );
                                  },
                                  child: YoutubeTrailer(
                                    height: height,
                                    video: video,
                                  ),
                                );
                              } else if (youtubeVideosProvider.isLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: whiteColor,
                                  ),
                                );
                              }
                              return null;
                            }),
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

class YoutubeTrailer extends StatelessWidget {
  const YoutubeTrailer({
    super.key,
    required this.height,
    required this.video,
  });

  final double height;
  final VideoItem video;

  @override
  Widget build(BuildContext context) {
    final imageHeight =
        video.snippet.thumbnails.defaultThumbnail.height.toDouble();
    final imageWidth =
        video.snippet.thumbnails.defaultThumbnail.width.toDouble();
    return Padding(
      padding: EdgeInsets.only(bottom: height * 0.02),
      child: Container(
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image(
                image: NetworkImage(
                  video.snippet.thumbnails.high.url,
                ),
                height: imageHeight,
                width: imageWidth,
                fit: BoxFit.cover,
                errorBuilder: (context, error, child) {
                  return const Icon(
                    Icons.error,
                    color: whiteColor,
                  );
                },
              ),
            ),
            SizedBox(width: height * .025),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    video.snippet.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: whiteColor,
                    ),
                  ),
                  Text(
                    video.snippet.channelTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  Text(
                    timeago.format(
                      DateTime.parse(video.snippet.publishTime),
                    ),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
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

class MovieProperty extends StatelessWidget {
  const MovieProperty(this.property, {super.key, required this.height});

  final String property;
  final double height;

  @override
  Widget build(BuildContext context) {
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
