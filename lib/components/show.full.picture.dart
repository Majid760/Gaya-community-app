import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gaya/utils/app_data.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../shared/view/widget/gaya_back_button.dart';

class FullPicture extends StatelessWidget {
  final String photo;

  const FullPicture({Key? key, required this.photo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: GayaBackButton(

          ),
        ),
        body: Stack(
          children: [
            PhotoView(
              imageProvider: ExtendedNetworkImageProvider(photo, cache: false, cacheRawData: false),
              heroAttributes: PhotoViewHeroAttributes(tag: photo, transitionOnUserGestures: true),
              errorBuilder: (context, error, stackTrace) => AppData.defaultGreySimpleImage,
              loadingBuilder: (context, event) => AppData.defaultBlackLoadingImage,
            ),
          ],
        ),
      ),
    );
  }
}

// class PostImages extends StatelessWidget {
//   final List<dynamic> allImages;
//   const PostImages({super.key, required this.allImages});

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: kBlackColor,
//         appBar: PreferredSize(
//             preferredSize: Size.fromHeight(50),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 BackButton(
//                   color: kWhiteColor,
//                 ),
//               ],
//             )),
//         body: Swiper(
//           containerHeight: MediaQuery.sizeOf(context).height * 0.3,
//           viewportFraction: 1.0,
//           fade: 0.8,
//           loop: false,
//           itemBuilder: (BuildContext context, int index) {
//             return PostImageWidget(
//               url: allImages[index],
//               size: Size(600, 600),
//             );

//             //     new CachedNetworkImage(
//             //   imageUrl: allImages[index],
//             //   fit: BoxFit.fill,
//             // );
//           },

//           // indicatorLayout:Colors,re
//           // autoplay: true,
//           itemCount: allImages.length,
//           pagination: new SwiperPagination(),
//         ),
//       ),
//     );
//   }
// }

class PostImages extends StatefulWidget {
  PostImages({super.key,
    this.initialIndex = 0,
    required this.allImages,
  }) : pageController = PageController(initialPage: initialIndex);

  final int initialIndex;
  final PageController pageController;
  final allImages;

  @override
  State<StatefulWidget> createState() {
    return _PhotoViewWrapperState();
  }
}

class _PhotoViewWrapperState extends State<PostImages> {
  late int currentIndex;

  @override
  void initState() {
    currentIndex = widget.initialIndex;
    super.initState();
  }

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // decoration: widget.backgroundDecoration,
        constraints: BoxConstraints.expand(
          height: MediaQuery.sizeOf(context).height,
        ),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: <Widget>[
            PhotoViewGallery.builder(
                scrollPhysics: const BouncingScrollPhysics(),
                builder: _buildItem,
                itemCount: widget.allImages.length,
                loadingBuilder: (context, event) => AppData.defaultBlackLoadingImage,
                pageController: widget.pageController,
                onPageChanged: onPageChanged),
            crossIconPositioned(),
          ],
        ),
      ),
    );
  }

  crossIconPositioned() {
    return Positioned(
      top: 40.0,
      right: 20.0,
      child: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Colors.black54,
            ),
            child: const Icon(Icons.cancel, size: 30, color: Colors.white)),
      ),
    );
  }

  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    //resource can be String or PickedItem
    final resource = widget.allImages[index];
    return PhotoViewGalleryPageOptions(
      imageProvider: resource is String
          ? ExtendedNetworkImageProvider(resource, cache: false, cacheRawData: false)
          : kIsWeb
          ? NetworkImage(XFile(resource.path).path)
          : resource.isFile
          ? FileImage(File(resource.path)) as ImageProvider<Object>?
          : NetworkImage(resource.path),
      initialScale: PhotoViewComputedScale.contained,
      minScale: PhotoViewComputedScale.contained * (0.5 + index / 10),
      maxScale: PhotoViewComputedScale.covered * 4.1,
      heroAttributes: PhotoViewHeroAttributes(tag: resource),
    );
  }
}
