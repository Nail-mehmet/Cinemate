import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'community_event.dart';
import 'community_state.dart';

class CommunityBloc extends Bloc<CommunityEvent, CommunityState> {
  final SupabaseClient supabase;

  CommunityBloc({required this.supabase})
      : super(CommunityState(communities: [], membershipStatus: {}, isLoading: true)) {
    on<LoadCommunities>(_onLoadCommunities);
    on<ToggleMembership>(_onToggleMembership);
  }

  Future<void> _onLoadCommunities(LoadCommunities event, Emitter<CommunityState> emit) async {
    emit(state.copyWith(isLoading: true));

    final response = await supabase
        .from('communities')
        .select('*');

    Map<String, bool> membershipStatus = {};

    for (var community in response) {
      final isMember = await _checkIfMember(community['id']);
      membershipStatus[community['id']] = isMember;
    }

    emit(state.copyWith(
      communities: response,
      membershipStatus: membershipStatus,
      isLoading: false,
    ));
  }

  Future<bool> toggleMembership(String communityId, bool isMember) async {
    final user = supabase.auth.currentUser;
    if (user == null) return false;

    try {
      if (isMember) {
        // Üyelikten çıkma işlemi
        await supabase
            .from('community_members')
            .delete()
            .eq('community_id', communityId)
            .eq('user_id', user.id);

        // Üye sayısını azalt
        await supabase.rpc('decrement_member_count', params: {
          'community_id': communityId,
        });
      } else {
        // Üyelik ekleme işlemi
        await supabase
            .from('community_members')
            .insert({
          'community_id': communityId,
          'user_id': user.id,
          'joined_at': DateTime.now().toIso8601String(),
        });

        // Üye sayısını artır
        await supabase.rpc('increment_member_count', params: {
          'community_id': communityId,
        });
      }

      // Güncel topluluk listesini al
      final updatedCommunities = await supabase
          .from('communities')
          .select('*');

      // Üyelik durumu localde güncelle
      final updatedStatus = Map<String, bool>.from(state.membershipStatus);
      updatedStatus[communityId] = !isMember;

      emit(state.copyWith(
        communities: updatedCommunities,
        membershipStatus: updatedStatus,
      ));

      return !isMember; // True dönerse katılma oldu, false ise ayrılma
    } catch (e) {
      print('Membership toggle error: $e');
      return isMember; // Hata durumunda eski durumu koru
    }
  }

  Future<void> _onToggleMembership(ToggleMembership event, Emitter<CommunityState> emit) async {
    final result = await toggleMembership(event.communityId, event.isMember);
    if (result != event.isMember) {
      add(LoadCommunities());
    }
  }

  Future<bool> _checkIfMember(String communityId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return false;

    final response = await supabase
        .from('community_members')
        .select()
        .eq('community_id', communityId)
        .eq('user_id', user.id);

    return response.isNotEmpty;
  }
}