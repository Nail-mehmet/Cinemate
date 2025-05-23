
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie_model.dart';

class MovieRemoteDataSource {
  final http.Client client;
  final String apiKey;

  MovieRemoteDataSource(this.client, this.apiKey);

  Future<List<MovieModel>> fetchPopularMovies() async {
    final response = await client.get(Uri.parse(
        'https://api.themoviedb.org/3/movie/popular?api_key=$apiKey&language=en-US&page=1'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<MovieModel>.from(
        data['results'].map((movie) => MovieModel.fromJson(movie)),
      );
    } else {
      throw Exception('Failed to load movies');
    }
  }
  
}