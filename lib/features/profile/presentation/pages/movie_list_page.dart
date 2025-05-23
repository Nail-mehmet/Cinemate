/*import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../movies/presentation/pages/movie_detail_page.dart';
class MovieListPage extends StatelessWidget {
  final String title;
  final List<int> movieIds;

  const MovieListPage({
    Key? key,
    required this.title,
    required this.movieIds,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.7,
        ),
        itemCount: movieIds.length,
        itemBuilder: (context, index) {
          final movieId = movieIds[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieDetailPage(movieId: movieId),
                ),
              );
            },
            child: FutureBuilder<String>(
              future: _getPosterPath(movieId),
              builder: (context, snapshot) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: snapshot.hasData
                      ? CachedNetworkImage(
                          imageUrl: 'https://image.tmdb.org/t/p/w500${snapshot.data}',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                          ),
                          errorWidget: (context, url, error) => 
                            Icon(Icons.movie, color: Colors.grey),
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: Center(child: CircularProgressIndicator()),
                        ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<String> _getPosterPath(int movieId) async {
    // Same implementation as in the profile page
    try {
      // Your TMDB API call here
      return '/placeholder.jpg'; // Replace with actual path
    } catch (e) {
      return '';
    }
  }
}*/