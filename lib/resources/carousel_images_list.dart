import 'package:flutter/cupertino.dart';

class CarouselImagesList {
  List<Widget> carouselImageList = [];

  final List<String> imagesUrl = [
    'images/money.jpg',
    'images/movie.png',
    'images/movie1.png',
    'images/movie2.png',
    'images/movie3.png',
    'images/movie4.png',
    'images/movie5.png',
    'images/movie6.png',
    'images/movie7.png',
    'images/series.png',
    'images/series1.png',
    'images/series2.png',
    'images/series3.png',
    'images/series4.png',
    'images/series5.png',
    'images/series6.png',
    'images/series7.png',
  ];

  CarouselImagesList() {
    carouselImageList = imagesUrl
        .map((image) => ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                image,
                fit: BoxFit.cover,
              ),
            ))
        .toList();
  }

  List<Widget> fetchImages() {
    return carouselImageList;
  }
}
