

import 'package:Cinemate/features/movies/domain/entities/movie_detail.dart';

import '../datasources/movie_detail_remote_data_source.dart';

abstract class MovieDetailRepository {
  Future<MovieDetail> getMovieDetail(int movieId);
}

class MovieDetailRepositoryImpl implements MovieDetailRepository {
  final MovieDetailRemoteDataSource remoteDataSource;

  MovieDetailRepositoryImpl(this.remoteDataSource);

  @override
  Future<MovieDetail> getMovieDetail(int movieId) {
    return remoteDataSource.getMovieDetail(movieId);
  }
}
