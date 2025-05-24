/*import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId)
          .collection("notifications")
          .orderBy("timestamp", descending: true)
          .get();

      // isRead: false olanları işaretle
      for (var doc in snapshot.docs) {
        if (!(doc.data()["isRead"] ?? false)) {
          doc.reference.update({"isRead": true});
        }
      }

      emit(NotificationLoaded(snapshot.docs.map((e) => e.data()).toList()));
    } catch (e) {
      emit(NotificationError("Bildirimler alınamadı: $e"));
    }
  }
}

*/