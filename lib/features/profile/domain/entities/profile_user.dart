import 'package:Cinemate/features/auth/domain/entities/app_user.dart';

class ProfileUser extends AppUser {
  final String? bio;
  final String? profileImageUrl;
  final List<String> followers;
  final List<String> following;
  final List<String> watchedMovies;
  final List<String> favoriteMovies;
  final List<String> savedlist;
  final List<String> topThreeMovies;

  ProfileUser({
    required super.uid,
    required super.email,
    required super.name,
    required this.bio,
    required this.profileImageUrl,
    required this.followers,
    required this.following,
    this.watchedMovies = const [],
    this.favoriteMovies = const [],
    this.savedlist = const [],
    this.topThreeMovies = const []
  });

  ProfileUser copyWith({
    String? newBio,
    String? newName,
    String? newEmail,
    String? newProfileImageUrl,
    List<String>? newFollowers,
    List<String>? newFollowing,
    List<String>? newWatchedMovies,
    List<String>? newFavoriteMovies,
    List<String>? newSavedlist,
    List<String>? newTopThreeMovies,
  }) {
    return ProfileUser(
      uid: uid,
      email: newEmail ?? email,
      name: newName ?? name,
      bio: newBio ?? bio,
      profileImageUrl: newProfileImageUrl ?? profileImageUrl,
      followers: newFollowers ?? followers,
      following: newFollowing ?? following,
      watchedMovies: newWatchedMovies ?? watchedMovies,
      favoriteMovies: newFavoriteMovies ?? favoriteMovies,
      savedlist: newSavedlist ?? savedlist,
      topThreeMovies: newTopThreeMovies ?? topThreeMovies
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "email": email,
      "name": name,
      "bio": bio,
      "profile_image": profileImageUrl,
      "followers": followers,
      "following": following,
      "watchedMovies": watchedMovies,
      "favoriteMovies": favoriteMovies,
      "savedlist": savedlist,
      "topThreeMovies" : topThreeMovies
    };
  }

  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    return ProfileUser(
      uid: json["uid"] ?? json["id"], // 👈 önemli düzeltme
      email: json["email"],
      name: json["name"],
      bio: json["bio"] ?? "",
      profileImageUrl: json["profile_image"] ?? "",
      followers: List<String>.from(json["followers"] ?? []),
      following: List<String>.from(json["following"] ?? []),
      watchedMovies: List<String>.from(json["watchedMovies"] ?? []),
      favoriteMovies: List<String>.from(json["favoriteMovies"] ?? []),
      savedlist: List<String>.from(json["savedlist"] ?? []),
      topThreeMovies: List<String>.from(json["topThreeMovies"] ?? []),
    );
  }

}