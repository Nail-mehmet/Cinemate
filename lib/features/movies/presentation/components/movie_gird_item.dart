import 'package:flutter/material.dart';

import '../../domain/entities/movie.dart';
import '../pages/movie_detail_page.dart';


class MovieGridItem extends StatelessWidget {
  final Movie movie;

  const MovieGridItem(this.movie, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Detay sayfasına git (movie'i gönderiyoruz)
        Navigator.push(
          context,  
          MaterialPageRoute(
            builder: (_) => MovieDetailPage(movieId: movie.id),
          ),
        );
      },
      child: Hero(
        tag: "poster-${movie.id}",
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8), // 🟢 oval köşe
          child: Image.network(
            'https://image.tmdb.org/t/p/w500${movie.posterPath}',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey[300],
              child: Icon(Icons.broken_image),
            ),
          ),
        ),
      ),
    );
  }
}