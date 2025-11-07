import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/assets_icons.dart';

import 'asset_images.dart';
import 'theme/app_colors.dart';

/// Enum for the type of snack-bar
enum GayaSnackBarType { communities, link, pin, problem, save, other, notification, error, send, success, waiting }

class SnackBarUtils {
  /// Returns the text color for the snack-bar
  /// based on the type of snack-bar, Default is black
  static Color textColor({GayaSnackBarType type = GayaSnackBarType.other}) {
    switch (type) {
      case GayaSnackBarType.error:
        return AppColors.white;
      default:
        return AppColors.black;
    }
  }

  /// Returns the background color for the snack-bar
  /// based on the type of snack-bar, Default is white
  static Color backgroundColor({GayaSnackBarType type = GayaSnackBarType.other}) {
    switch (type) {
      case GayaSnackBarType.error:
        return AppColors.error;
      default:
        return AppColors.white;
    }
  }

  /// Returns the icon for the snack-bar
  /// based on the type of snack-bar

  static Widget? getIconByType({required GayaSnackBarType type}) {
    double size = 20.r;
    switch (type) {
      case GayaSnackBarType.communities:
        return SvgIcons.communitiesIcon(height: size, width: size);
      case GayaSnackBarType.link:
        return SvgIconWidget.linkOutline1();
      case GayaSnackBarType.pin:
        return SvgIconWidget.pinOutlinee(height: size, width: size);
      case GayaSnackBarType.problem:
        return SvgIcons.problem(height: size, width: size);
      case GayaSnackBarType.save:
        return SvgIconWidget.bookmarkOutline(height: size, width: size);
      case GayaSnackBarType.notification:
        return SvgIconWidget.bellOutline1(height: size, width: size);
      case GayaSnackBarType.send:
        return SvgIconWidget.sendOutline(height: size, width: size);
      case GayaSnackBarType.success:
        return Icon(Icons.check_circle_outline, color: AppColors.primary, size: size);
      case GayaSnackBarType.error:
        return Icon(Icons.error_outline, color: AppColors.white, size: size);
      case GayaSnackBarType.waiting:
        return CupertinoActivityIndicator(color: AppColors.black);
      default:
        return null;
    }
  }
}
