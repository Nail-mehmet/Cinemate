import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../movies/domain/entities/movie.dart';
import '../domain/actor_details_entity.dart';
import '../domain/actor_repository.dart';


part 'actor_event.dart';
part 'actor_state.dart';

class ActorBloc extends Bloc<ActorEvent, ActorState> {
  final ActorRepository actorRepository;

  ActorBloc({required this.actorRepository}) : super(ActorInitial()) {
    on<LoadActorDetails>(_onLoadActorDetails);
    on<LoadActorMovies>(_onLoadActorMovies);
  }

  Future<void> _onLoadActorDetails(
      LoadActorDetails event,
      Emitter<ActorState> emit,
      ) async {
    emit(ActorLoading());
    try {
      final actorDetails = await actorRepository.getActorDetails(event.actorId);
      emit(ActorDetailsLoaded(actorDetails: actorDetails));
    } catch (e) {
      emit(ActorError(message: e.toString()));
    }
  }

  Future<void> _onLoadActorMovies(
      LoadActorMovies event,
      Emitter<ActorState> emit,
      ) async {
    if (state is ActorDetailsLoaded) {
      final currentState = state as ActorDetailsLoaded;
      emit(ActorDetailsLoaded(
        actorDetails: currentState.actorDetails,
        isLoadingMovies: true,
      ));

      try {
        final movies = await actorRepository.getActorMovies(event.actorId);
        emit(ActorDetailsLoaded(
          actorDetails: currentState.actorDetails,
          movies: movies,
        ));
      } catch (e) {
        emit(ActorDetailsLoaded(
          actorDetails: currentState.actorDetails,
          errorMessage: e.toString(),
        ));
      }
    }
  }
}