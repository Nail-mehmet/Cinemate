class Commune {
  final String id;
  final String text;
  final String? imageUrl;
  final String userId;
  final DateTime createdAt;

  Commune({
    required this.id,
    required this.text,
    required this.userId,
    required this.createdAt,
    this.imageUrl,
  });

  Commune copyWith({
    String? text,
    String? imageUrl,
    String? userId,
    DateTime? createdAt,
  }) {
    return Commune(
      id: id,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Commune.fromMap(Map<String, dynamic> data) {
    return Commune(
      id: data['id'] as String,
      text: data['text'] ?? '',
      imageUrl: data['image_url'] as String?,
      userId: data['user_id'] as String,
      createdAt: DateTime.parse(data['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap({required String communityId}) {
    return {
      'id': id,
      'text': text,
      'image_url': imageUrl,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'community_id': communityId,
    };
  }
}
