
import 'dart:convert';

import 'package:http/http.dart' as http;


import '../models/movie_detail_model.dart';

class MovieDetailRemoteDataSource {
  final http.Client client;
  final String apiKey;

  MovieDetailRemoteDataSource(this.client, this.apiKey);

  Future<MovieDetailModel> getMovieDetail(int movieId) async {
  final response = await client.get(
    Uri.parse('https://api.themoviedb.org/3/movie/$movieId?api_key=$apiKey&language=tr-US&append_to_response=credits,videos'),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return MovieDetailModel.fromJson(data);
  } else {
    throw Exception('Failed to load movie details');
  }
}

}
