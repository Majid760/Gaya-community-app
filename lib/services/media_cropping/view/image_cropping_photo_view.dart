import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gaya/gen/assets.gen.dart';
import 'package:gaya/services/media_cropping/service/image_cropping_service.dart';
import 'package:gaya/utils/app_data.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

enum CropRouteFrom { message, other }

class CropPhotoView extends StatefulWidget {
  CropPhotoView({
    super.key,
    this.loadingBuilder,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
    this.initialIndex = 0,
    required this.galleryItems,
    this.scrollDirection = Axis.horizontal,
    this.cropRoute = CropRouteFrom.other,
  }) : pageController = PageController(initialPage: initialIndex);

  final LoadingBuilder? loadingBuilder;
  final BoxDecoration? backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final int initialIndex;
  final PageController pageController;
  final List<File> galleryItems;
  final Axis scrollDirection;
  final CropRouteFrom cropRoute;

  @override
  State<StatefulWidget> createState() {
    return _CropPhotoViewState();
  }
}

class _CropPhotoViewState extends State<CropPhotoView> {
  late int currentIndex;
  List<File> images = [];
  final ImageServices imageService = ImageServices();

  @override
  void initState() {
    currentIndex = widget.initialIndex;
    images = widget.galleryItems;
    super.initState();
  }

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  void onSendPressed() {
    Get.back(result: images);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: getAppBar(),
      floatingActionButton: images.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.only(bottom: 40.0).r,
              child: _getSendIconButton(),
            )
          : const SizedBox.shrink(),
      body: SafeArea(
        child: Container(
          decoration: widget.backgroundDecoration,
          constraints: BoxConstraints.expand(height: MediaQuery.sizeOf(context).height),
          child: images.isEmpty
              ? Center(child: Text(GayaStrings.select_photo.tr))
              : PhotoViewGallery.builder(
                  scrollPhysics: const BouncingScrollPhysics(),
                  builder: _buildItem,
                  itemCount: images.length,
                  loadingBuilder: widget.loadingBuilder,
                  backgroundDecoration: widget.backgroundDecoration,
                  pageController: widget.pageController,
                  onPageChanged: onPageChanged,
                  scrollDirection: widget.scrollDirection),
        ),
      ),
    );
  }

  Widget _getSendIconButton() {
    switch (widget.cropRoute) {
      case CropRouteFrom.message:
        return FloatingActionButton(
          heroTag: null,
          onPressed: onSendPressed,
          backgroundColor: kTransparentColor,
          elevation: 0,
          child: Container(
              height: 48.r,
              width: 48.r,
              decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: Center(child: SvgPicture.asset(Assets.assets.icons.send, height: 30.r))),
        );
      case CropRouteFrom.other:
        return FloatingActionButton(
            backgroundColor: AppColors.primary, onPressed: onSendPressed, child: Icon(Icons.check, color: AppColors.white));
    }
  }

  getAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(56.h),
      child: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        centerTitle: true,
        backgroundColor: kBlackColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: kBlackColor),
        automaticallyImplyLeading: false,
        title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          IconButton(onPressed: () => Get.back(result: <File>[]), icon: Icon(Icons.cancel, size: 30.r, color: Colors.white)),
          Row(
            children: [
              images.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.delete_forever_rounded, size: 30.r, color: Colors.white),
                      onPressed: () {
                        if (currentIndex == 0) {
                          setState(() => images.removeAt(currentIndex));
                          Get.back(result: <File>[]);
                        } else {
                          setState(() => images.removeAt(currentIndex));
                        }
                      })
                  : const SizedBox.shrink(),
              IconButton(
                  icon: Icon(Icons.crop, size: 30.r, color: Colors.white),
                  onPressed: () async {
                    final croppedPhoto = await imageService.cropPhoto(images[currentIndex], context);
                    setState(() {
                      images[currentIndex] = croppedPhoto;
                    });
                  }),
            ],
          ),
        ]),
      ),
    );
  }

  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    //resource can be String or PickedItem
    final resource = widget.galleryItems[index];
    return PhotoViewGalleryPageOptions(
      imageProvider: FileImage(widget.galleryItems[index]),
      heroAttributes: PhotoViewHeroAttributes(tag: resource, transitionOnUserGestures: true),
      errorBuilder: (context, error, stackTrace) => AppData.defaultGreySimpleImage,
      // loadingBuilder: (context, event) => AppData.defaultBlackLoadingImage,
    );
  }
}
