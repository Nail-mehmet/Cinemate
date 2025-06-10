import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:Cinemate/features/movies/comment/comment_model.dart';
import 'package:Cinemate/themes/font_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../profile/presentation/pages/profile_page2.dart';
import 'package:flutter/services.dart';
class CommentTile extends StatefulWidget {
  final CommentModel comment;

  const CommentTile({Key? key, required this.comment}) : super(key: key);

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  bool _showSpoiler = false;
  final supabase = Supabase.instance.client;

  
  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _playClickSound() async {
  await HapticFeedback.lightImpact(); // Optional haptic feedback
  await SystemSound.play(SystemSoundType.click);
}
  @override
  Widget build(BuildContext context) {
    final comment = widget.comment;

    List<Widget> stars = List.generate(5, (index) {
      return Icon(
        index < comment.rating ? Icons.star : Icons.star_border,
        color: Colors.amber,
        size: 20,
      );
    });

    String formatDateManually(DateTime date) {
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();

      return '$day/$month/$year';
    }


    String formattedDate = formatDateManually(comment.createdAt);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar sol üstte sabit kalır
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage2(uid: comment.userId),
                ),
              );
            },
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                comment.userProfileImageUrl.isNotEmpty
                    ? comment.userProfileImageUrl
                    : 'assets/fallback_profile.jpg',
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Sağ taraf: metin içeriği
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfilePage2(uid: comment.userId),
                          ),
                        );
                      },
                      child: Text(
                        comment.userName,
                        style: AppTextStyles.bold.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: AppTextStyles.medium.copyWith(color: Theme.of(context).colorScheme.primary.withOpacity(0.4,),fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(children: stars),
                const SizedBox(height: 4),
                if (!comment.spoiler || _showSpoiler)
                  Text(
                    comment.commentText,
                    style: AppTextStyles.medium.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                    ),
                  ),
                if (comment.spoiler && !_showSpoiler)
                  GestureDetector(
                    onTap: () async {
                      await _playClickSound();
                      setState(() => _showSpoiler = true);
                    },
                    child: Container(
                      padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade600),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: Colors.amber, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'Spoiler içerir',
                            style: AppTextStyles.medium.copyWith(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 4),

              ],
            ),
          ),
        ],
      ),
    );

  }
}
// Yorumları Firestore'dan çekiyoruz
Future<List<CommentModel>> fetchComments(String movieId) async {
  final supabase = Supabase.instance.client;

  try {
    final response = await supabase
        .from('comments')
        .select('*, profiles(name, profile_image)')
        .eq('movie_id', movieId)
        .order('created_at', ascending: false);

    // response direkt data olarak dönüyor:
    final data = response as List<dynamic>;

    return data
        .map((e) => CommentModel.fromMap(e as Map<String, dynamic>))
        .toList();
  } catch (e) {
    print('Error fetching comments: $e');
    return [];
  }
}


