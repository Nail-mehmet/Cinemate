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

class CommunitiesPage extends StatelessWidget {
  const CommunitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

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

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.communities.length,
              itemBuilder: (context, index) {
                final community = state.communities[index];
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