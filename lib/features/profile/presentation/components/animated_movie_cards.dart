import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AnimatedMovieCards extends StatefulWidget {
  final String userId;

  const AnimatedMovieCards({required this.userId});

  @override
  _AnimatedMovieCardsState createState() => _AnimatedMovieCardsState();
}

class _AnimatedMovieCardsState extends State<AnimatedMovieCards> {
  bool isOpened = false;
  List<String> posterUrls = [];

  @override
  void initState() {
    super.initState();
    fetchMoviePosters();
  }

  Future<void> fetchMoviePosters() async {
    final moviesSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('topThreeMovies')
        .get();

    final movieIds = moviesSnapshot.docs.map((doc) => doc['movieId'].toString()).toList();

    final List<String> urls = [];

    for (String movieId in movieIds) {
      final response = await http.get(Uri.parse('https://api.themoviedb.org/3/movie/$movieId?api_key=7bd28d1b496b14987ce5a838d719c5c7'));
      final data = json.decode(response.body);
      final posterPath = data['poster_path'];
      urls.add('https://image.tmdb.org/t/p/w500$posterPath');
    }

    setState(() {
      posterUrls = urls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => isOpened = !isOpened),
      child: SizedBox(
        width: 300,
        height: 200,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: List.generate(posterUrls.length, (index) {
            double closedAngle = [-0.3, 0.0, 0.3][index];
            double openedOffsetX = [-100, 0, 100][index].toDouble();
            return buildAnimatedCard(
              imageUrl: posterUrls[index],
              closedAngle: closedAngle,
              openedOffsetX: openedOffsetX,
            );
          }),
        ),
      ),
    );
  }

  Widget buildAnimatedCard({
    required String imageUrl,
    required double closedAngle,
    required double openedOffsetX,
  }) {
    return AnimatedAlign(
      duration: Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      alignment: Alignment.bottomCenter,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        transformAlignment: Alignment.bottomCenter,
        transform: Matrix4.identity()
          ..translate(isOpened ? openedOffsetX : 0.0, isOpened ? -40.0 : 0.0)
          ..rotateZ(isOpened ? 0.0 : closedAngle),
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: 100,
              height: 160,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
