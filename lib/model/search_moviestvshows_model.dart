class SearchMoviesTvShowsModel {
  final int page;
  final List<MovieOrTvShow> results;
  final int totalPages;
  final int totalResults;

  SearchMoviesTvShowsModel({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory SearchMoviesTvShowsModel.fromJson(Map<String, dynamic> json) {
    return SearchMoviesTvShowsModel(
      page: json['page'],
      results: (json['results'] as List)
          .map((item) => MovieOrTvShow.fromJson(item))
          .toList(),
      totalPages: json['total_pages'],
      totalResults: json['total_results'],
    );
  }
}

class MovieOrTvShow {
  final int id;
  final String title;
  final String originalTitle;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String mediaType;
  final bool adult;
  final String originalLanguage;
  final List<int> genreIds;
  final double popularity;
  final String? firstAirDate;
  final String? releaseDate;
  final double voteAverage;
  final int voteCount;

  MovieOrTvShow({
    required this.id,
    required this.title,
    required this.originalTitle,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.mediaType,
    required this.adult,
    required this.originalLanguage,
    required this.genreIds,
    required this.popularity,
    this.firstAirDate,
    this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
  });

  factory MovieOrTvShow.fromJson(Map<String, dynamic> json) {
    return MovieOrTvShow(
      id: json['id'],
      title: json['title'] ?? json['name'],
      originalTitle: json['original_title'] ?? json['original_name'],
      overview: json['overview'],
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      mediaType: json['media_type'],
      adult: json['adult'] ?? false,
      originalLanguage: json['original_language'],
      genreIds: List<int>.from(json['genre_ids']),
      popularity: (json['popularity'] as num).toDouble(),
      firstAirDate: json['first_air_date'],
      releaseDate: json['release_date'],
      voteAverage: (json['vote_average'] as num).toDouble(),
      voteCount: json['vote_count'],
    );
  }
}
