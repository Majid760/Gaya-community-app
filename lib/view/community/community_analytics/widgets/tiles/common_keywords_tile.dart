import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/language/translation.dart';
import '../../../../../utils/textstyles.dart';
import '../../../../../utils/theme/app_spaces.dart';
import '../analytics_tile.dart';

class CommonKeywordsTile extends StatelessWidget {
  const CommonKeywordsTile({
    super.key,
    required this.keywords,
  });

  /* -------------------------------------------------------------------------- */
  /*                                  VARIABLES                                 */
  /* -------------------------------------------------------------------------- */
  final List<String> keywords;

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
          /* ----------------------- common keywords text [Text] ---------------------- */
          Text(
            GayaStrings.commonKeywords.tr,
            textAlign: TextAlign.left,
            style: CustomTypography.dark12,
            overflow: TextOverflow.ellipsis,
          ),
          MySpaces.gap3y,
          /* ------------------------ common keywords [Column] ------------------------ */
          keywords.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      keywords[0],
                      textAlign: TextAlign.left,
                      style: CustomTypography.headingStyle24Purple,
                      overflow: TextOverflow.ellipsis,
                    ),
                    MySpaces.gap2y,
                    Text(
                      keywords[1],
                      textAlign: TextAlign.left,
                      style: CustomTypography.headingStyle24Purple,
                      overflow: TextOverflow.ellipsis,
                    ),
                    MySpaces.gap2y,
                    Text(
                      keywords[2],
                      textAlign: TextAlign.left,
                      style: CustomTypography.headingStyle24Purple,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                )
              : Text(
            'N/A',
                  textAlign: TextAlign.left,
                  style: CustomTypography.headingStyle24,
                ),
        ],
      ),
    );
  }
}
