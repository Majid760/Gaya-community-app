import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/language/translation.dart';
import '../../../../../utils/textstyles.dart';
import '../../../../../utils/theme/app_spaces.dart';
import '../analytics_tile.dart';
import '../comparison_percentage_widget.dart';

class CommentsTile extends StatelessWidget {
  const CommentsTile({
    super.key,
    required this.comments,
    required this.fromTimeDuration,
    required this.percentage,
  });

  /* -------------------------------------------------------------------------- */
  /*                                  VARIABLES                                 */
  /* -------------------------------------------------------------------------- */
  final int comments;
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
          /* --------------------------- comments text [Text] -------------------------- */
          Text(
            GayaStrings.comments.tr,
            textAlign: TextAlign.left,
            style: CustomTypography.dark12,
          ),
          MySpaces.gap3y,
          /* -------------------------- comments count [Text] ------------------------- */
          Text(
            comments > 0 ? comments.toString() : 'N/A',
            textAlign: TextAlign.left,
            style: CustomTypography.headingStyle24,
          ),
          MySpaces.gap3y,
          if (comments > 0)
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
