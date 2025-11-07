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
    /* --------------------------- community name text -------------------------- */
    return Flexible(
      child: Text(
        communityName ?? '',
        maxLines: 1,
        textDirection: TextDirection.ltr,
        style: GayaTypography.title.copyWith(overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
