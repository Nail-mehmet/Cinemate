
import 'package:Cinemate/features/movies/domain/repos/movie_repository.dart';

import '../entities/movie.dart';


class GetMovies {
  final MovieRepository repository;

  GetMovies(this.repository);

  Future<List<Movie>> call() async {
    return await repository.getPopularMovies();
  }
}
