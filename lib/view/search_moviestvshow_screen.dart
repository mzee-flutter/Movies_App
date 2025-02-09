import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utilities/app_color.dart';
import '../utilities/utils/utils.dart';
import '../view_model/search_moviestvshow_view_model.dart';

class SearchMoviesTvShowScreen extends StatefulWidget {
  const SearchMoviesTvShowScreen({super.key});
  @override
  State<SearchMoviesTvShowScreen> createState() =>
      SearchMoviesTvShowScreenState();
}

class SearchMoviesTvShowScreenState extends State<SearchMoviesTvShowScreen> {
  final FocusNode _focusNode = FocusNode();
  late SearchMoviesTvShowViewModel searchProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
  }

  bool _isScrollNearToEnd(ScrollNotification scrollInfo) {
    return scrollInfo.metrics.pixels >=
        (scrollInfo.metrics.maxScrollExtent * 0.95);
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchMoviesTvShowViewModel>(context);
    final height = MediaQuery.of(context).size.height * 1;

    return Scaffold(
      backgroundColor: appColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: InkWell(
          onTap: () {
            searchProvider.clearSearch();
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_rounded,
            color: whiteColor,
          ),
        ),
        actions: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: height * .06),
              child: Consumer<SearchMoviesTvShowViewModel>(
                builder: (context, searchProvider, child) {
                  return TextFormField(
                    focusNode: _focusNode,
                    controller: searchProvider.controller,
                    style: const TextStyle(
                      color: whiteColor,
                    ),
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
                              icon: const Icon(
                                Icons.close,
                                color: whiteColor,
                              ),
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
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          child: Column(
            children: [
              Expanded(
                child: Consumer<SearchMoviesTvShowViewModel>(
                  builder: (context, searchProvider, child) {
                    if (!searchProvider.isFetching &&
                        searchProvider.allMoviesOrTvShows.isEmpty) {
                      return const Center(
                        child: Text(
                          'Search movies and Tv shows...',
                          style: TextStyle(
                            color: whiteColor,
                          ),
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
                        itemBuilder: (context, index) {
                          if (index ==
                              searchProvider.allMoviesOrTvShows.length) {
                            if (searchProvider.isPagesResultsEnd) {
                              return const Center(
                                  child: Text('no more results..'));
                            } else if (searchProvider.isFetching) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: whiteColor,
                                ),
                              );
                            }
                          }
                          final item = searchProvider.allMoviesOrTvShows[index];
                          return MoviesInfoContainer(
                              height: height,
                              title: item.title,
                              posterUrl: item.posterPath,
                              year: item.releaseDate.toString(),
                              averageVote: item.voteAverage);
                        },
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 7,
                          mainAxisSpacing: 7,
                          mainAxisExtent: 177,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MoviesInfoContainer extends StatelessWidget {
  const MoviesInfoContainer({
    super.key,
    required this.height,
    required this.title,
    required this.posterUrl,
    required this.year,
    required this.averageVote,
    this.icon,
  });

  final double height;
  final String title;
  final String? posterUrl;
  final String year;
  final double averageVote;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: height * .17,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Image(
              image: posterUrl != null && posterUrl!.isNotEmpty
                  ? NetworkImage('https://image.tmdb.org/t/p/w500/$posterUrl')
                  : const AssetImage('images/placeholder.png') as ImageProvider,
              fit: BoxFit.fitHeight,
              errorBuilder: (context, error, child) {
                return const Icon(
                  Icons.error,
                  color: Colors.white,
                  size: 30,
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Text(
                year.length >= 5 ? year.substring(0, 4) : year,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Icon(
                icon,
                color: Colors.yellow,
                size: 12,
              ),
              const SizedBox(
                width: 2,
              ),
              Text(
                averageVote.toStringAsFixed(1),
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ],
          ),
        )
      ],
    );
  }
}
