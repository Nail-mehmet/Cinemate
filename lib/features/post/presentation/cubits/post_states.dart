import '../../domain/entities/post.dart';
import '../../domain/entities/comment.dart';

abstract class PostState {}

//initial
class PostsInitial extends PostState {}

//loading
class PostsLoading extends PostState {}

class PostsLoadingMore extends PostState {
  final List<Post> currentPosts;
  PostsLoadingMore(this.currentPosts);
}

//uploading
class PostsUploading extends PostState{}

// error
class PostsError extends PostState{
  final String message;
  PostsError(this.message);
}
class CommentsLoading extends PostState {}

// loaded
class PostsLoaded extends PostState {
  final List<Post> posts;
  final bool hasMore;

  PostsLoaded(this.posts, {required this.hasMore});
}
class CommentsLoaded extends PostState {
  final List<Comment> comments;

  CommentsLoaded(this.comments);
}