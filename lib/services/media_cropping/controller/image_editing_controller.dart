import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gaya/services/media_cropping/service/image_cropping_service.dart';

class PhotoEditingController extends ChangeNotifier {
  PhotoEditingController() {}

  @override
  void dispose() {
    super.dispose();
  }

  // controller instances members
  // image service class
  ImageServices imageServices = ImageServices();
  PageController pageController = PageController(initialPage: 0);
  late int currentIndex;
  List<File> images = [];

  void setController(List<File> photos, [int initialPage = 0]) {
    images = photos;
    currentIndex = initialPage;
    notifyListeners();
  }

  void onPageChanged(int index) {
    currentIndex = index;
    notifyListeners();
  }

  void removeImage(int index) {
    images.removeAt(index);
    notifyListeners();
  }

  Future<void> cropPhoto(BuildContext context, File image) async {
    try {
      File file = await imageServices.cropPhoto(images[currentIndex], context);
      images.removeAt(currentIndex);
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
