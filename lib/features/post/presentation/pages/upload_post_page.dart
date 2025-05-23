/*import 'dart:io';
import 'dart:typed_data';
import 'package:debounce_throttle/debounce_throttle.dart';
import "package:flutter/foundation.dart" show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nail/features/auth/domain/entities/app_user.dart';
import 'package:nail/features/post/domain/entities/post.dart';
import 'package:nail/features/post/presentation/cubits/post_cubit.dart';
import 'package:nail/features/post/presentation/cubits/post_states.dart';
import 'package:nail/features/search/data/firebase_search_repo.dart';

import '../../../auth/presentation/cubits/auth_cubits.dart';
import '../../../movies/domain/entities/movie.dart';
import '../../../movies/search/movie_tile.dart';

class UploadPostPage extends StatefulWidget {
  const UploadPostPage({super.key});

  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {
  XFile? imagePickedFile;
  Uint8List? webImage;
  final textController = TextEditingController();
  AppUser? currentUser;
  String? selectedCategory;
  Movie? selectedMovie;
  List<Movie> searchResults = [];
  bool isSearching = false;
  final searchController = TextEditingController();
  final Debouncer _debouncer =
      Debouncer(const Duration(milliseconds: 500), initialValue: null);

  // List of categories
  final List<String> categories = [
    'Film Önerisi',
    'Manitayla İzlemelik',
    'Başyapıt',
    'Klasik',
    'Yerli Film',
    'Yabancı Film',
    'Animasyon',
    'Bilim Kurgu',
    'Korku',
    'Komedi'
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

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
  }

  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) {
        debugPrint("Resim seçilmedi.");
        return;
      }

      setState(() {
        imagePickedFile = pickedFile;

        if (kIsWeb) {
          pickedFile.readAsBytes().then((bytes) {
            setState(() {
              webImage = bytes;
            });
          });
        }
      });
    } catch (e) {
      debugPrint("Resim seçerken hata oluştu: $e");
    }
  }

  void uploadPost() {
    if (imagePickedFile == null ||
        textController.text.isEmpty ||
        selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Resim, başlık ve kategori seçilmeli")),
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
      relatedMovieId: selectedMovie!.id
          .toString(), // Seçilen film varsa ID'sini kaydediyoruz
      relatedMovieTitle:
          selectedMovie?.title, // Film başlığını da kaydedebiliriz
    );

    final postCubit = context.read<PostCubit>();

    if (kIsWeb) {
      postCubit.createPost(newPost, imageBytes: webImage);
    } else {
      postCubit.createPost(newPost, imagePath: imagePickedFile!.path);
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostCubit, PostState>(
      builder: (context, state) {
        if (state is PostsLoading || state is PostsUploading) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return buildUploadPage();
      },
      listener: (context, state) {
        if (state is PostsLoaded) {
          Navigator.pop(context);
        }
      },
    );
  }

  Widget buildUploadPage() {
    return Scaffold(
        appBar: AppBar(
          title: Text("Post Oluştur"),
          foregroundColor: Theme.of(context).colorScheme.primary,
          actions: [
            IconButton(onPressed: uploadPost, icon: Icon(Icons.upload)),
          ],
        ),
        body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(children: [
              if (kIsWeb && webImage != null)
                Container(
                  margin: EdgeInsets.only(bottom: 16),
                  child: Image.memory(webImage!,
                      height: 300, width: double.infinity, fit: BoxFit.cover),
                ),
              if (!kIsWeb && imagePickedFile != null)
                Container(
                  margin: EdgeInsets.only(bottom: 16),
                  child: Image.file(File(imagePickedFile!.path),
                      height: 300, width: double.infinity, fit: BoxFit.cover),
                ),
              MaterialButton(
                onPressed: pickImage,
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Text("Resim Seç",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 20),
              _buildTextField(),
              SizedBox(height: 16),
              _buildCategoryDropdown(),
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: 'İlgili filmi ara',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () => searchMovies(searchController.text),
                  ),
                ),
                onChanged: (value) {
                  _debouncer.value = value;
                },
                onSubmitted: searchMovies,
              ),

              // Arama sonuçları yükleniyor gösterimi
              if (isSearching) CircularProgressIndicator(),

              // Arama sonuçları listesi
              if (searchResults.isNotEmpty)
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 300),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics:
                        AlwaysScrollableScrollPhysics(), // Kaydırma davranışını garanti altına al
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final movie = searchResults[index];
                      return SizedBox(
                        height: 80, // Burada yüksekliği sabitliyoruz
                        child: MovieTile(
                          movie: movie,
                          isSelected: selectedMovie?.id == movie.id,
                          onTap: () => selectMovie(movie),
                          posterWidth: 50,
                          posterHeight: 80,
                        ),
                      );
                    },
                  ),
                ),
              if (selectedMovie != null)
                Column(
                  children: [
                    SizedBox(height: 16),
                    Text('Seçilen Film',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    if (selectedMovie != null)
                      Dismissible(
                        key: Key(selectedMovie!.id.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 30),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          setState(() {
                            selectedMovie = null;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Film seçimi kaldırıldı")),
                          );
                        },
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            //color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: MovieTile(
                            movie: selectedMovie!,
                            posterWidth: 100,
                            posterHeight: 160,
                            bigTile: false,
                          ),
                        ),
                      ),
                  ],
                ),
            ])));
  }

  Widget _buildTextField() {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 6),
        ],
      ),
      child: TextField(
        controller: textController,
        maxLines: 5,
        minLines: 3,
        style: TextStyle(
            fontSize: 16, color: Theme.of(context).colorScheme.primary),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Başlık...",
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 6),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: selectedCategory,
        hint: Text('Kategori Seçin', style: TextStyle(color: Colors.grey)),
        items: categories.map((String category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Text(category,
                style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedCategory = newValue;
          });
        },
        decoration: InputDecoration(
          border: InputBorder.none,
        ),
        isExpanded: true,
      ),
    );
  }
}*/
/*import 'dart:io';
import 'dart:typed_data';
import "package:flutter/foundation.dart" show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nail/features/auth/domain/entities/app_user.dart';
import 'package:nail/features/auth/presentation/components/my_text_field.dart';
import 'package:nail/features/post/domain/entities/post.dart';
import 'package:nail/features/post/presentation/cubits/post_cubit.dart';
import 'package:nail/features/post/presentation/cubits/post_states.dart';

import '../../../auth/presentation/cubits/auth_cubits.dart';

class UploadPostPage extends StatefulWidget {
  const UploadPostPage({super.key});

  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {
  // mobile image pick
  PlatformFile? imagePickedFile;

  Uint8List? webImage;

  final textController = TextEditingController();

  AppUser? currentUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getCurrentUser();
  }

  void getCurrentUser() async {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
  }

  Future<void> pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: kIsWeb, // Web için gerekli
      );

      if (result == null || result.files.isEmpty) {
        debugPrint("Resim seçilmedi.");
        return;
      }

      setState(() {
        imagePickedFile = result.files.first;

        if (kIsWeb) {
          webImage = imagePickedFile!.bytes;
        }
      });
    } catch (e) {
      debugPrint("Resim seçerken hata oluştu: $e");
    }
  }

// create & upload post

  void uploadPost() {
    if (imagePickedFile == null || textController.text.isNotEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Resim ve başlık oldurulmalı")));
      return;
    }

    final newPost = Post(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: currentUser!.uid,
        userName: currentUser!.name,
        text: textController.text,
        imageUrl: "",
        timeStamp: DateTime.now());

    // post cubit
    final postCubit = context.read<PostCubit>();

    // web upload
    if (kIsWeb) {
      postCubit.createPost(newPost, imageBytes: imagePickedFile?.bytes);
    }

    // mobile upload
    else {
      postCubit.createPost(newPost, imagePath: imagePickedFile?.path);
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostCubit, PostState>(
        builder: (context, state) {
          if (state is PostsLoading || state is PostsUploading) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return buildUploadPage();
        },
        listener: (context, state) {
          if(state is PostsLoaded){
            Navigator.pop(context);
          }
        });
  }

  Widget buildUploadPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Post Oluştur"),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Column(
          children: [
            // image prewie for web
            if (kIsWeb && webImage != null) Image.memory(webImage!),
            // image preview for mobile,

            if (!kIsWeb && imagePickedFile != null)
              Image.file(File(imagePickedFile!.path!)),

            // pick image button
            MaterialButton(
              onPressed: pickImage,
              color: Colors.blue,
              child: Text("Resim Seç"),
            ),

            MyTextField(
                controller: textController,
                hintText: "Başlık",
                obscureText: false),
          ],
        ),
      ),
    );
  }
}
*/