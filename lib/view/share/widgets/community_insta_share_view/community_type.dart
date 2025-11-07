import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/language/translation.dart';
import '../../../../utils/theme/app_typography.dart';

class CommunityType extends StatelessWidget {
  const CommunityType({super.key, required this.communityType});
  final String? communityType;

  @override
  Widget build(BuildContext context) {
    return Text(
      communityType!.isBlank == true
          ? "${GayaStrings.public_txt} ${GayaStrings.community}".tr
          : "${communityType?.toLowerCase().toString() ?? GayaStrings.public_txt} ${GayaStrings.community}".tr,
      style: CustomTypography.community.copyWith(height: 2),
    );
  }
}
