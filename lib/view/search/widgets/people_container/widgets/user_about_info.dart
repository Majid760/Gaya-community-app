import 'package:flutter/material.dart';

import '../../../../../utils/const.dart';
import '../../../../../utils/gaya_text_widget.dart';
import '../../../../../utils/methods.dart';
import '../../../../../utils/theme/app_typography.dart';

class UserAboutInfo extends StatelessWidget {
  const UserAboutInfo({
    super.key,
    required this.about,
  });

  final String about;

  @override
  Widget build(BuildContext context) {
    /* -------------------------------------------------------------------------- */
    /*                          main align widget [Align]                          */
    /* -------------------------------------------------------------------------- */
    return Align(
      alignment: Methods.isRTL(about) ? Alignment.centerRight : Alignment.centerLeft,
      /* ------------------------------- about text ------------------------------- */
      child: GayaTextWidget(
        about,
        style: GayaTypography.caption,
        colorClickableText: kprimaryColor,
        shouldIgnoreHashTag: false,
        trimLines: 2,
        trimLength: 76,
      ),
    );
  }
}
