import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaya/components/gaya_play_button.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../controller/create.post.controller.dart';
import '../../utils/const.dart';

class VideoPlayerWidget extends StatelessWidget {
  final CreatePostController controller;

  const VideoPlayerWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius_8),
          child: AspectRatio(
            aspectRatio: controller.videoPlayerController!.value.aspectRatio,
            child: VideoPlayer(
              controller.videoPlayerController!,
            ),
          ),
        ),
        controller.isVideoPlaying == true
            ? IconButton(
                icon: const Icon(Icons.pause, color: kWhiteColor),
                iconSize: 50,
                onPressed: () {
                  controller.videoPlayerController!.pause();
                  controller.isPlaying();
                },
              )
            : GayaPlayButtonWidget(
                onClick: () {
                  controller.videoPlayerController!.play();
                  controller.isPlaying();
                },
              ),
        Positioned(
            top: 10,
            right: 10,
            child: InkWell(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.black, size: 14),
              ),
              onTap: () {
                // controller.videoPlayerController.dispose();
                controller.removeVideoFromNewPost();
                // createPostController.removeNewPostmediaItem(index);
              },
            )),
        Positioned(
            bottom: 10,
            width: MediaQuery.sizeOf(context).width / 1.5,
            child: VideoProgressIndicator(
              controller.videoPlayerController!,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                  backgroundColor: Colors.blueGrey, bufferedColor: kprimaryColorLight, playedColor: kprimaryColor),
            ))
      ],
    );
  }
}

class HomePostVideoCustom extends StatefulWidget {
  final String videoLink;

  const HomePostVideoCustom({super.key, required this.videoLink});

  @override
  State<HomePostVideoCustom> createState() => _HomePostVideoCustomState();
}

class _HomePostVideoCustomState extends State<HomePostVideoCustom> {
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
                            _controller!.pause().then((value) => setState(() {}));
                          },
                        ))
                    : IconButton(
                        icon: SvgPicture.asset("Assets/icons/play_button.svg"),
                        iconSize: 50,
                        onPressed: () {
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

//old devs work
class HomePostVideo extends StatefulWidget {
  final double asceptRatio;
  final List<VideoPlayerController> controller;

  final String videoLink;

  const HomePostVideo({super.key, required this.asceptRatio, required this.controller, required this.videoLink});

  @override
  State<HomePostVideo> createState() => _HomePostVideoState();
}

class _HomePostVideoState extends State<HomePostVideo> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius_8),
          child: AspectRatio(
            aspectRatio: widget.asceptRatio,
            child: VideoPlayer(
              widget.controller[context.read<CreatePostController>().currentVideoIndex],
            ),
          ),
        ),
        context
                .read<CreatePostController>()
                .homePostvideoPlayerController[context.read<CreatePostController>().currentVideoIndex]
                .value
                .isPlaying
            ? IconButton(
                icon: const Icon(
                  Icons.pause,
                  color: kWhiteColor,
                ),
                iconSize: 50,
                onPressed: () {
                  widget.controller[context.read<CreatePostController>().currentVideoIndex].pause();
                },
              )
            : IconButton(
                icon: const Icon(
                  Icons.play_arrow,
                  color: kWhiteColor,
                ),
                iconSize: 50,
                onPressed: () {
                  widget.controller[context.read<CreatePostController>().currentVideoIndex].play();
                },
              ),
        Positioned(
            bottom: 10,
            width: MediaQuery.sizeOf(context).width / 1.5,
            child: VideoProgressIndicator(
              widget.controller[context.read<CreatePostController>().currentVideoIndex],
              allowScrubbing: true,
              colors: const VideoProgressColors(
                  backgroundColor: Colors.blueGrey, bufferedColor: kprimaryColorLight, playedColor: kprimaryColor),
            ))
      ],
    );
  }
}

class VideoAssetPlayer extends StatefulWidget {
  final String assetPath;

  final Widget? onLoading;

  const VideoAssetPlayer({super.key, required this.assetPath, this.onLoading});

  @override
  State<VideoAssetPlayer> createState() => _VideoAssetPlayerState();
}

class _VideoAssetPlayerState extends State<VideoAssetPlayer> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
      widget.assetPath,
    )..initialize().then((_) {
        _controller?.setVolume(0);
        _controller?.play();
        _controller?.setLooping(true);
        setState(() {});
      }).catchError((e) {
        _controller = null;
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
    return AnimatedSwitcher(
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        duration: const Duration(milliseconds: 100),
        child: _controller == null
            ? widget.onLoading ?? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kprimaryColor)))
            : VideoPlayer(_controller!));
  }
}
