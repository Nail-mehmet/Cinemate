//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Cinemate/features/notifications/domain/entities/notification_model.dart';
/*
class NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Kullanıcının bildirimlerini getir
  Future<List<NotificationModel>> getNotifications(String userId) async {
    final snapshot = await _firestore
        .collection('notifications')
        .doc(userId)
        .collection('user_notifications')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => NotificationModel.fromMap(doc.data()))
        .toList();
  }

  // Realtime bildirim akışı
  Stream<NotificationModel> getNotificationStream(String userId) {
    return _firestore
        .collection('notifications')
        .doc(userId)
        .collection('user_notifications')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .asyncMap((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return NotificationModel.fromMap(snapshot.docs.first.data());
      }
      return null;
    }).where((notification) => notification != null).cast<NotificationModel>();
  }

  // Takip bildirimi oluştur
  Future<void> createFollowNotification(
      String currentUserId, String targetUserId) async {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'follow',
      fromUserId: currentUserId,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('notifications')
        .doc(targetUserId) // Takip edilen kişiye bildirim gidecek
        .collection('user_notifications')
        .doc(notification.id)
        .set(notification.toMap());
  }
}*/