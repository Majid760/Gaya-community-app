import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaya/controller/group.controller.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../shared/view/widget/gaya_back_button.dart';
import '../../utils/methods.dart';
import '../../utils/textstyles.dart';

class GroupSettingsView extends StatefulWidget {
  final String communityDescription;
  final String communityId;

  const GroupSettingsView({Key? key, required this.communityDescription, required this.communityId}) : super(key: key);

  @override
  State<GroupSettingsView> createState() => _GroupSettingsViewState();
}

class _GroupSettingsViewState extends State<GroupSettingsView> {
  var getAllMembers;

  @override
  void initState() {
    final controller = context.read<GroupController>();
    getAllMembers = controller.getMembers(widget.communityId);
    controller.adminofCommunity(widget.communityId);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: kBlackColor),
        elevation: 0,
        backgroundColor: kWhiteColor,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: const GayaBackButton(),
        title: Text(GayaStrings.community_settings.tr, style: CustomTypography.bodyStyle),
      ),
      body: Column(
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
                        Navigator.pop(context);
                      },
                      child: Text(GayaStrings.cancel_txt.tr, style: CustomTypography.body2EnableStyle1)),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(GayaStrings.settings_txt.tr, style: CustomTypography.bodyStyle),
                )
              ],
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  GayaStrings.delete_my_account.tr,
                  style: CustomTypography.body4StyleLowWeight,
                ),
                SvgPicture.asset("Assets/icons/right_arrow.svg"),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          CupertinoListTileActionWidget(
            title: GayaStrings.privacy_policy.tr,
            onTap: () => Methods.openPrivacyPolicy(context),
          ),
          CupertinoListTileActionWidget(
            title: GayaStrings.terms_of_use.tr,
            onTap: () => Methods.openTermsAndConditions(context),
          ),
        ],
      ),
    );
  }
}

class CupertinoListTileActionWidget extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const CupertinoListTileActionWidget({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20).r,
      visualDensity: const VisualDensity(vertical: -2),
      trailing: SvgPicture.asset("Assets/icons/right_arrow.svg"),
      title: Text(
        title,
        style: CustomTypography.body4StyleLowWeight,
      ),
      onTap: onTap,
    );
  }
}
