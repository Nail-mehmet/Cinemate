import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class SeeAllButton extends StatelessWidget {
  final VoidCallback onTap;

  const SeeAllButton({required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: const Text(
        "Tümünü Gör",
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

