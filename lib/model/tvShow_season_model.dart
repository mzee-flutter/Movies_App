class TvShowSeason {
  final bool adult;
  final String? backdropPath;
  final List<dynamic> episodeRunTime;
  final String? firstAirDate;
  final int id;
  final bool inProduction;
  final List<String> languages;
  final String? lastAirDate;
  final Episode? lastEpisodeToAir;
  final String name;
  final Episode? nextEpisodeToAir;
  final int numberOfEpisodes;
  final int numberOfSeasons;
  final List<String> originCountry;
  final String originalLanguage;
  final String originalName;
  final String overview;
  final double popularity;
  final String? posterPath;
  final List<Season> seasons;
  final String status;
  final String tagline;
  final String type;
  final double voteAverage;
  final int voteCount;

  TvShowSeason({
    required this.adult,
    this.backdropPath,
    required this.episodeRunTime,
    this.firstAirDate,
    required this.id,
    required this.inProduction,
    required this.languages,
    this.lastAirDate,
    this.lastEpisodeToAir,
    required this.name,
    this.nextEpisodeToAir,
    required this.numberOfEpisodes,
    required this.numberOfSeasons,
    required this.originCountry,
    required this.originalLanguage,
    required this.originalName,
    required this.overview,
    required this.popularity,
    this.posterPath,
    required this.seasons,
    required this.status,
    required this.tagline,
    required this.type,
    required this.voteAverage,
    required this.voteCount,
  });

  factory TvShowSeason.fromJson(Map<String, dynamic> json) => TvShowSeason(
        adult: json["adult"],
        backdropPath: json["backdrop_path"],
        episodeRunTime: List<dynamic>.from(json["episode_run_time"] ?? []),
        firstAirDate: json["first_air_date"],
        id: json["id"],
        inProduction: json["in_production"],
        languages: List<String>.from(json["languages"] ?? []),
        lastAirDate: json["last_air_date"],
        lastEpisodeToAir: json["last_episode_to_air"] != null
            ? Episode.fromJson(json["last_episode_to_air"])
            : null,
        name: json["name"],
        nextEpisodeToAir: json["next_episode_to_air"] != null
            ? Episode.fromJson(json["next_episode_to_air"])
            : null,
        numberOfEpisodes: json["number_of_episodes"],
        numberOfSeasons: json["number_of_seasons"],
        originCountry: List<String>.from(json["origin_country"] ?? []),
        originalLanguage: json["original_language"],
        originalName: json["original_name"],
        overview: json["overview"] ?? "",
        popularity: (json["popularity"] as num?)?.toDouble() ?? 0.0,
        posterPath: json["poster_path"],
        seasons:
            (json["seasons"] as List).map((x) => Season.fromJson(x)).toList(),
        status: json["status"],
        tagline: json["tagline"] ?? "",
        type: json["type"],
        voteAverage: (json["vote_average"] as num?)?.toDouble() ?? 0.0,
        voteCount: json["vote_count"] ?? 0,
      );
}

class Episode {
  final int id;
  final String name;
  final String overview;
  final double voteAverage;
  final int voteCount;
  final String airDate;
  final int episodeNumber;
  final String episodeType;
  final String productionCode;
  final int runtime;
  final int seasonNumber;
  final int showId;
  final String? stillPath;

  Episode({
    required this.id,
    required this.name,
    required this.overview,
    required this.voteAverage,
    required this.voteCount,
    required this.airDate,
    required this.episodeNumber,
    required this.episodeType,
    required this.productionCode,
    required this.runtime,
    required this.seasonNumber,
    required this.showId,
    this.stillPath,
  });

  factory Episode.fromJson(Map<String, dynamic> json) => Episode(
        id: json["id"],
        name: json["name"],
        overview: json["overview"] ?? "",
        voteAverage: (json["vote_average"] as num?)?.toDouble() ?? 0.0,
        voteCount: json["vote_count"] ?? 0,
        airDate: json["air_date"] ?? "",
        episodeNumber: json["episode_number"],
        episodeType: json["episode_type"] ?? "",
        productionCode: json["production_code"] ?? "",
        runtime: json["runtime"] ?? 0,
        seasonNumber: json["season_number"],
        showId: json["show_id"],
        stillPath: json["still_path"],
      );
}

class Season {
  final String airDate;
  final int episodeCount;
  final int id;
  final String name;
  final String overview;
  final String? posterPath;
  final int seasonNumber;
  final double voteAverage;
  final List<Episode> episodes; // List of episodes for this season

  Season({
    required this.airDate,
    required this.episodeCount,
    required this.id,
    required this.name,
    required this.overview,
    this.posterPath,
    required this.seasonNumber,
    required this.voteAverage,
    required this.episodes,
  });

  factory Season.fromJson(Map<String, dynamic> json) => Season(
        airDate: json["air_date"] ?? "",
        episodeCount: json["episode_count"] ?? 0,
        id: json["id"],
        name: json["name"],
        overview: json["overview"] ?? "",
        posterPath: json["poster_path"],
        seasonNumber: json["season_number"],
        voteAverage: (json["vote_average"] as num?)?.toDouble() ?? 0.0,
        episodes: (json["episodes"] as List?)
                ?.map((x) => Episode.fromJson(x))
                .toList() ??
            [], // Parse episodes list
      );
}
