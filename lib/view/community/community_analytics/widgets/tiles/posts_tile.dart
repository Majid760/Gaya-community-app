import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/language/translation.dart';
import '../../../../../utils/textstyles.dart';
import '../../../../../utils/theme/app_spaces.dart';
import '../analytics_tile.dart';
import '../comparison_percentage_widget.dart';

class PostsTile extends StatelessWidget {
  const PostsTile({
    super.key,
    required this.posts,
    required this.fromTimeDuration,
    required this.percentage,
  });

  /* -------------------------------------------------------------------------- */
  /*                                  VARIABLES                                 */
  /* -------------------------------------------------------------------------- */
  final int posts;
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
          /* --------------------------- posts text [Text] -------------------------- */
          Text(
            GayaStrings.posts.tr,
            textAlign: TextAlign.left,
            style: CustomTypography.dark12,
          ),
          MySpaces.gap3y,
          /* --------------------------- posts count [Text] --------------------------- */
          Text(
            posts.toString(),
            textAlign: TextAlign.left,
            style: CustomTypography.headingStyle24,
          ),
          MySpaces.gap3y,
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
