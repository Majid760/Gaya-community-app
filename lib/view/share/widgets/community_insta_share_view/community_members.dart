import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/language/translation.dart';
import '../../../../utils/theme/app_typography.dart';

class CommunityMembers extends StatelessWidget {
  const CommunityMembers({
    super.key,
    required this.communityMembers,
  });

  final int? communityMembers;

  @override
  Widget build(BuildContext context) {
    return Text(
      (communityMembers ?? 0) > 1
          ? " ${communityMembers ?? 0} ${GayaStrings.members_txt.tr}"
          : "${communityMembers ?? 0} ${GayaStrings.members_txt.tr}",
      style: CustomTypography.community.copyWith(height: 2),
    );
  }
}
