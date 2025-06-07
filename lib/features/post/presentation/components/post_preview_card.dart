import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Cinemate/features/auth/domain/entities/app_user.dart';
import 'package:Cinemate/features/auth/presentation/cubits/auth_cubits.dart';
import 'package:Cinemate/features/post/domain/entities/post.dart';
import 'package:Cinemate/features/post/presentation/cubits/post_cubit.dart';
import 'package:Cinemate/features/profile/domain/entities/profile_user.dart';
import 'package:Cinemate/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:Cinemate/themes/font_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback? onTap;
  final VoidCallback? onLikeTap;
  final bool isLiked;
  final VoidCallback onDeletePressed;

  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onLikeTap,
    required this.isLiked,
    required this.onDeletePressed,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  ProfileUser? postUser;
  late final postCubit = context.read<PostCubit>();
  late final profileCubit = context.read<ProfileCubit>();
  AppUser? currentUser;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    fetchPostUser();
    getCurrentUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
  }

  Future<void> fetchPostUser() async {
    final fetchedUser = await profileCubit.getUserProfile(widget.post.userId);
    if (fetchedUser != null && mounted) {
      setState(() {
        postUser = fetchedUser;
      });
    }
  }

  void toggleLikePost() {
    final isLiked = widget.post.likes.contains(currentUser!.uid);

    // Optimistic update
    setState(() {
      if (isLiked) {
        widget.post.likes.remove(currentUser!.uid);
      } else {
        widget.post.likes.add(currentUser!.uid);
      }
    });

    // Update like in backend
    postCubit.toggleLikePost(widget.post.id, currentUser!.uid).catchError((error) {
      // Revert if error
      setState(() {
        if (isLiked) {
          widget.post.likes.add(currentUser!.uid);
        } else {
          widget.post.likes.remove(currentUser!.uid);
        }
      });
    });
  }

  Future<int> fetchCommentCount(String postId) async {
    final response = await supabase
        .from('post_comments')
        .select('id')
        .eq('post_id', postId);

    return response.length;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: widget.post.imageUrl ?? '',
              placeholder: (context, url) => Container(
                height: 250,
                color: Colors.grey[200],
              ),
              errorWidget: (context, url, error) => Container(
                height: 250,
                color: Colors.grey[200],
                child: const Icon(Icons.error),
              ),
              fit: BoxFit.cover,
              width: double.infinity,
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kullanıcı adı ve profil fotoğrafı
                    Row(
                      children: [
                        if (postUser?.profileImageUrl != null)
                          CircleAvatar(
                            radius: 12,
                            backgroundImage: NetworkImage(postUser!.profileImageUrl!),
                          )
                        else
                          const CircleAvatar(
                              radius: 12, child: Icon(Icons.person, size: 14)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            postUser?.name ?? "",
                            style: AppTextStyles.semiBold.copyWith(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),


                      ],
                    ),
                    SizedBox(height: 1,),

                    // Açıklama
                    if (widget.post.text.isNotEmpty)
                      Text(
                        widget.post.text,
                        style: AppTextStyles.medium.copyWith(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 6),

                    // Beğeni ve Yorum
                    Row(
                      children: [
                        GestureDetector(
                          onTap: toggleLikePost,
                          child: Image.asset(
                            widget.post.likes.contains(currentUser?.uid)
                                ? 'assets/icons/heart.png'
                                : 'assets/icons/like.png',
                            width: 18,
                            height: 18,
                            color: widget.post.likes.contains(currentUser?.uid)
                                ? Colors.red
                                : Colors.white70,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.post.likes.length.toString(),
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white70),
                        ),
                        const SizedBox(width: 12),
                        Image.asset(
                          'assets/icons/comment.png',
                          width: 18,
                          height: 18,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        FutureBuilder<int>(
                          future: fetchCommentCount(widget.post.id),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState != ConnectionState.done) {
                              return const Text(
                                "0",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white70),
                              );
                            }
                            return Text(
                              snapshot.data?.toString() ?? "0",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.white70),
                            );
                          },
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(widget.post.timeStamp),
                          style: AppTextStyles.medium.copyWith(fontSize: 12, color: Colors.white70)
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 2,
              right: 2,
              child: currentUser?.uid == widget.post.userId
                  ? IconButton(
                icon: const Icon(Icons.more_vert, size: 18, color: Colors.white70),
                onPressed: widget.onDeletePressed,
              )
                  : const SizedBox.shrink(), // boş widget döndürür
            ),

          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inMinutes < 1) return "şimdi";
    if (difference.inHours < 1) return "${difference.inMinutes} d";
    if (difference.inDays < 1) return "${difference.inHours} s";
    return "${difference.inDays} g";
  }
}