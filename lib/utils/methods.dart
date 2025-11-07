// ignore_for_file: use_build_context_synchronously
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feed_reaction/models/feed_reaction_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/components/snackbar.component.dart';
import 'package:gaya/controller/app_config_controller.dart';
import 'package:gaya/controller/communities.controller.dart';
import 'package:gaya/controller/firebase_analytics_controller.dart';
import 'package:gaya/controller/group.controller.dart';
import 'package:gaya/model/communities.memebers.model.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/model/create.post.model.dart';
import 'package:gaya/model/reaction_model.dart';
import 'package:gaya/model/user.communities.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/shared/view/widget/custom_post_options_list_tile.dart';
import 'package:gaya/shared/view/widget/gaya_alert_dialog.dart';
import 'package:gaya/shared/view/widget/gaya_snackbar.dart';
import 'package:gaya/utils/asset_images.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/strings.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_spaces.dart';
import 'package:gaya/view/chat/views/group_detail/new_group_screen.dart';
import 'package:gaya/view/community/controllers/secret_community_controller.dart';
import 'package:gaya/view/feed/view/community_user_feed/controller/home_feed_user_communities_controller.dart';
import 'package:gaya/widgets/profile.widgets/influence_bar_widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:intl/intl.dart' as intl;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bindings/initializing_dependencies.dart';
import '../components/progress.indicator.component.dart';
import '../services/services.dart';
import '../shared/constant/string_constant.dart';
import '../shared/service/cache_service/cache_services.dart';
import '../shared/view/widget/gaya_button_alert_dialog.dart';
import '../shared/view/widget/gaya_message_popup_modalsheet.dart';
import '../shared/view/widget/gaya_report_dialog.dart';
import '../view/community/components/community_joined_view.dart';
import '../view/community/components/give_crown_to_post_widget.dart';
import 'gaya_text_widget.dart';
import 'language/translation.dart';
import 'logger.dart';
import 'textstyles.dart';

class Methods {
  static final Services _firestoreServices = Services();

  static void showCommunityOperationModalSheet({
    required Community? communityModel,
    required BuildContext context,
    VoidCallback? onPin,
    VoidCallback? onHideUnhide,
    bool? isPinned,
    bool showPin = true,
    bool showReport = true,
    bool showNotification = true,
    bool showLeave = true,
    bool showHideUnhide = true,
    bool isHidden = false,
  }) async {
    final padding = const EdgeInsets.only(bottom: 8).r;
    showCircularModalSheet(
        context,
        FutureBuilder<CommunityMembership?>(
            future: _firestoreServices.getUserMembershipByCommunityId(communityId: communityModel?.communityId ?? ""),
            builder: (context, rawMembership) {
              if (rawMembership.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: MediaQuery.sizeOf(context).height * .2,
                  child: const PrimaryCircularProgressIndicator.centered(),
                );
              }
              final membership = rawMembership.data;
              return Column(
                children: [
                  /// pin unpin community
                  if (showPin)
                    GayaListTileButton(
                        title: ((isPinned ?? false) ? GayaStrings.unpin_community : GayaStrings.pin_community).tr,
                        subtitle: (GayaStrings.pin_community_to_top).tr,
                        margin: padding,
                        leading: SvgIconWidget.pinOutlinee(height: 2.r, width: 2.r),
                        onTap: () {
                          GayaSnackBar.show(
                              context: context,
                              type: GayaSnackBarType.pin,
                              text: "${GayaStrings.community.tr} ${isPinned ?? false ? GayaStrings.unpinned.tr : GayaStrings.pinned.tr}");

                          Navigator.pop(context);
                          if (onPin != null) {
                            onPin();
                          }
                        }),

                  // report community
                  if (showReport && AppConfigurationController.to.isAdminOrModerator(communityId: communityModel?.communityId) == false)
                    GayaListTileButton(
                        title: (GayaStrings.report_community).tr,
                        subtitle: (GayaStrings.im_concerned_about_this_community).tr,
                        margin: padding,
                        leading: SvgIcons.problem(height: 20.r, width: 20.r),
                        onTap: () async {
                          final GroupController report = GroupController();
                          bool isReported = await report.didCommunityAlreadyReported(communityModel!.communityId!);
                          if (!isReported) {
                            reportTextFieldBottomModal(context, onSubmit: (String reportMsg) async {
                              Navigator.pop(context);
                              await report.reportCommunity(communityModel.communityId!, context, reportMsg);
                            });
                          } else {
                            snackBar(context, GayaStrings.community_already_reported.tr, kprimaryColor);
                            Navigator.pop(context);
                          }
                        }),

                  // enable disable notification
                  if (showNotification)
                    StatefulBuilder(builder: (context, updateState) {
                      return GayaListTileButton(
                          title: ((membership?.isNotificationEnabled ?? false)
                                  ? GayaStrings.turn_off_notification_community
                                  : GayaStrings.turn_on_notification_community)
                              .tr,
                          subtitle: (GayaStrings.subscribe_this_community).tr,
                          margin: padding,
                          leading: SvgIconWidget.bellOutline1(height: 20.r, width: 20.r),
                          onTap: () {
                            final isEnabled = !(membership?.isNotificationEnabled ?? false);
                            membership?.copyWith(isNotificationEnabled: membership.isNotificationEnabled = isEnabled);
                            _firestoreServices.changeNotificationSubscription(communityModel?.communityId ?? "", isEnabled);
                            GayaSnackBar.show(
                                context: context,
                                type: GayaSnackBarType.notification,
                                text: "${GayaStrings.notification.tr} ${isEnabled ? GayaStrings.enabled.tr : GayaStrings.disabled.tr}");
                            Navigator.pop(context);
                          });
                    }),

                  // leave community
                  if (showLeave && membership?.isAdmin != true)
                    GayaListTileButton(
                      title: "${GayaStrings.leave_txt.tr} ${communityModel?.communityName ?? ""}",
                      margin: padding,
                      leading: SvgIconWidget.logoutOutline(height: 20.r, width: 20.r),
                      onTap: () =>
                          showLeaveCommunityAlert(communityModel: communityModel, context: context, onLeave: () => Navigator.pop(context)),
                    ),

                  // hide community
                  if (showHideUnhide)
                    GayaListTileButton(
                        title: isHidden ? GayaStrings.unhide_this_community.tr : GayaStrings.hide_this_community.tr,
                        subtitle: isHidden ? GayaStrings.i_want_to_see_this_community.tr : GayaStrings.i_dont_want_to_see_this_community.tr,
                        margin: padding,
                        leading: SvgIconWidget.eyeOffOutline(height: 20.r, width: 20.r),
                        onTap: () {
                          Navigator.pop(context);
                          if (onHideUnhide != null) {
                            onHideUnhide();
                            return;
                          }
                          AppConfigurationController.to.hideOrUnHideCommunity(communityId: communityModel?.communityId);
                          DefaultSnackBar.hideOrUnHideCommunity(context: context);
                        }),

                  SizedBox(height: 10.r),
                ],
              );
            }));
  }

  static void showLeaveCommunityAlert({
    required Community? communityModel,
    required BuildContext context,
    required VoidCallback onLeave,
  }) async {
    final GroupController controller = GroupController();
    if (communityModel?.communityId == null) return;
    GayaAlertDialog(
        context: context,
        title: GayaStrings.leave_community.tr,
        body: "${GayaStrings.Do_you_want_to_leave.tr} ${communityModel?.communityName ?? ""} ${GayaStrings.community_join_later.tr}",
        okButtonText: GayaStrings.leave_txt.tr,
        tapOnOk: () async {
          try {
            GayaSnackBar.show(
              context: context,
              type: GayaSnackBarType.communities,
              text: Gaya_Strings.leave_communityByName(communityName: communityModel?.communityName ?? ""),
            );
            Navigator.pop(context);
            onLeave();

            await controller.leaveTheCommunity(communityModel!.communityId!);
            await AppConfigurationController.to.leaveCommunity(communityModel.communityId!);
            await controller.deleteTheUserFromCommunity(communityModel.communityId!);

            /// remove from home screen circle (user community feed)
            if (HomeFeedUserCommunities.isRegistered) {
              HomeFeedUserCommunities.to.removeCommunity(communityModel);
            }

            // logging community left log event
            AnalyticsController.to.instance.logLeaveCommunity(
              communityId: communityModel.communityId,
              userId: FirebaseAuth.instance.currentUser!.uid,
            );
          } catch (_) {}
        },
        tapOnCancel: () {
          Navigator.pop(context);
        },
        cancleButtonText: GayaStrings.cancel_txt.tr);
  }

  static void showCommunityNotificationModalSheet({required Community community, required BuildContext context}) {
    showCircularModalSheet(
        context,
        FutureBuilder<CommunityMembership?>(
            future: _firestoreServices.getUserMembershipByCommunityId(communityId: community.communityId ?? ""),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: MediaQuery.sizeOf(context).height * .1,
                  child: const PrimaryCircularProgressIndicator.centered(),
                );
              }
              final membership = snapshot.data;
              return SafeArea(
                child: Column(
                  children: [
                    Text(GayaStrings.community_subscription.tr, style: GayaTypography.titleMedium),
                    SizedBox(height: MySpaces.gap2.h),
                    StatefulBuilder(builder: (context, updateState) {
                      return GayaSwitchButtonListTile(
                          title: GayaStrings.new_community_posts.tr,
                          subtitle: GayaStrings.anonymous_usreceive_alerts_for_any_new_updates_communityer.tr,
                          value: membership?.isNotificationEnabled ?? false,
                          onChanged: (value) {
                            final isEnabled = !(membership?.isNotificationEnabled ?? false);
                            membership?.copyWith(isNotificationEnabled: membership.isNotificationEnabled = isEnabled);
                            _firestoreServices.changeNotificationSubscription(community.communityId ?? "", isEnabled);

                            // Logging community notifications status analytics event
                            AnalyticsController.to.instance.logCommunityNotificationsStatus(
                              areNotificationsEnabled: isEnabled,
                              communityId: community.communityId ?? '',
                              userId: UserModel.to.uId ?? '',
                            );

                            updateState(() {});
                          });
                    }),
                    SizedBox(height: MySpaces.gap2.h),
                  ],
                ),
              );
            }));
  }

  // change auto post approval status for a community
  static void showCommunityAutoPostApprovalModalSheet({required Community community, required BuildContext context}) {
    showCircularModalSheet(
        context,
        FutureBuilder<Community?>(
            future: _firestoreServices.getCommunityDetailsModel(community.communityId ?? ""),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: MediaQuery.sizeOf(context).height * .1,
                  child: const PrimaryCircularProgressIndicator.centered(),
                );
              }
              if (snapshot.data == null) {
                return SizedBox(
                  height: MediaQuery.sizeOf(context).height * .1,
                  child: Center(
                    child: Text(GayaStrings.something_went_wrong_fetching_community.tr),
                  ),
                );
              }
              final communityModel = snapshot.data;
              return SafeArea(
                child: Column(
                  children: [
                    Text(GayaStrings.approval_settings.tr, style: GayaTypography.titleMedium),
                    SizedBox(height: MySpaces.gap2.h),
                    StatefulBuilder(builder: (context, updateState) {
                      return GayaSwitchButtonListTile(
                          title: GayaStrings.post_approvals.tr,
                          subtitle: GayaStrings.post_approval_description.tr,
                          value: communityModel?.isPostApprovalNeeded ?? false,
                          onChanged: (value) {
                            final isEnabled = !(communityModel?.isPostApprovalNeeded ?? false);
                            communityModel?.copyWith(isPostApprovalNeeded: communityModel.isPostApprovalNeeded = isEnabled);
                            // createCommunity.to.update(UserModel.to.copyWith(allowToDm: isEnabled));
                            _firestoreServices.toggleCommunityAutoPostsApprovalStatus(communityModel?.communityId ?? "", isEnabled);

                            // Logging community post approval to analytics event
                            AnalyticsController.to.instance.logSpecialFeatureUsage(
                              userId: UserModel.to.uId ?? '',
                              featureName: 'community_post_approval',
                            );

                            updateState(() {});
                          });
                    }),
                    SizedBox(height: MySpaces.gap2.h),
                  ],
                ),
              );
            }));
  }

  static void showDmStatusSettingModalSheet({required BuildContext context}) {
    showCircularModalSheet(
        context,
        FutureBuilder<UserModel?>(
            future: _firestoreServices.getUserById(UserModel.to.uId ?? ""),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: MediaQuery.sizeOf(context).height * .1,
                  child: const PrimaryCircularProgressIndicator.centered(),
                );
              }
              if (snapshot.data == null) {
                return SizedBox(
                  height: MediaQuery.sizeOf(context).height * .1,
                  child: Center(
                    child: Text(GayaStrings.something_went_wrong_fetching_profile.tr),
                  ),
                );
              }
              final userModel = snapshot.data;
              return SafeArea(
                child: Column(
                  children: [
                    Text(GayaStrings.dm_setting.tr, style: GayaTypography.titleMedium),
                    SizedBox(height: MySpaces.gap2.h),
                    StatefulBuilder(builder: (context, updateState) {
                      return GayaSwitchButtonListTile(
                          title: GayaStrings.change_dm_status.tr,
                          subtitle: GayaStrings.allow_others_to_send_to_send_dm.tr,
                          value: userModel?.allowToDm ?? true,
                          onChanged: (value) {
                            final isEnabled = !(userModel?.allowToDm ?? true);
                            userModel?.copyWith(allowToDm: userModel.allowToDm = isEnabled);
                            UserModel.to.update(UserModel.to.copyWith(allowToDm: isEnabled));
                            _firestoreServices.toggleDmSettingStatus(UserModel.to.uId ?? "", isEnabled);

                            // Logging personal message privacy to analytics event
                            AnalyticsController.to.instance.logSpecialFeatureUsage(
                              userId: UserModel.to.uId ?? '',
                              featureName: 'personal_message_privacy',
                            );

                            updateState(() {});
                          });
                    }),
                    SizedBox(height: MySpaces.gap2.h),
                  ],
                ),
              );
            }));
  }

  static void showLanguageSwitchModalSheet({required BuildContext context}) {
    late String selectedLanguageCode;
    showCircularModalSheet(
        context,
        SafeArea(
          child: Column(
            children: [
              Text(GayaStrings.language.tr, style: GayaTypography.titleMedium),
              SizedBox(height: MySpaces.gap2.h),
              GetBuilder<LocalizationController>(
                  autoRemove: false,
                  builder: (controller) {
                    selectedLanguageCode = controller.isHebrew ? "he" : "en";

                    /// radio buttons
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8).r,
                      child: Column(
                        children: [
                          RadioListTile(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            controlAffinity: ListTileControlAffinity.trailing,
                            title: Text("Hebrew", style: GayaTypography.body2),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12).r,
                            visualDensity: const VisualDensity(vertical: -2),
                            groupValue: selectedLanguageCode,
                            enableFeedback: false,
                            autofocus: true,
                            activeColor: kprimaryColor,
                            value: "he",
                            onChanged: (_) {
                              // Logging change language analytics event
                              AnalyticsController.to.instance.logChangeLanguage(
                                oldLanguage: 'english',
                                newLanguage: 'hebrew',
                                userId: UserModel.to.uId ?? '',
                              );

                              controller.toggleLanguage();
                            },
                          ),
                          RadioListTile(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            controlAffinity: ListTileControlAffinity.trailing,
                            title: Text("English", style: GayaTypography.body2),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12).r,
                            visualDensity: const VisualDensity(vertical: -2),
                            groupValue: selectedLanguageCode,
                            enableFeedback: false,
                            autofocus: true,
                            activeColor: kprimaryColor,
                            value: "en",
                            onChanged: (_) {
                              // Logging change language analytics event
                              AnalyticsController.to.instance.logChangeLanguage(
                                oldLanguage: 'hebrew',
                                newLanguage: 'english',
                                userId: UserModel.to.uId ?? '',
                              );

                              controller.toggleLanguage();
                            },
                          ),
                          SizedBox(height: MySpaces.gap6.r),
                          // end of dob and gender
                          GayaButton(
                            height: 50.r,
                            borderColor: kTransparentColor,
                            // textStyle: loginController.styleEmail,
                            textStyle: CustomTypography.body2EnableStyle,
                            title: GayaStrings.continue_txt.tr,
                            onPressed: () => Navigator.pop(context),
                            primaryColor: AppColors.primary,
                          ),
                          const SizedBox(height: distance_20),
                        ],
                      ),
                    );
                  }),
              SizedBox(height: MySpaces.gap2.h),
            ],
          ),
        ));
  }

  /// update post topics
  /// onDone is required to update the post topics in the post model
  static void showTopicPostUpdateModalSheet(
      {required Community community, required Post post, required BuildContext context, required Function(Post) onDoneButtonPressed}) {
    final services = Services();
    showModalBottomSheet(
      context: context,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(13.0), topRight: Radius.circular(13.0)),
      ),
      builder: (modalContext) => SafeArea(
        child: FutureBuilder<Community?>(
            initialData: community,
            future: services.getCommunityDetailsModel(community.communityId!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: MediaQuery.sizeOf(context).height * .2,
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
              final community = snapshot.data;
              return Container(
                padding: const EdgeInsets.all(20),
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
                    Container(height: 5, width: 40, decoration: const ShapeDecoration(color: borderColor, shape: StadiumBorder())),
                    const SizedBox(
                      height: distance_10,
                    ),
                    Text(GayaStrings.post_topic.tr, style: CustomTypography.bodyStyle),
                    const SizedBox(height: distance_15),
                    (community == null || community.communityTopicList == null)
                        ? SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.1,
                            child: Center(
                              child: Text(GayaStrings.no_topic_found.tr, style: CustomTypography.bodyStyle),
                            ),
                          )
                        : (community.communityTopicList!.isEmpty)
                            ? SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.1,
                                child: Center(child: Text(GayaStrings.no_topic_found_community.tr, style: CustomTypography.bodyStyle)),
                              )
                            : SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.3,
                                child: StatefulBuilder(builder: (context, update) {
                                  return ListView.builder(
                                      itemCount: community.communityTopicList?.length ?? 0,
                                      // padding: const EdgeInsets.symmetric(horizontal: distance_15, vertical: distance_10),
                                      itemBuilder: (context, index) {
                                        String singleTopic = community.communityTopicList?[index] ?? '';

                                        return CheckboxListTile(
                                            checkColor: kWhiteColor,
                                            activeColor: kprimaryColor,
                                            controlAffinity: ListTileControlAffinity.leading,
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                                            value:
                                                (post.postTopicList == null || !post.postTopicList!.contains(singleTopic)) ? false : true,
                                            title: Text(singleTopic, style: CustomTypography.body2StyleWeightBlack),
                                            onChanged: (newValue) {
                                              if (post.postTopicList == null) {
                                                post.postTopicList = [singleTopic];
                                              } else {
                                                if (post.postTopicList!.contains(singleTopic)) {
                                                  post.postTopicList!.remove(singleTopic);
                                                } else {
                                                  post.postTopicList!.add(singleTopic);
                                                }
                                              }
                                              update(() {});
                                            });
                                      });
                                }),
                              ),
                    const SizedBox(
                      height: distance_15,
                    ),
                    GayaButton(
                        title: GayaStrings.done.tr,
                        onPressed: () async {
                          if (community?.communityTopicList == null && post.postTopicList == null) {
                            Navigator.pop(modalContext);
                          }

                          onDoneButtonPressed(post);
                          if (modalContext.mounted) {
                            Navigator.pop(modalContext);
                          }

                          // save topics locally in post lists to do
                        },
                        borderColor: kTransparentColor,
                        height: 48,
                        primaryColor: AppColors.primary,
                        textStyle: TextStyle(color: kWhiteColor, fontWeight: FontWeight.w500, fontSize: 14.sp),
                        width: MediaQuery.sizeOf(context).width),
                    const SizedBox(
                      height: distance_15,
                    ),
                  ],
                ),
              );
            }),
      ),
    );
  }

  /// Show a crown left modal sheet.
  static showCrownsTotalModalSheet({required BuildContext? ctx}) {
    if (ctx?.mounted == true && UserModel.to.uId != null) {
      showCircularModalSheet(ctx ?? Get.context!, const GiveCrownToPostWidget());
    }
  }

  // show influence bottom sheet
  static showinfluenceScoreBottomSheet(context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(12.r), topRight: Radius.circular(12.r)),
      ),
      builder: (modalContext) {
        return const InfluenceBarBottomSheet();
      },
    );
  }

  // show influence Streak bottom sheet
  static showinfluenceStreakBottomSheet(context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(12.r), topRight: Radius.circular(12.r)),
      ),
      builder: (modalContext) {
        return const InfluenceStreakBarBottomSheet();
      },
    );
  }

  static final Debouncer _debouncer = Debouncer(delay: 200.milliseconds);

  //// routing to single community
  //// checking fingerprint for secret communities
  static routeToGroup({required Community community, bool clearPreviousRoutes = false, bool shouldReplace = false}) async {
    /// route to group
    debugPrint('Strp6 routing to group');

    if (community.communityType == 'Secret' && await AppConfigurationController.to.isFingerprintEnabled(community.communityId) != false) {
      _debouncer.call(() async {
        Get.lazyPut<SecretCommunityController>(() => SecretCommunityController(community: community));

        final fingerPrintStatus = await Get.find<SecretCommunityController>().checkFingerprintStatus();

        if (fingerPrintStatus == SupportState.supported) {
          String authorized = await Get.find<SecretCommunityController>().authenticateWithBiometrics(Get.context);
          if (authorized == 'Authorized' || authorized == 'מורשה') {
            Routes.groupView(community: community, clearPreviousRoutes: clearPreviousRoutes, shouldReplace: shouldReplace);
          }
          print('finger print status $authorized');
        } else if (fingerPrintStatus == SupportState.unsupported) {
          Routes.groupView(community: community, clearPreviousRoutes: clearPreviousRoutes, shouldReplace: shouldReplace);
        }
        print('finger print status $fingerPrintStatus');
      });
    } else {
      debugPrint('Strp7 routing to group');
      Routes.groupView(community: community, clearPreviousRoutes: clearPreviousRoutes, shouldReplace: shouldReplace);
    }
  }

  /// If the user is not a member of the community, it will show a modal bottom sheet to join the community.
  /// if the user is a member of the community, it will navigate to the community.
  /// if the community is not found, it will show a snackbar.
  static showModalSheetToJoinCommunity({
    Community? communityModel,
    required String? communityId,
    required BuildContext ctx,
    bool isFromDeepLink = false,
    bool shouldReplace = false,
  }) async {
    if (communityId == null) return;
    final services = Services.to;

    // Logging view community modal analytics event
    AnalyticsController.to.instance.logViewCommunityModal(
      communityId: communityId,
      userId: UserModel.to.uId ?? '',
    );

    if (AppConfigurationController.to.isMemberOfCommunity(communityId)) {
      debugPrint('is member of community');
      final Community? community =
          AppConfigurationController.to.joinedCommunities.firstWhereOrNull((element) => element.communityId == communityId);

      debugPrint("community ${community?.communityName}");

      /// if the community is found, it will navigate to the community view
      if (community?.communityId != null) {
        debugPrint("1 is member of community");
        if (community?.communityName != null && community?.communityName?.trim().isBlank == false) {
          debugPrint("2 is member of community");
          if (communityModel == null) {
            debugPrint("3 is member of community");
            return Methods.routeToGroup(community: community!, shouldReplace: shouldReplace);
          } else {
            try {
              final communityDetail = await services.getCommunitiesDetails(communityId);
              if (communityDetail?.data() != null) {
                Community commModel = Community.fromMap(communityDetail?.data() as Map<String, dynamic>);
                debugPrint("4 is member of community");
                return Methods.routeToGroup(community: commModel, shouldReplace: shouldReplace);
              } else {}
            } catch (_) {}
          }
        } else {
          debugPrint("Im member of community but couldnt find community in joinedCommunities list ${communityModel?.toMap()}");

          /// just go with the ID only as we are fetching in screen (Y)
          return Routes.groupView(community: Community(communityId: communityId));
        }
      }

      /// If Super admin, lethim go into the Community
      if (AppConfigurationController.to.isSuperAdmin) {
        /// just go with the ID only as we are fetching in screen (Y)
        return Routes.groupView(community: Community(communityId: communityId));
      }
    }
    if (ctx.mounted) {
      showCircularModalSheet(
          ctx,
          FutureBuilder<Community?>(
              future: _firestoreServices.getCommunityDetailsModel(communityId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.2,
                    child: const PrimaryCircularProgressIndicator.centered(),
                  );
                }
                final community = snapshot.data;
                // if the community is not found, it will not found
                if (community == null || community.communityId == null) {
                  return GayaMessagePopUpModalSheet(title: GayaStrings.community_not_exists.tr);
                }

                /// If community is of secret type and not from deep link, then return
                /// as secret community can only be accessed from deep link
                if (community.communityType == "Secret" && !isFromDeepLink) {
                  return GayaMessagePopUpModalSheet(
                    title: GayaStrings.community_not_exists_permission.tr,
                  );
                }

                /// if the community is found, it will show the community details
                /// get the total members of the community to avoid multiple calls to the database
                /// while rebuilding the widget by readMore/less
                final joinCommunity = Provider.of<GroupController>(context, listen: false);
                final communityMembership = joinCommunity.getUserMembershipByCommunityId(communityId: community.communityId ?? "");

                /// disable readMore or readLess if text is less than 240 characters
                final canReadMore = GayaTextWidget.canReadMore((community.communityDescription ?? ""));
                bool isLoading = false;

                return SafeArea(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20).r,
                    width: MediaQuery.sizeOf(context).width,
                    child: StatefulBuilder(builder: (context, readMore) {
                      return SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(community.communityName ?? "", style: CustomTypography.title24W600),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                community.communityType == "Private"
                                    ? SvgIconWidget.lockOutline1(height: 16.h, width: 16.w)
                                    : SvgIconWidget.lockUnlockedOutline(height: 16.h, width: 16.w),
                                const SizedBox(width: 10),
                                Text(
                                    community.communityType.isBlank == true
                                        ? "${GayaStrings.public_txt} ${GayaStrings.community}".tr
                                        : "${community.communityType?.toLowerCase().toString() ?? GayaStrings.public_txt} ${GayaStrings.community}"
                                            .tr,
                                    style: CustomTypography.community.copyWith(height: 2)),
                                Container(
                                    width: 1,
                                    height: 10.h,
                                    margin: const EdgeInsets.symmetric(horizontal: 10).r,
                                    decoration: const BoxDecoration(color: kBaseGrey)),
                                Text(
                                    (community.communityMembers ?? 0) > 1
                                        ? " ${community.communityMembers ?? 0} ${GayaStrings.members_txt.tr}"
                                        : "${community.communityMembers ?? 0} ${GayaStrings.members_txt.tr}",
                                    style: CustomTypography.community.copyWith(height: 2)),
                              ],
                            ),
                            SizedBox(height: MySpaces.gap2.h),
                            Text(GayaStrings.about.tr, style: CustomTypography.title24W600.copyWith(fontSize: 16.sp, height: 1.5)),
                            SizedBox(height: MySpaces.gap2.h),
                            GayaTextWidget(
                              (community.communityDescription ?? ""),
                              style: CustomTypography.postCaptionStyle,
                              isReadMore: context.read<CommunitiesController>().isReadMore == false,
                              trimCollapsedText: " ",
                              trimExpandedText: "",
                              callback: (isReadMore) {
                                context.read<CommunitiesController>().isReadMore = isReadMore;
                                readMore(() {});
                              },
                              key: UniqueKey(),
                            ),
                            const SizedBox(height: 10),
                            GayaButton(
                                onPressed: (canReadMore == false)
                                    ? null
                                    : () {
                                        readMore(() => context.read<CommunitiesController>().isReadMore =
                                            !context.read<CommunitiesController>().isReadMore);
                                      },
                                height: 50.h,
                                title: (context.read<CommunitiesController>().isReadMore == false
                                    ? GayaStrings.read_more.tr
                                    : GayaStrings.read_less.tr),
                                textStyle: CustomTypography.postCaptionStyle
                                    .copyWith(color: canReadMore ? AppColors.black : AppColors.secondary2, fontWeight: FontWeight.w500),
                                primaryColor: kBaseGrey,
                                borderColor: kTransparentColor),
                            const SizedBox(height: 10),
                            StatefulBuilder(
                              builder: (BuildContext context, update) {
                                return FutureBuilder<CommunityMembership?>(
                                    future: communityMembership,
                                    builder: (context, value) {
                                      final membership = value.data;
                                      debugPrint("membership: ${membership?.toMap()}");
                                      if ((membership?.isMember == true)) {
                                        Navigator.pop(context);
                                        AppConfigurationController.to.joinACommunity(community);
                                        SchedulerBinding.instance.addPostFrameCallback((_) {
                                          /// add community to user collection
                                          services.addCommunityToUser(UserCommunitiesModel(
                                              communityId: community.communityId, communityName: community.communityName));
                                          Methods.routeToGroup(community: community, shouldReplace: shouldReplace);
                                        });
                                      }
                                      return buttonIcon(
                                        iconString: IconsAssetsPathUtils.userPlusOutline,
                                        iconColor: AppColors.white,
                                        height: 50.h,
                                        isLoading: isLoading || value.connectionState == ConnectionState.waiting,
                                        textStyle: CustomTypography.postCaptionStyle.copyWith(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        borderColor: kTransparentColor,
                                        title:
                                            membership?.isMember == false ? GayaStrings.waiting_approval.tr : GayaStrings.join_community.tr,
                                        primaryColor: kprimaryColor,
                                        onPressed: () async {
                                          if (membership?.isMember == false) {
                                            return;
                                          }
                                          if (UserModel.to.uId == null) {
                                            Routes.requiredLoginView();
                                            return;
                                          }
                                          bool shouldNavigateToGroup = false;

                                          try {
                                            // already member
                                            if (membership?.isMember == true) {
                                              AppConfigurationController.to.joinACommunity(community);

                                              SchedulerBinding.instance.addPostFrameCallback((_) {
                                                Methods.routeToGroup(community: community, shouldReplace: shouldReplace);
                                              });
                                              return;
                                            }
                                            isLoading = true;
                                            update(() {});

                                            /// if the community is not fetched, then fetch it
                                            /// and update the community, this happened when the community
                                            /// is having issue with fetching so upon joining it will
                                            /// fetch the community details and update it
                                            if (community.communityName == null) {
                                              final reFetchedCommunity = await _firestoreServices.getCommunityDetailsModel(communityId);
                                              if (reFetchedCommunity != null) {
                                                community.updateWith(community: reFetchedCommunity);
                                                update(() {});
                                              }
                                            }

                                            // if public.
                                            if (community.communityType == "Public") {
                                              /// check if questionnaire is needed to join this community?
                                              if (community.isCommQNeeded == true) {
                                                Navigator.pop(context);
                                                return await Routes.gotoJoinCommunityQuestionnaireForm(
                                                    communityName: (community.communityName ?? ""),
                                                    communityId: community.communityId ?? "",
                                                    shouldNavigate: false,
                                                    oSuccess: () {
                                                      Methods.routeToGroup(community: community, shouldReplace: true);
                                                    },
                                                    onSubmit: () async {
                                                      AppConfigurationController.to.joinPublicCommunity(community);
                                                      await joinCommunity.joinThePublicGroup(communityId);
                                                      await joinCommunity.addCommunityToUserList(
                                                          community.communityName ?? "", communityId);

                                                      // logging member community joined log
                                                      AnalyticsController.to.instance.logUserAddedToCommunity(
                                                        communityId: communityId,
                                                        userId: UserModel.to.uId ?? '',
                                                      );
                                                    });
                                              } else {
                                                /// as questionnaire was not enabled so you can directly apply for joining community
                                                AppConfigurationController.to.joinPublicCommunity(community);
                                                await joinCommunity.joinThePublicGroup(communityId);
                                                await joinCommunity.addCommunityToUserList(community.communityName ?? "", communityId);
                                                shouldNavigateToGroup = true;

                                                // logging member community joined log
                                                AnalyticsController.to.instance.logUserAddedToCommunity(
                                                  communityId: communityId,
                                                  userId: UserModel.to.uId ?? '',
                                                );

                                                if (context.mounted) {
                                                  GayaSnackBar.show(
                                                      context: context,
                                                      type: GayaSnackBarType.communities,
                                                      text: GayaStrings.join_community_success.tr);
                                                }
                                              }

                                              // onJoinedSuccessCallback();
                                            } else {
                                              /// check if questionnaire is needed to join this community?
                                              if (community.isCommQNeeded == true) {
                                                Navigator.pop(context);
                                                return Routes.gotoJoinCommunityQuestionnaireForm(
                                                    communityName: community.communityName ?? "",
                                                    shouldNavigate: true,
                                                    communityId: community.communityId ?? "",
                                                    onSubmit: () async {
                                                      await joinCommunity.joinTheGroup(communityId);
                                                      await joinCommunity.sendCommunityJoiningApprovalNotificationToAdmin(community);
                                                    });
                                              } else {
                                                /// as questionnaire was not enabled so you can directly apply for joining community
                                                await joinCommunity.joinTheGroup(communityId);
                                                await joinCommunity.sendCommunityJoiningApprovalNotificationToAdmin(community);
                                              }

                                              // if (context.mounted) {
                                              //
                                              //   GayaSnackBar.show(
                                              //       context: context,
                                              //       type: GayaSnackBarType.communities,
                                              //       text: GayaStrings.request_send_success.tr);
                                              // }
                                            }
                                          } catch (e) {
                                            GayaSnackBar.show(
                                                context: context,
                                                type: GayaSnackBarType.communities,
                                                text: GayaStrings.unable_join_community.tr);
                                          } finally {
                                            isLoading = false;
                                            // no need to go below down if commQneed because we are going to questionnaire screen.
                                            if (community.isCommQNeeded == true) return;
                                            if (context.mounted) {
                                              Navigator.pop(context);
                                            }
                                            if (shouldNavigateToGroup) {
                                              SchedulerBinding.instance.addPostFrameCallback((_) {
                                                Methods.routeToGroup(community: community, shouldReplace: shouldReplace);
                                                return;
                                              });
                                            } else {
                                              Get.to(() => JoiningApprovalScreen(community: community), transition: Transition.topLevel);
                                            }
                                          }
                                        },
                                      );
                                    });
                              },
                            ),
                            MySpaces.bottom
                          ],
                        ),
                      );
                    }),
                  ),
                );
              }));
    }
  }

  static bool isRTL(String text) {
    bool isRTL = false;
    try {
      return intl.Bidi.detectRtlDirectionality(text);
    } catch (_) {}
    return isRTL;
  }

  static List<List<T>> generateListOfChunks<T>(List<T> inList, [int maxLength = 10]) {
    List<List<T>> outList = [];
    List<T> tmpList = [];
    int counter = 0;

    for (int current = 0; current < inList.length; current++) {
      if (counter != maxLength) {
        tmpList.add(inList[current]);
        counter++;
      }
      if (counter == maxLength || current == inList.length - 1) {
        outList.add(tmpList.toList());
        tmpList.clear();
        counter = 0;
      }
    }

    return outList;
  }

  static showConnectyCubeNewChatBottomSheets({required BuildContext context, required Function(UserModel?)? onUserTap}) {
    showConnectyCubeNewChatSheets(ctx: context, onUserTap: onUserTap);
  }

  static Future showModalSheetComment(BuildContext context, VoidCallback onReport,
      {VoidCallback? onCommentDelete,
      VoidCallback? onReply,
      required String commentId,
      required String postId,
      bool isReply = false,
      String? commentReplyId,
      bool? showReportOption}) async {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SingleChildScrollView(
            child: SafeArea(
              child: Column(
                children: [
                  if (showReportOption != null && showReportOption)
                    Builder(builder: (ctx) {
                      final bool isReported = (isReply && commentReplyId != null)
                          ? AppConfigurationController.to
                              .isCommentReplyReportedAlready(commentId: commentId, postId: postId, commentReplyId: commentReplyId)
                          : AppConfigurationController.to.isCommentReportedAlready(commentId: commentId, postId: postId);

                      return ListTile(
                        leading: const Icon(Icons.report),
                        title: (isReported) ? Text(GayaStrings.comment_reported_already.tr) : Text(GayaStrings.report_comment.tr),
                        onTap: (isReported) ? null : () => onReport(),
                        // Navigator.pop(context);
                      );
                    }),

                  Visibility(
                    visible: onReply != null,
                    child: ListTile(
                      leading: const Icon(Icons.reply),
                      title: Text(GayaStrings.reply_comment.tr),
                      onTap: () {
                        Navigator.pop(context);
                        onReply!();
                      },
                    ),
                  ),
                  Visibility(
                    visible: onCommentDelete != null,
                    child: ListTile(
                      leading: const Icon(Icons.delete),
                      title: Text(GayaStrings.delete_comment.tr),
                      onTap: () {
                        onCommentDelete!();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  //close
                  ListTile(
                    leading: const Icon(Icons.close),
                    title: Text(GayaStrings.close.tr),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  MySpaces.bottom
                ],
              ),
            ),
          );
        });
  }

  static Future showModalSheetProfilePicture(BuildContext context, VoidCallback? onChangePhoto, VoidCallback? onViewPhoto) async {
    if (DeviceCheck.isIOS) {
      final sheet = CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: CupertinoListTile(
              title: Text(GayaStrings.view_photo.tr,
                  style: GayaTypography.titleMedium.copyWith(color: AppColors.cupertinoBlue, fontWeight: FontWeight.w400)),
              leading: SvgIconWidget.cameraOutline(color: AppColors.cupertinoBlue),
              // leading: SvgPicture.asset(Assets.assets.icons.picturePickerIcon, color: AppColors.cupertinoBlue),
            ),
            onPressed: () => onViewPhoto!(),
          ),
          CupertinoActionSheetAction(
            child: CupertinoListTile(
              title: Text(GayaStrings.change_photo.tr,
                  style: GayaTypography.titleMedium.copyWith(color: AppColors.cupertinoBlue, fontWeight: FontWeight.w400)),
              leading: SvgIconWidget.imageOutline(color: AppColors.cupertinoBlue),
              // leading: SvgPicture.asset(Assets.assets.icons.videoPickerIcon, color: AppColors.cupertinoBlue),
            ),
            onPressed: () => onChangePhoto!(),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(GayaStrings.cancel_txt.tr,
              style: GayaTypography.titleMedium.copyWith(color: AppColors.error, fontWeight: FontWeight.w400)),
          onPressed: () => Navigator.pop(context),
        ),
      );

      showCupertinoModalPopup(context: context, builder: (context) => sheet);
      return;
    }

    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SingleChildScrollView(
            child: SafeArea(
              child: Column(
                children: [
                  ListTile(
                    leading: SvgIconWidget.cameraOutline(color: AppColors.primary),
                    // leading: SvgPicture.asset(Assets.assets.icons.picturePickerIcon),
                    title: Text(GayaStrings.view_photo.tr),
                    onTap: () {
                      onViewPhoto!();
                      //Navigator.pop(context);
                    },
                  ),

                  Visibility(
                    child: ListTile(
                      leading: SvgIconWidget.imageOutline(color: AppColors.primary),
                      // leading: SvgPicture.asset(Assets.assets.icons.videoPickerIcon),
                      title: Text(GayaStrings.change_photo.tr),
                      onTap: () => onChangePhoto!(),
                    ),
                  ),
                  //close
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10).r,
                    child: GayaButton(
                        height: 40.h,
                        borderColor: kTransparentColor,
                        // textStyle: loginController.styleEmail,
                        textStyle: GayaTypography.titleMedium.copyWith(color: AppColors.black),
                        title: GayaStrings.cancel_txt.tr,
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop("1");
                        },
                        primaryColor: AppColors.divider),
                  )
                ],
              ),
            ),
          );
        });
  }

  static showConfirmationDialogToOpenLink(Uri uri, BuildContext context) async {
    if (uri.toString().contains(Env.kDynamicLinkBaseUrl)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    if (context.mounted == false) return;
    showGayaAlertDialogButton(
      context: context,
      actionText: '',
      actionMsg: GayaStrings.open_external_link.tr,
      tapOnYes: () async {
        if (uri.path.contains('privacy')) {
          // Logging open privacy policy analytics event
          AnalyticsController.to.instance.logOpenPrivacyPolicy(
            userId: UserModel.to.uId ?? '',
          );
        }
        if (uri.path.contains('terms')) {
          // Logging open terms of use analytics event
          AnalyticsController.to.instance.logOpenTermsOfUse(
            userId: UserModel.to.uId ?? '',
          );
        }
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (context.mounted) {
          Navigator.pop(context);
        }
      },
      tapOnNo: () {
        Navigator.pop(context);
      },
    );
  }

  //shows dialog box by default to open link
  static Future launchMyUrl(
    String url, {
    Map<String, dynamic>? params,
    required BuildContext context,
    bool showConfirmationToOpenLink = true,
  }) async {
    try {
      final Uri uri = Uri.parse(url);

      if (url.contains("http") == false) {
        url = "http://$url";
      }

      if (await canLaunchUrl(uri)) {
        //show confirmation and open link on user interaction.
        showConfirmationToOpenLink ? showConfirmationDialogToOpenLink(uri, context) : await launchUrl(uri);
      }
    } catch (_) {
      GayaSnackBar.show(
        context: context,
        type: GayaSnackBarType.error,
        text: "Could not open the link",
      );
    }
  }

  static showCircularModalSheet(
    BuildContext context,
    Widget child,
  ) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: const Radius.circular(16.0).r),
        ),
        builder: (context) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 5.h,
                  width: 40.w,
                  margin: const EdgeInsets.only(top: 12, bottom: 8).r,
                  decoration: ShapeDecoration(color: AppColors.borderColor, shape: const StadiumBorder()),
                ),
                child,
              ],
            ),
          );
        });
  }

  static void openPrivacyPolicy(BuildContext context) {
    launchMyUrl(Env.kPrivacyPolicyUrl, context: context);
  }

  static void openTermsAndConditions(BuildContext context) {
    launchMyUrl(Env.kTermsAndConditionsUrl, context: context);
  }

  static void openContactUs(BuildContext context) {
    launchMyUrl(Env.kTermsAndConditionsUrl, context: context);
  }

  static Future<Uint8List?> generateLocalPdfThumbnail({required String url}) async {
    CacheServices cacheService = CacheServices();
    return await cacheService.generatelocalPdfThumbnail(url: url);
  }

////////////////////////////// Reactions/////////////////////////////////

  static getSvgIconPathFromIndex(int index) {
    if (index == 0) {
      return 'Assets/icons/vibes/filled_heart.svg';
    }
    if (index == 1) {
      return 'Assets/icons/vibes/in-love.svg';
    } else if (index == 2) {
      return 'Assets/icons/vibes/sad.svg';
    } else if (index == 3) {
      return 'Assets/icons/vibes/angry.svg';
    } else if (index == 4) {
      return 'Assets/icons/vibes/surprized.svg';
    } else if (index == 5) {
      return 'Assets/icons/vibes/funny.svg';
    } else if (index == 6) {
      /// forcefully to have outline heart icon
      return IconsAssetsPathUtils.greyHeartOutline;
    } else {
      /// default case - to return heart icon
      return IconsAssetsPathUtils.greyHeartOutline;
    }
  }

  static final reactions = [
    FeedReaction(
      reaction: SvgPicture.asset(
        'Assets/images/filled_heart.svg',
        fit: BoxFit.scaleDown,
        height: 22.r,
        width: 22.r,
      ),
      name: 'Like',
    ),
    FeedReaction(
      reaction: SvgPicture.asset(
        'Assets/images/in-love.svg',
        fit: BoxFit.scaleDown,
        height: 24.r,
        width: 24.r,
      ),
      name: 'Love',
    ),
    FeedReaction(
      reaction: SvgPicture.asset(
        'Assets/images/sad.svg',
        fit: BoxFit.scaleDown,
        height: 24.r,
        width: 24.r,
      ),
      name: 'Sad',
    ),
    FeedReaction(
      reaction: SvgPicture.asset(
        'Assets/images/surprized.svg',
        fit: BoxFit.scaleDown,
        height: 24.r,
        width: 24.r,
      ),
      name: 'Surprised',
    ),
    FeedReaction(
      reaction: SvgPicture.asset(
        'Assets/images/funny.svg',
        fit: BoxFit.scaleDown,
        height: 24.r,
        width: 24.r,
      ),
      name: 'Funny',
    ),
    FeedReaction(
      reaction: SvgPicture.asset(
        'Assets/images/angry.svg',
        fit: BoxFit.scaleDown,
        height: 24.r,
        width: 24.r,
      ),
      name: 'Angry',
    ),
  ];

  static Widget getMyReactionIcon(
    String? reactionType, {
    PostReactionDataModel? postReactionData,
    double? iconSize,

    /// show icon when there is no reaction
    bool shouldShowIcon = true,
  }) {
    int totalVibes = 0;
    if (postReactionData != null) {
      totalVibes = getTotalReactionOnPost(postReactionData: postReactionData);
    }
    // return my icon widget only
    if ((postReactionData == null || totalVibes == 0 || totalVibes == 1) && reactionType != null) {
      // return my reaction only
      return getReactionIconByReactionType(reactionType, iconSize);
    }
    // return default icon
    if (totalVibes == 0 || postReactionData == null) {
      if (!shouldShowIcon) return const SizedBox.shrink();
      return getDefaultReactionsIconsStack(iconSize);
    }
    // return other users icon widgets only
    if (totalVibes > 0 && reactionType == null) {
      if (!shouldShowIcon) return const SizedBox.shrink();
      return getReactionIconsWidget(
          totalVibes: totalVibes, isReactionedByMe: false, postReactionData: postReactionData, iconSize: iconSize);
    }
    // return mix icon widget
    if (totalVibes > 0 && reactionType != null) {
      return getReactionIconsWidget(totalVibes: totalVibes, isReactionedByMe: true, postReactionData: postReactionData, iconSize: iconSize);
    }

    return getDefaultReactionsIconsStack(iconSize);
  }

  static Widget getReactionIconByReactionType(
    String? reactionType,
    double? iconSize,
  ) {
    if (reactionType == null) {
      return getDefaultReactionsIconsStack(iconSize);
    }
    if (reactionType == 'Like') {
      return SvgPicture.asset(
        'Assets/icons/vibes/filled_heart.svg',
        fit: BoxFit.scaleDown,
        height: iconSize ?? 19.r,
        width: iconSize ?? 19.r,
      );
    }
    if (reactionType == 'Love') {
      return SvgPicture.asset(
        'Assets/icons/vibes/in-love.svg',
        fit: BoxFit.scaleDown,
        height: iconSize ?? 19.r,
        width: iconSize ?? 19.r,
      );
    }
    if (reactionType == 'Sad') {
      return SvgPicture.asset(
        'Assets/icons/vibes/sad.svg',
        fit: BoxFit.scaleDown,
        height: iconSize ?? 19.r,
        width: iconSize ?? 19.r,
      );
    }
    if (reactionType == 'Surprised') {
      return SvgPicture.asset(
        'Assets/icons/vibes/surprized.svg',
        fit: BoxFit.scaleDown,
        height: iconSize ?? 19.r,
        width: iconSize ?? 19.r,
      );
    }
    if (reactionType == 'Funny') {
      return SvgPicture.asset(
        'Assets/icons/vibes/funny.svg',
        fit: BoxFit.scaleDown,
        height: iconSize ?? 19.r,
        width: iconSize ?? 19.r,
      );
    }
    if (reactionType == 'Angry') {
      return SvgPicture.asset(
        'Assets/icons/vibes/angry.svg',
        fit: BoxFit.scaleDown,
        height: iconSize ?? 19.r,
        width: iconSize ?? 19.r,
      );
    }
    return getDefaultReactionsIconsStack(iconSize);
  }

  static Widget getReactionTextByReactionType(String? reactionType, double? fontSize) {
    if (reactionType == null) {
      return getDefaultReactionsText(fontSize);
    }
    if (reactionType == 'Like') {
      return Text(
        "1 ${GayaStrings.likes.tr}",
        style: (fontSize == null)
            ? GayaTypography.subtitleMedium.copyWith(color: Colors.red, fontSize: fontSize)
            : GayaTypography.caption.copyWith(color: Colors.red, fontSize: fontSize),
      );
    }
    if (reactionType == 'Love') {
      return Text(
        GayaStrings.love.tr,
        style: (fontSize == null)
            ? GayaTypography.subtitleMedium.copyWith(color: Colors.red, fontSize: fontSize)
            : GayaTypography.caption.copyWith(color: Colors.red, fontSize: fontSize),
      );
    }
    if (reactionType == 'Sad') {
      return Text(
        GayaStrings.sad.tr,
        style: (fontSize == null)
            ? GayaTypography.subtitleMedium.copyWith(color: kYellowColor)
            : GayaTypography.caption.copyWith(color: kYellowColor, fontSize: fontSize),
      );
    }
    if (reactionType == 'Surprised') {
      return Text(
        GayaStrings.surprised.tr,
        style: (fontSize == null)
            ? GayaTypography.subtitleMedium.copyWith(color: kYellowColor)
            : GayaTypography.caption.copyWith(color: kYellowColor, fontSize: fontSize),
      );
    }
    if (reactionType == 'Funny') {
      return Text(
        GayaStrings.funny.tr,
        style: (fontSize == null)
            ? GayaTypography.subtitleMedium.copyWith(color: kYellowColor)
            : GayaTypography.caption.copyWith(color: kYellowColor, fontSize: fontSize),
      );
    }
    if (reactionType == 'Angry') {
      return Text(
        GayaStrings.angry.tr,
        style: (fontSize == null)
            ? GayaTypography.subtitleMedium.copyWith(color: Colors.red, fontSize: fontSize)
            : GayaTypography.caption.copyWith(color: Colors.red, fontSize: fontSize),
      );
    }
    return getDefaultReactionsText(fontSize);
  }

  static Widget getReactionIconsWidget(
      {required int totalVibes, required bool isReactionedByMe, required PostReactionDataModel postReactionData, double? iconSize}) {
    var map = {
      0: postReactionData.like,
      1: postReactionData.inLove,
      2: postReactionData.sad,
      3: postReactionData.angry,
      4: postReactionData.surprized,
      5: postReactionData.funny,
    };
    if (totalVibes == 0) return getDefaultReactionsIconsStack(iconSize);
    var sortMapByValue = Map.fromEntries(map.entries.toList()..sort((e1, e2) => e1.value.compareTo(e2.value)));
    final reverseM = LinkedHashMap.fromEntries(sortMapByValue.entries.toList().reversed);
    List<int> keys = reverseM.keys.toList();
    reverseM.remove(keys[5]);
    reverseM.remove(keys[4]);
    reverseM.remove(keys[3]);
    reverseM.removeWhere((key, value) {
      return value == 0;
    });
    return _buildReactionsIconsStack(
        _getIconPath(reverseM: reverseM, reactionData: postReactionData, isReactedByMe: isReactionedByMe),
        (reverseM.keys.length < 2) ? null : getSvgIconPathFromIndex(reverseM.keys.toList()[1]),
        (reverseM.keys.length < 3) ? null : getSvgIconPathFromIndex(reverseM.keys.toList()[2]),
        iconSize);
  }

  /// decides either to return outlined heart  or filled heart according
  /// to the [isReactedByMe] value
  static String _getIconPath(
      {required LinkedHashMap<int, int> reverseM, required PostReactionDataModel reactionData, required bool isReactedByMe}) {
    return reverseM.keys.length == 1 && reverseM.values.first == reactionData.like && !isReactedByMe
        ? getSvgIconPathFromIndex(6)
        : getSvgIconPathFromIndex(reverseM.keys.first);
  }

  static int getTotalReactionOnPost({required PostReactionDataModel postReactionData}) {
    int totalVibes = 0;
    var map = {
      0: postReactionData.like,
      1: postReactionData.inLove,
      2: postReactionData.sad,
      3: postReactionData.angry,
      4: postReactionData.surprized,
      5: postReactionData.funny,
    };
    totalVibes = postReactionData.like +
        postReactionData.inLove +
        postReactionData.angry +
        postReactionData.sad +
        postReactionData.surprized +
        postReactionData.funny;
    return totalVibes;
  }

  static getShortForm(var number) {
    var f = NumberFormat.compact(locale: "en_US");
    return f.format(number);
  }

  static Widget _buildReactionsIconsStack(String path1, String? path2, String? path3, double? iconSize) {
    return Container(
      color: Colors.transparent,
      child: Stack(
        children: [
          if (path3 != null)
            Positioned(
              child: Padding(
                padding: EdgeInsets.only(left: iconSize != null ? 10 : 20).r,
                child: SvgPicture.asset(
                  path3,
                  fit: BoxFit.scaleDown,
                  height: iconSize ?? 19.r,
                  width: iconSize ?? 19.r,
                ),
              ),
            ),
          if (path2 != null)
            Positioned(
              child: Padding(
                padding: EdgeInsets.only(left: iconSize != null ? 7 : 10).r,
                child: SvgPicture.asset(
                  path2,
                  fit: BoxFit.scaleDown,
                  height: iconSize ?? 19.r,
                  width: iconSize ?? 19.r,
                ),
              ),
            ),
          SvgPicture.asset(
            path1,
            fit: BoxFit.scaleDown,
            height: iconSize ?? 19.r,
            width: iconSize ?? 19.r,
          ),
        ],
      ),
    );
  }

  static Widget getMyReactionText(
    String? reactionType, {
    PostReactionDataModel? postReactionData,
    double? fontSize,
    bool shouldShowNumbers = true,
  }) {
    int totalVibes = 0;

    if (postReactionData != null) {
      totalVibes = getTotalReactionOnPost(postReactionData: postReactionData);
    }
    // return my icon widget only
    if ((postReactionData == null || totalVibes == 0 || totalVibes == 1) && reactionType != null) {
      // return my reaction only
      return getReactionTextByReactionType(reactionType, fontSize);
    }
    // return default icon
    if (totalVibes == 0 || postReactionData == null) {
      return getDefaultReactionsText(fontSize, shouldShowNumbers: shouldShowNumbers);
    }
    // return other users icon widgets only
    if (totalVibes > 0 && reactionType == null) {
      return Text('${getShortForm(totalVibes)} ${postReactionData.isLikeOnly ? GayaStrings.likes.tr : GayaStrings.vibes.tr}',
          style: (fontSize == null)
              ? GayaTypography.subtitleMedium.copyWith(color: AppColors.secondary, fontSize: fontSize)
              : GayaTypography.caption.copyWith(color: AppColors.secondary, fontSize: fontSize));
    }
    // return mix text widget
    if (totalVibes > 0 && reactionType != null) {
      return Text(
        '${getShortForm(totalVibes)} ${!postReactionData.isLikeOnly ? GayaStrings.vibes.tr : GayaStrings.likes.tr}',
        style: (fontSize == null)
            ? GayaTypography.subtitleMedium.copyWith(
                color: (reactionType == 'Like' || reactionType == 'Love' || reactionType == 'Angry') ? Colors.red : const Color(0XFFffda6b),
                fontSize: fontSize)
            : GayaTypography.caption.copyWith(
                color: (reactionType == 'Like' || reactionType == 'Love' || reactionType == 'Angry') ? Colors.red : const Color(0XFFffda6b),
                fontSize: fontSize),
      );
    }

    return getDefaultReactionsText(fontSize);
  }

  static Widget getDefaultReactionsIconsStack(double? iconSize) {
    double? iconModifiedSize = (iconSize == null) ? null : iconSize - 2;

    return SvgIconWidget.heartOutline(
      height: 18.r,
      width: 18.r,
      color: AppColors.secondary,
    );
    return SvgPicture.asset(
      'Assets/icons/outline/heart_outline.svg',
      fit: BoxFit.scaleDown,
      color: AppColors.secondary,
      height: iconModifiedSize ?? 18.r,
      width: iconModifiedSize ?? 18.r,
    );
  }

  static Widget getDefaultReactionsText(double? fontSize, {bool shouldShowNumbers = true}) {
    return Text(
      shouldShowNumbers ? "0 ${GayaStrings.likes.tr}" : GayaStrings.like_txt.tr,
      style: (fontSize == null)
          ? GayaTypography.subtitleMedium.copyWith(color: AppColors.secondary)
          : GayaTypography.caption.copyWith(color: AppColors.secondary, fontSize: fontSize),
    );
  }

  static String getEmojiByType(String? reactionType) {
    if (reactionType == null) {
      return '${GayaStrings.likes.tr} ❤️';
    }
    if (reactionType == 'Like') {
      return '${GayaStrings.likes.tr} ❤️';
    }
    if (reactionType == 'Love') {
      return '${GayaStrings.love.tr} 😍';
    }
    if (reactionType == 'Sad') {
      return '${GayaStrings.sad.tr} 😢';
    }
    if (reactionType == 'Surprised') {
      return '${GayaStrings.surprised.tr} 😮';
    }
    if (reactionType == 'Funny') {
      return '${GayaStrings.funny.tr} 😂';
    }
    if (reactionType == 'Angry') {
      return '${GayaStrings.angry.tr} 😡';
    }
    return '${GayaStrings.likes.tr} ❤';
  }

  static List<int>? getReactionsCountsList({PostReactionDataModel? postReactionData}) {
    List<int> reactionsCountList = [];

    if (postReactionData == null) return null;

    var map = {
      0: postReactionData.like,
      1: postReactionData.inLove,
      2: postReactionData.sad,
      3: postReactionData.surprized,
      4: postReactionData.funny,
      5: postReactionData.angry,
    };

    for (var element in map.entries) {
      reactionsCountList.add(element.value);
    }
    return reactionsCountList;
  }

  static Future<List<T>> parseItems<T extends Object?>(
      QuerySnapshot<Map<String, dynamic>> snapshot, T? Function(Map<String, dynamic> data)? fromMap) async {
    List<T> items = [];
    final rawItems = snapshot.docs;
    for (var rawItem in rawItems) {
      try {
        if (fromMap == null) continue;
        final T? item = fromMap(rawItem.data());
        if (item != null) {
          items.add(item);
        }
      } catch (error) {
        MyLoggerServices.to.print("Error in makingModel: $error");
      }
    }
    return items;
  }

  // get user streak icon according to user's streak days
  static Widget getUserStreakIconOnUserStreakDays(int streakCount) {
    Widget streakIcons = SvgIconWidget.fireYellow;
    if (streakCount == 3) {
      streakIcons = SvgIconWidget.fireYellow;
    } else if (streakCount == 7) {
      streakIcons = SvgIconWidget.fireRed;
    } else if (streakCount == 30) {
      streakIcons = SvgIconWidget.firePrimary;
    } else if (streakCount >= 90) {
      streakIcons = SvgIconWidget.fireGreen;
    } else {
      streakIcons = SvgIconWidget.fireYellow;
    }
    return SizedBox(height: 19.r, width: 17.r, child: streakIcons);
  }
}
