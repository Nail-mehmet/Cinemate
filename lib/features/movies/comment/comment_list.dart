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

    String formattedDate = DateFormat('dd MMMM yyyy').format(comment.createdAt);

    return ListTile(
      onTap: () {
      /* Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage2(uid: comment.userId),
          ),
        );*/
      },
      contentPadding: const EdgeInsets.all(8),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(comment.userProfileImageUrl.isNotEmpty
            ? comment.userProfileImageUrl
            : 'assets/fallback_profile.jpg'),
      ),
      title: Text(comment.userName,
          style: AppTextStyles.bold.copyWith(
              color: Theme.of(context).colorScheme.primary, fontSize: 12)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
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
                    Text('Spoiler içerir (tıkla)',
                        style: AppTextStyles.medium.copyWith(fontSize: 12,color: Theme.of(context).colorScheme.tertiary)),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 4),
          Text(formattedDate,
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
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


