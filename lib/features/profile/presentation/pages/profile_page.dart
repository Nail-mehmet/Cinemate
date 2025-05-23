/*import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nail/features/auth/domain/entities/app_user.dart';
import 'package:nail/features/auth/presentation/cubits/auth_cubits.dart';
import 'package:nail/features/chat/presentation/cubits/chat_cubit.dart';
import 'package:nail/features/movies/presentation/pages/movie_detail_page.dart';
import 'package:nail/features/post/presentation/cubits/post_cubit.dart';
import 'package:nail/features/post/presentation/cubits/post_states.dart';
import 'package:nail/features/profile/presentation/components/follow_button.dart';
import 'package:nail/features/profile/presentation/components/message_button.dart';
import 'package:nail/features/profile/presentation/components/movie_stats.dart';
import 'package:nail/features/profile/presentation/components/profile_stats.dart';
import 'package:nail/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:nail/features/profile/presentation/cubits/profile_states.dart';
import 'package:nail/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nail/features/profile/presentation/pages/follower_page.dart';
import 'package:nail/features/search/presentation/pages/search_page.dart';
import 'package:nail/features/settings/pages/settings_page.dart';
import 'package:nail/themes/font_theme.dart';
import 'package:http/http.dart' as http;
import '../../../chat/presentation/pages/chat_page.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late final authCubit = context.read<AuthCubit>();
  late final profileCubit = context.read<ProfileCubit>();
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  bool _showExtendedBio = false;

  List<int> topThreeMovies = [];
  List<int> favoriteMovies = [];
  List<int> watchedMovies = [];
  List<int> savedMovies = [];

  // current user
  late AppUser? currentUser = authCubit.currentUser;

  int postCount = 0;
  int watchedMoviesCount = 0;
  int favoriteMoviesCount = 0;
  int savedMoviesCount = 0;

  @override
  void initState() {
    super.initState();
    profileCubit.fetchUserProfile(widget.uid);
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
  // setState kullanmadan sadece gerekli değişiklikleri yap
  _showExtendedBio = !_showExtendedBio;
  if (_showExtendedBio) {
    _animationController.forward();
  } else {
    _animationController.reverse();
  }
  // Sadece bio bölümünü yenilemek için
  setState(() {});
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
          color: Theme.of(context).colorScheme.background,
          height: MediaQuery.of(context).size.height * 0.9,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Poppins"
                ),
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
    final url = Uri.parse('https://api.themoviedb.org/3/movie/$movieId?api_key=$apiKey');

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
                      imageUrl: 'https://image.tmdb.org/t/p/w500$posterPath',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.grey),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
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
                placeholder: (context, url) => Container(color: Colors.grey),
                errorWidget: (context, url, error) => const Icon(Icons.error),
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
      SizedBox(height: 10,),
      Text(
        "En İyi Üçleme",
        style: AppTextStyles.semiBold.copyWith(color: Theme.of(context).colorScheme.primary,fontSize: 20)
      ),
      SizedBox(
        height: 220,
        child: Row(
          children: displayMovies.asMap().entries.map((entry) {
            final index = entry.key;
            final movieId = entry.value;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: movieId != null
                    ? _buildMovieItem(movieId, aspectRatio: 2 / 3)
                    : isOwnProfile
                        ? _buildEmptyTopMoviePlaceholder()
                        : const SizedBox(), // başkasının profilinde boş kutu gösterme
              ),
            );
          }).toList(),
        ),
      ),
      const SizedBox(height: 20),
    ],
  );
}


Widget _buildEmptyTopMoviePlaceholder() {
  return GestureDetector(
    onTap: () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage()));
      // Film ekleme sayfasına yönlendirme yapılabilir
    },
    child: Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(
            child: Icon(Icons.add, size: 40, color: Colors.grey),
          ),
          Text("En iyi üçlemeni tamamla", style: AppTextStyles.medium.copyWith(color: Theme.of(context).colorScheme.inversePrimary, fontSize: 12),)
        ],
      ),
    ),
  );
}

  Widget _buildMovieCollectionSection(String title, List<int> movies) {
    if (movies.isEmpty) return SizedBox();

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
                onPressed: () => _showAllMoviesBottomSheet(title, movies),
                child: Text("Tümünü Gör"),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 110, // Daha küçük boyut
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: SizedBox(
                  width: 65, // Daha küçük genişlik
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

  Future<void> _refreshProfileData() async {
  try {
    // Bloc üzerinden verileri yeniden çek
    await context.read<ProfileCubit>().fetchUserProfile(widget.uid!);
    
    // Ekstra film verilerini de yenile (opsiyonel)
    await Future.wait([
      _loadAllMovieCollections(),
      _loadTopThreeMovies(),
    ]);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Yenileme başarısız: ${e.toString()}")),
    );
    rethrow; // RefreshIndicator'ın animasyonunu sıfırlaması için
  }
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
                title: Text(user.name, style: AppTextStyles.semiBold),
                actions: [
                  if (isOwnPost)
                    IconButton(
                      icon: Icon(Icons.settings),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsPage(),
                          ),
                        );
                      },
                    ),
                ],
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      color: Theme.of(context).colorScheme.tertiary,
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                CachedNetworkImageProvider(user.profileImageUrl),
                          ),
                          SizedBox(height: 10),
                          Text(
                            user.name,
                            style: AppTextStyles.regular.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 22),
                          ),
                          SizedBox(height: 10),
                          ProfileStats(
                            postCount: postCount,
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
                              if (isOwnPost) // KENDİ PROFİLİ
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditProfilePage(user: user),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    foregroundColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                  child: Text("Profili Düzenle"),
                                ),
            
                              // BAŞKA KULLANICI PROFİLİ
                              Row(
                                children: [
                                  if (!isOwnPost)
                                    FollowButton(
                                      onPressed: followButtonPressed,
                                      isFollowing: user.followers
                                          .contains(currentUser!.uid),
                                    ),
                                  if (!isOwnPost)
                                    MessageButton(
                                      onPressed: () async {
                                        final currentUserId = currentUser!.uid;
                                        final otherUserId = user.uid;
                                        try {
                                          await context
                                              .read<ChatCubit>()
                                              .startNewChat(
                                                currentUserId: currentUserId,
                                                otherUserId: otherUserId,
                                                currentUserName:
                                                    currentUser!.name,
                                                currentUserAvatar:
                                                    "currentUser!.profileImageUrl",
                                                otherUserName: user.name,
                                                otherUserAvatar:
                                                    user.profileImageUrl,
                                              );
                                          final chatState =
                                              context.read<ChatCubit>().state;
                                          if (chatState is ChatStarted) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ChatPage(
                                                  chatId: chatState.chatId,
                                                  otherUserName: user.name,
                                                ),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Sohbet başlatılamadı: $e')),
                                          );
                                        }
                                      },
                                    ),
                                  SizedBox(width: 10),
                                  IconButton(
                                    icon: Icon(
                                      _showExtendedBio
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    onPressed: _toggleExtendedBio,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizeTransition(
                            sizeFactor: _heightAnimation,
                            child: Column(
                              children: [
                                SizedBox(height: 20),
                                //if (!isOwnPost) // Sadece başka kullanıcıda film istatistikleri göster
                                  MovieStats(
                                    watchedCount: watchedMoviesCount,
                                    favoriteCount: favoriteMoviesCount,
                                    savedCount: savedMoviesCount,
                                  ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: Container(
                                    width: double.infinity, // Tüm genişliği kapla
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start, // Sola hizala
                                      children: [
                                        Text(
                                          "Bio",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                          textAlign:
                                              TextAlign.left, // Metni sola hizala
                                        ),
                                        SizedBox(height: 5),
                                        Container(
                                          width: double
                                              .infinity, // Tüm genişliği kapla
                                          child: Text(
                                            user.bio,
                                            style: AppTextStyles.italic
                                                .copyWith(fontSize: 13),
                                            textAlign: TextAlign
                                                .left, // Metni sola hizala
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
                   
                    _buildTopMoviesSection(isOwnPost),
                    
                    // Diğer koleksiyonlar (küçük ve yatay kaydırılabilir)
                    _buildMovieCollectionSection('Favori Filmler', favoriteMovies),
                    _buildMovieCollectionSection('İzlenen Filmler', watchedMovies),
                    _buildMovieCollectionSection('Kaydedilenler', savedMovies),
                      
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Posts",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SizedBox(height: 10),
                    BlocBuilder<PostCubit, PostState>(
                      builder: (context, state) {
                        if (state is PostsLoaded) {
                          final userPosts = state.posts
                              .where((post) => post.userId == widget.uid)
                              .toList();
                          postCount = userPosts.length;
            
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: GridView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: userPosts.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                childAspectRatio: 1,
                              ),
                              itemBuilder: (context, index) {
                                final post = userPosts[index];
                                return null;
                                /*PostTile(
                                  post: post,
                                  onDeletePressed: isOwnPost
                                      ? () => context
                                          .read<PostCubit>()
                                          .deletePost(post.id)
                                      : null,
                                );*/
                              },
                            ),
                          );
                        } else if (state is PostsLoading) {
                          return Center(child: CircularProgressIndicator());
                        } else {
                          return Center(child: Text("Post yok"));
                        }
                      },
                    ),
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
}*/