import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:get/get.dart';

import '../../../utils/language/translation.dart';
import 'widgets/community_analytics_screen_body.dart';

class CommunityAnalyticsScreen extends StatelessWidget {
  const CommunityAnalyticsScreen({
    super.key,
    required this.communityId,
  });

  /* -------------------------------- VARIABLES ------------------------------- */
  final String communityId;

  @override
  Widget build(BuildContext context) {
    /* -------------------------------------------------------------------------- */
    /*                       main scaffold widget [Scaffold]                      */
    /* -------------------------------------------------------------------------- */
    return Scaffold(
      backgroundColor: kWhiteColor,
      /* ------------------------- screen appbar [AppBar] ------------------------- */
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        shape: Border(
          bottom: BorderSide(
            color: kBaseGrey.withOpacity(0.5),
          ),
        ),
        iconTheme: const IconThemeData(color: kBlackColor),
        title: Text(
          GayaStrings.community_analytics.tr,
          style: CustomTypography.bodyStyle,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      /* --------------- screen body [CommunityAnalyticsScreenBody] --------------- */
      body: CommunityAnalyticsScreenBody(communityId: communityId),
    );
  }
}
