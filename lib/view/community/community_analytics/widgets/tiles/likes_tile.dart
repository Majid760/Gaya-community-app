import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/language/translation.dart';
import '../../../../../utils/textstyles.dart';
import '../../../../../utils/theme/app_spaces.dart';
import '../analytics_tile.dart';
import '../comparison_percentage_widget.dart';

class LikesTile extends StatelessWidget {
  const LikesTile({
    super.key,
    required this.likes,
    required this.fromTimeDuration,
    required this.percentage,
  });

  /* -------------------------------------------------------------------------- */
  /*                                  VARIABLES                                 */
  /* -------------------------------------------------------------------------- */
  final int likes;
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
          /* --------------------------- likes text [Text] -------------------------- */
          Text(
            GayaStrings.likes.tr,
            textAlign: TextAlign.left,
            style: CustomTypography.dark12,
          ),
          MySpaces.gap3y,
          /* --------------------------- likes count [Text] --------------------------- */
          Text(
            likes > 0 ? likes.toString() : 'N/A',
            textAlign: TextAlign.left,
            style: CustomTypography.headingStyle24,
          ),
          MySpaces.gap3y,
          if (likes > 0)
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
