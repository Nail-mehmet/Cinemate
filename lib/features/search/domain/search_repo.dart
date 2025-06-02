

import '../../movies/domain/entities/cast_member.dart';
import '../../movies/domain/entities/movie.dart';
import '../../profile/domain/entities/profile_user.dart';

abstract class SearchRepo {
  Future<List<ProfileUser?>> searchUser(String query);
  Future<List<Movie>> searchMovie(String query);
  Future<List<Movie>> searchMovieByGenre(int genreId);
  Future<List<CastMember>> searchActor(String query); // Add this line
}