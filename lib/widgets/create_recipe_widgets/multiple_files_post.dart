import 'package:flutter/material.dart';
import 'package:gaya/controller/create.post.controller.dart';
import 'package:provider/provider.dart';

enum PostType {
  single,
  two,
  three,
  four,
  empty,
}

class MultipleImageShow extends StatelessWidget {
  final CreatePostController controller;
  const MultipleImageShow({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    PostType type = PostType.empty;
    return Consumer<CreatePostController>(builder: (_, postController, __) {
      postController.images.isNotEmpty
          ? type = postController.images.length == 1
              ? PostType.single
              : postController.images.length == 2
                  ? PostType.two
                  : postController.images.length == 3
                      ? PostType.three
                      : PostType.four
          : PostType.empty;
      return SizedBox(
        height: 270,
        child: type == PostType.single
            ? singleImage(postController.images, context)
            : type == PostType.two
                ? twoImage(postController.images)
                : type == PostType.three
                    ? threeImage(postController.images)
                    : type == PostType.four
                        ? fourImage(postController.images)
                        : const SizedBox(),
      );
    });
  }

  Widget singleImage(List<dynamic> images, context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4), image: DecorationImage(image: FileImage(images.first), fit: BoxFit.cover)),
        ),
        Positioned(
            top: 10,
            right: 10,
            child: InkWell(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.black,
                  size: 14,
                ),
              ),
              onTap: () {
                controller.removeNewPostmediaItem(0);
              },
            )),
      ],
    );
  }

  Widget twoImage(List<dynamic> images) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: ImageBuilderPost(
            borderRadius: BorderRadius.circular(4),
            index: 0,
            onPhotoTap: (_) {
              // Get.to(() => PhotoViewWrapper(initialIndex: _ ?? 0, galleryItems: images.map((e) => e.content).toList()));
            },
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: ImageBuilderPost(
            borderRadius: BorderRadius.circular(4),
            index: 1,
            onPhotoTap: (_) {
              // Get.to(() => PhotoViewWrapper(initialIndex: _ ?? 0, galleryItems: images.map((e) => e.content).toList()));
            },
          ),
        ),
      ],
    );
  }

  Widget threeImage(List<dynamic> images) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: ImageBuilderPost(
                  index: 0,
                  borderRadius: BorderRadius.circular(4),
                  onPhotoTap: (_) {
                    // Get.to(() => PhotoViewWrapper(initialIndex: _ ?? 0, galleryItems: images.map((e) => e.content).toList()));
                  },
                ),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: ImageBuilderPost(
                  index: 1,
                  borderRadius: BorderRadius.circular(4),
                  onPhotoTap: (_) {
                    // Get.to(() => PhotoViewWrapper(initialIndex: _ ?? 0, galleryItems: images.map((e) => e.content).toList()));
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Expanded(
          child: ImageBuilderPost(
            index: 2,
            borderRadius: BorderRadius.circular(4),
            onPhotoTap: (_) {
              // Get.to(() => PhotoViewWrapper(initialIndex: _ ?? 0, galleryItems: images.map((e) => e.content).toList()));
            },
          ),
        ),
      ],
    );
  }

  Widget fourImage(List<dynamic> images) {
    return Row(
      children: [
        Flexible(
          child: Column(
            children: [
              Flexible(
                child: ImageBuilderPost(
                  index: 0,
                  borderRadius: BorderRadius.circular(4),
                  onPhotoTap: (_) {
                    // Get.to(() => PhotoViewWrapper(initialIndex: _ ?? 0, galleryItems: images.map((e) => e.content).toList()));
                  },
                ),
              ),
              const SizedBox(height: 5),
              Flexible(
                child: ImageBuilderPost(
                  index: 2,
                  borderRadius: BorderRadius.circular(4),
                  onPhotoTap: (_) {
                    // Get.to(() => PhotoViewWrapper(initialIndex: _ ?? 0, galleryItems: images.map((e) => e.content).toList()));
                  },
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
                child: ImageBuilderPost(
                  index: 1,
                  borderRadius: BorderRadius.circular(4),
                  onPhotoTap: (_) {
                    // Get.to(() => PhotoViewWrapper(initialIndex: _ ?? 0, galleryItems: images.map((e) => e.content).toList()));
                  },
                ),
              ),
              const SizedBox(height: 5),
              Flexible(
                child: Stack(
                  children: [
                    Positioned(
                      child: ImageBuilderPost(
                        index: 3,
                        borderRadius: BorderRadius.circular(4),
                        onPhotoTap: (_) {
                          // Get.to(() => PhotoViewWrapper(initialIndex: _ ?? 0, galleryItems: images.map((e) => e.content).toList()));
                        },
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
                              child:
                                  Text("+ ${images.length - 4}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          )),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class ImageBuilderPost extends StatelessWidget {
  final int index;
  final BorderRadius borderRadius;
  final Function(int?)? onPhotoTap;

  const ImageBuilderPost({
    Key? key,
    required this.onPhotoTap,
    required this.index,
    required this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final createPostController = Provider.of<CreatePostController>(context, listen: true);

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: borderRadius, image: DecorationImage(image: FileImage(createPostController.images[index]), fit: BoxFit.cover)),
        ),
        Positioned(
            top: 10,
            right: 10,
            child: InkWell(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.black,
                  size: 14,
                ),
              ),
              onTap: () {
                createPostController.removeNewPostmediaItem(index);
              },
            )),
      ],
    );
  }
}
