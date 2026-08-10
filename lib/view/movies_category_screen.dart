import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../resources/components/media_card.dart';
import '../resources/constants.dart';
import '../utilities/app_color.dart';
import '../view_model/movies_category_view_model.dart';
import '../view_model/movies_dropDown_view_model.dart';
import 'full_movie_info_screen.dart';

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
    return Scaffold(
      backgroundColor: appColor,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: appColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // NOTE: `buttonsList()` builds and returns a Widget directly from
          // the ViewModel — that's the View layer's job under MVVM. It
          // works, but it means this screen can't be reasoned about (or
          // tested) as UI+state separately anymore, and it couples the
          // ViewModel to Flutter's widget tree. Worth moving that button
          // row into a small widget here in the view that just reads
          // `dropDownProvider`'s selected-category state and calls a
          // `setCategory(...)` method on it, once you're ready for that
          // cleanup — didn't touch it now since I don't have
          // MoviesDropDownViewModel's source to do it without guessing.
          Consumer<MoviesDropDownViewModel>(
            builder: (context, dropDownProvider, child) {
              return dropDownProvider.buttonsList();
            },
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Column(
            children: [
              SizedBox(height: 5.h),
              Expanded(
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
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 7.w,
                          mainAxisSpacing: 7.h,
                          mainAxisExtent: 177.h,
                        ),
                        itemBuilder: (context, index) {
                          if (index ==
                              moviesCategoryProvider.allMovies.length) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            );
                          }
                          final movie = moviesCategoryProvider.allMovies[index];
                          return MediaCard(
                            title: movie.title ?? 'Unknown',
                            posterPath: movie.posterPath,
                            dateLabel: movie.releaseDate ?? '',
                            voteAverage: movie.voteAverage ?? 0.0,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FullMovieInfoScreen(movie: movie),
                              ),
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
