import 'package:flutter/cupertino.dart';

class MyColorHex {
  MyColorHex();

  // black shades
  final Color black = const Color(0xFF000000);
  final Color blackShade2 = const Color(0xFF8E8E93);
  final Color blackShade3 = const Color(0xFFAEAEB2);
  final Color blackShade4 = const Color(0xFFC7C7CC);
  final Color blackShade5 = const Color(0xFFEBEBF0);
  final Color white = const Color(0xFFFFFFFF);

  // primary shades
  final Color primary = const Color(0xFF39005C);
  final Color primaryShade2 = const Color(0xFF7A24FF);
  final Color primaryShade3 = const Color(0xFF8133F1);
  final Color primaryShade4 = const Color(0xFFD28AFF);
  final Color primaryShade5 = const Color(0xFFEFE6FD);
  final Color primaryShade6 = const Color(0xFFECDDFF);

  // secondary shades
  final Color secondary = const Color(0xFF502349);
  final Color secondaryShade2 = const Color(0xFFA8569B);
  final Color secondaryShade3 = const Color(0xFFE27FD2);
  final Color secondaryShade4 = const Color(0xFFFFB5F3);
  final Color secondaryShade5 = const Color(0xFFFFF4FD);

  final Color skeleton = const Color(0xFFECF0F3);
  final Color borderColor = const Color(0xFFD1D2D6);
  final Color pollTileColor = const Color(0xFFF8F2FF);

  // custom shades
  final Color customChipColor = const Color(0xFFFFF2F1);
  final Color foundationPurple = const Color(0xFF6200EE);
}

class AppColors {
  static final MyColorHex _colors = MyColorHex();
  static final Color primary = _colors.primaryShade2;
  static final Color primary2 = _colors.primaryShade3;
  static final Color primary4 = _colors.primaryShade4;
  static final Color primary5 = _colors.primaryShade5;
  static final Color secondary = _colors.blackShade2;
  static final Color secondary2 = _colors.blackShade3;
  static final Color secondary4 = _colors.blackShade4;
  static final Color divider = _colors.blackShade5;
  static final Color primary6 = _colors.primaryShade6;
  static final Color black = _colors.black;
  static final Color black5 = _colors.blackShade5;
  static final Color white = _colors.white;
  static const Color cupertinoBlue = CupertinoColors.activeBlue;
  static const Color transparrent = Color(0x00000000);
  static final Color chipLightPink = _colors.customChipColor;
  static final Color skeleton = _colors.skeleton;
  static final Color borderColor = _colors.borderColor;
  static final Color pollTileColor = _colors.pollTileColor;
  static final Color foundationPurple = _colors.foundationPurple;

  static const Color gradientColor1 = Color(0xFF7A24FF);
  static const Color gradientColor2 = Color(0xFFFF67C6);
  static const Color gradientColor3 = Color(0xFF00FFAF);
  static const Color gradientColor4 = Color(0xFF37D8F5);
  static const Color gradientColor5 = Color(0xFF290A58);

  // warning, error, success
  static const Color success = Color(0xFF34C759);
  static const Color error = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFFFCC00);

  // influence bar blue color
  static const Color blueColor = Color(0xFF0094FF);

  // gradients
  static LinearGradient primaryGradient = const LinearGradient(
    begin: Alignment(-0.442813035, -0.974928729),
    end: Alignment(1.0, -3),
    colors: [gradientColor1, gradientColor2],
    stops: [0.123, 1.6],
    transform: GradientRotation(49.2),
  );
  static LinearGradient textGradient = const LinearGradient(
    begin: Alignment(-0.442813035, -0.974928729),
    end: Alignment(1.0, -1.0),
    colors: [gradientColor1, gradientColor2],
  );
  static LinearGradient influenceGradient = const LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    stops: [0.6, 1.0],
    colors: [
      Color(0xFF7A24FF),
      Color(0xCC00FFAF),
    ],
  );

  static LinearGradient influenceStreakFireYellowGradient = const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFEC84B), Color(0xFFF79009)],
  );
  static LinearGradient influenceStreakFireRedGradient = const LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [
      Color(0xFFFF3B30),
      Color(0xFFEDBE0A),
    ],
  );
  static LinearGradient influenceStreakFirePrimaryGradient = const LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [Color(0xFF7A24FF), Color(0xFF05F2BD)],
  );
  static LinearGradient influenceStreakFireGreenGradient = const LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [
      Color(0xFF34C759),
      Color(0xFF0AF49E),
    ],
  );
  static LinearGradient aiMatchCardGradient =   const LinearGradient(
      begin: Alignment.bottomLeft, end: Alignment.topRight,
      colors: [
    gradientColor1,
   gradientColor4,

  ]);
  static LinearGradient aiMatchCardGradient2 =   LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [
   skeleton,
    skeleton,
  ]);
  static LinearGradient aiMatchTextGradient =   const LinearGradient(

    begin: Alignment.bottomCenter,
    end: Alignment.topRight,
    colors: [
      Color.fromRGBO(122, 36, 255, 0.90),
      Color.fromRGBO(55, 216, 245, 0.90),
    ],
    stops: [0.0, 0.8],
    transform: GradientRotation(325 * 3.14159265 / 180), // Convert degrees to radians
  );
}
