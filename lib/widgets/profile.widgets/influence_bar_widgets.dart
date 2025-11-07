import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
// Influence Bar Widgets Below

class InfluenceBarBottomSheet extends StatefulWidget {
  const InfluenceBarBottomSheet({Key? key}) : super(key: key);

  @override
  State<InfluenceBarBottomSheet> createState() => _InfluenceBarBottomSheetState();
}

class _InfluenceBarBottomSheetState extends State<InfluenceBarBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.9,
      width: MediaQuery.sizeOf(context).width,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(13.0), topRight: Radius.circular(13.0)),
      ),
      padding: const EdgeInsets.all(20).r,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(),
                Text(GayaStrings.influenceBar_txt.tr, style: GayaTypography.title),
                InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text(GayaStrings.done.tr, style: GayaTypography.title.copyWith(color: AppColors.primary))),
              ],
            ),
            SizedBox(
              height: 40.r,
            ),
            Text(GayaStrings.influenceBarBottom_txt.tr,
                textAlign: TextAlign.center, style: GayaTypography.title.copyWith(fontSize: 14, fontWeight: FontWeight.w400)),
            SizedBox(
              height: 40.r,
            ),
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                InfluencePointsDetailItemWidget(
                  influenceIconWidget: SvgIconWidget.heartPrimary,
                  influenceTitle: GayaStrings.influenceBarHeartPrimary_txt.tr,
                  influenceDetail: GayaStrings.influenceBarHeartDescription_txt.tr,
                ),
                SizedBox(
                  height: 30.r,
                ),
                InfluencePointsDetailItemWidget(
                  influenceIconWidget: SvgIconWidget.tickGreen,
                  influenceTitle: GayaStrings.influenceBarTickGreen_txt.tr,
                  influenceDetail: GayaStrings.influenceBarTickDescription_txt.tr,
                ),
                SizedBox(
                  height: 30.r,
                ),
                InfluencePointsDetailItemWidget(
                  influenceIconWidget: SvgIconWidget.tickBlue,
                  influenceTitle: GayaStrings.influenceBarTickBlue_txt.tr,
                  influenceDetail: GayaStrings.influenceBarBlueTickDescription_txt.tr,
                ),
                SizedBox(
                  height: 30.r,
                ),
                InfluencePointsDetailItemWidget(
                  influenceIconWidget: SvgIconWidget.emojiBlue,
                  influenceTitle: GayaStrings.influenceBarEmojiBlue_txt.tr,
                  influenceDetail: GayaStrings.influenceBarBlueEmojiDescription_txt.tr,
                ),
                SizedBox(
                  height: 30.r,
                ),
                InfluencePointsDetailItemWidget(
                  influenceIconWidget: SvgIconWidget.emojiYellow,
                  influenceTitle: GayaStrings.influenceBarEmojiYellow_txt.tr,
                  influenceDetail: GayaStrings.influenceBarEmojiDescription_txt.tr,
                ),
                SizedBox(
                  height: 30.r,
                ),
                InfluencePointsDetailItemWidget(
                  influenceIconWidget: SvgIconWidget.closeRed,
                  influenceTitle: GayaStrings.influenceBarCloseRed_txt.tr,
                  influenceDetail: GayaStrings.influenceBarCloseDescription_txt.tr,
                ),
                SizedBox(
                  height: 30.r,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class InfluencePointsDetailItemWidget extends StatelessWidget {
  final Widget influenceIconWidget;
  final String influenceTitle;
  final String influenceDetail;

  const InfluencePointsDetailItemWidget(
      {super.key, required this.influenceIconWidget, required this.influenceTitle, required this.influenceDetail});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            height: 41.r,
            width: 41.r,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: influenceIconWidget),
        SizedBox(
          width: 16.r,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(influenceTitle, style: GayaTypography.title.copyWith(fontWeight: FontWeight.w500)),
              SizedBox(
                height: 6.r,
              ),
              Text(influenceDetail, maxLines: 3, overflow: TextOverflow.ellipsis, style: GayaTypography.subtitleRegular)
            ],
          ),
        )
      ],
    );
  }
}

class InfluenceBarWidget extends StatefulWidget {
  final int score;
  final bool isMe;
  const InfluenceBarWidget({super.key, required this.score, required this.isMe});

  @override
  State<InfluenceBarWidget> createState() => _InfluenceBarWidgetState();
}

class _InfluenceBarWidgetState extends State<InfluenceBarWidget> {
  String percentage = '0';
  String influenceText = GayaStrings.if_you_want_to_stay_level_up_txt;
  Color influenceColor = AppColors.error;
  Widget influenceIconWidget = SvgIconWidget.closeRed;

  final user = UserModel.to;

  @override
  void initState() {
    getPercentage(widget.score);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10).r,
          child: LinearPercentIndicator(
            animation: widget.isMe,
            animationDuration: 1000,
            alignment: MainAxisAlignment.start,
            width: MediaQuery.sizeOf(context).width - 51.r,
            lineHeight: 29.r,
            percent: user.isUserInfluenceScoreGreaterThan100(widget.score) ? 1.0 : (widget.score / 100),
            barRadius: Radius.circular(30.r),
            widgetIndicator: Container(
                height: 38.r,
                width: 40.r,
                // color: Colors.amber,
                decoration: BoxDecoration(
                    gradient: user.isUserInfluenceScoreLessThan90(widget.score) ? null : AppColors.influenceGradient,
                    color: user.isUserInfluenceScoreBetween15And90(widget.score) ? influenceColor : null,
                    borderRadius: BorderRadius.circular(1000)),
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 10, right: 45).r,
                child: Text("$percentage%",
                    textAlign: TextAlign.start, style: GayaTypography.titleMedium.copyWith(fontSize: 12.sp, color: AppColors.white))),
            center: (widget.isMe)
                ? Container(
                width: MediaQuery.sizeOf(context).width - 51.r,
                    padding: EdgeInsets.only(left: user.isUserInfluenceScoreGreaterThanOrEqualTo60(widget.score) ? 25 : 10, right: 10).r,
                    alignment: user.isUserInfluenceScoreGreaterThanOrEqualTo60(widget.score) ? Alignment.centerLeft : Alignment.centerRight,
                    // color: Colors.green,
                    child: Text(influenceText.tr,
                        style: GayaTypography.titleMedium.copyWith(color: (widget.score < 60) ? AppColors.black : AppColors.white)))
                : null,
            linearStrokeCap: LinearStrokeCap.roundAll,
            backgroundColor: AppColors.secondary4,
            progressColor: user.isUserInfluenceScoreLessThan90(widget.score) ? influenceColor : null,
            linearGradient: user.isUserInfluenceScoreLessThan90(widget.score) ? null : AppColors.influenceGradient,
          ),
        ),
        Container(
            height: 41.r,
            width: 41.r,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: influenceIconWidget)
      ],
    );
  }

  void getPercentage(int score) {
    if (user.isUserInfluenceScoreLessThanOrEqualTo20(score)) {
      percentage = score.toString();
      influenceText = GayaStrings.if_you_want_to_stay_level_up_txt;
      influenceColor = AppColors.error;
      influenceIconWidget = SvgIconWidget.closeRed;
    } else if (user.isUserInfluenceScoreBetween20And40(score)) {
      percentage = score.toString();
      influenceText = GayaStrings.you_can_do_better_txt;
      influenceColor = AppColors.warning;
      influenceIconWidget = SvgIconWidget.emojiYellow;
    } else if (user.isUserInfluenceScoreBetween40And50(score)) {
      percentage = score.toString();
      influenceText = GayaStrings.crush_it_its_up_you_txt;
      influenceColor = AppColors.blueColor;
      influenceIconWidget = SvgIconWidget.emojiBlue;
    } else if (user.isUserInfluenceScoreBetween50And60(score)) {
      percentage = score.toString();
      influenceText = GayaStrings.keep_killing_it_txt;
      influenceColor = AppColors.blueColor;
      influenceIconWidget = SvgIconWidget.tickBlue;
    } else if (user.isUserInfluenceScoreBetween60And70(score)) {
      percentage = score.toString();
      influenceText = GayaStrings.you_are_rocking_txt;
      influenceColor = AppColors.success;
      influenceIconWidget = SvgIconWidget.tickGreen;
    } else if (user.isUserInfluenceScoreBetween70And80(score)) {
      percentage = score.toString();
      influenceText = GayaStrings.wow_you_are_killing_it_txt;
      influenceColor = AppColors.success;
      influenceIconWidget = SvgIconWidget.tickGreen;
    } else if (user.isUserInfluenceScoreBetween80And90(score)) {
      percentage = score.toString();
      influenceText = GayaStrings.you_are_an_absolute_legend_txt;
      influenceColor = AppColors.success;
      influenceIconWidget = SvgIconWidget.tickGreen;
    } else if (user.isUserInfluenceScoreGreaterThanOrEqualTo90(score)) {
      if (user.isUserInfluenceScoreGreaterThan100(score)) {
        percentage = '100';
      } else {
        percentage = score.toString();
      }
      influenceText = GayaStrings.you_are_the_ultimate_champion_txt;
      influenceIconWidget = SvgIconWidget.heartPrimary;
    }
  }
}

// Influence Streak widgets below

class InfluenceStreakBarBottomSheet extends StatefulWidget {
  const InfluenceStreakBarBottomSheet({Key? key}) : super(key: key);

  @override
  State<InfluenceStreakBarBottomSheet> createState() => _InfluenceStreakBarBottomSheetState();
}

class _InfluenceStreakBarBottomSheetState extends State<InfluenceStreakBarBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.7,
      width: MediaQuery.sizeOf(context).width,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(13.0), topRight: Radius.circular(13.0)),
      ),
      padding: const EdgeInsets.all(20).r,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(),
                Text(GayaStrings.influence_days_streak_txt.tr, style: GayaTypography.title),
                InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text(GayaStrings.done.tr, style: GayaTypography.title.copyWith(color: AppColors.primary))),
              ],
            ),
            SizedBox(
              height: 20.r,
            ),
            Text(GayaStrings.influence_days_streak_detail_txt.tr,
                textAlign: TextAlign.center, style: GayaTypography.title.copyWith(fontSize: 14, fontWeight: FontWeight.w400)),
            SizedBox(
              height: 20.r,
            ),
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                InfluenceStreakListTile(
                  influenceIconWidget: SvgIconWidget.fireYellow,
                  influenceTitle: GayaStrings.three_days_streak_txt.tr,
                  influenceDetail: GayaStrings.three_days_streak_detail_txt.tr,
                ),
                SizedBox(
                  height: 30.r,
                ),
                InfluenceStreakListTile(
                  influenceIconWidget: SvgIconWidget.fireRed,
                  influenceTitle: GayaStrings.seven_days_streak_txt.tr,
                  influenceDetail: GayaStrings.seven_days_streak_detail_txt.tr,
                ),
                SizedBox(
                  height: 30.r,
                ),
                InfluenceStreakListTile(
                  influenceIconWidget: SvgIconWidget.firePrimary,
                  influenceTitle: GayaStrings.one_month_streak_txt.tr,
                  influenceDetail: GayaStrings.one_month_streak_detail_txt.tr,
                ),
                SizedBox(
                  height: 30.r,
                ),
                InfluenceStreakListTile(
                  influenceIconWidget: SvgIconWidget.fireGreen,
                  influenceTitle: GayaStrings.three_month_streak_txt.tr,
                  influenceDetail: GayaStrings.three_month_streak_detail_txt.tr,
                ),
                SizedBox(
                  height: 30.r,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class InfluenceStreakListTile extends StatelessWidget {
  final Widget influenceIconWidget;
  final String influenceTitle;
  final String influenceDetail;

  const InfluenceStreakListTile(
      {super.key, required this.influenceIconWidget, required this.influenceTitle, required this.influenceDetail});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            height: 41.r,
            width: 41.r,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: influenceIconWidget),
        SizedBox(
          width: 16.r,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(influenceTitle, style: GayaTypography.title.copyWith(fontWeight: FontWeight.w500)),
              SizedBox(
                height: 6.r,
              ),
              Text(influenceDetail, maxLines: 3, overflow: TextOverflow.ellipsis, style: GayaTypography.subtitleRegular)
            ],
          ),
        )
      ],
    );
  }
}

class InfluenceStreakWidget extends StatefulWidget {
  final int streakScore;
  const InfluenceStreakWidget({super.key, required this.streakScore});

  @override
  State<InfluenceStreakWidget> createState() => _InfluenceStreakWidgetState();
}

class _InfluenceStreakWidgetState extends State<InfluenceStreakWidget> {
  Widget influenceIconWidget = SvgIconWidget.fireYellow;
  LinearGradient influenceColor = AppColors.influenceStreakFireYellowGradient;
  final user = UserModel.to;

  @override
  void initState() {
    getStreakType();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LinearPercentIndicator(
      animation: true,
      // padding: EdgeInsets.zero,
      padding: const EdgeInsets.only(left: 6, right: 16).r,
      animationDuration: 1000,
      alignment: MainAxisAlignment.start,
      lineHeight: 29.r,
      percent: (widget.streakScore / 100),
      barRadius: Radius.circular(30.r),
      widgetIndicator: Container(
        height: 45.r,
        width: 70.r,
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.only(
          top: 2,
          left: 0,
        ).r,
        child: influenceIconWidget,
      ),
      linearStrokeCap: LinearStrokeCap.roundAll,
      backgroundColor: AppColors.secondary4,
      linearGradient: influenceColor,
    );
  }

  void getStreakType() {
    if (user.isUserOnThreeDaysStreak(user.streakDaysCount ?? 0)) {
      influenceIconWidget = SvgIconWidget.fireYellow;
      influenceColor = AppColors.influenceStreakFireYellowGradient;
    } else if (user.isUserOnSevenDaysStreak(user.streakDaysCount ?? 0)) {
      influenceIconWidget = SvgIconWidget.fireRed;
      influenceColor = AppColors.influenceStreakFireRedGradient;
    } else if (user.isUserOnThirtyDaysStreak(user.streakDaysCount ?? 0)) {
      influenceIconWidget = SvgIconWidget.firePrimary;
      influenceColor = AppColors.influenceStreakFirePrimaryGradient;
    } else if (user.isUserOnNinetyDaysStreak(user.streakDaysCount ?? 0)) {
      influenceIconWidget = SvgIconWidget.fireGreen;
      influenceColor = AppColors.influenceStreakFireGreenGradient;
    }
  }
}
