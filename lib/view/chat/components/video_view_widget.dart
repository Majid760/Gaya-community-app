import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gaya/services/media_cropping/view/video_editor_screen/video_player_view.dart';

class VideoViewWidget extends StatelessWidget {
  const VideoViewWidget(
      {Key? key, this.isVideo = false, required this.mediaFile, this.height = 120, this.width = 100})
      : super(key: key);
  final bool isVideo;
  final File mediaFile;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
              width: width,
              height: height,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  image: isVideo ? null : DecorationImage(image: FileImage(mediaFile), fit: BoxFit.cover)),
              child: isVideo ? ClipRRect(borderRadius: BorderRadius.circular(8), child: VideoPlayScreen(video: mediaFile)) : null),
        ),
      ],
    );
  }
}
