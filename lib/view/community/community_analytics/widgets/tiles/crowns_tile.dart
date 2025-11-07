import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/language/translation.dart';
import '../../../../../utils/textstyles.dart';
import '../../../../../utils/theme/app_spaces.dart';
import '../analytics_tile.dart';
import '../comparison_percentage_widget.dart';

class CrownsTile extends StatelessWidget {
  const CrownsTile({
    super.key,
    required this.crowns,
    required this.fromTimeDuration,
    required this.percentage,
  });

  /* -------------------------------------------------------------------------- */
  /*                                  VARIABLES                                 */
  /* -------------------------------------------------------------------------- */
  final int crowns;
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
          /* --------------------------- crowns text [Text] -------------------------- */
          Text(
            GayaStrings.crowns.tr,
            textAlign: TextAlign.left,
            style: CustomTypography.dark12,
          ),
          MySpaces.gap3y,
          /* --------------------------- crowns count [Text] -------------------------- */
          Text(
            crowns > 0 ? crowns.toString() : 'N/A',
            textAlign: TextAlign.left,
            style: CustomTypography.headingStyle24,
          ),
          MySpaces.gap3y,
          if (crowns > 0)
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
