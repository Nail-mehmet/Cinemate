abstract class CommunityEvent {}

class LoadCommunities extends CommunityEvent {}

class ToggleMembership extends CommunityEvent {
  final String communityId;
  final bool isMember;

  ToggleMembership(this.communityId, this.isMember);
}
