import 'cast_member.dart';

class MovieDetail {
  final int id;
  final String title;
  final String posterPath;
  final String backdropPath;
  final List<String> genres;
  final int runtime;
  final String releaseDate;
  final String director;
  final List<CastMember> cast;
  final String overview;
  final double voteAverage;
  final String? trailerKey; // 👈 Yeni eklenen trailer key alanı (nullable)

  MovieDetail({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.backdropPath,
    required this.genres,
    required this.runtime,
    required this.releaseDate,
    required this.director,
    required this.cast,
    required this.overview,
    required this.voteAverage,
    this.trailerKey, // 👈 Optional (required eklenmez)
  });
}
/*
class CastMember {
  final String name;
  final String profilePath;

  CastMember({required this.name, required this.profilePath});
}*/