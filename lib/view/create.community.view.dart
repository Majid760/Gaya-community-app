// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:gaya/components/snackbar.component.dart';
// import 'package:gaya/controller/app_config_controller.dart';
// import 'package:gaya/controller/communities.controller.dart';
// import 'package:gaya/gen/assets.gen.dart';
// import 'package:gaya/model/community.model.dart';
// import 'package:gaya/routing/getx_route_methods.dart';
// import 'package:gaya/utils/enum.dart';
// import 'package:gaya/utils/helpers.functions.dart';
// import 'package:gaya/widgets/create.community.widgets/commnity.view1.widget.dart';
// import 'package:gaya/widgets/create.community.widgets/community.view3.widget.dart';
// import 'package:gaya/widgets/create.community.widgets/community.view4.widget.dart';
// import 'package:provider/provider.dart';
// import '../components/button.component.dart';
// import '../components/progress.indicator.component.dart';
// import '../controller/topics.controller.dart';
// import "../routing/routes.dart" as route;
// import '../utils/app_data.dart';
// import '../utils/const.dart';
// import '../utils/textstyles.dart';
// import '../widgets/create.community.widgets/community.view2.widget.dart';

// class CreateCommunityView extends StatelessWidget {
//   CreateCommunityView({Key? key}) : super(key: key);

//   bool isLoading = false;

//   @override
//   Widget build(BuildContext context) {
//     final communityController = Provider.of<CommunitiesController>(context, listen: true);
//     final topicController = Provider.of<TopicsController>(context, listen: true);

//     return Scaffold(
//       appBar: getAppbar(context, communityController),
//       body: getBody(context, communityController, topicController),
//     );
//   }

//   PreferredSizeWidget getAppbar(BuildContext context, CommunitiesController communityController) {
//     return AppBar(
//       systemOverlayStyle: SystemUiOverlayStyle.dark,
//       shape: Border(bottom: BorderSide(color: kBaseGrey.withOpacity(0.5))),
//       automaticallyImplyLeading: true,
//       iconTheme: const IconThemeData(color: kBlackColor),
//       actions: [
//         communityController.getCommunityViewPage == CreateCommunityViewEnum.CommunityView4
//             ? communityController.skip == true
//                 ? const Center(child: CircularProgressIndicator.adaptive())
//                 : StatefulBuilder(builder: (context, setState) {
//                     return isLoading
//                         ? AppData.loadingAsyncWidget
//                         : TextButton(
//                             onPressed: () async {
//                               setState(() => isLoading = true);
//                               try {
//                                 final imageUpload = Provider.of<HelpersFunctions>(context, listen: false);
//                                 await communityController.createACommunity(context, imageUpload, communityController.skip);
//                                 Routes.succesfullyJoinedCommunity();
//                                 communityController.communityViewPage = CreateCommunityViewEnum.CommunityView1;
//                               } catch (_) {
//                                 debugPrint(_.toString());
//                               } finally {
//                                 setState(() => isLoading = false);
//                               }
//                             },
//                             child: const Text("Skip", style: TextStyle(color: kprimaryColor)),
//                           );
//                   })
//             : const SizedBox.shrink()
//       ],
//       title: const Text('Create a community', style: CustomTypography.bodyStyle),
//       centerTitle: true,
//       backgroundColor: kTransparentColor,
//       elevation: 0,
//     );
//   }

//   Widget getBody(BuildContext context, CommunitiesController communityController, TopicsController topicController) {
//     final helperFunctionController = Provider.of<HelpersFunctions>(context);
//     final communityController = Provider.of<CommunitiesController>(context, listen: true);

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: distance_20),
//       child: SingleChildScrollView(
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           const SizedBox(
//             height: distance_20,
//           ),
//           Row(
//             children: [
//               progressIndicator(
//                   ontap: () {},
//                   // ontap: () => communityController.setCommunityViewPage(
//                   //     CreateCommunityViewEnum.CommunityView1),
//                   color: communityController.getCommunityViewPage == CreateCommunityViewEnum.CommunityView1 ||
//                           communityController.getCommunityViewPage == CreateCommunityViewEnum.CommunityView2 ||
//                           communityController.getCommunityViewPage == CreateCommunityViewEnum.CommunityView3 ||
//                           communityController.getCommunityViewPage == CreateCommunityViewEnum.CommunityView4
//                       ? kprimaryColor
//                       : borderColor),
//               const SizedBox(
//                 width: distance_5,
//               ),
//               progressIndicator(
//                   ontap: () {},
//                   // ontap: () => communityController.setCommunityViewPage(
//                   //     CreateCommunityViewEnum.CommunityView2),
//                   color: communityController.getCommunityViewPage == CreateCommunityViewEnum.CommunityView2 ||
//                           communityController.getCommunityViewPage == CreateCommunityViewEnum.CommunityView3 ||
//                           communityController.getCommunityViewPage == CreateCommunityViewEnum.CommunityView4
//                       ? kprimaryColor
//                       : borderColor),
//               const SizedBox(
//                 width: distance_5,
//               ),
//               progressIndicator(
//                   ontap: () {},
//                   // ontap: () => communityController.setCommunityViewPage(
//                   //     CreateCommunityViewEnum.CommunityView3),
//                   color: communityController.getCommunityViewPage == CreateCommunityViewEnum.CommunityView3 ||
//                           communityController.getCommunityViewPage == CreateCommunityViewEnum.CommunityView4
//                       ? kprimaryColor
//                       : borderColor),
//               const SizedBox(
//                 width: distance_5,
//               ),
//               progressIndicator(
//                   ontap: () {},
//                   // => communityController.setCommunityViewPage(
//                   //     CreateCommunityViewEnum.CommunityView4),
//                   color: communityController.getCommunityViewPage == CreateCommunityViewEnum.CommunityView4 ? kprimaryColor : borderColor),
//             ],
//           ),
//           const SizedBox(
//             height: distance_20,
//           ),
//           getCreateCommunity(communityController.getCommunityViewPage),
//           const SizedBox(
//             height: distance_10,
//           ),
//           communityController.createPostLoader == false
//               ? communityController.getCommunityViewPage == CreateCommunityViewEnum.CommunityView4
//                   ? communityController.skip == true
//                       ? const SizedBox.shrink()
//                       : SizedBox(
//                           height: 40,
//                           width: double.infinity,
//                           child: ElevatedButton.icon(
//                               style: ElevatedButton.styleFrom(backgroundColor: kBaseGrey, elevation: 0),
//                               onPressed: () async {
//                                 if (isLoading == true) return;
//                                 isLoading = true;
//                                 try {
//                                   final imageUpload = Provider.of<HelpersFunctions>(context, listen: false);
//                                   final CreateCommunityModel? newCommunity = await communityController.createACommunity(
//                                       context, imageUpload, communityController.createPostLoader);

//                                   if (newCommunity != null) {
//                                     AppConfigurationController.to.asAdminCommunities.add(newCommunity);
//                                     Routes.createPost(community: newCommunity, isFromHome: false, replace: true);
//                                   }
//                                 } catch (_) {
//                                 } finally {
//                                   isLoading = false;
//                                 }
//                               },
//                               icon: SvgPicture.asset(Assets.assets.icons.write),
//                               label: const Text(
//                                 "Create post",
//                                 style: CustomTypography.body4Style,
//                               )),
//                         )
//                   : button(
//                       height: 50,
//                       textStyle: CustomTypography.body2Style,
//                       borderColor: kTransparentColor,
//                       title: 'Continue',
//                       onPressed: () async {
//                         if (communityController.getCommunityViewPage == CreateCommunityViewEnum.CommunityView1) {
//                           if (communityController.communityName.value.text.isNotEmpty && topicController.selectedList.isNotEmpty) {
//                             communityController.setCommunityViewPage(CreateCommunityViewEnum.CommunityView2);
//                           } else {
//                             snackBar(context, "Enter community name & add the topic", kprimaryColor);
//                           }
//                         } else if (communityController.getCommunityViewPage == CreateCommunityViewEnum.CommunityView2) {
//                           if (helperFunctionController.communityImage != null && helperFunctionController.communityCoverImage != null) {
//                             communityController.setCommunityViewPage(CreateCommunityViewEnum.CommunityView3);
//                           } else {
//                             snackBar(context, "please select cover and profile picture to continue", kprimaryColor);
//                           }
//                         } else if (communityController.getCommunityViewPage == CreateCommunityViewEnum.CommunityView3) {
//                           if (communityController.description.value.text.isNotEmpty) {
//                             communityController.setCommunityViewPage(CreateCommunityViewEnum.CommunityView4);
//                           } else {
//                             snackBar(context, "Your description is empty", kprimaryColor);
//                           }
//                         }
//                       },
//                       primaryColor: kprimaryColor)
//               : const Center(
//                   child: CircularProgressIndicator.adaptive(
//                   backgroundColor: kprimaryColor,
//                 )),
//         ]),
//       ),
//     );
//   }

//   Widget getCreateCommunity(CreateCommunityViewEnum getView) {
//     switch (getView) {
//       case CreateCommunityViewEnum.CommunityView1:
//         return const CommunityView1();
//       case CreateCommunityViewEnum.CommunityView2:
//         return const CommunityView2();
//       case CreateCommunityViewEnum.CommunityView3:
//         return const CommunityView3();
//       case CreateCommunityViewEnum.CommunityView4:
//         return const CommunityView4();
//     }
//   }
// }
