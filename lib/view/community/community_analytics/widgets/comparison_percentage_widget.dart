import 'package:flutter/material.dart';

import '../../../../utils/textstyles.dart';

class ComparisonPercentage extends StatelessWidget {
  const ComparisonPercentage({
    super.key,
    required this.percentage,
    required this.fromTimeDuration,
  });

  final double percentage;
  final String fromTimeDuration;

  @override
  Widget build(BuildContext context) {
    /* -------------------------------------------------------------------------- */
    /*                            main row widget [Row]                           */
    /* -------------------------------------------------------------------------- */
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /* -------------------------------------------------------------------------- */
        /*                          arrow icon [Image.asset]                          */
        /* -------------------------------------------------------------------------- */
        Image.asset(
          percentage >= 0.0
              ? r'Assets/icons/ic_green_arrow_up.png'
              : r'Assets/icons/ic_red_arrow_down.png',
          width: 20.0,
          height: 20.0,
        ),
        const SizedBox(width: 10.0),
        /* ---------------------------- percentage [Text] --------------------------- */
        Text(
          '${percentage >= 0.0 ? '+' : ''}${percentage.toStringAsFixed(2)}% ',
          style: percentage >= 0.0 ? CustomTypography.analyticsPercentageGreen : CustomTypography.analyticsPercentageRed,
        ),
        /* ----------------------------- vs time [Text] ----------------------------- */
        Expanded(
          child: Text(
            fromTimeDuration,
            style: CustomTypography.analyticsPercentageGrey,
          ),
        ),
      ],
    );
  }
}
