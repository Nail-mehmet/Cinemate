
import 'package:flutter/material.dart';
import 'package:Cinemate/themes/font_theme.dart';

class FollowButton extends StatelessWidget {

  final void Function()? onPressed;
  final bool isFollowing;

  const FollowButton({
    super.key,
    required this.isFollowing,
    required this.onPressed
    });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 40),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      isFollowing ? Theme.of(context).colorScheme.inversePrimary :  Theme.of(context).colorScheme.inversePrimary,
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),),
                                ),
        //color: isFollowing ? Theme.of(context).colorScheme.primary : Colors.blue,
        child: Text(isFollowing ? "Takipten Çık" : "Takip Et",
        style: AppTextStyles.bold.copyWith(color: isFollowing ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary,fontSize: 14),),
      ),
    );

  }
}
