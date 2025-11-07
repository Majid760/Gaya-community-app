import 'package:flutter/material.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_typography.dart';

class TitleAndSubtitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const TitleAndSubtitle({Key? key, required this.title, required this.subtitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GayaTypography.titleMedium.copyWith(height: 1.18)),
        Text(subtitle, style: GayaTypography.subtitleRegular.copyWith(color: AppColors.secondary, height: 1.54)),
      ],
    );
  }
}