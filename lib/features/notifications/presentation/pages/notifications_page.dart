import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../themes/font_theme.dart';
import '../../../home/presentation/pages/post_detail_page.dart';
import '../../../post/domain/entities/post.dart';
import '../../../profile/presentation/pages/profile_page2.dart';
import '../cubits/notification_bloc.dart';

class NotificationsPage extends StatelessWidget {
  final String currentUserId;

  const NotificationsPage({Key? key, required this.currentUserId})
      : super(key: key);

  Future<Post?> fetchPost(String postId) async {
    try {
      final data = await Supabase.instance.client
          .from('posts')
          .select()
          .eq('id', postId)
          .single();

      return Post.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchUser(String userId) async {
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return data as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }


  String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) return "şimdi";
    if (diff.inMinutes < 2) return "az önce";
    if (diff.inMinutes < 60) return "${diff.inMinutes} dakika önce";
    if (diff.inHours < 2) return "1 saat önce";
    if (diff.inHours < 24) return "${diff.inHours} saat önce";
    if (diff.inDays < 2) return "Dün";
    if (diff.inDays < 7) return "${diff.inDays} gün önce";

    return "${dateTime.day}.${dateTime.month}.${dateTime.year}";
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationCubit()..fetchNotifications(currentUserId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Bildirimler"),
        ),
        body: BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is NotificationLoaded) {
              final allNotifications = state.notifications;

              final unread = allNotifications
                  .where((n) => !(n["is_read"] ?? false))
                  .toList();
              final read = allNotifications
                  .where((n) => (n["is_read"] ?? false))
                  .toList();

              Widget buildNotificationTile(Map<String, dynamic> notification) {
                final type = notification["type"];
                final fromUserId = notification["from_user_id"];
                final postId = notification["post_id"];
                final isRead = notification["is_read"] ?? false;
                // Zaman dönüşümü için güncelleme
                final createdAt = notification["created_at"] != null
                    ? (notification["created_at"] is int
                    ? DateTime.fromMillisecondsSinceEpoch(notification["created_at"])
                    : DateTime.parse(notification["created_at"]))
                    : null;

                return FutureBuilder(
                  future: Future.wait([
                    fetchUser(fromUserId),
                    if (type == "like" && postId != null) fetchPost(postId),
                  ]),
                  builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox();
                    }

                    final userData = snapshot.data![0] as Map<String, dynamic>?;
                    final post = snapshot.data!.length > 1
                        ? snapshot.data![1] as Post?
                        : null;

                    final userName = userData?["name"] ?? userData?["name"] ?? "Kullanıcı";
                    final userPhoto = userData?["profile_image"] ?? "";

                    return _AnimatedNotificationTile(
                      isRead: isRead,
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: (userPhoto != null && userPhoto.isNotEmpty)
                            ? Image.network(
                          userPhoto,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const CircleAvatar(
                            child: Icon(Icons.person),
                            radius: 20,
                          ),
                        )
                            : const CircleAvatar(
                          child: Icon(Icons.person),
                          radius: 20,
                        ),
                      ),

                      title: type == "follow"
                          ? "$userName seni takip etti."
                          : "$userName gönderini beğendi.",
                      timeText: createdAt != null ? timeAgo(createdAt) : "",
                      trailing: type == "like" && post != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(post.imageUrl,
                            width: 50, height: 50, fit: BoxFit.cover),
                      )
                          : null,
                      onTap: () {
                        if (type == "like" && post != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => PostDetailPage(post: post)),
                          );
                        } else if (type == "follow") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ProfilePage2(uid: fromUserId)),
                          );
                        }
                      },
                    );
                  },
                );
              }

              return ListView(
                children: [
                  ...unread.map(buildNotificationTile),
                  if (unread.isNotEmpty && read.isNotEmpty)
                    Row(
                      children: [
                        const Expanded(child: Divider(thickness: 1)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "Yeni",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Expanded(child: Divider(thickness: 1)),
                      ],
                    ),
                  ...read.map(buildNotificationTile),
                ],
              );
            } else if (state is NotificationError) {
              return Center(child: Text(state.message));
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}

// _AnimatedNotificationTile widget'ı aynı kalabilir

class _AnimatedNotificationTile extends StatefulWidget {
  final bool isRead;
  final Widget leading;
  final String title;
  final String timeText;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _AnimatedNotificationTile({
    required this.isRead,
    required this.leading,
    required this.title,
    required this.timeText,
    this.trailing,
    this.onTap,
  });

  @override
  State<_AnimatedNotificationTile> createState() =>
      _AnimatedNotificationTileState();
}

class _AnimatedNotificationTileState extends State<_AnimatedNotificationTile> {
  double opacity = 1.0;

  @override
  void initState() {
    super.initState();
    if (!widget.isRead) {
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() => opacity = 0.0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: widget.isRead ? null : Theme.of(context).colorScheme.primary.withOpacity(opacity * 0.15),
      ),
      child: ListTile(
        leading: widget.leading,
        title: Text(widget.title, style: AppTextStyles.medium.copyWith(color: Theme.of(context).colorScheme.primary),),
        subtitle: widget.timeText.isNotEmpty ? Text(widget.timeText, style: AppTextStyles.bold.copyWith(fontSize: 12),) : null,
        trailing: widget.trailing,
        onTap: widget.onTap,
      ),
    );
  }
}