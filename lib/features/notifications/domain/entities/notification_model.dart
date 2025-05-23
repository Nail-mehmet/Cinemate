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
      fromUserId: map['fromUserId'] ?? '',
      postId: map['postId'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      isRead: map['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'fromUserId': fromUserId,
      'postId': postId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isRead': isRead,
    };
  }
}