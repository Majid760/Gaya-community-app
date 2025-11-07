import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:google_fonts/google_fonts.dart';

export 'package:gaya/utils/theme/app_typography.dart';

class GayaTheme {
  static ThemeData themeData(context) => ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(
            builders: {TargetPlatform.android: CupertinoPageTransitionsBuilder(), TargetPlatform.iOS: CupertinoPageTransitionsBuilder()}),
        fontFamily: GayaFontTheme.primaryFont,
        scaffoldBackgroundColor: kWhiteColor,
        textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: kprimaryColor)),
        textTheme: GayaFontTheme.gayaTextTheme(context),
      );
}

class GayaFontTheme {
  /// font families consts
  static const String sfProDisplay = "SFProDisplay";
  static const String notoColorEmoji = "NotoColorEmoji";

  // my font families
  static const String primaryFont = sfProDisplay;

  static const String fallBackFont = notoColorEmoji;
  static TextStyle lexendDecaFont = GoogleFonts.lexendDeca();

  static const CupertinoThemeData cupertinoApp = CupertinoThemeData(
    textTheme: CupertinoTextThemeData(
      textStyle: TextStyle(
        fontFamily: sfProDisplay,
        fontFamilyFallback: [GayaFontTheme.notoColorEmoji],
      ),
    ),
  );

  static TextTheme gayaTextTheme(BuildContext context) {
    if (kIsWeb) return Theme.of(context).textTheme;
    if (DeviceCheck.isIOS) return Theme.of(context).textTheme;
    return Theme.of(context).textTheme.copyWith(
          bodyLarge: Theme.of(context).textTheme.bodyLarge?.copyWith(fontFamilyFallback: [fallBackFont], fontFamily: primaryFont),
          bodyMedium: Theme.of(context).textTheme.bodyMedium?.copyWith(fontFamilyFallback: [fallBackFont], fontFamily: primaryFont),
          displayLarge: Theme.of(context).textTheme.displayLarge?.copyWith(fontFamilyFallback: [fallBackFont], fontFamily: primaryFont),
          displayMedium: Theme.of(context).textTheme.displayMedium?.copyWith(fontFamilyFallback: [fallBackFont], fontFamily: primaryFont),
          titleMedium: Theme.of(context).textTheme.titleMedium?.copyWith(fontFamilyFallback: [fallBackFont], fontFamily: primaryFont),
          titleSmall: Theme.of(context).textTheme.titleSmall?.copyWith(fontFamilyFallback: [fallBackFont], fontFamily: primaryFont),
        );
  }
}
