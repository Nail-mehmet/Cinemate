import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Cinemate/features/profile/domain/repos/profile_repo.dart';
import 'package:Cinemate/features/profile/presentation/cubits/profile_states.dart';
import 'package:Cinemate/features/storage/domain/storage_repo.dart';
import 'package:http/http.dart' as http;
import '../../../notifications/domain/repositories/notification_repository.dart';
import '../../domain/entities/profile_user.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;
  final StorageRepo storageRepo;
  final Map<int, Map<String, dynamic>> _movieCache = {};

  ProfileCubit({required this.profileRepo, required this.storageRepo})
      : super(ProfileInitial());

  // Kullanıcı profilini çek (tek profil sayfası için)
  Future<void> fetchUserProfile(String uid) async {
    if (state is ProfileLoaded && (state as ProfileLoaded).profileUser.uid == uid) {
      return; // Zaten aynı kullanıcı yüklüyse tekrar çekme
    }

    emit(ProfileLoading());
    try {
      final user = await profileRepo.fetchUserProfile(uid);
      emit(user != null
          ? ProfileLoaded(user)
          : ProfileError("Kullanıcı bulunamadı"));
    } catch (e) {
      emit(ProfileError("Profil yüklenemedi: ${e.toString()}"));
    }
  }

  // Firestore yerine Supabase kullanıyorsan, burada ilgili tablodan çekme fonksiyonları repo içinde olmalı,
  // bu yüzden örnek olarak sadece repo fonksiyonlarını çağırıyorum.

  Future<List<String>> getTopThreeMovies(String userId) async {
    try {
      final movies = await profileRepo.getUserMovies(userId, 'top_three_movies');
      return movies;
    } catch (e) {
      print('Error getting top three movies: $e');
      return [];
    }
  }

  Future<List<String>> getMovieCollection(String userId, String collectionName) async {
    try {
      final movies = await profileRepo.getUserMovies(userId, collectionName);
      return movies;
    } catch (e) {
      print('Error getting $collectionName: $e');
      return [];
    }
  }

  // Kullanıcı profilini tekrar getirmek için
  Future<ProfileUser?> getUserProfile(String uid) async {
    try {
      final user = await profileRepo.fetchUserProfile(uid);
      return user;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  // Profili güncelle
  Future<void> updateProfile({
    required String uid,
    String? newBio,
    String? newBusiness,
    String? newName,
    String? newEmail,
    Uint8List? imageWebBytes,
    String? imageMobilePath,
  }) async {
    emit(ProfileLoading());
    try {
      final currentUser = await profileRepo.fetchUserProfile(uid);
      if (currentUser == null) {
        emit(ProfileError("Kullanıcı bilgisi yüklenemedi"));
        return;
      }

      String? imageDownloadUrl;
      if (imageWebBytes != null || imageMobilePath != null) {
        imageDownloadUrl = imageMobilePath != null
            ? await storageRepo.uploadProfileImageMobile(imageMobilePath, uid)
            : await storageRepo.uploadProfileImageWeb(imageWebBytes!, uid);

        if (imageDownloadUrl == null) {
          emit(ProfileError("Resim yüklenemedi"));
          return;
        }
      }

      final updatedProfile = currentUser.copyWith(
        newBio: newBio,
        newName: newName,
        newEmail: newEmail,
        newProfileImageUrl: imageDownloadUrl,
        newBusiness: newBusiness,
      );


      await profileRepo.updateProfile(updatedProfile);

      // Güncellenmiş profili emit et
      emit(ProfileLoaded(updatedProfile)); // <-- Direkt güncellenmiş kullanıcıyı gönder

    } catch (e) {
      emit(ProfileError("Profil güncelleme hatası: ${e.toString()}"));
    }
  }

  // Takip / Takipten çık işlemi
  Future<void> toggleFollow(String currentUserId, String targetUserId) async {
    try {
      // Takip/Unfollow işlemi
      await profileRepo.toggleFollow(currentUserId, targetUserId);

      // Cubit state'ini güncelle
      final currentState = state;
      if (currentState is ProfileLoaded) {
        final profileUser = currentState.profileUser;

        // followers listesini kopyala ve güncelle
        final updatedFollowers = List<String>.from(profileUser.followers);
        if (updatedFollowers.contains(currentUserId)) {
          updatedFollowers.remove(currentUserId);
        } else {
          updatedFollowers.add(currentUserId);
        }

        final updatedProfileUser = profileUser.copyWith(newFollowers: updatedFollowers);

        //emit(ProfileLoaded(profileUser: updatedProfileUser));
      }
    } catch (e) {
      emit(ProfileError("Hata oluştu: $e"));
    }
  }



  // Cache'den film detaylarını getir
  Map<String, dynamic>? getCachedMovie(int movieId) {
    return _movieCache[movieId];
  }

  // Film detaylarını getir (cache yoksa API'den çek)
  Future<Map<String, dynamic>> getMovieDetails(int movieId) async {
    if (_movieCache.containsKey(movieId)) {
      return _movieCache[movieId]!;
    }

    const apiKey = '7bd28d1b496b14987ce5a838d719c5c7';
    final url = Uri.parse('https://api.themoviedb.org/3/movie/$movieId?api_key=$apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _movieCache[movieId] = data;
        return data;
      } else {
        throw Exception('Film detayları yüklenemedi');
      }
    } catch (e) {
      throw Exception('Film çekme başarısız: $e');
    }
  }
}
