/*import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Cinemate/features/communities/domain/entities/community_post_model.dart';
import 'package:Cinemate/features/communities/presentation/components/community_post_card.dart';
import 'package:Cinemate/features/communities/presentation/cubits/commune_bloc.dart';
import 'package:Cinemate/features/communities/presentation/cubits/commune_event.dart';
import 'package:Cinemate/features/communities/presentation/cubits/commune_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Cinemate/features/profile/presentation/components/user_tile.dart';
import 'package:Cinemate/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:Cinemate/themes/font_theme.dart';

class CommunityDetailPage extends StatefulWidget {
  final String communityId;
  final String currentUserId;
  final String communityName;

  const CommunityDetailPage({
    required this.communityId,
    required this.currentUserId,
    required this.communityName,
  });

  @override
  _CommunityDetailPageState createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends State<CommunityDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  File? _selectedImage;
  final _textController = TextEditingController();
  bool _isFabOpen = false;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _hasMorePosts = true;
  final int _postsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<CommuneBloc>().add(LoadCommunes(
          communityId: widget.communityId,
          limit: _postsPerPage,
        ));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore &&
        _hasMorePosts) {
      _loadMorePosts();
    }
  }

  void _loadMorePosts() {
    final state = context.read<CommuneBloc>().state;
    if (state is CommuneLoaded && state.communes.isNotEmpty) {
      final oldestPost = state.communes.last;
      _isLoadingMore = true;
      context.read<CommuneBloc>().add(LoadCommunes(
            communityId: widget.communityId,
            limit: _postsPerPage,
            lastFetched: oldestPost,
          ));
    }
  }

  Widget _buildFab() {
    if (_tabController.index != 0) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isFabOpen) ...[
          FloatingActionButton.extended(
            heroTag: "textPost",
            onPressed: () {
              setState(() => _isFabOpen = false);
              _showTextPostSheet();
            },
            icon: const Icon(Icons.text_fields),
            label: const Text("Metin Gönder"),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: "imagePost",
            onPressed: () {
              setState(() => _isFabOpen = false);
              _showImagePostSheet();
            },
            icon: const Icon(Icons.image),
            label: const Text("Fotoğraf Gönder"),
          ),
          const SizedBox(height: 10),
        ],
        FloatingActionButton(
          onPressed: () {
            setState(() => _isFabOpen = !_isFabOpen);
          },
          child: Icon(_isFabOpen ? Icons.close : Icons.add),
        ),
      ],
    );
  }

  void _showTextPostSheet() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          top: 24,
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.35,
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _textController,
                      maxLines: 8,
                      decoration: InputDecoration(
                        hintText: 'Bir şeyler yaz...',
                        filled: true,
                        fillColor: Colors.grey,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      final commune = Commune(
                        id: '',
                        text: _textController.text,
                        userId: widget.currentUserId,
                        createdAt: DateTime.now(),
                      );
                      context.read<CommuneBloc>().add(CreateCommune(
                            communityId: widget.communityId,
                            commune: commune,
                          ));
                      Navigator.pop(context);
                      _textController.clear();
                    },
                    child: const Text(
                      'Paylaş',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white),
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


  void _showImagePostSheet() async {
  final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
  setState(() {
    _selectedImage = picked != null ? File(picked.path) : null;
  });

  if (_selectedImage == null) return;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          top: 24,
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          _selectedImage!,
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _textController,
                      maxLines: 8,
                      decoration: InputDecoration(
                        hintText: 'Bir şeyler yaz...',
                        filled: true,
                        fillColor: Colors.grey,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      final commune = Commune(
                        id: '',
                        text: _textController.text,
                        userId: widget.currentUserId,
                        createdAt: DateTime.now(),
                      );
                      context.read<CommuneBloc>().add(CreateCommune(
                            communityId: widget.communityId,
                            commune: commune,
                            image: _selectedImage,
                          ));
                      Navigator.pop(context);
                      _textController.clear();
                    },
                    child: const Text(
                      'Paylaş',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white),
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.communityName,
          style: AppTextStyles.bold,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: Theme.of(context).colorScheme.tertiary,
              ),
              child: TabBar(
                controller: _tabController,
                onTap: (index) {
                  setState(() {
                    _isFabOpen = false;
                  });
                },
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black54,
                tabs: const [
                  Tab(text: 'Gönderiler'),
                  Tab(text: 'Üyeler'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          BlocConsumer<CommuneBloc, CommuneState>(
            listener: (context, state) {
              if (state is CommuneLoaded) {
                _isLoadingMore = false;
                _hasMorePosts = state.hasMore;
              }
            },
            builder: (context, state) {
              if (state is CommuneLoading && state.communes.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is CommuneError) {
                return Center(child: Text(state.message));
              }
              if (state is CommuneLoaded) {
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        reverse: true, // This makes newest appear at bottom
                        itemCount: state.communes.length + (_hasMorePosts ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= state.communes.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          return CommuneCard(
                            post: state.communes[index],
                            currentUserId: widget.currentUserId,
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
              return const Center(child: Text('Bir hata oluştu.'));
            },
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('communities')
                .doc(widget.communityId)
                .collection('members')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('Henüz üye yok.'));
              }

              final memberIds =
                  snapshot.data!.docs.map((doc) => doc.id).toList();
              return ListView.builder(
                itemCount: memberIds.length,
                itemBuilder: (context, index) {
                  final uid = memberIds[index];
                  return FutureBuilder(
                    future: context.read<ProfileCubit>().getUserProfile(uid),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final user = snapshot.data!;
                        return UserTile(user: user);
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const ListTile(
                          title: Text("Yükleniyor..."),
                        );
                      } else {
                        return const ListTile(
                          title: Text("Kullanıcı bulunamadı"),
                        );
                      }
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: _buildFab(),
    );
  }
}*/