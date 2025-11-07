import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/routing/getx_route_methods.dart';

import '../../components/image_swiper.dart';
import '../../components/profile_image_widget.dart';

enum PostType {
  single,
  two,
  three,
  four,
  empty,
}

class MultipleNetworkImagesView extends StatelessWidget {
  final List<dynamic> images;
  const MultipleNetworkImagesView({Key? key, required this.images}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final images = this.images.map((e) => e.toString()).toList();
    PostType type = PostType.empty;
    type = (images.length == 1)
        ? PostType.single
        : (images.length == 2)
            ? PostType.two
            : (images.length == 3)
                ? PostType.three
                : (images.length == 4)
                    ? PostType.four
                    : PostType.empty;
    return type == PostType.single
        ? singleImage(images, context)
        : type == PostType.two
            ? twoImage(images, context)
            : type == PostType.three
                ? threeImage(images, context)
                : type == PostType.four
                    ? fourImage(images, context)
                    : const SizedBox();
  }

  Widget singleImage(List<dynamic> images, context) {
    return GestureDetector(
      onTap: () {
        Routes.openImages(urls: images as List<String>, index: 0, ctx: context);
      },
      child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12).r),
          child: ScrolledHero(
              tag: images.first,
              transitionOnUserGestures: true,
              child: PostImageWidget(url: images.first)) //PostImageModifiedWidget(url: e),
          ),
    );
  }

  Widget twoImage(List<dynamic> images, context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.35,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Routes.openImages(urls: images as List<String>, index: 0, ctx: context);
              },
              child: ImageBuilderPost(
                borderRadius: BorderRadius.circular(4),
                imageUrl: images[0],
                onPhotoTap: (_) {
                  // Get.to(() => PhotoViewWrapper(initialIndex: _ ?? 0, galleryItems: images.map((e) => e.content).toList()));
                },
              ),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Routes.openImages(urls: images as List<String>, index: 1, ctx: context);
              },
              child: ImageBuilderPost(
                borderRadius: BorderRadius.circular(4),
                imageUrl: images[1],
                onPhotoTap: (_) {
                  // Get.to(() => PhotoViewWrapper(initialIndex: _ ?? 0, galleryItems: images.map((e) => e.content).toList()));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget threeImage(List<dynamic> images, context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.35,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: GestureDetector(
                    onTap: () {
                      Routes.openImages(urls: images as List<String>, index: 0, ctx: context);
                    },
                    child: ImageBuilderPost(
                      imageUrl: images[0],
                      borderRadius: BorderRadius.circular(4),
                      onPhotoTap: (_) {
                        // Get.to(() => PhotoViewWrapper(initialIndex: _ ?? 0, galleryItems: images.map((e) => e.content).toList()));
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: GestureDetector(
                    onTap: () {
                      Routes.openImages(urls: images as List<String>, index: 1, ctx: context);
                    },
                    child: ImageBuilderPost(
                      imageUrl: images[1],
                      borderRadius: BorderRadius.circular(4),
                      onPhotoTap: (_) {
                        // Get.to(() => PhotoViewWrapper(initialIndex: _ ?? 0, galleryItems: images.map((e) => e.content).toList()));
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Routes.openImages(urls: images as List<String>, index: 2, ctx: context);
              },
              child: ImageBuilderPost(
                imageUrl: images[2],
                borderRadius: BorderRadius.circular(4),
                onPhotoTap: (_) {
                  // Get.to(() => PhotoViewWrapper(initialIndex: _ ?? 0, galleryItems: images.map((e) => e.content).toList()));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget fourImage(List<dynamic> images, context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.35,
      child: Row(
        children: [
          Flexible(
            child: Column(
              children: [
                Flexible(
                  child: GestureDetector(
                    onTap: () {
                      Routes.openImages(urls: images as List<String>, index: 0, ctx: context);
                    },
                    child: ImageBuilderPost(
                      imageUrl: images[0],
                      borderRadius: BorderRadius.circular(4),
                      onPhotoTap: (_) {
                        // Get.to(() => PhotoViewWrapper(initialIndex: _ ?? 0, galleryItems: images.map((e) => e.content).toList()));
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Flexible(
                  child: GestureDetector(
                    onTap: () {
                      Routes.openImages(urls: images as List<String>, index: 1, ctx: context);
                    },
                    child: ImageBuilderPost(
                      imageUrl: images[1],
                      borderRadius: BorderRadius.circular(4),
                      onPhotoTap: (_) {
                        // Get.to(() => PhotoViewWrapper(initialIndex: _ ?? 0, galleryItems: images.map((e) => e.content).toList()));
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Column(
              children: [
                Flexible(
                  child: GestureDetector(
                    onTap: () {
                      Routes.openImages(urls: images as List<String>, index: 2, ctx: context);
                    },
                    child: ImageBuilderPost(
                      imageUrl: images[2],
                      borderRadius: BorderRadius.circular(4),
                      onPhotoTap: (_) {
                        // Get.to(() => PhotoViewWrapper(initialIndex: _ ?? 0, galleryItems: images.map((e) => e.content).toList()));
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Flexible(
                  child: Stack(
                    children: [
                      Positioned(
                        child: GestureDetector(
                          onTap: () {
                            Routes.openImages(urls: images as List<String>, index: 3, ctx: context);
                          },
                          child: ImageBuilderPost(
                            imageUrl: images[3],
                            borderRadius: BorderRadius.circular(4),
                            onPhotoTap: (_) {
                              // Get.to(() => PhotoViewWrapper(initialIndex: _ ?? 0, galleryItems: images.map((e) => e.content).toList()));
                            },
                          ),
                        ),
                      ),
                      // +1 +2 means shows how many more images left...
                      if (images.length > 4)
                        Positioned.fill(
                            right: 0,
                            left: 0,
                            child: InkWell(
                              onTap: () {
                                // Get.to(() => PhotoViewWrapper(initialIndex: 2, galleryItems: images.map((e) => e.content).toList()));
                              },
                              child: Container(
                                alignment: Alignment.center,
                                color: Colors.black.withOpacity(0.6),
                                child: Text("+ ${images.length - 4}",
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            )),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ImageBuilderPost extends StatelessWidget {
  final String imageUrl;
  final BorderRadius borderRadius;
  final Function(int?)? onPhotoTap;
  const ImageBuilderPost({
    Key? key,
    required this.onPhotoTap,
    required this.imageUrl,
    required this.borderRadius,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
        ),
        child: ScrolledHero(
            tag: imageUrl,
            transitionOnUserGestures: true,
            child: PostImageWidget(url: imageUrl)));
  }
}
