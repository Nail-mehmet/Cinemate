class CastMember {
  final String name;
  final String profilePath;

  CastMember({
    required this.name,
    required this.profilePath,
  });

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      name: json['name'] ?? '',
      profilePath: json['profile_path'] ?? '',
    );
  }
}
