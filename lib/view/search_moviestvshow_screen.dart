import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../model/search_moviestvshows_model.dart';
import '../resources/components/media_card.dart';
import '../utilities/app_color.dart';
import '../utilities/media_mapper.dart';
import '../utilities/utils/utils.dart';
import '../view_model/search_moviestvshow_view_model.dart';
import 'full_movie_info_screen.dart';
import 'full_tvshow_info_screen.dart';

class SearchMoviesTvShowScreen extends StatefulWidget {
  const SearchMoviesTvShowScreen({super.key});
  @override
  State<SearchMoviesTvShowScreen> createState() =>
      SearchMoviesTvShowScreenState();
}

class SearchMoviesTvShowScreenState extends State<SearchMoviesTvShowScreen> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    // Local resources must be torn down *before* calling super.dispose() —
    // the original order (super first, then _focusNode.dispose()) disposes
    // the focus node after the framework has already finished disposing
    // this State, which is the wrong lifecycle order and can throw in
    // debug mode ("A FocusNode was used after being disposed" style
    // assertions if anything still references it mid-teardown).
    _focusNode.dispose();
    super.dispose();
  }

  bool _isScrollNearToEnd(ScrollNotification scrollInfo) {
    return scrollInfo.metrics.pixels >=
        (scrollInfo.metrics.maxScrollExtent * 0.95);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        // Search field now lives in `title` instead of being an Expanded
        // widget stuffed into `actions`. AppBar's `actions` row is meant
        // for small, tightly-sized icons — an Expanded text field in there
        // works by accident on some Flutter versions and is a common
        // source of "RenderFlex children have non-zero flex" layout
        // errors on others. `title` + `titleSpacing: 0` is the supported
        // way to get a full-width field next to a leading button.
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: whiteColor),
          onPressed: () {
            context.read<SearchMoviesTvShowViewModel>().clearSearch();
            Navigator.pop(context);
          },
        ),
        title: Consumer<SearchMoviesTvShowViewModel>(
          builder: (context, searchProvider, child) {
            return TextFormField(
              focusNode: _focusNode,
              controller: searchProvider.controller,
              style: const TextStyle(color: whiteColor),
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                hintText: 'Search movies...',
                hintStyle: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w400,
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                suffixIcon: searchProvider.isTextFieldEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close, color: whiteColor),
                        onPressed: () {
                          searchProvider.closeIconClick();
                          FocusScope.of(context).requestFocus(_focusNode);
                        },
                      ),
              ),
              cursorColor: Colors.deepOrangeAccent,
              onFieldSubmitted: (value) {
                _focusNode.unfocus();
                final title = searchProvider.controller.text.trim();
                if (title.isEmpty) {
                  Utils.flutterFlushBar(context, 'Invalid Input');
                  return;
                }
                searchProvider.fetchSearchResult(title);
              },
            );
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          child: Consumer<SearchMoviesTvShowViewModel>(
            builder: (context, searchProvider, child) {
              if (!searchProvider.isFetching &&
                  searchProvider.allMoviesOrTvShows.isEmpty) {
                return const Center(
                  child: Text(
                    'Search movies and Tv shows...',
                    style: TextStyle(color: whiteColor),
                  ),
                );
              }
              return NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (_isScrollNearToEnd(scrollInfo) &&
                      !searchProvider.isFetching &&
                      !searchProvider.isPagesResultsEnd) {
                    searchProvider.fetchSearchResult(
                        searchProvider.controller.text.trim());
                  }
                  return true;
                },
                child: GridView.builder(
                  itemCount: searchProvider.allMoviesOrTvShows.length +
                      (searchProvider.isFetching ||
                              searchProvider.isPagesResultsEnd
                          ? 1
                          : 0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 7.w,
                    mainAxisSpacing: 7.h,
                    mainAxisExtent: 177.h,
                  ),
                  itemBuilder: (context, index) {
                    if (index == searchProvider.allMoviesOrTvShows.length) {
                      if (searchProvider.isPagesResultsEnd) {
                        return const Center(child: Text('no more results..'));
                      }
                      return const Center(
                        child: CircularProgressIndicator(color: whiteColor),
                      );
                    }
                    final MovieOrTvShow item =
                        searchProvider.allMoviesOrTvShows[index];

                    // TMDB's multi-search endpoint can also return
                    // mediaType == 'person' results. Neither detail screen
                    // is a fit for those, so they're skipped here rather
                    // than incorrectly opened as a movie.
                    if (item.mediaType == 'person') {
                      return const SizedBox.shrink();
                    }
                    final isTv = item.mediaType == 'tv';

                    return MediaCard(
                      title: item.title,
                      posterPath: item.posterPath,
                      // Movies have releaseDate, TV results have
                      // firstAirDate — MovieOrTvShow carries both (one is
                      // always null depending on mediaType), so fall back
                      // between them instead of assuming every result has
                      // releaseDate the way the old code did.
                      dateLabel: item.releaseDate ?? item.firstAirDate ?? '',
                      voteAverage: item.voteAverage,
                      onTap: () {
                        _focusNode.unfocus();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => isTv
                                ? FullTvShowInfoScreen(
                                    tvShow: tvShowFromSearchResult(item))
                                : FullMovieInfoScreen(
                                    movie: movieFromSearchResult(item)),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
