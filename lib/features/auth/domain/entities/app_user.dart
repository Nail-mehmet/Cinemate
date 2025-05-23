
class AppUser {
  final String uid;
  final String email;
  final String name;

  AppUser({
    required this.uid,
    required this.name,
    required this.email
  });


  Map<String, dynamic> toJson() {
    return{
      "uid": uid,
      "email": email,
      "name": name,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> jsonUser) {
    return AppUser(
      uid: jsonUser["uid"],
      email: jsonUser["eimal"],
      name: jsonUser["name"]
    );
  }

  


}