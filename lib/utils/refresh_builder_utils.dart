import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

class RefreshBuilderUtils {
  static CupertinoFooter get footer => const CupertinoFooter(
        position: IndicatorPosition.locator,
        userWaterDrop: false,
        emptyWidget: SizedBox(),
      );

  static CupertinoHeader get header => const CupertinoHeader(
        position: IndicatorPosition.locator,
        userWaterDrop: false,
        safeArea: true,
        triggerOffset: 40,
        hapticFeedback: true,
        triggerWhenRelease: true,
        emptyWidget: SizedBox(),
      );

  static CupertinoFooter get footerAbove => const CupertinoFooter(
        position: IndicatorPosition.above,
        userWaterDrop: false,
        emptyWidget: SizedBox(),
      );

  static CupertinoHeader get headerAbove => const CupertinoHeader(
        position: IndicatorPosition.above,
        userWaterDrop: false,
        safeArea: true,
        triggerOffset: 40,
        hapticFeedback: true,
        emptyWidget: SizedBox(),
      );
}