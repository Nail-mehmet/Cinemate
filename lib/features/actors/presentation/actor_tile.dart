import 'package:Cinemate/themes/font_theme.dart';
import 'package:flutter/material.dart';

import '../../movies/domain/entities/cast_member.dart';
import 'actor_details_screen.dart';

class ActorTile extends StatelessWidget {
  final CastMember actor;
  final double? posterWidth;
  final double? posterHeight;

  const ActorTile({
    super.key,
    required this.actor,
    this.posterWidth = 50,
    this.posterHeight = 180,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: actor.profilePath.isNotEmpty
            ? ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            'https://image.tmdb.org/t/p/w200${actor.profilePath}',
            width: posterWidth,
            height: posterHeight,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: posterWidth,
              height: posterHeight,
              color: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.person),
            ),
          ),
        )
            : Container(
          width: posterWidth,
          height: posterHeight,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.person,color: Colors.white70,),
        ),
        title: Text(actor.name,style: AppTextStyles.medium,),
        //subtitle: actor.character != null ? Text(actor.character!) : null,
        onTap: () {
          // Navigate to actor details page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ActorDetailsScreen(actorId: actor.id),
            ),
          );
        },
      ),
    );
  }
}