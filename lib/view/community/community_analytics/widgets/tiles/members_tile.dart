import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/language/translation.dart';
import '../../../../../utils/textstyles.dart';
import '../../../../../utils/theme/app_spaces.dart';
import '../analytics_tile.dart';

class MembersTile extends StatelessWidget {
  const MembersTile({
    super.key,
    required this.members,
  });

  /* -------------------------------------------------------------------------- */
  /*                                  VARIABLES                                 */
  /* -------------------------------------------------------------------------- */
  final int members;

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
          /* --------------------------- members text [Text] -------------------------- */
          Text(
            GayaStrings.members.tr,
            textAlign: TextAlign.left,
            style: CustomTypography.dark12,
          ),
          MySpaces.gap3y,
          /* -------------------------- members count [Text] -------------------------- */
          Text(
            members.toString(),
            textAlign: TextAlign.left,
            style: CustomTypography.headingStyle24,
          ),
        ],
      ),
    );
  }
}
