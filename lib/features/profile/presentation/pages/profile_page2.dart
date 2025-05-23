import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_widget/home_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:Cinemate/features/auth/domain/entities/app_user.dart';
import 'package:Cinemate/features/auth/presentation/cubits/auth_cubits.dart';
import 'package:Cinemate/features/auth/presentation/cubits/navbar_cubit.dart';
import 'package:Cinemate/features/chat/presentation/cubits/chat_cubit.dart';
import 'package:Cinemate/features/home/presentation/components/movie_card.dart';
import 'package:Cinemate/features/home/presentation/pages/post_detail_page.dart';
import 'package:Cinemate/features/movies/presentation/cubits/movie_cubit.dart';
import 'package:Cinemate/features/movies/presentation/pages/movie_detail_page.dart';
import 'package:Cinemate/features/post/domain/entities/post.dart';
import 'package:Cinemate/features/post/presentation/components/post_tile.dart';
import 'package:Cinemate/features/post/presentation/cubits/post_cubit.dart';
import 'package:Cinemate/features/post/presentation/cubits/post_states.dart';
import 'package:Cinemate/features/premium/pages/premiums_page.dart';
import 'package:Cinemate/features/premium/pages/subscriptions_page.dart';
import 'package:Cinemate/features/profile/domain/entities/profile_user.dart';
import 'package:Cinemate/features/profile/presentation/components/animated_movie_cards.dart';
import 'package:Cinemate/features/profile/presentation/components/bio_box.dart';
import 'package:Cinemate/features/profile/presentation/components/follow_button.dart';
import 'package:Cinemate/features/profile/presentation/components/message_button.dart';
import 'package:Cinemate/features/profile/presentation/components/movie_stats.dart';
import 'package:Cinemate/features/profile/presentation/components/premium_button.dart';
import 'package:Cinemate/features/profile/presentation/components/profile_stats.dart';
import 'package:Cinemate/features/profile/presentation/components/user_tile.dart';
import 'package:Cinemate/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:Cinemate/features/profile/presentation/cubits/profile_states.dart';
import 'package:Cinemate/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Cinemate/features/profile/presentation/pages/follower_page.dart';
import 'package:Cinemate/features/search/presentation/pages/search_page.dart';
import 'package:Cinemate/features/settings/pages/settings_page.dart';
import 'package:Cinemate/themes/font_theme.dart';
import 'package:http/http.dart' as http;
import '../../../../config/home_widget_helper.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import 'package:intl/intl.dart';

import '../components/popup_topthremovies.dart';

class ProfilePage2 extends StatefulWidget {
  final String uid;
  const ProfilePage2({super.key, required this.uid});

  @override
  State<ProfilePage2> createState() => _ProfilePage2State();
}

class _ProfilePage2State extends State<ProfilePage2>
    with TickerProviderStateMixin {
  late final authCubit = context.read<AuthCubit>();
  late final profileCubit = context.read<ProfileCubit>();
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  bool _showExtendedBio = false;
  late TabController _tabController;
  bool _isLoading = false;
  StreamSubscription? _subscription;
  Timer? _timer;

  List<int> topThreeMovies = [];
  List<int> favoriteMovies = [];
  List<int> watchedMovies = [];
  List<int> savedMovies = [];

  // current user
  late AppUser? currentUser = authCubit.currentUser;
  List<Map<String, dynamic>> _userReviews = [];
  int _postCount = 0;
  int watchedMoviesCount = 0;
  int favoriteMoviesCount = 0;
  int savedMoviesCount = 0;

  //////////////////////
  String appGroupId = "group.ArtSyncc";
  String iOSWidgetName = "CinemateWidget";
  String androidWidgetName = "CinemateWidget";
  String dataKey = "text_from_flutter_app";
  ////////////////////////////////////

  @override
  void initState() {
    super.initState();
    HomeWidget.setAppGroupId(appGroupId);
    profileCubit.fetchUserProfile(widget.uid);
    context.read<PostCubit>().fetchPostsForUser(widget.uid);
    _loadPostCount();
    _loadUserReviews();
    _loadTopThreeMovies();
    _loadAllMovieCollections();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _heightAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _subscription = context.read<MovieCubit>().stream.listen((state) {
      if (mounted) {
        setState(() {});
      }
    });

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    _subscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  void _homewidget() async {


    String data = "selam";
    await HomeWidget.saveWidgetData(dataKey, data);

    await HomeWidget.updateWidget(
      iOSName: iOSWidgetName,
      androidName: androidWidgetName,
    );

  }

  Future<void> _loadPostCount() async {
    final postSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: widget.uid)
        .get();

    setState(() {
      _postCount = postSnapshot.docs.length;
    });
  }

  Future<void> _showUserTopThreeMovies() async {
    final currentUserId = currentUser!.uid;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/lotties/matching.json', // Lottie dosyanızın yolunu buraya ekleyin
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            Text(
                'Aynı 3 filmi sevenleri arıyorum...',
                style: AppTextStyles.bold.copyWith(color: Colors.white)
            ),
          ],
        ),
      ),
    );

    try {
      final matchingUsers =
      await _findUsersWithSameTopThreeMovies(currentUserId);
      Navigator.of(context).pop();

      if (matchingUsers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Aynı 3 filmi seven başka kullanıcı bulunamadı')),
        );
        return;
      }

      // Bottom Sheet ile kullanıcıları göster
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.85, // %85 yükseklik
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Başlık ve kapatma butonu için sabit yükseklikte container
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Aynı 3 Filmi Sevenler (${matchingUsers.length})',
                      style: AppTextStyles.bold.copyWith(fontSize: 18),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 24),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Liste kısmı
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: matchingUsers.length,
                    itemBuilder: (context, index) {
                      final user = matchingUsers[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: UserTile(user: user),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata oluştu: ${e.toString()}')),
      );
    }
  }

  Future<List<ProfileUser>> _findUsersWithSameTopThreeMovies(
      String currentUserId) async {
    final startTime = DateTime.now();
    final currentUserMovies = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('topThreeMovies')
        .get();

    if (currentUserMovies.docs.length != 3) return [];

    final currentUserMovieIds =
    currentUserMovies.docs.map((doc) => doc['movieId'] as int).toSet();

    final allUsers = await FirebaseFirestore.instance.collection('users').get();
    final matchingUsers = <ProfileUser>[];

    for (final userDoc in allUsers.docs) {
      if (userDoc.id == currentUserId) continue;

      final userMovies =
      await userDoc.reference.collection('topThreeMovies').get();
      if (userMovies.docs.length != 3) continue;

      final userMovieIds =
      userMovies.docs.map((doc) => doc['movieId'] as int).toSet();

      if (currentUserMovieIds.difference(userMovieIds).isEmpty) {
        matchingUsers
            .add(ProfileUser.fromJson(userDoc.data() as Map<String, dynamic>));
      }
    }

    final elapsedTime = DateTime.now().difference(startTime);
    // Eğer 3 saniyeden az sürdüyse, kalan süre kadar bekletiyoruz
    if (elapsedTime < const Duration(seconds: 3)) {
      await Future.delayed(const Duration(seconds: 3) - elapsedTime);
    }

    return matchingUsers;
  }

  Widget _buildReviewsTab() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_userReviews.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Henüz film incelemesi bulunmamaktadır',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUserReviews,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 8),
        itemCount: _userReviews.length,
        separatorBuilder: (context, index) => SizedBox(height: 8),
        itemBuilder: (context, index) => _buildReviewTile(_userReviews[index]),
      ),
    );
  }

  Future<void> _loadUserReviews() async {
    setState(() => _isLoading = true);

    try {
      final reviewsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .collection('movie_reviews')
          .orderBy('timestamp', descending: true)
          .get();

      List<Map<String, dynamic>> reviews = [];

      for (var doc in reviewsSnapshot.docs) {
        try {
          final data = doc.data();
          final movieId = data['movieId'];
          if (movieId == null) continue;

          final movieDoc = await FirebaseFirestore.instance
              .collection('movies')
              .doc(movieId)
              .get();

          if (movieDoc.exists) {
            reviews.add({
              'comment': data,
              'movieId': movieId,
              'movieData': movieDoc.data(),
            });
          }
        } catch (e) {
          debugPrint('Yorum işlenirken hata: $e');
        }
      }

      setState(() {
        _userReviews = reviews;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Yorumlar yüklenirken hata: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Yorumlar yüklenirken bir hata oluştu')),
      );
    }
  }

  Widget _buildReviewTile(Map<String, dynamic> review) {
    final comment = review['comment'] ?? {};
    final movieId = review['movieId'] ?? '';
    final date = (comment['timestamp'] as Timestamp?)?.toDate();
    final formattedDate =
    date != null ? DateFormat('dd MMM yyyy').format(date) : '';

    final rating = comment['rating']?.toDouble() ?? 0.0;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Film Posteri
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 75,
                height: 110,
                child: MovieCard(
                  movieId: movieId,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetailPage(
                          movieId: int.tryParse(movieId) ?? 0,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            SizedBox(width: 12),

            // Yorum Detayları
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Film adı + puan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          comment['movieTitle'] ?? 'Bilinmeyen Film',
                          style: AppTextStyles.bold.copyWith(color: Theme.of(context).colorScheme.primary,fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          SizedBox(width: 2),
                          Text(
                            rating.toStringAsFixed(1),
                            style: AppTextStyles.medium.copyWith(color: Theme.of(context).colorScheme.primary)
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 8),

                  // Yorum metni
                  Text(
                    comment['comment'] ?? '',
                    style: AppTextStyles.medium.copyWith(color: Theme.of(context).colorScheme.primary.withOpacity(0.6)),
                  ),

                  SizedBox(height: 10),

                  // Tarih + yıldızlar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formattedDate,
                        style: AppTextStyles.medium.copyWith(color: Theme.of(context).colorScheme.secondary,fontSize: 12)
                      ),
                      /* Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 14,
                        ),
                      ),
                    ),*/
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadAllMovieCollections() async {
    try {
      final futures = await Future.wait([
        profileCubit.getMovieCollection(widget.uid, 'favoriteMovies'),
        profileCubit.getMovieCollection(widget.uid, 'watchedMovies'),
        profileCubit.getMovieCollection(widget.uid, 'savedlist'),
      ]);

      setState(() {
        favoriteMovies = futures[0];
        watchedMovies = futures[1];
        savedMovies = futures[2];
      });
    } catch (e) {
      print('Error loading movie collections: $e');
    }
  }

  Future<void> _loadTopThreeMovies() async {
    try {
      final movies = await profileCubit.getTopThreeMovies(widget.uid);
      setState(() {
        topThreeMovies = movies;
      });
    } catch (e) {
      print('Error loading top three movies: $e');
    }
  }

  void _showAllMoviesBottomSheet(String title, List<int> movies) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          color: Theme.of(context).colorScheme.surface,
          height: MediaQuery.of(context).size.height * 0.9,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Poppins",
                    color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.6,
                  ),
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    return _buildMovieItem(movies[index]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _fetchMovieDetails(int movieId) async {
    const apiKey = '7bd28d1b496b14987ce5a838d719c5c7';
    final url = Uri.parse(
        'https://api.themoviedb.org/3/movie/$movieId?api_key=$apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load movie details');
      }
    } catch (e) {
      throw Exception('Failed to fetch movie: $e');
    }
  }

  Widget _buildMovieItem(int movieId, {double aspectRatio = 2 / 3}) {
    // Cubit'ten cached movie verisini al
    final profileCubit = context.read<ProfileCubit>();
    final movieData = profileCubit.getCachedMovie(movieId);

    // Eğer veri cache'de yoksa FutureBuilder ile yükle
    if (movieData == null) {
      return FutureBuilder<Map<String, dynamic>>(
        future: profileCubit.getMovieDetails(movieId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: Colors.grey[300],
              child: const Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Container(
              color: Colors.grey[300],
              child: const Icon(Icons.error),
            );
          }

          final movieData = snapshot.data!;
          final posterPath = movieData['poster_path'] as String?;

          return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MovieDetailPage(movieId: movieId),
                  ),
                );
              },
              child: AspectRatio(
                aspectRatio: aspectRatio,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: posterPath != null
                      ? CachedNetworkImage(
                    imageUrl:
                    'https://image.tmdb.org/t/p/w500$posterPath',
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: Colors.grey),
                    errorWidget: (context, url, error) =>
                    const Icon(Icons.error),
                  )
                      : Container(
                    color: Colors.grey,
                    child: const Center(child: Icon(Icons.movie)),
                  ),
                ),
              ));
        },
      );
    }

    // Cache'den gelen veri ile widget'ı oluştur
    final posterPath = movieData['poster_path'] as String?;
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetailPage(movieId: movieId),
            ),
          );
        },
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: posterPath != null
                ? CachedNetworkImage(
              imageUrl: 'https://image.tmdb.org/t/p/w500$posterPath',
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Container(color: Colors.grey),
              errorWidget: (context, url, error) =>
              const Icon(Icons.error),
            )
                : Container(
              color: Colors.grey,
              child: const Center(child: Icon(Icons.movie)),
            ),
          ),
        ));
  }

  Widget _buildTopMoviesSection(bool isOwnProfile) {
    final displayMovies = List<int?>.filled(3, null);
    for (int i = 0; i < topThreeMovies.length && i < 3; i++) {
      displayMovies[i] = topThreeMovies[i];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 12),

        // Başlık ve paylaş butonu
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: SizedBox(
            height: 48, // Fixed height for the header section
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Text(
                    "En İyi Üçlemem",
                    style: AppTextStyles.bold.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 20,
                    ),
                  ),
                ),
                if (isOwnProfile)
                  Positioned(
                      left: 0,
                      child: TextButton(
                          onPressed: () => _showUserTopThreeMovies(),
                          child: Text(
                            "Eşleş",
                            style: AppTextStyles.bold.copyWith(color: Theme.of(context).colorScheme.primary),
                          ))),
                if (isOwnProfile && topThreeMovies.length == 3)
                  Positioned(
                    right: 0,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      icon: Icon(Icons.share, size: 22,color: Theme.of(context).colorScheme.primary),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => FavoriteMoviesPopup(
                            topThreeMovies: topThreeMovies,
                            buildMovieItem: (id, {aspectRatio = 2 / 3}) =>
                                _buildMovieItem(id, aspectRatio: aspectRatio),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Film kutuları
        SizedBox(
          height: 170,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: displayMovies.asMap().entries.map((entry) {
                final index = entry.key;
                final movieId = entry.value;

                return Container(
                  width: 110,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: movieId != null
                      ? _buildMovieItem(movieId, aspectRatio: 2 / 3)
                      : _buildEmptyTopMoviePlaceholder(isOwnProfile),
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildEmptyTopMoviePlaceholder([bool isOwnProfile = true]) {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      child: isOwnProfile
          ? GestureDetector(
        onTap: () {
          context.read<NavBarCubit>().changeTab(2);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 40,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  "En iyi üçlemeni tamamla",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.medium.copyWith(
                    color: Theme.of(context).colorScheme.tertiary,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      )
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_creation_outlined,
            size: 40,
            color:
            Theme.of(context).colorScheme.tertiary.withOpacity(0.4),
          ),
          const SizedBox(height: 8),
          Text(
            "Boş",
            textAlign: TextAlign.center,
            style: AppTextStyles.medium.copyWith(
              color:
              Theme.of(context).colorScheme.tertiary.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieCollectionSection(String title, List<int> movies) {
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
                style: AppTextStyles.bold.copyWith(color: Theme.of(context).colorScheme.primary)
              ),
              if (movies.isNotEmpty)
                TextButton(
                  onPressed: () => _showAllMoviesBottomSheet(title, movies),
                  child: Text(
                    "Tümünü Gör",
                    style: AppTextStyles.medium.copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 110,
          child: movies.isEmpty
              ? Center(
            child: Text(
              "Bu liste boş",
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          )
              : ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: SizedBox(
                  width: 65,
                  child: _buildMovieItem(movies[index]),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  void followButtonPressed() {
    final profileState = profileCubit.state;
    if (profileState is! ProfileLoaded) {
      return;
    }

    final profileUser = profileState.profileUser;
    final isFollowing = profileUser.followers.contains(currentUser!.uid);

    //optimistically update the ui
    setState(() {
      if (isFollowing) {
        profileUser.followers.remove(currentUser!.uid);
      } else {
        profileUser.followers.add(currentUser!.uid);
      }
    });

    profileCubit.toggleFollow(currentUser!.uid, widget.uid).catchError((error) {
      //reverse update if there is an error
      setState(() {
        if (isFollowing) {
          profileUser.followers.add(currentUser!.uid);
        } else {
          profileUser.followers.remove(currentUser!.uid);
        }
      });
    });
  }

  void _toggleExtendedBio() {
    _showExtendedBio = !_showExtendedBio;
    if (_showExtendedBio) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    setState(() {});
  }

  Future<void> _refreshProfileData() async {
    try {
      await context.read<ProfileCubit>().fetchUserProfile(widget.uid!);
      await Future.wait([]);
      await _loadTopThreeMovies();
      await _loadAllMovieCollections();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Yenileme başarısız: ${e.toString()}")),
      );
      rethrow;
    }
  }

  Widget _buildPostsGrid(List<Post> posts) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (posts.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Henüz paylaşımı bulunmamaktadır',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        childAspectRatio: 1,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return GestureDetector(
          onTap: () {
            // Navigate to post detail page
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PostDetailPage(post: post)));
          },
          child: CachedNetworkImage(
            imageUrl: post.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: Colors.grey[200]),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isOwnPost = (widget.uid == currentUser!.uid);

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded) {
          final user = state.profileUser;

          // Film istatistiklerini güncelle
          watchedMoviesCount = user.watchedMovies.length;
          favoriteMoviesCount = user.favoriteMovies.length;
          savedMoviesCount = user.savedlist.length;

          return RefreshIndicator(
            onRefresh: _refreshProfileData,
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                title: Text(user.name,
                    style: AppTextStyles.bold.copyWith(fontSize: 25,color: Theme.of(context).colorScheme.primary)),
                actions: [
                  if (isOwnPost)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                        icon: Icon(Icons.settings,color: Theme.of(context).colorScheme.primary),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SettingsPage(),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
              body: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: Container(
                        color: Theme.of(context).colorScheme.tertiary,
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: CachedNetworkImageProvider(
                                  user.profileImageUrl),
                            ),
                            SizedBox(height: 10),
                            Text(
                              user.name,
                              style: AppTextStyles.medium.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 22),
                            ),
                            SizedBox(height: 10),
                            ProfileStats(
                              postCount: _postCount,
                              followerCount: user.followers.length,
                              followingCount: user.following.length,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FollowerPage(
                                    followers: user.followers,
                                    following: user.following,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isOwnPost) ...[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditProfilePage(user: user),
                                          ),
                                        );
                                        Future.delayed(Duration.zero, () {
                                          WidgetHelper.updateWidgetFromFirebase();
                                        });

                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context).colorScheme.primary,
                                        foregroundColor: Theme.of(context).colorScheme.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Text(
                                        "Profili Düzenle",
                                        style: AppTextStyles.bold.copyWith(
                                          color: Theme.of(context).colorScheme.tertiary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  FlamingButton(
                                    text: "Premium",
                                    onPressed: () {

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PremiumsPage(),
                                        ),
                                      );
                                    },
                                  ),


                                ] else ...[
                                  FollowButton(
                                    onPressed: followButtonPressed,
                                    isFollowing: user.followers.contains(currentUser!.uid),
                                  ),
                                  const SizedBox(width: 10),
                                  MessageButton(
                                    onPressed: () async {
                                      final currentUserId = currentUser!.uid;
                                      final otherUserId = user.uid;
                                      try {
                                        await context.read<ChatCubit>().startNewChat(
                                          currentUserId: currentUserId,
                                          otherUserId: otherUserId,
                                          currentUserName: currentUser!.name,
                                          currentUserAvatar: "currentUser!.profileImageUrl",
                                          otherUserName: user.name,
                                          otherUserAvatar: user.profileImageUrl,
                                        );
                                        final chatState = context.read<ChatCubit>().state;
                                        if (chatState is ChatStarted) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ChatPage(
                                                chatId: chatState.chatId,
                                                otherUserName: user.name,
                                                otherUserId: otherUserId,
                                                otherUserAvatar: "",
                                              ),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Sohbet başlatılamadı: $e')),
                                        );
                                      }
                                    },
                                  ),
                                ],
                                const SizedBox(width: 10),
                                IconButton(
                                  icon: Icon(
                                    _showExtendedBio
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  onPressed: _toggleExtendedBio,
                                ),
                              ],
                            ),

                            SizeTransition(
                              sizeFactor: _heightAnimation,
                              child: Column(
                                children: [
                                  SizedBox(height: 20),
                                  MovieStats(
                                    watchedCount: watchedMoviesCount,
                                    favoriteCount: favoriteMoviesCount,
                                    savedCount: savedMoviesCount,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: Container(
                                      width: double.infinity,
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Hakkımda",
                                            style: AppTextStyles.medium.copyWith(color: Theme.of(context).colorScheme.primary),
                                            textAlign: TextAlign.left,
                                          ),
                                          SizedBox(height: 5),
                                          Container(
                                            width: double.infinity,
                                            child: Text(
                                              user.bio,
                                              style: AppTextStyles.italic
                                                  .copyWith(fontSize: 13,color: Theme.of(context).colorScheme.primary),
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _buildTopMoviesSection(isOwnPost),
                    ),
                    SliverToBoxAdapter(
                      child: _buildMovieCollectionSection(
                          'Favori Filmler', favoriteMovies),
                    ),
                    SliverToBoxAdapter(
                      child: _buildMovieCollectionSection(
                          'İzlenen Filmler', watchedMovies),
                    ),
                    SliverToBoxAdapter(
                      child: _buildMovieCollectionSection(
                          'Kaydedilenler', savedMovies),
                    ),
                    SliverToBoxAdapter(
                      child: TabBar(
                        controller: _tabController,
                        tabs: [
                          Tab(
                            icon: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.grid_on, size: 20),
                                SizedBox(width: 8),
                                Text("Gönderiler"),
                              ],
                            ),
                          ),
                          Tab(
                            icon: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.star, size: 20),
                                SizedBox(width: 8),
                                Text("Yorumlar"),
                              ],
                            ),
                          ),
                        ],
                        labelColor: Theme.of(context).colorScheme.primary,
                        unselectedLabelColor: Theme.of(context).colorScheme.secondary,
                        indicatorColor: Theme.of(context).colorScheme.primary,

                        labelStyle: AppTextStyles.medium,
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    // Posts Tab
                    BlocBuilder<PostCubit, PostState>(
                      builder: (context, state) {
                        if (state is PostsLoaded) {
                          final userPosts = state.posts
                              .where((post) => post.userId == widget.uid)
                              .toList();

                          return _buildPostsGrid(userPosts);
                        } else if (state is PostsLoading) {
                          return Center(child: CircularProgressIndicator());
                        } else {
                          return Center(child: Text("No posts yet"));
                        }
                      },
                    ),

                    // Reviews Tab
                    _buildReviewsTab(),
                  ],
                ),
              ),
            ),
          );
        } else if (state is ProfileLoading) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        } else {
          return const Scaffold(
            body: Center(child: Text("Kullanıcı profili yok")),
          );
        }
      },
    );
  }
}