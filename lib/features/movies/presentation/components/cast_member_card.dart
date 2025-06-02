
import 'package:flutter/material.dart';

import '../../../actors/presentation/actor_details_screen.dart';
import '../../domain/entities/cast_member.dart';
class CastMemberCard extends StatelessWidget {
  final CastMember castMember;


  const CastMemberCard({
    Key? key,
    required this.castMember
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActorDetailsScreen(actorId: castMember.id),
          ),
        );
      },
      child: SizedBox(
        width: 70,
        height: 135, // yükseklik artırıldı
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 60,
                height: 90,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: castMember.profilePath.isNotEmpty
                        ? NetworkImage('https://image.tmdb.org/t/p/w200${castMember.profilePath}',
                    )
                        : const AssetImage('assets/fallback_image.jpg') as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 34, // daha fazla yer ayrıldı
              child: Text(
                castMember.name,
                style: const TextStyle(fontSize: 12, height: 1.2), // satır aralığı da dengelendi
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    );
  }
}