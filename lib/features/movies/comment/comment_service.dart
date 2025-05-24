import 'package:supabase_flutter/supabase_flutter.dart';

import 'comment_model.dart';

class CommentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> addComment({
    required String movieId,
    required String commentText,
    required double rating,
    String? movieTitle,
    required bool spoiler,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception("User not authenticated");

      // 0. Eğer film movies tablosunda yoksa ekle
      final existingMovie = await _supabase
          .from('movies')
          .select()
          .eq('id', movieId)
          .maybeSingle();

      if (existingMovie == null && movieTitle != null) {
        await _supabase.from('movies').insert({
          'id': movieId,
          'title': movieTitle,
          'average_rating': 0.0, // Başlangıç değeri olarak 0.0
        });
      }

      // 1. Yorumu ekle
      await _supabase.from('comments').insert({
        'movie_id': movieId,
        'user_id': user.id,
        'comment': commentText,
        'rating': rating,
        'spoiler': spoiler,
        'movie_title': movieTitle,
      });

      // 2. Kullanıcı incelemesini güncelle (upsert)
      await _supabase.from('user_reviews').upsert({
        'movie_id': movieId,
        'user_id': user.id,
        'comment': commentText,
        'rating': rating,
        'spoiler': spoiler,
        'movie_title': movieTitle,
      }, onConflict: 'movie_id,user_id');

      // 3. Ortalama puanı güncelle
      await _updateMovieAverageRating(movieId);
    } catch (e) {
      throw Exception('Failed to add comment: ${e.toString()}');
    }
  }

  Future<void> _updateMovieAverageRating(String movieId) async {
    try {
      final response = await _supabase
          .from('comments')
          .select('rating')
          .eq('movie_id', movieId);

      final ratings = List<double>.from(
        response.map((item) => (item['rating'] as num).toDouble()),
      );

      final average = ratings.isNotEmpty
          ? ratings.reduce((a, b) => a + b) / ratings.length
          : 0.0;

      await _supabase
          .from('movies')
          .update({'average_rating': average})
          .eq('id', movieId);
    } catch (e) {
      throw Exception('Failed to update average rating: ${e.toString()}');
    }
  }





}
