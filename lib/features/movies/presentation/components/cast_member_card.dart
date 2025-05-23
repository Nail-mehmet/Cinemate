import 'package:flutter/material.dart';
class CastMemberCard extends StatelessWidget {
  final String name;
  final String profilePath;

  const CastMemberCard({
    Key? key,
    required this.name,
    required this.profilePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
                  image: profilePath.isNotEmpty
                      ? NetworkImage('https://image.tmdb.org/t/p/w200$profilePath')
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
              name,
              style: const TextStyle(fontSize: 12, height: 1.2), // satır aralığı da dengelendi
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}
