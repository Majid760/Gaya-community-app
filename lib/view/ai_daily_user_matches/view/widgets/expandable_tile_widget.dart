import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaya/bindings/initializing_dependencies.dart';
import 'package:gaya/components/profile_image_widget.dart';
import 'package:gaya/controller/notification.controller.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/shared/view/widget/gaya_alert_dialog.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_spaces.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:gaya/view/ai_daily_user_matches/controller/ai_matches_controller.dart';
import 'package:gaya/view/ai_daily_user_matches/utils/ai_assets_path.dart';
import 'package:gaya/view/ai_daily_user_matches/utils/strings.dart';
import 'package:gaya/view/ai_daily_user_matches/view/widgets/ai_match_timer.dart';
import 'package:gaya/view/ai_daily_user_matches/view/widgets/match_setting_bottom_sheet.dart';
import 'package:gaya/view/chat/controllers/chat_controller.dart';
import 'package:gaya/view/splash/view/widget/gradient_text.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class ExpandableTile extends StatefulWidget {
  const ExpandableTile({Key? key}) : super(key: key);

  @override
  _ExpandableTileState createState() => _ExpandableTileState();
}

class _ExpandableTileState extends State<ExpandableTile> {
  @override
  Widget build(BuildContext context) {
    NotificationController notificationController = Provider.of<NotificationController>(context, listen: false);
    final LocalizationController localizationController = Get.find();
    Size size = MediaQuery.sizeOf(context);
    return GetBuilder<AIMatchesController>(
        init: AIMatchesController.to,
        builder: (matchController) {
          return Stack(
            children: [
              if (!matchController.isExpanded)
                GestureDetector(
                  onTap: () {
                    matchController.collapseExpandTile(expand: true);
                  },
                  child: Container(
                    height: 54.h,
                    width: size.width,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage((matchController.isSendMatchRequest() || matchController.isGotMatch())
                            ? AiAssetsPath.image3
                            : AiAssetsPath.image1),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              if (matchController.isExpanded)
                GestureDetector(
                  onTap: () {
                    matchController.collapseExpandTile(expand: false);
                  },
                  child: Container(
                    height: 323.h,
                    width: size.width, // Note: Ensure you have the Get package or replace it with the desired width value
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(matchController.isGotMatch() ? AiAssetsPath.image4 : AiAssetsPath.image2),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),

              ///when match found
              if (matchController.isGotMatch() == true && matchController.isExpanded)
                ExpandedContents2(
                  title: GayaStrings.your_new_match_is_here.tr,
                  des:
                      "${GayaStrings.expandedDes31.tr} ${matchController.isSameAge()} ${GayaStrings.expandedDes32.tr} ${matchController.getMutualTopics()} ${GayaStrings.expandedDes322.tr} ${matchController.getMutualCommunities()} ${GayaStrings.expandedDes33.tr}",
                  buttonText:
                      '${GayaStrings.break_the_ice_with_Mellow.tr}${matchController.myAIMatchModel?.matchedUserProfile?.name ?? ""}',
                  textButtonText: "${GayaStrings.you_have.tr} 23:03 ${GayaStrings.hours_until_its_too_late.tr}",
                  onTap: () {
                    matchController.collapseExpandTile(expand: false);
                    // matchController.setLetsGo(status: false);
                  },
                  onTap2: () {
                    matchController.collapseExpandTile(expand: false);
                  },
                ),

              ///Expanded contents when user not send  request
              if (matchController.isExpanded && matchController.isGotMatch() == false && matchController.isSendMatchRequest() == false)
                ExpandedContents(
                  permissionStatus: false,
                  isRequestSend: false,
                  title: GayaStrings.meet_gaya_ai_here_to_make_connecting_easier.tr,
                  des: GayaStrings.expandedDes1.tr,
                  buttonText: GayaStrings.give_it_a_try.tr,
                  textButtonText: GayaStrings.maybe_later.tr,
                  onTap: () {
                    matchController.collapseExpandTile(expand: false);
                    //  matchController.setLetsGo(status: false);
                  },
                  onTap2: () {
                    matchSettingBottomSheet(context);
                  },
                ),

              ///Expanded contents when user send  request and not got match
              if (matchController.isExpanded && matchController.isSendMatchRequest() && matchController.isGotMatch() == false)
                ExpandedContents(
                  permissionStatus: notificationController.checkPermissionStatus()!,
                  isRequestSend: true,
                  title: GayaStrings.a_new_match_will_be_here_soon.tr,
                  des: '${GayaStrings.expandedDes2.tr}${matchController.getLocalTimeFoUtc1700()}${GayaStrings.expandedDes22.tr}',
                  buttonText: GayaStrings.please_notify_me.tr,
                  textButtonText: GayaStrings.match_settings.tr,
                  onTap: () {
                    matchSettingBottomSheet(context);
                  },
                  onTap2: () {
                    showGayaAlertDialogButton(
                        context: context,
                        actionMsg: "${GayaStrings.psst.tr} ",
                        actionText: GayaStrings.alert_des.tr,
                        yseButtonTitle: GayaStrings.settings,
                        noButtonTitle: GayaStrings.no_thanks,
                        tapOnYes: () async {
                          Provider.of<NotificationController>(context, listen: false).init(context: context);
                          Navigator.pop(context);
                        },
                        tapOnNo: () {
                          matchController.collapseExpandTile(expand: false);
                          Navigator.pop(context);
                        });

                    // showDialog(
                    //   context: context,
                    //   builder: (BuildContext context) => showAlertDialog(context),
                    // );
                  },
                ),
              Visibility(
                visible: !matchController.isExpanded,
                child: GestureDetector(
                  onTap: () {
                    matchController.collapseExpandTile(expand: true);
                  },
                  child: Container(
                    height: 54.h,
                    padding: const EdgeInsets.only(
                      top: 11,
                      left: 20,
                      right: 8,
                      bottom: 10,
                    ).r,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        matchController.isSendMatchRequest() || matchController.isGotMatch()
                            ? matchController.isGotMatch()
                                ? Text.rich(
                                    textAlign: localizationController.isHebrew ? TextAlign.right : TextAlign.left,
                                    textDirection: localizationController.isHebrew ? TextDirection.rtl : TextDirection.ltr,
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text:
                                              "${GayaStrings.you_matched_with.tr} ${matchController.myAIMatchModel?.matchedUserProfile?.name}.\n",
                                          style: GayaTypography.titleSemiBold.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            height: 1,
                                          ),
                                        ),
                                        TextSpan(
                                          text: "${GayaStrings.say_hi_before_its_too_late.tr}👋",
                                          style: GayaTypography.titleSemiBold.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w400,
                                            height: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Text.rich(
                                    textAlign: localizationController.isHebrew ? TextAlign.right : TextAlign.left,
                                    textDirection: localizationController.isHebrew ? TextDirection.rtl : TextDirection.ltr,
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "${GayaStrings.a_new_match_will_be_here_soon.tr}\n",
                                          style: GayaTypography.titleSemiBold.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            height: 1,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '${GayaStrings.check_out_your_match_at.tr} ${matchController.getLocalTimeFoUtc1700()}',
                                          style: GayaTypography.titleSemiBold.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w400,
                                            height: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                            : Padding(
                                padding: const EdgeInsets.only(left: 40).r,
                                child: SizedBox(
                                  width: 190.w,
                                  child: Text(
                                    GayaStrings.meet_new_people_near_you_using_gaya_ai.tr,
                                    textAlign: localizationController.isHebrew ? TextAlign.right : TextAlign.left,
                                    textDirection: localizationController.isHebrew ? TextDirection.rtl : TextDirection.ltr,
                                    style: GayaTypography.titleSemiBold
                                        .copyWith(fontWeight: FontWeight.w700, height: 1, color: AppColors.white, letterSpacing: 0),
                                  ),
                                ),
                              ),
                        matchController.isSendMatchRequest() == false
                            ? MatchButtonWidget(
                                title: GayaStrings.give_it_a_try.tr,
                                width: 101.w,
                                height: 35.h,
                                onTap: () {
                                  matchSettingBottomSheet(context);
                                })
                            : (matchController.isSendMatchRequest() && matchController.isGotMatch())
                                ? MatchButtonWidget(
                                    title: GayaStrings.say_Hi.tr,
                                    width: 101.w,
                                    height: 35.h,
                                    onTap: matchController.isLoading
                                        ? () {}
                                        : () async {
                                            matchController.setIsLoading(status: true);
                                            await ChatController.to().helperFunc.createNewChatAndSendMessage(
                                                context, matchController.myAIMatchModel?.matchedUserProfile?.id ?? "", '', "AIMatch",
                                                simplePostTextMessage:
                                                    "${GayaStrings.expandedDes31.tr} ${matchController.isSameAge()} ${GayaStrings.expandedDes32.tr} ${matchController.getMutualTopics()} ${GayaStrings.expandedDes322.tr} ${matchController.getMutualCommunities()} ${GayaStrings.expandedDes33.tr}",
                                                customData: "AIMatch");
                                            Future.delayed(const Duration(seconds: 5));
                                            matchController.setIsLoading(status: false);
                                          })
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        AiAssetsPath.lockIcon,
                                        width: 24.w,
                                        height: 24.h,
                                        color: AppColors.white,
                                      ),
                                      const SizedBox(width: 3),
                                      const AIMatchTimer(),
                                    ],
                                  )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }
}

///Give it try button
class MatchButtonWidget extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final double width;
  final double height;
  final double? fontSize;

  const MatchButtonWidget(
      {required this.title, required this.onTap, required this.width, required this.height, this.fontSize = 16, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          width: width.w,
          height: height.h,
          alignment: Alignment.center,
          decoration: ShapeDecoration(
            color: AppColors.white.withOpacity(0.9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4).r,
            ),
          ),
          child: !AIMatchesController.to.isLoading
              ? GradientText(
                  title,
                  style: GayaTypography.titleSemiBold.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: fontSize!.sp,
                    height: 1.20,
                  ),
                  gradient: AppColors.aiMatchTextGradient,
                )
              : CupertinoActivityIndicator(color: AppColors.foundationPurple)),
    );
  }
}

///Expanded contents
class ExpandedContents extends StatelessWidget {
  final String title;
  final String des;
  final String buttonText;
  final String textButtonText;
  final VoidCallback onTap;
  final VoidCallback onTap2;
  final bool isRequestSend;
  final bool permissionStatus;

  const ExpandedContents(
      {Key? key,
      required this.title,
      required this.des,
      required this.buttonText,
      required this.textButtonText,
      required this.onTap,
      required this.onTap2,
      required this.isRequestSend,
      required this.permissionStatus})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    final box2 = SizedBox(
      height: MySpaces.gap2.h,
    );
    final box4 = SizedBox(
      height: MySpaces.gap4.h,
    );
    LocalizationController localizationController = Get.find();
    return Positioned(
        top: isRequestSend ? 100.h : 91.h,
        left: 20.w,
        right: 20.w,
        child: Column(
          crossAxisAlignment: localizationController.isHebrew ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              title,
              textAlign: localizationController.isHebrew ? TextAlign.right : TextAlign.left,
              textDirection: localizationController.isHebrew ? TextDirection.rtl : TextDirection.ltr,
              style:
                  GayaTypography.titleSemiBold.copyWith(fontWeight: FontWeight.w700, fontSize: 24.sp, height: 1.17, color: AppColors.white),
            ),
            box2,
            Text(
              des,
              textAlign: localizationController.isHebrew ? TextAlign.right : TextAlign.left,
              textDirection: localizationController.isHebrew ? TextDirection.rtl : TextDirection.ltr,
              style:
                  GayaTypography.titleSemiBold.copyWith(fontWeight: FontWeight.w400, fontSize: 16.sp, height: 1.50, color: AppColors.white),
            ),
            box2,

            ///check if user has permission to send notification(if not allowed then show button otherwise hide it)
            if (!permissionStatus)
              MatchButtonWidget(
                title: buttonText,
                width: size.width,
                height: 40.h,
                onTap: onTap2,
                fontSize: 20,
              ),
            box4,
            Center(
              child: GestureDetector(
                onTap: onTap,
                child: Text(
                  textButtonText,
                  textAlign: localizationController.isHebrew ? TextAlign.right : TextAlign.left,
                  textDirection: localizationController.isHebrew ? TextDirection.rtl : TextDirection.ltr,
                  style: GayaTypography.titleSemiBold
                      .copyWith(fontWeight: FontWeight.w400, fontSize: 16.sp, height: 1.50, color: AppColors.white),
                ),
              ),
            ),
          ],
        ));
  }
}

///when match found
class ExpandedContents2 extends StatelessWidget {
  final String title;
  final String des;
  final String buttonText;
  final String textButtonText;
  final VoidCallback onTap;
  final VoidCallback onTap2;

  const ExpandedContents2(
      {Key? key,
      required this.title,
      required this.des,
      required this.buttonText,
      required this.textButtonText,
      required this.onTap,
      required this.onTap2})
      : super(key: key);

  UserModel get userModel => UserModel.to;

  AIMatchesController get matchController => AIMatchesController.to;

  @override
  Widget build(BuildContext context) {
    final LocalizationController localizationController = Get.find();
    final duration = AIMatchesController.to.getTotalDurationForTweenAnimation();
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    SizedBox box = SizedBox(
      height: MySpaces.gap2.h,
    );
    SizedBox box2 = SizedBox(
      height: MySpaces.gap3.h,
    );
    SizedBox box3 = SizedBox(
      height: MySpaces.gap4.h,
    );
    return Positioned(
        top: 16.h,
        left: 20.w,
        right: 20.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 327.w,
              height: 34.3.h,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    AiAssetsPath.boot,
                    width: 30.w,
                    height: 34.3.h,
                  ),
                  Text(
                    title,
                    textAlign: localizationController.isHebrew ? TextAlign.right : TextAlign.left,
                    textDirection: localizationController.isHebrew ? TextDirection.rtl : TextDirection.ltr,
                    style: GayaTypography.titleSemiBold
                        .copyWith(fontWeight: FontWeight.w700, fontSize: 24.sp, height: 1.17, color: AppColors.white),
                  ),
                  SvgPicture.asset(
                    AiAssetsPath.surprised,
                    fit: BoxFit.scaleDown,
                    height: 24.r,
                    width: 24.r,
                  ),
                ],
              ),
            ),
            box2,
            SizedBox(
              width: 177.50.w,
              height: 78.h,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Stack(
                        children: [
                          (matchController.myAIMatchModel?.matchedUserProfile?.imageUrl == "")
                              ? CircleAvatar(
                                  radius: 25.r,
                                  backgroundColor: AppColors.primary, // Set a transparent background to make the circle's border blurry too

                                  child: Image.asset(
                                    AiAssetsPath.boot,
                                  ),
                                )
                              : CircleAvatar(
                                  backgroundColor: Colors.grey[300],
                                  radius: 25.r,
                                  child: ProfileImageWidget(url: matchController.myAIMatchModel?.matchedUserProfile?.imageUrl)),

                          ///this is used to blur the match found image.
                          CircleAvatar(
                            radius: 25.r,
                            backgroundColor:
                                AppColors.white.withOpacity(0.5), // Set a transparent background to make the circle's border blurry too
                          ),
                        ],
                      ),
                      Text(
                        matchController.myAIMatchModel?.matchedUserProfile?.name ?? '',
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GayaTypography.titleSemiBold
                            .copyWith(fontWeight: FontWeight.w400, fontSize: 16.sp, height: 1.50, color: AppColors.white),
                      ),
                    ],
                  ),
                  Text(
                    "+",
                    style: GayaTypography.titleSemiBold
                        .copyWith(fontWeight: FontWeight.w700, fontSize: 30.sp, height: 0, color: AppColors.white),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      (userModel.profilePicture == '' || userModel.profilePicture == null)
                          ? CircleAvatar(
                              radius: 25.r,
                              backgroundColor: AppColors.primary,
                              child: Image.asset(
                                AiAssetsPath.boot,
                              ),
                            )
                          : CircleAvatar(
                              backgroundColor: Colors.grey[300], radius: 25.r, child: ProfileImageWidget(url: userModel.profilePicture)),
                      SizedBox(
                        width: 70.w,
                        child: Text(
                          userModel.userName,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: GayaTypography.titleSemiBold
                              .copyWith(fontWeight: FontWeight.w400, fontSize: 16.sp, height: 1.50, color: AppColors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            box2,
            Text(
              des,
              textAlign: TextAlign.center,
              textDirection: localizationController.isHebrew ? TextDirection.rtl : TextDirection.ltr,
              style:
                  GayaTypography.titleSemiBold.copyWith(fontWeight: FontWeight.w400, fontSize: 16.sp, height: 1.5, color: AppColors.white),
            ),
            box3,
            MatchButtonWidget(
              title: buttonText,
              width: Get.width,
              height: 40.h,
              onTap: onTap2,
            ),
            box3,
            GestureDetector(
              onTap: onTap,
              child: Text(
                // '${hours.toString().padLeft(2, "0")}:${minutes.toString().padLeft(2, "0")} ',
                "${GayaStrings.you_have.tr} ${hours.toString().padLeft(2, "0")}:${minutes.toString().padLeft(2, "0")} ${GayaStrings.hours_until_its_too_late.tr}",
                textAlign: localizationController.isHebrew ? TextAlign.right : TextAlign.left,
                textDirection: localizationController.isHebrew ? TextDirection.rtl : TextDirection.ltr,
                style: GayaTypography.titleSemiBold
                    .copyWith(fontWeight: FontWeight.w400, fontSize: 12.64.sp, height: 1.50, letterSpacing: 0.04, color: AppColors.white),
              ),
            )
          ],
        ));
  }
}
