import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<Map<String, dynamic>> notifications;

  NotificationLoaded(this.notifications);
}

class NotificationError extends NotificationState {
  final String message;

  NotificationError(this.message);
}

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationLoading());

  Future<void> fetchNotifications(String currentUserId) async {
    try {
      final notifications = await Supabase.instance.client
          .from('notifications')
          .select()
          .eq('user_id', currentUserId)
          .order('created_at', ascending: false);

      final castedNotifications =
      (notifications as List).cast<Map<String, dynamic>>();

      // is_read: false olanları işaretle
      final unreadNotifications =
      castedNotifications.where((n) => !(n['is_read'] ?? false));

      for (var notification in unreadNotifications) {
        await Supabase.instance.client
            .from('notifications')
            .update({'is_read': true})
            .eq('id', notification['id']);
      }

      emit(NotificationLoaded(castedNotifications));
    } catch (e) {
      emit(NotificationError("Bildirimler alınamadı: $e"));
    }
  }
}
