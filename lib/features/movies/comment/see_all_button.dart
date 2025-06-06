import 'package:Cinemate/themes/font_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class SeeAllButton extends StatelessWidget {
  final VoidCallback onTap;

  const SeeAllButton({required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child:  Text(
        "Tümünü Gör",
        style: AppTextStyles.bold.copyWith(color: Theme.of(context).colorScheme.primary)
      ),
    );
  }
}

