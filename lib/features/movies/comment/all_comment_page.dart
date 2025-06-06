import 'package:Cinemate/themes/font_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:Cinemate/features/movies/comment/comment_list.dart';
import 'package:Cinemate/features/movies/comment/comment_model.dart';

class AllCommentsPage extends StatelessWidget {
  final List<CommentModel> comments;

  const AllCommentsPage({Key? key, required this.comments}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tüm Yorumlar",style: AppTextStyles.bold,)),
      body: ListView.builder(
        itemCount: comments.length,
        itemBuilder: (context, index) {
          return CommentTile(comment: comments[index]);
        },
      ),
    );
  }
}

