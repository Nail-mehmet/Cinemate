
class AppUser {
  final String uid;
  final String email;
  final String name;
  final String profileImageUrl;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.profileImageUrl
  });


  Map<String, dynamic> toJson() {
    return{
      "uid": uid,
      "email": email,
      "name": name,
      "profile_image": profileImageUrl
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> jsonUser) {
    return AppUser(
      uid: jsonUser["uid"],
      email: jsonUser["eimal"],
      name: jsonUser["name"],
        profileImageUrl: jsonUser["profile_image"]
    );
  }

}