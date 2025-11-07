import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpers/helpers.dart';
import '../../utils/const.dart';

class InterestWidget extends StatelessWidget {
  final String image;
  final Color color;
  final String? title;
  final VoidCallback? onTap;
  final double horizontalDistance;
  final TextStyle? textstyle;

  const InterestWidget({
    Key? key,
    this.textstyle,
    required this.image,
    this.title,
    this.onTap,
    required this.horizontalDistance,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isHebrew = Get.locale?.languageCode == "he";
    return GestureDetector(
        onTap: onTap,
        child: Chip(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          label: Text(isHebrew ? "${title.toString().tr}  $image" : '$image ${title.toString().tr}', style: textstyle),
          padding: EdgeInsets.symmetric(horizontal: horizontalDistance, vertical: distance_10),
        ));
  }
}
