// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:gaya/components/button.component.dart';
// import 'package:gaya/components/profile_image_widget.dart';
// import 'package:gaya/controller/group.controller.dart';
// import 'package:gaya/gen/assets.gen.dart';
// import 'package:gaya/model/user.model.dart';
// import 'package:gaya/routing/getx_route_methods.dart';
// import 'package:gaya/utils/const.dart';
// import 'package:gaya/utils/language/translation.dart';
// import 'package:gaya/utils/theme/app_colors.dart';
// import 'package:gaya/utils/theme/app_spaces.dart';
// import 'package:gaya/utils/theme/app_typography.dart';
// import 'package:gaya/view/community/controllers/pending_posts_and_friends_controller.dart';
// import 'package:get/get.dart';
// import 'package:provider/provider.dart';
//
// class ApproveUserItemWidget extends StatefulWidget {
//   final String communityId;
//   final UserModel userModel;
//   CommunityPendingPostsAndUsersController communityPendingPostsAndUsersController;
//
//   ApproveUserItemWidget(
//       {Key? key, required this.communityId, required this.userModel, required this.communityPendingPostsAndUsersController})
//       : super(key: key);
//
//   @override
//   State<ApproveUserItemWidget> createState() => _ApproveUserItemWidgetState();
// }
//
// class _ApproveUserItemWidgetState extends State<ApproveUserItemWidget> with AutomaticKeepAliveClientMixin {
//   @override
//   Widget build(BuildContext context) {
//     final defaultWidth = MediaQuery.sizeOf(context).width * 0.3;
//     super.build(context);
//     return Column(
//       children: [
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             InkWell(
//               onTap: () => Routes.viewProfile(uid: widget.userModel.uId, model: widget.userModel),
//               child: widget.userModel.profilePicture == ''
//                   ? CircleAvatar(
//                       backgroundColor: kBaseGrey,
//                       child: Image.asset(Assets.assets.images.userDefault, cacheHeight: 48),
//                     )
//                   : CircleAvatar(radius: 24.r, backgroundColor: kBaseGrey, child: ProfileImageWidget(url: widget.userModel.profilePicture)),
//             ),
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.only(left: MySpaces.gap3).r,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(widget.userModel.name ?? "", style: GayaTypography.subtitleMedium),
//                             Text(widget.userModel.dobAndGender(),
//                                 style: GayaTypography.subtitleRegular.copyWith(color: AppColors.secondary)),
//                           ],
//                         ),
//                         const Spacer(),
//                         Text(
//                           widget.communityPendingPostsAndUsersController.getUserJoiningRequestJiffyTime(widget.userModel),
//                           style: GayaTypography.caption.copyWith(color: AppColors.secondary, fontSize: 12.64.sp),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: MySpaces.gap2.h),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         button(
//                             onPressed: () async {
//                               await widget.communityPendingPostsAndUsersController.acceptJoiningRequest(
//                                   widget.userModel,
//                                   Provider.of<GroupController>(
//                                     context,
//                                     listen: false,
//                                   ));
//                             },
//                             width: defaultWidth,
//                             height: 30.h,
//                             textStyle: GayaTypography.subtitleMedium.copyWith(color: AppColors.white),
//                             title: GayaStrings.approve_txt.tr,
//                             primaryColor: kprimaryColor,
//                             borderColor: kTransparentColor),
//                         SizedBox(width: MySpaces.gap3.w),
//                         button(
//                             onPressed: () async {
//                               await widget.communityPendingPostsAndUsersController.rejectJoiningRequest(
//                                   widget.userModel,
//                                   Provider.of<GroupController>(
//                                     context,
//                                     listen: false,
//                                   ));
//                             },
//                             width: defaultWidth,
//                             height: 30.h,
//                             title: GayaStrings.decline_txt.tr,
//                             primaryColor: kBaseGrey,
//                             textStyle: GayaTypography.subtitleMedium,
//                             borderColor: kTransparentColor)
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: MySpaces.gap2.h),
//         const Divider(
//           color: kBaseGrey,
//           thickness: 1,
//         ),
//       ],
//     );
//   }
//
//   @override
//   bool get wantKeepAlive => true;
// }
