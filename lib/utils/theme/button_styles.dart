import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../const.dart';

class GayaButtonStyles {
  // comments/ reply
  static final actionRowTextButtonStyle = TextButton.styleFrom(
    tapTargetSize: MaterialTapTargetSize.padded,
    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
    foregroundColor: kSecondaryColor,
    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0).r,
  );
  // home post widget
  static final actionRowTextButtonStyle2 = TextButton.styleFrom(
    tapTargetSize: MaterialTapTargetSize.padded,
    foregroundColor: kSecondaryColor,
    padding: const EdgeInsets.symmetric(horizontal: 2).r,
  );

  // comments dialog reply with 0 paddings
  static final actionRowTextButtonStyleForCommentsDialog = TextButton.styleFrom(
    tapTargetSize: MaterialTapTargetSize.padded,
    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
    foregroundColor: kSecondaryColor,
    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0).r,
  );

  // comments dialog reply with minimum paddings
  static final actionRowTextButtonStyleForCommentsDialogReply = TextButton.styleFrom(
    tapTargetSize: MaterialTapTargetSize.padded,
    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
    foregroundColor: kSecondaryColor,
    padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 0).r,
  );
}
