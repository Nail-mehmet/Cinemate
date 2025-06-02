
import 'dart:convert';

import 'package:Cinemate/features/movies/domain/entities/movie.dart';
import 'package:Cinemate/features/profile/domain/entities/profile_user.dart';
import 'package:Cinemate/features/search/domain/search_repo.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../movies/domain/entities/cast_member.dart';
class FirebaseSearchRepo implements SearchRepo {
  final String _apiKey = '7bd28d1b496b14987ce5a838d719c5c7'; // 🔑 Buraya kendi TMDB API anahtarını yaz
  final supabase = Supabase.instance.client;

  @override
  Future<List<ProfileUser>> searchUser(String query) async {
    try {
      final response = await supabase.from('profiles').select().ilike('name', '$query%');
      print('Raw response: $response');

// Her kullanıcı için detaylı log
      for (var user in response) {
        print('User data: $user');
        print('Bio is null? ${user['bio'] == null}');
        print('Profile image is null? ${user['profile_image'] == null}');
        print('Full user JSON: ${jsonEncode(response)}');

      }
      return (response as List)
          .map((json) => ProfileUser.fromJson(json))
          .toList();
    } catch (e) {
      print('Supabase error details: $e'); // Detaylı hatayı logla
      throw Exception('Error fetching users: ${e.toString()}');
    }
  }


  @override
  Future<List<Movie>> searchMovie(String query) async {
    try {
      final url = Uri.parse(
        'https://api.themoviedb.org/3/search/movie?api_key=$_apiKey&query=$query&language=tr-TR',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];

        return results
            .map((json) => Movie.fromJson(json))
            .toList();
      } else {
        throw Exception("TMDB Hata: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Film arama hatası: $e");
    }
  }

  @override
  Future<List<CastMember>> searchActor(String query) async {
    try {
      final url = Uri.parse(
        'https://api.themoviedb.org/3/search/person?api_key=$_apiKey&query=$query&language=tr-TR',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];

        return results
            .map((json) => CastMember(
          id: json['id'],
          name: json['name'],
          profilePath: json['profile_path'] ?? '',
          //popularity: json['popularity']?.toDouble() ?? 0.0,
        ))
            .toList();
      } else {
        throw Exception("TMDB Actor Search Error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Actor search error: $e");
    }
  }
  Future<List<Movie>> searchMovieByGenre(int genreId) async {
    final response = await http.get(
      Uri.parse(
        'https://api.themoviedb.org/3/discover/movie?api_key=$_apiKey&with_genres=$genreId&language=tr-TR'
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List).map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load movies by genre');
    }
  }
}