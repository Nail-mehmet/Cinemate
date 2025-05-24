/*import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'community_event.dart';
import 'community_state.dart';

class CommunityBloc extends Bloc<CommunityEvent, CommunityState> {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  CommunityBloc({required this.firestore, required this.auth})
      : super(CommunityState(communities: [], membershipStatus: {}, isLoading: true)) {
    on<LoadCommunities>(_onLoadCommunities);
    on<ToggleMembership>(_onToggleMembership);
  }

  Future<void> _onLoadCommunities(LoadCommunities event, Emitter<CommunityState> emit) async {
    emit(state.copyWith(isLoading: true));
    final snapshot = await firestore.collection('communities').get();

    Map<String, bool> membershipStatus = {};

    for (var doc in snapshot.docs) {
      final isMember = await _checkIfMember(doc.id);
      membershipStatus[doc.id] = isMember;
    }

    emit(state.copyWith(
      communities: snapshot.docs,
      membershipStatus: membershipStatus,
      isLoading: false,
    ));
  }
  Future<bool> toggleMembership(String communityId, bool isMember) async {
  final user = auth.currentUser;
  if (user == null) return false;

  final communityRef = firestore.collection('communities').doc(communityId);
  final memberRef = communityRef.collection('members').doc(user.uid);

  await firestore.runTransaction((transaction) async {
    final communityDoc = await transaction.get(communityRef);
    final currentCount = communityDoc['membersCount'] ?? 0;

    if (isMember) {
      transaction.delete(memberRef);
      transaction.update(communityRef, {'membersCount': currentCount - 1});
    } else {
      transaction.set(memberRef, {
        'userId': user.uid,
        'joinedAt': FieldValue.serverTimestamp(),
      });
      transaction.update(communityRef, {'membersCount': currentCount + 1});
    }
  });

  // Üyelik durumu localde güncelle
  final updatedStatus = Map<String, bool>.from(state.membershipStatus);
  updatedStatus[communityId] = !isMember;

  final updatedCommunities = await firestore.collection('communities').get();

  emit(state.copyWith(
    communities: updatedCommunities.docs,
    membershipStatus: updatedStatus,
  ));

  return !isMember; // True dönerse katılma oldu, false ise ayrılma
}


  Future<void> _onToggleMembership(ToggleMembership event, Emitter<CommunityState> emit) async {
    final user = auth.currentUser;
    if (user == null) return;

    final communityRef = firestore.collection('communities').doc(event.communityId);
    final memberRef = communityRef.collection('members').doc(user.uid);

    await firestore.runTransaction((transaction) async {
      final communityDoc = await transaction.get(communityRef);
      final currentCount = communityDoc['membersCount'] ?? 0;

      if (event.isMember) {
        transaction.delete(memberRef);
        transaction.update(communityRef, {'membersCount': currentCount - 1});
      } else {
        transaction.set(memberRef, {
          'userId': user.uid,
          'joinedAt': FieldValue.serverTimestamp(),
        });
        transaction.update(communityRef, {'membersCount': currentCount + 1});
      }
    });

    add(LoadCommunities());
  }

  Future<bool> _checkIfMember(String communityId) async {
    final user = auth.currentUser;
    if (user == null) return false;

    final doc = await firestore
        .collection('communities')
        .doc(communityId)
        .collection('members')
        .doc(user.uid)
        .get();

    return doc.exists;
  }
}
*/