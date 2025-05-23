/*

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nail/features/auth/presentation/cubits/auth_cubits.dart';
import 'package:nail/features/post/domain/entities/comment.dart';
import 'package:nail/features/post/presentation/cubits/post_cubit.dart';

import '../../../auth/domain/entities/app_user.dart';

class CommentTile2 extends StatefulWidget {
  final Comment comment;
  const CommentTile2({super.key, required this.comment});

  @override
  State<CommentTile2> createState() => _CommentTile2State();
}

class _CommentTile2State extends State<CommentTile2> {

  AppUser? currentUser;
  bool isOwnPost = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    isOwnPost = (widget.comment.userId == currentUser!.uid);
  }

  void showOptions() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("yorumu Silmek istediğine emin misin?"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("İptal")),
                TextButton(
                    onPressed: () {
                      context
                        .read<PostCubit>()
                        .deleteComment(widget.comment.postId, widget.comment.id);
                      Navigator.of(context).pop();
                    },
                    child: Text("İptal")),
              ],
            ));
  }

  
  @override
  Widget build(BuildContext context) {
    return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [
              Text(widget.comment.userName,style: TextStyle(fontWeight: FontWeight.bold),),

              const SizedBox(width: 10,),
          
              Text(widget.comment.text),

              const Spacer(),

              if(isOwnPost)
                GestureDetector(
                  onTap: showOptions,
                  child: Icon(Icons.more_horiz, color: Theme.of(context).colorScheme.primary,),
                )
  
            ],
          ),
        );
}
}*/