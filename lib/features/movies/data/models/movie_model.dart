import '../../domain/entities/movie.dart';

class MovieModel extends Movie {
  MovieModel({
    required int id,
    required String title,
    required String? posterPath, // Nullable yapıldı
    required String releaseDate,
    required String? backdropPath, // Nullable yapıldı
    required List<String> genres,
  }) : super(
          id: id,
          title: title,
          posterPath: posterPath ?? '', // Entity'de String olduğu için fallback
          releaseDate: releaseDate,
          backdropPath: backdropPath ?? '', // Entity'de String olduğu için fallback
          genres: genres,
        );

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] as int? ?? 0, // Null kontrolü
      title: json['title'] as String? ?? 'Başlık Yok',
      posterPath: json['poster_path'] as String?, // Nullable
      releaseDate: json['release_date'] as String? ?? 'Tarih Yok',
      backdropPath: json['backdrop_path'] as String?, // Nullable
      genres: (json['genre_ids'] as List<dynamic>?)?.map((id) => id.toString()).toList() ?? [],
    );
  }
}