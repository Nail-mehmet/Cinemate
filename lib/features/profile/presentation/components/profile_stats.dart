


import 'package:flutter/material.dart';
import 'package:Cinemate/themes/font_theme.dart';

class ProfileStats extends StatelessWidget {

  final int postCount;
  final int followerCount;
  final int followingCount;
  final void Function()? onTap;
  const ProfileStats({
    super.key,
    required this.postCount,
    required this.followerCount,
    required this.followingCount,
    required this.onTap});

  @override
  Widget build(BuildContext context) {

    var textStyleForCount = TextStyle(
      fontSize: 20, color: Theme.of(context).colorScheme.inversePrimary
    );

    var textStyleForText = TextStyle(
      color: Theme.of(context).colorScheme.primary
    );
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
            //posts
      
        SizedBox(
          width: 100,
          child: Column(
            children: [
              Text(postCount.toString(),style: AppTextStyles.medium.copyWith(fontSize: 18,color: Theme.of(context).colorScheme.secondary),),
              Text("posts", style: AppTextStyles.medium.copyWith(color: Theme.of(context).colorScheme.secondary),)
            ],
          ),
        ),
        
      
        // followers
        SizedBox(
          width: 100,
          child: Column(
            children: [
              Text(followerCount.toString(), style: AppTextStyles.medium.copyWith(fontSize: 18,color: Theme.of(context).colorScheme.secondary),),
              Text("takipçi", style: AppTextStyles.medium.copyWith(color: Theme.of(context).colorScheme.secondary),)
            ],
          ),
        ),
      
      
        // following
        SizedBox(
          width: 100,
          child: Column(
            children: [
              Text(followingCount.toString(),style: AppTextStyles.medium.copyWith(fontSize: 18,color: Theme.of(context).colorScheme.secondary),),
              Text("takip", style: AppTextStyles.medium.copyWith(color: Theme.of(context).colorScheme.secondary),)
            ],
          ),
        ),
        ],
      
      
      
      ),
    );
  }
}