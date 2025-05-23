/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addComment({
  required String movieId,
  required String commentText,
  required double rating,
  String? movieTitle,
  required bool spoiler,
}) async {
  final user = _auth.currentUser;
  if (user == null) throw Exception("Kullanıcı giriş yapmamış");

  final commentData = {
    'userId': user.uid,
    'comment': commentText,
    'rating': rating,
    'spoiler': spoiler,
    'timestamp': FieldValue.serverTimestamp(),
  };

  final movieRef = _firestore.collection('movies').doc(movieId);
  final commentsRef = movieRef.collection('comments');
  final userReviewRef = _firestore
      .collection('users')
      .doc(user.uid)
      .collection('movie_reviews')
      .doc(movieId);

  await commentsRef.add(commentData);

  await userReviewRef.set({
    'movieId': movieId,
    'comment': commentText,
    'rating': rating,
    'spoiler': spoiler,
    'timestamp': FieldValue.serverTimestamp(),
    'movieTitle': movieTitle,
  });

  final allComments = await commentsRef.get();
  double total = 0;
  int count = 0;

  for (var doc in allComments.docs) {
    final data = doc.data();
    if (data.containsKey('rating') && data['rating'] is num) {
      total += (data['rating'] as num).toDouble();
      count++;
    }
  }

  final average = count > 0 ? total / count : 0;

  await movieRef.set({
    'averageRating': average,
  }, SetOptions(merge: true));
}


}
*/