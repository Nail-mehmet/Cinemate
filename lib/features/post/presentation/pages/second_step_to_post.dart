import 'dart:io';
import 'dart:typed_data';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:Cinemate/features/auth/domain/entities/app_user.dart';
import 'package:Cinemate/features/auth/presentation/cubits/auth_cubits.dart';
import 'package:Cinemate/features/movies/domain/entities/movie.dart';
import 'package:Cinemate/features/movies/search/movie_tile.dart';
import 'package:Cinemate/features/post/domain/entities/post.dart';
import 'package:Cinemate/features/post/presentation/cubits/post_cubit.dart';
import 'package:Cinemate/features/post/presentation/cubits/post_states.dart';
import 'package:Cinemate/features/search/data/firebase_search_repo.dart';
import 'package:Cinemate/themes/font_theme.dart';

class PostDetailsPage extends StatefulWidget {
  final String? imagePath;
  final Uint8List? webImage;

  const PostDetailsPage({
    super.key,
    this.imagePath,
    this.webImage,
  });

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  final textController = TextEditingController();
  AppUser? currentUser;
  String? selectedCategory;
  Movie? selectedMovie;
  List<Movie> searchResults = [];
  bool isSearching = false;
  final searchController = TextEditingController();
  final Debouncer _debouncer =
      Debouncer(const Duration(milliseconds: 500), initialValue: '');
  bool _isSearchActive = false;
  final FocusNode _searchFocusNode = FocusNode();
  

  // Kategoriler
  final List<String> categories = [
    'Tümü',
    'Film Önerisi',
    'Sevgiliyle İzlemelik',
    'Başyapıt',
    'Klasik',
    'Yerli Film',
    'Yabancı Film',
    'Animasyon',
    'Bilim Kurgu',
    'Korku',
    'Komedi',
    "Kafa Dağıtmalık",
    "Gerçek Hikâyeden Uyarlama",
    "İlham Veren Filmler",
  ];

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    _debouncer.values.listen((query) {
      if (query.isNotEmpty) {
        searchMovies(query);
      } else {
        setState(() {
          searchResults = [];
        });
      }
    });
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
  }

  Future<void> searchMovies(String query) async {
    setState(() {
      isSearching = true;
    });

    try {
      final results = await FirebaseSearchRepo().searchMovie(query);
      setState(() {
        searchResults = results;
        isSearching = false;
      });
    } catch (e) {
      setState(() {
        isSearching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Film aranırken hata oluştu: $e")),
      );
    }
  }

  void selectMovie(Movie movie) {
    setState(() {
      selectedMovie = movie;
      searchController.clear();
      searchResults = [];
    });
  }

  void uploadPost() {
    if (textController.text.isEmpty || selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Başlık ve kategori seçilmeli")),
      );
      return;
    }

    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: currentUser!.uid,
      userName: currentUser!.name,
      text: textController.text,
      imageUrl: "",
      timeStamp: DateTime.now(),
      likes: [],
      comments: [],
      category: selectedCategory!,
      relatedMovieId: selectedMovie?.id.toString(),
      relatedMovieTitle: selectedMovie?.title,
    );

    final postCubit = context.read<PostCubit>();

    if (widget.webImage != null) {
      postCubit.createPost(newPost, imageBytes: widget.webImage);
    } else if (widget.imagePath != null) {
      postCubit.createPost(newPost, imagePath: widget.imagePath);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fotoğraf seçilmedi")),
      );
    }
  }

  @override
  void dispose() {
    textController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostCubit, PostState>(
      listener: (context, state) {
        if (state is PostsLoaded) {
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      },
      builder: (context, state) {
        if (state is PostsUploading) {
  return const Scaffold(
    body: Center(
      child: LottieWidget(), // Aşağıda tanımlanacak
    ),
  );
}


        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Post Detayları',
              style: AppTextStyles.semiBold,
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Seçilen fotoğraf önizlemesi
                if (widget.imagePath != null || widget.webImage != null)
                  Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: widget.webImage != null
                            ? MemoryImage(widget.webImage!)
                            : FileImage(File(widget.imagePath!))
                                as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                // Başlık metin alanı
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  child: TextField(
                    controller: textController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Açıklama Giriniz...', // Sadece hintText kullan
                      hintStyle:
                          AppTextStyles.medium.copyWith(color: Theme.of(context).colorScheme.primary), // Gri renkte yap
                      border: InputBorder.none, // Kenarlık yok
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      // Yani soldan 16, yukarıdan 12 boşluk veriyoruz → sol üstte olur
                    ),
                    style: TextStyle(fontSize: 16),
                  ),
                ),

                const SizedBox(height: 20),
                // Kategori seçimi
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: selectedCategory == null
                        ? 'Kategori'
                        : null, // Hide label when value selected
                    floatingLabelBehavior:
                        FloatingLabelBehavior.never, // Prevent floating label
                    hintText: selectedCategory == null
                        ? 'Kategori seçiniz'
                        : null, // Optional hint
                    labelStyle: AppTextStyles.regular,
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.tertiary,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 0, vertical: 14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 10),
                      child: Image.asset(
                        'assets/icons/list.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    prefixIconConstraints: BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                  dropdownColor: Theme.of(context).colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(12),
                  items: categories
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category, style: AppTextStyles.regular.copyWith(color: Theme.of(context).colorScheme.primary)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                  selectedItemBuilder: (BuildContext context) {
                    return categories.map<Widget>((String value) {
                      return Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          selectedCategory ?? '    Kategori',
                          style: AppTextStyles.medium.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      );
                    }).toList();
                  },
                ),

                const SizedBox(height: 20),
                // Film arama
                Row(
                  children: [
                    Expanded(
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: searchController,
                          focusNode: _searchFocusNode,
                          onTap: () {
                            setState(() {
                              _isSearchActive = true;
                            });
                          },
                          onChanged: (value) => _debouncer.value = value,
                          decoration: InputDecoration(
                            isDense: true, // Daha sıkı yerleşim
                            hintText: _isSearchActive
                                ? 'Film Ara...'
                                : 'İlgili filmi ara (isteğe bağlı)',
                            hintStyle: AppTextStyles.medium.copyWith(color: Theme.of(context).colorScheme.primary),
                            border: InputBorder.none,
                            prefixIcon: _isSearchActive
                                ? AnimatedSwitcher(
                                    duration: Duration(milliseconds: 300),
                                    transitionBuilder: (child, animation) =>
                                        ScaleTransition(
                                            scale: animation, child: child),
                                    child: Icon(Icons.search,
                                        key: ValueKey('search_active')),
                                  )
                                : null,
                            suffixIcon: AnimatedSwitcher(
                              duration: Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) =>
                                  ScaleTransition(
                                      scale: animation, child: child),
                              child: _isSearchActive
                                  ? IconButton(
                                      key: ValueKey('close_button'),
                                      icon: Icon(Icons.close),
                                      onPressed: () {
                                        setState(() {
                                          _isSearchActive = false;
                                          searchController.clear();
                                          FocusScope.of(context).unfocus();
                                        });
                                      },
                                    )
                                  : IconButton(
                                      key: ValueKey('search_button'),
                                      icon: Icon(Icons.search),
                                      onPressed: () {
                                        setState(() {
                                          _isSearchActive = true;
                                          FocusScope.of(context)
                                              .requestFocus(_searchFocusNode);
                                        });
                                      },
                                    ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Arama sonuçları
                if (isSearching)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                if (searchResults.isNotEmpty)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final movie = searchResults[index];
                        return MovieTile(
                          movie: movie,
                          isSelected: selectedMovie?.id == movie.id,
                          onTap: () => selectMovie(movie),
                          posterWidth: 50,
                          posterHeight: 80,
                        );
                      },
                    ),
                  ),
                // Seçilen film
                if (selectedMovie != null)
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      Text('Seçilen Film',
                          style: AppTextStyles.bold.copyWith(fontSize: 18)),
                      const SizedBox(height: 8),
                      Dismissible(
                        key: Key(selectedMovie!.id.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.red,
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => setState(() {
                          selectedMovie = null;
                        }),
                        child: MovieTile(
                          movie: selectedMovie!,
                          posterWidth: 100,
                          posterHeight: 150,
                        ),
                      ),
                    ],
                  ),
                SizedBox(
                  height: 25,
                ),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: uploadPost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primary, // Instagram blue
                      foregroundColor: Theme.of(context).colorScheme.tertiary,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      shadowColor: Colors.blue.withOpacity(0.3),
                    ),
                    child: Text(
                      "Paylaş",
                      style: AppTextStyles.bold.copyWith(
                        fontSize: 16,
                        letterSpacing: 0.5,
                        color: Theme.of(context).colorScheme.tertiary

                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class LottieWidget extends StatelessWidget {
  const LottieWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/lotties/uploading.json',
      width: 250,
      height: 250,
      fit: BoxFit.contain,
    );
  }
}