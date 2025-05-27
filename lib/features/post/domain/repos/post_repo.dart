import 'package:Cinemate/features/post/domain/entities/comment.dart';
import 'package:Cinemate/features/post/domain/entities/post.dart';

abstract class PostRepo {
  Future<List<Post>> fetchAllPosts({required int page, required int perPage});
  Future<void> createPost(Post post);
  Future<void> deletePost(String postId);
  Future<List<Post>> fetchPostsByUserId(String userId);
  Future<void> toggleLikePost(String postId, String userId);
  Future<void> addComment(String postId, Comment comment);
  Future<void> deleteComment(String postId, String commentId);
  Future<List<Comment>> fetchCommentsForPost(String postId);
  Stream<List<Comment>> streamCommentsForPost(String postId);
  Future<void> toggleLikeComment(String postId, String commentId, String userId);

}
