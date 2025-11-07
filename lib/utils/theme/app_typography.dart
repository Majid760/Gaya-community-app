/// TO Calculate Line Height Of Text from FIGMA
/// LINE HEIGHT formula  = (line-height/fontSize)
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/textstyles.dart';

import '../const.dart';
import 'app_colors.dart';

class GayaTypography {
  // headers
  static final h1 = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 28.8.sp,
      color: AppColors.black,
      height: 1.5,
      letterSpacing: 0.2,
      fontFamily: GayaFontTheme.primaryFont);
  static final h2 = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 25.63.sp,
      color: AppColors.black,
      height: 1.5,
      letterSpacing: 0.4,
      fontFamily: GayaFontTheme.primaryFont);

  static final h3 = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 22.78.sp,
      color: AppColors.black,
      height: 1.5,
      letterSpacing: 0.4,
      fontFamily: GayaFontTheme.primaryFont);

  static final h4 = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 20.25.sp,
      color: AppColors.black,
      height: 1.2,
      letterSpacing: 0.4,
      fontFamily: GayaFontTheme.primaryFont);

  static final body2 =
      TextStyle(fontWeight: FontWeight.w400, fontSize: 16.sp, color: AppColors.black, height: 1.8, fontFamily: GayaFontTheme.primaryFont);

  // titles
  static final titleMedium = TextStyle(
      fontWeight: FontWeight.w500, fontSize: 16.sp, color: AppColors.black, letterSpacing: 0.2, fontFamily: GayaFontTheme.primaryFont);

  static final title = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16.sp,
    color: AppColors.black,
    letterSpacing: 0.4,
    fontFamily: GayaFontTheme.primaryFont,
  );

  static final titleSemiBold = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 16.sp,
      color: AppColors.black,
      height: 1.5,
      letterSpacing: 0.2,
      fontFamily: GayaFontTheme.primaryFont);

  // texts
  static final text = TextStyle(
      fontWeight: FontWeight.w400, fontSize: 16.sp, color: AppColors.black, letterSpacing: 0.2, fontFamily: GayaFontTheme.primaryFont);

  // subtitles
  static final subtitleRegular = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14.22.sp,
    color: AppColors.black,
    letterSpacing: 0.1,
    fontFamily: GayaFontTheme.primaryFont,
  );

  static final subtitleMedium = TextStyle(
      fontWeight: FontWeight.w500, fontSize: 14.22.sp, color: AppColors.black, letterSpacing: 0.1, fontFamily: GayaFontTheme.primaryFont);

  // captions
  static final caption = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 12.64.sp,
    color: AppColors.black,
    height: 0.702,
    letterSpacing: 0.3,
    fontFamily: GayaFontTheme.primaryFont,
  );

  static final captionMedium = TextStyle(
      fontWeight: FontWeight.w500, fontSize: 12.sp, color: AppColors.black, letterSpacing: 0.3, fontFamily: GayaFontTheme.primaryFont);

  static final caption2 = TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 11.24.sp,
      color: AppColors.black,
      height: 0.51,
      letterSpacing: 0.3,
      fontFamily: GayaFontTheme.primaryFont);

  static final caption2Medium = TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 12.64.sp,
      color: AppColors.black,
      height: 1.424,
      letterSpacing: 0.3,
      fontFamily: GayaFontTheme.primaryFont);
  static final caption4Medium = TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 18.sp,
      color: AppColors.white,
      height: 1.2,
      letterSpacing: 0.2,
      fontFamily: GayaFontTheme.primaryFont);

  static final caption3 = TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 10.sp,
      color: AppColors.black,
      height: 2,
      letterSpacing: 0.2,
      fontFamily: GayaFontTheme.primaryFont);

  static final caption3Medium = TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 10.sp,
      color: AppColors.black,
      height: 0.45,
      letterSpacing: 0.2,
      fontFamily: GayaFontTheme.primaryFont);
}

class CustomTypography {
  CustomTypography();

  static final TextStyle superTitleStyle = TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 36.sp,
      color: AppColors.black,
      height: 0.84,
      letterSpacing: 0.2,
      fontFamily: GayaFontTheme.primaryFont);

  static final title24W600 = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 24.sp,
      color: AppColors.black,
      height: 1.7,
      letterSpacing: 0.2,
      fontFamily: GayaFontTheme.primaryFont);
  static final TextStyle community = TextStyle(
      fontWeight: FontWeight.w500, fontSize: 12.sp, color: AppColors.black, letterSpacing: 0.2, fontFamily: GayaFontTheme.primaryFont);

  static final TextStyle postCaptionStyle = TextStyle(
      fontSize: 14.sp,
      fontFamily: GayaFontTheme.primaryFont,
      fontFamilyFallback: DeviceCheck.isIOS ? [] : [GayaFontTheme.fallBackFont],
      height: 1.5);

  static final TextStyle badgeTextStyle = TextStyle(fontSize: 12.sp, fontFamily: GayaFontTheme.primaryFont, height: 1);

  static final TextStyle modalSheetTitleStyle = GayaTypography.text.copyWith(height: 1.13);

  static final TextStyle bodyStyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 16.sp,
    fontFamily: GayaFontTheme.primaryFont,
    color: AppColors.black,
  );

  static final TextStyle headingStyle =
      TextStyle(fontWeight: FontWeight.w700, fontSize: 24.sp, fontFamily: GayaFontTheme.primaryFont, color: AppColors.black);

  static final TextStyle headingStyle24 =
      TextStyle(fontWeight: FontWeight.w600, fontSize: 24.sp, fontFamily: GayaFontTheme.primaryFont, color: AppColors.black);

  static final TextStyle headingStyle24Purple = headingStyle24.copyWith(color: const Color(0xFF8500D6));

  static final TextStyle subHeading =
      TextStyle(fontWeight: FontWeight.w600, fontSize: 20.sp, fontFamily: GayaFontTheme.primaryFont, color: AppColors.black);

  static final TextStyle bodyStyle18 =
      TextStyle(fontWeight: FontWeight.w500, fontSize: 18.sp, fontFamily: GayaFontTheme.primaryFont, color: AppColors.black);

  static final TextStyle bodyStyle17 = TextStyle(
      fontWeight: FontWeight.w400, fontSize: 18.sp, fontFamily: GayaFontTheme.primaryFont, color: kSecondaryColor, letterSpacing: -0.41);

  static final TextStyle body1Style =
      TextStyle(fontWeight: FontWeight.w500, height: 1.5, fontSize: 16.sp, color: kSecondaryColor, fontFamily: GayaFontTheme.primaryFont);

  static final TextStyle body2Style =
      TextStyle(fontWeight: FontWeight.w500, fontFamily: GayaFontTheme.primaryFont, fontSize: 16.sp, color: kWhiteColor);
  static final TextStyle body2StyleWeight = body2Style.copyWith(fontWeight: FontWeight.w600);
  static final TextStyle body2StyleWeightkPrimary = body2StyleWeight.copyWith(color: kprimaryColor);
  static final TextStyle body2StyleWeightBlack = body2StyleWeight.copyWith(color: kBlackColor);
  static final TextStyle body2StyleWeighGrey = body2StyleWeight.copyWith(color: disableColor);

  static final TextStyle body2DisableStyle = body2Style.copyWith(color: disableColor);
  static final TextStyle body2EnableStyle = body2Style.copyWith(color: kWhiteColor);
  static final TextStyle body2EnableStyle1 = body2Style.copyWith(color: kBlackColor);

  static final TextStyle body4Style =
      TextStyle(fontWeight: FontWeight.w500, fontSize: 14.sp, fontFamily: GayaFontTheme.primaryFont, color: kBlackColor);
  static final TextStyle body4StyleLowWeight = body4Style.copyWith(fontWeight: FontWeight.w400);
  static final TextStyle body4StyleHeight = body4Style.copyWith(height: 1.5);
  static final TextStyle body4StyleWhite = body4Style.copyWith(color: kWhiteColor);
  static final TextStyle body4StyleBlack = body4Style.copyWith(color: kBlackColor);
  static final TextStyle body4KStylePrimary = body4Style.copyWith(color: kprimaryColor);
  static final TextStyle body4StyleWhiteLessWeight = body4StyleLowWeight.copyWith(color: kWhiteColor);
  static final TextStyle body4StyleWhiteMoreWeight = body4StyleWhite.copyWith(fontWeight: FontWeight.w600);
  static final TextStyle body4StyleLessWeight = body4StyleHeight.copyWith(color: kBlackColor, fontWeight: FontWeight.w400);

  static final TextStyle secondaryFontStyleBig =
      TextStyle(fontWeight: FontWeight.w500, fontFamily: GayaFontTheme.primaryFont, fontSize: 15.sp, color: kBlackColor);
  static final TextStyle secondaryFontStyle =
      TextStyle(fontWeight: FontWeight.w500, fontSize: 14.sp, fontFamily: GayaFontTheme.primaryFont, color: kSecondaryColor);
  static final TextStyle secondaryFontStyleWeight = secondaryFontStyle.copyWith(fontWeight: FontWeight.w400);
  static final TextStyle secondaryFontStyleWeightHeightlow = secondaryFontStyle.copyWith(height: 1.5);
  static final TextStyle secondaryFontStyleWeightHeight = secondaryFontStyle.copyWith(fontWeight: FontWeight.w400, height: 2);

  static final TextStyle unreadStyle =
      TextStyle(fontWeight: FontWeight.w500, height: 1.52, fontSize: 14.22.sp, fontFamily: GayaFontTheme.primaryFont, color: kBlackColor);

  static final TextStyle body3Style =
      TextStyle(fontWeight: FontWeight.w500, fontSize: 12.sp, fontFamily: GayaFontTheme.primaryFont, color: kSecondaryColor);
  static final TextStyle body3MStyle = body3Style.copyWith(fontWeight: FontWeight.w400);

  static final TextStyle titleStyleWhite =
      TextStyle(fontWeight: FontWeight.w500, fontSize: 12.sp, fontFamily: GayaFontTheme.primaryFont, color: kWhiteColor);
  static final TextStyle titleStyleWhiteWeight = titleStyleWhite.copyWith(fontWeight: FontWeight.w600);
  static final TextStyle titleStyleBlack = titleStyleWhite.copyWith(fontWeight: FontWeight.w600, color: kBlackColor);

  static final TextStyle yellowebodyStyle =
      TextStyle(fontWeight: FontWeight.w400, fontSize: 12.sp, fontFamily: GayaFontTheme.primaryFont, color: kYellowColor);
  static final TextStyle dark12 =
      TextStyle(fontWeight: FontWeight.w500, fontSize: 12.sp, fontFamily: GayaFontTheme.primaryFont, color: kBlackColor);
  static final TextStyle darkWhite12 = dark12.copyWith(color: kWhiteColor);

  static final TextStyle analyticsPercentageRed =
      TextStyle(fontWeight: FontWeight.w500, fontSize: 10.sp, fontFamily: GayaFontTheme.primaryFont, color: const Color(0xFFFF3B30));
  static final TextStyle analyticsPercentageGreen = analyticsPercentageRed.copyWith(color: const Color(0xFF34C759));
  static final TextStyle analyticsPercentageGrey = analyticsPercentageRed.copyWith(color: const Color(0xFF8E8E93));

  static final TextStyle searchTabBarInactive =
      TextStyle(fontWeight: FontWeight.w500, fontSize: 14.22.sp, fontFamily: GayaFontTheme.primaryFont, color: AppColors.secondary);
  static final TextStyle searchTabBarActive = searchTabBarInactive.copyWith(color: const Color(0xFF8500D6));

  static final TextStyle linkStyle = body4StyleLessWeight.copyWith(color: kLinkColor);
  static final TextStyle hashTagStyle = body4StyleLessWeight.copyWith(color: kHashTagColor);
  static final TextStyle atTheRateTagStyle = body4StyleLessWeight.copyWith(color: kHashTagColor);
}

class DeviceCheck {
  static bool get isIOS {
    if (kIsWeb) {
      return false;
    } else {
      return Platform.isIOS;
    }
  }

  static bool get isAndroid {
    if (kIsWeb) {
      return false;
    } else {
      return Platform.isAndroid;
    }
  }

  static bool get isWeb {
    return kIsWeb;
  }
}
