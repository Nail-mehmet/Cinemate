/*import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String text;
  final DateTime timestamp;
  final List<String> likes; // ✔️ Artık liste

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.text,
    required this.timestamp,
    this.likes = const [],
  });

  Comment copyWith({
    String? id,
    String? postId,
    String? userId,
    String? userName,
    String? text,
    DateTime? timestamp,
    List<String>? likes,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "postId": postId,
      "userId": userId,
      "userName": userName,
      "text": text,
      "timestamp": Timestamp.fromDate(timestamp),
      'likes': likes, // ✔️ Listeyi direkt Firestore'a yaz
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    List<String> likesList = [];
    if (json['likes'] != null) {
      if (json['likes'] is List) {
        likesList = List<String>.from(json['likes']!.map((e) => e.toString()));
      } else if (json['likes'] is int) {
        // Eğer sayı olarak geliyorsa boş liste döndür veya loglayın
      }
    }

    return Comment(
      id: json["id"],
      postId: json["postId"],
      userId: json["userId"],
      userName: json["userName"],
      text: json["text"],
      timestamp: (json["timestamp"] as Timestamp).toDate(),
      likes: List<String>.from(json['likes'] ?? []), // ✔️ Liste olarak al
    );
  }
}
*/