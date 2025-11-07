import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaya/components/profile_image_widget.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/view/community/controllers/community_profile_controller.dart';
import 'package:gaya/view/search.communities.view.dart';
import 'package:gaya/view/share/controllers/instagram_story_share_controller.dart';
import 'package:get/get.dart';
import 'package:linkwell/linkwell.dart';
import 'package:provider/provider.dart';

import '../components/custom_snackbars.dart';
import '../components/show.friends.sheet.dart';
import '../components/skeleton.post.component.dart';
import '../components/snackbar.component.dart';
import '../controller/app_config_controller.dart';
import '../controller/firebase_analytics_controller.dart';
import '../controller/group.controller.dart';
import '../controller/homepage.controller.dart';
import '../gen/assets.gen.dart';
import '../model/user.model.dart';
import '../routing/getx_route_methods.dart';
import '../scripts/delete_community_script.dart';
import '../shared/view/widget/custom_post_options_list_tile.dart';
import '../shared/view/widget/gaya_alert_dialog.dart';
import '../shared/view/widget/gaya_alertbox.dart';
import '../shared/view/widget/gaya_back_button.dart';
import '../shared/view/widget/gaya_report_dialog.dart';
import '../utils/asset_images.dart';
import '../utils/assets_icons.dart';
import '../utils/const.dart';
import '../utils/enum.dart';
import '../utils/helper/helper.functions.dart';
import '../utils/language/translation.dart';
import '../utils/methods.dart';
import '../utils/textstyles.dart';
import '../utils/theme/app_colors.dart';
import '../widgets/group_view_widget/approval.row.dart';
import 'community/controllers/community_editing_controller.dart';
import 'community/controllers/community_feed_controller.dart';
import 'community/views/community_view_feed.dart';
import 'share/models/community_insta_share.dart';

class GroupView extends StatefulWidget {
  final Community communityModel;

  const GroupView({Key? key, required this.communityModel}) : super(key: key);

  @override
  State<GroupView> createState() => _GroupViewState();
}

class _GroupViewState extends State<GroupView> {
  var getPosts;
  var isUserInCommunity;

  bool isLeaveCommunityButtonLoading = false;

  // late CommunityEditingController communityFeedController;
  late CommunityProfileController communityProfileController;
  late EditCommunityController editCommunityController;

  @override
  void initState() {
    editCommunityController = EditCommunityController.to(tag: widget.communityModel.communityId);
    communityProfileController = CommunityProfileController.to(tag: widget.communityModel.communityId);
    isLeaveCommunityButtonLoading = false;
    isUserInCommunity = context.read<GroupController>().isUserInCommunity(widget.communityModel.communityId!);

    // Logging view community event
    AnalyticsController.to.instance.logViewCommunity(
      communityId: widget.communityModel.communityId ?? '',
      userId: UserModel.to.uId ?? '',
    );

    super.initState();
  }

  @override
  void dispose() {
    String previousRoute = Get.previousRoute;

    if (previousRoute != '/commentWithPostScreen') {
      editCommunityController.resetState();
    }

    super.dispose();
  }

  ///
  /// Fetches the community from either CommunityProfileController || Widget.communityModel
  /// reason: when getting from post, the community might be outdated, so communityProfileController is
  /// always updated with the latest community
  ///
  Community get getCommunityModel {
    Community _community = widget.communityModel;
    bool isRegistered = CommunityProfileController.isRegistered(tag: widget.communityModel.communityId);
    if (isRegistered && CommunityProfileController.to(tag: widget.communityModel.communityId).communityModel != null) {
      _community = CommunityProfileController.to(tag: widget.communityModel.communityId).communityModel!;
    }
    return _community;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: kBlackColor),
        elevation: 0,
        backgroundColor: kWhiteColor,
        automaticallyImplyLeading: false,
        leading: const GayaBackButton(),
        title: GetBuilder<CommunityProfileController>(
            tag: widget.communityModel.communityId,
            autoRemove: false,
            init: communityProfileController,
            builder: (controller) {
              return Row(
                children: [
                  InkWell(
                    radius: 20,
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      // getDocsAccordingToTimeStamp();
                      //UnComment these line below when done testing
                      if (controller.communityModel?.CommunityPic != null || controller.communityModel?.CommunityPic.isBlank == false) {
                        Routes.openImages(urls: [controller.communityModel!.CommunityPic!], index: 0, ctx: context);
                      }
                    },
                    child: Hero(
                      tag: controller.communityModel!.CommunityPic ?? "",
                      child: CircleAvatar(
                          backgroundColor: kBaseGrey,
                          child: ProfileImageWidget(url: controller.communityModel?.CommunityPic, size: const Size(40, 40))),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: SizedBox(
                      child: Text(
                        controller.communityModel!.communityName ?? "",
                        style: CustomTypography.bodyStyle,
                        textDirection:
                            Methods.isRTL(controller.communityModel!.communityName ?? "") ? TextDirection.rtl : TextDirection.ltr,
                        maxLines: 2,
                      ),
                    ),
                  ),
                ],
              );
            }),
        actions: [
          IconButton(
              icon: SvgIconWidget.searchLgOutline(height: 20.h),
              // icon: const Icon(Icons.search),
              color: kBlackColor,
              onPressed: () {
                showCupertinoDialog(
                    context: context,
                    builder: (_) => SearchCommunities(
                        isCommunityUsersSearch: true, communityId: communityProfileController.communityModel?.communityId ?? ''));
              }),
          InkWell(
            onTap: () async {
              if (communityProfileController.communityModel?.communityType == 'Secret') {
                Routes.openInvitePermission(
                  communityId: communityProfileController.communityId,
                );
                // Routes.secretCommunityInvitationView(community: communityProfileController.communityModel);
              } else {
                context.read<HomePageController>().searchFriendsController.clear();
                context.read<HomePageController>().searchFriends.clear();
                if (FirebaseAuth.instance.currentUser?.uid == null) {
                } else {
                  context.read<HomePageController>().sentMessageUserIds.clear();
                  context.read<HomePageController>().isSend = false;

                  /// Getting communityProfileController to get [communityId] data
                  CommunityProfileController communityProfileController =
                      CommunityProfileController.to(tag: widget.communityModel.communityId);
                  // creating instance of CommunityInstaShare for share
                  CommunityInstaShare communityInstaShare = CommunityInstaShare(
                    communityName: communityProfileController.communityModel?.communityName ?? '',
                    communityDp: communityProfileController.communityModel?.CommunityPic,
                    communityCover: communityProfileController.communityModel?.coverPicture,
                    communityInfo: communityProfileController.communityModel?.communityDescription,
                    communityMembers: communityProfileController.communityModel?.communityMembers,
                    communityType: communityProfileController.communityModel?.communityType,
                    community: communityProfileController.communityModel,
                  );
                  // setting instaShare instance to communityInstaShare to share community
                  InstagramStoryShareController.instance.instaShare = communityInstaShare;

                  showModalToSendItem(
                    context,
                    communityProfileController.communityModel!.communityId!,
                    GayaStrings.shared_community.tr,
                    messageType: MessageType.community,
                    community: communityProfileController.communityModel,
                  );

                  // showModalToSendItem(context, communityProfileController.communityModel!.communityId!, GayaStrings.shared_community.tr,
                  //     messageType: MessageType.community, community: communityProfileController.communityModel);

                  await context.read<HomePageController>().yourFriends();
                }
              }
            },
            child: SvgIconWidget.userPlusOutline(height: 20.h),
            // child: SvgPicture.asset('Assets/icons/add.svg')
          ),
          IconButton(
              onPressed: () {
                getBottomSheet(context, community: getCommunityModel);
              },
              icon: SvgIconWidget.menuOutline(height: 20.h)
              // icon: const Icon(Icons.menu)
              ),
          const SizedBox(width: 10),
        ],
      ),
      body: GetBuilder<CommunityFeedController>(
          init: CommunityFeedController.to(tag: widget.communityModel.communityId),
          tag: widget.communityModel.communityId,
          autoRemove: false,
          builder: (feedController) {
            return AbsorbPointer(
              absorbing: feedController.isLoading,
              child: NestedScrollView(
                headerSliverBuilder: (ctx, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                        child: Column(
                      children: [
                        /// cover photo
                        GetBuilder<CommunityProfileController>(
                            tag: widget.communityModel.communityId,
                            init: communityProfileController,
                            autoRemove: false,
                            builder: (communityProfileController) {
                              return InkWell(
                                onTap: () {
                                  if (communityProfileController.communityModel?.coverPicture != null ||
                                      communityProfileController.communityModel?.coverPicture.isBlank == false) {
                                    Routes.openImages(urls: [communityProfileController.communityModel!.coverPicture!], index: 0, ctx: ctx);
                                  }
                                },
                                child: Hero(
                                  tag: communityProfileController.communityModel?.coverPicture ?? "",
                                  child: SizedBox(
                                      height: 130.h,
                                      width: double.infinity,
                                      child: PostImageWidget(
                                          url: communityProfileController.communityModel?.coverPicture,
                                          size: const Size(double.infinity, 350))),
                                ),
                              );
                            }),

                        /// description
                        GetBuilder<CommunityProfileController>(
                          tag: widget.communityModel.communityId,
                          init: communityProfileController,
                          autoRemove: false,
                          builder: (communityProfileController) {
                            if (communityProfileController.isLoading) {
                              return Container(height: 80, width: double.infinity, color: kBaseGrey);
                            }
                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20).r,
                              alignment: Alignment.center,
                              decoration:
                                  BoxDecoration(color: communityProfileController.getColorFromHexaString() ?? const Color(0xFFD28AFF)),
                              child: GetBuilder<CommunityProfileController>(
                                  tag: widget.communityModel.communityId,
                                  init: communityProfileController,
                                  autoRemove: false,
                                  builder: (controller) {
                                    return LinkWell(
                                      controller.communityModel?.communityDescription ?? "",
                                      style: CustomTypography.body4Style,
                                      textAlign: TextAlign.center,
                                      textDirection:
                                          context.read<HomePageController>().isRTL(getCommunityModel.communityDescription.toString())
                                              ? TextDirection.rtl
                                              : TextDirection.ltr,
                                      linkStyle: const TextStyle(color: kprimaryColor, fontFamily: GayaFontTheme.primaryFont),
                                    );
                                  }),
                            );
                          },
                        ),

                        /// community topics list
                        GetBuilder<EditCommunityController>(
                            tag: widget.communityModel.communityId,
                            init: editCommunityController,
                            builder: (editCommunityController) {
                              if (editCommunityController.isLoading) {
                                return const CommunityTopicsSkeleton();
                              }

                              /// if theres no community topics, don't show anything
                              if (editCommunityController.createCommunityModel == null ||
                                  editCommunityController.createCommunityModel?.communityTopicList == null ||
                                  editCommunityController.createCommunityModel!.communityTopicList!.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              return Column(
                                children: [
                                  Container(
                                    height: 56,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.all(distance_12),
                                    child: GetBuilder<CommunityFeedController>(
                                      tag: widget.communityModel.communityId,
                                      init: CommunityFeedController.to(tag: widget.communityModel.communityId),
                                      builder: (feedController) {
                                        List topics = [""] + (editCommunityController.createCommunityModel?.communityTopicList ?? []);
                                        return GetBuilder<CommunityProfileController>(
                                          tag: widget.communityModel.communityId,
                                          init: communityProfileController,
                                          builder: (communityProfileController) {
                                            return ListView.builder(
                                                itemCount: topics.length,
                                                padding: const EdgeInsets.only(right: 6),
                                                scrollDirection: Axis.horizontal,
                                                itemBuilder: (context, index) {
                                                  final String currentTopic = topics[index];
                                                  final bool isSelectedTopic = currentTopic == feedController.selectedTopic ||
                                                      feedController.selectedTopic == null && index == 0;

                                                  return (index == 0)
                                                      ? InkWell(
                                                          highlightColor: kTransparentColor,
                                                          hoverColor: kTransparentColor,
                                                          splashColor: kTransparentColor,
                                                          onTap: () => feedController.setSelectedTopic(null),
                                                          child: Container(
                                                            height: 32,
                                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                                            margin: const EdgeInsets.only(right: 6),
                                                            decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(20),
                                                                color: isSelectedTopic
                                                                    ? (communityProfileController.getColorFromHexaString() != null)
                                                                        ? communityProfileController.getColorFromHexaString()
                                                                        : const Color(0xFFD28AFF) //kprimaryColorLight
                                                                    : kBaseGrey),
                                                            alignment: Alignment.center,
                                                            child: SvgPicture.asset('Assets/images/default_search.svg',
                                                                color: isSelectedTopic ? kBlackColor : kSecondaryColor),
                                                          ),
                                                        )
                                                      : InkWell(
                                                          highlightColor: kTransparentColor,
                                                          hoverColor: kTransparentColor,
                                                          splashColor: kTransparentColor,
                                                          onTap: () {
                                                            print('topics is: $currentTopic');
                                                            //if topic name doesn't exist.
                                                            if (currentTopic?.isBlank == null) return;
                                                            feedController.setSelectedTopic(currentTopic);
                                                          },
                                                          child: Container(
                                                            height: 32,
                                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                                            margin: const EdgeInsets.only(right: 6),
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(20),
                                                              color: isSelectedTopic
                                                                  ? (communityProfileController.getColorFromHexaString() != null)
                                                                      ? communityProfileController.getColorFromHexaString()
                                                                      : const Color(0xFFD28AFF) //kprimaryColorLight
                                                                  : kBaseGrey,
                                                            ),
                                                            alignment: Alignment.center,
                                                            child: Text(
                                                              currentTopic,
                                                              style: TextStyle(
                                                                fontWeight: FontWeight.w500,
                                                                fontSize: 12.sp,
                                                                height: 1.5,
                                                                color: isSelectedTopic ? kBlackColor : kSecondaryColor,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                });
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  const Divider(height: 0),
                                ],
                              );
                            }),

                        /// community members + post approvals
                        GetBuilder<EditCommunityController>(
                          tag: widget.communityModel.communityId,
                          init: editCommunityController,
                          autoRemove: false,
                          builder: (editCommunityController) {
                            if (editCommunityController.isLoading) {
                              return const SizedBox.shrink();
                            }
                            if (!CommunityProfileController.to(tag: widget.communityModel.communityId).isAdminOrModerator) {
                              return const SizedBox.shrink();
                            }

                            return Consumer<GroupController>(
                              builder: (context, checkAdming, _) {
                                return Column(
                                  children: [
                                    StreamProvider<QuerySnapshot?>(
                                      create: (context) => checkAdming.getApprovePosts(widget.communityModel.communityId!),
                                      initialData: null,
                                      child: Consumer<QuerySnapshot?>(builder: (context, waitingPosts, _) {
                                        return waitingPosts == null
                                            ? const SizedBox.shrink()
                                            : waitingPosts.docs.isEmpty
                                                ? const SizedBox.shrink()
                                                : Column(
                                                    children: [
                                                      InkWell(
                                                        onTap: () {
                                                          if (CommunityProfileController.to(tag: widget.communityModel.communityId)
                                                              .isAdminOrModerator) {
                                                            Routes.openApprovePostsView(communityId: widget.communityModel.communityId);
                                                          }
                                                        },
                                                        child: SizedBox(
                                                          height: 50.h,
                                                          child: ApprovalRow(
                                                              icon: Assets.assets.icons.postApproval,
                                                              title: "${waitingPosts.docs.length} ${GayaStrings.post_waiting_approval.tr}"),
                                                        ),
                                                      ),
                                                      const Divider(height: 1),
                                                    ],
                                                  );
                                      }),
                                    ),
                                    StreamProvider<QuerySnapshot?>(
                                      create: (context) => checkAdming.getPendingMembers(widget.communityModel.communityId!),
                                      initialData: null,
                                      child: Consumer<QuerySnapshot?>(builder: (context, waitingPosts, _) {
                                        return waitingPosts == null || waitingPosts.docs.isEmpty
                                            ? const SizedBox.shrink()
                                            : Column(
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      if (CommunityProfileController.to(tag: widget.communityModel.communityId)
                                                          .isAdminOrModerator) {
                                                        final _community = getCommunityModel;

                                                        Routes.openApproveUsersView(
                                                          communityId: _community?.communityId ?? "",
                                                          communityName: _community?.communityName ?? "",
                                                        );
                                                      }
                                                    },
                                                    child: SizedBox(
                                                      key: UniqueKey(),
                                                      height: 50.h,
                                                      child: ApprovalRow(
                                                        icon: ImageAssetsUtils.userPlusOutline,
                                                        title: "${waitingPosts.docs.length} ${GayaStrings.user_waiting_approval.tr}",
                                                      ),
                                                    ),
                                                  ),
                                                  const Divider(height: 0.1),
                                                ],
                                              );
                                      }),
                                    )
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ))
                  ];
                },
                body: CommunityFeedView(communityModel: getCommunityModel, controller: feedController),
              ),
            );
          }),
      floatingActionButton: GestureDetector(
          onTap: () {
            if (widget.communityModel.communityId != null) {
              Community? _community = getCommunityModel;
              debugPrint("Going to createPost with this model: ${widget.communityModel.toMap()}");
              Routes.createPost(community: _community, from: PostCreationFrom.Community);
            }

            HapticFeedback.mediumImpact();
          },
          child: GetBuilder<CommunityProfileController>(
            tag: widget.communityModel.communityId,
            autoRemove: false,
            init: communityProfileController,
            builder: (communityProfileController) {
              return Container(
                margin: !DeviceCheck.isIOS ? const EdgeInsets.only(bottom: 20).r : null,
                padding: const EdgeInsets.all(12).r,
                height: 48.r,
                width: 48.r,
                decoration: BoxDecoration(
                    color: (communityProfileController.getColorFromHexaString() != null)
                        ? communityProfileController.getColorFromHexaString()
                        : const Color(0xFFD28AFF),
                    borderRadius: BorderRadius.circular(borderRadius_4).r),
                child: SvgIconWidget.editOutline(height: 24.r, width: 24.r),
              );
            },
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  getBottomSheet(BuildContext context, {required Community community}) {
    return showModalBottomSheet(
      context: context,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(13.0), topRight: Radius.circular(13.0)),
      ),
      builder: (modalContext) => Container(
        padding: const EdgeInsets.all(0),
        width: MediaQuery.sizeOf(context).width,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(13.0), topRight: Radius.circular(13.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(height: distance_20.r),
            Container(
              height: 5,
              width: 40,
              decoration: const ShapeDecoration(color: borderColor, shape: StadiumBorder()),
            ),
            GayaListTileButton(
                title: GayaStrings.about.tr,
                leading: SvgIconWidget.infoCircleOutline(height: 20.r, width: 20.r),
                // leading: SvgIcons.information(height: 20.r, width: 20.r),
                onTap: () {
                  Navigator.of(context).pop();
                  Routes.openCommunityAbout(community: getCommunityModel);
                }),
            GayaListTileButton(
              title: GayaStrings.community_notification.tr,
              leading: SvgIconWidget.bellOutline1(height: 20.r, width: 20.r),
              // leading: SvgIcons.bellOutline(height: 20.r, width: 20.r),
              onTap: () {
                Navigator.of(context).pop();
                Methods.showCommunityNotificationModalSheet(
                  community: getCommunityModel,
                  context: context,
                );
              },
            ),
            GayaListTileButton(
                title: GayaStrings.event.tr,
                leading: SvgIconWidget.calendarOutline(height: 20.r, width: 20.r),
                onTap: () {
                  Navigator.of(context).pop();
                  Routes.communityCalendarView(communityId: widget.communityModel.communityId ?? "", isEditable: false);
                }),
            if (getCommunityModel.communityType == 'Secret')
              GayaListTileButton(
                title: GayaStrings.access_lock.tr,
                leading: SvgIconWidget.lockOutline1(height: 20.r, width: 20.r),
                onTap: () async {
                  Navigator.of(context).pop();
                  bool isEnabled = await AppConfigurationController.to.isFingerprintEnabled(widget.communityModel.communityId) != false;

                  if (!mounted) return;

                  // Logging community access use analytics event
                  AnalyticsController.to.instance.logCommunityAccessLockUse(
                    communityId: widget.communityModel.communityId ?? '',
                    isAccessLockEnabled: isEnabled,
                    userId: UserModel.to.uId ?? '',
                  );

                  toggleFingerprintAccessLockBottomModal(context, widget.communityModel.communityId!, isEnabled);
                },
              ),
            if (getCommunityModel.adminUid == FirebaseAuth.instance.currentUser!.uid || AppConfigurationController.to.isSuperAdmin)
              GayaListTileButton(
                  title: GayaStrings.community_settings.tr,
                  // leading: SvgIcons.settings(height: 20.r, width: 20.r),
                  leading: SvgIconWidget.settingsOutline(height: 20.r, width: 20.r),
                  onTap: () {
                    // here we are setting the community model in controller
                    editCommunityController.setCreateCommunityModel(editCommunityController.createCommunityModel ?? widget.communityModel);
                    // pop the bottom bar
                    Get.back();
                    Routes.communitySettingsView(communityId: widget.communityModel.communityId ?? "");
                  }),
            Consumer<GroupController>(
              builder: (ctrContext, report, child) {
                return _isAdmin(community: community)
                    ? const SizedBox.shrink()
                    : GayaListTileButton(
                        title: GayaStrings.report.tr,
                        leading: SvgIcons.problem(height: 20.r, width: 20.r),
                        onTap: () async {
                          bool isReported = await report.didCommunityAlreadyReported(widget.communityModel.communityId!);
                          if (!isReported) {
                            // ignore: use_build_context_synchronously
                            Navigator.pop(modalContext);
                            // ignore: use_build_context_synchronously
                            reportTextFieldBottomModal(ctrContext, onSubmit: (String reportMsg) async {
                              Navigator.pop(context);
                              await report.reportCommunity(widget.communityModel.communityId!, context, reportMsg);
                            });
                          } else {
                            if (context.mounted) {
                              snackBar(context, GayaStrings.community_already_reported.tr, kprimaryColor);
                              Navigator.pop(context);
                            }
                          }
                        });
              },
            ),
            Consumer<GroupController>(builder: (context, value, child) {
              return _isAdmin(community: community)
                  ? const SizedBox.shrink()
                  : FutureProvider<QuerySnapshot?>(
                      initialData: null,
                      create: (context) => isUserInCommunity,
                      child: Consumer<QuerySnapshot?>(
                        builder: (context, leaveCommunity, _) {
                          return Consumer<GroupController>(builder: (__, leave, _) {
                            return GayaListTileButton(
                              title: GayaStrings.leave_txt.tr,
                              leading: SvgIconWidget.logoutOutline(height: 20.r, width: 20.r),
                              // leading: SvgIcons.leave(height: 20.r, width: 20.r),
                              onTap: () async {
                                Methods.showLeaveCommunityAlert(
                                    communityModel: getCommunityModel,
                                    context: context,
                                    onLeave: () {
                                      Navigator.pop(context); //modal sheet
                                      Navigator.pop(context); // screen
                                    });
                              },
                            );
                          });
                        },
                      ));
            }),
            SizedBox(height: 10.r),
            if (AppConfigurationController.to.isSuperAdmin) ...[
              GayaListTileButton(
                title: GayaStrings.delete_this_community.tr,
                // leading: SvgIcons.settings(height: 20.r, width: 20.r),
                leading: const Icon(CupertinoIcons.delete),
                onTap: () async {
                  showGayaAlertDialogBox(
                    context: context,
                    child: AlertBoxViewDynamic(
                      title: GayaStrings.delete_this_community.tr,
                      subTitle: GayaStrings.delete_this_community_sub_title.tr,
                      okButtonText: GayaStrings.delete_txt.tr,
                      tapOnNo: () => Navigator.pop(context),
                      icon: const Icon(CupertinoIcons.delete, size: 50, color: AppColors.error),
                      tapOnYes: () async {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        if (widget.communityModel.communityId.isBlank == true) return;
                        CustomSnackBar.showCustomToast(
                          message: "Processing, You'll be notified when the community is deleted",
                          color: AppColors.skeleton,
                          messageColor: AppColors.black,
                          icon: const CupertinoActivityIndicator(),
                          messageStyle: GayaTypography.subtitleMedium.copyWith(color: AppColors.black, fontSize: 12.sp),
                        );

                        /// wait for 6 minimum seconds to show the snackbar
                        await Future.wait([
                          Future.delayed(6.seconds),
                          DeleteCommunityServices.instance.deleteCommunity(communityId: widget.communityModel.communityId!)
                        ]);

                        CustomSnackBar.showCustomToast(
                          message: "Community '${getCommunityModel.communityName}' has been deleted successfully. Please refresh",
                          color: AppColors.skeleton,
                          messageColor: AppColors.black,
                          icon: const Icon(CupertinoIcons.checkmark_alt_circle_fill, color: AppColors.success),
                          messageStyle: GayaTypography.subtitleMedium.copyWith(color: AppColors.black, fontSize: 12.sp),
                        );
                      },
                    ),
                  );
                },
              ),
              GayaListTileButton(
                title: community.isArchive ? "Unarchive" : "Archive this community",
                // leading: SvgIcons.settings(height: 20.r, width: 20.r),
                leading: const Icon(CupertinoIcons.eye_slash),
                onTap: () async {
                  showGayaAlertDialogBox(
                    context: context,
                    child: AlertBoxViewDynamic(
                      title: community.isArchive ? "Unarchive" : "Archive this community",
                      subTitle:
                          "Are you sure you want to ${community.isArchive ? "unarchive" : "archive"} this community? You can ${community.isArchive ? "archive" : "unarchive"} it later.",
                      okButtonText: community.isArchive ? "Unarchive" : "Archive",
                      tapOnNo: () => Navigator.pop(context),
                      icon: const Icon(CupertinoIcons.eye_slash, size: 50, color: AppColors.error),
                      tapOnYes: () async {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        if (widget.communityModel.communityId.isBlank == true) return;

                        /// wait for 6 minimum seconds to show the snackbar
                        await Future.wait([
                          community.isArchive
                              ? DeleteCommunityServices.instance.unarchiveCommunity(communityId: widget.communityModel.communityId!)
                              : DeleteCommunityServices.instance.archiveCommunity(communityId: widget.communityModel.communityId!)
                        ]);

                        community.isArchived = !(community.isArchived ?? false);
                        CustomSnackBar.showCustomToast(
                          message:
                              "Community '${getCommunityModel.communityName}' has been ${community.isArchive ? "archived" : "unarchived"} successfully.",
                          color: AppColors.skeleton,
                          messageColor: AppColors.black,
                          icon: const Icon(CupertinoIcons.checkmark_alt_circle_fill, color: AppColors.success),
                          messageStyle: GayaTypography.subtitleMedium.copyWith(color: AppColors.black, fontSize: 12.sp),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
            SizedBox(height: 20.r),
          ],
        ),
      ),
    );
  }

  bool _isAdmin({required Community community}) {
    bool isReg = CommunityProfileController.isRegistered(tag: community.communityId);
    if (isReg) {
      return CommunityProfileController.to(tag: community.communityId).isAdmin;
    } else {
      return community.isAdmin;
    }
  }
}

class DynamicSliverAppBar extends StatefulWidget {
  final Widget child;
  final double maxHeight;

  const DynamicSliverAppBar({
    required this.child,
    required this.maxHeight,
    Key? key,
  }) : super(key: key);

  @override
  _DynamicSliverAppBarState createState() => _DynamicSliverAppBarState();
}

class _DynamicSliverAppBarState extends State<DynamicSliverAppBar> {
  final GlobalKey _childKey = GlobalKey();
  bool isHeightCalculated = false;
  double? height;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!isHeightCalculated) {
        isHeightCalculated = true;
        setState(() {
          height = (_childKey.currentContext?.findRenderObject() as RenderBox).size.height;
        });
      }
    });

    return SliverAppBar(
      backgroundColor: const Color(0x00000000),
      automaticallyImplyLeading: false,
      expandedHeight: isHeightCalculated ? height : widget.maxHeight,
      flexibleSpace: FlexibleSpaceBar(
        background: Column(
          children: [
            Container(
              key: _childKey,
              child: widget.child,
            ),
            const Expanded(child: SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}

void toggleFingerprintAccessLockBottomModal(BuildContext context, String communityId, bool isEnabled) async {
  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(13.0), topRight: Radius.circular(13.0))),
      builder: (context) {
        bool value = isEnabled;
        return StatefulBuilder(builder: (context, notifyState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              width: MediaQuery.sizeOf(context).width,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(13.0), topRight: Radius.circular(13.0)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Center(
                    child: Container(
                      height: 5,
                      width: 40,
                      decoration: const ShapeDecoration(color: kBaseGrey, shape: StadiumBorder()),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(GayaStrings.access_lock.tr, style: CustomTypography.bodyStyle),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(GayaStrings.require_touch_id.tr, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.sp)),
                      Switch.adaptive(
                          activeColor: kprimaryColor,
                          value: value,
                          onChanged: (newValue) async {
                            // Navigator.pop(context);
                            showGayaAlertDialogButton(
                              context: context,
                              actionText: GayaStrings.change_community_access.tr,
                              tapOnYes: () async {
                                Navigator.pop(context);
                                await AppConfigurationController.to.toggleFingerprintStatusOfASecretCommunityMember(communityId, newValue);
                                notifyState(() => value = newValue);
                              },
                              tapOnNo: () => Navigator.pop(context),
                            );
                          })
                    ],
                  ),
                  SizedBox(height: 5.r),
                  Text(
                    GayaStrings.when_enabled_you_will_need_to_use_touched.tr,
                    style: CustomTypography.secondaryFontStyleWeight,
                    maxLines: 2,
                  ),
                  SizedBox(height: 16.r),
                ],
              ),
            ),
          );
        });
      });
}
