import 'package:supabase_flutter/supabase_flutter.dart';
import '../entities/notification_model.dart';

class NotificationRepository {
  final SupabaseClient _supabase;

  NotificationRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  // Kullanıcının bildirimlerini getir
  Future<List<NotificationModel>> getNotifications(String userId) async {
    final data = await _supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (data as List)
        .map((item) => NotificationModel.fromMap(item))
        .toList();
  }

  // Realtime bildirim akışı
  Stream<NotificationModel> getNotificationStream(String userId) {
    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(1)
        .asyncMap((snapshot) {
      if (snapshot.isNotEmpty) {
        return NotificationModel.fromMap(snapshot.first);
      }
      return null;
    })
        .where((notification) => notification != null)
        .cast<NotificationModel>();
  }

  // Bildirim ekle
  Future<void> addNotification(Map<String, dynamic> notification) async {
    final inserted = await _supabase.from('notifications').insert(notification);

    if (inserted == null || inserted is List && inserted.isEmpty) {
      throw Exception('Bildirim eklenemedi.');
    }
  }
}
