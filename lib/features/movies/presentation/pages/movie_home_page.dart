
import 'package:Cinemate/features/movies/presentation/components/quote_card.dart';
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
            return ListView(
              padding: const EdgeInsets.all(8.0),
              children: [
                QuoteCard(),
                GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.6,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(), // 👈 Scroll çatışmasını önler
                  children: state.movies
                      .map((movie) => MovieGridItem(movie))
                      .toList(),
                ),
              ],
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
