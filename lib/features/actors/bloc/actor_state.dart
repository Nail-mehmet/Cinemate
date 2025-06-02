part of 'actor_bloc.dart';

abstract class ActorState extends Equatable {
  const ActorState();

  @override
  List<Object> get props => [];
}

class ActorInitial extends ActorState {}

class ActorLoading extends ActorState {}

class ActorDetailsLoaded extends ActorState {
  final ActorDetails actorDetails;
  final List<Movie>? movies;
  final bool isLoadingMovies;
  final String? errorMessage;

  const ActorDetailsLoaded({
    required this.actorDetails,
    this.movies,
    this.isLoadingMovies = false,
    this.errorMessage,
  });

  @override
  List<Object> get props => [
    actorDetails,
    movies ?? [],
    isLoadingMovies,
    errorMessage ?? '',
  ];
}

class ActorError extends ActorState {
  final String message;

  const ActorError({required this.message});

  @override
  List<Object> get props => [message];
}