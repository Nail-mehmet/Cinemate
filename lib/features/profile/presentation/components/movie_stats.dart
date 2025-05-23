
import 'package:flutter/material.dart';

class MovieStats extends StatelessWidget {
  final int watchedCount;
  final int favoriteCount;
  final int savedCount;

  const MovieStats({
    super.key,
    required this.watchedCount,
    required this.favoriteCount,
    required this.savedCount,
  });

  @override
  Widget build(BuildContext context) {
    var textStyleForCount = TextStyle(
      fontSize: 20, 
      color: Theme.of(context).colorScheme.secondary
    );


    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Watched Movies
        SizedBox(
          width: 100,
          child: Column(
            children: [
              Text(watchedCount.toString(), style: textStyleForCount),
              Icon(Icons.visibility, color: Colors.blue,),
            ],
          ),
        ),
        
        // Favorite Movies
        SizedBox(
          width: 100,
          child: Column(
            children: [
              Text(favoriteCount.toString(), style: textStyleForCount),
              Icon(Icons.favorite, color: Colors.red,),
            ],
          ),
        ),
      
        // Saved Movies
        SizedBox(
          width: 100,
          child: Column(
            children: [
              Text(savedCount.toString(), style: textStyleForCount),
              Icon(Icons.playlist_add, color: Colors.green,),
            ],
          ),
        ),
      ],
    );
  }
}