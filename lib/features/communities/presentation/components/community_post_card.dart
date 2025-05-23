import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:Cinemate/features/communities/domain/entities/community_post_model.dart';
import 'package:Cinemate/features/profile/presentation/pages/profile_page2.dart';
import 'package:Cinemate/themes/font_theme.dart';

class CommuneCard extends StatelessWidget {
  final Commune post;
  final String currentUserId; // Giriş yapan kullanıcının ID'si

  const CommuneCard({
    required this.post,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    bool isMine = post.userId == currentUserId;

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(post.userId).get(),
      builder: (context, snapshot) {
        String? profileUrl;
        String userName = 'Unknown User';
        String formattedDate =
            DateFormat('MMM d, HH:mm').format(post.createdAt);

        if (snapshot.hasData && snapshot.data!.exists) {
          profileUrl = snapshot.data!['profileImageUrl'];
          userName = snapshot.data!['name'] ?? userName;
        }

        return Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            //color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            //border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Gönderi görseli (eğer varsa)
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

              // Gönderi metni
              Align(
                alignment:
                    isMine ? Alignment.centerRight : Alignment.centerLeft,
                child: Padding(
                  padding:  EdgeInsets.only(
                    left: isMine? 0: 10,
                    right: isMine? 10: 0
                  ),
                  child: Text(
                    post.text,
                    style: AppTextStyles.bold.copyWith(color: Theme.of(context).colorScheme.inversePrimary),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Profil, isim ve tarih
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!isMine)
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProfilePage2(uid: post.userId),
                              ),
                            );
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
                                    fontWeight: FontWeight.bold),
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
                            style:
                                AppTextStyles.medium.copyWith(color: Theme.of(context).colorScheme.inversePrimary),
                          ),
                        ),
                      ],
                    ),
                  if (!isMine)
                    Padding(
                      padding: const EdgeInsets.only(right: 18.0),
                      child: Text(
                        formattedDate,
                        style: AppTextStyles.medium.copyWith(color: Theme.of(context).colorScheme.inversePrimary),
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
}
