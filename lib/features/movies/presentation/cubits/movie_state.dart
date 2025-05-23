
part of 'movie_cubit.dart';

abstract class MovieState {}

class MovieInitial extends MovieState {}
class MovieLoading extends MovieState {}
class MovieLoaded extends MovieState {
  final List<Movie> movies;
  MovieLoaded(this.movies): assert(movies.every((m) => m.posterPath != null));
}
class MovieError extends MovieState {
  final String message;
  MovieError(this.message);
}