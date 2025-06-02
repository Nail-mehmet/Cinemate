
import '../../../movies/domain/entities/cast_member.dart';
import '../../../movies/domain/entities/movie.dart';
import '../../../profile/domain/entities/profile_user.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<ProfileUser?> users;
  final List<Movie> movies;
  final List<CastMember> actors; // Add this line


  SearchLoaded({required this.users, required this.movies, this.actors = const []});
}

class SearchError extends SearchState {
  final String message;

  SearchError(this.message);
}