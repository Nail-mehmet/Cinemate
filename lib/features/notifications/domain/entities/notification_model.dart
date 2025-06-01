class NotificationModel {
  final String id;
  final String type; // 'follow', 'like', 'comment' vb.
  final String fromUserId;
  final String? postId; // Beğeni veya yorum için
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.type,
    required this.fromUserId,
    this.postId,
    required this.createdAt,
    this.isRead = false,
  });

  // Firebase'den veri çekerken kullanılacak factory constructor
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      type: map['type'] ?? '',
      fromUserId: map['from_user_id'] ?? '',
      postId: map['post_id'],

      createdAt: DateTime.parse(map['created_at']),
      isRead: map['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'from_user_id': fromUserId,
      'post_id': postId,
      'created_at': createdAt.millisecondsSinceEpoch,
      'is_read': isRead,
    };
  }
}