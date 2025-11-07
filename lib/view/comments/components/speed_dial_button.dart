import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:get/get.dart';

class SpeedDialView extends StatelessWidget {
  const SpeedDialView({
    Key? key,
    this.tapOnPhoto,
    this.tapOnVideo,
    this.tapOnDocument,
  }) : super(key: key);
  final VoidCallback? tapOnPhoto;
  final VoidCallback? tapOnVideo;
  final VoidCallback? tapOnDocument;

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      useRotationAnimation: true,
      backgroundColor: kprimaryColor,
      tooltip: GayaStrings.add_media.tr,
      childPadding: const EdgeInsets.all(0),
      spaceBetweenChildren: 16,
      activeChild: SvgIconWidget.xCloseOutline(color: kWhiteColor),
      buttonSize: Size(38.h, 38.h),
      childrenButtonSize: Size(38.h, 38.h),
      visible: true,
      closeManually: false,
      overlayColor: kBaseGrey,
      overlayOpacity: 0.7,
      // backgroundColor: CustomColors.primaryColor,
      foregroundColor: Colors.white,
      elevation: 2.0,
      shape: const CircleBorder(),
      // orientation: SpeedDialOrientation.Up,
      children: [
        SpeedDialChild(child: SvgIconWidget.imageOutline(color: kWhiteColor), backgroundColor: kprimaryColor, onTap: tapOnPhoto),
        SpeedDialChild(child: const Icon(Icons.video_library, color: kWhiteColor), backgroundColor: kprimaryColor, onTap: tapOnVideo),
        SpeedDialChild(child: SvgIconWidget.fileOutline(color: kWhiteColor), backgroundColor: kprimaryColor, onTap: tapOnDocument),
      ],
      child: SvgIconWidget.plusOutline(color: kWhiteColor),
    );
  }
}
