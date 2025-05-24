import 'package:flutter/material.dart';
import 'package:Cinemate/themes/font_theme.dart';
import '../domain/entities/movie.dart';
import '../presentation/pages/movie_detail_page.dart';

class MovieTile extends StatelessWidget {
  final Movie movie;
  final VoidCallback? onTap;
  final bool isSelected;
  final double posterWidth;
  final double posterHeight;
  final bool bigTile;

  const MovieTile({
    super.key, 
    required this.movie, 
    this.onTap, 
    this.isSelected = false,
    this.posterWidth = 100,
    this.posterHeight = 150,
    this.bigTile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap ?? () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MovieDetailPage(movieId: movie.id),
              ),
            );
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster kısmı
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  'https://image.tmdb.org/t/p/w500${movie.posterPath ?? ''}',
                  width: posterWidth,
                  height: posterHeight,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: posterWidth,
                    height: posterHeight,
                    color: Colors.grey[300],
                    child: Icon(Icons.movie, size: posterWidth * 0.5),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Film bilgileri
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        style: AppTextStyles.medium.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (movie.releaseDate != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Yıl: ${movie.releaseDate!.split('-')[0]}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      if (bigTile && movie.genres.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: movie.genres.map((genre) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6.0),
                                  child: Chip(
                                    label: Text(
                                      genre,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).colorScheme.secondary,
                                      ),
                                    ),
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.1),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}