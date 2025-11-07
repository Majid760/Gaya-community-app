import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gaya/gen/assets.gen.dart';
import 'package:gaya/utils/methods.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:gaya/view/ai_daily_user_matches/utils/ai_assets_path.dart';
// import 'package:gaya/view/chat_ubaid/controllers/new_chat_controller.dart';
import 'package:jiffy/jiffy.dart';

class AlreadyChattedUserWidget extends StatelessWidget {
  final String profileImage, name, message;
  final String time;
  final String type;
  final VoidCallback ontap;
  final VoidCallback onLongTap;
  final bool isRead;
  final int unreadMessagesCount;
  bool isMatchDialog = false;

  AlreadyChattedUserWidget(
      {Key? key,
      required this.profileImage,
      required this.ontap,
      required this.onLongTap,
      required this.name,
      required this.message,
      required this.time,
      this.type = 'Private',
      required this.isRead,
      required this.unreadMessagesCount,
      required this.isMatchDialog})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16).r,
      leading: profileImage != ''
          ? CircleAvatar(
              radius: 25.r,
              child: CachedNetworkImage(
                imageUrl: profileImage,
                memCacheHeight: 80,
                memCacheWidth: 80,
                imageBuilder: (context, imageProvider) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                    ),
                  );
                },
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade200),
                ),
                placeholder: (context, url) => Image.asset(Assets.assets.images.userDefault),
              ),
              // onBackgroundImageError: ((exception, stackTrace) => Icon(Icons.error_outline)),
            )
          : (type == 'Private')
              ? CircleAvatar(radius: 25.r, backgroundImage: const AssetImage('Assets/images/user.png'))
              : SvgPicture.asset(
                  Assets.assets.icons.groupImage,
                  fit: BoxFit.cover,
                ),
      title: Text(name, style: CustomTypography.body4StyleHeight, overflow: TextOverflow.ellipsis, maxLines: 1),
      subtitle: Text(
        message,
        textDirection: Methods.isRTL(message) ? TextDirection.rtl : TextDirection.ltr,
        style: unreadMessagesCount > 0 ? CustomTypography.unreadStyle : GayaTypography.subtitleRegular.copyWith(color: AppColors.secondary),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: 100.r,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isMatchDialog)
                  Container(
                    width: 26.r,
                    height: 26.r,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.black5,
                    ),
                    child: Image.asset(
                      AiAssetsPath.boot,
                      width: 16.w,
                      height: 20.h,
                    ),
                  ),
                SizedBox(width: 7.r),
                Text(
                  time,
                  style: CustomTypography.secondaryFontStyleWeight.copyWith(fontSize: 12.sp),
                  // textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(height: 4.h),
          if (unreadMessagesCount > 0)
            Container(
              // radius: 8.r,
              padding: const EdgeInsets.all(4).r,
              // color: kprimaryColor,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
              child: Text(
                unreadMessagesCount.toString(),
                textDirection: Methods.isRTL(message) ? TextDirection.rtl : TextDirection.ltr,
                style: GayaTypography.subtitleRegular.copyWith(color: AppColors.white, fontSize: 10.sp),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            )
        ],
      ),
      onTap: ontap, // NewChatController.tapOnChat(name),
      onLongPress: onLongTap,
    );
  }
}
