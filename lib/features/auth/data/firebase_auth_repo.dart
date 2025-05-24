import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:Cinemate/features/auth/domain/entities/app_user.dart';
import 'package:Cinemate/features/auth/domain/repos/auth_repo.dart';

class SupabaseAuthRepo implements AuthRepo {
  final supabase = Supabase.instance.client;

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
        'profile_image': '', // Varsayılan boş ya da placeholder URL
        'is_premium': false, // Başlangıçta false
        'created_at': DateTime.now().toIso8601String(),
      });

      return AppUser(
        uid: user.id,
        name: name,
        email: email,
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
    );
  }
}
