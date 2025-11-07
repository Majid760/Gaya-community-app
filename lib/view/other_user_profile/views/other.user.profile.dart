// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/components/check_for_app_update.dart';
import 'package:gaya/components/snackbar.component.dart';
import 'package:gaya/controller/app_config_controller.dart';
import 'package:gaya/controller/firebase_analytics_controller.dart';
import 'package:gaya/controller/gaya_shared_controller.dart';
import 'package:gaya/controller/profile.controller.dart';
import 'package:gaya/generated/assets.dart';
import 'package:gaya/model/compliments_list.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/shared/service/message_service/message_service.dart';
import 'package:gaya/shared/service/service/shared_service.dart';
import 'package:gaya/shared/view/widget/gaya_report_dialog.dart';
import 'package:gaya/shared/view/widget/gaya_snackbar.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/theme/app_spaces.dart';
import 'package:gaya/view/chat/controllers/chat_controller.dart';
import 'package:gaya/view/profile/components/skeletons.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import '../../../components/dialogue.dart';
import '../../../controller/block_controller.dart';
import '../../../controller/report_controller.dart';
import '../../../model/user.model.dart';
import '../../../services/services.dart';
import '../../../shared/service/friendship_status_service.dart';
import '../../../shared/view/widget/gaya_alert_dialog.dart';
import '../../../shared/view/widget/gaya_back_button.dart';
import '../../../utils/asset_images.dart';
import '../../../utils/const.dart';
import '../../../utils/enum.dart';
import '../../../utils/gaya_text_widget.dart';
import '../../../utils/methods.dart';
import '../../../utils/textstyles.dart';
import '../../../utils/theme/app_colors.dart';
import '../../../widgets/profile.widgets/button.widget.dart';
import '../../../widgets/profile.widgets/figure.widget.dart';
import '../../../widgets/profile.widgets/profileimage.widget.dart';
import '../../../widgets/topic_view_widgets/interest.widget.dart';

class PeopleProfileView extends StatefulWidget {
  PeopleProfileView({Key? key, required this.usermodel}) : super(key: key);

  UserModel usermodel;

  @override
  State<PeopleProfileView> createState() => _PeopleProfileViewState();
}

class _PeopleProfileViewState extends State<PeopleProfileView> {
  DocumentSnapshot? snapshot;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Map<String, dynamic>? map;
  var profileDetails;
  late Future<UserModel?> futureUserModel;
  var otherProfileDetails;
  final Services services = Services();

  final performance = PerformanceController.to.instance;

  late ProfileController profileController;

  bool isSendMessageTapped = false;

  @override
  void initState() {
    performance.startUserProfileViewLoadTime();
    profileController = Provider.of<ProfileController>(context, listen: false);
    futureUserModel = services.getUserById(widget.usermodel.uId);
    profileDetails = getFriend();

    context.read<ProfileController>().getUserDetails();
    otherProfileDetails = context.read<ProfileController>().getOtherUserProfileDetails(widget.usermodel.uId ?? "");

    complimentList.shuffle();
    // adding other user profile view count
    context.read<ProfileController>().addUserProfileViewedCount(
          otherUserProfileId: widget.usermodel.uId!,
        );

    // Logging view user analytics event
    AnalyticsController.to.instance.logViewUser(
      viewingUserId: UserModel.to.uId ?? '',
      viewedUserId: widget.usermodel.uId ?? '',
    );

    super.initState();
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  QuerySnapshot? getFriends;

  Future getFriend() async {
    User? user = _firebaseAuth.currentUser;
    getFriends = await FirebaseFirestore.instance
        .collection('friendship')
        .where("senderUid", isEqualTo: widget.usermodel.uId)
        .where('Recieveruid', isEqualTo: user?.uid)
        .get();

    return getFriends;
  }

  void _onBanUnBan(BuildContext context) async {
    if (widget.usermodel.uId.isBlank == true || !AppConfigurationController.to.isSuperAdmin) return;

    bool isBan = widget.usermodel.isActive == true;
    showGayaAlertDialogButton(
      context: context,
      actionText: "${isBan ? "ban completely from app" : "unban completely from app"}?".toLowerCase(),
      tapOnYes: () async {
        Navigator.pop(context);
        await AppConfigurationController.to.banUnban(widget.usermodel.uId!, isBan: isBan);
        if (isBan) {
          widget.usermodel.isActive = false;
          GayaSnackBar.show(context: context, type: GayaSnackBarType.success, text: GayaStrings.user_banned_success.tr);
        } else {
          widget.usermodel.isActive = true;
          GayaSnackBar.show(context: context, type: GayaSnackBarType.success, text: GayaStrings.user_unbanned_success.tr);
        }
      },
      tapOnNo: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = const EdgeInsets.symmetric(horizontal: 20).r;
    // _prefs?.remove('timerStartTime');
    // print(_prefs);
    User? user = firebaseAuth.currentUser;
    final controller = Provider.of<ProfileController>(context, listen: false);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.white,
        leading: const GayaBackButton(),
        middle: Text(GayaStrings.profile_txt.tr, style: GayaTypography.titleMedium),
        trailing: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          child: IconButton(
            tooltip: GayaStrings.more_txt.tr,
            padding: EdgeInsets.zero,
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            splashRadius: 20.r,
            icon: SvgIcons.moreIconBlack,
            onPressed: () {
              user == null
                  ? Routes.loginView()
                  : Methods.showCircularModalSheet(
                      context,
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10).r,
                        width: MediaQuery.sizeOf(context).width,
                        decoration: const BoxDecoration(color: Colors.white),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GayaButton(
                              title: GayaStrings.share_profile.tr,
                              onPressed: () async {
                                Get.back();

                                final shareAbleLink = await GayaSharedController.to.createAShareableProfileLink(user: widget.usermodel);
                                if (shareAbleLink != null) await Share.share(shareAbleLink);
                              },
                              borderColor: kTransparentColor,
                              height: 50.h,
                              primaryColor: kBaseGrey,
                              textStyle: GayaTypography.subtitleRegular,
                              width: MediaQuery.sizeOf(context).width,
                            ),
                            const SizedBox(height: 10),
                            GayaButton(
                              title: BlockController.to.isUserBlocked(widget.usermodel.uId ?? "")
                                  ? GayaStrings.user_blocked.tr
                                  : GayaStrings.block_user.tr,
                              onPressed: () async {
                                if (widget.usermodel.uId == null) return;
                                BlockController.to.block(userId: widget.usermodel.uId ?? "", context: context);

                                Get.back();
                              },
                              borderColor: kTransparentColor,
                              height: 50.h,
                              primaryColor: kBaseGrey,
                              textStyle: GayaTypography.subtitleRegular.copyWith(color: AppColors.error),
                              width: MediaQuery.sizeOf(context).width,
                            ),
                            const SizedBox(height: 10),
                            GayaButton(
                              title: GayaStrings.report.tr,
                              onPressed: () async {
                                Get.back();

                                reportTextFieldBottomModal(
                                  context,
                                  onSubmit: (String reportMsg) async {
                                    bool isExist = await controller.checkCurrentUserReportedThatUserAlready(widget.usermodel.uId!);
                                    if (!isExist) {
                                      await ReportController.to.reportAUser(widget.usermodel.uId!, context, reportMsg: reportMsg);
                                    } else {
                                      snackBar(context, GayaStrings.already_reported.tr, kRedColor);
                                    }
                                  },
                                );
                              },
                              borderColor: kTransparentColor,
                              height: 50.h,
                              primaryColor: kBaseGrey,
                              textStyle: GayaTypography.subtitleRegular.copyWith(color: AppColors.error),
                              width: MediaQuery.sizeOf(context).width,
                            ),
                            const SizedBox(height: 10),

                            ///show only to super admin.
                            if (AppConfigurationController.to.isSuperAdmin)
                              GayaButton(
                                title: widget.usermodel.isActive == true ? GayaStrings.ban_user.tr : GayaStrings.unban_user.tr,
                                onPressed: () async {
                                  Get.back();
                                  _onBanUnBan(context);
                                },
                                borderColor: kTransparentColor,
                                height: 50.h,
                                primaryColor: kBaseGrey,
                                textStyle: GayaTypography.subtitleRegular.copyWith(color: AppColors.error),
                                width: MediaQuery.sizeOf(context).width,
                              ),
                          ],
                        ),
                      ),
                    );
            },
          ),
        ),
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: FutureBuilder<UserModel?>(
              initialData: widget.usermodel,
              future: futureUserModel,
              builder: (context, userSnapshot) {
                try {
                  print("userSnapshot.data ${userSnapshot.data}");
                  widget.usermodel = userSnapshot.data!;
                } catch (e) {
                  print(e);
                  return const SizedBox.shrink();
                }
                return FutureBuilder(
                  future: profileDetails,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        height: MediaQuery.sizeOf(context).height,
                        child: const SizedBox.shrink(),
                      );
                    } else if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(GayaStrings.some_error_occurred.tr),
                        );
                      }
                    }
                    performance.stopUserProfileViewLoadTime();
                    debugPrint("USER PRFILE ${widget.usermodel.name?.length}");
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: distance_15),
                        Padding(
                          padding: horizontalPadding,
                          child: ProfilePicWidget(
                            oncovertap: () => Routes.openImages(urls: [widget.usermodel.coverPhoto ?? ""], index: 0, ctx: context),
                            onproftap: () => Routes.openImages(urls: [widget.usermodel.profilePicture ?? ""], index: 0, ctx: context),
                            coverPhoto: widget.usermodel.coverPhoto,
                            profilePic: widget.usermodel.profilePicture,
                          ),
                        ),
                        Padding(
                          padding: horizontalPadding,
                          child: Center(child: Text(widget.usermodel.name ?? "", style: CustomTypography.subHeading)),
                        ),
                        const SizedBox(height: distance_20),
                        Padding(
                          padding: horizontalPadding,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: FutureBuilder<int>(
                                    future: context.read<ProfileController>().getOtherUserFriendsCount(widget.usermodel.uId ?? ""),
                                    builder: ((context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const CountSkeletonWidget();
                                      } else if (snapshot.connectionState == ConnectionState.done) {
                                        return FiguresWidget(
                                          number: (snapshot.data ?? 0).toString(),
                                          title: GayaStrings.friends_txt.tr,
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    })),
                              ),
                              Expanded(
                                flex: 1,
                                child: FutureBuilder<int>(
                                    future: context.read<ProfileController>().getOtherUserCommunityCount(widget.usermodel.uId ?? ""),
                                    builder: (context, communitesCountSnapshot) {
                                      if (communitesCountSnapshot.connectionState == ConnectionState.waiting) {
                                        return const CountSkeletonWidget();
                                      }
                                      return FiguresWidget(
                                          number: (communitesCountSnapshot.data ?? 0).toString(), title: GayaStrings.communities_txt.tr);
                                    }),
                              ),
                              Expanded(
                                flex: 1,
                                child: FiguresWidget(
                                  number: (widget.usermodel.userTotalCrowns ?? 0).toString(),
                                  title: GayaStrings.crowns_txt.tr,
                                  flower: SvgPicture.asset('Assets/images/filled_crown.svg', height: 10, width: 12),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: distance_15),
                        Padding(
                          padding: horizontalPadding,
                          child: Center(
                            child: GayaTextWidget(
                              (widget.usermodel.bio ?? ""),
                              style: CustomTypography.body4StyleLowWeight,
                              trimLines: 20,
                              shouldIgnoreSelectableText: false,
                              trimMode: TrimMode.line,
                              trimCollapsedText: GayaStrings.read_more.tr,
                              trimExpandedText: GayaStrings.read_less.tr,
                              colorClickableText: kprimaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: distance_10),
                        Padding(
                          padding: horizontalPadding,
                          child: user == null
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: ButtonWidget(
                                        icon: SvgPicture.asset("Assets/icons/Union.svg", color: Colors.white),
                                        onTap: () {
                                          Routes.loginView();
                                        },
                                        buttonColor: kprimaryColor,
                                        color: kBlackColor.withOpacity(0.5),
                                        title: GayaStrings.add_friend.tr,
                                        style: CustomTypography.body4StyleWhite,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: distance_5,
                                    ),
                                    Expanded(
                                      child: ButtonWidget(
                                          onTap: () {
                                            Routes.loginView();
                                          },
                                          title: GayaStrings.message_txt.tr,
                                          buttonColor: kBaseGrey,
                                          color: kBlackColor.withOpacity(0.5),
                                          icon: SvgPicture.asset(
                                            "Assets/images/outline_mesage.svg",
                                            color: Colors.black,
                                          ),
                                          style: CustomTypography.body2StyleWeightBlack),
                                    ),
                                  ],
                                )
                              : StreamBuilder<QuerySnapshot>(
                                  stream: getFriends?.docs.isEmpty ?? true
                                      ? FirebaseFirestore.instance
                                          .collection('friendship')
                                          .where("Recieveruid", isEqualTo: widget.usermodel.uId)
                                          .where('senderUid', isEqualTo: user.uid)
                                          .snapshots()
                                      : FirebaseFirestore.instance
                                          .collection('friendship')
                                          .where("Recieveruid", isEqualTo: user.uid)
                                          .where('senderUid', isEqualTo: widget.usermodel.uId)
                                          .snapshots(),
                                  builder: (context, dataSnapshot) {
                                    if (dataSnapshot.connectionState == ConnectionState.waiting) {
                                      return Row(
                                        children: [
                                          Expanded(child: Container(height: distance_40, color: Colors.grey[300])),
                                          const SizedBox(width: distance_5),
                                          Expanded(child: Container(height: distance_40, color: Colors.grey[300])),
                                        ],
                                      );
                                    } else if (dataSnapshot.connectionState == ConnectionState.active ||
                                        dataSnapshot.connectionState == ConnectionState.done) {
                                      if (dataSnapshot.hasData) {
                                        bool _canSendMessage = canSendMessage(dataSnapshot);
                                        return Row(
                                          children: [
                                            Expanded(
                                              child: Consumer<ProfileController>(
                                                builder: (context, profileContrl, __) {
                                                  return ButtonWidget(
                                                    icon: dataSnapshot.data!.docs.isEmpty
                                                        ? profileContrl.isRequestSend
                                                            ? SvgPicture.asset("Assets/icons/Union.svg", color: Colors.grey)
                                                            : SvgPicture.asset("Assets/icons/Union.svg", color: Colors.white)
                                                        : (FriendshipStatusService.instance.getFriendshipStatus(
                                                                    friendshipSnapshot: dataSnapshot,
                                                                    me: user.uid,
                                                                    other: widget.usermodel.uId ?? "") ==
                                                                FriendshipStatus.requestSent)
                                                            ? const SizedBox()
                                                            : FriendshipStatusService.instance.getFriendshipStatus(
                                                                        friendshipSnapshot: dataSnapshot,
                                                                        me: user.uid,
                                                                        other: widget.usermodel.uId ?? "") ==
                                                                    FriendshipStatus.acceptRequest
                                                                ? SvgPicture.asset("Assets/icons/Union.svg", color: Colors.white)
                                                                : SvgPicture.asset("Assets/icons/Union_del.svg", color: Colors.black),
                                                    onTap: () async {
                                                      await _onFriendshipButtonTap(dataSnapshot, user, profileContrl, controller, context);
                                                    },
                                                    buttonColor:
                                                        _getFriendshipButtonColor(dataSnapshot, user.uid, widget.usermodel.uId ?? ''),
                                                    color: kBlackColor.withOpacity(0.5),
                                                    title: _getFriendshipButtonTitle(dataSnapshot, user.uid, widget.usermodel.uId ?? ''),
                                                    style:
                                                        _getFriendshipButtonTextStyle(dataSnapshot, user.uid, widget.usermodel.uId ?? ''),
                                                  );
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: distance_5),
                                            Expanded(
                                              child: StatefulBuilder(builder: (context, update) {
                                                return ButtonWidget(
                                                  isLoading: isSendMessageTapped,
                                                  onTap: () async {
                                                    if (isSendMessageTapped) {
                                                      return;
                                                    }
                                                    update(() => isSendMessageTapped = true);
                                                    if (GayaRemoteConfig.to.isConnectyCubeEnabled) {
                                                      final errorMessage = canSendMessageError(dataSnapshot);
                                                      if (errorMessage != null) {
                                                        GayaSnackBar.show(
                                                            context: context, type: GayaSnackBarType.problem, text: errorMessage);
                                                        return;
                                                      }
                                                      if (ChatController.to().currentUser != null) {
                                                        await ChatController.to()
                                                            .helperFunc
                                                            .openOrCreateCubeConversation(context, widget.usermodel.uId ?? "");
                                                      }
                                                    } else {
                                                      if (widget.usermodel.uId != null) {
                                                        await MessageUtils.sendAMessage(widget.usermodel, context: context);
                                                      }
                                                    }

                                                    /// navigation to chat screen takes time, so delaying the button state change
                                                    await Future.delayed(const Duration(seconds: 1));
                                                    update(() => isSendMessageTapped = false);
                                                  },
                                                  title: (GayaStrings.message.tr),
                                                  buttonColor: _canSendMessage ? kprimaryColor : kBaseGrey,
                                                  color: kBlackColor.withOpacity(0.8),
                                                  icon: SvgPicture.asset(
                                                    "Assets/images/outline_mesage.svg",
                                                    color: _canSendMessage ? Colors.white : disableColor,
                                                  ),
                                                  style: _canSendMessage
                                                      ? CustomTypography.body2StyleWeight
                                                      : CustomTypography.body2StyleWeighGrey,
                                                );
                                              }),
                                            ),
                                          ],
                                        );
                                      } else {
                                        const SizedBox.shrink();
                                      }
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                        ),
                        const SizedBox(height: distance_12),
                        FutureProvider<DocumentSnapshot?>(
                          initialData: null,
                          create: (context) => otherProfileDetails,
                          child: Consumer<DocumentSnapshot?>(
                            builder: (context, value, _) {
                              late UserModel userDetailsModel;
                              if (value != null) {
                                userDetailsModel = UserModel.fromMap(value.data() as Map<String, dynamic>, userId: value.id);
                              }
                              return value == null
                                  ? const SizedBox()
                                  : Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        StatefulBuilder(builder: (context, state) {
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: horizontalPadding,
                                                child: Text(GayaStrings.compliment_txt.tr, style: GayaTypography.titleMedium),
                                              ),
                                              SizedBox(height: 4.h),
                                              Padding(
                                                padding: horizontalPadding,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      width: MediaQuery.sizeOf(context).width * 0.65,
                                                      child: Text(
                                                        '${'${GayaStrings.send_txt.tr} '}${widget.usermodel.name} ${GayaStrings.compliment_anonymously.tr}',
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.w400,
                                                            color: Colors.grey,
                                                            fontSize: 14.sp,
                                                            fontFamily: GayaFontTheme.primaryFont),
                                                      ),
                                                    ),
                                                    SizedBox(width: 5.w),
                                                    Expanded(
                                                      child: GestureDetector(
                                                        onTap: () => state(() => complimentList.shuffle()),
                                                        child: Row(
                                                          children: [
                                                            SizedBox(
                                                              height: 20.h,
                                                              width: 20.w,
                                                              child: SvgPicture.asset(Assets.shuffleIcon),
                                                            ),
                                                            SizedBox(width: 10.w),
                                                            Expanded(
                                                              child: Text(
                                                                GayaStrings.shuffle_txt.tr,
                                                                overflow: TextOverflow.ellipsis,
                                                                style: GayaTypography.titleMedium,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 12.h),
                                              Container(
                                                margin: horizontalPadding,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(16.r),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Color.fromRGBO(0, 0, 0, 0.25),
                                                      blurRadius: 16,
                                                      offset: Offset(4, 4), // changes position of shadow
                                                    ),
                                                  ],
                                                ),
                                                height: 175.h,
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20).r,
                                                  child: GridView.builder(
                                                    physics: const NeverScrollableScrollPhysics(),
                                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                      mainAxisSpacing: 15.w,
                                                      crossAxisSpacing: 15.w,
                                                      crossAxisCount: 2,
                                                      mainAxisExtent: 50.h,
                                                    ),
                                                    itemCount: 4,
                                                    shrinkWrap: true,
                                                    itemBuilder: (context, index) => InkWell(
                                                      onTap: () {
                                                        ComplimentSavedUser tappedUser = ComplimentSavedUser(
                                                          id: widget.usermodel.uId.toString(),
                                                          name: widget.usermodel.name.toString(),
                                                          startTime: DateTime.now(),
                                                        );

                                                        controller.startComplimentTime(
                                                          user: tappedUser,
                                                          context: context,
                                                          compliment: complimentList[index],
                                                        );
                                                      },
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: kprimaryColor,
                                                          borderRadius: BorderRadius.circular(5.r),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            complimentList[index].tr,
                                                            style: TextStyle(
                                                                fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.white),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }),
                                        /*    SizedBox(height: 22.r),
                                        Padding(
                                          padding: horizontalPadding,
                                          child: Text(GayaStrings.influence_txt.tr, style: GayaTypography.titleMedium),
                                        ),
                                        SizedBox(height: 8.r),
                                        Container(
                                          margin: horizontalPadding,
                                          height: 42.r,
                                          // color: Colors.pink,
                                          alignment: Alignment.center,
                                          child: InfluenceBarWidget(score: userDetailsModel.userInfluenceScoreWithCrowns, isMe: false),
                                        ),*/
                                        SizedBox(height: 20.h),
                                        Padding(
                                          padding: horizontalPadding,
                                          child: Text(
                                            GayaStrings.fav_topics.tr,
                                            style: GayaTypography.titleMedium,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Padding(
                                          padding: horizontalPadding,
                                          child: Wrap(
                                            direction: Axis.horizontal,
                                            runAlignment: WrapAlignment.start,
                                            // runSpacing: distance_10,
                                            spacing: distance_10,
                                            children: List.generate(userDetailsModel.interests?.length ?? 0, (index) {
                                              return InterestWidget(
                                                color: kBaseGrey,
                                                horizontalDistance: distance_40,
                                                image: userDetailsModel.interests?[index].image ?? '',
                                                title: userDetailsModel.interests?[index].title ?? '',
                                                onTap: () {
                                                  Routes.seeAllInterestCommunitiesView(
                                                      communityName: userDetailsModel.interests?[index].title);
                                                },
                                              );
                                            }),
                                          ),
                                        ),
                                      ],
                                    );
                            },
                          ),
                        ),
                        MySpaces.bottom
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// callback to pass on addFriend, removeFriend, acceptRequest, requestSent Button tap
  Future<void> _onFriendshipButtonTap(
    AsyncSnapshot<QuerySnapshot<Object?>> dataSnapshot,
    User user,
    ProfileController profileContrl,
    ProfileController controller,
    BuildContext context,
  ) async {
    switch (FriendshipStatusService.instance.getFriendshipStatus(
      friendshipSnapshot: dataSnapshot,
      me: user.uid,
      other: widget.usermodel.uId ?? '',
    )) {
      /* ----------------------- FriendshipStatus.addFriend ----------------------- */
      case FriendshipStatus.addFriend:
        if (dataSnapshot.data!.docs.isEmpty || profileContrl.isRequestSend == false) {
          final userDeatail = profileContrl.userDetails!;
          final userDetailModel = widget.usermodel;
          await profileContrl.createFriendShip(
            userDetailModel.uId ?? '',
            userDetailModel.name ?? '',
            userDeatail['name'] ?? '',
            userDeatail['profilePic'] ?? '',
            userDetailModel.fm_token,
          );
        }
        break;
      /* ------------------------ FriendshipStatus.unFriend ----------------------- */
      case FriendshipStatus.unFriend:
        log('unfriend sent.');
        DialogueC(
          widget.usermodel.name!,
          () {
            Get.back();
            controller.unFriend(widget.usermodel.uId!);
          },
          context,
        );

        break;
      /* --------------------- FriendshipStatus.acceptRequest --------------------- */
      case FriendshipStatus.acceptRequest:
        await profileContrl.acceptFriendRequest(dataSnapshot.data!.docs[0].id);
        // Logging accept friend request event to analytics
        AnalyticsController.to.instance.logAcceptFriendRequest(
          userId: user.uid,
          friendUserId: widget.usermodel.uId,
        );
        break;
      /* ---------------------- FriendshipStatus.requestSent ---------------------- */
      case FriendshipStatus.requestSent:
        controller.unFriend(widget.usermodel.uId!);
        break;
    }
  }

  /// invoke to get button color
  Color _getFriendshipButtonColor(
    AsyncSnapshot<QuerySnapshot<Object?>> friendshipSnapshot,
    String myUid,
    String otherUid,
  ) {
    switch (FriendshipStatusService.instance.getFriendshipStatus(
      friendshipSnapshot: friendshipSnapshot,
      me: myUid,
      other: otherUid,
    )) {
      case FriendshipStatus.addFriend:
        return kprimaryColor;
      case FriendshipStatus.unFriend:
        return kBaseGrey;
      case FriendshipStatus.acceptRequest:
        return kprimaryColor;
      case FriendshipStatus.requestSent:
        return kprimaryColor;
    }
  }

  /// invoke to get button text style
  TextStyle _getFriendshipButtonTextStyle(
    AsyncSnapshot<QuerySnapshot<Object?>> friendshipSnapshot,
    String myUid,
    String otherUid,
  ) {
    switch (FriendshipStatusService.instance.getFriendshipStatus(
      friendshipSnapshot: friendshipSnapshot,
      me: myUid,
      other: otherUid,
    )) {
      case FriendshipStatus.addFriend:
        return CustomTypography.body4StyleWhite;
      case FriendshipStatus.unFriend:
        return CustomTypography.bodyStyle;
      case FriendshipStatus.acceptRequest:
        return CustomTypography.body4StyleWhite;
      case FriendshipStatus.requestSent:
        return CustomTypography.body4StyleWhite;
    }
  }

  /// invoke to get title of button
  String _getFriendshipButtonTitle(
    AsyncSnapshot<QuerySnapshot<Object?>> friendshipSnapshot,
    String myUid,
    String otherUid,
  ) {
    switch (FriendshipStatusService.instance.getFriendshipStatus(
      friendshipSnapshot: friendshipSnapshot,
      me: myUid,
      other: otherUid,
    )) {
      case FriendshipStatus.addFriend:
        return GayaStrings.add_friend.tr;
      case FriendshipStatus.unFriend:
        return GayaStrings.unfriend.tr;
      case FriendshipStatus.acceptRequest:
        return GayaStrings.accept_request.tr;
      case FriendshipStatus.requestSent:
        return GayaStrings.request_sent.tr;
    }
  }

  bool canSendMessage(AsyncSnapshot<QuerySnapshot<Object?>> friendshipSnapshot) {
    bool _isFriend = isMyFriend(friendshipSnapshot);
    bool isDMDisabled = widget.usermodel.allowToDm == false;
    bool isAgeValid = SharedService.isEnteredAgeValid(widget.usermodel.dob ?? DateTime(2000), 16);
    return MessageUtils.canSendMessage(_isFriend, isAgeValid, isDMDisabled) == null;
  }

  String? canSendMessageError(AsyncSnapshot<QuerySnapshot<Object?>> friendshipSnapshot) {
    bool _isFriend = isMyFriend(friendshipSnapshot);
    bool isDMDisabled = widget.usermodel.allowToDm == false;
    bool isAgeValid = SharedService.isEnteredAgeValid(widget.usermodel.dob ?? DateTime(2000), 16);
    return MessageUtils.canSendMessage(_isFriend, isAgeValid, isDMDisabled);
  }

  bool isMyFriend(AsyncSnapshot<QuerySnapshot<Object?>> friendshipSnapshot) {
    if (friendshipSnapshot.data?.docs.isEmpty ?? true) {
      return false;
    }
    return FriendshipStatusService.instance.getFriendshipStatus(
          friendshipSnapshot: friendshipSnapshot,
          me: UserModel.to.uId ?? "",
          other: widget.usermodel.uId ?? "",
        ) ==
        FriendshipStatus.unFriend;
  }
}
