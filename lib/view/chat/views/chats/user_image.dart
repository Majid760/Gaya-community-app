import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/app_data.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.useHeightWidthForcefully,
    this.height,
    this.width,
    this.maxDiskCacheHeight,
    this.maxDiskCacheWidth,
    required this.url,
    this.shape,
    this.fit,
    this.onError,
    this.onLoading,
    required this.isActive,
  });

  final bool? useHeightWidthForcefully;
  final double? height;
  final double? width;
  final int? maxDiskCacheHeight;
  final int? maxDiskCacheWidth;
  final String? url;
  final BoxShape? shape;
  final BoxFit? fit;
  final Widget? onError;
  final Widget? onLoading;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 62.r,
      width: width ?? 62.r,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CachedNetworkImage(
            memCacheHeight: useHeightWidthForcefully ?? false ? height?.toInt() : 30,
            memCacheWidth: useHeightWidthForcefully ?? false ? width?.toInt() : 30,
            maxHeightDiskCache: maxDiskCacheHeight ?? 80,
            maxWidthDiskCache: maxDiskCacheWidth ?? 80,
            imageUrl: url ?? "",
            imageBuilder: (context, imageProvider) {
              return Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: imageProvider, fit: BoxFit.cover)));
            },
            fit: fit,

            /// added +2 to radius because the default picture has a border of 2
            errorWidget: (context, url, error) => onError ?? AppData.defaultUserProfileWidget(radius: 64.r.toInt()),
            placeholder: (context, url) => onLoading ?? AppData.defaultUserProfileWidget(radius: 64.r.toInt()),
          ),
          isActive
              ? Positioned(
                  bottom: -1,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                    child: Container(
                      width: 10.r,
                      height: 10.r,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
