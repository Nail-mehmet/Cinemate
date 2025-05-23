
import 'package:equatable/equatable.dart';
import 'package:Cinemate/features/notifications/domain/entities/notification_model.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object> get props => [];
}

class FetchNotifications extends NotificationEvent {
  final String userId;

  const FetchNotifications(this.userId);

  @override
  List<Object> get props => [userId];
}

class NotificationReceived extends NotificationEvent {
  final NotificationModel notification;

  const NotificationReceived(this.notification);

  @override
  List<Object> get props => [notification];
}