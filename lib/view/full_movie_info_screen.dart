import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movies/model/youtube_videos_model.dart';
import 'package:movies/resources/genre_ids_converter.dart';
import 'package:movies/view/trailer_screen.dart';
import 'package:movies/view_model/youtube_view_model/youtube_videos_view_model.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../model/movieslist_model.dart';
import '../utilities/app_color.dart';

class FullMovieInfoScreen extends StatefulWidget {
  const FullMovieInfoScreen({super.key, required this.movie});
  final Movies movie;
  @override
  State<FullMovieInfoScreen> createState() => FullMovieInfoScreenState();
}

class FullMovieInfoScreenState extends State<FullMovieInfoScreen> {
  final GenreIdsConverter _converter = GenreIdsConverter();
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
      final youtubeVideosProvider =
          Provider.of<YoutubeVideosViewModel>(context, listen: false);
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _openOverview() {
    final overview = widget.movie.overview;
    if (overview == null || overview.isEmpty) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: appColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.all(20.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.movie.title ?? '',
                style: TextStyle(
                  color: whiteColor,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                overview,
                style: TextStyle(
                    color: Colors.grey.shade300, fontSize: 14.sp, height: 1.4),
              ),
            ],
          ),
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
        automaticallyImplyLeading: true,
        leading: Consumer<YoutubeVideosViewModel>(
          builder: (context, youtubeVideosProvider, child) {
            return IconButton(
              onPressed: () {
                youtubeVideosProvider.clearTrailerList();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_rounded, color: whiteColor),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 7.h, horizontal: 10.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: height * 0.23,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5.r),
                  child: widget.movie.backdropPath != null &&
                          widget.movie.backdropPath!.isNotEmpty
                      ? Image.network(
                          'https://image.tmdb.org/t/p/w500${widget.movie.backdropPath}',
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
                            child: Icon(Icons.error, color: whiteColor),
                          ),
                        )
                      : Container(
                          color: Colors.grey.shade900,
                          child: const Center(
                            child:
                                Icon(Icons.movie_outlined, color: Colors.grey),
                          ),
                        ),
                ),
              ),
              SizedBox(height: height * .011),
              Text(
                widget.movie.title ?? 'Untitled',
                style: TextStyle(
                  color: whiteColor,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: height * 0.008),
              Wrap(
                spacing: 6.w,
                runSpacing: 4.h,
                children: [
                  ..._converter
                      .getGenreNames(widget.movie.genreIds ?? [])
                      .map((genre) => _GenreChip(label: genre)),
                ],
              ),
              SizedBox(height: height * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.yellow, size: 15.sp),
                      SizedBox(width: 4.w),
                      Text(
                        (widget.movie.voteAverage ?? 0.0).toStringAsFixed(1),
                        style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        widget.movie.releaseDate ?? '—',
                        style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                      ),
                    ],
                  ),
                  Consumer<YoutubeVideosViewModel>(
                    builder: (context, youtubeVideosProvider, child) {
                      final hasTrailer =
                          youtubeVideosProvider.trailers.isNotEmpty;
                      // Previously this always navigated with the first
                      // trailer's id even when the list was still loading or
                      // came back empty, which meant the player screen could
                      // open with an empty/invalid video id. Now it's
                      // disabled until a trailer is actually available.
                      return MaterialButton(
                        height: height * .05,
                        minWidth: height * .15,
                        color: hasTrailer ? whiteColor : Colors.grey.shade700,
                        onPressed: hasTrailer
                            ? () {
                                final firstVideoId = youtubeVideosProvider
                                    .trailers[0].id.videoId;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TrailerScreen(
                                      id: firstVideoId,
                                      title: widget.movie.title,
                                    ),
                                  ),
                                );
                              }
                            : null,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_arrow,
                                color: hasTrailer
                                    ? blackColor
                                    : Colors.grey.shade400),
                            Text(
                              'Watch Now',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: hasTrailer
                                    ? blackColor
                                    : Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              if (widget.movie.overview != null &&
                  widget.movie.overview!.isNotEmpty) ...[
                SizedBox(height: height * 0.012),
                GestureDetector(
                  onTap: _openOverview,
                  child: Text(
                    widget.movie.overview!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.grey.shade300,
                        fontSize: 13.sp,
                        height: 1.3),
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
              SizedBox(height: height * 0.01),
              Consumer<YoutubeVideosViewModel>(
                builder: (context, youtubeVideosProvider, child) {
                  if (youtubeVideosProvider.isLoading &&
                      youtubeVideosProvider.trailers.isEmpty) {
                    return const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(color: whiteColor),
                      ),
                    );
                  }
                  if (!youtubeVideosProvider.isLoading &&
                      youtubeVideosProvider.trailers.isEmpty) {
                    return const Expanded(
                      child: Center(
                        child: Text(
                          'No videos found for this title.',
                          style: TextStyle(color: whiteColor),
                        ),
                      ),
                    );
                  }

                  return Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: youtubeVideosProvider.trailers.length +
                          (youtubeVideosProvider.isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < youtubeVideosProvider.trailers.length) {
                          final video = youtubeVideosProvider.trailers[index];
                          return InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TrailerScreen(
                                  id: video.id.videoId,
                                  title: widget.movie.title,
                                ),
                              ),
                            ),
                            child: YoutubeTrailer(height: height, video: video),
                          );
                        }
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: CircularProgressIndicator(color: whiteColor),
                          ),
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

class _GenreChip extends StatelessWidget {
  const _GenreChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.grey.shade300, fontSize: 11.sp),
      ),
    );
  }
}

class YoutubeTrailer extends StatelessWidget {
  const YoutubeTrailer({super.key, required this.height, required this.video});

  final double height;
  final VideoItem video;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: height * 0.02),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Image.network(
              video.snippet.thumbnails.high.url,
              height: 90.h,
              width: 120.w,
              fit: BoxFit.cover,
              errorBuilder: (context, error, child) =>
                  const Icon(Icons.error, color: whiteColor),
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
                  style: const TextStyle(color: whiteColor),
                ),
                Text(
                  video.snippet.channelTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                ),
                Text(
                  timeago.format(DateTime.parse(video.snippet.publishTime)),
                  style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                ),
              ],
            ),
          ),
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
