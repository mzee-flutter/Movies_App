import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movies/model/person_model.dart';
import 'package:movies/resources/carousel_images_list.dart';
import 'package:movies/view/search_moviestvshow_screen.dart';
import 'package:provider/provider.dart';

import '../resources/components/media_card.dart';
import '../resources/constants.dart';
import '../utilities/app_color.dart';
import '../utilities/routes/routes_name.dart';
import '../view_model/home_view_model.dart';
import '../view_model/movieslist_view_model.dart';
import '../view_model/peronlist_view_model.dart';
import '../view_model/tvshowslist_view-model.dart';
import 'carousel_view.dart';
import 'drawer_view.dart';
import 'full_movie_info_screen.dart';
import 'full_tvshow_info_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final CarouselImagesList imagesList = CarouselImagesList();

  @override
  void initState() {
    super.initState();
    final homeProvider = Provider.of<HomeViewModel>(context, listen: false);
    final moviesProvider =
        Provider.of<MoviesListViewModel>(context, listen: false);
    final showsProvider =
        Provider.of<TvShowsListViewModel>(context, listen: false);
    final personProvider =
        Provider.of<PersonListViewModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      homeProvider.loadHomeData(
        fetchMoviesList: () => moviesProvider.fetchMoviesList(),
        fetchTvShowsList: () => showsProvider.fetchTvShowsList(),
        fetchPersonList: () => personProvider.fetchPersonList(),
      );
    });
  }

  /// The three horizontal lists (movies / tv shows / people) previously had
  /// three identical copies of this exact check under different names
  /// (`_isMoviesNearEnd`, `_isTvShowNearEnd`, `_isPersonNearEnd`). One
  /// method, reused everywhere, is the single source of truth.
  bool _isNearEnd(ScrollNotification scrollInfo) {
    return scrollInfo.metrics.pixels >=
        (scrollInfo.metrics.maxScrollExtent * 0.95);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final homeProvider = Provider.of<HomeViewModel>(context);

    return Scaffold(
      drawer: DrawerView(height: height),
      key: scaffoldKey,
      backgroundColor: appColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 1,
        backgroundColor: appColor,
        centerTitle: true,
        title: const Text('Discover', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            splashRadius: 20.r,
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchMoviesTvShowScreen(),
                ),
              );
            },
          ),
          SizedBox(width: 4.w),
        ],
      ),
      // SafeArea now wraps the body unconditionally. Previously it only
      // wrapped the loading spinner branch — the actual content branch
      // rendered straight under the status bar / notch on devices where
      // that matters.
      body: SafeArea(
        child: homeProvider.isLoading
            ? const Center(child: CircularProgressIndicator(color: whiteColor))
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MoviesCarousel(height: height),
                    SizedBox(height: height * .02),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Categories(
                              name: 'Popular',
                              onTap: () => Navigator.pushNamed(
                                  context, RoutesName.moviesCategoryScreen),
                            ),
                            SizedBox(height: height * .005),
                            SizedBox(
                              height: height * .216,
                              child: Consumer<MoviesListViewModel>(
                                builder: (context, moviesProvider, child) {
                                  if (moviesProvider.allMovies.isEmpty &&
                                      !moviesProvider.isFetching) {
                                    return notFoundMessage;
                                  }
                                  return NotificationListener<
                                      ScrollNotification>(
                                    onNotification: (scrollInfo) {
                                      if (_isNearEnd(scrollInfo)) {
                                        moviesProvider.fetchMoviesList();
                                      }
                                      return true;
                                    },
                                    child: GridView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: moviesProvider
                                              .allMovies.length +
                                          (moviesProvider.isFetching ? 1 : 0),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 1,
                                        mainAxisSpacing: 8.w,
                                        crossAxisSpacing: 8.w,
                                        mainAxisExtent: 90.w,
                                      ),
                                      itemBuilder: (context, index) {
                                        if (index ==
                                            moviesProvider.allMovies.length) {
                                          return const Center(
                                            child: CircularProgressIndicator(
                                              color: appColor,
                                              backgroundColor: Colors.white,
                                            ),
                                          );
                                        }
                                        final movie =
                                            moviesProvider.allMovies[index];
                                        return MediaCard(
                                          title: movie.title ?? 'Unknown',
                                          posterPath: movie.posterPath,
                                          dateLabel: movie.releaseDate ?? '',
                                          voteAverage: movie.voteAverage ?? 0.0,
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  FullMovieInfoScreen(
                                                      movie: movie),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: height * .02),
                            Categories(
                              name: 'Tv Shows',
                              onTap: () => Navigator.pushNamed(
                                  context, RoutesName.tvShowsCategoryScreen),
                            ),
                            SizedBox(height: height * .005),
                            SizedBox(
                              height: height * .216,
                              child: Consumer<TvShowsListViewModel>(
                                builder: (context, showsProvider, child) {
                                  if (showsProvider.allTvShows.isEmpty &&
                                      !showsProvider.isFetching) {
                                    return notFoundMessage;
                                  }
                                  return NotificationListener<
                                      ScrollNotification>(
                                    onNotification: (scrollInfo) {
                                      if (_isNearEnd(scrollInfo)) {
                                        showsProvider.fetchTvShowsList();
                                      }
                                      return true;
                                    },
                                    child: GridView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: showsProvider
                                              .allTvShows.length +
                                          (showsProvider.isFetching ? 1 : 0),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 1,
                                        mainAxisSpacing: 8.w,
                                        crossAxisSpacing: 8.w,
                                        mainAxisExtent: 90.w,
                                      ),
                                      itemBuilder: (context, index) {
                                        if (index ==
                                            showsProvider.allTvShows.length) {
                                          return const Center(
                                            child: CircularProgressIndicator(
                                              color: appColor,
                                              backgroundColor: Colors.white,
                                            ),
                                          );
                                        }
                                        final show =
                                            showsProvider.allTvShows[index];
                                        return MediaCard(
                                          title: show.name ?? 'Unknown',
                                          posterPath: show.posterPath,
                                          dateLabel:
                                              show.firstAirDate?.toString() ??
                                                  '',
                                          voteAverage: show.voteAverage ?? 0.0,
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  FullTvShowInfoScreen(
                                                      tvShow: show),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: height * .02),
                            // Was labelled "Tv Models" with a no-op onTap in
                            // the original — this row actually renders
                            // people, and there's no "person detail" screen
                            // in scope yet, so the tap is intentionally left
                            // unset rather than silently doing nothing under
                            // a misleading label.
                            const Categories(
                              name: 'Popular People',
                              onTap: _noopPersonTap,
                            ),
                            SizedBox(height: height * .005),
                            SizedBox(
                              height: height * .216,
                              child: Consumer<PersonListViewModel>(
                                builder: (context, personProvider, child) {
                                  if (personProvider.allPersonList.isEmpty &&
                                      !personProvider.isFetching) {
                                    return notFoundMessage;
                                  }
                                  return NotificationListener<
                                      ScrollNotification>(
                                    onNotification: (scrollInfo) {
                                      if (_isNearEnd(scrollInfo)) {
                                        personProvider.fetchPersonList();
                                      }
                                      return true;
                                    },
                                    child: GridView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: personProvider
                                              .allPersonList.length +
                                          (personProvider.isFetching ? 1 : 0),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 1,
                                        mainAxisSpacing: 8.w,
                                        crossAxisSpacing: 8.w,
                                        mainAxisExtent: 90.w,
                                      ),
                                      itemBuilder: (context, index) {
                                        if (index ==
                                            personProvider
                                                .allPersonList.length) {
                                          return const Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                            ),
                                          );
                                        }
                                        final person =
                                            personProvider.allPersonList[index];
                                        return ActorsInfoContainer(
                                          height: height,
                                          person: person,
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

void _noopPersonTap() {}

class ActorsInfoContainer extends StatelessWidget {
  const ActorsInfoContainer({
    super.key,
    required this.height,
    required this.person,
  });

  final double height;
  final Person person;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: person.profilePath != null && person.profilePath!.isNotEmpty
                ? Image.network(
                    'https://image.tmdb.org/t/p/w500${person.profilePath}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, child) => const Icon(
                      Icons.error,
                      color: Colors.white,
                      size: 30,
                    ),
                  )
                : const Icon(Icons.person, color: Colors.white, size: 30),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            person.name ?? 'error',
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
          child: Text(
            person.knownForDepartment ?? 'Unknown',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class Categories extends StatelessWidget {
  const Categories({super.key, required this.name, required this.onTap});
  final String name;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded,
              color: Colors.white, size: 14),
        ],
      ),
    );
  }
}
