import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/community_visibility_row.dart';
import 'package:gaya/components/dot_widget.dart';
import 'package:gaya/controller/group.controller.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/services/services.dart';
import 'package:gaya/shared/view/widget/gaya_alert_dialog.dart';
import 'package:gaya/shared/view/widget/gaya_back_button.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/gaya_text_widget.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_spaces.dart';
import 'package:gaya/widgets/group_view_widget/show.community.members.dart';
import 'package:gaya/widgets/profile.widgets/button.widget.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../controller/firebase_analytics_controller.dart';
import '../../controller/homepage.controller.dart';
import '../../utils/textstyles.dart';

class AboutGroupView extends StatefulWidget {
  final Community community;

  const AboutGroupView({Key? key, required this.community}) : super(key: key);

  @override
  State<AboutGroupView> createState() => _AboutGroupViewState();
}

class _AboutGroupViewState extends State<AboutGroupView> {
  var getAllMembers;

  @override
  void initState() {
    final controller = context.read<GroupController>();
    getAllMembers = controller.getMembers(widget.community.communityId!);
    controller.adminofCommunity(widget.community.communityId!);

    // Logging view about community analytics event
    AnalyticsController.to.instance.logViewAboutCommunity(
      userId: UserModel.to.uId ?? '',
      communityId: widget.community.communityId ?? '',
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<GroupController>(context, listen: false);
    final gap16 = SizedBox(height: MySpaces.gap4.h);
    final gap8 = SizedBox(height: MySpaces.gap2.h);
    final gap4 = SizedBox(height: MySpaces.gap1.h);
    return Scaffold(
      backgroundColor: kWhiteColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: kBlackColor),
        elevation: 0,
        backgroundColor: kWhiteColor,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: const GayaBackButton(),
        title: Text(GayaStrings.about.tr, style: GayaTypography.titleMedium),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: StreamBuilder<bool>(
              stream: controller.isNotificationEnabled(widget.community.communityId!),
              builder: (_, isNotificationEnabled) {
                if (isNotificationEnabled.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                } else if (isNotificationEnabled.connectionState == ConnectionState.active) {
                  final isEnabled = isNotificationEnabled.data ?? false;
                  return CupertinoIconButton(
                      onPressed: () =>
                          toggleNotificationSubscriptionBottomModal(context, controller, widget.community.communityId!, isEnabled),
                      icon: SvgIconWidget.bellFilled(color: isEnabled == true ? kprimaryColor : kSecondaryColor));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      body: FutureBuilder<int?>(
          initialData: widget.community.communityMembers ?? 0,
          future: Services.to.getCommunityTotalMembers(widget.community.communityId!),
          builder: (context, snap) {
            final totalMembers = snap.data ?? 0;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10).r,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                              child: Text(widget.community.communityName ?? "",
                                  maxLines: 1, overflow: TextOverflow.ellipsis, style: GayaTypography.h4)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6).r,
                            child: DotWidget(color: AppColors.secondary, size: 2.r),
                          ),
                          CommunityTypeWidget(
                            community: widget.community,
                            textStyle: GayaTypography.subtitleMedium.copyWith(height: 1.40),
                          ),
                        ],
                      ),
                      gap16,
                      Text(GayaStrings.description_txt.tr, style: GayaTypography.titleSemiBold),
                      gap8,
                      Align(
                        alignment: context.read<HomePageController>().isRTL(widget.community.communityDescription ?? "")
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: GayaTextWidget(widget.community.communityDescription ?? ""),
                      ),
                      gap16,
                      gap16,
                      Row(
                        children: [
                          Text(GayaStrings.members_txt.tr, style: CustomTypography.body2StyleWeightBlack),
                          SizedBox(width: MySpaces.gap1.w),
                          Text('(${totalMembers})', style: CustomTypography.body2StyleWeightBlack),
                        ],
                      ),
                      // gap16,
/*
                    /// TODO : Implement search functionality
                    const GayaSearchTextField(
                      isEnabled: false,
                    ), */
                      gap4,
                    ],
                  ),
                ),
                // member lists.
                Expanded(
                  child: GetCommunityMembers(
                      communityModel: widget.community,
                      getAllMembers: getAllMembers,
                      controller: controller,
                      communityId: widget.community.communityId!),
                )
              ],
            );
          }),
    );
  }
}

void toggleNotificationSubscriptionBottomModal(BuildContext context, GroupController controller, String communityId, bool isEnabled) async {
  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(13.0), topRight: Radius.circular(13.0))),
      builder: (context) {
        bool value = isEnabled;
        return StatefulBuilder(builder: (context, setState) {
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
                      Text(
                        GayaStrings.community_notification_2.tr,
                        style: CustomTypography.bodyStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(GayaStrings.new_community_posts.tr, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                      Switch.adaptive(
                          activeColor: kprimaryColor,
                          value: value,
                          onChanged: (newValue) async {
                            // Navigator.pop(context);
                            showGayaAlertDialogButton(
                              context: context,
                              actionText: GayaStrings.change_community_status.tr,
                              tapOnYes: () async {
                                Navigator.pop(context);
                                controller.toggleNotificationSubscription(communityId, newValue);
                                setState(() => value = newValue);
                              },
                              tapOnNo: () {
                                Navigator.pop(context);
                              },
                            );
                          })
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(GayaStrings.receive_alerts_for_any_update_in_community.tr,
                      style: CustomTypography.secondaryFontStyleWeight, maxLines: 2),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        });
      });
}
