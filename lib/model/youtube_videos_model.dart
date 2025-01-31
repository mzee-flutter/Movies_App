class YoutubeSearchResponse {
  final String kind;
  final String etag;
  final String? nextPageToken;
  final String regionCode;
  final PageInfo pageInfo;
  final List<VideoItem> items;

  YoutubeSearchResponse({
    required this.kind,
    required this.etag,
    this.nextPageToken,
    required this.regionCode,
    required this.pageInfo,
    required this.items,
  });

  factory YoutubeSearchResponse.fromJson(Map<String, dynamic> json) {
    return YoutubeSearchResponse(
      kind: json['kind'],
      etag: json['etag'],
      nextPageToken: json['nextPageToken'],
      regionCode: json['regionCode'],
      pageInfo: PageInfo.fromJson(json['pageInfo']),
      items: (json['items'] as List)
          .map((item) => VideoItem.fromJson(item))
          .toList(),
    );
  }
}

class PageInfo {
  final int totalResults;
  final int resultsPerPage;

  PageInfo({
    required this.totalResults,
    required this.resultsPerPage,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) {
    return PageInfo(
      totalResults: json['totalResults'],
      resultsPerPage: json['resultsPerPage'],
    );
  }
}

class VideoItem {
  final String kind;
  final String etag;
  final VideoId id;
  final Snippet snippet;

  VideoItem({
    required this.kind,
    required this.etag,
    required this.id,
    required this.snippet,
  });

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      kind: json['kind'],
      etag: json['etag'],
      id: VideoId.fromJson(json['id']),
      snippet: Snippet.fromJson(json['snippet']),
    );
  }
}

class VideoId {
  final String kind;
  final String videoId;

  VideoId({
    required this.kind,
    required this.videoId,
  });

  factory VideoId.fromJson(Map<String, dynamic> json) {
    return VideoId(
      kind: json['kind'],
      videoId: json['videoId'],
    );
  }
}

class Snippet {
  final String publishedAt;
  final String channelId;
  final String title;
  final String description;
  final Thumbnails thumbnails;
  final String channelTitle;
  final String liveBroadcastContent;
  final String publishTime;

  Snippet({
    required this.publishedAt,
    required this.channelId,
    required this.title,
    required this.description,
    required this.thumbnails,
    required this.channelTitle,
    required this.liveBroadcastContent,
    required this.publishTime,
  });

  factory Snippet.fromJson(Map<String, dynamic> json) {
    return Snippet(
      publishedAt: json['publishedAt'],
      channelId: json['channelId'],
      title: json['title'],
      description: json['description'],
      thumbnails: Thumbnails.fromJson(json['thumbnails']),
      channelTitle: json['channelTitle'],
      liveBroadcastContent: json['liveBroadcastContent'],
      publishTime: json['publishTime'],
    );
  }
}

class Thumbnails {
  final Thumbnail defaultThumbnail;
  final Thumbnail medium;
  final Thumbnail high;

  Thumbnails({
    required this.defaultThumbnail,
    required this.medium,
    required this.high,
  });

  factory Thumbnails.fromJson(Map<String, dynamic> json) {
    return Thumbnails(
      defaultThumbnail: Thumbnail.fromJson(json['default']),
      medium: Thumbnail.fromJson(json['medium']),
      high: Thumbnail.fromJson(json['high']),
    );
  }
}

class Thumbnail {
  final String url;
  final int width;
  final int height;

  Thumbnail({
    required this.url,
    required this.width,
    required this.height,
  });

  factory Thumbnail.fromJson(Map<String, dynamic> json) {
    return Thumbnail(
      url: json['url'],
      width: json['width'],
      height: json['height'],
    );
  }
}
