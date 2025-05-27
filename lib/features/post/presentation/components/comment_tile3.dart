import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:Cinemate/features/post/domain/entities/comment.dart';
import 'package:Cinemate/features/profile/presentation/pages/profile_page.dart';
import 'package:intl/intl.dart';
import 'package:Cinemate/features/profile/presentation/pages/profile_page2.dart';
class CommentTile3 extends StatefulWidget {
  final Comment comment;
  final String? userProfileImageUrl;
  final String? currentUserId;
  final Future<void> Function()? onLikePressed; // async desteklemek için

  const CommentTile3({
    super.key,
    required this.comment,
    this.userProfileImageUrl,
    this.onLikePressed,
    this.currentUserId,
  });

  @override
  State<CommentTile3> createState() => _CommentTile3State();
}

class _CommentTile3State extends State<CommentTile3> {
  late bool isLiked;
  late int likeCount;

  @override
  void initState() {
    super.initState();
    isLiked = widget.currentUserId != null &&
        widget.comment.likes.contains(widget.currentUserId);
    likeCount = widget.comment.likes.length;
  }

  void _handleLikePressed() async {
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });

    // Firestore güncellemesi
    await widget.onLikePressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage2(uid: widget.comment.userId),
        ),
      ),
      child: Container(
  margin: const EdgeInsets.symmetric(vertical: 4),
  child: ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    leading: CircleAvatar(
      backgroundImage: widget.userProfileImageUrl != null
          ? CachedNetworkImageProvider(widget.userProfileImageUrl!)
          : const AssetImage("assets/default_avatar.png") as ImageProvider,
    ),
    title: Text(
      widget.comment.userName,
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    ),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start, // Add this for proper alignment
          children: [
            Expanded( // Wrap the Text with Expanded
              child: Text(
                widget.comment.text,
                softWrap: true, // Ensures text wraps to next line
                overflow: TextOverflow.visible, // Allows text to expand
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: GestureDetector(
                onTap: _handleLikePressed,
                child: Row(
                  children: [
                    Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 16,
                      color: isLiked ? Colors.red : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$likeCount',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              _formatDate(widget.comment.timestamp),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 11,
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ],
    ),
  ),
),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy - HH:mm').format(date);
  }
}
