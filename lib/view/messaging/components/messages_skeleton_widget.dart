import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/skeleton.post.component.dart';
import 'package:gaya/utils/const.dart';

class MessageSuggestionsSkeleton extends StatelessWidget {
  const MessageSuggestionsSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: <Widget>[
          Container(
            width: 62.r,
            height: 62.r,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: kBaseGrey),
          ),
          SizedBox(height: 8.h),
          Container(width: 30.w, height: 10.h, color: kBaseGrey),
        ],
      ),
    );
  }
}

class MessagesSkeletonWidget extends StatelessWidget {
  double horizontolPadding;
  MessagesSkeletonWidget({Key? key, this.horizontolPadding = 24}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.9),
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontolPadding),
            child: const MessageSkeleton(),
          ),
          Divider(
            thickness: 1,
            color: kSecondaryLightColor.withOpacity(1),
          ),
          const SizedBox(
            height: distance_8,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontolPadding),
            child: const MessageSkeleton(),
          ),
          Divider(
            thickness: 1,
            color: kSecondaryLightColor.withOpacity(1),
          ),
          const SizedBox(
            height: distance_8,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontolPadding),
            child: const MessageSkeleton(),
          ),
          Divider(
            thickness: 1,
            color: kSecondaryLightColor.withOpacity(1),
          ),
          const SizedBox(
            height: distance_8,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontolPadding),
            child: const MessageSkeleton(),
          ),
          Divider(
            thickness: 1,
            color: kSecondaryLightColor.withOpacity(1),
          ),
          const SizedBox(
            height: distance_8,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontolPadding),
            child: const MessageSkeleton(),
          ),
          Divider(
            thickness: 1,
            color: kSecondaryLightColor.withOpacity(1),
          ),
          const SizedBox(
            height: distance_8,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontolPadding),
            child: const MessageSkeleton(),
          ),
          Divider(
            thickness: 1,
            color: kSecondaryLightColor.withOpacity(1),
          ),
          const SizedBox(
            height: distance_8,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontolPadding),
            child: const MessageSkeleton(),
          ),
          Divider(
            thickness: 1,
            color: kSecondaryLightColor.withOpacity(1),
          ),
          const SizedBox(
            height: distance_8,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontolPadding),
            child: const MessageSkeleton(),
          ),
          Divider(
            thickness: 1,
            color: kSecondaryLightColor.withOpacity(1),
          ),
        ],
      ),
    );
  }
}
