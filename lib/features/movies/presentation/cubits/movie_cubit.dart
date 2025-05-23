
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Cinemate/features/movies/domain/repos/movie_repository.dart';

import '../../domain/entities/movie.dart';

part 'movie_state.dart';

class MovieCubit extends Cubit<MovieState> {
  final MovieRepository movieRepo;

  MovieCubit({required this.movieRepo}) : super(MovieInitial());

  void fetchMovies() async {
    try {
      emit(MovieLoading());
      final movies = await movieRepo.getPopularMovies();
      emit(MovieLoaded(movies));
    } catch (e) {
      emit(MovieError(e.toString()));
    }
  }
}
  