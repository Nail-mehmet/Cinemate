// movie_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MovieCard extends StatefulWidget {
  final String movieId;
  final String? movieTitle;
  final double? voteAverage;
  final VoidCallback? onTap;

  const MovieCard({
    super.key,
    required this.movieId,
    this.movieTitle,
    this.voteAverage,
    this.onTap,
  });

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  String? _posterPath;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchPosterPath();
  }

  Future<void> _fetchPosterPath() async {
    try {
      if (!mounted) return;
      final response = await http.get(
        Uri.parse('https://api.themoviedb.org/3/movie/${widget.movieId}?api_key=7bd28d1b496b14987ce5a838d719c5c7'),
      ).timeout(const Duration(seconds: 10));
      if (!mounted) return;
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if(mounted){
          setState(() {
          _posterPath = data['poster_path'];
          _isLoading = false;
        });
        }
      } else {
        if(mounted){
          setState(() {
          _hasError = true;
          _isLoading = false;
        });
        }
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      debugPrint('Movie poster fetch error: $e');
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 100, // Daha küçük boyut
        height: 150,
        margin: const EdgeInsets.only(right: 12, bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _hasError
                ? const Center(child: Icon(Icons.movie))
                : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: "https://image.tmdb.org/t/p/w200$_posterPath",
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.movie),
                    ),
                  ),
      ),
    );
  }
}