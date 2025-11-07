import 'package:flutter/material.dart';
import 'package:gaya/components/profile_image_widget.dart';

import '../gen/assets.gen.dart';
import '../utils/const.dart';

class AvatarWidget extends StatelessWidget {
  final Widget imageWidget;
  final Color backgroundColor;
  final String profileImg;
  final bool shouldShowImageWidget;

  const AvatarWidget({
    Key? key,
    required this.imageWidget,
    required this.backgroundColor,
    required this.profileImg,
    this.shouldShowImageWidget = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 55,
          child: Stack(
            children: [
              profileImg == ''
                  ? CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage(
                        Assets.assets.images.userDefault,
                      ),
                      backgroundColor: kBaseGrey,
                    )
                  : CircleAvatar(
                      radius: 25,
                      backgroundColor: kBaseGrey,
                      child: ProfileImageWidget(
                        url: profileImg,
                        size: const Size(80, 80),
                      ),
                    ),
              if (shouldShowImageWidget)
                Positioned(
                  bottom: -1,
                  right: 3,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: kTransparentColor,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: backgroundColor,
                      child: imageWidget,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class ColorAvatarWidget extends StatelessWidget {
  final Widget imageWidget;
  final Color backgroundColor;
  final bool shouldShowImageWidget;

  const ColorAvatarWidget({
    Key? key,
    required this.imageWidget,
    required this.backgroundColor,
    this.shouldShowImageWidget = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 55,
          child: Stack(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundColor: kprimaryColor,
              ),
              if (shouldShowImageWidget)
                Positioned(
                  bottom: -1,
                  right: 3,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: kTransparentColor,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: backgroundColor,
                      child: imageWidget,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
