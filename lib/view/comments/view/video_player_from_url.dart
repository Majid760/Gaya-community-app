// play video from url

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gaya/utils/const.dart';
import 'package:video_player/video_player.dart';

import '../../../components/gaya_play_button.dart';

class VideoPlayerFromUrl extends StatefulWidget {
  const VideoPlayerFromUrl({Key? key, required this.url, this.localFile}) : super(key: key);
  final String url;
  final File? localFile;

  @override
  State<VideoPlayerFromUrl> createState() => _VideoPlayerFromUrlState();
}

class _VideoPlayerFromUrlState extends State<VideoPlayerFromUrl> {
  late VideoPlayerController controller;
  String videoUrl = '';

  @override
  void initState() {
    super.initState();
    videoUrl = widget.url;
    controller = widget.localFile != null ? VideoPlayerController.file(widget.localFile!) : VideoPlayerController.network(videoUrl);
    controller.addListener(() {
      setState(() {});
    });
    controller.setLooping(false);
    controller.initialize().then((_) => setState(() {}));
    // controller.play();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBlackColor,
      body: InkWell(
        onTap: () {
          if (controller.value.isPlaying) {
            controller.pause();
          } else {
            controller.play();
          }
        },
        child: Container(
          height: MediaQuery.sizeOf(context).height,
          child: Stack(alignment: Alignment.center, children: [
            VideoPlayer(controller),
            controller.value.isPlaying
                ? IconButton(
                    onPressed: () async => await controller.pause(), icon: const Icon(Icons.pause, color: kWhiteColor), iconSize: 50)
                : IconButton(
                    onPressed: () async => controller.play(), icon: const Icon(Icons.play_arrow, color: kWhiteColor), iconSize: 50),
            Positioned(
                bottom: 10,
                width: MediaQuery.sizeOf(context).width / 1.5,
                child: VideoProgressIndicator(
                  controller,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                      backgroundColor: Colors.blueGrey, bufferedColor: kprimaryColorLight, playedColor: kprimaryColor),
                ))
          ]),
        ),
      ),
    );
  }
}

//  videoplayer from url with  backbutton
class VideoPlayerWithBackButtonFromUrl extends StatefulWidget {
  const VideoPlayerWithBackButtonFromUrl({Key? key, required this.url, this.localFile}) : super(key: key);
  final String url;
  final File? localFile;
  @override
  State<VideoPlayerWithBackButtonFromUrl> createState() => _VideoPlayerWithBackButtonFromUrlState();
}

class _VideoPlayerWithBackButtonFromUrlState extends State<VideoPlayerWithBackButtonFromUrl> {
  late VideoPlayerController controller;
  String videoUrl = '';

  @override
  void initState() {
    super.initState();
    videoUrl = widget.url;
    controller = widget.localFile != null ? VideoPlayerController.file(widget.localFile!) : VideoPlayerController.network(videoUrl);
    controller.addListener(() {
      setState(() {});
    });
    controller.setLooping(false);
    controller.initialize().then((_) => setState(() {}));
    controller.play();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: true, backgroundColor: kBlackColor, elevation: 0),
      body: Container(
        color: kBlackColor,
        child: Stack(alignment: Alignment.center, children: [
          InkWell(onTap: () => controller.value.isPlaying ? controller.pause() : controller.play(), child: VideoPlayer(controller)),
          controller.value.isPlaying
              ? const SizedBox.shrink()
              : GayaPlayButtonWidget(iconPath: "Assets/icons/play_button.svg", onClick: () async => controller.play()),
          Positioned(
              bottom: 20,
              width: MediaQuery.sizeOf(context).width / 1.5,
              child: VideoProgressIndicator(
                controller,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                    backgroundColor: Colors.blueGrey, bufferedColor: kprimaryColorLight, playedColor: kprimaryColor),
              ))
        ]),
      ),
    );
  }
}
