import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:Cinemate/features/profile/domain/entities/profile_user.dart';
import 'package:Cinemate/features/profile/domain/repos/profile_repo.dart';

class SupabaseProfileRepo implements ProfileRepo {
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  Future<ProfileUser?> fetchUserProfile(String uid) async {
    try {
      // profiles tablosundan user kaydını çek, is_premium alanını da seç
      final profileData = await supabase
          .from('profiles')
          .select()
          .eq('id', uid)
          .maybeSingle();

      if (profileData == null) return null;

      // Kullanıcının premium durumunu al
      final bool isPremium = profileData['is_premium'] ?? false;

      // Temel film listelerini çek
      final watchedMovies = await getUserMovies(uid, 'watched_movies');
      final favoriteMovies = await getUserMovies(uid, 'favorite_movies');
      final savedlist = await getUserMovies(uid, 'savedlist_movies');

      // Premium kullanıcılar için ekstra özellikler
      List<String> topThreeMovies = [];
      if (isPremium) {
        topThreeMovies = await getUserMovies(uid, 'top_three_movies');
      }

      // Takipçi ve takip edilenler
      final followers = await _getFollowers(uid);
      final following = await _getFollowing(uid);

      return ProfileUser(
        uid: uid,
        email: profileData['email'],
        name: profileData['name'],
        bio: profileData['bio'] ?? '',
        profileImageUrl: profileData['profile_image'] ?? '',
        followers: followers,
        following: following,
        watchedMovies: watchedMovies,
        favoriteMovies: favoriteMovies,
        savedlist: savedlist,
        topThreeMovies: topThreeMovies,
        isPremium: isPremium,
      );
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  Future<List<String>> getUserMovies(String userId, String tableName) async {
    try {
      final List<dynamic> data = await supabase
          .from(tableName)
          .select('movie_id')
          .eq('user_id', userId);

      return data.map((e) => e['movie_id'].toString()).toList();
    } catch (e) {
      print('Error fetching $tableName: $e');
      return [];
    }
  }


  Future<List<String>> _getFollowers(String userId) async {
    try {
      final List<dynamic> data = await supabase
          .from('user_relationships')
          .select('follower_id')
          .eq('following_id', userId);

      return data.map((e) => e['follower_id'] as String).toList();
    } catch (e) {
      print('Error fetching followers: $e');
      return [];
    }
  }

  Future<List<String>> _getFollowing(String userId) async {
    try {
      final List<dynamic> data = await supabase
          .from('user_relationships')
          .select('following_id')
          .eq('follower_id', userId);

      return data.map((e) => e['following_id'] as String).toList();
    } catch (e) {
      print('Error fetching following: $e');
      return [];
    }
  }

  @override
  Future<void> updateProfile(ProfileUser updatedProfile) async {
    try {
      final updates = {
        'bio': updatedProfile.bio,
        'profile_image': updatedProfile.profileImageUrl,
        'name': updatedProfile.name,
        'email': updatedProfile.email, // Eğer email de güncelleniyorsa ekle
      };

      final response = await supabase
          .from('profiles')
          .update(updates)
          .eq('id', updatedProfile.uid);
            // Eğer kullandığın supabase paketinde gerekliyse

      if (response.error != null) {
        throw Exception('Failed to update profile: ${response.error!.message}');
      }

      if (response.data == null) {
        throw Exception('No data returned from update query');
      }

      // Güncelleme başarılı
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }


  @override
  Future<void> toggleFollow(String currentUid, String targetUid) async {
    try {
      // Takip ilişkisini kontrol et
      final response = await supabase
          .from('user_relationships')
          .select()
          .eq('follower_id', currentUid)
          .eq('following_id', targetUid);

      if (response.isNotEmpty) {
        // Zaten takip ediyorsa, takipten çıkar
        await supabase
            .from('user_relationships')
            .delete()
            .eq('follower_id', currentUid)
            .eq('following_id', targetUid);
      } else {
        // Takip et
        await supabase.from('user_relationships').insert({
          'follower_id': currentUid,
          'following_id': targetUid,
          'created_at': DateTime.now().toIso8601String(),
        });

        // Bildirim ekle
        await supabase.from('notifications').insert({
          'user_id': targetUid,
          'type': 'follow',
          'from_user_id': currentUid,
          'created_at': DateTime.now().toIso8601String(),
          'is_read': false,
        });
      }
    } catch (e) {
      throw Exception('Takip işlemi başarısız: $e');
    }
  }


}
