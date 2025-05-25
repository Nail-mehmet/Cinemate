import 'dart:io';
import 'package:Cinemate/features/communities/domain/entities/community_post_model.dart';

abstract class CommuneEvent {
  const CommuneEvent();
}

class LoadCommunes extends CommuneEvent {
  final String communityId;
  final int limit;
  final Commune? lastFetched;

  const LoadCommunes({
    required this.communityId,
    required this.limit,
    this.lastFetched,
  });
}

class CreateCommune extends CommuneEvent {
  final String communityId;
  final Commune commune;
  final File? image;

  const CreateCommune({
    required this.communityId,
    required this.commune,
    this.image,
  });
}