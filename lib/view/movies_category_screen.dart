import 'package:flutter/material.dart';
import 'package:movies/view/full_movie_info_screen.dart';
import 'package:provider/provider.dart';
import '../resources/constants.dart';
import '../utilities/app_color.dart';

import '../view_model/movies_dropDown_view_model.dart';
import '../view_model/movies_category_view_model.dart';

import 'home_screen.dart';

class MoviesCategoryScreen extends StatefulWidget {
  const MoviesCategoryScreen({super.key});

  @override
  State<MoviesCategoryScreen> createState() => MoviesCategoryScreenState();
}

class MoviesCategoryScreenState extends State<MoviesCategoryScreen> {
  @override
  void initState() {
    super.initState();
    final moviesCategoryProvider =
        Provider.of<MoviesCategoryViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (moviesCategoryProvider.allMovies.isEmpty) {
        moviesCategoryProvider.fetchDifferentMoviesCategory();
      }
    });
  }

  bool _isMoviesNearEnd(ScrollNotification scrollInfo) {
    return scrollInfo.metrics.pixels >=
        (scrollInfo.metrics.maxScrollExtent * 0.95);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    return Scaffold(
      backgroundColor: appColor,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: appColor,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        actions: [
          Consumer<MoviesDropDownViewModel>(
              builder: (context, dropDownProvider, child) {
            return dropDownProvider.buttonsList();
          }),
          SizedBox(
            width: height * .02,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Column(
            children: [
              SizedBox(
                height: height * .005,
              ),
              Expanded(
                /// i have remove the container from here
                child: Consumer<MoviesCategoryViewModel>(
                  builder: (context, moviesCategoryProvider, child) {
                    if (!moviesCategoryProvider.isFetching &&
                        moviesCategoryProvider.allMovies.isEmpty) {
                      return notFoundMessage;
                    }
                    return NotificationListener<ScrollNotification>(
                      onNotification: (scrollInfo) {
                        if (_isMoviesNearEnd(scrollInfo)) {
                          moviesCategoryProvider.fetchDifferentMoviesCategory();
                        }
                        return true;
                      },
                      child: GridView.builder(
                        itemCount: moviesCategoryProvider.allMovies.length +
                            (moviesCategoryProvider.isFetching ? 1 : 0),
                        scrollDirection: Axis.vertical,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 7,
                          mainAxisSpacing: 7,
                          mainAxisExtent: 177,
                        ),
                        itemBuilder: (context, index) {
                          if (index ==
                              moviesCategoryProvider.allMovies.length) {
                            return const Align(
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            );
                          }
                          final movie = moviesCategoryProvider.allMovies[index];
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          FullMovieInfoScreen(movie: movie)));
                            },
                            child: MoviesInfoContainer(
                              height: height,
                              title: movie.title ?? 'Unknown',
                              posterUrl: movie.posterPath ?? 'no_image',
                              year: movie.releaseDate ?? '---',
                              averageVote: movie.voteAverage ?? 0.0,
                              icon: Icons.star,
                            ),
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
    );
  }
}
