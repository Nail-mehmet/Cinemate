import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Cinemate/features/movies/domain/entities/movie.dart';
import 'package:Cinemate/features/profile/domain/entities/profile_user.dart';
import 'package:Cinemate/features/search/domain/search_repo.dart';
import 'package:Cinemate/features/search/presentation/cubits/search_states.dart';

import '../../../movies/domain/entities/cast_member.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchRepo searchRepo;

  SearchCubit({required this.searchRepo}) : super(SearchInitial());

  Future<void> search(String query, {String searchType = 'all'}) async {
    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    try {
      emit(SearchLoading());

      List<ProfileUser?> users = [];
      List<Movie> movies = [];
      List<CastMember> actors = [];

      if (searchType == 'all' || searchType == 'users') {
        users = await searchRepo.searchUser(query);
      }

      if (searchType == 'all' || searchType == 'movies') {
        movies = await searchRepo.searchMovie(query);
      }

      if (searchType == 'all' || searchType == 'actors') {
        actors = await searchRepo.searchActor(query);
      }

      emit(SearchLoaded(users: users, movies: movies, actors: actors));
    } catch (e) {
      emit(SearchError("Arama işlemi sırasında bir hata oluştu"));
    }
  }

  Future<void> searchByGenre(String genreName) async {
    try {
      emit(SearchLoading());
      
      // Find the genre ID from the name
      final genreId = _getGenreIdByName(genreName);
      
      if (genreId == null) {
        emit(SearchError("Geçersiz film türü"));
        return;
      }
      
      // Get movies by genre ID
      final movies = await searchRepo.searchMovieByGenre(genreId);
      
      emit(SearchLoaded(users: [], movies: movies));
    } catch (e) {
      emit(SearchError("Film türüne göre arama sırasında bir hata oluştu"));
    }
  }



  // Helper method to get genre ID by name
  int? _getGenreIdByName(String name) {
    final genres = {
      'Aksiyon': 28,
      'Macera': 12,
      'Animasyon': 16,
      'Komedi': 35,
      'Suç': 80,
      'Drama': 18,
      'Aile': 10751,
      'Fantastik': 14,
      'Tarih': 36,
      'Korku': 27,
      'Müzik': 10402,
      'Gizem': 9648,
      'Romantik': 10749,
      'Bilim Kurgu': 878,
      'Gerilim': 53,
      'Savaş': 10752,
      'Western': 37,
    };
    
    return genres[name];
  }
}