import 'package:flutter/material.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:get/get.dart';

import '../../utils/const.dart';
import '../../utils/textstyles.dart';

class TimingWidget extends StatelessWidget {
  final String title;
  final String time;
  final VoidCallback onTap;
  const TimingWidget({
    Key? key,
    required this.title,
    required this.time,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: CustomTypography.bodyStyle,
        ),
        Spacer(),
        GestureDetector(
          onTap: onTap,

          //  createRecipeController.gettimer(context);

          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: distance_10, horizontal: distance_20),
            decoration: BoxDecoration(
              color: kBaseGrey,
              borderRadius: BorderRadius.circular(borderRadius_4),
            ),
            child: Text(
              '$time ${GayaStrings.min.tr}',
              style: CustomTypography.bodyStyle,
            ),
          ),
        ),
      ],
    );
  }
}
