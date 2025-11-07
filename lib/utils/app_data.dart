import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gaya/utils/theme/app_colors.dart';

import '../gen/assets.gen.dart';

class AppData {
  AppData._();

  //Error Circle Avatar
  static const Widget defaultErrorWidget = DefaultErrorWidget();

  //user default profile picture
  static Widget defaultUserProfileWidget({int? radius}) => DefaultUserProfileWidget(radius: radius);

  static const Widget defaultGreyCircleImage = DefaultGreyCircleImage();
  static const Widget defaultInterestImage = DefaultInterestImage();

  static const Widget defaultGreySimpleImage = DefaultGreySimpleImage();

  static const Widget defaultGreyLoadingImage = DefaultGreyLoadingImage();

  static const Widget defaultBlackLoadingImage = DefaultBlackLoadingImage();

  // loading widget for async buttons.
  static const Widget loadingAsyncWidget = LoadingAsyncWidget();
}

class DefaultGreyLoadingImage extends StatelessWidget {
  const DefaultGreyLoadingImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(shape: BoxShape.rectangle, color: Colors.grey.shade200),
      child: const Center(child: CupertinoActivityIndicator()),
    );
  }
}

class DefaultUserProfileWidget extends StatelessWidget {
  final int? radius;

  const DefaultUserProfileWidget({Key? key, required this.radius}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(Assets.assets.images.userDefault, cacheHeight: radius ?? 40, cacheWidth: radius ?? 40);
  }
}

class DefaultGreyCircleImage extends StatelessWidget {
  const DefaultGreyCircleImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade200),
    );
  }
}

class DefaultInterestImage extends StatelessWidget {
  const DefaultInterestImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        shape: BoxShape.rectangle,
        color: Colors.black.withOpacity(0.5),
      ),
    );
  }
}

class DefaultGreySimpleImage extends StatelessWidget {
  const DefaultGreySimpleImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(shape: BoxShape.rectangle, color: Colors.grey.shade200),
    );
  }
}

class DefaultBlackLoadingImage extends StatelessWidget {
  const DefaultBlackLoadingImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(shape: BoxShape.rectangle, color: Colors.black),
      child: const Center(
          child: CircularProgressIndicator.adaptive(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      )),
    );
  }
}

class LoadingAsyncWidget extends StatelessWidget {
  const LoadingAsyncWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: CircularProgressIndicator.adaptive(
      backgroundColor: AppColors.primary,
    ));
  }
}

class DefaultErrorWidget extends StatelessWidget {
  const DefaultErrorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade200),
      child: const Center(child: Icon(Icons.error, color: Colors.red)),
    );
  }
}

class AnonymousProfilePictureWidget extends StatelessWidget {
  final String? gender;
  final int? radius;

  const AnonymousProfilePictureWidget({Key? key, required this.gender, this.radius}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (gender == "male") {
      return Image.asset("Assets/images/anonymous_boy.png", cacheHeight: radius ?? 40, cacheWidth: radius ?? 40);
    } else if (gender == "female") {
      return Image.asset("Assets/images/anonymous_girl.png", cacheHeight: radius ?? 40, cacheWidth: radius ?? 40);
    }
    return Image.asset("Assets/images/anonymous_user.png", cacheHeight: radius ?? 40, cacheWidth: radius ?? 40);
  }
}
