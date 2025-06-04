import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:Cinemate/features/auth/domain/entities/app_user.dart';
import 'package:Cinemate/features/auth/presentation/cubits/auth_cubits.dart';
import 'package:Cinemate/features/home/presentation/components/movie_card.dart';
import 'package:Cinemate/features/movies/presentation/pages/movie_detail_page.dart';
import 'package:Cinemate/features/post/domain/entities/comment.dart';
import 'package:Cinemate/features/post/domain/entities/post.dart';
import 'package:Cinemate/features/post/presentation/components/comment_tile3.dart';
import 'package:Cinemate/features/post/presentation/cubits/post_cubit.dart';
import 'package:Cinemate/features/profile/domain/entities/profile_user.dart';
import 'package:Cinemate/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:Cinemate/features/profile/presentation/pages/profile_page2.dart';
import 'package:Cinemate/themes/font_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../post/presentation/cubits/post_states.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;
  final void Function()? onDeletePressed;
  final ProfileUser? postUser;

  const PostDetailPage({
    super.key,
    required this.post,
    this.onDeletePressed,
    this.postUser,
  });

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late final PostCubit _postCubit;
  late final ProfileCubit _profileCubit;
  late final authCubit = context.read<AuthCubit>();
  late final profileCubit = context.read<ProfileCubit>();
  final _commentTextController = TextEditingController();
  final int commentCount = 0;
  late AppUser? currentUser = authCubit.currentUser;

  bool _isOwnPost = false;
  bool _showHeart = false;
  AppUser? _currentUser;
  ProfileUser? _postUser;
  List<Comment> _comments = [];

  @override
  void initState() {
    super.initState();
    _postCubit = context.read<PostCubit>();
    _profileCubit = context.read<ProfileCubit>();
    _initializeData();
    _fetchComments();
    fetchCommentCount(widget.post.id);
  }
  final SupabaseClient supabase = Supabase.instance.client;


  Future<int> fetchCommentCount(String postId) async {
    final response = await supabase
        .rpc('get_comment_count', params: {'post_id_param': postId});

    return response as int;
  }



  void _initializeData() {
    final authCubit = context.read<AuthCubit>();
    _currentUser = authCubit.currentUser;
    _isOwnPost = (widget.post.userId == _currentUser?.uid);
    _postUser = widget.postUser;

    if (_postUser == null) {
      _loadPostUser();
    }
  }

  Future<void> _loadPostUser() async {
    final user = await _profileCubit.getUserProfile(widget.post.userId);
    if (mounted) {
      setState(() => _postUser = user);
    }
  }

  void _fetchComments() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _postCubit.fetchCommentsForPost(widget.post.id);
    });
  }

  void _toggleLikePost() {
    if (_currentUser == null) return;

    final isLiked = widget.post.likes.contains(_currentUser!.uid);
    setState(() {
      if (isLiked) {
        widget.post.likes.remove(_currentUser!.uid);
      } else {
        widget.post.likes.add(_currentUser!.uid);
        _showHeart = true;
        Future.delayed(const Duration(milliseconds: 1700), () {
          if (mounted) setState(() => _showHeart = false);
        });
      }
    });

    _postCubit
        .toggleLikePost(widget.post.id, _currentUser!.uid)
        .catchError((_) {
      if (mounted) {
        setState(() {
          if (isLiked) {
            widget.post.likes.add(_currentUser!.uid);
          } else {
            widget.post.likes.remove(_currentUser!.uid);
          }
        });
      }
    });
  }

void _openNewCommentBox() {
  final TextEditingController _controller = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
             Text(
              "Yorum Ekle",
              style: AppTextStyles.bold.copyWith(color: Theme.of(context).colorScheme.primary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _controller,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: "Yorumunuzu yazın...",
                  border: InputBorder.none,
                  hintStyle: AppTextStyles.medium.copyWith(fontSize: 15, color: Theme.of(context).colorScheme.primary)
                ),
              
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("İptal", style: AppTextStyles.bold.copyWith(color: Theme.of(context).colorScheme.primary),),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      _commentTextController.text = _controller.text;
                      _addComment();
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text("Gönder",style: AppTextStyles.bold.copyWith(color: Theme.of(context).colorScheme.tertiary)),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

  bool _isValidUuid(String id) {
    final uuidRegex = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$');
    return uuidRegex.hasMatch(id);
  }
  final Uuid uuid = const Uuid();

  void _addComment() {
    if (_currentUser == null || _commentTextController.text.isEmpty) return;

    final newComment = Comment(
      id: uuid.v4(), // Her zaman yeni bir UUID oluştur
      postId: widget.post.id,
      userId: _currentUser!.uid,
      userName: _currentUser!.name,
      text: _commentTextController.text,
      timestamp: DateTime.now(),
      userProfileUrl: _currentUser!.profileImageUrl

    );

    _postCubit.addComment(widget.post.id, newComment);
    _commentTextController.clear();
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Postu Sil"),
        content: const Text("Bu postu silmek istediğinize emin misiniz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          TextButton(
            onPressed: () {
              widget.onDeletePressed?.call();
              Navigator.pop(context);
            },
            child: const Text("Sil", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }


  @override
  void dispose() {
    _commentTextController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
// Çıktı: "15 Mayıs 2023"
  Future<void> _refreshPostAndComments() async {
    _fetchComments();
    _buildPostContent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      appBar: AppBar(
        title: const Text("Gönderi", style: AppTextStyles.semiBold),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Header and Content
            _buildPostContent(),

            // Comments Section
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 16),
              child: Text(
                "Yorumlar",
                style: AppTextStyles.semiBold.copyWith(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontSize: 20,
                ),
              ),
            ),

            // Comments List
            _buildCommentsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPostContent() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info
          _buildUserInfo(),
          const SizedBox(height: 10),

          // Post Image
          _buildPostImage(),
          const SizedBox(height: 16),

          // Post Text
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: Text(
              widget.post.text,
              style: AppTextStyles.medium.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          // Like/Comment Buttons
          _buildInteractionButtons(),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage2(uid: widget.post.userId),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 10,
            ),
            _postUser?.profileImageUrl != null
                ? CachedNetworkImage(
                    imageUrl: _postUser!.profileImageUrl!,
                    imageBuilder: (context, imageProvider) => CircleAvatar(
                      radius: 25,
                      backgroundImage: imageProvider,
                    ),
                    placeholder: (context, url) => const CircleAvatar(
                      radius: 25,
                      child: Icon(Icons.person),
                    ),
                    errorWidget: (context, url, error) => const CircleAvatar(
                      radius: 25,
                      child: Icon(Icons.error),
                    ),
                  )
                : const CircleAvatar(
                    radius: 25,
                    child: Icon(Icons.person),
                  ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.userName,
                  style: AppTextStyles.medium.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 18,
                  ),
                ),
                Text(
                  _formatDate(widget.post.timeStamp),
                  style: AppTextStyles.regular.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (_isOwnPost)
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: _showDeleteDialog,
              ),
          ],
        ),
      ),
    );
  }


  Widget _buildPostImage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Stack(
        children: [
          GestureDetector(
            onDoubleTap: _toggleLikePost,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: widget.post.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const SizedBox(
                      height: 300,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
                if (_showHeart)
                  Positioned.fill(
                    child: Center(
                      child: Lottie.asset(
                        'assets/lotties/heart.json',
                        width: 220,
                        repeat: false,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (widget.post.relatedMovieId != null &&
              widget.post.relatedMovieId!.isNotEmpty)
            Positioned(
              right: 2,
              bottom: 2,
              child: MovieCard(
                movieId: widget.post.relatedMovieId!,
                movieTitle: widget.post.relatedMovieTitle,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MovieDetailPage(
                        movieId: int.tryParse(widget.post.relatedMovieId!) ?? 0,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInteractionButtons() {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  widget.post.likes.contains(_currentUser?.uid)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: widget.post.likes.contains(_currentUser?.uid)
                      ? Colors.red
                      : Theme.of(context).colorScheme.primary,
                ),
                onPressed: _toggleLikePost,
              ),
              Text(
                widget.post.likes.length.toString(),
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  Icons.comment,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: _openNewCommentBox,
              ),
              FutureBuilder<int>(
                future: fetchCommentCount(widget.post.id),
                initialData: null, // Veya widget.post.commentCount gibi önceden bilinen bir değer
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return const SizedBox.shrink(); // Veya loading indicator
                  }
                  return Text(
                    snapshot.data.toString(),
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
              )
            ],
          ),

        ],
      ),
    );
  }

  Widget _buildCommentsSection() {
    return BlocBuilder<PostCubit, PostState>(
      builder: (context, state) {
        if (state is PostsLoaded) {
          final post = state.posts.firstWhere(
            (p) => p.id == widget.post.id,
            orElse: () => widget.post,
          );

          final comments = post.comments ?? [];

          if (comments.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Text(
                  "Henüz yorum yok",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];
              final currentUserId = context.read<AuthCubit>();

              return CommentTile3(
                comment: comment,
                userProfileImageUrl: comment.userProfileUrl,
                currentUserId: currentUser?.uid,
                onLikePressed: () async {
                  await context.read<PostCubit>().toggleLikeComment(
                      widget.post.id, comment.id, currentUser!.uid);
                },
              );
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
