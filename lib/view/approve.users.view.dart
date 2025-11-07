// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:gaya/utils/language/translation.dart';
// import 'package:get/get.dart';
//
// import '../shared/view/widget/gaya_back_button.dart';
// import '../utils/const.dart';
// import '../utils/textstyles.dart';
// import 'community/components/paginated_community_pending_members.dart';
// import 'community/controllers/pending_posts_and_friends_controller.dart';
//
// class ApproveUsersView extends StatefulWidget {
//   final String communityid;
//   final String communityName;
//
//   const ApproveUsersView({Key? key, required this.communityid, required this.communityName}) : super(key: key);
//
//   @override
//   State<ApproveUsersView> createState() => _ApproveUsersViewState();
// }
//
// class _ApproveUsersViewState extends State<ApproveUsersView> {
//   late CommunityPendingPostsAndUsersController communityPendingPostsAndUsersController;
//
//   @override
//   void initState() {
//     communityPendingPostsAndUsersController = CommunityPendingPostsAndUsersController.to(tag: widget.communityid);
//     communityPendingPostsAndUsersController.initializeCommunityMembersServices();
//     // communityPendingPostsAndUsersController.getCommunityMembersProfile();
//     communityPendingPostsAndUsersController.requestMoreData(fromInit: true);
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     communityPendingPostsAndUsersController.resetController(isDisposing: true);
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         automaticallyImplyLeading: false,
//         leading: const GayaBackButton(),
//         backgroundColor: kTransparentColor,
//         iconTheme: const IconThemeData(color: kBlackColor),
//         centerTitle: true,
//         title: Text(GayaStrings.waiting_confirmation.tr, style: CustomTypography.bodyStyle),
//         shape: Border(bottom: BorderSide(color: kBaseGrey.withOpacity(0.5))),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 20.r),
//             PaginatedCommunityPendingMembers(communityId: widget.communityid),
//             SizedBox(height: 20.r),
//           ],
//         ),
//       ),
//     );
//   }
// }
