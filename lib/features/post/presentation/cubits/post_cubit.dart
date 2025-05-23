/*import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Cinemate/features/post/domain/entities/comment.dart';
import 'package:Cinemate/features/post/domain/entities/post.dart';
import 'package:Cinemate/features/post/domain/repos/post_repo.dart';
import 'package:Cinemate/features/post/presentation/cubits/post_states.dart';
import 'package:Cinemate/features/storage/domain/storage_repo.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepo postRepo;
  final StorageRepo storageRepo;

  PostCubit({required this.postRepo, required this.storageRepo})
      : super(PostsInitial());


  // create w new post

  final StreamController<List<Post>> _postsStreamController = StreamController.broadcast();
  Stream<List<Post>> get postsStream => _postsStreamController.stream;

  // Yorum ekleme metodunu güncelleyelim
  Future<void> addComment(String postId, Comment comment) async {
    try {
      await postRepo.addComment(postId, comment);
      
      // Post'u güncelleyerek yorumları tekrar çek
      final updatedPost = await _updatePostWithComments(postId);
      
      // Tüm post listesini güncelle
      _updatePostInList(updatedPost);
      
      // Stream'i güncelle
      _postsStreamController.add(_filteredPosts);
    } catch (e) {
      emit(PostsError("Yorum yüklenemedi: $e"));
    }
  }

  Future<void> fetchPostsForUser(String uid) async {
  emit(PostsLoading());
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true) // 👈 En yeni post en üstte
        .get();

    final posts = snapshot.docs.map((doc) => Post.fromJson(doc.data())).toList();
    emit(PostsLoaded(posts, hasMore: false));
  } catch (e) {
    emit(PostsError("Failed to fetch user posts"));
  }
}



  Future<Post> _updatePostWithComments(String postId) async {
    final comments = await postRepo.fetchCommentsForPost(postId);
    final postIndex = _allPosts.indexWhere((p) => p.id == postId);
    if (postIndex != -1) {
      return _allPosts[postIndex].copyWith(comments: comments);
    }
    return _allPosts.firstWhere((p) => p.id == postId);
  }

  void _updatePostInList(Post updatedPost) {
    final postIndex = _allPosts.indexWhere((p) => p.id == updatedPost.id);
    if (postIndex != -1) {
      _allPosts[postIndex] = updatedPost;
      _applyFilter();
    }
  }
  Future<void> createPost(Post post,
  {String? imagePath, Uint8List? imageBytes})async{
    String? imageUrl;

    try{
      // handle image upload for mobile platforms

    if(imagePath != null){
      emit(PostsUploading());
      imageUrl = await storageRepo.uploadPostImageMobile(imagePath, post.id);
    }

    // handle image upload for web platforms
    else if (imageBytes != null){
      emit(PostsUploading());
      imageUrl = await storageRepo.uploadPostImageWeb(imageBytes, post.id);
    }

    // give imageurl to post
    final newPost = post.copyWith(imageUrl: imageUrl);

    // create post in the backend
    postRepo.createPost(newPost);

    // re-fetch allposts
    fetchAllPosts();
  } catch (e) {
    emit(PostsError("post oluştulumaadı: $e"));
    }
 }

 List<Post> _allPosts = [];
  List<Post> _filteredPosts = [];
  String? _selectedCategory;
  int _page = 0;
  final int _perPage = 10;
  bool _hasMore = true;

 //fetch all posts
  Future<void> fetchAllPosts({bool loadMore = false}) async {
    try {
      if (!loadMore) {
        _page = 0;
        _hasMore = true;
        emit(PostsLoading());
      } else {
        if (!_hasMore) return;
        _page++;
      }

      final newPosts = await postRepo.fetchAllPosts(page: _page, perPage: _perPage);
      
      if (!loadMore) {
        _allPosts = newPosts;
      } else {
        _allPosts.addAll(newPosts);
      }

      _hasMore = newPosts.length == _perPage;
      _applyFilter();
    } catch (e) {
      emit(PostsError("Senkronizasyon hatası: $e"));
    }
  }

  void updateCommentLikeLocally(String postId, String commentId, String userId) {
  final state = this.state;
  if (state is PostsLoaded) {
    final posts = state.posts.map((post) {
      if (post.id == postId) {
        final comments = post.comments?.map((comment) {
          if (comment.id == commentId) {
            final likes = List<String>.from(comment.likes);
            if (likes.contains(userId)) {
              likes.remove(userId);
            } else {
              likes.add(userId);
            }
            return comment.copyWith(likes: likes);
          }
          return comment;
        }).toList();
        return post.copyWith(comments: comments);
      }
      return post;
    }).toList();

    emit(PostsLoaded(posts, hasMore: true));
  }
}

  Future<void> toggleLikeComment(String postId, String commentId, String userId) async {
  final commentRef = FirebaseFirestore.instance
      .collection('posts')
      .doc(postId)
      .collection('comments')
      .doc(commentId);

  final commentSnap = await commentRef.get();

  if (!commentSnap.exists) return;

  List<String> currentLikes = List<String>.from(commentSnap['likes'] ?? []);
  if (currentLikes.contains(userId)) {
    currentLikes.remove(userId);
  } else {
    currentLikes.add(userId);
  }

  await commentRef.update({'likes': currentLikes});

  // Yorumları yeniden fetch ETME – sadece Firestore'da güncelleme yap
  // UI, CommentTile3 içinde lokal olarak güncelleniyor zaten
}


  void filterByCategory(String? category) {
    _selectedCategory = category;
    _applyFilter();
  }

  void _applyFilter() {
    if (_selectedCategory == null) {
      _filteredPosts = List.from(_allPosts);
    } else {
      _filteredPosts = _allPosts.where((post) => post.category == _selectedCategory).toList();
    }
    emit(PostsLoaded(_filteredPosts, hasMore: _hasMore));
  }

// delete apost

  Future<void> deletePost(String postId) async{
    try{
      await postRepo.deletePost(postId);
    } catch (e) {}
  }


 // toggle like on a post
 Future<void> toggleLikePost(String postId, String userId) async {

  try{
    await postRepo.toggleLikePost(postId, userId);
  } catch(e) {
    emit(PostsError("Hata oluştu: $e"));
  }
 }

/*
 // add a comment to a post
 Future<void> addComment(String postId, Comment comment) async {
  try {
    await postRepo.addComment(postId, comment);

    // Yeni yorumu ekledikten sonra yorumları tekrar çek
    final updatedComments = await postRepo.fetchCommentsForPost(postId);
    emit(CommentsLoaded(updatedComments));
  } catch (e) {
    emit(PostsError("yorum yüklenemedi $e"));
  }
}

*/




 // delete comment from a post
 Future<void> deleteComment(String postId, String commentId) async {
  try{
    await postRepo.deleteComment(postId, commentId);

    await fetchAllPosts();
  }catch (e) {
    emit(PostsError("yorum silinemei: $e"));
  }
 }

 Future<void> fetchCommentsForPost(String postId) async {
  try {
    emit(PostsLoading());
    final comments = await postRepo.fetchCommentsForPost(postId);
    
    // Mevcut post'u güncelleyerek yorumları ekleyelim
    final updatedPosts = _allPosts.map((post) {
      if (post.id == postId) {
        return post.copyWith(comments: comments);
      }
      return post;
    }).toList();

    _allPosts = updatedPosts;
    _applyFilter();
  } catch (e) {
    emit(PostsError("Yorumlar yüklenemedi: $e"));
  }
}


}*/

