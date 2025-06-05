import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:Cinemate/features/auth/domain/entities/app_user.dart';
import 'package:Cinemate/features/auth/domain/repos/auth_repo.dart';
import 'package:gotrue/gotrue.dart';
class SupabaseAuthRepo implements AuthRepo {
  final supabase = Supabase.instance.client;
 /* final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '617938988547-63h1meb8o1qriecmau4ra2oc7ql2olmt.apps.googleusercontent.com',
  );*/


  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) return null;

      final userData = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return AppUser(
        uid: user.id,
        email: user.email!,
        name: userData['name'],
        profileImageUrl: userData['profile_image'],
      );
    } catch (e) {
      throw Exception("Hatalı Giriş: $e");
    }
  }

  @override
  @override
  Future<AppUser?> registerWithEmailPassword(String name, String email, String password) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) return null;

      // FCM token'ı al
      final fcmToken = await FirebaseMessaging.instance.getToken();

      // Supabase'e kayıt
      await supabase.from('profiles').insert({
        'id': user.id,
        'email': email,
        'name': name,
        'bio': 'adım kahtan',
        'business': '',
        'profile_image': '',
        'is_premium': false,
        'fcm_token': fcmToken, // ← BU SATIRI EKLEDİK
        'created_at': DateTime.now().toIso8601String(),
      });

      return AppUser(
        uid: user.id,
        name: name,
        email: email,
        profileImageUrl: '',
      );
    } catch (e) {
      throw Exception("Kayıt Hatası: $e");
    }
  }


  @override
  Future<void> logout() async {
    await supabase.auth.signOut();
  }


  @override
  Future<AppUser?> getCurrentUser() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final userData = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    return AppUser(
      uid: user.id,
      email: user.email!,
      name: userData['name'],
        profileImageUrl: userData["profile_image"]
    );
  }
}