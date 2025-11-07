import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../const.dart';

class MySpaces {
  static const gap1 = 0.0;
  static const gap3 = 12.0;
  static const gap2 = 8.0;
  static const gap4 = 16.0;
  static const gap5 = 20.0;
  static const gap6 = 24.0;
  static const gap7 = 28.0;
  static const gap8 = 32.0;
  static const gap10 = 40.0;
  static const gap12 = 48.0;
  static const gap20 = 80.0;

  /// bottom space
  static Widget bottom = SizedBox(height: 10.r);

  /* -------------------------------------------------------------------------- */
  /*                              HORIZONTAL SPACES                             */
  /* -------------------------------------------------------------------------- */
  static SizedBox gap1x = const SizedBox(width: gap1);
  static SizedBox gap2x = const SizedBox(width: gap2);
  static SizedBox gap3x = const SizedBox(width: gap3);
  static SizedBox gap4x = const SizedBox(width: gap4);
  static SizedBox gap5x = const SizedBox(width: gap5);
  static SizedBox gap6x = const SizedBox(width: gap6);
  static SizedBox gap7x = const SizedBox(width: gap7);
  static SizedBox gap8x = const SizedBox(width: gap8);

  /* -------------------------------------------------------------------------- */
  /*                               VERTICAL SPACES                              */
  /* -------------------------------------------------------------------------- */
  static SizedBox gap1y = const SizedBox(height: gap1);
  static SizedBox gap2y = const SizedBox(height: gap2);
  static SizedBox gap3y = const SizedBox(height: gap3);
  static SizedBox gap4y = const SizedBox(height: gap4);
  static SizedBox gap5y = const SizedBox(height: gap5);
  static SizedBox gap6y = const SizedBox(height: gap6);
  static SizedBox gap7y = const SizedBox(height: gap7);
  static SizedBox gap8y = const SizedBox(height: gap8);
}

class MyDividers {
  static Widget postFeed = const Divider(color: kSecondaryLightColor, height: 1, thickness: 1);

  static Widget notification = const Divider(color: kSecondaryLightColor, height: 2, thickness: 1);
}
