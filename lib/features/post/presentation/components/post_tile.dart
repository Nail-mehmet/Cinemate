
/*import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nail/features/auth/domain/entities/app_user.dart';
import 'package:nail/features/auth/presentation/components/my_text_field.dart';
import 'package:nail/features/auth/presentation/cubits/auth_cubits.dart';
import 'package:nail/features/post/domain/entities/comment.dart';
import 'package:nail/features/post/presentation/components/comment_tile2.dart';
import 'package:nail/features/post/presentation/cubits/post_states.dart';
import 'package:nail/features/profile/presentation/pages/profile_page.dart';

import '../../domain/entities/post.dart';
import '../cubits/post_cubit.dart';
import '../../../profile/domain/entities/profile_user.dart';
import '../../../profile/presentation/cubits/profile_cubit.dart';

// profil sayfası için bu
class PostTile extends StatefulWidget {
  final Post post;
  final void Function()? onDeletePressed;
  const PostTile(
      {super.key, required this.post, required this.onDeletePressed});

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  // cubits
  late final postCubit = context.read<PostCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  bool isOwnPost = false;

  // current user
  AppUser? currentUser;

  // post user
  ProfileUser? postUser;

  @override
  void initState() {
    super.initState();

    getCurrentUser();
    fetchPostUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    isOwnPost = (widget.post.userId == currentUser!.uid);
  }

  Future<void> fetchPostUser() async {
    final fetchedUser = await profileCubit.getUserProfile(widget.post.userId);
    if (fetchedUser != null) {
      setState(() {
        postUser = fetchedUser;
      });
    }
  }

  // user tapped like button
  void toggleLikePost() {
    // current like status
    final isLiked = widget.post.likes.contains(currentUser!.uid);

    // optiimistically like and upate ui
    setState(() {
      if (isLiked) {
        widget.post.likes.remove(currentUser!.uid);
      } else {
        widget.post.likes.add(currentUser!.uid);
      }
    });

    //update like
    postCubit
        .toggleLikePost(widget.post.id, currentUser!.uid)
        .catchError((error) {
      setState(() {
        if (isLiked) {
          widget.post.likes.add(currentUser!.uid);
        } else {
          widget.post.likes.remove(currentUser!.uid);
        }
      });
    });
  }

  final commentTextController = TextEditingController();

  // openc comment boc
  void openNewCommentBox() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: MyTextField(
                  controller: commentTextController,
                  hintText: "yorum ekle",
                  obscureText: false),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop,
                    child: Text("iptal")),
                TextButton(
                    onPressed: () {
                      addComment();
                      Navigator.of(context).pop();
                    },
                    child: Text("kaydet")),
              ],
            ));
  }

  void addComment() {
    final newComment = Comment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        postId: widget.post.id,
        userId: currentUser!.uid,
        userName: currentUser!.name,
        text: commentTextController.text,
        timestamp: DateTime.now());

    // add comment using cubit
    if (commentTextController.text.isNotEmpty) {
      postCubit.addComment(widget.post.id, newComment);
    }
  }

  @override
  void dispose() {
    commentTextController.dispose();
    super.dispose();
  }

  void showOptions() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Postu Silmek istediğine emin misin?"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("İptal")),
                TextButton(
                    onPressed: () {
                      widget.onDeletePressed!();
                      Navigator.of(context).pop();
                    },
                    child: Text("İptal")),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: Column(
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(
                  uid: widget.post.userId,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // profile pic
                  postUser?.profileImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: postUser!.profileImageUrl,
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.person),
                          imageBuilder: (context, imageProvider) => Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                )),
                          ),
                        )
                      : const Icon(Icons.person),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    widget.post.userName,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            
                  const Spacer(),
                  if (isOwnPost)
                    GestureDetector(
                      onTap: showOptions,
                      child: Icon(
                        Icons.delete,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                ],
              ),
            ),
          ),
          CachedNetworkImage(
            imageUrl: widget.post.imageUrl,
            height: 430,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => const SizedBox(
              height: 430,
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),

          // buttons like comment t,mestamp
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Row(
                    children: [
                      // like button
                      GestureDetector(
                        onTap: toggleLikePost,
                        child: Icon(
                            widget.post.likes.contains(currentUser!.uid)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: widget.post.likes.contains(currentUser!.uid)
                                ? Colors.red
                                : Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        widget.post.likes.length.toString(),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
                // comment button
                GestureDetector(
                    onTap: openNewCommentBox,
                    child: Icon(
                      Icons.comment,
                      color: Theme.of(context).colorScheme.primary,
                    )),

                Text(
                  widget.post.comments.length.toString(),
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12),
                ),

                const Spacer(),

                //timestamo
                Text(widget.post.timeStamp.toString()),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
            child: Row(
              
              children: [
                Text(widget.post.userName,
                style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(width: 10,),
            
                Text(widget.post.text)
              ],
            ),
          ),

          //comment section
          BlocBuilder<PostCubit, PostState>(
            builder: (context, state) {
              if(state is PostsLoaded){
                final post = state.posts.firstWhere((post) => (post.id == widget.post.id));

                if(post.comments.isNotEmpty){
                  int showCommentCount = post.comments.length;

                  return ListView.builder(
                    itemCount: showCommentCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final comment = post.comments[index];

                      return CommentTile2(comment: comment);
                    },
                  );
                }
              }

              if(state is PostsLoading){
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              else if (state is PostsError){
                return Center(
                  child: Text(state.message),
                );
              }

              else {
                return const SizedBox();
              }
            }
            )


        ],
      ),
    );
  }
}
*/
/*
class PostTile extends StatefulWidget {
  final Post post;
  final void Function()? onDeletePressed;
  const PostTile(
      {super.key, required this.post, required this.onDeletePressed});

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  // cubits
  late final postCubit = context.read<PostCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  bool isOwnPost = false;

  // current user
  AppUser? currentUser;

  // post user
  ProfileUser? postUser;

  @override
  void initState() {
    super.initState();

    getCurrentUser();
    fetchPostUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    isOwnPost = (widget.post.userId == currentUser!.uid);
  }

  Future<void> fetchPostUser() async {
    final fetchedUser = await profileCubit.getUserProfile(widget.post.userId);
    if (fetchedUser != null) {
      setState(() {
        postUser = fetchedUser;
      });
    }
  }

  // user tapped like button
  void toggleLikePost() {
    // current like status
    final isLiked = widget.post.likes.contains(currentUser!.uid);

    // optiimistically like and upate ui
    setState(() {
      if (isLiked) {
        widget.post.likes.remove(currentUser!.uid);
      } else {
        widget.post.likes.add(currentUser!.uid);
      }
    });

    //update like
    postCubit
        .toggleLikePost(widget.post.id, currentUser!.uid)
        .catchError((error) {
      setState(() {
        if (isLiked) {
          widget.post.likes.add(currentUser!.uid);
        } else {
          widget.post.likes.remove(currentUser!.uid);
        }
      });
    });
  }

  final commentTextController = TextEditingController();

  // openc comment boc
  void openNewCommentBox() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: MyTextField(
                  controller: commentTextController,
                  hintText: "yorum ekle",
                  obscureText: false),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop,
                    child: Text("iptal")),
                TextButton(
                    onPressed: () {
                      addComment();
                      Navigator.of(context).pop();
                    },
                    child: Text("kaydet")),
              ],
            ));
  }

  void addComment() {
    final newComment = Comment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        postId: widget.post.id,
        userId: currentUser!.uid,
        userName: currentUser!.name,
        text: commentTextController.text,
        timestamp: DateTime.now());

    // add comment using cubit
    if (commentTextController.text.isNotEmpty) {
      postCubit.addComment(widget.post.id, newComment);
    }
  }

  @override
  void dispose() {
    commentTextController.dispose();
    super.dispose();
  }

  void showOptions() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Postu Silmek istediğine emin misin?"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("İptal")),
                TextButton(
                    onPressed: () {
                      widget.onDeletePressed!();
                      Navigator.of(context).pop();
                    },
                    child: Text("İptal")),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.secondary,
        child: Column(
          children: [
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(
                    uid: widget.post.userId,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // profile pic
                    postUser?.profileImageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: postUser!.profileImageUrl,
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.person),
                            imageBuilder: (context, imageProvider) => Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  )),
                            ),
                          )
                        : const Icon(Icons.person),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      widget.post.userName,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              
                    const Spacer(),
                    if (isOwnPost)
                      GestureDetector(
                        onTap: showOptions,
                        child: Icon(
                          Icons.delete,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                  ],
                ),
              ),
            ),
            CachedNetworkImage(
              imageUrl: widget.post.imageUrl,
              height: 430,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => const SizedBox(
                height: 430,
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
      
            // buttons like comment t,mestamp
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: Row(
                      children: [
                        // like button
                        GestureDetector(
                          onTap: toggleLikePost,
                          child: Icon(
                              widget.post.likes.contains(currentUser!.uid)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: widget.post.likes.contains(currentUser!.uid)
                                  ? Colors.red
                                  : Theme.of(context).colorScheme.primary),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          widget.post.likes.length.toString(),
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  // comment button
                  GestureDetector(
                      onTap: openNewCommentBox,
                      child: Icon(
                        Icons.comment,
                        color: Theme.of(context).colorScheme.primary,
                      )),
      
                  Text(
                    widget.post.comments.length.toString(),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12),
                  ),
      
                  const Spacer(),
      
                  //timestamo
                  Text(widget.post.timeStamp.toString()),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
              child: Row(
                
                children: [
                  Text(widget.post.userName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  ),
      
                  const SizedBox(width: 10,),
              
                  Text(widget.post.text)
                ],
              ),
            ),
      
            //comment section
            BlocBuilder<PostCubit, PostState>(
              builder: (context, state) {
                if(state is PostsLoaded){
                  final post = state.posts.firstWhere((post) => (post.id == widget.post.id));
      
                  if(post.comments.isNotEmpty){
                    int showCommentCount = post.comments.length;
      
                    return ListView.builder(
                      itemCount: showCommentCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final comment = post.comments[index];
      
                        return CommentTile(comment: comment);
                      },
                    );
                  }
                }
      
                if(state is PostsLoading){
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
      
                else if (state is PostsError){
                  return Center(
                    child: Text(state.message),
                  );
                }
      
                else {
                  return const SizedBox();
                }
              }
              )
      
      
          ],
        ),
      ),
    );
  }
}

*/