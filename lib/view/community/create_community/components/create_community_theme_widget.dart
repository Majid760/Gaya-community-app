import 'package:flutter/material.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:get/get.dart';

class CreateCommunityThemeWidget extends StatelessWidget {
  const CreateCommunityThemeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          GayaStrings.create_first_post.tr,
          style: CustomTypography.bodyStyle,
        ),
        const SizedBox(
          height: distance_10,
        ),
        Text(
          GayaStrings.welcome_create_first_post.tr,
          style: CustomTypography.secondaryFontStyleWeight,
        ),
        const SizedBox(
          height: distance_12,
        ),
      ],
    );
  }
}
