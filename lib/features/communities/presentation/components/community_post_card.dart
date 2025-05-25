import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:Cinemate/features/communities/domain/entities/community_post_model.dart';
import 'package:Cinemate/features/profile/presentation/pages/profile_page2.dart';
import 'package:Cinemate/themes/font_theme.dart';

class CommuneCard extends StatelessWidget {
  final Commune post;
  final String currentUserId;
  final _supabase = Supabase.instance.client;

  CommuneCard({
    required this.post,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    bool isMine = post.userId == currentUserId;
    final formattedDate = DateFormat('MMM d, HH:mm').format(post.createdAt);

    return FutureBuilder<Map<String, dynamic>?>(
      future: _getUserProfile(post.userId),
      builder: (context, snapshot) {
        String? profileUrl;
        String userName = 'Unknown User';

        if (snapshot.hasData && snapshot.data != null) {
          profileUrl = snapshot.data!['avatar_url'];
          userName = snapshot.data!['full_name'] ?? userName;
        }

        return Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (post.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isMine ? 20 : 0),
                    bottomRight: Radius.circular(isMine ? 0 : 20),
                  ),
                  child: Image.network(
                    post.imageUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 12),

              Align(
                alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: isMine ? 0 : 10,
                    right: isMine ? 10 : 0,
                  ),
                  child: Text(
                    post.text,
                    style: AppTextStyles.bold.copyWith(
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!isMine)
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            /*Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProfilePage2(uid: post.userId),
                              ),
                            );*/
                          },
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundImage: profileUrl != null
                                    ? NetworkImage(profileUrl)
                                    : const AssetImage(
                                    'assets/default_avatar.png')
                                as ImageProvider,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 18.0),
                          child: Text(
                            formattedDate,
                            style: AppTextStyles.medium.copyWith(
                              color: Theme.of(context).colorScheme.inversePrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (!isMine)
                    Padding(
                      padding: const EdgeInsets.only(right: 18.0),
                      child: Text(
                        formattedDate,
                        style: AppTextStyles.medium.copyWith(
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: profileUrl != null
                              ? NetworkImage(profileUrl)
                              : const AssetImage('assets/default_avatar.png')
                          as ImageProvider,
                        ),
                      ],
                    ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _getUserProfile(String userId) async {
    final data = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    return data;
  }

}