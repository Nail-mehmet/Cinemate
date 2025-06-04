import 'package:Cinemate/features/movies/presentation/components/expandable_text.dart';
import 'package:Cinemate/themes/font_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../movies/domain/entities/movie.dart';
import '../../movies/search/movie_tile.dart';
import '../bloc/actor_bloc.dart';
import '../domain/actor_details_entity.dart';
import '../domain/actor_repository.dart';

class ActorDetailsScreen extends StatelessWidget {
  final int actorId;

  const ActorDetailsScreen({Key? key, required this.actorId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ActorBloc(
        actorRepository: context.read<ActorRepository>(),
      )..add(LoadActorDetails(actorId)),
      child: Scaffold(
      appBar: AppBar(
      title: BlocBuilder<ActorBloc, ActorState>(
    builder: (context, state) {
    if (state is ActorDetailsLoaded) {
    return Text(state.actorDetails.name,style: AppTextStyles.bold.copyWith(color: Theme.of(context).colorScheme.primary,fontSize: 24),);
    } else {
    return const Text('Actor Details');
    }
    },
    ),
    ),
    body: BlocBuilder<ActorBloc, ActorState>(
        builder: (context, state) {
          if (state is ActorInitial || state is ActorLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ActorError) {
            return Center(child: Text(state.message));
          } else if (state is ActorDetailsLoaded) {
            final actor = state.actorDetails;
            final movies = state.movies;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildActorHeader(context, actor),
                  //const Divider(thickness: 1),
                  _buildBiographySection(context, actor),
                  //const Divider(thickness: 1),
                  _buildMoviesSection(context, state, movies),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    ));
  }

  Widget _buildActorHeader(BuildContext context, ActorDetails actor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: actor.profilePath.isNotEmpty
                ? Image.network(
              'https://image.tmdb.org/t/p/w300${actor.profilePath}',
              width: 120,
              height: 180,
              fit: BoxFit.cover,
            )
                : Container(
              width: 120,
              height: 180,
              color: Colors.grey[300],
              child: const Icon(Icons.person, size: 60),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  actor.name,
                 // style: Theme.of(context).textTheme.headline6,
                ),
                const SizedBox(height: 8),
                if (actor.popularity > 0)
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        actor.popularity.toStringAsFixed(1),
                        //style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                if (actor.birthday != null)
                  _buildInfoRow('Doğum:', actor.birthday!),
                if (actor.placeOfBirth != null)
                  _buildInfoRow('Doğum Yeri:', actor.placeOfBirth!),
                if (actor.deathday != null)
                  _buildInfoRow('Ölüm:', actor.deathday!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiographySection(BuildContext context, ActorDetails actor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Biyografi',
            style: AppTextStyles.bold.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 8),
          ExpandableText(
            text: actor.biography?.isNotEmpty == true
                ? actor.biography!
                : 'Biyografisi mevcut değil',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
  Widget _buildMoviesSection(
      BuildContext context,
      ActorDetailsLoaded state,
      List<Movie>? movies,
      ) {
    if (movies == null) {
      // Load movies if not loaded yet
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ActorBloc>().add(LoadActorMovies(actorId));
      });

      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (movies.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Oyuncunun filmleri bulunamadı.'),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16,),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filmografi',
            style: AppTextStyles.bold.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),

            itemCount: movies.length,
            itemBuilder: (context, index) {
              return MovieTile(movie: movies[index],posterHeight: 100, posterWidth: 70,);
            },
          ),
        ],
      ),
    );
  }
}



