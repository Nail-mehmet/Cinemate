class ActorDetails {
  final int id;
  final String name;
  final String? biography;
  final String? birthday;
  final String? deathday;
  final String? placeOfBirth;
  final String profilePath;
  final double popularity;

  ActorDetails({
    required this.id,
    required this.name,
    this.biography,
    this.birthday,
    this.deathday,
    this.placeOfBirth,
    required this.profilePath,
    required this.popularity,
  });

  factory ActorDetails.fromJson(Map<String, dynamic> json) {
    return ActorDetails(
      id: json['id'],
      name: json['name'],
      biography: json['biography'],
      birthday: json['birthday'],
      deathday: json['deathday'],
      placeOfBirth: json['place_of_birth'],
      profilePath: json['profile_path'] ?? '',
      popularity: json['popularity']?.toDouble() ?? 0.0,
    );
  }
}