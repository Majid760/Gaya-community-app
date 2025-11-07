import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/gen/assets.gen.dart';

import '../../utils/const.dart';
import '../../utils/methods.dart';
import '../../utils/textstyles.dart';
import '../../utils/theme/app_colors.dart';

class GetMessageList extends StatelessWidget {
  final String profileImage, name, message;
  final String time;
  final VoidCallback ontap;
  final VoidCallback onLongTap;
  final bool isRead;

  const GetMessageList(
      {Key? key,
      required this.profileImage,
      required this.ontap,
      required this.onLongTap,
      required this.name,
      required this.message,
      required this.time,
      required this.isRead})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16).r,
      leading: profileImage == ''
          ? CircleAvatar(radius: 25.r, backgroundImage: const AssetImage('Assets/images/user.png'))
          : CircleAvatar(
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
            ),
      title: Text(name, style: CustomTypography.body4StyleHeight, overflow: TextOverflow.ellipsis, maxLines: 1),
      subtitle: Text(
        message,
        textDirection: Methods.isRTL(message) ? TextDirection.rtl : TextDirection.ltr,
        style: isRead == false ? CustomTypography.unreadStyle : GayaTypography.subtitleRegular.copyWith(color: AppColors.secondary),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(time, style: CustomTypography.secondaryFontStyleWeight),
          SizedBox(height: 12.h),
          if (isRead == false) const CircleAvatar(radius: 4, backgroundColor: kprimaryColor)
        ],
      ),
      onTap: ontap,
      onLongPress: onLongTap,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16).r,
      child: InkWell(
        highlightColor: kTransparentColor,
        splashColor: kTransparentColor,
        hoverColor: const Color.fromRGBO(255, 255, 255, 0.0),
        onTap: ontap,
        onLongPress: onLongTap,
        child: SizedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              profileImage == ''
                  ? CircleAvatar(
                      radius: 25.r,
                      backgroundImage: AssetImage('Assets/images/user.png'),
                    )
                  : CircleAvatar(
                      radius: 25.r,
                      child: CachedNetworkImage(
                        imageUrl: profileImage,
                        memCacheHeight: 50,
                        memCacheWidth: 50,
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
                    ),
              const SizedBox(width: distance_10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: CustomTypography.body4StyleHeight,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const Spacer(),
                        Text(time, style: CustomTypography.secondaryFontStyleWeight),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            message,
                            // textDirection: Methods.isRTL(message) ? TextDirection.rtl : TextDirection.ltr,
                            style: isRead == false ? CustomTypography.unreadStyle : CustomTypography.secondaryFontStyleWeight,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Spacer(),
                        isRead == true ? const CircleAvatar(radius: 4, backgroundColor: kprimaryColor) : const SizedBox(),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
