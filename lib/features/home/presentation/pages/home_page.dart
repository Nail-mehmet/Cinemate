import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:Cinemate/features/auth/domain/entities/app_user.dart';
import 'package:Cinemate/features/auth/presentation/cubits/auth_cubits.dart';
import 'package:Cinemate/features/home/presentation/components/my_drawer.dart';
import 'package:Cinemate/features/home/presentation/pages/post_detail_page.dart';
import 'package:Cinemate/features/post/presentation/cubits/post_cubit.dart';
import 'package:Cinemate/features/post/presentation/pages/photo_selection_page.dart';
import 'package:Cinemate/themes/font_theme.dart';

import '../../../post/presentation/components/post_preview_card.dart';
import '../../../post/presentation/cubits/post_states.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final postCubit = context.read<PostCubit>();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _horizontalscrollController = ScrollController();
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
  String? selectedCategory;
  AppUser? currentUser;

  @override
  void initState() {
    super.initState();
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    fetchAllPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      postCubit.fetchAllPosts(loadMore: true);
    }
  }

  void fetchAllPosts() {
    postCubit.fetchAllPosts();
  }

  void filterByCategory(String? category) {
  setState(() {
    selectedCategory = category == 'Tümü' ? null : category;
  });
  postCubit.filterByCategory(selectedCategory);

  // Scroll işlemini bir sonraki frame'e erteliyoruz
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_horizontalscrollController.hasClients) {
      final index = categories.indexOf(category!);
      final itemWidth = 100; // Yaklaşık item genişliği
      final screenWidth = MediaQuery.of(context).size.width;
      final offset = (index * (itemWidth + 16)) - (screenWidth / 2) + (itemWidth / 2);
      
      // Maksimum scroll sınırını kontrol ediyoruz
      final maxScroll = _horizontalscrollController.position.maxScrollExtent;
      final adjustedOffset = offset.clamp(0.0, maxScroll);

      _horizontalscrollController.animateTo(
        adjustedOffset,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gönderiler",style: AppTextStyles.bold,),
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PhotoSelectionPage(),
                )),
            icon: Icon(Icons.add),
            
          )
        ],
      ),
      body: Column(
        children: [
          // Kategori Tab'ları
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              controller: _horizontalscrollController,
              itemCount: categories.length,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category ||
                    (category == 'Tümü' && selectedCategory == null);

                return AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: EdgeInsets.only(right: 8, top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.2),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            )
                          ]
                        : null,
                  ),
                  child: Material(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => filterByCategory(category),
                      splashColor:
                          Theme.of(context).primaryColor.withOpacity(0.2),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(12),
                         /* border: Border.all(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade200,
                            width: 1.5,
                          ),*/
                        ),
                        child: Center(
                          child: Text(
                            category,
                            style: AppTextStyles.regular.copyWith(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.tertiary
                                  : Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Post Listesi
          Expanded(
            child: BlocBuilder<PostCubit, PostState>(
              builder: (context, state) {
                if (state is PostsLoading && state is! PostsLoaded) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is PostsLoaded) {
                  final posts = state.posts;

                  if (posts.isEmpty) {
                    return const Center(
                      child: Text("Mevcut Post yok"),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<PostCubit>().fetchAllPosts();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: MasonryGridView.count(
                        controller: _scrollController,
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        itemCount: posts.length + (state.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= posts.length) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final post = posts[index];
                          final isLiked = post.likes.contains(currentUser?.uid ?? "");

                          return PostCard(
                            post: post,
                            onDeletePressed: () async {
                              // Silme onay dialog'u göster
                              final shouldDelete = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title:  Text('Postu Sil',style: AppTextStyles.bold,),
                                  content:  Text('Bu postu silmek istediğinize emin misiniz?',style: AppTextStyles.medium,),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child:  Text('İptal',style: AppTextStyles.medium,),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child:  Text('Sil', style: AppTextStyles.bold.copyWith(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );

                              if (shouldDelete == true) {
                                // PostCubit üzerinden silme işlemi yap
                                context.read<PostCubit>().deletePost(post.id);
                              }
                            },
                            isLiked: isLiked,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PostDetailPage(
                                    post: post,
                                    onDeletePressed: () {
                                      context.read<PostCubit>().deletePost(post.id);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  );
                } else if (state is PostsError) {
                  return Center(child: Text(state.message));
                } else {
                  return const SizedBox();
                }
              },
            ),

          ),
        ],
      ),
    );
  }
}
