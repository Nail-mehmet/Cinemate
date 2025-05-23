/*import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Cinemate/features/profile/domain/repos/profile_repo.dart';
import 'package:Cinemate/features/profile/presentation/cubits/profile_states.dart';
import 'package:Cinemate/features/storage/domain/storage_repo.dart';
import "package:http/http.dart" as http;
import '../../../notifications/domain/repositories/notification_repository.dart';
import '../../domain/entities/profile_user.dart';

class ProfileCubit extends Cubit<ProfileState>{
  final ProfileRepo profileRepo;
  final StorageRepo storageRepo;
  final Map<int, Map<String, dynamic>> _movieCache = {};

  ProfileCubit({required this.profileRepo, required this.storageRepo}) : super(ProfileInitial());

  // fetchc user profiel -> useful for loading single profile pages
  Future<void> fetchUserProfile(String uid)async{
    try{
      emit(ProfileLoading());
      final user = await profileRepo.fetchUserProfile(uid);
      if(user != null){
        emit(ProfileLoaded(user));
      }else {
        emit(ProfileError("böyle bir kullanıcı yok"));
      }
    }catch (e) {
      emit(ProfileError(e.toString()));
    }
  }


  Future<List<int>> getTopThreeMovies(String userId) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('topThreeMovies')
      .get();
      
  return snapshot.docs.map((doc) => doc.data()['movieId'] as int).toList();
}

Future<List<int>> getMovieCollection(String userId, String collectionName) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection(collectionName)
          .get();
      
      return snapshot.docs.map((doc) => doc.data()['movieId'] as int).toList();
    } catch (e) {
      print('Error getting $collectionName: $e');
      return [];
    }
  }

  // return user profile fiven uid -> useful for loading many profiles for posts
  Future<ProfileUser?> getUserProfile(String uid) async {
    final user = await profileRepo.fetchUserProfile(uid);
    return user;
  }

  // update bio
  Future<void> updateProfile({
    required String uid,
    String? newBio,
    String? newName,
    String? newEmail,
    Uint8List? imageWebBytes,
    String? imageMobilePath,
  })async{
    emit(ProfileLoading());
    try{
      // fetxh current porfile first
      final currentUser = await profileRepo.fetchUserProfile(uid);

      if(currentUser == null){
        emit(ProfileError("kullanıcı bilgisi yükelenemedi"));
        return;
      }


      // profiel pictue update
      String? imageDownloadUrl;

      if(imageWebBytes != null || imageMobilePath !=null){

        // for mobile
        if(imageMobilePath != null){
          imageDownloadUrl = await storageRepo.uploadProfileImageMobile(imageMobilePath, uid);
        }
        // for web
        else if(imageWebBytes != null){
          imageDownloadUrl = await storageRepo.uploadProfileImageWeb(imageWebBytes,uid);
        }

        if(imageDownloadUrl == null){
          emit(ProfileError("Resim yüklenemedi"));
          return;
        }
      }

      //update new profile

      final updatedProfile = currentUser.copyWith(
        newBio: newBio ?? currentUser.bio,
        newName: newName ?? currentUser.name,
        newEmail: newEmail ?? currentUser.email,
        newProfileImageUrl: imageDownloadUrl ?? currentUser.profileImageUrl,

       );

      // update in repo
      await profileRepo.updateProfile(updatedProfile);

      // re-fetch the updated profile
      await fetchUserProfile(uid);



    }catch(e){
      emit(ProfileError("profile hatasi : $e"));
    }
  }


  Future<void> toggleFollow (String currentUserId, String targetUserId) async{


    try{
      await profileRepo.toggleFollow(currentUserId, targetUserId);
    }catch (e) {
      emit(ProfileError("hata oluştu $e"));
    }
  }

  Map<String, dynamic>? getCachedMovie(int movieId) {
    return _movieCache[movieId];
  }

  // Film detaylarını getir (cache'de yoksa API'den yükle)
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
        _movieCache[movieId] = data; // Cache'e ekle
        return data;
      } else {
        throw Exception('Failed to load movie details');
      }
    } catch (e) {
      throw Exception('Failed to fetch movie: $e');
    }
  }
}*/