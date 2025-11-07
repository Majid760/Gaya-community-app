import 'package:flutter/material.dart';
import 'package:gaya/utils/extension.dart';

import '../../../utils/theme/app_typography.dart';

class AppBadge extends StatelessWidget {
  final int count;
  final Widget child;

  const AppBadge({Key? key, required this.count, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: count > 0,
      padding: const EdgeInsets.only(left: 4, right: 4),
      label: Text(count.toCount99Plus, style: CustomTypography.badgeTextStyle),
      child: child,
    );
  }
}
