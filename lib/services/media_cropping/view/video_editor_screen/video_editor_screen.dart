import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gaya/services/media_cropping/controller/video_editing_controller.dart';
import 'package:gaya/services/media_cropping/view/video_editor_screen/cropp_screen.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:get/get.dart';
import 'package:helpers/helpers.dart' show OpacityTransition;
import 'package:provider/provider.dart';
import 'package:video_editor/video_editor.dart';

class VideoEditorScreen extends StatelessWidget {
  const VideoEditorScreen({super.key, required this.file});
  final File file;
  final double height = 60;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<VideoEditingController>(
      create: (notifierContext) => VideoEditingController(fileTE: file),
      child: WillPopScope(
        onWillPop: () async => false,
        child: Consumer<VideoEditingController>(
          builder: (consumerContext, videoEditingCtrl, __) {
            return Scaffold(
              key: UniqueKey(),
              backgroundColor: kWhiteColor,
              body: videoEditingCtrl.controller.initialized
                  ? SafeArea(
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              SafeArea(
                                child: SizedBox(
                                  height: 60,
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: IconButton(
                                              onPressed: () => Get.back(result: videoEditingCtrl.file),
                                              icon: const Icon(Icons.arrow_back),
                                              tooltip: GayaStrings.go_back.tr)),
                                      const VerticalDivider(endIndent: 22, indent: 22),
                                      Expanded(
                                        child: IconButton(
                                            onPressed: () => videoEditingCtrl.controller.rotate90Degrees(RotateDirection.left),
                                            icon: const Icon(Icons.rotate_left),
                                            tooltip: GayaStrings.un_clockwise.tr),
                                      ),
                                      Expanded(
                                        child: IconButton(
                                            onPressed: () => videoEditingCtrl.controller.rotate90Degrees(RotateDirection.right),
                                            icon: const Icon(Icons.rotate_right),
                                            tooltip: GayaStrings.clockwise.tr),
                                      ),
                                      Expanded(
                                        child: IconButton(
                                            onPressed: () => Navigator.push(
                                                context,
                                                MaterialPageRoute<void>(
                                                    builder: (context) => CropScreen(controller: videoEditingCtrl.controller))),
                                            icon: const Icon(Icons.crop),
                                            tooltip: GayaStrings.crop_screen.tr),
                                      ),
                                      const VerticalDivider(endIndent: 22, indent: 22),
                                      Expanded(
                                        child: PopupMenuButton(
                                          tooltip: GayaStrings.export_menu.tr,
                                          icon: const Icon(Icons.save_alt_outlined),
                                          itemBuilder: (buildContext) => [
                                            PopupMenuItem(
                                                onTap: () async => await videoEditingCtrl.exportVideo(context),
                                                child:  Text(GayaStrings.export_video.tr)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: DefaultTabController(
                                  length: 2,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: TabBarView(
                                          physics: const NeverScrollableScrollPhysics(),
                                          children: [
                                            Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                CropGridViewer.preview(controller: videoEditingCtrl.controller),
                                                AnimatedBuilder(
                                                  animation: videoEditingCtrl.controller.video,
                                                  builder: (_, __) => OpacityTransition(
                                                    visible: !videoEditingCtrl.controller.isPlaying,
                                                    child: GestureDetector(
                                                      onTap: videoEditingCtrl.controller.video.play,
                                                      child: Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                                        child: const Icon(Icons.play_arrow, color: Colors.black),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            CoverViewer(controller: videoEditingCtrl.controller)
                                          ],
                                        ),
                                      ),
                                      Container(
                                        height: 200,
                                        margin: const EdgeInsets.only(top: 10),
                                        child: Column(
                                          children: [
                                            TabBar(
                                              unselectedLabelColor: Colors.blue,
                                              labelColor: kprimaryColor,
                                              indicatorColor: kprimaryColor,
                                              indicatorPadding: const EdgeInsets.symmetric(horizontal: 20),
                                              tabs: [
                                                Row(mainAxisAlignment: MainAxisAlignment.center, children:  [
                                                  const Padding(padding: EdgeInsets.all(5), child: Icon(Icons.content_cut)),
                                                  Text(GayaStrings.trim.tr)
                                                ]),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children:  [
                                                    const Padding(padding: EdgeInsets.all(5), child: Icon(Icons.video_label)),
                                                    Text(GayaStrings.cover.tr)
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Expanded(
                                              child: TabBarView(
                                                physics: const NeverScrollableScrollPhysics(),
                                                children: [
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: _trimSlider(videoEditingCtrl, context),
                                                  ),
                                                  _coverSelection(videoEditingCtrl),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ValueListenableBuilder(
                                        valueListenable: videoEditingCtrl.isExporting,
                                        builder: (_, bool export, __) => OpacityTransition(
                                          visible: export,
                                          child: AlertDialog(
                                            title: ValueListenableBuilder(
                                              valueListenable: videoEditingCtrl.exportingProgress,
                                              builder: (_, double value, __) => Text(
                                                "${GayaStrings.exporting_video.tr} ${(value * 100).ceil()}%",
                                                style: const TextStyle(fontSize: 12),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    )
                  : const Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }

  String formatter(Duration duration) =>
      [duration.inMinutes.remainder(60).toString().padLeft(2, '0'), duration.inSeconds.remainder(60).toString().padLeft(2, '0')].join(":");

  List<Widget> _trimSlider(VideoEditingController videoEditingCtrl, BuildContext context) {
    return [
      AnimatedBuilder(
        animation: Listenable.merge([
          videoEditingCtrl.controller,
          videoEditingCtrl.controller.video,
        ]),
        builder: (_, __) {
          final duration = videoEditingCtrl.controller.videoDuration.inSeconds;
          final pos = videoEditingCtrl.controller.trimPosition * duration;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: height / 4),
            child: Row(children: [
              Text(formatter(Duration(seconds: pos.toInt()))),
              const Expanded(child: SizedBox()),
              OpacityTransition(
                visible: videoEditingCtrl.controller.isTrimming,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(formatter(videoEditingCtrl.controller.startTrim)),
                  const SizedBox(width: 10),
                  Text(formatter(videoEditingCtrl.controller.endTrim)),
                ]),
              ),
            ]),
          );
        },
      ),
      Container(
        width: MediaQuery.sizeOf(context).width,
        margin: EdgeInsets.symmetric(vertical: height / 4),
        child: TrimSlider(
          controller: videoEditingCtrl.controller,
          height: height,
          horizontalMargin: height / 4,
          child: TrimTimeline(
            controller: videoEditingCtrl.controller,
            padding: const EdgeInsets.only(top: 10),
          ),
        ),
      )
    ];
  }

  Widget _coverSelection(VideoEditingController videoEditingCtrl) {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(15),
          child: CoverSelection(
            controller: videoEditingCtrl.controller,
            size: height + 10,
            quantity: 8,
            selectedCoverBuilder: (cover, size) {
              return Stack(
                alignment: Alignment.center,
                children: [cover, Icon(Icons.check_circle, color: const CoverSelectionStyle().selectedBorderColor)],
              );
            },
          ),
        ),
      ),
    );
  }
}
