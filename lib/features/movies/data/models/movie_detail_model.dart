import '../../domain/entities/cast_member.dart';
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
    String? trailerKey,
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
    trailerKey: trailerKey,
  );

  factory MovieDetailModel.fromJson(Map<String, dynamic> json) {
    // Director bilgisi (daha güvenli versiyon)
    final crew = List<Map<String, dynamic>>.from(json['credits']?['crew'] ?? []);
    final directorEntry = crew.firstWhere(
          (member) => member['job'] == 'Director',
      orElse: () => {},
    );
    final directorName = directorEntry['name']?.toString() ?? 'Unknown';

    // Cast bilgisi (güncellenmiş versiyon)
    final castJson = List<Map<String, dynamic>>.from(json['credits']?['cast'] ?? []);
    final castList = castJson.map((item) {
      return CastMember(
        id: item['id'] as int? ?? 0, // 👈 ID eklendi
        name: item['name']?.toString() ?? 'Unknown',
        profilePath: item['profile_path']?.toString() ?? '',
      );
    }).take(10).toList();

    // Trailer bilgisi
    final videos = List<Map<String, dynamic>>.from(json['videos']?['results'] ?? []);
    final trailer = videos.firstWhere(
          (video) => video['type'] == 'Trailer' && video['site'] == 'YouTube',
      orElse: () => {},
    );
    final trailerKey = trailer['key']?.toString();

    return MovieDetailModel(
      id: json['id'] as int? ?? 0,
      title: json['title']?.toString() ?? 'No Title',
      posterPath: json['poster_path']?.toString() ?? '',
      backdropPath: json['backdrop_path']?.toString() ?? '',
      genres: List<Map<String, dynamic>>.from(json['genres'] ?? [])
          .map((g) => g['name']?.toString() ?? '')
          .where((name) => name.isNotEmpty)
          .toList(),
      runtime: json['runtime'] as int? ?? 0,
      releaseDate: json['release_date']?.toString() ?? '',
      director: directorName,
      cast: castList,
      overview: json['overview']?.toString() ?? 'No overview available',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      trailerKey: trailerKey,
    );
  }

  // JSON'a çevirme metodu (opsiyonel)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'genres': genres,
      'runtime': runtime,
      'release_date': releaseDate,
      'director': director,
      'cast': cast.map((c) => {
        'id': c.id,
        'name': c.name,
        'profile_path': c.profilePath,
      }).toList(),
      'overview': overview,
      'vote_average': voteAverage,
      'trailer_key': trailerKey,
    };
  }
}