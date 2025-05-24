
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Cinemate/themes/font_theme.dart';
import '../components/movie_gird_item.dart';
import '../cubits/movie_cubit.dart';

class MovieHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MovieCubit, MovieState>(
        builder: (context, state) {
          if (state is MovieLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is MovieLoaded) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.count(
                crossAxisCount: 3, // 🟢 3 sütun
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.6,
                children: state.movies
                    .map((movie) => MovieGridItem(movie)) // 🟢 parametre adı eklendi
                    .toList(),
              ),
            );
          } else if (state is MovieError) {
            return Center(child: Text(state.message));
          }
          return Container();
        },
      ),
    );
  }
}