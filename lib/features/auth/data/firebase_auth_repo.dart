import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:Cinemate/features/auth/domain/entities/app_user.dart';
import 'package:Cinemate/features/auth/domain/repos/auth_repo.dart';
import 'package:gotrue/gotrue.dart';
class SupabaseAuthRepo implements AuthRepo {
  final supabase = Supabase.instance.client;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '617938988547-63h1meb8o1qriecmau4ra2oc7ql2olmt.apps.googleusercontent.com',
  );


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
  Future<AppUser?> registerWithEmailPassword(String name, String email, String password) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) return null;

      await supabase.from('profiles').insert({
        'id': user.id,
        'email': email,
        'name': name,
        "bio": "adım kahtan",
        "business" ""
        'profile_image': '', // Varsayılan boş ya da placeholder URL
        'is_premium': false, // Başlangıçta false
        'created_at': DateTime.now().toIso8601String(),
      });

      return AppUser(
        uid: user.id,
        name: name,
        email: email,
          profileImageUrl: ""
      );
    } catch (e) {
      throw Exception("Kayıt Hatası: $e");
    }
  }

  @override
  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  Future<AppUser?> signInWithGoogle() async {
    try {
      // 1. Google ile oturum aç
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google sign in cancelled');

      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null) throw Exception('Google ID token is null');

      // 2. Supabase'e Google ile giriş yap
      final AuthResponse response = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      // 3. Kullanıcı bilgilerini kontrol et
      if (response.user == null) throw Exception('Supabase authentication failed');

      // 4. Profil bilgilerini al veya oluştur
      final userData = await supabase
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .maybeSingle();

      // Eğer profil yoksa oluştur
      if (userData == null) {
        await supabase.from('profiles').insert({
          'id': response.user!.id,
          'email': response.user!.email,
          'name': googleUser.displayName ?? 'Kullanıcı',
          'bio': '',
          'profile_image': googleUser.photoUrl ?? '',
          'is_premium': false,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // 5. AppUser döndür
      return AppUser(
        uid: response.user!.id,
        email: response.user!.email!,
        name: userData?['name'] ?? googleUser.displayName ?? 'Kullanıcı',
          profileImageUrl: ""
      );
    } catch (e) {
      print('Google ile giriş hatası: $e');
      rethrow;
    }
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