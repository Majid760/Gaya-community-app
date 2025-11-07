// import 'package:badges/badges.dart';
// import 'package:badges/badges.dart' as badge;
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:gaya/components/shader.coloring.dart';
// import 'package:gaya/view/communities.view.dart';
// import 'package:gaya/view/home.view.dart';
// import 'package:gaya/view/messaging/message.view.dart';
// import 'package:gaya/view/notification.view.dart';
// import 'package:gaya/view/profile.view.dart';
// import 'package:get/get.dart';
// import 'package:provider/provider.dart';
//
// import '../controller/communities.controller.dart';
// import '../controller/profile.controller.dart';
// import '../gen/assets.gen.dart';
// import '../utils/app_data.dart';
// import '../utils/const.dart';
// import '../utils/textstyles.dart';
//
// import '../view/require.sigin.register.dart';
//
//
// class BottomNavigationWidget extends StatefulWidget {
//   final int selectedIndex;
//
//   BottomNavigationWidget({required this.selectedIndex});
//
//   @override
//   State<BottomNavigationWidget> createState() => _BottomNavigationWidgetState();
// }
//
// class _BottomNavigationWidgetState extends State<BottomNavigationWidget> {
//   int _selectedIndex = 0;
//   late ProfileController controller;
//   late Stream _stream;
//
//   @override
//   initState() {
//     super.initState();
//     controller = Provider.of<ProfileController>(context, listen: false);
//     _stream = controller.newMessages();
//     // _selectedIndex = widget.selectedIndex;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     User? user = FirebaseAuth.instance.currentUser;
//     final controller = Provider.of<ProfileController>(context, listen: false);
//
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: distance_20),
//       alignment: Alignment.center,
//       height: distance_50,
//       decoration: BoxDecoration(
//           border: Border.all(
//         color: kBaseGrey.withOpacity(0.25),
//       )),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           InkWell(
//             onTap: () {
//               Get.off(() => HomeView(), transition: Transition.fadeIn);
//             },
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 RadiantGradientMask(
//                   colors1: widget.selectedIndex == 0 ? Color(0xFFFFB5F3) : kWhiteColor,
//                   colors2: widget.selectedIndex == 0 ? Color(0xFFAC2EFA) : kWhiteColor,
//                   child: Image.asset(
//                     Assets.assets.icons.home,
//                     color: widget.selectedIndex == 0 ? kWhiteColor : kSecondaryColor,
//                     height: 20,
//                   ),
//                 ),
//                 SizedBox(
//                   height: MediaQuery.of(context).orientation == Orientation.portrait ? 10 : 0,
//                 ),
//                 Text(
//                   "Home",
//                   style: widget.selectedIndex == 0 ? bottomBarSelectedTextStyle : bottomBarUnSelectedTextStyle,
//                 ),
//               ],
//             ),
//           ),
//           InkWell(
//               onTap: () {
//                 user == null
//                     ? Navigator.of(context).push(MaterialPageRoute(
//                         builder: (context) => RequireSignRegisterView(
//                               userNotSigin: true,
//                             )))
//                     : Get.off(() => MessageView(), transition: Transition.fadeIn);
//               },
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   FirebaseAuth.instance.currentUser == null
//                       ? SvgPicture.asset(
//                           Assets.assets.icons.messages,
//                           color: widget.selectedIndex == 1 ? kprimaryColor : kSecondaryColor,
//                           height: 20,
//                         )
//                       : StreamBuilder(
//                           stream: controller.newMessages(),
//                           builder: (context, snapshot) {
//                             return Consumer<ProfileController>(
//                               builder: (context, provider, child) {
//                                 return badge.Badge(
//                                   showBadge: provider.unreadMessagesAvailable,
//                                   child: SvgPicture.asset(
//                                     Assets.assets.icons.messages,
//                                     color: widget.selectedIndex == 1 ? kprimaryColor : kSecondaryColor,
//                                     height: 20,
//                                   ),
//                                 );
//                               },
//                             );
//                           }),
//                   SizedBox(
//                     height: MediaQuery.of(context).orientation == Orientation.portrait ? 10 : 0,
//                   ),
//                   Text(
//                     "Messages",
//                     style: widget.selectedIndex == 1 ? bottomBarSelectedTextStyle : bottomBarUnSelectedTextStyle,
//                   ),
//                 ],
//               )),
//           InkWell(
//             onTap: () {
//               Get.off(() => CommunityView(), transition: Transition.fadeIn);
//
//               if (user != null) {
//                 context.read<CommunitiesController>().checkForCommunityBatch();
//               }
//               ;
//             },
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.center,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 context.read<CommunitiesController>().notiifcationList.contains(1) == true
//                     ? Badge(
//                         child: SvgPicture.asset(
//                           Assets.assets.icons.groups,
//                           color: widget.selectedIndex == 2 ? kprimaryColor : kSecondaryColor,
//                           height: 20,
//                         ),
//                       )
//                     : SvgPicture.asset(
//                         Assets.assets.icons.groups,
//                         color: widget.selectedIndex == 2 ? kprimaryColor : kSecondaryColor,
//                         height: 20,
//                       ),
//                 SizedBox(
//                   height: MediaQuery.of(context).orientation == Orientation.portrait ? 10 : 0,
//                 ),
//                 Text(
//                   "Communities",
//                   style: widget.selectedIndex == 2 ? bottomBarSelectedTextStyle : bottomBarUnSelectedTextStyle,
//                 ),
//               ],
//             ),
//           ),
//           InkWell(
//               onTap: () {
//                 user == null
//                     ? Navigator.of(context).push(MaterialPageRoute(
//                         builder: (context) => RequireSignRegisterView(
//                               userNotSigin: true,
//                             )))
//                     : Get.off(() => NotificationView(), transition: Transition.fadeIn);
//               },
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   FirebaseAuth.instance.currentUser == null
//                       ? SvgPicture.asset(
//                           Assets.assets.icons.notification,
//                           color: widget.selectedIndex == 3 ? kprimaryColor : kSecondaryColor,
//                           height: 20,
//                         )
//                       : StreamBuilder(
//                           stream: controller.newNotifications(),
//                           builder: (context, snapshot) {
//                             return Consumer<ProfileController>(
//                               builder: (context, provider, child) {
//                                 return badge.Badge(
//                                   showBadge: provider.unReadNotificationsAvailable,
//                                   child: SvgPicture.asset(
//                                     Assets.assets.icons.notification,
//                                     color: widget.selectedIndex == 3 ? kprimaryColor : kSecondaryColor,
//                                     height: 20,
//                                   ),
//                                 );
//                               },
//                             );
//                           }),
//                   SizedBox(
//                     height: MediaQuery.of(context).orientation == Orientation.portrait ? 10 : 0,
//                   ),
//                   Text(
//                     "Notification",
//                     style: widget.selectedIndex == 3 ? bottomBarSelectedTextStyle : bottomBarUnSelectedTextStyle,
//                   ),
//                 ],
//               )),
//           InkWell(
//             onTap: () {
//               user == null
//                   ? Navigator.of(context).push(MaterialPageRoute(
//                       builder: (context) => RequireSignRegisterView(
//                             userNotSigin: true,
//                           )))
//                   : Get.off(() => ProfileView(), transition: Transition.fadeIn);
//             },
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 user != null
//                     ? Container(
//                         alignment: Alignment.center,
//                         height: 25,
//                         width: 25,
//                         decoration: BoxDecoration(
//                           color: widget.selectedIndex == 4 ? kprimaryColor : const Color.fromRGBO(255, 255, 255, 0.0),
//                           shape: BoxShape.circle,
//                           border: Border.all(color: kSecondaryColor),
//                         ),
//                         child: FutureProvider<DocumentSnapshot?>(
//                           initialData: null,
//                           create: (context) => controller.getuseProfileDetails(),
//                           child: Consumer<DocumentSnapshot?>(builder: (context, value, _) {
//                             return value == null
//                                 ? CircleAvatar(
//                                     backgroundColor: kBaseGrey,
//                                     radius: 15,
//                                   )
//                                 : Builder(builder: (context) {
//                                     var data = value.data() as Map<String, dynamic>;
//                                     return data['profilePic'] == ''
//
//                                         ? CircleAvatar(backgroundColor: kBaseGrey, radius: 15, backgroundImage: AssetImage('Assets/images/user.png'))
//                                         : CircleAvatar(
//                                             backgroundColor: kBaseGrey,
//                                             radius: 15,
//                                             // backgroundImage:
//                                             //     CachedNetworkImageProvider(
//                                             //         data['profilePic'])
//                                             child: CachedNetworkImage(
//                                               imageUrl: data['profilePic'],
//                                               imageBuilder: (context, imageProvider) {
//                                                 return Container(
//                                                   decoration: BoxDecoration(
//                                                     shape: BoxShape.circle,
//                                                     image: DecorationImage(
//                                                       image: imageProvider,
//                                                       fit: BoxFit.cover,
//                                                     ),
//                                                   ),
//                                                 );
//                                               },
//                                               fit: BoxFit.cover,
//
//                                               errorWidget: (context, url, error) => AppData.defaultErrorWidget,
//                                               placeholder: (context, url) => Image.asset(Assets.assets.images.userDefault),
//                                             ));
//                                   });
//                           }),
//                         ))
//                     : SvgPicture.asset(
//                         Assets.assets.icons.profile,
//                         height: 27,
//                         color: widget.selectedIndex == 4 ? kprimaryColor : kSecondaryColor,
//                       ),
//                 SizedBox(
//                   height: MediaQuery.of(context).orientation == Orientation.portrait ? 10 : 0,
//                 ),
//                 Text(
//                   "Profile",
//                   style: widget.selectedIndex == 4 ? bottomBarSelectedTextStyle : bottomBarUnSelectedTextStyle,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }