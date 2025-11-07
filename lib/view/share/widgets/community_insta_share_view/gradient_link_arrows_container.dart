import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/asset_images.dart';

class GradientLinkArrowsContainer extends StatelessWidget {
  const GradientLinkArrowsContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0.w),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          stops: [0.5, 1.0],
          colors: [
            Color(0xFF7A24FF),
            Color(0xFFFF67C6),
          ],
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /* -------------------------- paste your link image ------------------------- */
            Image.asset(
              'Assets/images/paste_your_link.png',
              width: 1.0.sw * 0.4,
            ),
            SizedBox(height: 16.0.w),
            /* ---------------------------------- arrow --------------------------------- */
            SvgIcons.arrows,
          ],
        ),
      ),
    );
  }
}
