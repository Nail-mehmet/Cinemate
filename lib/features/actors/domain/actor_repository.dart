
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../movies/domain/entities/movie.dart';
import 'actor_details_entity.dart';

class ActorRepository {
  final String apiKey = '7bd28d1b496b14987ce5a838d719c5c7';
  final String baseUrl = 'https://api.themoviedb.org/3';

  Future<ActorDetails> getActorDetails(int actorId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/person/$actorId?api_key=$apiKey&language=tr-TR'),
    );

    if (response.statusCode == 200) {
      return ActorDetails.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load actor details');
    }
  }

  Future<List<Movie>> getActorMovies(int actorId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/person/$actorId/movie_credits?api_key=$apiKey&language=tr-TR'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Movie>.from(data['cast'].map((x) => Movie.fromJson(x)));
    } else {
      throw Exception('Failed to load actor movies');
    }
  }
}