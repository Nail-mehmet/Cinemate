import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Supabase import eklenmeli
import '../../profile/domain/entities/profile_user.dart';

class UserProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client; // Supabase instance
  ProfileUser? _user;
  bool _isPremium = false;

  ProfileUser? get user => _user;
  bool get isPremium => _isPremium;

  // İsim çakışmasını önlemek için fonksiyonu yeniden adlandıralım
  Future<void> loadUserProfile(String uid) async {
    try {
      // profiles tablosundan verileri çek
      final profileData = await _supabase
          .from('profiles')
          .select()
          .eq('id', uid)
          .maybeSingle();

      if (profileData == null) return;

      // Film listelerini çek (örnek olarak sadece watchedMovies gösteriyorum)
      final watchedMovies = await _getUserMovies(uid, 'watched_movies');

      _user = ProfileUser(
        uid: uid,
        email: profileData['email'],
        name: profileData['name'],
        bio: profileData['bio'] ?? '',
        business: profileData["business"] ?? "",
        profileImageUrl: profileData['profile_image'] ?? '',
        followers: List<String>.from(profileData['followers'] ?? []),
        following: List<String>.from(profileData['following'] ?? []),
        watchedMovies: watchedMovies,
        isPremium: profileData['is_premium'] ?? false,
      );

      _isPremium = _user?.isPremium ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  Future<void> updatePremiumStatus(bool status) async {
    if (_user == null) return;

    try {
      await _supabase
          .from('profiles') // Dikkat: profiles olmalı
          .update({'is_premium': status})
          .eq('id', _user!.uid);

      _isPremium = status;
      _user = _user?.copyWith(newIsPremium: status);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating premium status: $e');
    }
  }

  // Örnek film çekme fonksiyonu
  Future<List<String>> _getUserMovies(String uid, String tableName) async {
    final response = await _supabase
        .from(tableName)
        .select('movie_id')
        .eq('user_id', uid);

    return response.map<String>((item) => item['movie_id'].toString()).toList();
  }
}