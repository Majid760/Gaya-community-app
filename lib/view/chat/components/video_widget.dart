import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gaya/utils/const.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoWidget extends StatefulWidget {
  final String videoLink;

  const VideoWidget({super.key, required this.videoLink});

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      widget.videoLink,
    )..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller?.dispose();
    }
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.videoLink),
      onVisibilityChanged: (VisibilityInfo info) {
        debugPrint("${info.visibleFraction} of my widget is visible");
        if (info.visibleFraction == 0 && _controller != null) {
          _controller?.pause();
        }
      },
      child: _controller == null
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kprimaryColor),
              ),
            )
          : Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius_8),
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  ),
                ),
                _controller!.value.isPlaying
                    ? AnimatedOpacity(
                        duration: const Duration(seconds: 3),
                        opacity: _controller!.value.isPlaying ? 1 : 0,
                        child: IconButton(
                          icon: const Icon(
                            Icons.pause,
                            color: kTransparentColor,
                          ),
                          iconSize: 50,
                          onPressed: () {
                            print("pause");
                            _controller!.pause().then((value) => setState(() {}));
                          },
                        ))
                    : IconButton(
                        icon: SvgPicture.asset(
                          "Assets/icons/play_button.svg",
                        ),
                        iconSize: 50,
                        onPressed: () {
                          print("play");
                          _controller?.setLooping(true);
                          _controller!.play().then((value) => setState(() {}));
                        },
                      ),
                Positioned(
                    bottom: 10,
                    width: MediaQuery.sizeOf(context).width / 1.5,
                    child: VideoProgressIndicator(
                      _controller!,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                          backgroundColor: Colors.blueGrey, bufferedColor: kprimaryColorLight, playedColor: kprimaryColor),
                    ))
              ],
            ),
    );
  }
}
