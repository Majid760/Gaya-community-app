import 'package:flutter/material.dart';
import 'package:gaya/components/profile_image_widget.dart';
import 'package:get/get.dart';

import '../../../../../utils/language/translation.dart';
import '../../../../../utils/textstyles.dart';
import '../../../../../utils/theme/app_spaces.dart';
import '../analytics_tile.dart';

class MostActiveUserTile extends StatelessWidget {
  const MostActiveUserTile({
    super.key,
    required this.profileImagePath,
    required this.userName,
  });

  /* -------------------------------------------------------------------------- */
  /*                                 VARIABLES                                 */
  /* -------------------------------------------------------------------------- */
  final String profileImagePath;
  final String userName;

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
          /* ---------------------- most active user text [Text] ---------------------- */
          Text(
            GayaStrings.mostActiveUser.tr,
            textAlign: TextAlign.left,
            style: CustomTypography.dark12,
          ),
          MySpaces.gap3y,
          /* ------------------ profile image and username row [Row] ------------------ */
          Row(
            children: [
              /* --------------- profile image [ClipOval > PostImageWidget] --------------- */
              if (userName.isNotEmpty)
                ClipOval(
                  child: PostImageWidget(
                    url: profileImagePath,
                    width: 32.0,
                    height: 32.0,
                  ),
                ),
              MySpaces.gap1x,
              /* -------------------- user name text [Expanded > Text] -------------------- */
              Expanded(
                child: Text(
                  userName.isNotEmpty ? userName : 'N/A',
                  textAlign: TextAlign.left,
                  style: CustomTypography.dark12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
