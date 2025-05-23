/*import 'dart:convert';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:Cinemate/features/auth/domain/entities/app_user.dart';
import 'package:Cinemate/features/auth/presentation/cubits/auth_cubits.dart';
import 'package:Cinemate/features/movies/comment/bottom_sheet.dart';
import 'package:Cinemate/features/movies/comment/comment_card.dart';
import 'package:Cinemate/features/movies/presentation/components/swap_poster.dart';
import 'package:Cinemate/features/movies/presentation/components/cast_member_card.dart';
import 'package:Cinemate/features/movies/presentation/components/expandable_text.dart';
import 'package:Cinemate/features/movies/presentation/pages/movie_news_page.dart';
import 'package:Cinemate/themes/font_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../comment/all_comment_page.dart';
import '../../comment/comment_model.dart';
import '../../comment/see_all_button.dart';
import '../cubits/movie_detail_cubit.dart';
import '../cubits/movie_detail_state.dart';
import 'package:Cinemate/features/movies/comment/comment_list.dart';
import 'package:http/http.dart' as http;

class MovieDetailPage extends StatefulWidget {
  final int movieId;

  const MovieDetailPage({super.key, required this.movieId});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  late Future<List<CommentModel>> commentsFuture;
  late final authCubit = context.read<AuthCubit>();
  late AppUser? currentUser = authCubit.currentUser;
  bool _isExpanded = false;
  bool isWatched = false;
  bool isFavorited = false;
  bool isInSavedlist = false;
  bool isInTopThree = false;
  bool isLoading = true;
  bool isOpened = false;

  //

  @override
  void initState() {
    super.initState();
    commentsFuture = fetchComments(widget.movieId.toString());
    context.read<MovieDetailCubit>().fetchMovieDetail(widget.movieId);
    _checkMovieStatus(widget.movieId);
  }

  Future<void> removeWatchedMovie(int movieId) async {
    final watchedRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('watchedMovies');

    final snapshot =
        await watchedRef.where('movieId', isEqualTo: movieId).get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // Film ID'sini kullanıcının favorilerinden kaldır
  Future<void> removeFavoriteMovie(int movieId) async {
    final favoriteRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('favoriteMovies');

    final snapshot =
        await favoriteRef.where('movieId', isEqualTo: movieId).get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // Film ID'sini kullanıcının izleyeceği listeden kaldır
  Future<void> removeFromSavedlist(int movieId) async {
    final savedlistRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('savedlist');

    final snapshot =
        await savedlistRef.where('movieId', isEqualTo: movieId).get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // Film ID'sini kullanıcının en iyi üçleme listesinden kaldır
  Future<void> removeFromTopThreeMovies(int movieId) async {
    final topMoviesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('topThreeMovies');

    final snapshot =
        await topMoviesRef.where('movieId', isEqualTo: movieId).get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

//
// snackbarü
  void showCustomSnackbar(String message, Color color, IconData icon) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.regular.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w200,
                  color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      duration: const Duration(milliseconds: 2000),
    );

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

//
////////////////////////////////////////////////////////////
  Future<void> toggleWatchedMovie(int movieId) async {
    final watchedMovies = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('watchedMovies');

    final snapshot =
        await watchedMovies.where('movieId', isEqualTo: movieId).get();

    if (snapshot.docs.isEmpty) {
      // Eğer film daha önce eklenmemişse ekle
      await watchedMovies.add({
        'movieId': movieId,
        'addedAt': FieldValue.serverTimestamp(),
      });
      showCustomSnackbar(
        'Film izlenenlere Eklendi.',
        Colors.blue,
        Icons.visibility,
      );
    } else {
      // Eğer film eklenmişse, kaldıralım
      await removeWatchedMovie(movieId);
      showCustomSnackbar(
        'Film İzlenenelerden Çıkarıldı.',
        Colors.redAccent,
        Icons.visibility_off,
      );
    }
  }

  // Film ID'sini kullanıcının favorilerine ekle veya çıkar
  Future<void> toggleFavoriteMovie(int movieId) async {
    final favoriteRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('favoriteMovies');

    final snapshot =
        await favoriteRef.where('movieId', isEqualTo: movieId).get();

    if (snapshot.docs.isEmpty) {
      // Eğer film daha önce eklenmemişse ekle
      await favoriteRef.add({
        'movieId': movieId,
        'addedAt': FieldValue.serverTimestamp(),
      });
      showCustomSnackbar(
        'Film Beğenilenlere Eklendi',
        Colors.redAccent,
        Icons.favorite,
      );
    } else {
      // Eğer film eklenmişse, kaldıralım
      await removeFavoriteMovie(movieId);
      showCustomSnackbar(
        'Film Beğenilenlerden çıkarıldı.',
        Colors.redAccent,
        Icons.favorite_border_outlined,
      );
    }
  }

  // Film ID'sini kullanıcının izleyeceği listesine ekle veya çıkar
  Future<void> toggleSavedlist(int movieId, BuildContext context) async {
    final savedlistRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('savedlist');

    final snapshot =
        await savedlistRef.where('movieId', isEqualTo: movieId).get();

    if (snapshot.docs.isEmpty) {
      // Film eklenmemişse → ekle
      await savedlistRef.add({
        'movieId': movieId,
        'addedAt': FieldValue.serverTimestamp(),
      });
      showCustomSnackbar(
        'Fİlm Kaydedildi.',
        Colors.green,
        Icons.playlist_add_check,
      );
    } else {
      // Film zaten varsa → kaldır
      await removeFromSavedlist(movieId);
      showCustomSnackbar(
        'Film kaydedilenlerden çıkarıldı.',
        Colors.redAccent,
        Icons.playlist_remove,
      );
    }

    // Snackbar göster
  }

  // Film ID'sini kullanıcının en iyi üçleme listesine ekle veya çıkar
  Future<bool> toggleTopThreeMovies(int movieId, BuildContext context) async {
    final topMovies = await getTopThreeMovies();

    if (topMovies.contains(movieId)) {
      setState(() {
        isInTopThree = false;
      });

      await removeFromTopThreeMovies(movieId);

      showCustomSnackbar(
        'Film en iyi 3 listesinden çıkarıldı.',
        Colors.redAccent,
        Icons.remove_circle_outline,
      );

      return true;
    } else {
      final topMoviesRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('topThreeMovies');

      final movieDetails = await fetchMovieDetails(movieId);
      final posterPath = movieDetails['poster_path'];

      if (topMovies.length < 3) {
        await topMoviesRef.add({
          'movieId': movieId,
          'poster_path': posterPath,
          'addedAt': FieldValue.serverTimestamp(),
        });

        setState(() {
          isInTopThree = true;
        });

        showCustomSnackbar(
          'Film en iyi 3 listene eklendi!',
          Colors.green,
          Icons.check_circle_outline,
        );

        return true;
      } else {
        final replacedMovieId = await showRemoveMovieDialogWithPosters(
          context,
          movieId,
          posterPath,
        );

        if (replacedMovieId != null) {
          await updateTopThreeMovies(
            removeMovieId: replacedMovieId,
            addMovieId: movieId,
            newPosterPath: posterPath,
          );

          setState(() {
            isInTopThree = true;
          });

          showCustomSnackbar(
            'Film başarıyla değiştirildi!',
            Colors.orange,
            Icons.swap_horiz,
          );

          return true;
        } else {
          showCustomSnackbar(
            'İşlem iptal edildi.',
            Colors.grey,
            Icons.cancel_outlined,
          );

          return false;
        }
      }
    }
  }

  Future<void> _checkMovieStatus(int movieId) async {
    setState(() {
      isLoading = true; // Yükleme başlasın
    });

    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(currentUser!.uid);

    final watchedSnapshot = await userDoc
        .collection('watchedMovies')
        .where('movieId', isEqualTo: movieId)
        .get();

    final favoriteSnapshot = await userDoc
        .collection('favoriteMovies')
        .where('movieId', isEqualTo: movieId)
        .get();

    final savedlistSnapshot = await userDoc
        .collection('savedlist')
        .where('movieId', isEqualTo: movieId)
        .get();

    final topThreeSnapshot = await userDoc
        .collection('topThreeMovies')
        .where('movieId', isEqualTo: movieId)
        .get();

    setState(() {
      isWatched = watchedSnapshot.docs.isNotEmpty;
      isFavorited = favoriteSnapshot.docs.isNotEmpty;
      isInSavedlist = savedlistSnapshot.docs.isNotEmpty;
      isInTopThree = topThreeSnapshot.docs.isNotEmpty;
      isLoading = false; // Yükleme tamamlandı
    });
  }

  Future<List<int>> getTopThreeMovies() async {
    final topMoviesSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('topThreeMovies')
        .get();

    return topMoviesSnapshot.docs.map((doc) => doc['movieId'] as int).toList();
  }

  Future<Map<String, dynamic>> fetchMovieDetails(int movieId) async {
    final response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/movie/$movieId?api_key=7bd28d1b496b14987ce5a838d719c5c7'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Film detayları alınamadı.');
    }
  }

  String getPosterUrl(String posterPath) {
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  Future<void> updateTopThreeMovies({
    required int removeMovieId,
    required int addMovieId,
    required String newPosterPath,
  }) async {
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(currentUser!.uid);
    final topMoviesRef = userRef.collection('topThreeMovies');

    final snapshot = await topMoviesRef.get();
    final docToRemove =
        snapshot.docs.firstWhere((doc) => doc['movieId'] == removeMovieId);
    await topMoviesRef.doc(docToRemove.id).delete();

    await topMoviesRef.add({
      'movieId': addMovieId,
      'poster_path': newPosterPath,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  // Kullanıcıya hangi filmi çıkarmak istediğini soran bir dialog
  Future<int?> showRemoveMovieDialogWithPosters(
    BuildContext context,
    int newMovieId,
    String newPosterPath,
  ) async {
    final currentTopMovies = await getTopThreeMovies(); // Sadece ID listesi
    final currentMovies =
        await Future.wait(currentTopMovies.map(fetchMovieDetails));

    return await showGeneralDialog<int>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: GestureDetector(
                onTap: () {},
                child: SwapPosterDialog(
                  newMovie: {
                    'id': newMovieId,
                    'poster_path': newPosterPath,
                  },
                  currentMovies: currentMovies
                      .map((movie) => {
                            'id': movie['id'],
                            'poster_path': movie['poster_path'],
                          })
                      .toList(),
                  onConfirm: (int replacedMovieId) {
                    Navigator.of(context).pop(replacedMovieId);
                  },
                  onCancel: () {
                    Navigator.of(context).pop(null);
                  },
                ),
              ),
            ),
          ),
        );
      },
      barrierLabel: 'Dismiss',
    );
  }

  Future<void> _launchTrailer(String? trailerKey) async {
    if (trailerKey == null || trailerKey.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bu filmin trailerı bulunamadı')),
        );
      }
      return;
    }

    // Clean the trailer key in case it's a full URL
    String cleanKey = trailerKey;
    if (trailerKey.contains('watch?v=')) {
      cleanKey = trailerKey.split('watch?v=').last;
    }
    cleanKey = cleanKey.split('&').first; // Remove any URL parameters

    try {
      final url = Uri.parse('https://www.youtube.com/watch?v=$cleanKey');
      final bool launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'YouTube uygulaması bulunamadı, tarayıcıda açmayı deneyin')),
        );
        // Fallback to in-app browser
        await launchUrl(
          url,
          mode: LaunchMode.inAppWebView,
        );
      }
    } catch (e) {
      debugPrint('Trailer Error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trailer açılırken hata oluştu')),
        );
      }
    }
  }

  bool _showLargePoster = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MovieDetailCubit, MovieDetailState>(
        builder: (context, state) {
          if (state is MovieDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MovieDetailLoaded) {
            final movie = state.movie;

            return Stack(
              children: [
                Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              // BACKDROP IMAGE

                              Container(
                                foregroundDecoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.grey.shade800,//Theme.of(context).colorScheme.tertiary,
                                      Colors.transparent
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                ),
                                width: MediaQuery.of(context).size.width,
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: movie.backdropPath.isNotEmpty
                                        ? NetworkImage(
                                            'https://image.tmdb.org/t/p/w500${movie.backdropPath}')
                                        : const AssetImage(
                                                'assets/fallback_image.jpg')
                                            as ImageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                              // POSTER
                              Positioned(
                                bottom: 10,
                                right: 20,
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _showLargePoster = true),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      'https://image.tmdb.org/t/p/w200${movie.posterPath}',
                                      height: 150,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              if (movie.trailerKey != null &&
                                  movie.trailerKey!.isNotEmpty)
                                Positioned(
                                  bottom: 2,
                                  left: 5,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: ElevatedButton.icon(
                                      onPressed: () =>
                                          _launchTrailer(movie.trailerKey!),
                                      icon: Icon(Icons.play_arrow, size: 24,color: Colors.white,),
                                      label: Text(
                                        "Trailer'ı İzle",
                                        style: AppTextStyles.bold.copyWith(color: Colors.white),),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF345d64),
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 2),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        elevation: 6,
                                        shadowColor: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Container(
                                              width: 250,
                                              child: Text(
                                                movie.title,
                                                style: AppTextStyles.bold.copyWith(color: Theme.of(context).colorScheme.primary, fontSize: 26)

                                                // Taşarsa üç nokta ekler
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 30.0),
                                              child: Row(
                                                children: [
                                                  Container(
                                                      height: 40,
                                                      width: 40,
                                                      child: Image.asset(
                                                          "assets/imdb.png")),
                                                  Text(
                                                      "  ${movie.voteAverage.toStringAsFixed(1)}"),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        Text("Yönetmen: ${movie.director}",
                                            style: AppTextStyles.bold.copyWith(
                                                fontSize: 14,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary.withOpacity(0.7))),

                                        // Release Date & Runtime
                                        Text(
                                            "${movie.releaseDate.substring(0, 4)}",
                                            style: AppTextStyles.bold.copyWith(
                                                fontSize: 14,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary.withOpacity(0.7))),
                                        Text("${movie.runtime} dakika",
                                            style: AppTextStyles.bold.copyWith(
                                                fontSize: 14,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary.withOpacity(0.7))),

                                        // yıldız gelcek buraya
                                      ],
                                    ),
                                  ],
                                ),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: movie.genres.map((genre) {
                                    return Chip(
                                      label: Text(
                                        genre,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .tertiary),
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 10),
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary.withOpacity(0.8),
                                      side:
                                          BorderSide(color: Colors.transparent),
                                    );
                                  }).toList(),
                                ),
                                ExpandableText(text: movie.overview),
                                Text("Oyuncular",
                                    style: AppTextStyles.bold.copyWith(
                                        fontSize: 28,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary)),
                                SizedBox(
                                  height: 130,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: movie.cast.length,
                                    itemBuilder: (context, index) {
                                      final castMember = movie.cast[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6),
                                        child: CastMemberCard(
                                          name: castMember.name,
                                          profilePath: castMember.profilePath,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(20)),
                                        ),
                                        builder: (context) {
                                          return Padding(
                                            padding: EdgeInsets.only(
                                              bottom: MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom,
                                            ),
                                            child: CommentBottomSheet(
                                              movieId: widget.movieId,
                                              movieTitle: movie.title,
                                              posterPath: movie.posterPath,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12))),
                                    child: Text(
                                      'Yorum Ekle/ Değerlendir',
                                      style: AppTextStyles.bold.copyWith(color: Theme.of(context)
                                          .colorScheme
                                          .tertiary)
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Yorumlar",
                                            style: AppTextStyles.bold.copyWith(color: Theme.of(context)
                                                .colorScheme
                                                .primary, fontSize: 18)
                                          ),
                                          SeeAllButton(
                                            onTap: () {
                                              commentsFuture.then((comments) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        AllCommentsPage(
                                                            comments: comments),
                                                  ),
                                                );
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    FutureBuilder<List<CommentModel>>(
                                      future: commentsFuture,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        } else if (snapshot.hasError) {
                                          return const Center(
                                              child:
                                                  Text('Yorumlar yüklenemedi'));
                                        } else if (!snapshot.hasData ||
                                            snapshot.data!.isEmpty) {
                                          return const Center(
                                              child: Text(
                                                  'Henüz yorum yapılmamış.'));
                                        } else {
                                          final comments = snapshot.data!;
                                          return SizedBox(
                                            height: 180,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: comments.length > 5
                                                  ? 5
                                                  : comments.length,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              itemBuilder: (context, index) {
                                                final comment = comments[index];
                                                return CommentCard(
                                                    comment: comment);
                                              },
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  MovieNewsPage(
                                                      movieTitle: movie.title),
                                            ),
                                          );
                                        },
                                        child: Text("haberler")),
                                        SizedBox(height: 200,)
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Positioned(
                        top: 60,
                        right: 20,
                        child: Container(
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.white70),
                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(FontAwesomeIcons.xmark,
                                  color: Colors.black),
                            ))),
                    Positioned(
                      bottom: 15,
                      right: 30,
                      left: 30,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          color: Theme.of(context).colorScheme.primary,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                  onPressed: () async {
                                    setState(() {
                                      isWatched = !isWatched;
                                    });
                                    await toggleWatchedMovie(movie.id);
                                  },
                                  icon: Icon(
                                      isWatched
                                          ? Icons
                                              .visibility // İzlenmişse onay ikonu
                                          : Icons
                                              .visibility_off, // İzlenecekse saat ikonu
                                      color: isWatched
                                          ? Colors.blue
                                          : Theme.of(context)
                                              .colorScheme
                                              .tertiary)),
                              // Favorite Icon
                              IconButton(
                                onPressed: () async {
                                  setState(() {
                                    isFavorited = !isFavorited;
                                  });
                                  await toggleFavoriteMovie(movie.id);
                                },
                                icon: Icon(
                                  isFavorited
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFavorited
                                      ? Colors.red
                                      : Theme.of(context).colorScheme.tertiary,
                                ),
                              ),

                              IconButton(
                                onPressed: () async {
                                  setState(() {
                                    isInSavedlist = !isInSavedlist;
                                  });
                                  await toggleSavedlist(movie.id, context);
                                },
                                icon: Icon(
                                  isInSavedlist
                                      ? Icons.playlist_add
                                      : Icons.playlist_add_check,
                                  color: isInSavedlist
                                      ? Colors.green
                                      : Theme.of(context).colorScheme.tertiary,
                                ),
                              ),

                              // Watchlist Icon
                              /* IconButton(
                        onPressed: () async {
                          // toggleSavedlist fonksiyonunu çağır ve sonucu bekle
                          await toggleSavedlist(movie.id, context);
            
                          // isInSavedlist durumunu kontrol et ve UI'yi güncelle
                          setState(() {
                            isInSavedlist =
                                !isInSavedlist; // Durum tersine çevrilecek
                          });
                        },
                        icon: Icon(
                          isInSavedlist
                              ? Icons.playlist_add_check
                              : Icons.playlist_add,
                          color: isInSavedlist
                              ? Colors.green
                              : null, // Kaydedildiyse yeşil renk
                        ),
                      ),*/

                              // Top 3 Icon
                              IconButton(
                                onPressed: () async {
                                  final willBeInTopThree = !isInTopThree;

                                  // Firestore işlemi başlayacak
                                  bool success = false;

                                  // Yıldızın rengi, sadece işlemin başarılı olduğunda değişecek
                                  setState(() {
                                    // Başlangıçta yıldızın rengini değiştirmiyoruz
                                    // Firebase işlemi başarılı olursa onu güncelleyeceğiz.
                                  });

                                  try {
                                    // Firestore işlemi
                                    success = await toggleTopThreeMovies(
                                        movie.id, context);

                                    if (success) {
                                      setState(() {
                                        isInTopThree = willBeInTopThree;
                                      });
                                    }
                                  } catch (e) {
                                    // Hata durumu: Yıldız rengi geri alınacak
                                    setState(() {
                                      isInTopThree = !willBeInTopThree;
                                    });
                                  }
                                },
                                icon: Icon(
                                  isInTopThree ? Icons.star : Icons.star_border,
                                  color: isInTopThree
                                      ? Colors.amber
                                      : Theme.of(context).colorScheme.tertiary,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_showLargePoster)
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: GestureDetector(
                        onTap: () => setState(() => _showLargePoster = false),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          color: Colors.black.withOpacity(0.5),
                          child: Center(
                            child: GestureDetector(
                              onTap: () {},
                              child: Hero(
                                tag: "poster-${movie.id}",
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      'https://image.tmdb.org/t/p/w780${movie.posterPath}',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          } else if (state is MovieDetailError) {
            return Center(child: Text(state.message));
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
*/
/*
class MovieDetailPage extends StatefulWidget {
  final int movieId;

  const MovieDetailPage({super.key, required this.movieId});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  final TextEditingController _controller = TextEditingController();

  void _submitComment() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      CommentService().addComment(widget.movieId.toString(), text);
      _controller.clear();
      FocusScope.of(context).unfocus(); // Klavyeyi kapat
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<MovieDetailCubit>().fetchMovieDetail(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MovieDetailCubit, MovieDetailState>(
        builder: (context, state) {
          if (state is MovieDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MovieDetailLoaded) {
            final movie = state.movie;

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 250,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: movie.backdropPath.isNotEmpty
                        ? Image.network(
                            'https://image.tmdb.org/t/p/w500${movie.backdropPath}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/fallback_image.jpg',
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Image.asset(
                            'assets/fallback_image.jpg',
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Poster
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              'https://image.tmdb.org/t/p/w200${movie.posterPath}',
                              height: 150,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/fallback_image.jpg',
                                  fit: BoxFit.cover,
                                  height: 150,
                                  width: 100,
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Title
                        Text(
                          movie.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Text("Yönetmen: ${movie.director}"),
                        Text("Çıkış Tarihi: ${movie.releaseDate}"),
                        Text("Süre: ${movie.runtime} dakika"),

                        const SizedBox(height: 8),

                        Wrap(
                          spacing: 8,
                          children: movie.genres.map((genre) {
                            return Chip(
                              label: Text(genre),
                              backgroundColor: Colors.grey.shade200,
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 16),
                        const Text(
                          "Oyuncular",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: movie.cast.length,
                            itemBuilder: (context, index) {
                              final castMember = movie.cast[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        width: 60,
                                        height: 90,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: castMember.profilePath.isNotEmpty
                                                ? NetworkImage('https://image.tmdb.org/t/p/w200${castMember.profilePath}')
                                                : const AssetImage('assets/fallback_image.jpg') as ImageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      castMember.name,
                                      style: const TextStyle(fontSize: 12),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 16),
                        const Text(
                          "Yorumlar",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        CommentList(movieId: widget.movieId.toString()),
                        const SizedBox(height: 80), // Yorum kutusu için boşluk
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else if (state is MovieDetailError) {
            return Center(child: Text(state.message));
          } else {
            return const SizedBox.shrink();
          }
        },
      ),

      // 🟢 Yorum kutusu buraya alındı
      bottomNavigationBar: Padding(
        padding: MediaQuery.of(context).viewInsets, // Klavye açılınca yukarı çıkar
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Yorumunuzu yazın...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _submitComment,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/