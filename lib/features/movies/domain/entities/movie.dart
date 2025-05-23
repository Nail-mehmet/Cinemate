class Movie {
  final int id;
  final String title;
  final String? posterPath; // Nullable yapın
  final String? releaseDate; // Nullable yapın
  final String? backdropPath;
  final List<String> genres;
  
  Movie({
    required this.id,
    required this.title,
    this.posterPath, // required kaldırıldı
    this.releaseDate, // required kaldırıldı
    this.backdropPath,
    required this.genres,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as int? ?? 0, // Null fallback
      title: json['title'] as String? ?? 'Başlık Yok',
      posterPath: json['poster_path'] as String?,
      releaseDate: json['release_date'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      genres: (json['genres'] as List<dynamic>?)?.map((g) => g['name'].toString()).toList() ?? [],
    );
  }
}