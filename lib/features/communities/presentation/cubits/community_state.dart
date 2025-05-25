class CommunityState {
  final List<Map<String, dynamic>> communities;
  final Map<String, bool> membershipStatus;
  final bool isLoading;

  CommunityState({
    required this.communities,
    required this.membershipStatus,
    this.isLoading = false,
  });

  CommunityState copyWith({
    List<Map<String, dynamic>>? communities,
    Map<String, bool>? membershipStatus,
    bool? isLoading,
  }) {
    return CommunityState(
      communities: communities ?? this.communities,
      membershipStatus: membershipStatus ?? this.membershipStatus,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}