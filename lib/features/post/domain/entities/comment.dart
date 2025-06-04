class Comment {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String? userProfileUrl; // New field for profile picture
  final String text;
  final DateTime timestamp;
  final List<String> likes;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    this.userProfileUrl, // Marked as nullable
    required this.text,
    required this.timestamp,
    this.likes = const [],
  });

  Comment copyWith({
    String? id,
    String? postId,
    String? userId,
    String? userName,
    String? userProfileUrl,
    String? text,
    DateTime? timestamp,
    List<String>? likes,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userProfileUrl: userProfileUrl ?? this.userProfileUrl,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "post_id": postId,
      "user_id": userId,
      "user_name": userName,
      "profile_image": userProfileUrl, // Added to JSON
      "text": text,
      "created_at": timestamp.toIso8601String(),
      'likes': likes,
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json["id"],
      postId: json["post_id"],
      userId: json["user_id"],
      userName: json["user_name"],
      userProfileUrl: json["profile_image"], // Added from JSON
      text: json["text"],
      timestamp: DateTime.parse(json["created_at"]),
      likes: List<String>.from(json['likes'] ?? []),
    );
  }
}