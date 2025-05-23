
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/movie_detail_repository_impl.dart';
import 'movie_detail_state.dart';

//part 'movie_detail_state.dart';

class MovieDetailCubit extends Cubit<MovieDetailState> {
  final MovieDetailRepository repository;

  MovieDetailCubit(this.repository) : super(MovieDetailInitial());

  Future<void> fetchMovieDetail(int movieId) async {
    emit(MovieDetailLoading());
    try {
      final detail = await repository.getMovieDetail(movieId);
      emit(MovieDetailLoaded(detail));
    } catch (e) {
      emit(MovieDetailError("Hata: ${e.toString()}"));
    }
  }
}
