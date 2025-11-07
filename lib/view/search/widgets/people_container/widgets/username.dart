import 'package:flutter/material.dart';

import '../../../../../utils/theme/app_typography.dart';

class Username extends StatelessWidget {
  const Username({
    super.key,
    required this.username,
  });

  final String username;

  @override
  Widget build(BuildContext context) {
    /* ------------------------------ username text ----------------------------- */
    return Text(
      username,
      maxLines: 1,
      textDirection: TextDirection.ltr,
      style: GayaTypography.title.copyWith(overflow: TextOverflow.ellipsis),
    );
  }
}
