import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/asset_images.dart';

class NavBarIcon extends StatelessWidget {
  final String path;
  final Color? color;

  const NavBarIcon({Key? key, required this.path, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 5).r,
      child: GayaSvgAsset(
        path,
        height: 24.r,
        color: color,
      ),
    );
  }
}
