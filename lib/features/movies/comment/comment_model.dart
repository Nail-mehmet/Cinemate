class CommentModel {
  final int id;
  final String movieId;
  final String userId;
  final String userName;
  final String commentText;
  final String movieTitle;
  final DateTime createdAt;
  final double rating;
  final String userProfileImageUrl;
  final bool spoiler;

  CommentModel({
    required this.id,
    required this.movieId,
    required this.userId,
    required this.userName,
    required this.commentText,
    required this.movieTitle,
    required this.createdAt,
    required this.rating,
    required this.userProfileImageUrl,
    this.spoiler = false,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] ?? 0,
      movieId: map['movie_id'] ?? '',
      userId: map['user_id'] ?? '',
      userName: map['profiles']?['name'] ?? 'Anonymous', // Joined from profiles
      commentText: map['comment'] ?? '',
      movieTitle: map['movie_title'] ?? '',
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      userProfileImageUrl: map['profiles']?['profile_image'] ?? '', // Joined from profiles
      spoiler: map['spoiler'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'movie_id': movieId,
      'user_id': userId,
      'comment': commentText,
      'movie_title': movieTitle,
      'created_at': createdAt.toIso8601String(),
      'rating': rating,
      'spoiler': spoiler,
    };
  }
}