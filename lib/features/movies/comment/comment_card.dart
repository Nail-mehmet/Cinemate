import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:Cinemate/features/movies/comment/comment_model.dart';
import 'package:intl/intl.dart';
import 'package:Cinemate/themes/font_theme.dart';

class CommentCard extends StatefulWidget {
  final CommentModel comment;
  const CommentCard({required this.comment});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  bool _showSpoiler = false;

  Future<void> _playClickSound() async {
  await HapticFeedback.lightImpact(); // Optional haptic feedback
  await SystemSound.play(SystemSoundType.click);
}

  String formatDateTurkishLong(DateTime date) {
    const monthsTR = [
      '',
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];

    final day = date.day;
    final month = monthsTR[date.month];
    final year = date.year;

    return '$day $month $year';
  }


  @override
  Widget build(BuildContext context) {
    final comment = widget.comment;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;


    return Container(
      width: screenWidth * 0.8,
      margin: const EdgeInsets.only(right: 15),
      child: Stack(
        children: [
          // Main comment content
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top section (user info and rating)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: comment.userProfileImageUrl.isNotEmpty ? NetworkImage(comment.userProfileImageUrl) : null,
                         /* child: Text(
                            comment.userName[0].toUpperCase(),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),*/
                        ),
                       /* CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: comment.userProfileImageUrl.isNotEmpty
                              ? NetworkImage(comment.userProfileImageUrl)
                              : null,
                          child: comment.userProfileImageUrl.isEmpty
                              ? Text(
                                  comment.userName[0].toUpperCase(),
                                  style: const TextStyle(
                                      fontSize: 20, fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),*/
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(comment.userName,
                                style: AppTextStyles.bold.copyWith(
                                    color: Theme.of(context).colorScheme.tertiary)),
                            const SizedBox(height: 5),
                            Text(
                             formatDateTurkishLong(comment.createdAt),
                              style: AppTextStyles.medium.copyWith(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(comment.rating.toString(),
                            style: AppTextStyles.bold.copyWith(color: Theme.of(context).colorScheme.tertiary)),
                        const SizedBox(width: 8),
                        const Icon(FontAwesomeIcons.solidStar,
                            color: Color.fromARGB(255, 157, 146, 44), size: 15),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Comment text - shown normally if no spoiler or spoiler is revealed
                if (!comment.spoiler || _showSpoiler)
                  Text(
                    comment.commentText,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.medium.copyWith(
                        color: Theme.of(context).colorScheme.tertiary, fontSize: 12),
                  ),
                // Placeholder for spoiler text to maintain consistent height
                if (comment.spoiler && !_showSpoiler)
                  const Text(
                    'Spoiler İçerir',
                    maxLines: 3,
                    style: TextStyle(color: Colors.transparent),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // Spoiler overlay (only shown if comment has spoiler and not revealed)
          if (comment.spoiler && !_showSpoiler)
            Positioned.fill(
              child: GestureDetector(
                onTap: () async {
                await _playClickSound();
                setState(() => _showSpoiler = true);
              },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          
                          Text(
                            'Spoiler içerir',
                            style: AppTextStyles.bold.copyWith(color: Theme.of(context).colorScheme.tertiary)
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}



