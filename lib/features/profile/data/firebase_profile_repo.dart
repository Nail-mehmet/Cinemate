/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Cinemate/features/profile/domain/entities/profile_user.dart';
import 'package:Cinemate/features/profile/domain/repos/profile_repo.dart';

class FirebaseProfileRepo implements ProfileRepo {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<ProfileUser?> fetchUserProfile(String uid) async {
    try {
      // Kullanıcı temel bilgilerini çek
      final userDoc = await firebaseFirestore.collection('users').doc(uid).get();
      
      if (!userDoc.exists) return null;

      final userData = userDoc.data();
      if (userData == null) return null;

      // Subcollection'lardan film listelerini çek
      final watchedMovies = await _getSubcollectionIds(uid, 'watchedMovies');
      final favoriteMovies = await _getSubcollectionIds(uid, 'favoriteMovies');
      final savedlist = await _getSubcollectionIds(uid, 'savedlist');
      final topThreeMovies = await _getSubcollectionIds(uid, 'topThreeMovies');

      return ProfileUser(
        uid: uid,
        email: userData['email'],
        name: userData['name'],
        bio: userData['bio'] ?? '',
        profileImageUrl: userData['profileImageUrl'] ?? '',
        bgImageUrl: userData['bgImageUrl'] ?? '',
        followers: List<String>.from(userData['followers'] ?? []),
        following: List<String>.from(userData['following'] ?? []),
        watchedMovies: watchedMovies,
        favoriteMovies: favoriteMovies,
        savedlist: savedlist,
        topThreeMovies: topThreeMovies,
      );
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  Future<List<String>> _getSubcollectionIds(String userId, String collectionName) async {
    try {
      final snapshot = await firebaseFirestore
          .collection('users')
          .doc(userId)
          .collection(collectionName)
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print('Error fetching $collectionName: $e');
      return [];
    }
  }


  @override
  Future<void> updateProfile(ProfileUser updatedProfile) async {
    try {
      await firebaseFirestore
          .collection("users")
          .doc(updatedProfile.uid)
          .update({
            "bio": updatedProfile.bio,
            "profileImageUrl": updatedProfile.profileImageUrl,
            "bgImageUrl": updatedProfile.bgImageUrl,
            "name" : updatedProfile.name
          });
    } catch (e) {
      throw Exception(e);
    }
  }
  
  @override
  Future<void> toggleFollow(String currentUid, String targetUid) async {
  try {
    final currentUserDoc = await firebaseFirestore.collection("users").doc(currentUid).get();
    final targetUserDoc = await firebaseFirestore.collection("users").doc(targetUid).get();

    if (currentUserDoc.exists && targetUserDoc.exists) {
      final currentUserData = currentUserDoc.data();
      final targetUserData = targetUserDoc.data();

      if (currentUserData != null && targetUserData != null) {
        final List<String> currentFollowing = List<String>.from(currentUserData["following"] ?? []);

        if (currentFollowing.contains(targetUid)) {
          // Takipten çıkma
          await firebaseFirestore.collection("users").doc(currentUid).update({
            "following": FieldValue.arrayRemove([targetUid])
          });

          await firebaseFirestore.collection("users").doc(targetUid).update({
            "followers": FieldValue.arrayRemove([currentUid])
          });
        } else {
          // Takip etme
          await firebaseFirestore.collection("users").doc(currentUid).update({
            "following": FieldValue.arrayUnion([targetUid])
          });

          await firebaseFirestore.collection("users").doc(targetUid).update({
            "followers": FieldValue.arrayUnion([currentUid])
          });

          // Bildirim ekle
          await firebaseFirestore
              .collection("users")
              .doc(targetUid)
              .collection("notifications")
              .add({
            "type": "follow",
            "fromUserId": currentUid,
            "timestamp": FieldValue.serverTimestamp(),
            "isRead": false
          });
        }
      }
    }
  } catch (e) {
    throw Exception(e);
  }
}

}*/