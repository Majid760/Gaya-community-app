import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaya/controller/app_config_controller.dart';
import 'package:gaya/controller/homepage.controller.dart';
import 'package:gaya/controller/profile.controller.dart';
import 'package:gaya/controller/report_controller.dart';
import 'package:gaya/controller/topics.controller.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/shared/view/widget/gaya_alert_dialog.dart';
import 'package:gaya/shared/view/widget/gaya_back_button.dart';
import 'package:gaya/shared/view/widget/gaya_report_dialog.dart';
import 'package:gaya/shared/view/widget/gaya_snackbar.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/refresh_builder_utils.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/view/Auth/controller/login.controller.dart';
import 'package:gaya/view/community/communities/components/contact_us_view.dart';
import 'package:gaya/view/profile/components/skeletons.dart';
import 'package:gaya/view/profile/contact_us/model/contact_us.dart';
import 'package:gaya/view/saved.posts.view.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:provider/provider.dart';

import '../components/button.component.dart';
import '../components/report_dialogue.dart';
import '../controller/firebase_analytics_controller.dart';
import '../scripts/delete_account_script.dart';
import '../utils/assets_icons.dart';
import '../utils/const.dart';
import '../utils/gaya_text_widget.dart';
import '../utils/methods.dart';
import '../utils/textstyles.dart';
import '../utils/theme/app_spaces.dart';
import '../widgets/group_view_widget/settings.widget.dart';
import '../widgets/profile.widgets/button.widget.dart';
import '../widgets/profile.widgets/figure.widget.dart';
import '../widgets/profile.widgets/profileimage.widget.dart';
import '../widgets/topic_view_widgets/interest.widget.dart';
import 'community/communities/components/hidden_communities_view.dart';

// CupertinoActivityIndicator(color: loadingColor),
final _debouncer = Debouncer(delay: const Duration(milliseconds: 3000));

class ProfileView extends StatefulWidget {
  final bool canPop;

  const ProfileView({Key? key, this.canPop = true}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  var getUserDetailsFunc;
  late Future<int> myCommunitiesLength;
  late Future<int> myFriendsCount;
  User? user = FirebaseAuth.instance.currentUser;
  late ProfileController profileController;

  @override
  void initState() {
    profileController = Provider.of<ProfileController>(context, listen: false);
    _onRefresh();
    super.initState();
  }

  /// Refreshes the profile page
  _onRefresh({bool shouldNotify = false}) async {
    getUserDetailsFunc = context.read<ProfileController>().getuseProfileDetails();
    myCommunitiesLength = context.read<ProfileController>().getMyCommunitiesCount();
    myFriendsCount = context.read<ProfileController>().getCurrentUsersFriendCount();
    if (shouldNotify) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        shape: Border(bottom: BorderSide(color: kBaseGrey.withOpacity(0.5))),
        automaticallyImplyLeading: false,
        title: Text(GayaStrings.profile_txt.tr, style: CustomTypography.bodyStyle),
        leading: widget.canPop ? const GayaBackButton() : null,
        actions: [
          FirebaseAuth.instance.currentUser == null
              ? const SizedBox()
              : Row(
                  children: [
                    IconButton(
                        visualDensity: const VisualDensity(horizontal: -2),
                        tooltip: GayaStrings.settings_txt.tr,
                        onPressed: () {
                          user == null
                              ? Routes.loginView()
                              : Methods.showCircularModalSheet(
                                  context,
                                  SafeArea(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 20).r,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              GestureDetector(
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text(GayaStrings.cancel_txt.tr,
                                                      style: CustomTypography.body2EnableStyle1.copyWith(fontSize: 14.sp))),
                                              Text(GayaStrings.settings_txt.tr, style: CustomTypography.bodyStyle),
                                              //place holder only
                                              Opacity(opacity: 0, child: Text(GayaStrings.cancel_txt.tr))
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        CupertinoListTileActionWidget(
                                            title: GayaStrings.delete_my_account.tr,
                                            onTap: () async {
                                              Navigator.pop(context);
                                              //show bottom sheet
                                              showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  builder: (context) => Padding(
                                                        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
                                                        child: const DeleteAccountPopup(),
                                                      ));
                                            }),
                                        CupertinoListTileActionWidget(
                                            title: "Change Language",
                                            onTap: () async {
                                              Navigator.pop(context);
                                              Methods.showLanguageSwitchModalSheet(context: context);
                                            }),
                                        CupertinoListTileActionWidget(
                                            title: GayaStrings.account_privacy.tr,
                                            onTap: () async {
                                              Navigator.pop(context);
                                              Methods.showDmStatusSettingModalSheet(context: context);
                                            }),
                                        CupertinoListTileActionWidget(
                                          title: GayaStrings.hidden_communities.tr,
                                          onTap: () async {
                                            Navigator.pop(context);

                                            // Logging view all hidden communities event
                                            AnalyticsController.to.instance.logViewAllHiddenCommunities(
                                              userId: UserModel.to.uId ?? '',
                                            );

                                            Get.to(() => const HiddenCommunitiesView());
                                          },
                                        ),
                                        CupertinoListTileActionWidget(
                                          title: GayaStrings.report_problem.tr,
                                          onTap: () async {
                                            Navigator.pop(context);
                                            reportTextFieldBottomModal(
                                              context,
                                              onSubmit: (String reportMsg) async {
                                                ReportController.to.reportAProblem(contactUs: ContactUs.problem(message: reportMsg));
                                                GayaSnackBar.show(
                                                    context: context,
                                                    type: GayaSnackBarType.success,
                                                    text: GayaStrings.appreciate_feedback.tr);
                                              },
                                            );
                                          },
                                        ),
                                        CupertinoListTileActionWidget(
                                          title: GayaStrings.privacy_policy.tr,
                                          onTap: () => Methods.openPrivacyPolicy(context),
                                        ),
                                        CupertinoListTileActionWidget(
                                          title: GayaStrings.terms_of_use.tr,
                                          onTap: () => Methods.openTermsAndConditions(context),
                                        ),
                                        CupertinoListTileActionWidget(
                                          title: GayaStrings.contact_us.tr,
                                          onTap: () async {
                                            Navigator.pop(context);

                                            /// Navigating to contact us page
                                            final isFormSubmitted = await Get.to(() => const ContactUsView());
                                            if (isFormSubmitted != null && isFormSubmitted == true) {
                                              // ignore: use_build_context_synchronously
                                              GayaSnackBar.show(
                                                  context: context,
                                                  type: GayaSnackBarType.success,
                                                  text: GayaStrings.appreciate_feedback.tr);
                                            }
                                          },
                                        ),
                                        const SizedBox(height: 10),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 20).r,
                                          child: GayaButton(
                                              title: GayaStrings.log_out.tr,
                                              islogout: true,
                                              onPressed: () async {
                                                Navigator.pop(context);
                                                showGayaAlertDialogButton(
                                                    context: context,
                                                    actionMsg: "${GayaStrings.are_you_sure.tr} ",
                                                    actionText: GayaStrings.log_out.tr,
                                                    tapOnYes: () async {
                                                      Navigator.pop(context);
                                                      await Provider.of<LoginController>(context, listen: false).logout(context);
                                                    },
                                                    tapOnNo: () => Navigator.pop(context));
                                              },
                                              borderColor: kTransparentColor,
                                              height: 50,
                                              primaryColor: kBaseGrey,
                                              textStyle: const TextStyle(color: kRedColor, fontWeight: FontWeight.w500, fontSize: 14),
                                              width: MediaQuery.sizeOf(context).width),
                                        ),
                                        const SizedBox(height: 10),
                                      ],
                                    ),
                                  ));
                        },
                        icon: SvgIconWidget.settingsOutline()),
                    const SizedBox(
                      width: distance_10,
                    ),
                  ],
                ),
        ],
        centerTitle: true,
        backgroundColor: kTransparentColor,
        elevation: 0,
      ),
      body: FirebaseAuth.instance.currentUser == null
          ? Center(
              child: CupertinoButton(
              color: kprimaryColor,
              onPressed: () => Routes.loginView(),
              child: Text(GayaStrings.sign_in.tr, style: CustomTypography.body2Style),
            ))
          : Stack(
              children: [
                FutureBuilder<DocumentSnapshot?>(
                    future: getUserDetailsFunc,
                    builder: ((context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator.adaptive(backgroundColor: kprimaryColor),
                        );
                      } else if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasError) {
                          return Text(GayaStrings.error_occurred.tr);
                        }

                        if (snapshot.hasData && snapshot.data != null && snapshot.data?.data() != null) {
                          DocumentSnapshot userData = snapshot.data as DocumentSnapshot;
                          UserModel userDetailsModel = UserModel.fromSnapshot(userData);
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20).r,
                            child: EasyRefresh(
                              simultaneously: true,
                              header: RefreshBuilderUtils.headerAbove,
                              onRefresh: () => _onRefresh(shouldNotify: true),
                              child: ListView(
                                children: [
                                  const SizedBox(height: distance_15),
                                  ProfilePicWidget(
                                    camera: Positioned(
                                        top: 0,
                                        right: 00,
                                        child: IconButton(
                                          icon: SvgIconWidget.cameraFilled(color: AppColors.white),
                                          // icon: const Icon(Icons.camera_alt, color: kWhiteColor),
                                          onPressed: () async {
                                            bool shouldRefresh = await profileController.imagePickerCover(context);
                                            if (shouldRefresh) {
                                              // Logging user profile update event to analytics
                                              AnalyticsController.to.instance.logUpdateProfile(
                                                updationType: 'profileCover',
                                                userId: userDetailsModel.uId,
                                                userName: userDetailsModel.name,
                                                userEmail: userDetailsModel.email,
                                              );

                                              Routes.switchView(initialIndex: 4);
                                            }
                                          },
                                        )),
                                    oncovertap: () {
                                      if (userDetailsModel.coverPhoto != null && userDetailsModel.coverPhoto != "") {
                                        Routes.openImages(urls: [userDetailsModel.coverPhoto ?? ""], index: 0, ctx: context);
                                      }
                                    },
                                    onproftap: () {
                                      Methods.showModalSheetProfilePicture(
                                        context,
                                        () {
                                          Navigator.pop(context);
                                          Routes.editProfile(userModel: userDetailsModel);
                                        },
                                        // Navigator.pop(context);
                                        // Routes.editProfile(userModel: userDetailsModel);
                                        // Navigator.of(context).push(
                                        //   MaterialPageRoute(builder: (context) => EditProfileView(userModel: userDetailsModel)),
                                        // );
                                        () {
                                          if (userDetailsModel.profilePicture != null && userDetailsModel.profilePicture != "") {
                                            Routes.openImages(urls: [userDetailsModel.profilePicture ?? ""], index: 0, ctx: context);
                                          }
                                        },
                                      );
                                    },
                                    coverPhoto: userDetailsModel.coverPhoto,
                                    profilePic: userDetailsModel.profilePicture,

                                    /// COMMENTED For INFLUENCE BAR
                                    // streakIcon: Methods.getUserStreakIconOnUserStreakDays(userDetailsModel.userOngoingStreakTotalDays),
                                  ),
                                  Center(
                                    child: Text(
                                      userDetailsModel.name.toString(),
                                      style: CustomTypography.subHeading,
                                      textDirection: context.read<HomePageController>().isRTL(userDetailsModel.name.toString())
                                          ? TextDirection.rtl
                                          : TextDirection.ltr,
                                    ),
                                  ),
                                  const SizedBox(height: distance_10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: FutureBuilder<int>(
                                            future: myFriendsCount,
                                            builder: ((context, snapshot) {
                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                return const CountSkeletonWidget();
                                              } else if (snapshot.connectionState == ConnectionState.done) {
                                                if (snapshot.hasData && snapshot.data != null) {
                                                  return GestureDetector(
                                                    onTap: () {
                                                      if (snapshot.data == null || snapshot.data == 0) return;
                                                      Routes.myFriendView();
                                                    },
                                                    child: Container(
                                                      color: Colors.transparent,
                                                      child: FiguresWidget(
                                                        number: (snapshot.data).toString(),
                                                        title: GayaStrings.friends_txt.tr,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }
                                              return const SizedBox.shrink();
                                            })),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: FutureBuilder<int>(
                                            future: myCommunitiesLength,
                                            builder: (context, communitesCountSnapshot) {
                                              if (communitesCountSnapshot.connectionState == ConnectionState.waiting) {
                                                return const CountSkeletonWidget();
                                              } else if (communitesCountSnapshot.connectionState == ConnectionState.done) {
                                                if (communitesCountSnapshot.hasData) {
                                                  return GestureDetector(
                                                    onTap: () {
                                                      if (communitesCountSnapshot.data == null || communitesCountSnapshot.data == 0) return;
                                                      Routes.seeAllMyCommunitiesView();
                                                    },
                                                    child: Container(
                                                      color: Colors.transparent,
                                                      child: FiguresWidget(
                                                        number: (communitesCountSnapshot.data ?? 0).toString(),
                                                        title: GayaStrings.communities_txt.tr,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }
                                              return const SizedBox.shrink();
                                            }),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: FiguresWidget(
                                          number: (UserModel.to.userTotalCrowns ?? 0).toString(),
                                          title: GayaStrings.crowns_txt.tr,
                                          flower: SvgIconWidget.crownFilledd(color: AppColors.warning, height: 16.h),
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: distance_15,
                                  ),
                                  Center(
                                      child: GayaTextWidget(
                                    (userDetailsModel.bio ?? "").toString(),
                                    style: CustomTypography.body4StyleLowWeight,
                                    trimLines: 20,
                                    shouldIgnoreSelectableText: false,
                                    colorClickableText: kprimaryColor,
                                  )

                                      /*SelectableLinkify(
                                  onOpen: (link) async {
                                    if (await canLaunch(link.url)) {
                                      await launch(link.url);
                                    } else {
                                      throw 'Could not launch $link';
                                    }
                                    ;
                                  },
                                  textDirection: context.read<HomePageController>().isRTL(userDetailsModel.bio.toString())
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                  text: userDetailsModel.bio.toString(),
                                  textAlign: TextAlign.center,
                                  style: CustomTypography.body4StyleLowWeight,
                                  CustomTypography.linkStyle: TextStyle(color: kprimaryColor),
                                ),*/
                                      ),
                                  const SizedBox(height: distance_10),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 6,
                                        child: ButtonWidget(
                                            onTap: () async {
                                              if (FirebaseAuth.instance.currentUser == null) {
                                                Routes.loginView(clearPreviousRoutes: true);
                                                return;
                                              }
                                              profileController.image = null;
                                              Routes.editProfile(userModel: userDetailsModel);
                                            },
                                            buttonColor: kBaseGrey,
                                            color: kBlackColor.withOpacity(0.5),
                                            title: GayaStrings.edit_profile.tr,
                                            style: CustomTypography.body2StyleWeightBlack),
                                      ),
                                      const SizedBox(width: distance_5),
                                      Expanded(
                                        child: CupertinoIconButton(
                                          onPressed: () => Routes.savedPostsView(),
                                          //Navigator.of(context).push(_createRoute());
                                          icon: Container(
                                              alignment: Alignment.center,
                                              height: distance_40,
                                              padding: const EdgeInsets.symmetric(horizontal: distance_5),
                                              decoration: BoxDecoration(
                                                color: kBaseGrey,
                                                borderRadius: BorderRadius.circular(borderRadius_4),
                                              ),
                                              child: SvgIconWidget.bookmarkOutline()),
                                        ),
                                      ),
                                    ],
                                  ),
                                  /*
                               /// COMMENTED For INFLUENCE BAR
                               SizedBox(height: 16.r),
                                  Text(GayaStrings.influence_txt.tr, style: GayaTypography.titleMedium),
                                  SizedBox(height: 8.r),
                                  GestureDetector(
                                    onTap: () {
                                      Methods.showinfluenceScoreBottomSheet(context);
                                    },
                                    child: Container(
                                      height: 42.r,
                                      alignment: Alignment.center,
                                      child: Builder(builder: (context) {
                                        return InfluenceBarWidget(isMe: true, score: userDetailsModel.userInfluenceScoreWithCrowns);
                                      }),
                                    ),
                                  )
                                  SizedBox(height: 16.r),
                                  Text(userDetailsModel.getContinuesStreakDaysAccordingToSingularPlugarCount,
                                      style: GayaTypography.titleMedium),
                                  Text(userDetailsModel.getRemainingStreakDaysAccordingToSingularPlugarCount,
                                      style: GayaTypography.subtitleRegular.copyWith(color: AppColors.secondary)),
                                  SizedBox(height: 8.r),
                                  ,
                                  GestureDetector(
                                    onTap: () {
                                      Methods.showinfluenceStreakBottomSheet(context);
                                    },
                                    child: SizedBox(
                                      height: 42.r,
                                      // alignment: Alignment.start,
                                      child: Builder(builder: (context) {
                                        return InfluenceStreakWidget(
                                          streakScore:
                                              userDetailsModel.userStreakPercentage <= 5 ? 6 : userDetailsModel.userStreakPercentage,
                                        );
                                      }),
                                    ),
                                  ),
                            */
                                  SizedBox(height: 12.r),
                                  Wrap(
                                    direction: Axis.horizontal,
                                    runAlignment: WrapAlignment.start,
                                    // runSpacing: distance_8,
                                    spacing: distance_8,
                                    children: List.generate(userDetailsModel.interests?.length ?? 0, (index) {
                                      return InterestWidget(
                                        color: kBaseGrey,
                                        horizontalDistance: distance_40,
                                        image: userDetailsModel.interests?[index].image ?? '',
                                        title: userDetailsModel.interests?[index].title ?? '',
                                        onTap: () {
                                          Routes.seeAllInterestCommunitiesView(communityName: userDetailsModel.interests?[index].title);
                                          //  helper.getName();
                                        },
                                      );
                                    }),
                                  ),

                                  ///space
                                  MySpaces.bottom
                                ],
                              ),
                            ),
                          );
                        }
                      }
                      FirebaseAuth.instance.signOut();
                      return Center(child: Text(GayaStrings.something_wrong.tr));
                    })),
                Consumer<LoginController>(builder: (context, loginController, child) {
                  return Visibility(
                    visible: loginController.isLogoutLoading,
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        alignment: Alignment.center,
                        height: MediaQuery.sizeOf(context).height * 0.18,
                        width: MediaQuery.sizeOf(context).width * .4,
                        decoration: const BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.all(Radius.circular(10))),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CupertinoActivityIndicator(color: AppColors.black),
                              const SizedBox(height: distance_16),
                              Text(GayaStrings.logging_out.tr,
                                  style: CustomTypography.bodyStyle.copyWith(color: AppColors.white), textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }

  // @override
  // void dispose() {
  //   Provider.of<ProfileController>(context, listen: false).resetFields();
  //   super.dispose();
  // }

//Appbar
  PreferredSizeWidget getAppbar(BuildContext context) {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;

    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      shape: Border(
          bottom: BorderSide(
        color: kBaseGrey.withOpacity(0.5),
      )),
      automaticallyImplyLeading: false,
      title: Text(
        GayaStrings.profile_txt.tr,
        style: CustomTypography.bodyStyle,
      ),
      actions: [
        firebaseAuth.currentUser == null
            ? const SizedBox()
            : Row(
                children: [
                  InkWell(
                    onTap: () {
                      user == null
                          ? Routes.loginView()
                          : showModalBottomSheet(
                              context: context,
                              builder: (context) => Container(
                                padding: const EdgeInsets.all(20),
                                height: 270,
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
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: MediaQuery.sizeOf(context).width,
                                      child: Stack(
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: InkWell(
                                                onTap: () {
                                                  Get.back();
                                                },
                                                child: Text(GayaStrings.cancel_txt.tr, style: CustomTypography.body2EnableStyle1)),
                                          ),
                                          Align(alignment: Alignment.center, child: Text(GayaStrings.settings_txt.tr, style: CustomTypography.bodyStyle))
                                        ],
                                      ),
                                    ),
                                    CupertinoListTileActionWidget(
                                        title: GayaStrings.delete_my_account.tr,
                                        onTap: () async {
                                          Get.back();
                                          //show bottom sheet
                                          showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              builder: (context) => Padding(
                                                padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
                                                    child: const DeleteAccountPopup(),
                                                  ));
                                        }),
                                    CupertinoListTileActionWidget(
                                        title: GayaStrings.report_problem.tr,
                                        onTap: () async {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return const ReportDialogue();
                                              });
                                        }),
                                    CupertinoListTileActionWidget(
                                      title: GayaStrings.privacy_policy.tr,
                                      onTap: () => Methods.openPrivacyPolicy(context),
                                    ),
                                    CupertinoListTileActionWidget(
                                      title: GayaStrings.terms_of_use.tr,
                                      onTap: () => Methods.openTermsAndConditions(context),
                                    ),
                                    const SizedBox(height: 10),
                                    GayaButton(
                                        title: GayaStrings.log_out.tr,
                                        islogout: true,
                                        onPressed: () async {
                                          // await Provider.of<LoginController>(context, listen: false).logout(context);
                                          showGayaAlertDialogButton(
                                              context: context,
                                              actionMsg: "${GayaStrings.are_you_sure.tr} ",
                                              actionText: GayaStrings.log_out.tr,
                                              tapOnYes: () async {
                                                context.read<TopicsController>().selectedList.clear();
                                                Navigator.pop(context);
                                                await Provider.of<LoginController>(context, listen: false).logout(context);
                                              },
                                              tapOnNo: () => Get.back());
                                        },
                                        borderColor: kTransparentColor,
                                        height: 50,
                                        primaryColor: kBaseGrey,
                                        textStyle: const TextStyle(color: kRedColor, fontWeight: FontWeight.w500, fontSize: 14),
                                        width: MediaQuery.sizeOf(context).width),
                                  ],
                                ),
                              ),
                            );
                    },
                    child: SvgPicture.asset(
                      "Assets/icons/settings.svg",
                      color: kBlackColor.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(
                    width: distance_10,
                  ),
                ],
              ),
      ],
      centerTitle: true,
      backgroundColor: kTransparentColor,
      elevation: 0,
    );
  }

//Body
  Widget getBody(
    BuildContext context,
  ) {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;

    return firebaseAuth.currentUser == null
        ? Center(
            child: CupertinoButton(
            color: kprimaryColor,
            onPressed: () => Routes.loginView(),
            child: Text(
              GayaStrings.sign_in.tr,
              style: CustomTypography.body2Style,
            ),
          ))
        : FutureBuilder<DocumentSnapshot?>(
            future: getUserDetailsFunc,
            builder: ((context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(backgroundColor: kprimaryColor),
                );
              } else if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Text(GayaStrings.error_occurred.tr);
                }

                if (snapshot.hasData && snapshot.data != null && snapshot.data?.data() != null) {
                  DocumentSnapshot userData = snapshot.data as DocumentSnapshot;
                  UserModel userDetailsModel = UserModel.fromSnapshot(userData);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: distance_20),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: distance_15),
                          ProfilePicWidget(
                            camera: Positioned(
                                top: 0,
                                right: 00,
                                child: IconButton(
                                  icon: const Icon(Icons.camera_alt, color: kWhiteColor),
                                  onPressed: () async {
                                    bool shouldRefresh = await profileController.imagePickerCover(context);
                                    if (shouldRefresh) {
                                      Routes.switchView(initialIndex: 4);
                                    }
                                  },
                                )),
                            oncovertap: () {
                              if (userDetailsModel.coverPhoto != null && userDetailsModel.coverPhoto != "") {
                                Routes.openImages(urls: [userDetailsModel.coverPhoto ?? ""], index: 0, ctx: context);
                              }
                            },
                            onproftap: () {
                              if (userDetailsModel.profilePicture != null && userDetailsModel.profilePicture != "") {
                                Routes.openImages(urls: [userDetailsModel.profilePicture ?? ""], index: 0, ctx: context);
                              }
                            },
                            coverPhoto: userDetailsModel.coverPhoto,
                            profilePic: userDetailsModel.profilePicture,
                          ),
                          Center(
                            child: Text(
                              userDetailsModel.name.toString(),
                              style: CustomTypography.subHeading,
                              textDirection: context.read<HomePageController>().isRTL(userDetailsModel.name.toString())
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                            ),
                          ),
                          const SizedBox(height: distance_10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              FutureProvider<int>(
                                initialData: 0,
                                create: (context) => myFriendsCount,
                                child: Consumer<int>(builder: (context, count, _) {
                                  return FiguresWidget(number: (count).toString(), title: 'Friends');
                                }),
                              ),
                              FutureBuilder<int>(
                                  initialData: 0,
                                  future: myCommunitiesLength,
                                  builder: (context, communitesCountSnapshot) {
                                    return FiguresWidget(
                                      number: (communitesCountSnapshot.data ?? 0).toString(),
                                      title: GayaStrings.communities_txt.tr,
                                    );
                                  }),
                            ],
                          ),
                          const SizedBox(
                            height: distance_15,
                          ),
                          Center(
                              child: GayaTextWidget(
                                (userDetailsModel.bio.toString()),
                            style: CustomTypography.body4StyleLowWeight,
                            trimLines: 20,
                            shouldIgnoreSelectableText: false,
                            colorClickableText: kprimaryColor,
                          )

                              /*SelectableLinkify(
                              onOpen: (link) async {
                                if (await canLaunch(link.url)) {
                                  await launch(link.url);
                                } else {
                                  throw 'Could not launch $link';
                                }
                                ;
                              },
                              textDirection: context.read<HomePageController>().isRTL(userDetailsModel.bio.toString())
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              text: userDetailsModel.bio.toString(),
                              textAlign: TextAlign.center,
                              style: CustomTypography.body4StyleLowWeight,
                              CustomTypography.linkStyle: TextStyle(color: kprimaryColor),
                            ),*/
                              ),
                          const SizedBox(
                            height: distance_10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 6,
                                child: ButtonWidget(
                                  onTap: () async {
                                    if (firebaseAuth.currentUser == null) {
                                      Routes.loginView(clearPreviousRoutes: true);
                                      return;
                                    }
                                    profileController.image = null;

                                    Routes.editProfile(userModel: userDetailsModel);
                                  },
                                  buttonColor: kBaseGrey,
                                  color: kBlackColor.withOpacity(0.5),
                                  title: GayaStrings.edit_profile.tr,
                                  style: CustomTypography.body2StyleWeightBlack,
                                ),
                              ),
                              const SizedBox(width: distance_5),
                              Expanded(
                                child: InkWell(
                                  onTap: () => Routes.savedPostsView(),
                                  child: Container(
                                      alignment: Alignment.center,
                                      height: distance_40,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: distance_5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: kBaseGrey,
                                        borderRadius: BorderRadius.circular(borderRadius_4),
                                      ),
                                      child: SvgIconWidget.bookmarkOutline()
                                      // child: SvgPicture.asset(
                                      //     "Assets/icons/save.svg",
                                      //     color: kBlackColor.withOpacity(0.8),
                                      //   )
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: distance_10,
                          ),
                          Wrap(
                            direction: Axis.horizontal,
                            runAlignment: WrapAlignment.start,
                            runSpacing: distance_10,
                            spacing: distance_10,
                            children: List.generate(userDetailsModel.interests?.length ?? 0, (index) {
                              return IntrinsicWidth(
                                child: InterestWidget(
                                  color: kBaseGrey,
                                  horizontalDistance: distance_40,
                                  image: userDetailsModel.interests?[index].image ?? '',
                                  title: userDetailsModel.interests?[index].title.tr ?? '',
                                  onTap: () {},
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              }
              FirebaseAuth.instance.signOut();
              return Center(child: Text(GayaStrings.something_wrong.tr));
            }));
  }

  // void showConfirmationDeleteDialog(BuildContext context) {
  //   // set up the buttons
  //   Widget cancelButton = TextButton(
  //     child: Text("Cancel", style: TextStyle(color: Colors.grey)),
  //     onPressed: () {
  //       Navigator.of(context).pop();
  //     },
  //   );
  //   Widget continueButton = TextButton(
  //     child: Text("Delete"),
  //     onPressed: () async {
  //       AccountDeletionServices().deleteMyAccountPermenantly();
  //       Navigator.of(context).pop();
  //       Navigator.of(context).pushNamed(route.login);
  //     },
  //   );
  //
  //   // set up the AlertDialog
  //   AlertDialog alert = AlertDialog(
  //     title: Text("Delete Account Permanently"),
  //     content: Text("Are you sure you want to delete your account? This action cannot be undone."),
  //     actions: [
  //       cancelButton,
  //       continueButton,
  //     ],
  //   );
  //
  //   // show the dialog
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return alert;
  //     },
  //   );
  // }

//Animation while routing to save post screen flutter
  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const SavedPostsView(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }
}

class DeleteAccountPopup extends StatefulWidget {
  const DeleteAccountPopup({Key? key}) : super(key: key);

  @override
  State<DeleteAccountPopup> createState() => _DeleteAccountPopupState();
}

class _DeleteAccountPopupState extends State<DeleteAccountPopup> {
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  String? error;

  setError(String? value) {
    setState(() {
      error = value ?? GayaStrings.something_wrong.tr;
    });
  }

  toggleLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = _getProviderType(FirebaseAuth.instance.currentUser?.providerData[0].providerId ?? '');
    bool isWithProvider = provider == ProviderType.google || provider == ProviderType.apple || provider == ProviderType.phone;

    return SingleChildScrollView(
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            color: Colors.white,
            child: Column(
              children: [
                Text(
                  GayaStrings.delete_account.tr,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  GayaStrings.delete_account_anytime.tr,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 30,
                ),
                if (isWithProvider == false)
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: GayaStrings.enter_password_continue.tr,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                const SizedBox(
                  height: 10,
                ),
                if (error != null)
                  Text(
                    error ?? '',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(
                  height: 20,
                ),
                if (isLoading)
                  const CircularProgressIndicator()
                else
                  GayaButton(
                      title: GayaStrings.delete_account_permanently.tr,
                      islogout: false,
                      onPressed: () => _onDeleteTap(),
                      borderColor: kTransparentColor,
                      height: 50,
                      primaryColor: kBaseGrey,
                      textStyle: const TextStyle(color: kRedColor, fontWeight: FontWeight.w500, fontSize: 14),
                      width: double.infinity),
              ],
            )));
  }

  ProviderType _getProviderType(String providerId) {
    switch (providerId) {
      case 'google.com':
        return ProviderType.google;
      case 'apple.com':
        return ProviderType.apple;
      case 'phone':
        return ProviderType.phone;
      case 'password':
        return ProviderType.email;
      default:
        return ProviderType.none;
    }
  }

  _onDeleteTap() async {
    ProviderType providerType = _getProviderType(FirebaseAuth.instance.currentUser?.providerData[0].providerId ?? '');

    /// Deletion process for PHONE, as we will not have password for phone
    /// we will send OTP to user's phone number and then delete the account
    /// after re-authentication
    if (providerType == ProviderType.phone) {
      return Routes.verifyPhoneOTPView(phoneNumber: FirebaseAuth.instance.currentUser?.phoneNumber ?? '', isDeleteProcess: true);
    }

    /// getting provider type
    final bool isWithProvider =
        providerType == ProviderType.google || providerType == ProviderType.apple || providerType == ProviderType.phone;

    error = null;
    toggleLoading();
    if (isWithProvider == false && _passwordController.text.trim().length < 3) {
      setError(GayaStrings.enter_your_password.tr);
      toggleLoading();
      return;
    }
    final deletionService = AccountDeletionServices.instance;
    try {
      final credentials = isWithProvider == false
          ? await deletionService.reAuthenticateUserWithPassword(password: _passwordController.text)
          : providerType == ProviderType.google
              ? await deletionService.reAuthenticateUserGoogle()
              : providerType == ProviderType.apple
                  ? await deletionService.reAuthenticateUserApple()
                  : null;
      if (credentials != null) {
        deletionService.deleteMyAccountPermenantly(credential: credentials);

        Get.back();
        AppConfigurationController.to.resetOnLogInOrOut();
        Routes.loginView(clearPreviousRoutes: true);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        setError(GayaStrings.password_incorrect.tr);
      } else {
        setError(e.message);
      }
    } catch (_) {
    } finally {
      toggleLoading();
    }
  }
}

enum ProviderType { google, apple, phone, email, none }
