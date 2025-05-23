import '../../domain/entities/movie_detail.dart';

class MovieDetailModel extends MovieDetail {
  MovieDetailModel({
    required int id,
    required String title,
    required String posterPath,
    required String backdropPath,
    required List<String> genres,
    required int runtime,
    required String releaseDate,
    required String director,
    required List<CastMember> cast,
    required String overview,
    required double voteAverage,
    String? trailerKey, // 👈 Yeni eklenen trailerKey
  }) : super(
          id: id,
          title: title,
          posterPath: posterPath,
          backdropPath: backdropPath,
          genres: genres,
          runtime: runtime,
          releaseDate: releaseDate,
          director: director,
          cast: cast,
          overview: overview,
          voteAverage: voteAverage,
          trailerKey: trailerKey, // 👈 Super'e iletilen yeni alan
        );

  factory MovieDetailModel.fromJson(Map<String, dynamic> json) {
  // Director bilgisi (null-safe)
  final crew = (json['credits']?['crew'] as List<dynamic>?) ?? []; // 👈 Null kontrolü
  final directorEntry = crew.firstWhere(
    (member) => member['job'] == 'Director',
    orElse: () => null,
  );
  final directorName = directorEntry?['name'] ?? 'Unknown';

  // Cast bilgisi (null-safe)
  final castJson = (json['credits']?['cast'] as List<dynamic>?) ?? []; // 👈 Null kontrolü
  final castList = castJson.map((item) {
    return CastMember(
      name: item['name'] ?? '',
      profilePath: item['profile_path'] ?? '',
    );
  }).take(10).toList();

  // Trailer bilgisi (null-safe)
  final videos = (json['videos']?['results'] as List<dynamic>?) ?? []; // 👈 Null kontrolü
  final trailer = videos.firstWhere(
    (video) => video['type'] == 'Trailer' && video['site'] == 'YouTube',
    orElse: () => null,
  );
  final trailerKey = trailer?['key'] as String?; // 👈 Null olabilir

  return MovieDetailModel(
    id: json['id'] as int,
    title: json['title'] as String,
    posterPath: json['poster_path'] as String? ?? '',
    backdropPath: json['backdrop_path'] as String? ?? '',
    genres: (json['genres'] as List<dynamic>?)?.map((g) => g['name'] as String).toList() ?? [],
    runtime: json['runtime'] as int? ?? 0,
    releaseDate: json['release_date'] as String? ?? '',
    director: directorName,
    cast: castList,
    overview: json["overview"] as String? ?? "",
    voteAverage: (json["vote_average"] as num?)?.toDouble() ?? 0.0,
    trailerKey: trailerKey, // 👈 Null olabilir
  );
}
}