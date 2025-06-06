import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:Cinemate/features/auth/domain/entities/app_user.dart';
import 'package:Cinemate/features/auth/presentation/cubits/auth_cubits.dart';
import 'dart:convert';
import 'package:lottie/lottie.dart';
import 'package:Cinemate/features/movies/domain/entities/movie.dart';
import 'package:Cinemate/features/profile/domain/entities/profile_user.dart';
import 'package:Cinemate/features/profile/presentation/components/user_tile.dart';
import 'package:Cinemate/features/search/presentation/components/trilogy_card.dart';
import 'package:Cinemate/features/search/presentation/cubits/search_cubit.dart';
import 'package:Cinemate/features/search/presentation/cubits/search_states.dart';
import 'package:Cinemate/features/movies/search/movie_tile.dart';

import 'package:Cinemate/themes/font_theme.dart';

import '../../../actors/presentation/actor_tile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();
  late final searchCubit = context.read<SearchCubit>();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchType = 'all'; // 'all', 'movies', 'users', 'actors'
  late final authCubit = context.read<AuthCubit>();
  late AppUser? currentUser = authCubit.currentUser;
  bool _showFilters = false;
  String? _selectedGenre;
  bool _searchBarActive = false;

  // List of movie genres
  final List<Map<String, dynamic>> genres = [
    {'id': 28, 'name': 'Aksiyon'},
    {'id': 12, 'name': 'Macera'},
    {'id': 16, 'name': 'Animasyon'},
    {'id': 35, 'name': 'Komedi'},
    {'id': 80, 'name': 'Suç'},
    {'id': 18, 'name': 'Drama'},
    {'id': 10751, 'name': 'Aile'},
    {'id': 14, 'name': 'Fantastik'},
    {'id': 36, 'name': 'Tarih'},
    {'id': 27, 'name': 'Korku'},
    {'id': 10402, 'name': 'Müzik'},
    {'id': 9648, 'name': 'Gizem'},
    {'id': 10749, 'name': 'Romantik'},
    {'id': 878, 'name': 'Bilim Kurgu'},
    {'id': 53, 'name': 'Gerilim'},
    {'id': 10752, 'name': 'Savaş'},
    {'id': 37, 'name': 'Western'},
  ];

  void onSearchChanged() {
    final query = searchController.text;
    if (_selectedGenre != null) {
      // If a genre is selected, search for movies in that genre
      searchCubit.searchByGenre(_selectedGenre!);
      return;
    }
    searchCubit.search(query, searchType: _searchType);

    if (query.isNotEmpty && !_showFilters) {
      setState(() {
        _showFilters = true;
      });
    } else if (query.isEmpty && _showFilters) {
      setState(() {
        _showFilters = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_searchFocusNode);
    });
  }

  @override
  void dispose() {
    searchController.removeListener(onSearchChanged);
    searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<Movie> _fetchMovieDetails(int movieId) async {
    final response = await http.get(
      Uri.parse(
          'https://api.themoviedb.org/3/movie/$movieId?api_key=7bd28d1b496b14987ce5a838d719c5c7&language=tr-TR'),
    );
    if (response.statusCode == 200) {
      return Movie.fromJson(json.decode(response.body));
    } else {
      throw Exception('Film detayları yüklenemedi');
    }
  }

  Widget _buildFilterChip(BuildContext context, String label, String value) {
    final isSelected = _searchType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _searchType = value;
          onSearchChanged();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search Bar ve Filtreler
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 0),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: "Kullanıcı, film veya oyuncu ara...",
                      hintStyle: AppTextStyles.medium.copyWith(color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (searchController.text.isNotEmpty)
                            IconButton(
                              icon: Icon(
                                Icons.close_rounded,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              onPressed: () {
                                searchController.clear();
                                setState(() {
                                  _selectedGenre = null;
                                });
                              },
                            ),
                        ],
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                // Filtre Chips'leri
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _showFilters || _selectedGenre != null
                      ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(context, 'Tümü', 'all'),
                          const SizedBox(width: 8),
                          _buildFilterChip(context, 'Filmler', 'movies'),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                              context, 'Kullanıcılar', 'users'),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                              context, 'Oyuncular', 'actors'),
                        ],
                      ),
                    ),
                  )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          // Sonuç Listesi veya Boş Durum
          Expanded(
            child: BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) {
                if (state is SearchLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is SearchError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline_rounded,
                            size: 48,
                            color: Theme.of(context).colorScheme.error),
                        const SizedBox(height: 16),
                        Text(state.message,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error)),
                      ],
                    ),
                  );
                }

                if (state is SearchLoaded) {
                  final users = state.users;
                  final movies = state.movies;
                  final actors = state.actors;

                  if (users.isEmpty &&
                      movies.isEmpty &&
                      actors.isEmpty &&
                      (searchController.text.isNotEmpty ||
                          _selectedGenre != null)) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded,
                              size: 48,
                              color: Theme.of(context).colorScheme.secondary),
                          const SizedBox(height: 16),
                          Text("Sonuç bulunamadı",
                              style: TextStyle(
                                  fontSize: 18,
                                  color:
                                  Theme.of(context).colorScheme.secondary)),
                          const SizedBox(height: 8),
                          Text(
                              _selectedGenre != null
                                  ? "'${_selectedGenre}' türünde film bulunamadı"
                                  : "'${searchController.text}' için sonuç yok",
                              style: TextStyle(
                                  color: Theme.of(context).hintColor)),
                        ],
                      ),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      if (users.isNotEmpty && _searchType != 'movies' && _searchType != 'actors') ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                          child: Text("Kullanıcılar",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color:
                                  Theme.of(context).colorScheme.primary)),
                        ),
                        ...users.map((user) => UserTile(user: user!)).toList(),
                      ],
                      if (movies.isNotEmpty && _searchType != 'users' && _searchType != 'actors') ...[
                        if (_selectedGenre != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.arrow_back,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                  onPressed: () {
                                    setState(() {
                                      _selectedGenre = null;
                                      searchController.clear();
                                    });
                                  },
                                ),
                                Text(
                                  "$_selectedGenre Filmleri",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                              ],
                            ),
                          ),
                        ...movies
                            .map((movie) => MovieTile(
                            movie: movie,
                            posterWidth: 60,
                            posterHeight: 90))
                            .toList(),
                      ],
                      if (actors.isNotEmpty && _searchType != 'users' && _searchType != 'movies') ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                          child: Text("Oyuncular",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color:
                                  Theme.of(context).colorScheme.primary)),
                        ),
                        ...actors.map((actor) => ActorTile(actor: actor)).toList(),
                      ],
                    ],
                  );
                }

                // Arama yapılmamışken gösterilen alan - Genre list
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        "Film Türleri",
                        style: AppTextStyles.bold.copyWith(color: Theme.of(context).colorScheme.primary,fontSize: 16)
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: genres.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color:
                          Theme.of(context).dividerColor.withOpacity(0.2),
                        ),
                        itemBuilder: (context, index) {
                          final genre = genres[index];
                          return ListTile(
                            title: Text(genre['name'], style: AppTextStyles.medium),
                            trailing: Icon(
                              Icons.chevron_right_rounded,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            onTap: () {
                              setState(() {
                                _selectedGenre = genre['name'];
                                _searchType = 'movies';
                                onSearchChanged();
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}