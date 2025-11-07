// import 'dart:io';
//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:gaya/controller/communities.controller.dart';
// import 'package:gaya/controller/topics.controller.dart';
// import 'package:gaya/gen/assets.gen.dart';
// import 'package:gaya/view/search.communities.view.dart';
// import 'package:get/get.dart';
// import 'package:provider/provider.dart';
//
// import '../components/textfield.component.dart';
// import '../routing/getx_route_methods.dart';
// import '../utils/const.dart';
// import '../utils/language/translation.dart';
// import '../utils/textstyles.dart';
// import 'Auth/controller/require.sigin.register.dart';
// import 'community/communities/components/guest_communities_list.dart';
// import 'community/communities/components/hot_communities_list.dart';
// import 'community/communities/components/my_communities_list.dart';
// import 'community/communities/components/recommended_communities_list.dart';
// import 'community/communities/components/user_interest_communities_list.dart';
// import 'community/communities/controllers/guest_communities_controller.dart';
// import 'community/communities/controllers/hottopic_communities_controller.dart';
// import 'community/communities/controllers/interest_communities_controller.dart';
// import 'community/communities/controllers/recommended_communities_controller.dart';
//
// class CommunityView extends StatefulWidget {
//   const CommunityView({Key? key}) : super(key: key);
//
//   @override
//   State<CommunityView> createState() => _CommunityViewState();
// }
//
// class _CommunityViewState extends State<CommunityView> {
//   User? user = FirebaseAuth.instance.currentUser;
//
//   late CommunitiesController _communitiesController;
//
//   @override
//   void initState() {
//     _communitiesController = context.read<CommunitiesController>();
//     _communitiesController.communitiesScrollController = ScrollController();
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _communitiesController.communitiesScrollController.dispose();
//     user = null;
//     super.dispose();
//   }
//
//   Future<void> _onRefresh({bool isGuest = false}) async => setState(() {
//         /// Guest Communities Refresh
//         if (isGuest) {
//           GuestCommunitiesController.to.onRefreshPull();
//           return;
//         }
//
//         /// User Communities Refresh
//         InterestCommunitiesController.to.onRefreshPull();
//         RecommendedCommunitiesController.to.onRefreshPull();
//         HotTopicCommunitiesController.to.onRefreshPull();
//       });
//
//   List<Widget> communities = [
//     const MyCommunitiesListView(),
//     //HOT TOPICS
//     const HotCommunities(),
//     const UserInterestCommunities(),
//     const RecommendedCommunities(),
//     SizedBox(height: distance_20.r),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         systemOverlayStyle: SystemUiOverlayStyle.dark,
//         backgroundColor: kTransparentColor,
//         elevation: 0,
//         shape: Border(bottom: BorderSide(color: kBaseGrey.withOpacity(0.5))),
//         title: Text(GayaStrings.communities_txt.tr, style: CustomTypography.bodyStyle),
//         centerTitle: true,
//         automaticallyImplyLeading: false,
//         bottom: PreferredSize(
//           preferredSize: Size(0.0, distance_40.r),
//           child: Padding(
//               padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12).r,
//               child: GayaSearchTextField(
//                 isEnabled: false,
//                 onTap: () {
//                   if (user != null) {
//                     if (Platform.isIOS) {
//                       showCupertinoDialog(context: context, builder: (context) => const SearchCommunities(), barrierDismissible: true);
//                     } else {
//                       Get.to(() => const SearchCommunities(), transition: Transition.cupertinoDialog);
//                     }
//                   } else {
//                     Get.to(() => const RequireSignRegisterView(userNotSigin: true), transition: Transition.cupertinoDialog);
//                   }
//                 },
//               )),
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
//       body: user != null
//           ?
//
//           /// User Communities -- Logged In User
//           RefreshIndicator(
//               color: kprimaryColor,
//               onRefresh: () async => await _onRefresh(),
//               child: ListView.builder(
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 controller: _communitiesController.communitiesScrollController,
//                 padding: EdgeInsets.zero,
//                 itemCount: communities.length,
//                 itemBuilder: (ctx, index) => communities[index],
//               )
//
//               // ListView(
//               //   physics: const AlwaysScrollableScrollPhysics(),
//               //   controller: _communitiesController.communitiesScrollController,
//               //   padding: EdgeInsets.zero,
//               //   children: [
//               //     const MyCommunitiesListView(),
//               //     //HOT TOPICS
//               //     const HotCommunities(),
//               //     const UserInterestCommunities(),
//               //     const RecommendedCommunities(),
//               //     SizedBox(height: distance_20.r),
//               //   ],
//               // ),
//               )
//           :
//
//           /// Guest User Communities -- Non-User
//           RefreshIndicator(
//               color: kprimaryColor,
//               onRefresh: () async => await _onRefresh(isGuest: true),
//               child: ListView(
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 controller: _communitiesController.communitiesScrollController,
//                 padding: EdgeInsets.zero,
//                 children: [
//                   const GuestCommunities(),
//                   SizedBox(height: distance_20.r),
//                 ],
//               ),
//             ),
//       floatingActionButton: user == null
//           ? const SizedBox()
//           : FloatingActionButton(
//               backgroundColor: kTransparentColor,
//               elevation: 0,
//               materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//               onPressed: user != null
//                   ? () {
//                       context.read<TopicsController>().selectedList.clear();
//                       context.read<TopicsController>().usersInterest.clear();
//                       Routes.createCommunityView();
//                     }
//                   : () => Routes.loginView(),
//               child: Container(
//                 height: 48.h,
//                 width: 48.w,
//                 padding: const EdgeInsets.all(12).r,
//                 decoration: BoxDecoration(color: kprimaryColor, borderRadius: BorderRadius.circular(borderRadius_4).r),
//                 child: SvgPicture.asset(Assets.assets.icons.communities, color: Colors.white, height: 24.r, width: 24.r),
//               ),
//             ),
//     );
//   }
// }
