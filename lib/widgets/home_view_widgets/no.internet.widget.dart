import 'package:flutter/material.dart';

import '../../utils/strings.dart';
import '../../utils/textstyles.dart';

class NoInternetWidget extends StatelessWidget {
  const NoInternetWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                noInternet,
              style: CustomTypography.headingStyle,
            ),
              const SizedBox(
                height: 10,
              ),
              Text(
                sureInternet,
              style: CustomTypography.secondaryFontStyleWeight,
              textAlign: TextAlign.center,
            ),
            ],
          ),
        ),
      );
  }
}