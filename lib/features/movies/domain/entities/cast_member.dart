class CastMember {
  final int id;
  final String name;
  final String profilePath;

  CastMember({
    required this.id,
    required this.name,
    required this.profilePath,
  });

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      profilePath: json['profile_path'] ?? '',
    );
  }
}
