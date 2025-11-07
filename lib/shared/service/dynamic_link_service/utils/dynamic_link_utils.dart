import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/model/create.post.model.dart';

import '../../../../model/user.model.dart';
import '../enums/dynamic_link_type.dart';
import '../model/gaya_social_tag.dart';

class DynamicLinkUtils {
  /// * Check if community id is involved in dynamic link
  bool isCommunityIdInvolved(DynamicLinkType type) =>
      type == DynamicLinkType.shareCommunityPost ||
      type == DynamicLinkType.shareCommunityProfile ||
      type == DynamicLinkType.communityInvite;

  DynamicLinkType getDynamicLinkType(String? type) {
    if (type == null) return DynamicLinkType.idle;
    if (type == "shareCommunityPost") return DynamicLinkType.shareCommunityPost;
    if (type == "communityInvite") return DynamicLinkType.communityInvite;
    if (type == "shareCommunityProfile") return DynamicLinkType.shareCommunityProfile;
    if (type == "userProfile") return DynamicLinkType.userProfile;
    if (type == "groupChat") return DynamicLinkType.groupChat;

    return DynamicLinkType.idle;
  }

  static GayaSocialTag? generateTagPost({required Post? post}) {
    return GayaSocialTag(
      pictureURL: post?.multipleImages?.isNotEmpty ?? false ? post?.multipleImages?.first : post?.community.CommunityPic,
      title: post?.postedBy.name ?? DynamicLinkConstants.shareCommunityPost,
      description: post?.postDescription,
    );
  }

  static GayaSocialTag? generateTagGroupChat({required String? userName, required CubeDialog? groupChatModel}) {
    return GayaSocialTag(
      pictureURL: groupChatModel?.photo,
      title: groupChatModel?.name ?? DynamicLinkConstants.shareChatGroupLink,
      description: userName,
    );
  }

  static GayaSocialTag? generateTagCommunity({required Community? community, bool isSecretCommunity = false}) {
    if (isSecretCommunity) {
      return GayaSocialTag(
        title: DynamicLinkConstants.invitedToSecretCommunity(userName: UserModel.to.name ?? "Gaya User"),
        description: DynamicLinkConstants.joinSecretCommunityDescription(communityName: community?.communityName ?? "Gaya Community"),
        type: DynamicLinkType.communityInvite,
        pictureURL:
            "https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/images%2Fapp_images%2Fpurple_color.png?alt=media&token=ab3af66c-e156-4f8e-b606-92753628ae98",
      );
    }
    return GayaSocialTag(
      pictureURL: community?.CommunityPic,
      title: community?.communityName,
      description: community?.communityDescription,
    );
  }
}
