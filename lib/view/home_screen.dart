import 'package:flutter/material.dart';
import 'package:movies/model/person_model.dart';
import 'package:movies/resources/carousel_images_list.dart';
import 'package:movies/view/search_moviestvshow_screen.dart';
import 'package:provider/provider.dart';
import '../resources/constants.dart';
import '../utilities/app_color.dart';
import '../utilities/routes/routes_name.dart';
import '../view_model/home_view_model.dart';
import '../view_model/movieslist_view_model.dart';
import '../view_model/peronlist_view_model.dart';
import '../view_model/tvshowslist_view-model.dart';
import 'carousel_view.dart';
import 'drawer_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final CarouselImagesList imagesList = CarouselImagesList();
  late MoviesListViewModel moviesProvider;
  late TvShowsListViewModel showsProvider;
  late PersonListViewModel perssonProvider;

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

  /// This function says that if the user scroll 90% percent of the screen then return true.
  /// On the bases of the true and false we fetch further or next page movies.
  bool _isMoviesNearEnd(ScrollNotification scrollInfo) {
    return scrollInfo.metrics.pixels >=
        (scrollInfo.metrics.maxScrollExtent * 0.95);
  }

  bool _isTvShowNearEnd(ScrollNotification scrollInfo) {
    return scrollInfo.metrics.pixels >=
        (scrollInfo.metrics.maxScrollExtent * 0.95);
  }

  bool _isPersonNearEnd(ScrollNotification scrollInfo) {
    return scrollInfo.metrics.pixels >=
        (scrollInfo.metrics.maxScrollExtent * .95);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    final homeProvider = Provider.of<HomeViewModel>(context);
    return Scaffold(
        drawer: DrawerView(
          height: height,
        ),
        key: scaffoldKey,
        backgroundColor: appColor,
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          elevation: 1,
          backgroundColor: appColor,
          centerTitle: true,
          title: const Text(
            'Discover',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            InkWell(
              splashColor: Colors.transparent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchMoviesTvShowScreen(),
                  ),
                );
              },
              child: const Icon(Icons.search),
            ),
            SizedBox(
              width: height * .025,
            ),
          ],
        ),
        body: homeProvider.isLoading
            ? const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: CircularProgressIndicator(
                    color: whiteColor,
                  ),
                ),
              )
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MoviesCarousel(height: height),
                    SizedBox(height: height * .02),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(children: [
                          Categories(
                              name: 'Popular',
                              onTap: () {
                                Navigator.pushNamed(
                                    context, RoutesName.moviesCategoryScreen);
                              }),
                          SizedBox(
                            height: height * .005,
                          ),
                          Container(
                            height: height * .216,
                            child: Consumer<MoviesListViewModel>(
                              builder: (context, moviesProvider, child) {
                                if (moviesProvider.allMovies.isEmpty &&
                                    !moviesProvider.isFetching) {
                                  return notFoundMessage;
                                }
                                return NotificationListener<ScrollNotification>(
                                  onNotification: (scrollInfo) {
                                    if (_isMoviesNearEnd(scrollInfo)) {
                                      moviesProvider.fetchMoviesList();
                                    }
                                    return true;
                                  },
                                  child: GridView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: moviesProvider.allMovies.length +
                                        (moviesProvider.isFetching ? 1 : 0),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 1,
                                      mainAxisSpacing: 8,
                                      crossAxisSpacing: 8,
                                      mainAxisExtent: 90,
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

                                      return MoviesInfoContainer(
                                        height: height,
                                        title: movie.title ?? 'Unknown',
                                        posterUrl:
                                            movie.posterPath ?? 'no_image',
                                        year: movie.releaseDate ?? '---',
                                        averageVote: movie.voteAverage ?? 0.0,
                                        icon: Icons.star,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            height: height * .02,
                          ),
                          Categories(
                              name: 'Tv Shows',
                              onTap: () {
                                Navigator.pushNamed(
                                    context, RoutesName.tvShowsCategoryScreen);
                              }),
                          SizedBox(
                            height: height * .005,
                          ),
                          Container(
                            height: height * .216,
                            child: Consumer<TvShowsListViewModel>(
                              builder: (context, showsProvider, child) {
                                if (showsProvider.allTvShows.isEmpty &&
                                    !showsProvider.isFetching) {
                                  return notFoundMessage;
                                }
                                return NotificationListener<ScrollNotification>(
                                  onNotification: (scrollInfo) {
                                    if (_isTvShowNearEnd(scrollInfo)) {
                                      showsProvider.fetchTvShowsList();
                                    }
                                    return true;
                                  },
                                  child: GridView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: showsProvider.allTvShows.length +
                                        (showsProvider.isFetching ? 1 : 0),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 1,
                                      mainAxisSpacing: 8,
                                      crossAxisSpacing: 8,
                                      mainAxisExtent: 90,
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
                                      return MoviesInfoContainer(
                                        height: height,
                                        title: show.name ?? 'Unknown',
                                        posterUrl:
                                            show.posterPath ?? 'no_image',
                                        year: show.firstAirDate.toString(),
                                        averageVote: show.voteAverage ?? 0.0,
                                        icon: Icons.star,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            height: height * .02,
                          ),
                          Categories(name: 'Tv Models', onTap: () {}),
                          SizedBox(
                            height: height * .005,
                          ),
                          Container(
                            height: height * .216,
                            child: Consumer<PersonListViewModel>(
                              builder: (context, personProvider, child) {
                                if (personProvider.allPersonList.isEmpty &&
                                    !personProvider.isFetching) {
                                  return notFoundMessage;
                                }
                                return NotificationListener<ScrollNotification>(
                                  onNotification: (scrollInfo) {
                                    if (_isPersonNearEnd(scrollInfo)) {
                                      personProvider.fetchPersonList();
                                    }
                                    return true;
                                  },
                                  child: GridView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        personProvider.allPersonList.length +
                                            (personProvider.isFetching ? 1 : 0),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 1,
                                      mainAxisSpacing: 8,
                                      crossAxisSpacing: 8,
                                      mainAxisExtent: 90,
                                    ),
                                    itemBuilder: (context, index) {
                                      if (index ==
                                          personProvider.allPersonList.length) {
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
                          )
                        ]),
                      ),
                    ),
                  ],
                ),
              ));
  }
}

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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: height * .17,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Image(
                image: NetworkImage(
                  'https://image.tmdb.org/t/p/w500${person.profilePath}',
                ),
                errorBuilder: (context, error, child) {
                  return const Icon(
                    Icons.error,
                    color: Colors.white,
                    size: 30,
                  );
                },
                fit: BoxFit.cover,
              ),
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
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class Categories extends StatelessWidget {
  const Categories({
    super.key,
    required this.name,
    required this.onTap,
  });
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
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white,
            size: 14,
          )
        ],
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
