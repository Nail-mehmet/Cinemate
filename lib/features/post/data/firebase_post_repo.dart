/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Cinemate/features/post/domain/entities/comment.dart';
import 'package:Cinemate/features/post/domain/entities/post.dart';
import 'package:Cinemate/features/post/domain/repos/post_repo.dart';

class FirebasePostRepo implements PostRepo{
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // store the posts in a collection callled posts
  final CollectionReference postsCollection = FirebaseFirestore.instance.collection("posts");
  @override
  Future<void> createPost(Post post) async{
    try{

      await postsCollection.doc(post.id).set(post.toJson());

    }catch(e){
      throw Exception("Post oluşturulken hata oldu. $e");
    }
  }

  @override
  Future<void> deletePost(String postId) async{
    await postsCollection.doc(postId).delete();
  }

  @override
  Future<List<Post>> fetchAllPosts({required int page, required int perPage}) async {
  try {
    // İlk olarak sıralı şekilde tüm postları getiriyoruz
    final postsSnapshot = await postsCollection
        .orderBy("timestamp", descending: true)
        .limit((page + 1) * perPage) // Şu ana kadarki tüm postları çekiyoruz
        .get();

    final allPosts = postsSnapshot.docs
        .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
        .toList();

    // Sayfaya göre kesiyoruz (örnek: page=0, 0-9; page=1, 10-19 arası postlar)
    final start = page * perPage;
    final end = start + perPage;

    // Firestore'da direkt "offset" olmadığı için bunu kod içinde kesiyoruz
    final paginatedPosts = allPosts.length > start
        ? allPosts.sublist(start, end > allPosts.length ? allPosts.length : end)
        : <Post>[];

    return paginatedPosts;
  } catch (e) {
    throw Exception("Error yüklenirken oluştu: $e");
  }
}


  @override
  Future<List<Post>> fetchPostsByUserId(String userId) async {
    try{
      // fetch posts snapshot with this uid
      final postsSnapshot = await postsCollection.where("userId", isEqualTo: userId).get();

      // convert ifrestore ocument from json -> list of posts
      final userPosts = postsSnapshot.docs
      .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
      .toList();


      return userPosts; 

    }catch(e) {
      throw Exception("error fetching posts by user: $e");
    }
  }
  
  @override
  Future<void> toggleLikePost(String postId, String userId) async {
  try {
    // get the post document
    final postDoc = await postsCollection.doc(postId).get();

    if (postDoc.exists) {
      final postData = postDoc.data() as Map<String, dynamic>;
      final post = Post.fromJson(postData);

      final hasLiked = post.likes.contains(userId);

      if (hasLiked) {
        // Unlike
        post.likes.remove(userId);
      } else {
        // Like
        post.likes.add(userId);

        // Bildirim ekle (kendine beğeni yapmadıysa)
        if (post.userId != userId) {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(post.userId)
              .collection("notifications")
              .add({
            "type": "like",
            "fromUserId": userId,
            "postId": postId,
            "timestamp": FieldValue.serverTimestamp(),
            "isRead": false
          });
        }
      }

      // Update likes list in Firestore
      await postsCollection.doc(postId).update({
        "likes": post.likes,
      });
    } else {
      throw Exception("Post bulunamadı");
    }
  } catch (e) {
    throw Exception("Hata oluştu: $e");
  }
}


  @override
  Future<void> addComment(String postId, Comment comment) async {
  try {
    // Check if post exists
    final postDoc = await postsCollection.doc(postId).get();
    
    if (!postDoc.exists) {
      throw Exception("Post bulunamadı");
    }
    
    // Add comment to the comments subcollection
    await postsCollection
        .doc(postId)
        .collection('comments')
        .doc(comment.id)
        .set(comment.toJson());
        
  } catch (e) {
    throw Exception("Yorum yüklenemedi: $e");
  }
}

Future<void> toggleLikeComment(String postId, String commentId, String userId) async {
  final commentRef = FirebaseFirestore.instance
      .collection('posts')
      .doc(postId)
      .collection('comments')
      .doc(commentId);

  await FirebaseFirestore.instance.runTransaction((transaction) async {
    final snapshot = await transaction.get(commentRef);
    if (!snapshot.exists) return;

    final data = snapshot.data()!;
    final likes = List<String>.from(data['likes'] ?? []);

    if (likes.contains(userId)) {
      likes.remove(userId);
    } else {
      likes.add(userId);
    }

    transaction.update(commentRef, {'likes': likes});
  });
}


@override
@override
Stream<List<Comment>> streamCommentsForPost(String postId) {
  return postsCollection
      .doc(postId)
      .collection('comments')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Comment.fromJson(doc.data()))
          .toList());
}



@override
Future<void> deleteComment(String postId, String commentId) async {
  try {
    // Check if post exists
    final postDoc = await postsCollection.doc(postId).get();
    
    if (!postDoc.exists) {
      throw Exception("Post bulunamadı");
    }
    
    // Delete the comment from the subcollection
    await postsCollection
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .delete();
        
  } catch (e) {
    throw Exception("Yorum silinemedi: $e");
  }
}
@override
Future<List<Comment>> fetchCommentsForPost(String postId) async {
  try {
    final commentsSnapshot = await postsCollection
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .get();

    return commentsSnapshot.docs
        .map((doc) => Comment.fromJson(doc.data()))
        .toList();
  } catch (e) {
    throw Exception("Yorumlar yüklenemedi: $e");
  }
}



}*/