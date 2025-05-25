import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Cinemate/features/communities/domain/repository/community_repository.dart';
import 'package:Cinemate/features/communities/presentation/cubits/commune_event.dart';
import 'package:Cinemate/features/communities/presentation/cubits/commune_state.dart';

class CommuneBloc extends Bloc<CommuneEvent, CommuneState> {
  final CommuneRepository repository;
  static const int _postsPerPage = 10;

  CommuneBloc(this.repository) : super(CommuneInitial()) {
    on<LoadCommunes>(_onLoadCommunes);
    on<CreateCommune>(_onCreateCommune);
  }

  Future<void> _onLoadCommunes(
      LoadCommunes event,
      Emitter<CommuneState> emit,
      ) async {
    try {
      if (event.lastFetched != null && state is CommuneLoaded) {
        emit((state as CommuneLoaded).copyWith(isLoadingMore: true));
      } else {
        emit(CommuneLoading());
      }

      final communes = await repository.fetchCommunes(
        communityId: event.communityId,
        limit: event.limit,
        lastFetched: event.lastFetched,
      );

      if (event.lastFetched != null && state is CommuneLoaded) {
        final currentState = state as CommuneLoaded;
        final allCommunes = [...currentState.communes, ...communes];
        emit(currentState.copyWith(
          communes: allCommunes,
          isLoadingMore: false,
          hasMore: communes.length >= event.limit,
        ));
      } else {
        emit(CommuneLoaded(
          communes,
          isLoadingMore: false,
          hasMore: communes.length >= event.limit,
        ));
      }
    } catch (e) {
      emit(CommuneError('Failed to load posts: $e'));
    }
  }

  Future<void> _onCreateCommune(
      CreateCommune event,
      Emitter<CommuneState> emit,
      ) async {
    try {
      await repository.createCommune(
        communityId: event.communityId,
        commune: event.commune,
        image: event.image,
      );
      add(LoadCommunes(
        communityId: event.communityId,
        limit: _postsPerPage,
      ));
    } catch (e) {
      emit(CommuneError('Failed to create post: $e'));
    }
  }
}