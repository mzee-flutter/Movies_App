import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utilities/app_color.dart';
import '../view_model/movieslist_view_model.dart';

class MoviesCarousel extends StatelessWidget {
  const MoviesCarousel({
    super.key,
    required this.height,
  });
  final double height;

  @override
  Widget build(BuildContext context) {
    final moviesViewModel = Provider.of<MoviesListViewModel>(context);

    if (moviesViewModel.isFetching && moviesViewModel.allMovies.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: whiteColor,
        ),
      );
    }

    if (moviesViewModel.allMovies.isEmpty) {
      return const Center(
          child: Text(
        'No movies available.',
        style: TextStyle(
          color: whiteColor,
        ),
      ));
    }

    return CarouselSlider.builder(
      itemCount: moviesViewModel.allMovies.length,
      itemBuilder: (context, index, realIndex) {
        final movie = moviesViewModel.allMovies[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            image: DecorationImage(
              image: NetworkImage(
                'https://image.tmdb.org/t/p/w500/${movie.backdropPath}',
              ),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
      options: CarouselOptions(
        height: height * .18,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
        enlargeCenterPage: true,
        padEnds: true,
        pauseAutoPlayOnTouch: true,
        disableCenter: true,
        autoPlayCurve: Curves.fastOutSlowIn,
      ),
    );
  }
}
