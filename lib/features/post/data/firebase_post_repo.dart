import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:Cinemate/features/post/domain/entities/comment.dart';
import 'package:Cinemate/features/post/domain/entities/post.dart';
import 'package:Cinemate/features/post/domain/repos/post_repo.dart';

class SupabasePostRepo implements PostRepo {
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  @override
  Future<void> createPost(Post post) async {
    try {
      final response = await supabase
          .from('posts')
          .insert(post.toJson());

     /* if (response.error != null) {
        throw Exception(response.error!.message);
      }*/
    } catch (e) {
      throw Exception("Post oluşturulurken hata oldu: $e");
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      // Önce yorumları sil (foreign key constraint için)
      await supabase.from('post_comments').delete().eq('post_id', postId);
      // Sonra postu sil
      await supabase.from('posts').delete().eq('id', postId);
    } catch (e) {
      throw Exception("Post silinirken hata oldu: $e");
    }
  }

  @override
  Future<List<Post>> fetchAllPosts({required int page, required int perPage}) async {
    try {
      final response = await supabase
          .from('posts')
          .select()
          .order('created_at', ascending: false)
          .range(page * perPage, (page + 1) * perPage - 1);

      return (response as List).map((post) => Post.fromJson(post)).toList();
    } catch (e) {
      throw Exception("Postlar yüklenirken hata oluştu: $e");
    }
  }

  @override
  Future<List<Post>> fetchPostsByUserId(String userId) async {
    try {
      final response = await supabase
          .from('posts')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((post) => Post.fromJson(post)).toList();
    } catch (e) {
      throw Exception("Kullanıcı postları yüklenirken hata oluştu: $e");
    }
  }

  @override
  Future<void> toggleLikePost(String postId, String userId) async {
    try {
      // Postu al
      final postResponse = await supabase
          .from('posts')
          .select('likes, user_id')
          .eq('id', postId)
          .single();

      final post = postResponse as Map<String, dynamic>;
      final likes = List<String>.from(post['likes'] ?? []);
      final postOwnerId = post['user_id'] as String;

      // Like durumunu kontrol et ve güncelle
      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId);

        // Bildirim oluştur (kendine like atmadıysa)
        if (postOwnerId != userId) {

          await supabase.from('notifications').insert({
            'user_id': postOwnerId,
            'type': 'like',
            'from_user_id': userId,
            'created_at': DateTime.now().toIso8601String(),
            'is_read': false,
            "post_id": postId
          });
        }
      }

      // Postu güncelle
      await supabase
          .from('posts')
          .update({'likes': likes})
          .eq('id', postId);
    } catch (e) {
      throw Exception("Like işlemi sırasında hata: $e");
    }
  }

  @override
  Future<void> addComment(String postId, Comment comment) async {
    try {
      // Postun varlığını kontrol et
      final postExists = await supabase
          .from('posts')
          .select('id')
          .eq('id', postId)
          .maybeSingle();

      if (postExists == null) {
        throw Exception("Post bulunamadı");
      }

      // Yorumu ekle
      await supabase.from('post_comments').insert(comment.toJson());

      // Bildirim oluştur (kendine yorum yapmadıysa)
      /*final post = postExists as Map<String, dynamic>;
      if (post['user_id'] != comment.userId) {
        await supabase.from('notifications').insert({
          'user_id': post['user_id'],
          'type': 'comment',
          'from_user_id': comment.userId,
          'id': postId,
          'created_at': DateTime.now().toIso8601String(),//comment.id,
          'is_read': false
        });
      }*/
    } catch (e) {
      throw Exception("Yorum eklenirken hata oluştu: $e");
    }
  }

  @override
  Future<void> toggleLikeComment(String postId, String commentId, String userId) async {
    try {
      // Yorumu al
      final commentResponse = await supabase
          .from('post_comments')
          .select('likes')
          .eq('id', commentId)
          .single();

      final comment = commentResponse as Map<String, dynamic>;
      final likes = List<String>.from(comment['likes'] ?? []);

      // Like durumunu kontrol et ve güncelle
      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId);
      }

      // Yorumu güncelle
      await supabase
          .from('post_comments')
          .update({'likes': likes})
          .eq('id', commentId);
    } catch (e) {
      throw Exception("Yorum like işlemi sırasında hata: $e");
    }
  }

  @override
  Stream<List<Comment>> streamCommentsForPost(String postId) {
    return supabase
        .from('post_comments')
        .stream(primaryKey: ['id'])
        .eq('post_id', postId)
        .order('created_at', ascending: false)
        .map((snapshot) =>
        (snapshot as List).map((comment) => Comment.fromJson(comment)).toList());
  }

  @override
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await supabase
          .from('post_comments')
          .delete()
          .eq('id', commentId)
          .eq('post_id', postId);
    } catch (e) {
      throw Exception("Yorum silinirken hata oluştu: $e");
    }
  }

  @override
  Future<List<Comment>> fetchCommentsForPost(String postId) async {
    try {
      final response = await supabase
          .from('post_comments')
          .select()
          .eq('post_id', postId)
          .order('created_at', ascending: false);

      return (response as List).map((comment) => Comment.fromJson(comment)).toList();
    } catch (e) {
      throw Exception("Yorumlar yüklenirken hata oluştu: $e");
    }
  }
}