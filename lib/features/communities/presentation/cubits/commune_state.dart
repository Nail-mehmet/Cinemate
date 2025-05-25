import 'package:Cinemate/features/communities/domain/entities/community_post_model.dart';

abstract class CommuneState {
  const CommuneState();
}

class CommuneInitial extends CommuneState {}

class CommuneLoading extends CommuneState {
  final List<Commune> communes;

  const CommuneLoading({this.communes = const []});
}

class CommuneLoaded extends CommuneState {
  final List<Commune> communes;
  final bool isLoadingMore;
  final bool hasMore;

  const CommuneLoaded(
      this.communes, {
        this.isLoadingMore = false,
        this.hasMore = true,
      });

  CommuneLoaded copyWith({
    List<Commune>? communes,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return CommuneLoaded(
      communes ?? this.communes,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class CommuneError extends CommuneState {
  final String message;

  const CommuneError(this.message);
}