import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../utils/assets_icons.dart';
import '../../../utils/language/translation.dart';
import 'figure_match_widget.dart';

class MatchedDataRow extends StatelessWidget {
  const MatchedDataRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width.w,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60).r,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FiguresMatchWidget(count: "10", icon: SvgIconWidget.communityOutline(), title: GayaStrings.communities_txt.tr),
            FiguresMatchWidget(count: "10", icon: SvgIconWidget.interestOutline(), title: GayaStrings.interests_txt.tr),
            FiguresMatchWidget(count: "10", icon: SvgIconWidget.friendOutline(), title: GayaStrings.friends_txt.tr),
          ],
        ),
      ),
    );
  }
}

