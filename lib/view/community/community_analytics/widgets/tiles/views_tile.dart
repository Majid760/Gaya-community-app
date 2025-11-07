// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/language/translation.dart';
import '../../../../../utils/textstyles.dart';
import '../../../../../utils/theme/app_spaces.dart';
import '../analytics_tile.dart';
import '../comparison_percentage_widget.dart';

class ViewsTile extends StatelessWidget {
  const ViewsTile({
    Key? key,
    required this.views,
    required this.fromTimeDuration,
    required this.percentage,
  }) : super(key: key);

  /* -------------------------------------------------------------------------- */
  /*                                  VARIABLES                                 */
  /* -------------------------------------------------------------------------- */
  final int views;
  final String fromTimeDuration;
  final double percentage;

  @override
  Widget build(BuildContext context) {
    /* -------------------------------------------------------------------------- */
    /*                     main analytics tile [AnalyticsTile]                    */
    /* -------------------------------------------------------------------------- */
    return AnalyticsTile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          /* --------------------------- views text [Text] -------------------------- */
          Text(
            GayaStrings.views.tr,
            textAlign: TextAlign.left,
            style: CustomTypography.dark12,
          ),
          MySpaces.gap3y,
          /* --------------------------- views count [Text] --------------------------- */
          Text(
            views > 0 ? views.toString() : 'N/A',
            textAlign: TextAlign.left,
            style: CustomTypography.headingStyle24,
          ),
          MySpaces.gap3y,
          if (views > 0)
            /* ----------- comparison percentage widget [ComparisonPercentage] ---------- */
            ComparisonPercentage(
              fromTimeDuration: fromTimeDuration,
              percentage: percentage,
            ),
        ],
      ),
    );
  }
}
