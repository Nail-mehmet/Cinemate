import 'package:flutter/material.dart';
import 'package:Cinemate/features/profile/domain/entities/profile_user.dart';
import 'package:Cinemate/features/profile/presentation/pages/profile_page2.dart';
import 'package:Cinemate/themes/font_theme.dart';

class UserTile extends StatelessWidget {
  final ProfileUser user;

  const UserTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(user.name,style: AppTextStyles.medium,),
      subtitle: Text(user.email,style: AppTextStyles.medium,),
      subtitleTextStyle:
          TextStyle(color: Theme.of(context).colorScheme.primary),
      leading: user.profileImageUrl!.isNotEmpty
          ? CircleAvatar(
              backgroundImage: NetworkImage(user.profileImageUrl!),
              radius: 30,
            )
          : CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              radius: 30,
            ),
      trailing: Icon(
        Icons.arrow_forward,
        color: Theme.of(context).colorScheme.primary,
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage2(uid: user.uid)),
      ),
    );
  }
}
