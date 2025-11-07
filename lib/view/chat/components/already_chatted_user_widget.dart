// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:gaya/gen/assets.gen.dart';
// import 'package:gaya/utils/const.dart';
// import 'package:gaya/utils/methods.dart';
// import 'package:gaya/utils/textstyles.dart';
// import 'package:gaya/utils/theme/app_colors.dart';
// import 'package:gaya/utils/theme/app_typography.dart';
// import 'package:gaya/view/chat_ubaid/controllers/new_chat_controller.dart';
// import 'package:jiffy/jiffy.dart';


// class AlreadyChattedUserWidget extends StatelessWidget {
//   final String profileImage, name, message;
//   final String time;
//   final VoidCallback ontap;
//   final VoidCallback onLongTap;
//   final bool isRead;
//   final bool? isGroup;

//   const AlreadyChattedUserWidget(
//       {Key? key,
//       required this.profileImage,
//       required this.ontap,
//       required this.onLongTap,
//       required this.name,
//       required this.message,
//       required this.time,
//       this.isGroup,
//       required this.isRead})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16).r,
//       leading: profileImage == ''
//           ? CircleAvatar(radius: 25.r, backgroundImage: const AssetImage('Assets/images/user.png'))
//           : CircleAvatar(
//               radius: 25.r,
//               child: CachedNetworkImage(
//                 imageUrl: profileImage,
//                 memCacheHeight: 80,
//                 memCacheWidth: 80,
//                 imageBuilder: (context, imageProvider) {
//                   return Container(
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
//                     ),
//                   );
//                 },
//                 fit: BoxFit.cover,
//                 errorWidget: (context, url, error) => Container(
//                   decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade200),
//                 ),
//                 placeholder: (context, url) => Image.asset(Assets.assets.images.userDefault),
//               ),
//               // onBackgroundImageError: ((exception, stackTrace) => Icon(Icons.error_outline)),
//             ),
//       title: Text(name, style: CustomTypography.body4StyleHeight, overflow: TextOverflow.ellipsis, maxLines: 1),
//       subtitle: Text(
//         message,
//         textDirection: Methods.isRTL(message) ? TextDirection.rtl : TextDirection.ltr,
//         style: isRead == false ? CustomTypography.unreadStyle : GayaTypography.subtitleRegular.copyWith(color: AppColors.secondary),
//         overflow: TextOverflow.ellipsis,
//       ),
//       trailing: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           Text(Jiffy(time).fromNow(), style: CustomTypography.secondaryFontStyleWeight),
//           SizedBox(height: 12.h),
//           if (isRead == false) const CircleAvatar(radius: 4, backgroundColor: kprimaryColor)
//         ],
//       ),
//       onTap:() =>  NewChatController.tapOnChat(name,isGroup??false),
//       onLongPress: onLongTap,
//     );

//   }
// }
