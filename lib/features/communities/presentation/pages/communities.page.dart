import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Cinemate/features/communities/presentation/components/community_card.dart';
import 'package:Cinemate/features/communities/presentation/cubits/community_bloc.dart';
import 'package:Cinemate/features/communities/presentation/cubits/community_event.dart';
import 'package:Cinemate/features/communities/presentation/cubits/community_state.dart';
import 'package:Cinemate/features/communities/presentation/pages/community_detail_page.dart';
import 'package:Cinemate/themes/font_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/presentation/cubits/auth_cubits.dart';
import '../../../auth/presentation/cubits/auth_states.dart';
import '../../../premium/pages/subscriptions_page.dart';
import '../../../profile/presentation/cubits/profile_cubit.dart';
import '../../../profile/presentation/cubits/profile_states.dart';

class CommunitiesPage extends StatefulWidget {
  final VoidCallback? onGoToFirstTab;
  const CommunitiesPage({super.key, this.onGoToFirstTab});

  @override
  State<CommunitiesPage> createState() => _CommunitiesPageState();
}

class _CommunitiesPageState extends State<CommunitiesPage> with SingleTickerProviderStateMixin{
  final supabase = Supabase.instance.client;
  bool? isPremium;
  String? currentUserId;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserData();
/*_shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeOut,
    ));*/

  }
  /*
  void _showPremiumRequiredDialog() {
    // Animasyonu başlat
    _shakeController.forward(from: 0);

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_shakeAnimation.value * (1 - (_shakeAnimation.value / 10)), 0),
            child: Transform.rotate(
              angle: _shakeAnimation.value * 0.01,
              child: child,
            ),
          );
        },
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star_rounded,
                  size: 60,
                  color: Colors.amber,
                ),
                const SizedBox(height: 20),
                Text(
                  "Premium ile Sınırları Aş!",
                  style: AppTextStyles.bold.copyWith(fontSize: 20)
                ),
                const SizedBox(height: 10),
                Text(
                  "Sadece Premium üyeler özel film topluluklarına katılabilir.\nSen de favori filmlerin hakkında konuş, analizler yap, öneriler al!",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.regular.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          if (widget.onGoToFirstTab != null) {
                            widget.onGoToFirstTab!();
                          }
                        },
                        child: Text("Sonra",style: AppTextStyles.bold,),
                      ),


                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Önce mevcut sayfadan çık, sonra yeni sayfaya git
                          Navigator.of(context).pop(); // Mevcut sayfayı kapat
                          Future.delayed(Duration.zero, () { // Microtask ile sıraya al
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PremiumSubscriptionPage(),
                              ),
                            );
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                        ),
                        child: Text("Premium Ol",style: AppTextStyles.bold.copyWith(fontSize: 12),),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

*/
  void _loadUserData() {
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      setState(() {
        currentUserId = authState.user.uid;
      });
      context.read<ProfileCubit>().fetchUserProfile(currentUserId!).then((_) {
        final profileState = context.read<ProfileCubit>().state;
        if (profileState is ProfileLoaded) {
          setState(() {
            isPremium = profileState.profileUser.isPremium;

            /*if (isPremium == false) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Future.delayed(Duration(microseconds: 100), () {
                  _showPremiumRequiredDialog();
                });
              });
            }*/
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {


    return BlocProvider(
      create: (_) => CommunityBloc(
        supabase: supabase,
      )..add(LoadCommunities()),
      child: Scaffold(
        body: BlocBuilder<CommunityBloc, CommunityState>(
          builder: (context, state) {
            if (state.isLoading && state.communities.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.communities.isEmpty) {
              return const Center(child: Text('Topluluk bulunamadı'));
            }
            final displayedCommunities = [...state.communities]
              ..sort((a, b) => a['created_at'].compareTo(b['created_at']));

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.communities.length,
              itemBuilder: (context, index) {
                final community = displayedCommunities[index];
                final communityId = community['id'];
                final name = community['name'];
                final imageUrl = community['image_url'];
                final membersCount = community['members_count'] ?? 0;
                final isMember = state.membershipStatus[communityId] ?? false;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: CommunityCard(
                    name: name,
                    membersCount: membersCount,
                    isMember: isMember,
                    imageUrl: imageUrl,
                    onJoin: () async {
                      final joinNoti = community['join_noti'] ?? 'Topluluğa katıldınız';
                      final leaveNoti = community['leave_noti'] ?? 'Topluluktan ayrıldınız';

                      final result = await context
                          .read<CommunityBloc>()
                          .toggleMembership(communityId, isMember);

                      final title = result
                          ? (!isMember ? 'Merhaba!' : 'Bilgi')
                          : 'Üzgünüz';
                      final message = result
                          ? (!isMember ? joinNoti : leaveNoti)
                          : leaveNoti;
                      final contentType = result
                          ? (!isMember ? ContentType.success : ContentType.warning)
                          : ContentType.failure;

                      final snackBar = SnackBar(
                        elevation: 0,
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.transparent,
                        content: AwesomeSnackbarContent(
                            title: title,
                            message: message,
                            contentType: contentType,
                            messageTextStyle: AppTextStyles.bold.copyWith(color: Colors.white)
                        ),
                      );

                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(snackBar);

                      // İlk defa katılıyorsa detay sayfasına yönlendir
                      if (!isMember && result) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CommunityDetailPage(
                              communityId: communityId,
                              currentUserId: supabase.auth.currentUser?.id ?? '',
                              communityName: name,
                            ),
                          ),
                        );
                      }
                    },
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CommunityDetailPage(
                            communityId: communityId,
                            currentUserId: supabase.auth.currentUser?.id ?? '',
                            communityName: name,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}