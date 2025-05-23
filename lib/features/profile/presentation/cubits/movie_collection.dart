/*import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../movies/presentation/pages/movie_detail_page.dart';
class MovieCollectionSection extends StatelessWidget {
  final String title;
  final List<int> movieIds;
  final VoidCallback onSeeAllPressed;
  final bool isCompact;

  const MovieCollectionSection({
    super.key,
    required this.title,
    required this.movieIds,
    required this.onSeeAllPressed,
    this.isCompact = true,
  });

  @override
  Widget build(BuildContext context) {
    if (movieIds.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              TextButton(
                onPressed: onSeeAllPressed,
                child: Text(
                  'Tümünü Gör',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: isCompact ? 150 : null,
          child: isCompact
              ? _buildHorizontalMovieList(context, movieIds.take(5).toList())
              : _buildGridMovieList(context, movieIds),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildHorizontalMovieList(BuildContext context, List<int> movieIds) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: movieIds.length,
      itemBuilder: (context, index) {
        return FutureBuilder<String?>(
          future: _fetchMoviePosterPath(movieIds[index]),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return _buildMovieItemPlaceholder();
            }
            return _buildMovieItem(
              context,
              movieIds[index],
              snapshot.data,
              itemWidth: 100,
              itemHeight: 150,
            );
          },
        );
      },
    );
  }

  Widget _buildGridMovieList(BuildContext context, List<int> movieIds) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: movieIds.length,
      itemBuilder: (context, index) {
        return FutureBuilder<String?>(
          future: _fetchMoviePosterPath(movieIds[index]),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return _buildMovieItemPlaceholder();
            }
            return _buildMovieItem(
              context,
              movieIds[index],
              snapshot.data,
              itemWidth: double.infinity,
              itemHeight: double.infinity,
            );
          },
        );
      },
    );
  }

  Widget _buildMovieItem(
    BuildContext context,
    int movieId,
    String? posterPath, {
    required double itemWidth,
    required double itemHeight,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MovieDetailPage(movieId: movieId),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: itemWidth,
            height: itemHeight,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: posterPath != null && posterPath.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: 'https://image.tmdb.org/t/p/w500$posterPath',
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        _buildMovieItemPlaceholder(),
                    errorWidget: (context, url, error) =>
                        _buildMovieItemError(),
                  )
                : _buildMovieItemError(),
          ),
        ),
      ),
    );
  }

  Widget _buildMovieItemPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildMovieItemError() {
    return Container(
      color: Colors.grey[300],
      child: const Center(child: Icon(Icons.broken_image)),
    );
  }

  Future<String?> _fetchMoviePosterPath(int movieId) async {
    const apiKey = '7bd28d1b496b14987ce5a838d719c5c7'; // Buraya kendi TMDB API key'ini koy
    final dio = Dio();

    try {
      final response = await dio.get(
        'https://api.themoviedb.org/3/movie/$movieId',
        queryParameters: {'api_key': apiKey},
      );

      if (response.statusCode == 200) {
        return response.data['poster_path'] as String?;
      }
      return null;
    } catch (e) {
      print('Error fetching movie poster: $e');
      return null;
    }
  }
}
*/