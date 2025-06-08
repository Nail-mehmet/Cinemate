import 'package:flutter/material.dart';
import 'package:Cinemate/features/notifications/presentation/pages/notifications_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationIconWithBadge extends StatelessWidget {
  final String currentUserId;

  const NotificationIconWithBadge({Key? key, required this.currentUserId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notificationsStream = Stream.periodic(const Duration(seconds: 2))
        .asyncMap((_) async {
      final response = await Supabase.instance.client
          .from('notifications')
          .select()
          .eq('user_id', currentUserId)
          .eq('is_read', false)
          .order('created_at', ascending: false);

      if (response == null) {
        return <Map<String, dynamic>>[];
      }
      return List<Map<String, dynamic>>.from(response as List);
    });



    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: notificationsStream,
      builder: (context, snapshot) {
        final unreadCount = snapshot.data?.length ?? 0;

        return Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: Stack(
            children: [
              IconButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationsPage(currentUserId: currentUserId),
                    ),
                  );
                  // Stream zaten güncel kalacak
                },
                icon: const Icon(Icons.notifications_none_rounded),
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 15,
                      minHeight: 15,
                    ),
                    child: Text(
                      unreadCount > 9 ? '9+' : unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );

  }
}