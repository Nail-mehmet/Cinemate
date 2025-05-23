
import '../../domain/entities/movie.dart';
import '../../domain/repos/movie_repository.dart';
import '../datasources/movie_remote_data_source.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource remoteDataSource;

  MovieRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Movie>> getPopularMovies() async {
    return await remoteDataSource.fetchPopularMovies();
  }  
}
