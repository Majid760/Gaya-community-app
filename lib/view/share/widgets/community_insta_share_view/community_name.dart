import 'package:flutter/material.dart';

import '../../../../utils/theme/app_typography.dart';

class CommunityName extends StatelessWidget {
  const CommunityName({
    super.key,
    required this.communityName,
  });

  final String? communityName;

  @override
  Widget build(BuildContext context) {
    return Text(
      communityName ?? '',
      maxLines: 1,
      textDirection: TextDirection.ltr,
      style: CustomTypography.title24W600.copyWith(overflow: TextOverflow.ellipsis),
    );
  }
}
