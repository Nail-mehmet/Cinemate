import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Cinemate/features/post/domain/entities/comment.dart';
import 'package:Cinemate/features/post/domain/entities/post.dart';
import 'package:Cinemate/features/post/domain/repos/post_repo.dart';
import 'package:Cinemate/features/post/presentation/cubits/post_states.dart';
import 'package:Cinemate/features/storage/domain/storage_repo.dart';
import 'package:uuid/uuid.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepo postRepo;
  final StorageRepo storageRepo;
  final Uuid uuid = const Uuid();

  List<Post> _allPosts = [];
  List<Post> _filteredPosts = [];
  String? _selectedCategory;
  int _page = 0;
  final int _perPage = 10;
  bool _hasMore = true;
  final StreamController<List<Post>> _postsStreamController = StreamController.broadcast();

  Stream<List<Post>> get postsStream => _postsStreamController.stream;

  PostCubit({required this.postRepo, required this.storageRepo})
      : super(PostsInitial());

  bool _isValidUuid(String id) {
    final uuidRegex = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$');
    return uuidRegex.hasMatch(id);
  }

  Future<void> createPost(Post post, {String? imagePath, Uint8List? imageBytes}) async {
    try {
      String? imageUrl;

      // 1. Resmi yükle (eğer varsa)
      if (imagePath != null || imageBytes != null) {
        emit(PostsUploading());
        imageUrl = imagePath != null
            ? await storageRepo.uploadPostImageMobile(imagePath, post.id)
            : await storageRepo.uploadPostImageWeb(imageBytes!, post.id);
      }

      // 2. Post nesnesini güncelle (imageUrl ekleyerek)
      final newPost = post.copyWith(
        id: _isValidUuid(post.id) ? post.id : uuid.v4(),
        imageUrl: imageUrl, // Resim URL'sini ekliyoruz
      );

      // 3. Post'u veritabanına kaydet
      await postRepo.createPost(newPost);

      // 4. State'i güncelle
      _allPosts.insert(0, newPost);
      _applyFilter();
      emit(PostsLoaded(_filteredPosts, hasMore: _hasMore));

    } catch (e) {
      emit(PostsError("Post oluşturulamadı: ${e.toString()}"));
      rethrow; // Hatanın üst katmana iletilmesi için
    }
  }

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
      emit(PostsError("Postlar yüklenirken hata oluştu: $e"));
    }
  }

  Future<void> fetchPostsForUser(String uid) async {
    emit(PostsLoading());
    try {
      final userPosts = await postRepo.fetchPostsByUserId(uid);
      _allPosts = userPosts;
      _applyFilter();
    } catch (e) {
      emit(PostsError("Kullanıcı postları yüklenirken hata oluştu"));
    }
  }

  Future<void> toggleLikePost(String postId, String userId) async {
    try {
      await postRepo.toggleLikePost(postId, userId);

      // Postu güncelle
      final index = _allPosts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        final post = _allPosts[index];
        final likes = List<String>.from(post.likes);
        if (likes.contains(userId)) {
          likes.remove(userId);
        } else {
          likes.add(userId);
        }
        _allPosts[index] = post.copyWith(likes: likes);
        _applyFilter();
      }
    } catch (e) {
      emit(PostsError("Beğeni işlemi sırasında hata: $e"));
    }
  }

  Future<void> addComment(String postId, Comment comment) async {
    try {
      await postRepo.addComment(postId, comment);

      // Yorumları yeniden yükle
      final comments = await postRepo.fetchCommentsForPost(postId);

      // Postu güncelle
      final index = _allPosts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        _allPosts[index] = _allPosts[index].copyWith(comments: comments);
        _applyFilter();
      }
    } catch (e) {
      emit(PostsError("Yorum eklenirken hata oluştu: $e"));
    }
  }

  Future<void> toggleLikeComment(String postId, String commentId, String userId) async {
    try {
      await postRepo.toggleLikeComment(postId, commentId, userId);

      // Yorumları yeniden yükle
      final comments = await postRepo.fetchCommentsForPost(postId);

      // Postu güncelle
      final index = _allPosts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        _allPosts[index] = _allPosts[index].copyWith(comments: comments);
        _applyFilter();
      }
    } catch (e) {
      emit(PostsError("Yorum beğenisi değiştirilirken hata oluştu: $e"));
    }
  }

  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await postRepo.deleteComment(postId, commentId);

      // Yorumları yeniden yükle
      final comments = await postRepo.fetchCommentsForPost(postId);

      // Postu güncelle
      final index = _allPosts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        _allPosts[index] = _allPosts[index].copyWith(comments: comments);
        _applyFilter();
      }
    } catch (e) {
      emit(PostsError("Yorum silinirken hata oluştu: $e"));
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await postRepo.deletePost(postId);

      // Postu listeden kaldır
      _allPosts.removeWhere((p) => p.id == postId);
      _applyFilter();
    } catch (e) {
      emit(PostsError("Post silinirken hata oluştu: $e"));
    }
  }

  Future<void> fetchCommentsForPost(String postId) async {
    try {
      emit(PostsLoading());
      final comments = await postRepo.fetchCommentsForPost(postId);

      // Postu güncelle
      final index = _allPosts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        _allPosts[index] = _allPosts[index].copyWith(comments: comments);
        _applyFilter();
      }
    } catch (e) {
      emit(PostsError("Yorumlar yüklenirken hata oluştu: $e"));
    }
  }

  Stream<List<Comment>> streamCommentsForPost(String postId) {
    return postRepo.streamCommentsForPost(postId);
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
    _postsStreamController.add(_filteredPosts);
  }

  @override
  Future<void> close() {
    _postsStreamController.close();
    return super.close();
  }
}