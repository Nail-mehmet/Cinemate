import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Cinemate/features/post/domain/entities/comment.dart';

class Post {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final String imageUrl;
  final DateTime timeStamp;
  final List<String> likes;
  final List<Comment>? comments; // Nullable yapıyoruz
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
    this.comments = const [], // Artık nullable
    required this.category,
    this.relatedMovieId,
    this.relatedMovieTitle,
  });

  Post copyWith({
    String? imageUrl,
    String? category,
    List<Comment>? comments, // CopyWith'e comments eklendi
  }) {
    return Post(
      id: id,
      userId: userId,
      userName: userName,
      text: text,
      imageUrl: imageUrl ?? this.imageUrl,
      timeStamp: timeStamp,
      likes: likes,
      comments: comments ?? this.comments,
      category: category ?? this.category,
      relatedMovieId: relatedMovieId,
      relatedMovieTitle: relatedMovieTitle,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "userId": userId,
      "name": userName,
      "text": text,
      "imageUrl": imageUrl,
      "timestamp": Timestamp.fromDate(timeStamp),
      "likes": likes,
      // Comments artık JSON'a dahil edilmiyor
      "category": category,
      "relatedMovieId": relatedMovieId,
      "relatedMovieTitle": relatedMovieTitle,
    };
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json["id"],
      userId: json["userId"],
      userName: json["name"],
      text: json["text"],
      imageUrl: json["imageUrl"],
      timeStamp: (json["timestamp"] as Timestamp).toDate(),
      likes: List<String>.from(json["likes"] ?? []),
      comments: null, // Artık direkt null olarak başlatıyoruz
      category: json["category"] ?? 'Genel',
      relatedMovieId: json["relatedMovieId"],
      relatedMovieTitle: json["relatedMovieTitle"],
    );
  }
}