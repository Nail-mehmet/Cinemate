import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:Cinemate/features/post/domain/entities/comment.dart';
import 'package:Cinemate/features/profile/presentation/pages/profile_page2.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../profile/domain/entities/profile_user.dart';
import '../../../profile/presentation/cubits/profile_cubit.dart';

class CommentTile3 extends StatefulWidget {
  final Comment comment;
  final String? userProfileImageUrl;
  final String? currentUserId;
  final Future<void> Function()? onLikePressed;

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
  late bool _isLiked;
  late int _likeCount;
  bool _isLikeInProgress = false;
  ProfileUser? _commentUser;
  late final profileCubit = context.read<ProfileCubit>();



  @override
  void initState() {
    super.initState();
    _initializeLikeState();
    _loadPostUser();
  }

  @override
  void didUpdateWidget(covariant CommentTile3 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.comment.id != widget.comment.id ||
        oldWidget.currentUserId != widget.currentUserId) {
      _initializeLikeState();
    }
  }

  void _initializeLikeState() {
    _isLiked = widget.currentUserId != null &&
        widget.comment.likes.contains(widget.currentUserId);
    _likeCount = widget.comment.likes.length;
  }

  Future<void> _loadPostUser() async {
    final user = await profileCubit.getUserProfile(widget.comment.userId);
    if (mounted) {
      setState(() => _commentUser = user);
    }
  }

  Future<void> _handleLikePressed() async {
    if (_isLikeInProgress) return;

    setState(() {
      _isLikeInProgress = true;
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });

    try {
      await widget.onLikePressed?.call();
    } catch (e) {
      setState(() {
        _isLiked = !_isLiked;
        _likeCount += _isLiked ? 1 : -1;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Beğeni işlemi sırasında hata: $e')),
      );
    } finally {
      setState(() {
        _isLikeInProgress = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _isLikeInProgress ? null : _handleLikePressed,
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
            backgroundColor: Colors.grey.shade200,
            backgroundImage: (_commentUser != null &&
                _commentUser!.profileImageUrl != null &&
                _commentUser!.profileImageUrl.isNotEmpty)
                ? CachedNetworkImageProvider(_commentUser!.profileImageUrl)
                : null,
            child: (_commentUser == null ||
                _commentUser!.profileImageUrl == null ||
                _commentUser!.profileImageUrl.isEmpty)
                ? const Icon(Icons.person, size: 30, color: Colors.grey)
                : null,
          ),


          title: Text(
            _commentUser?.name ?? "",
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.comment.text,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: GestureDetector(
                      onTap: _isLikeInProgress ? null : _handleLikePressed,
                      child: Row(
                        children: [
                          Icon(
                            _isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: _isLiked ? Colors.red : Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$_likeCount',
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
                    formatDateManually(widget.comment.timestamp),
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

  /*String _formatDate(DateTime date) {
    return DateFormat('d MMM HH:mm', 'tr_TR').format(date);
  }*/
  String formatDateManually(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }
}
