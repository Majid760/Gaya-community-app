import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import '../../../../components/button.component.dart';
import '../../../../components/check_for_app_update.dart';
import '../../../../components/share_on_your_story_button.dart';
import '../../../../components/skeleton.post.component.dart';
import '../../../../controller/firebase_analytics_controller.dart';
import '../../../../controller/gaya_shared_controller.dart';
import '../../../../controller/homepage.controller.dart';
import '../../../../generated/assets.dart';
import '../../../../model/community.model.dart';
import '../../../../model/user.model.dart';
import '../../../../routing/getx_route_methods.dart';
import '../../../../services/services.dart';
import '../../../../shared/service/dynamic_link_service/enums/dynamic_link_type.dart';
import '../../../../shared/service/dynamic_link_service/model/gaya_social_tag.dart';
import '../../../../shared/service/dynamic_link_service/utils/dynamic_link_utils.dart';
import '../../../../shared/view/widget/gaya_back_button.dart';
import '../../../../shared/view/widget/gaya_snackbar.dart';
import '../../../../utils/const.dart';
import '../../../../utils/gaya_text_widget.dart';
import '../../../../utils/helper/helper.functions.dart';
import '../../../../utils/language/translation.dart';
import '../../../../utils/logger.dart';
import '../../../../utils/textstyles.dart';
import '../../../../utils/theme/app_colors.dart';
import '../../../../widgets/home_view_widgets/your.friends.widget.dart';

class InviteFriendsScreen extends StatefulWidget {
  const InviteFriendsScreen({super.key});

  @override
  State<InviteFriendsScreen> createState() => _InviteFriendsScreenState();
}

class _InviteFriendsScreenState extends State<InviteFriendsScreen> {
  /* -------------------------------------------------------------------------- */
  /*                               STATE VARIABLES                              */
  /* -------------------------------------------------------------------------- */
  late final Community community;
  late final HomePageController homeController;
  late final Services services;

  /* -------------------------------------------------------------------------- */
  /*                               LIFECYCLE API'S                              */
  /* -------------------------------------------------------------------------- */
  @override
  void initState() {
    super.initState();
    // Get the community from the getX route arguments.
    community = (Get.arguments["community"] as Community);
    // Get the home controller from the provider.
    homeController = Provider.of<HomePageController>(context, listen: false);
    // Creating a service instance.
    services = Services.to;
  }

  @override
  Widget build(BuildContext context) {
    /* -------------------------------------------------------------------------- */
    /*                                Main Scaffold                               */
    /* -------------------------------------------------------------------------- */
    return Scaffold(
      backgroundColor: kWhiteColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: kBlackColor),
        elevation: 0,
        backgroundColor: kWhiteColor,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: const GayaBackButton(),
        title: Text(GayaStrings.invite_Friends.tr, style: GayaTypography.titleMedium),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0.w, vertical: 16.0.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /* -------------------------- Spread the word text -------------------------- */
            Text(
              GayaStrings.spread_the_word.tr,
              style: GayaTypography.titleSemiBold,
            ),
            SizedBox(height: 8.0.h),
            /* -------------------- Spread the word description text -------------------- */
            Align(
              alignment:
                  context.read<HomePageController>().isRTL(GayaStrings.spread_the_word.tr) ? Alignment.centerRight : Alignment.centerLeft,
              child: GayaTextWidget(GayaStrings.spread_the_word_desc.tr),
            ),
            SizedBox(height: 8.0.h),
            /* ---------------------------- Search text field --------------------------- */
            CupertinoSearchTextField(
              autocorrect: false,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6).r,
              controller: homeController.searchFriendsController,
              placeholder: GayaStrings.search_user.tr,
              onChanged: homeController.searchFriendsFunc,
            ),
            SizedBox(height: 12.0.h),
            Expanded(
              child: FutureBuilder<List<UserModel>?>(
                future: services.getMyAllFriends(),
                builder: (context, snapshot) {
                  /* ------------------------------ WAITING STATE ----------------------------- */
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
                  /* ---------------------------- DATA LOADED STATE --------------------------- */
                  if (snapshot.hasData) {
                    final allFriends = snapshot.data;

                    // Checking all friends list is not empty or null
                    if (allFriends?.isEmpty == true) {
                      return Center(child: Text(GayaStrings.no_user_found.tr, style: CustomTypography.body2DisableStyle));
                    }

                    // Removing the current user from the list
                    allFriends!.removeWhere((element) => element.uId == UserModel.to.uId);

                    // Adding the friends list to the home controller
                    context.read<HomePageController>()
                      ..allFriends.clear()
                      ..addUsersInAllFriends(allFriends);

                    return Consumer<HomePageController>(
                      builder: (context, homepageController, _) {
                        return Builder(
                          builder: (context) {
                            if (homepageController.searchFriends.isEmpty && homeController.isSearchModeOn == true) {
                              return Center(
                                child: Text(GayaStrings.no_user_found.tr, style: CustomTypography.body2DisableStyle),
                              );
                            } else if (homeController.isSearchModeOn == true) {
                              return FriendsListSearchModalWidget(
                                lastMessage: GayaStrings.shared_community.tr,
                                friend: homeController.searchFriends,
                                homeController: homepageController,
                                messageType: MessageType.community,
                                postId: community.communityId ?? '',
                                community: community,
                              );
                            } else {
                              return FriendsListModalWidget(
                                lastMessage: GayaStrings.shared_community.tr,
                                friend: allFriends,
                                homeController: homepageController,
                                messageType: MessageType.community,
                                postId: community.communityId ?? '',
                                community: community,
                              );
                            }
                          },
                        );
                      },
                    );
                  }

                  /* -------------------------------- ELSE CASE ------------------------------- */
                  return Center(child: Text(GayaStrings.no_user_found.tr, style: CustomTypography.body2Style));
                },
              ),
            ),
            SizedBox(height: 12.0.h),
            Row(
              children: [
                /* ---------------------------- Copy link button ---------------------------- */
                Expanded(child: _CopyLinkButton(community: community)),
                SizedBox(width: 12.0.w),
                /* ---------------------------- Share link button --------------------------- */
                Expanded(child: _ShareButton(community: community)),
              ],
            ),
            SizedBox(height: 12.0.h),
            /* ----------- share on your story button [ShareOnYourStoryButton] ---------- */
            if (GayaRemoteConfig.to.isShowInstagramShareStory) const ShareOnYourStoryButton(isCommunity: true),
            SizedBox(height: 12.0.h),
            /* ----------------------- Send sms invitation button ----------------------- */
            _SendSMSInvitationButton(community: community),
          ],
        ),
      ),
    );
  }
}

/// Send SMS Invitation Button for sending the link to other apps
class _SendSMSInvitationButton extends StatelessWidget {
  const _SendSMSInvitationButton({
    required this.community,
  });

  final Community community;

  @override
  Widget build(BuildContext context) {
    return buttonIcon(
      height: 40.0.h,
      borderColor: kTransparentColor,
      primaryColor: AppColors.primary,
      title: GayaStrings.send_sms_invitation.tr,
      iconString: Assets.iconsInvite,
      icon: null,
      textStyle: CustomTypography.body4StyleWhite,
      onPressed: () async {
        if (community.communityId != null) {
          Routes.openInvitePermission(
            communityId: community.communityId!,
          );
        }
      },
    );
  }
}

/// Share Button for sharing the link to other apps
class _ShareButton extends StatelessWidget {
  const _ShareButton({
    required this.community,
  });

  final Community community;

  @override
  Widget build(BuildContext context) {
    return buttonIcon(
      height: 40.0.h,
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
        queryParam = community.queryParams;
        tag = DynamicLinkUtils.generateTagCommunity(community: community);
        type = DynamicLinkType.communityInvite;

        /// Engagement Score
        EngagementScoreController.to.instance.onShare(communityId: community.communityId ?? "");
        MyLoggerServices.to.print("Shareable link is ${community.queryParams}");
        final shareAbleLink = await GayaSharedController.to.createAShareableLink(queryParam: queryParam, tag: tag, type: type);
        if (shareAbleLink != null) {
          await Share.share(shareAbleLink);
        }

        // logging share event
        AnalyticsController.to.instance.logShare(
          contentType: 'community',
          itemId: community.communityId ?? '',
          userId: UserModel.to.uId ?? '',
          platform: 'social_media',
        );
      },
    );
  }
}

/// Copy Link Button for copying the link to clipboard
class _CopyLinkButton extends StatelessWidget {
  const _CopyLinkButton({
    required this.community,
  });

  final Community community;

  @override
  Widget build(BuildContext context) {
    return buttonIcon(
      height: 40.0.h,
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
        queryParam = community.queryParams;
        tag = DynamicLinkUtils.generateTagCommunity(community: community);
        type = DynamicLinkType.communityInvite;
        final shareAbleLink = await GayaSharedController.to.createAShareableLink(
          queryParam: queryParam,
          tag: tag,
          type: type,
        );
        Clipboard.setData(ClipboardData(text: shareAbleLink ?? ""));
        MyLoggerServices.to.print("Shareable link is $shareAbleLink");

        // ignore: use_build_context_synchronously
        GayaSnackBar.show(context: context, type: GayaSnackBarType.link, text: GayaStrings.copied_to_clipboard.tr);

        // logging share event
        AnalyticsController.to.instance.logShare(
          contentType: 'community',
          itemId: community.communityId ?? '',
          userId: UserModel.to.uId ?? '',
          platform: 'copy_link',
        );
      },
    );
  }
}
