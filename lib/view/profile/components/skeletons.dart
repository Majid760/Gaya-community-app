import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/const.dart';
import 'package:shimmer/shimmer.dart';

class CountSkeletonWidget extends StatelessWidget {
  const CountSkeletonWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 15.r,
            width: 20.r,
            decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(borderRadius_4)),
          ),
          const SizedBox(height: distance_5),
          Container(
            height: 17.r,
            width: 40.r,
            decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(borderRadius_4)),
          ),
        ],
      ),
    );
    return SizedBox(
      // height: 100,
      width: 100,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!, //Color(0xFFECF0F3),
        highlightColor: Colors.grey[400]!,
        period: const Duration(milliseconds: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(borderRadius_4)),
            ),
            const SizedBox(height: distance_5),
            Container(
              height: 18,
              width: 40,
              decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(borderRadius_4)),
            ),
          ],
        ),
      ),
    );
  }
}

