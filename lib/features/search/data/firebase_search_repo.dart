
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Cinemate/features/movies/domain/entities/movie.dart';
import 'package:Cinemate/features/profile/domain/entities/profile_user.dart';
import 'package:Cinemate/features/search/domain/search_repo.dart';
import 'package:http/http.dart' as http;
class FirebaseSearchRepo implements SearchRepo {
  final String _apiKey = '7bd28d1b496b14987ce5a838d719c5c7'; // 🔑 Buraya kendi TMDB API anahtarını yaz

  @override
  Future<List<ProfileUser?>> searchUser(String query) async {
    try {
      final result = await FirebaseFirestore.instance
          .collection("users")
          .where("name", isGreaterThanOrEqualTo: query)
          .where("name", isLessThanOrEqualTo: "$query\uf8ff")
          .get();

      return result.docs
          .map((doc) => ProfileUser.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception("Error $e");
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