import 'package:flutter/material.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:gaya/view/ai_daily_user_matches/controller/ai_matches_controller.dart';

class AIMatchTimer extends StatelessWidget {
  final bool showSeconds;

  const AIMatchTimer({super.key, this.showSeconds = false});

  @override
  Widget build(BuildContext context) {
    final duration = AIMatchesController.to.getTotalDurationForTweenAnimation();
    return TweenAnimationBuilder<Duration>(
        tween: Tween(begin: duration, end: Duration.zero),
        duration: duration,
        onEnd: () {
          AIMatchesController.to.fetchMyMatches(shouldRemoveMyMatchDoc: true);
        },
        builder: (BuildContext context, Duration value, Widget? child) {
          final hours = value.inHours % 24;
          final minutes = value.inMinutes % 60;
          return Text(
            '${hours.toString().padLeft(2, "0")}:${minutes.toString().padLeft(2, "0")} ',
            style: GayaTypography.titleSemiBold.copyWith(fontWeight: FontWeight.w400, fontSize: 25.63, height: 1.2, color: AppColors.white),
          );
        });
  }

 
}
