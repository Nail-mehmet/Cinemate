import 'package:Cinemate/features/auth/domain/entities/app_user.dart';

class ProfileUser extends AppUser {
  final String? bio;
  final String? business;
  //final String? profileImageUrl;
  final List<String> followers;
  final List<String> following;
  final List<String> watchedMovies;
  final List<String> favoriteMovies;
  final List<String> savedlist;
  final List<String> topThreeMovies;
  final bool isPremium;

  ProfileUser({
    required super.uid,
    required super.email,
    required super.name,
    required this.bio,
    required this.business,
    required super.profileImageUrl,
    required this.followers,
    required this.following,
    this.watchedMovies = const [],
    this.favoriteMovies = const [],
    this.savedlist = const [],
    this.topThreeMovies = const [],
    this.isPremium = false,

  });

  ProfileUser copyWith({
    String? newBio,
    String? newBusiness,
    String? newName,
    String? newEmail,
    String? newProfileImageUrl,
    List<String>? newFollowers,
    List<String>? newFollowing,
    List<String>? newWatchedMovies,
    List<String>? newFavoriteMovies,
    List<String>? newSavedlist,
    List<String>? newTopThreeMovies,
    bool? newIsPremium,
  }) {
    return ProfileUser(
      uid: uid,
      email: newEmail ?? email,
      name: newName ?? name,
      bio: newBio ?? bio,
      business: newBusiness ?? business,
      profileImageUrl: newProfileImageUrl ?? profileImageUrl,
      followers: newFollowers ?? followers,
      following: newFollowing ?? following,
      watchedMovies: newWatchedMovies ?? watchedMovies,
      favoriteMovies: newFavoriteMovies ?? favoriteMovies,
      savedlist: newSavedlist ?? savedlist,
      topThreeMovies: newTopThreeMovies ?? topThreeMovies,
      isPremium: newIsPremium ?? isPremium,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "email": email,
      "name": name,
      "bio": bio,
      "business": business,
      "profile_image": profileImageUrl,
      "followers": followers,
      "following": following,
      "watchedMovies": watchedMovies,
      "favoriteMovies": favoriteMovies,
      "savedlist": savedlist,
      "topThreeMovies": topThreeMovies,
      "is_premium": isPremium,
    };
  }

  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    return ProfileUser(
      uid: json["uid"] ?? json["id"],
      email: json["email"],
      name: json["name"],
      bio: json["bio"] ?? "",
      business: json["business"] ?? "",
      profileImageUrl: json["profile_image"] ?? "",
      followers: List<String>.from(json["followers"] ?? []),
      following: List<String>.from(json["following"] ?? []),
      watchedMovies: List<String>.from(json["watchedMovies"] ?? []),
      favoriteMovies: List<String>.from(json["favoriteMovies"] ?? []),
      savedlist: List<String>.from(json["savedlist"] ?? []),
      topThreeMovies: List<String>.from(json["topThreeMovies"] ?? []),
      isPremium: json["is_premium"] ?? false,
    );
  }
}