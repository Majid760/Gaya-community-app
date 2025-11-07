// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:gaya/gen/assets.gen.dart';
// import 'package:gaya/widgets/notification_widgets/notification.whole.widget.dart';
// import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

// import '../../utils/const.dart';
// import '../../utils/textstyles.dart';

// class GetNotificationsWidget extends StatelessWidget {
//   const GetNotificationsWidget({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             height: distance_15,
//           ),
//           RequestNotificationWidget(
//             color: greenColor,
//             text: 'Noa Hillzenrat Liked your post',
//             postedTime: 'Today at 20:31 PM',
//             pic: Icon(
//               FontAwesomeIcons.comment,
//               color: kWhiteColor,
//               size: 15,
//             ),
//           ),
//           SizedBox(
//             height: distance_10,
//           ),
//           Divider(
//             color: kBaseGrey.withOpacity(0.5),
//           ),
//           SizedBox(
//             height: distance_10,
//           ),
//           RequestNotificationWidget(
//               color: kBaseGrey,
//               text: 'Noa Hillzenrat comment on your post.',
//               postedTime: 'Today at 20:31 PM',
//               pic: CircleAvatar(
//                 // backgroundImage: CachedNetworkImageProvider(profileImage1),
//                 child: CachedNetworkImage(
//                   imageUrl: profileImage,
//                   imageBuilder: (context, imageProvider) {
//                     return Container(
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         image: DecorationImage(
//                           image: imageProvider,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     );
//                   },
//                   fit: BoxFit.cover,
//                   errorWidget: (context, url, error) => Container(
//                     decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade200),
//                     child: Center(
//                         child: Icon(
//                       Icons.error,
//                       color: Colors.red,
//                     )),
//                   ),
//                   placeholder: (context, url) => Image.asset(
//                     Assets.assets.images.userDefault,
//                   ),
//                 ),
//               )),
//           SizedBox(
//             height: distance_10,
//           ),
//           Divider(
//             color: kBaseGrey.withOpacity(0.5),
//           ),
//           SizedBox(
//             height: distance_10,
//           ),
//           RequestNotificationWidget(
//             color: kprimaryColor,
//             text: 'Noa Hillzenrat added a photo in Veagaterian vibes.',
//             postedTime: 'Today at 20:31 PM',
//             pic: Icon(
//               FontAwesomeIcons.heart,
//               color: kWhiteColor,
//               size: 15,
//             ),
//           ),
//           SizedBox(
//             height: distance_10,
//           ),
//           Divider(
//             color: kBaseGrey.withOpacity(0.5),
//           ),
//           SizedBox(
//             height: distance_10,
//           ),
//           RequestNotificationWidget(
//             color: kYellowColor,
//             text: 'Noa Hillzenrat gived a flower to your post.',
//             postedTime: 'Today at 20:31 PM',
//             pic: Icon(
//               MdiIcons.flowerPoppy,
//               color: kWhiteColor,
//               size: 15,
//             ),
//           ),
//           SizedBox(
//             height: distance_10,
//           ),
//           Divider(
//             color: kBaseGrey.withOpacity(0.5),
//           ),
//           SizedBox(
//             height: distance_10,
//           ),
//           Divider(
//             color: kBaseGrey.withOpacity(0.5),
//           ),
//           SizedBox(
//             height: distance_10,
//           ),
//           RequestNotificationWidget(
//               color: blueColor,
//               text: 'Noa ',
//               postedTime: 'Today at 20:31 PM',
//               pic: Icon(
//                 Icons.person,
//                 color: kWhiteColor,
//                 size: 15,
//               ),
//               widget1: Container(
//                 alignment: Alignment.center,
//                 height: distance_40,
//                 padding: EdgeInsets.symmetric(
//                   horizontal: distance_5,
//                 ),
//                 decoration: BoxDecoration(
//                   color: kprimaryColor,
//                   borderRadius: BorderRadius.circular(borderRadius_4),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.person_add_alt_1_outlined, color: kWhiteColor),
//                     SizedBox(
//                       width: distance_5,
//                     ),
//                     Text(
//                       'Approve',
//                       style: CustomTypography.body4StyleWhite,
//                     )
//                   ],
//                 ),
//               ),
//               widget2: Container(
//                 alignment: Alignment.center,
//                 height: distance_40,
//                 padding: EdgeInsets.symmetric(
//                   horizontal: distance_5,
//                 ),
//                 decoration: BoxDecoration(
//                   color: kBaseGrey,
//                   borderRadius: BorderRadius.circular(borderRadius_4),
//                 ),
//                 child: Text(
//                   'Decline',
//                   style: CustomTypography.bodyStyle,
//                 ),
//               )),
//         ],
//       ),
//     );
//   }
// }
