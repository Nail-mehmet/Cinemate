import 'package:flutter/material.dart';
import 'package:Cinemate/themes/font_theme.dart';

class MessageButton extends StatelessWidget {
  final VoidCallback onPressed;

  const MessageButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),)
      ),
      
      onPressed: onPressed,
      child: Text(
        " Mesaj At ",
        style: AppTextStyles.bold.copyWith(color: Theme.of(context).colorScheme.tertiary)
      ),
    );
  }
}
