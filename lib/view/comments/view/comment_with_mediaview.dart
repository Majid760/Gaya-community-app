import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gaya/services/media_cropping/view/video_editor_screen/video_player_view.dart';
import 'package:gaya/utils/const.dart';

class CommentMediaView extends StatelessWidget {
  const CommentMediaView(
      {Key? key, this.tapOnImageRemove, this.isVideo = false, required this.mediaFile, this.height = 120, this.width = 100})
      : super(key: key);
  final VoidCallback? tapOnImageRemove;
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
        Positioned(
            top: 14,
            right: 14,
            child: InkWell(
              onTap: tapOnImageRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: kBaseGrey, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.black, size: 14),
              ),
            )),
      ],
    );
  }
}
