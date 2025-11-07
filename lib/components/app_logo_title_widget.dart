import 'package:flutter/material.dart';
import 'package:gaya/utils/const.dart';

import '../gen/assets.gen.dart';

class GayaLogo extends StatelessWidget {
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const GayaLogo({Key? key, this.height, this.width, this.padding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(left: distance_20),
      child: Image.asset(Assets.assets.images.gayaLogo.path, cacheHeight: 150, cacheWidth: 150, height: height, width: width),
    );
  }
}
