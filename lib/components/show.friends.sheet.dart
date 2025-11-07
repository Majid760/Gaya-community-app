// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/components/check_for_app_update.dart';
import 'package:gaya/components/skeleton.post.component.dart';
import 'package:gaya/controller/firebase_analytics_controller.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/model/create.post.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/services/services.dart';
import 'package:gaya/shared/service/dynamic_link_service/model/gaya_social_tag.dart';
import 'package:gaya/shared/service/dynamic_link_service/utils/dynamic_link_utils.dart';
import 'package:gaya/shared/view/widget/gaya_snackbar.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:gaya/utils/helper/helper.functions.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/logger.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_spaces.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import '../controller/gaya_shared_controller.dart';
import '../controller/homepage.controller.dart';
import '../model/user.model.dart';
import '../shared/service/dynamic_link_service/enums/dynamic_link_type.dart';
import '../shared/service/message_service/message_service.dart';
import '../utils/const.dart';
import '../utils/textstyles.dart';
import '../view/chat/controllers/chat_controller.dart';
import '../widgets/home_view_widgets/search.friends.widget.dart';
import '../widgets/home_view_widgets/your.friends.widget.dart';
import 'share_on_your_story_button.dart';

void showMyFriendsSheets({required BuildContext context, required Function(UserModel?) onUserTap}) {
  showModalBottomSheet(
      context: context,
      enableDrag: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(13.0), topRight: Radius.circular(13.0))),
      builder: (context) {
        return WillPopScope(
            onWillPop: () async {
              // homeController.searchFriendsController.clear();
              // homeController.isSearchModeOn = false;
              return true;
            },
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
              child: SizedBox(
                height: 350.h,
                child: SearchFriendView(onUserTap: (user) async => onUserTap(user), showTrailingIcon: true),
              ),
            ));
      });
}

// search friend view
class SearchFriendView extends StatefulWidget {
  const SearchFriendView({Key? key, this.onUserTap, required this.showTrailingIcon}) : super(key: key);
  final Function(UserModel?)? onUserTap;
  final bool showTrailingIcon;

  @override
  State<SearchFriendView> createState() => _SearchFriendViewState();
}

class _SearchFriendViewState extends State<SearchFriendView> {
  final Debouncer _debouncer = Debouncer(delay: 400.milliseconds);
  TextEditingController textController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<HomePageController>(builder: (context, homeController, __) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(height: 4, width: 40, decoration: const BoxDecoration(color: kBaseGrey)),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20).r,
              child: CupertinoSearchTextField(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6).r,
                  placeholder: GayaStrings.search_user.tr,
                  controller: textController,
                  onSuffixTap: () {
                    textController.clear();
                    homeController.fetchUsers('a');
                  },
                  onChanged: (query) async {
                    _debouncer.call(() {
                      homeController.fetchUsers(query.trim().isEmpty ? 'a' : query);
                    });
                  },
                  prefixIcon: SvgIconWidget.searchLgOutline(color: AppColors.secondary, height: 20.h)),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: homeController.isLoading
                  ? const Column(
                      children: [
                        UserListTileSkeleton(),
                        UserListTileSkeleton(),
                        UserListTileSkeleton(),
                      ],
                    )
                  : homeController.searchedUser.isNotEmpty
                      ? SearchFriendListView(
                          users: homeController.searchedUser,
                          onUserTap: (user) async => await widget.onUserTap!(user),
                          showTrailingIcon: widget.showTrailingIcon)
                      : Center(
                          child: Text(
                            GayaStrings.no_user_found.tr,
                          ),
                        ),
            )
          ],
        );
      }),
    );
  }
}

Future<QuerySnapshot<Object?>?> getUserFriends({required BuildContext context}) {
  final homeController = Provider.of<HomePageController>(context, listen: false);
  var strm = homeController.myFriendsOrInterestBaseOrRandomUsers();
  return strm;
}

Services services = Services();

/// * Item either be Post or community
void showModalToSendItem(
  BuildContext parentContext,
  String id,
  String lastMessage, {
  required MessageType messageType,
  Post? post,
  Community? community,
}) {
  final homeController = Provider.of<HomePageController>(parentContext, listen: false);
  final getFreindsQUery = services.getMyAllFriends();
  showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(13.0), topRight: Radius.circular(13.0))),
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            homeController.searchFriendsController.clear();
            homeController.isSearchModeOn = false;
            return true;
          },
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(left: 20, right: 20, bottom: MediaQuery.viewInsetsOf(context).bottom),
              child: SizedBox(
                height: 500.h, // 350,

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(height: 4, width: 40, decoration: const BoxDecoration(color: kBaseGrey)),
                    if (community != null) const SizedBox(height: 10),
                    if (community != null)
                      SizedBox(
                        height: 42,
                        child: buttonIcon(
                            // height: 36,
                            borderColor: kTransparentColor,
                            primaryColor: AppColors.primary,
                            title: GayaStrings.send_sms_invitation.tr,
                            iconString: "Assets/icons/invite.svg",
                            icon: null,
                            textStyle: CustomTypography.body4StyleWhite,
                            onPressed: () async {
                              Get.back();
                              print('community is: $community');
                              if (community.communityId != null) {
                                Routes.openInvitePermission(
                                  communityId: community.communityId!,
                                );
                              } else {}
                            }),
                      ),
                    if (community != null) const SizedBox(height: 12),
                    if (community != null)
                      IntrinsicHeight(
                        child: Row(
                          children: [
                            const Expanded(
                              child: Divider(thickness: 2, color: kBaseGrey),
                            ),
                            const SizedBox(width: 8),
                            Text("OR", style: CustomTypography.secondaryFontStyle),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Divider(thickness: 2, color: kBaseGrey),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    CupertinoSearchTextField(
                      autocorrect: false,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6).r,
                      controller: homeController.searchFriendsController,
                      placeholder: GayaStrings.search_user.tr,
                      onChanged: homeController.searchFriendsFunc,
                    ),
                    const SizedBox(height: 12),
                    Consumer<HomePageController>(builder: (context, seachfriends, _) {
                      return Expanded(
                        child: FutureBuilder<List<UserModel>?>(
                            future: getFreindsQUery,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                                  child: Column(
                                    children: [
                                      UserListTileSkeleton(),
                                      UserListTileSkeleton(),
                                      UserListTileSkeleton(),
                                    ],
                                  ),
                                );
                              }
                              final allFriends = snapshot.data;
                              try {
                                if (allFriends?.isNotEmpty == true) {
                                  allFriends?.removeWhere((element) => element.uId == UserModel.to.uId);
                                }
                              } catch (_) {}
                              if (allFriends == null) {
                                return const SizedBox.shrink();
                              }
                              return Builder(builder: (context) {
                                seachfriends.allFriends.clear();
                                for (var user in allFriends) {
                                  seachfriends.allFriends.add(user);
                                }
                                if (seachfriends.searchFriends.isEmpty && homeController.isSearchModeOn == true) {
                                  return Center(child: Text(GayaStrings.no_search_found.tr, style: CustomTypography.body2DisableStyle));
                                } else if (homeController.isSearchModeOn == true) {
                                  return FriendsListSearchModalWidget(
                                      lastMessage: lastMessage,
                                      friend: homeController.searchFriends,
                                      homeController: seachfriends,
                                      messageType: messageType,
                                      postId: id,
                                      post: post,
                                      community: community);
                                } else {
                                  return FriendsListModalWidget(
                                      lastMessage: lastMessage,
                                      friend: allFriends,
                                      homeController: seachfriends,
                                      messageType: messageType,
                                      postId: id,
                                      post: post,
                                      community: community);
                                }
                              });
                            }),
                      );
                    }),
                    SizedBox(
                      height: 120.h,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: buttonIcon(
                                  height: 40,
                                  borderColor: kTransparentColor,
                                  primaryColor: AppColors.primary,
                                  title: GayaStrings.copy_txt.tr,
                                  iconString: "Assets/icons/outline.svg",
                                  icon: null,
                                  textStyle: CustomTypography.titleStyleWhite,
                                  onPressed: () async {
                                    String queryParam = "";
                                    GayaSocialTag? tag;
                                    late DynamicLinkType type;
                                    if (post != null) {
                                      queryParam = post.queryParams;
                                      tag = DynamicLinkUtils.generateTagPost(post: post);
                                      type = DynamicLinkType.shareCommunityPost;
                                    } else if (community != null) {
                                      queryParam = community.queryParams;
                                      tag = DynamicLinkUtils.generateTagCommunity(community: community);
                                      type = DynamicLinkType.communityInvite;
                                    }
                                    final shareAbleLink = await GayaSharedController.to.createAShareableLink(
                                      queryParam: queryParam,
                                      tag: tag,
                                      type: type,
                                    );
                                    Clipboard.setData(ClipboardData(text: shareAbleLink ?? ""));
                                    MyLoggerServices.to.print("Shareable link is $shareAbleLink");

                                    GayaSnackBar.show(
                                        context: context, type: GayaSnackBarType.link, text: GayaStrings.copied_to_clipboard.tr);
                                    Navigator.pop(context);

                                    // logging share event
                                    AnalyticsController.to.instance.logShare(
                                      contentType: post == null ? 'community' : 'post',
                                      itemId: post == null ? community?.communityId ?? '' : post.postid ?? '',
                                      userId: UserModel.to.uId ?? '',
                                      platform: 'copy_link',
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: MySpaces.gap3.w),
                              Expanded(
                                child: buttonIcon(
                                  height: 40.h,
                                  borderColor: kTransparentColor,
                                  primaryColor: kBaseGrey,
                                  title: GayaStrings.share_txt.tr,
                                  iconString: "",
                                  icon: CupertinoIcons.arrow_turn_up_right,
                                  textStyle: CustomTypography.dark12,
                                  onPressed: () async {
                                    String queryParam = "";
                                    GayaSocialTag? tag;
                                    late DynamicLinkType type;
                                    if (post != null) {
                                      queryParam = post.queryParams;
                                      tag = DynamicLinkUtils.generateTagPost(post: post);
                                      type = DynamicLinkType.shareCommunityPost;
                                    } else if (community != null) {
                                      queryParam = community.queryParams;
                                      tag = DynamicLinkUtils.generateTagCommunity(community: community);
                                      type = DynamicLinkType.communityInvite;
                                    }

                                    /// Engagement Score
                                    if (post != null) {
                                      EngagementScoreController.to.instance.onShare(postId: post.postid);
                                    } else {
                                      EngagementScoreController.to.instance.onShare(communityId: community?.communityId ?? "");
                                    }
                                    MyLoggerServices.to.print("Shareable link is ${community?.queryParams}");
                                    final shareAbleLink =
                                        await GayaSharedController.to.createAShareableLink(queryParam: queryParam, tag: tag, type: type);
                                    if (shareAbleLink != null) {
                                      await Share.share(shareAbleLink);
                                    }
                                    Navigator.pop(context);

                                    // logging share event
                                    AnalyticsController.to.instance.logShare(
                                      contentType: post == null ? 'community' : 'post',
                                      itemId: post == null ? community?.communityId ?? '' : post.postid ?? '',
                                      userId: UserModel.to.uId ?? '',
                                      platform: 'social_media',
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: MySpaces.gap3.w),
                          /* ----------- share on your story button [ShareOnYourStoryButton] ---------- */
                          if (GayaRemoteConfig.to.isShowInstagramShareStory) const ShareOnYourStoryButton(isCommunity: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      });
}

/// returns true if user can send a message
///
/// A Gateway to check if user can send a message or not
Future<bool> _canSendMessage(UserModel user, BuildContext ctx) async {
  final error = await MessageUtils.canSendAMessage(user: user);
  if (error != null) {
    GayaSnackBar.show(context: ctx, text: error, type: GayaSnackBarType.error);
    return false;
  }

  return true;
}

/// * Item either be Post or community
void showModalToSendItem2(
  BuildContext parentContext,
  String id,
  String lastMessage, {
  required MessageType messageType,
  Post? post,
  Community? community,
}) {
  final homeController = Provider.of<HomePageController>(parentContext, listen: false);

  homeController.fetchUsers('a');
  showModalBottomSheet(
    context: parentContext,
    isScrollControlled: true,
    enableDrag: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(13.0), topRight: Radius.circular(13.0))),
    builder: (context) {
      return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
          child: SizedBox(
            height: 500.h, // 350,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Expanded(
                  child: SearchFriendView(
                      onUserTap: (user) async {
                        if (user != null) {
                          String type = messageType == MessageType.community ? 'community' : 'post';
                          if (GayaRemoteConfig.to.isConnectyCubeEnabled) {
                            bool canSend = await _canSendMessage(user, context);

                            /// if user can't send a message then return
                            if (!canSend) return;
                            await ChatController.to().helperFunc.createNewChatAndSendMessage(
                                context, user.uId ?? '', post?.postid ?? "", type,
                                attachmentData: post?.postid ?? "", post: post, community: community);
                          } else {
                            await MessageUtils.sendAPostMessage(user, context: context, onPostShare: () {
                              HelperFunc().sendMessageAsPostOrCommunity(user.uId ?? "", post?.postid ?? "", context, lastMessage);
                            });
                          }
                        }
                      },
                      showTrailingIcon: false),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20).r,
                  child: SizedBox(
                    height: 120,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: buttonIcon(
                                height: 40.h,
                                borderColor: kTransparentColor,
                                primaryColor: AppColors.primary,
                                title: GayaStrings.copy_txt.tr,
                                iconString: "Assets/icons/outline.svg",
                                icon: null,
                                textStyle: CustomTypography.titleStyleWhite,
                                onPressed: () async {
                                  String queryParam = "";
                                  GayaSocialTag? tag;
                                  late DynamicLinkType type;
                                  print(post);
                                  if (post != null) {
                                    queryParam = post.queryParams;
                                    tag = DynamicLinkUtils.generateTagPost(post: post);
                                    type = DynamicLinkType.shareCommunityPost;
                                  } else if (community != null) {
                                    queryParam = community.queryParams;
                                    tag = DynamicLinkUtils.generateTagCommunity(community: community);
                                    type = DynamicLinkType.communityInvite;
                                  }
                                  final shareAbleLink =
                                      await GayaSharedController.to.createAShareableLink(queryParam: queryParam, tag: tag, type: type);
                                  Clipboard.setData(ClipboardData(text: shareAbleLink ?? ""));
                                  MyLoggerServices.to.print("Shareable link is $shareAbleLink");

                                  GayaSnackBar.show(
                                      context: context, type: GayaSnackBarType.link, text: GayaStrings.copied_to_clipboard.tr);
                                  Navigator.pop(context);

                                  // logging share event
                                  AnalyticsController.to.instance.logShare(
                                    contentType: post == null ? 'community' : 'post',
                                    itemId: post == null ? community?.communityId ?? '' : post.postid ?? '',
                                    userId: UserModel.to.uId ?? '',
                                    platform: 'copy_link',
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: MySpaces.gap3.w),
                            Expanded(
                                child: buttonIcon(
                                  height: 40.h,
                              borderColor: kTransparentColor,
                              primaryColor: kBaseGrey,
                              title: GayaStrings.share_txt.tr,
                              iconString: "",
                              icon: CupertinoIcons.arrow_turn_up_right,
                              textStyle: CustomTypography.dark12,
                              onPressed: () async {
                                String queryParam = "";
                                GayaSocialTag? tag;
                                late DynamicLinkType type;
                                if (post != null) {
                                  queryParam = post.queryParams;
                                  tag = DynamicLinkUtils.generateTagPost(post: post);
                                  type = DynamicLinkType.shareCommunityPost;
                                } else if (community != null) {
                                  queryParam = community.queryParams;
                                  tag = DynamicLinkUtils.generateTagCommunity(community: community);
                                  type = DynamicLinkType.communityInvite;
                                }

                                /// Engagement Score
                                if (post != null) {
                                  EngagementScoreController.to.instance.onShare(postId: post.postid);
                                } else {
                                  EngagementScoreController.to.instance.onShare(communityId: community?.communityId ?? "");
                                }
                                MyLoggerServices.to.print("Shareable link is ${community?.queryParams}");
                                final shareAbleLink =
                                    await GayaSharedController.to.createAShareableLink(queryParam: queryParam, tag: tag, type: type);
                                if (shareAbleLink != null) {
                                  await Share.share(shareAbleLink);
                                }
                                Navigator.pop(context);

                                // logging share event
                                AnalyticsController.to.instance.logShare(
                                  contentType: post == null ? 'community' : 'post',
                                  itemId: post == null ? community?.communityId ?? '' : post.postid ?? '',
                                  userId: UserModel.to.uId ?? '',
                                  platform: 'social_media',
                                );
                              },
                            )),
                          ],
                        ),
                        SizedBox(height: MySpaces.gap3.w),
                        /* ----------- share on your story button [ShareOnYourStoryButton] ---------- */
                        if (GayaRemoteConfig.to.isShowInstagramShareStory) const ShareOnYourStoryButton(isCommunity: false),
                        SizedBox(height: MySpaces.gap3.r),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
