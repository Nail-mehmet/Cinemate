import 'package:flutter/material.dart';
import 'package:Cinemate/themes/font_theme.dart';

class TabItem extends StatelessWidget {
  final String title;

  const TabItem({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bold,
          ),
          
        ],
      ),
    );
  }
}