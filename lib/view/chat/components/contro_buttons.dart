import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/const.dart';
import 'package:just_audio/just_audio.dart';

class ControlButtons extends StatelessWidget {
  final AudioPlayer player;

  const ControlButtons(this.player, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: player.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;
        if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
          return Icon(Icons.play_arrow, color: kprimaryColor, size: 32.r);
          // SizedBox(width: 24.w, height: 24.h);
          // return SizedBox(
          //   width: 24.w,
          //   height: 24.h,
          //   child: const CircularProgressIndicator(strokeWidth: 1),
          // );
        } else if (playing != true) {
          // return const Icon(Icons.play_arrow, color: AppColors.blue);
          return GestureDetector(onTap: player.play, child: Icon(Icons.play_arrow, color: kprimaryColor, size: 32.r));
        } else if (processingState != ProcessingState.completed) {
          // return const Icon(Icons.play_arrow, color: AppColors.blue);
          return GestureDetector(onTap: player.pause, child: Icon(Icons.pause, color: kprimaryColor, size: 32.r));
        } else {
          // return const Icon(Icons.play_arrow, color: AppColors.blue);
          return GestureDetector(
            child: Icon(Icons.play_arrow, color: kprimaryColor, size: 32.r),
            onTap: () => player.seek(Duration.zero),
          );
        }
      },
    );
  }
}
