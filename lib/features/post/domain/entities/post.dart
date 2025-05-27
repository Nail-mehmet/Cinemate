import 'package:Cinemate/features/post/domain/entities/comment.dart';

class Post {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final String imageUrl;
  final DateTime timeStamp;
  final List<String> likes;
  final List<Comment>? comments;
  final String category;
  final String? relatedMovieId;
  final String? relatedMovieTitle;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.imageUrl,
    required this.timeStamp,
    required this.likes,
    this.comments,
    required this.category,
    this.relatedMovieId,
    this.relatedMovieTitle,
  });

  Post copyWith({
    String? id,
    String? userId,
    String? userName,
    String? text,
    String? imageUrl,
    DateTime? timeStamp,
    List<String>? likes,
    List<Comment>? comments,
    String? category,
    String? relatedMovieId,
    String? relatedMovieTitle,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      timeStamp: timeStamp ?? this.timeStamp,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      category: category ?? this.category,
      relatedMovieId: relatedMovieId ?? this.relatedMovieId,
      relatedMovieTitle: relatedMovieTitle ?? this.relatedMovieTitle,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "user_id": userId,
      "user_name": userName,
      "text": text,
      "image_url": imageUrl,
      "created_at": timeStamp.toIso8601String(),
      "likes": likes,
      "category": category,
      "related_movie_id": relatedMovieId,
      "related_movie_title": relatedMovieTitle,
    };
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json["id"],
      userId: json["user_id"],
      userName: json["user_name"],
      text: json["text"],
      imageUrl: json["image_url"],
      timeStamp: DateTime.parse(json["created_at"]),
      likes: List<String>.from(json["likes"] ?? []),
      category: json["category"] ?? 'Genel',
      relatedMovieId: json["related_movie_id"],
      relatedMovieTitle: json["related_movie_title"],
    );
  }


}