import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/const.dart';

class NavBarItem extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool isExpanded;

  const NavBarItem({Key? key, required this.child, required this.onTap, this.isExpanded = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: IconButton(
        splashRadius: 45.r,
        visualDensity: const VisualDensity(horizontal: -4),
        padding: EdgeInsets.zero,
        highlightColor: kSecondaryLightColor,
        onPressed: onTap,
        icon: child,
      ),
    );
  }
}
