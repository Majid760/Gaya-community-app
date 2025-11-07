enum PostCreationFrom { Home, Community, FeedDetail, CommunityCreation, postReply,vibe,poll }

enum HomepageSwitch { home, message, groups, notifications, profile }

enum groupDetailsSwitch { About, Discussion, Recipe, Event }

enum createRecipeEnum { one, two }

enum communityType { Public, Private, Secret }

enum CreateCommunityViewEnum { CommunityView1, CommunityView2, CommunityView3, CommunityView4, CommunityView5 }

enum CrownRouteEnum { home, group, savePost, postWithComments }

enum ConnectionStatus {
  online,
  offline,
}

enum FriendshipStatus {
  addFriend,
  unFriend,
  acceptRequest,
  requestSent,
}

/// enum for search type (In search screen)
enum SearchType {
  top,
  communities,
  posts,
  people,
}

/// enum for community joined status
enum CommunityJoiningStatus {
  joined,
  waitingForApproval,
  notJoined,
}
