import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String userId;
  final String userName;
  final String commentText;
  final DateTime createdAt;
  final double rating;
  final String userProfileImageUrl; // Burada var yerine String kullanıyoruz
  final bool spoiler;

  CommentModel({
    required this.userId,
    required this.userName,
    required this.commentText,
    required this.createdAt,
    required this.rating,
    required this.userProfileImageUrl, // Kullanıcı profil resmi burada zorunlu
    this.spoiler = false
  });

  // Firestore verisinden map alıp, CommentModel nesnesine çeviriyoruz
  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      userId: map['userId'],
      userName: map['userName'],
      commentText: map['commentText'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      rating: (map['rating'] as num).toDouble(),
      userProfileImageUrl: map['userProfileImageUrl'] ?? '', // Eğer varsa al, yoksa boş string
      spoiler: map["spoiler"] ?? false,
    );
  }

  // CommentModel'ı map formatına dönüştürüyoruz
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'commentText': commentText,
      'createdAt': createdAt,
      'rating': rating,
      'userProfileImageUrl': userProfileImageUrl, // Profil resmini de ekliyoruz
      'spoiler': spoiler,
    };
  }
}
