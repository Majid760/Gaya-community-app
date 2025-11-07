// import 'package:easy_refresh/easy_refresh.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:gaya/model/user.model.dart';
// import 'package:gaya/utils/const.dart';
// import 'package:gaya/utils/language/translation.dart';
// import 'package:gaya/utils/refresh_builder_utils.dart';
// import 'package:gaya/view/community/components/approve_user_item_widget.dart';
// import 'package:gaya/view/community/components/moderators_skeleton_widget.dart';
// import 'package:gaya/view/community/controllers/pending_posts_and_friends_controller.dart';
// import 'package:get/get.dart';
//
// class PaginatedCommunityPendingMembers extends StatelessWidget {
//   final String communityId;
//
//   const PaginatedCommunityPendingMembers({
//     Key? key,
//     required this.communityId,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final skeletonList = ListView(physics: const NeverScrollableScrollPhysics(), children: const [PendingUsersSkeletonWidget()]);
//     final emptyList = SizedBox(
//         height: MediaQuery.sizeOf(context).height - kToolbarHeight, child: Center(child: Text(GayaStrings.no_pending_request_found.tr)));
//     return Container(
//       padding: const EdgeInsets.only(bottom: 30, left: 20, right: 20).r,
//       height: MediaQuery.sizeOf(context).height - kToolbarHeight,
//       child: GetBuilder<CommunityPendingPostsAndUsersController>(
//           init: CommunityPendingPostsAndUsersController.to(tag: communityId),
//           builder: (controller) {
//             return EasyRefresh.builder(
//               // refreshOnStart: true,
//              simultaneously: true,
              //               noMoreLoad: false,
//               controller: controller.refreshController,
//               header: RefreshBuilderUtils.headerAbove,
//               footer: ClassicFooter(
//                   processedText: "",
//                   succeededIcon: const Icon(Icons.check, color: kTransparentColor),
//                   showMessage: false,
//                   triggerWhenReach: true,
//                   noMoreText: GayaStrings.no_more_members.tr),
//               onRefresh: () async => controller.resetController(),
//               onLoad: controller.isMembersEmpty ? null : () async => await controller.requestMoreData(),
//               childBuilder: (context, physics) {
//                 if (controller.isLoading) {
//                   return skeletonList;
//                 }
//                 if (controller.isMembersEmpty) {
//                   return emptyList;
//                 }
//                 return ListView.builder(
//                   physics: physics,
//                   itemCount: 50,
//                   itemBuilder: (context, index) {
//                     UserModel singleUser = controller.getMembers()[0];
//                     return ApproveUserItemWidget(
//                         communityId: communityId, userModel: singleUser, communityPendingPostsAndUsersController: controller);
//                   },
//                 );
//               },
//             );
//           }),
//     );
//   }
// }
