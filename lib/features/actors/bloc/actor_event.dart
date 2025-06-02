part of 'actor_bloc.dart';

abstract class ActorEvent extends Equatable {
  const ActorEvent();

  @override
  List<Object> get props => [];
}

class LoadActorDetails extends ActorEvent {
  final int actorId;

  const LoadActorDetails(this.actorId);

  @override
  List<Object> get props => [actorId];
}

class LoadActorMovies extends ActorEvent {
  final int actorId;

  const LoadActorMovies(this.actorId);

  @override
  List<Object> get props => [actorId];
}