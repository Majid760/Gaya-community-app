import 'package:flutter/material.dart';

import '../../../../utils/theme/app_spaces.dart';
import 'analytics_tile.dart';

class EmptyStructure extends StatelessWidget {
  const EmptyStructure({super.key});

  @override
  Widget build(BuildContext context) {
    /* -------------------------------------------------------------------------- */
    /*                            main row widget [Row]                           */
    /* -------------------------------------------------------------------------- */
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              const AnalyticsTile(
                child: SizedBox(
                  height: 50.0,
                ),
              ),
              MySpaces.gap3y,
              const AnalyticsTile(
                child: SizedBox(
                  height: 80.0,
                ),
              ),
              MySpaces.gap3y,
              const AnalyticsTile(
                child: SizedBox(
                  height: 60.0,
                ),
              ),
              MySpaces.gap3y,
              const AnalyticsTile(
                child: SizedBox(
                  height: 60.0,
                ),
              ),
              MySpaces.gap3y,
              const AnalyticsTile(
                child: SizedBox(
                  height: 40.0,
                ),
              ),
            ],
          ),
        ),
        MySpaces.gap3x,
        Expanded(
          child: Column(
            children: [
              const AnalyticsTile(
                child: SizedBox(
                  height: 60.0,
                ),
              ),
              MySpaces.gap3y,
              const AnalyticsTile(
                child: SizedBox(
                  height: 60.0,
                ),
              ),
              MySpaces.gap3y,
              const AnalyticsTile(
                child: SizedBox(
                  height: 60.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
