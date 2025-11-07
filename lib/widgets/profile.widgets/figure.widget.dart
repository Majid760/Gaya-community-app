import 'package:flutter/material.dart';

import '../../utils/const.dart';
import '../../utils/textstyles.dart';

class FiguresWidget extends StatelessWidget {
  final String number;
  final String title;
  final Widget? flower;
  const FiguresWidget({
    Key? key,
    required this.number,
    required this.title,
    this.flower,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(number, style: CustomTypography.body2StyleWeightBlack),
            const SizedBox(width: distance_5),
            flower ?? const SizedBox(),
          ],
        ),
        const SizedBox(height: distance_5),
        Text(
          title,
          style: CustomTypography.body4Style,
        ),
      ],
    );
  }
}
