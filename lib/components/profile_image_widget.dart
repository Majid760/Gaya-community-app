import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:extended_image_library/extended_image_library.dart' show File;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gaya/utils/app_data.dart';

class ProfileImageWidget extends StatelessWidget {
  final String? url;
  final double height;
  final double width;
  final Widget? onLoading;
  final Widget? onError;
  final Size? size;
  final int? maxDiskCacheWidth;
  final int? maxDiskCacheHeight;
  final BoxShape? shape;
  final BoxFit? fit;
  final bool isHttpsImage;
  final bool useHeightWidthForcefully;

  const ProfileImageWidget(
      {Key? key,
      required this.url,
      this.height = 90,
      this.width = 90,
      this.onError,
      this.onLoading,
      this.size,
      this.maxDiskCacheHeight,
      this.maxDiskCacheWidth,
      this.shape = BoxShape.circle,
      this.fit = BoxFit.cover,
      this.isHttpsImage = true,
      this.useHeightWidthForcefully = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      memCacheHeight: useHeightWidthForcefully ? height.toInt() : 30,
      memCacheWidth: useHeightWidthForcefully ? width.toInt() : 30,
      maxHeightDiskCache: maxDiskCacheHeight ?? 80,
      maxWidthDiskCache: maxDiskCacheWidth ?? 80,
      imageUrl: url ?? "",
      imageBuilder: (context, imageProvider) {
        return Container(
          decoration: BoxDecoration(
            shape: shape!,
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
        );
      },
      fit: fit,
      errorWidget: (context, url, error) => onError ?? AppData.defaultGreyCircleImage,
      placeholder: (context, url) => onLoading ?? AppData.defaultGreyCircleImage,
    );

    // return ExtendedImage.network(
    //   url ?? '',
    //   // width: height,
    //   // height: width,
    //   fit: BoxFit.fill,
    //   cache: true,
    //   cacheWidth: shouldHaveInfinityWidth ? null : this.size?.width.toInt() ?? 40,
    //   cacheHeight: shouldHaveInfinityHeight ? null : this.size?.height.toInt() ?? 40,
    //   maxBytes: 2000 * 2000 * 10,
    //   cacheMaxAge: const Duration(days: 4),
    //   clearMemoryCacheIfFailed: true,
    //   clearMemoryCacheWhenDispose: true,
    //   shape: BoxShape.circle,
    //   loadStateChanged: (ExtendedImageState state) {
    //     switch (state.extendedImageLoadState) {
    //       case LoadState.loading:
    //         return onLoading ?? AppData.defaultGreyCircleImage;
    //       case LoadState.completed:
    //         return null;
    //       case LoadState.failed:
    //         return onError ?? AppData.defaultGreyCircleImage;
    //     }
    //   },
    // );
  }
}

class PostImageWidget extends StatelessWidget {
  final String? url;
  final double? height;
  final double? width;
  final Widget? onLoading;
  final Widget? onError;
  final Size? size;
  final BoxFit? fit;
  final BoxShape? shape;
  final bool isHttpsImage;

  const PostImageWidget(
      {Key? key,
      required this.url,
      this.height,
      this.width,
      this.onError,
      this.onLoading,
      this.size,
      this.fit = BoxFit.cover,
      this.shape = BoxShape.rectangle,
      this.isHttpsImage = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return kIsWeb || isHttpsImage
        ? ExtendedImage.network(
            url ?? '',
            width: height,
            height: width,
            fit: fit,
            shape: shape,
            cacheHeight: size?.height.toInt() ?? 500,
            enableMemoryCache: false,
            maxBytes: 5000 * 5000 * 10,
            cacheMaxAge: const Duration(days: 3),
            clearMemoryCacheIfFailed: true,
            retries: 3,
            loadStateChanged: (ExtendedImageState state) {
              switch (state.extendedImageLoadState) {
                case LoadState.loading:
                  return onLoading ??
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.4,
                        child: AppData.defaultGreyLoadingImage,
                      );
                case LoadState.completed:
                  double height = (state.extendedImageInfo?.image.height != null && state.extendedImageInfo?.image.width != null)
                      ? getImageHeight(
                          context, state.extendedImageInfo!.image.height.toDouble(), state.extendedImageInfo!.image.width.toDouble())
                      : MediaQuery.sizeOf(context).height * 0.4.toDouble();
                  return ExtendedImageWidget(
                    url: url,
                    height: height,
                    width: MediaQuery.sizeOf(context).width,
                    fit: fit,
                    shape: shape,
                    size: size,
                  );

                case LoadState.failed:
                  return onError ??
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.4,
                        child: AppData.defaultGreySimpleImage,
                      );
              }
            },
          )
        : ExtendedImage.file(
            File(url ?? ''),
            width: height,
            height: width,
            fit: fit,
            shape: shape,
            cacheHeight: size?.height.toInt() ?? 500,
            enableMemoryCache: false,
            maxBytes: 5000 * 5000 * 10,
            clearMemoryCacheIfFailed: true,
            loadStateChanged: (ExtendedImageState state) {
              switch (state.extendedImageLoadState) {
                case LoadState.loading:
                  return onLoading ?? AppData.defaultGreyLoadingImage;
                case LoadState.completed:
                  return null;
                case LoadState.failed:
                  return onError ?? AppData.defaultGreySimpleImage;
              }
            },
          );
  }

  double getImageHeight(context, double height, double width) {
    double imageHeight = (width > height)
        ? (height > (MediaQuery.sizeOf(context).height * 0.35).toDouble())
            ? (MediaQuery.sizeOf(context).height * 0.35).toDouble()
            : (MediaQuery.sizeOf(context).height * 0.2).toDouble()
        : (height > (MediaQuery.sizeOf(context).height * 0.35).toDouble())
            ? (MediaQuery.sizeOf(context).height * 0.5).toDouble()
            : height;

    return imageHeight;
  }
}

class ExtendedImageWidget extends StatelessWidget {
  const ExtendedImageWidget({
    super.key,
    required this.url,
    required this.height,
    required this.width,
    required this.fit,
    required this.shape,
    required this.size,
  });

  final String? url;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final BoxShape? shape;
  final Size? size;

  @override
  Widget build(BuildContext context) {
    return ExtendedImage.network(
      url ?? '',
      width: width,
      height: height,
      fit: fit,
      cache: true,
      shape: shape,
      cacheHeight: size?.height.toInt() ?? 500,
      enableMemoryCache: false,
      maxBytes: 5000 * 5000 * 10,
      cacheMaxAge: const Duration(days: 3),
      clearMemoryCacheIfFailed: true,
      retries: 3,
    );
  }
}

class PostImageModifiedWidget extends StatelessWidget {
  final String? url;
  final double height;
  final double width;
  final Widget? onLoading;
  final Widget? onError;
  final Size? size;
  final int? maxDiskCacheWidth;
  final int? maxDiskCacheHeight;
  final BoxShape? shape;
  final BoxFit? fit;
  final bool isHttpsImage;

  const PostImageModifiedWidget(
      {Key? key,
      required this.url,
      this.height = 90,
      this.width = 90,
      this.onError,
      this.onLoading,
      this.size,
      this.maxDiskCacheHeight,
      this.maxDiskCacheWidth,
      this.shape = BoxShape.rectangle,
      this.fit = BoxFit.cover,
      this.isHttpsImage = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      memCacheHeight: 30,
      memCacheWidth: 30,
      maxHeightDiskCache: size?.height.toInt() ?? 500,
      // maxWidthDiskCache: maxDiskCacheWidth ?? 80,
      imageUrl: url ?? "",
      imageBuilder: (context, imageProvider) {
        return Container(decoration: BoxDecoration(shape: shape!, image: DecorationImage(image: imageProvider, fit: BoxFit.cover)));
      },
      fit: fit,
      errorWidget: (context, url, error) => onError ?? AppData.defaultGreyCircleImage,
      placeholder: (context, url) => onLoading ?? AppData.defaultGreyCircleImage,
    );

    // return ExtendedImage.network(
    //   url ?? '',
    //   // width: height,
    //   // height: width,
    //   fit: BoxFit.fill,
    //   cache: true,
    //   cacheWidth: shouldHaveInfinityWidth ? null : this.size?.width.toInt() ?? 40,
    //   cacheHeight: shouldHaveInfinityHeight ? null : this.size?.height.toInt() ?? 40,
    //   maxBytes: 2000 * 2000 * 10,
    //   cacheMaxAge: const Duration(days: 4),
    //   clearMemoryCacheIfFailed: true,
    //   clearMemoryCacheWhenDispose: true,
    //   shape: BoxShape.circle,
    //   loadStateChanged: (ExtendedImageState state) {
    //     switch (state.extendedImageLoadState) {
    //       case LoadState.loading:
    //         return onLoading ?? AppData.defaultGreyCircleImage;
    //       case LoadState.completed:
    //         return null;
    //       case LoadState.failed:
    //         return onError ?? AppData.defaultGreyCircleImage;
    //     }
    //   },
    // );
  }
}
