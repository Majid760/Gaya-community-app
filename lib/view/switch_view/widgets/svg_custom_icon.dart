import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgCustomIcon extends StatelessWidget {
  final String svgAssetPath;

  const SvgCustomIcon({Key? key, required this.svgAssetPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(svgAssetPath, height: 20);
  }
}
