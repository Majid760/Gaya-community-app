import 'package:flutter/material.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:get/get.dart';

import '../utils/const.dart';
import '../utils/textstyles.dart';

DialogueC(
  final String name,
  final Function()? unfriend,
  final BuildContext context,
) =>
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("${GayaStrings.cancel_friend_txt.tr} $name ?"),
        content: Row(
          children: [
            Expanded(
              child: GayaButton(
                primaryColor: AppColors.primary,
                title: GayaStrings.yes_txt.tr,
                textStyle: CustomTypography.body4StyleWhite,
                borderColor: const Color.fromRGBO(255, 255, 255, 0.0),
                height: 40,
                width: double.infinity,
                onPressed: unfriend,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
                child: GayaButton(
                  primaryColor: kSecondaryColor,
              title: GayaStrings.no_txt.tr,
              textStyle: CustomTypography.body4StyleWhite,
              borderColor: const Color.fromRGBO(255, 255, 255, 0.0),
              height: 40,
              width: double.infinity,
              onPressed: () {
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
