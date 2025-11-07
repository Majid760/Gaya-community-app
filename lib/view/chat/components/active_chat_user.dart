import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/view/chat/components/user_image.dart';

class ActiveChatUser extends StatelessWidget {
  final String? url;
  final String? userName;
  final double height;
  final double width;
  final Widget? onLoading;
  final Widget? onError;
  final int? maxDiskCacheWidth;
  final int? maxDiskCacheHeight;
  final BoxShape? shape;
  final BoxFit? fit;
  final bool isHttpsImage;
  final bool useHeightWidthForcefully;
  final bool isActive;

  const ActiveChatUser({
    Key? key,
    required this.url,
    required this.userName,
    this.height = 90,
    this.width = 90,
    this.onError,
    this.onLoading,
    this.maxDiskCacheHeight,
    this.maxDiskCacheWidth,
    this.shape = BoxShape.circle,
    this.fit = BoxFit.cover,
    this.isHttpsImage = true,
    this.useHeightWidthForcefully = false,
    required this.isActive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 62.r,
          height: 62.r,
          child: UserAvatar(
              useHeightWidthForcefully: useHeightWidthForcefully,
              height: height,
              width: width,
              maxDiskCacheHeight: maxDiskCacheHeight,
              maxDiskCacheWidth: maxDiskCacheWidth,
              url: url,
              shape: shape,
              fit: fit,
              onError: onError,
              onLoading: onLoading,
              isActive: isActive),
        ),
        SizedBox(height: 8.h),
        Text(
          userName!,
          //name cannot pass 10 chars
          // (otherUser.name?.length ?? 0) > 10 ? '${otherUser.name!.substring(0, 7)}...' : otherUser.name ?? anonymousUser,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: TextStyle(fontSize: 12.64.sp, height: 1.18, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}
