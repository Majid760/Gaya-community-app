import 'package:flutter/material.dart';
import 'package:gaya/components/skeleton.post.component.dart';
import 'package:gaya/utils/const.dart';

class ModeratorsSkeletonWidget extends StatelessWidget {
  const ModeratorsSkeletonWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.5),
      child: ListView(
        padding: const EdgeInsets.only(right: 16),
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          UsersSkeleton(),
          SizedBox(
            height: distance_18,
          ),
          UsersSkeleton(),
          SizedBox(
            height: distance_18,
          ),
          UsersSkeleton(),
          SizedBox(
            height: distance_18,
          ),
          UsersSkeleton(),
          SizedBox(
            height: distance_18,
          ),
          UsersSkeleton(),
          SizedBox(
            height: distance_18,
          ),
          UsersSkeleton(),
          SizedBox(
            height: distance_18,
          ),
          UsersSkeleton(),
        ],
      ),
    );
  }
}

class PendingUsersSkeletonWidget extends StatelessWidget {
  const PendingUsersSkeletonWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height - kToolbarHeight),
      child: ListView(
        // padding: const EdgeInsets.only(right: 16),
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          PendingUsersSkeleton(),
          PendingUsersSkeleton(),
          PendingUsersSkeleton(),
          PendingUsersSkeleton(),
          PendingUsersSkeleton(),
          PendingUsersSkeleton(),
          PendingUsersSkeleton(),
          PendingUsersSkeleton(),
          PendingUsersSkeleton(),
          PendingUsersSkeleton(),
          PendingUsersSkeleton(),
          PendingUsersSkeleton(),
          PendingUsersSkeleton(),
          PendingUsersSkeleton(),
        ],
      ),
    );
  }
}
