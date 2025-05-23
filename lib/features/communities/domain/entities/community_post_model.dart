import 'package:cloud_firestore/cloud_firestore.dart';

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
  Commune copyWith({String? text, String? imageUrl, String? userId, DateTime? createdAt}) {
  return Commune(
    id: id,
    text: text ?? this.text,
    imageUrl: imageUrl ?? this.imageUrl,
    userId: userId ?? this.userId,
    createdAt: createdAt ?? this.createdAt,
  );
}


  factory Commune.fromMap(String id, Map<String, dynamic> data) {
    return Commune(
      id: id,
      text: data['text'] ?? '',
      imageUrl: data['imageUrl'],
      userId: data['userId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'imageUrl': imageUrl,
      'userId': userId,
      'createdAt': createdAt,
    };
  }

  static fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {}
}
