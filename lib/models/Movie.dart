
class Movie {
  final String? backdropPath;
  final int? id;
  final String? originalLanguage;
  final String? originalTitle;
  final String? overview;
  final double? popularity;
  final String? posterPath;
  final String? releaseDate;
  final String? title;
  final bool? video;
  final int? voteCount;
  final String? voteAverage;

  String? error;

  Movie(
      {this.backdropPath,
      this.id,
      this.originalLanguage,
      this.originalTitle,
      this.overview,
      this.popularity,
      this.posterPath,
      this.releaseDate,
      this.title,
      this.video,
      this.voteCount,
      this.voteAverage});

  Movie.fromJson(Map<String, dynamic> json):
        backdropPath= json['backdrop_path'],
        id= json['id'],
        originalLanguage= json['original_language'],
        originalTitle= json['original_title'],
        overview= json['overview'],
        popularity= json['popularity'],
        posterPath= json['poster_path'],
        releaseDate= json['release_date'],
        title= json['title'],
        video= json['video'],
        voteCount= json['vote_count'],
        voteAverage= json['vote_average'].toString();

  Map<String, dynamic> toJson() => {
        'backdrop_path': backdropPath,
        'id': id,
        'original_language': originalLanguage,
        'original_title': originalTitle,
        'overview': overview,
        'popularity': popularity,
        'poster_path': posterPath,
        'release_date': releaseDate,
        'title': title,
        'video': video,
        'vote_count': voteCount,
        'vote_average': voteAverage,
      };

  @override
  String toString() {
    return '{backdropPath: $backdropPath, id: $id, originalLanguage: $originalLanguage, originalTitle: $originalTitle, overview: $overview, popularity: $popularity, posterPath: $posterPath, releaseDate: $releaseDate, title: $title, video: $video, voteCount: $voteCount, voteAverage: $voteAverage, error: $error}';
  }

}