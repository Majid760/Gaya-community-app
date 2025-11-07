import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/const.dart';
import 'package:shimmer/shimmer.dart';

class ShowTitleCommunityShimmer extends StatelessWidget {
  const ShowTitleCommunityShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: distance_20),
      height: 18,
      width: 40,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFD4D5D9), kBaseGrey], stops: [0, 1]),
        borderRadius: BorderRadius.circular(borderRadius_8),
        color: kBaseGrey,
      ),
    );
  }
}

class ShowCommunityShimmer extends StatelessWidget {
  final bool isGridView;
  const ShowCommunityShimmer({Key? key, this.isGridView = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
        children: List.generate(2, (index) {
      return Container(
        margin: const EdgeInsets.only(left: distance_20).r,
        width:isGridView?null : 154.w,
        height: isGridView?null : 112.h,
        decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFD4D5D9), kBaseGrey], stops: [0, 1]),
            borderRadius: BorderRadius.circular(borderRadius_8).r,
            color: kBaseGrey),
      );
    }));
  }
}
class ShowHomeCommunityShimmer extends StatelessWidget {
  const ShowHomeCommunityShimmer({super.key});



  @override
  Widget build(BuildContext context) {
    return Row(
        children: List.generate(4, (index) {
      return Container(
        margin: const EdgeInsets.only(right: distance_8, bottom: 8).r,
        width: 56,
        height: 56,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: kBaseGrey),
      );
    }));
  }
}

class CircleCommunitySkeleton extends StatelessWidget {
  const CircleCommunitySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: distance_8, bottom: 8).r,
      width: 56,
      height: 56,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFECF0F3)),
    );
  }
}

class ShowCommunityNameShimmer extends StatelessWidget {
  const ShowCommunityNameShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        margin: const EdgeInsets.only(left: distance_20),
        height: 18,
        width: 40,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFD4D5D9), kBaseGrey], stops: [0, 1]),
          borderRadius: BorderRadius.circular(borderRadius_8),
          color: kBaseGrey,
        ),
      ),
      Container(
        margin: const EdgeInsets.only(left: distance_20),
        height: 18,
        width: 30,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFD4D5D9), kBaseGrey], stops: [0, 1]),
          borderRadius: BorderRadius.circular(borderRadius_8),
          color: kBaseGrey,
        ),
      )
    ]

        //   List.generate(2, (index) {
        //   return Shimmer.fromColors(
        //     baseColor: Colors.grey[300]!, //Color(0xFFECF0F3),
        //     highlightColor: Colors.grey[400]!,
        //     child: Container(
        //       margin: const EdgeInsets.only(left: distance_20),
        //       height: 112,
        //       width: 154,
        //       decoration: BoxDecoration(
        //         gradient: const LinearGradient(colors: [Color(0xFFD4D5D9), kBaseGrey], stops: [0, 1]),
        //         borderRadius: BorderRadius.circular(borderRadius_8),
        //         color: kBaseGrey,
        //       ),
        //     ),
        //   );
        // })

        );
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Shimmer.fromColors(
        baseColor: Colors.grey[300]!, //Color(0xFFECF0F3),
        highlightColor: Colors.grey[400]!,
        period: const Duration(milliseconds: 800),
        child: Container(
          margin: const EdgeInsets.only(left: distance_20),
          height: 18,
          width: 40,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFD4D5D9), kBaseGrey], stops: [0, 1]),
            borderRadius: BorderRadius.circular(borderRadius_8),
            color: kBaseGrey,
          ),
        ),
      ),
      Shimmer.fromColors(
        baseColor: Colors.grey[300]!, //Color(0xFFECF0F3),
        highlightColor: Colors.grey[400]!,
        period: const Duration(milliseconds: 800),
        child: Container(
          margin: const EdgeInsets.only(left: distance_20),
          height: 18,
          width: 30,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFD4D5D9), kBaseGrey], stops: [0, 1]),
            borderRadius: BorderRadius.circular(borderRadius_8),
            color: kBaseGrey,
          ),
        ),
      )
    ]

        //   List.generate(2, (index) {
        //   return Shimmer.fromColors(
        //     baseColor: Colors.grey[300]!, //Color(0xFFECF0F3),
        //     highlightColor: Colors.grey[400]!,
        //     child: Container(
        //       margin: const EdgeInsets.only(left: distance_20),
        //       height: 112,
        //       width: 154,
        //       decoration: BoxDecoration(
        //         gradient: const LinearGradient(colors: [Color(0xFFD4D5D9), kBaseGrey], stops: [0, 1]),
        //         borderRadius: BorderRadius.circular(borderRadius_8),
        //         color: kBaseGrey,
        //       ),
        //     ),
        //   );
        // })

        );
  }
}
