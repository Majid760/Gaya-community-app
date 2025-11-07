import '../enums/dynamic_link_type.dart';

class GayaSocialTag {
  final String? title;
  final String? description;
  final String? pictureURL;
  final DynamicLinkType type;

  GayaSocialTag({this.title, this.description, this.pictureURL, this.type = DynamicLinkType.idle});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'pictureURL': pictureURL,
      'type': type.name,
    };
  }
}

class DynamicLinkConstants {
  static const String shareCommunityPost = "Shared a post";
  static const String shareChatGroupLink = "Shared a group chat";
  static const String communityInvite = "Invited you to join a community";
  static const String shareCommunityProfile = "Shared a community";
  static const String userProfile = "Shared a profile";

  //Secret Community invitation
  static String invitedToSecretCommunity({required String userName}) => "$userName invited you to a secret community";
  static String joinSecretCommunityDescription({required String communityName}) => "Join a secret community $communityName on Gaya";

  static String inviteMessage({required String userName, required String communityName, required String url}) =>
      "$userName invited you to join $communityName community on Gaya with the link below \n\n $url";
}
