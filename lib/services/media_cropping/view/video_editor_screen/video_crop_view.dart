import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/gen/assets.gen.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/services/media_cropping/controller/video_editing_controller.dart';
import 'package:gaya/services/media_cropping/view/video_editor_screen/video_player_view.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../utils/theme/app_colors.dart';

class CropVideoView extends StatelessWidget {
  const CropVideoView({super.key, required this.video, this.isFromMessageView = false});

  final File video;
  final bool isFromMessageView;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<VideoEditingController>(
        create: (context) => VideoEditingController(fileTE: video),
        child: Scaffold(
          key: UniqueKey(),
          appBar: AppBar(
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              iconTheme: const IconThemeData(color: kBlackColor),
              shape: const Border(bottom: BorderSide(color: kBaseGrey)),
              automaticallyImplyLeading: false,
              title: Consumer<VideoEditingController>(
                builder: (_, videoEditingCntrl, child) {
                  return SizedBox(
                    key: UniqueKey(),
                    width: MediaQuery.sizeOf(context).width,
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      IconButton(onPressed: () => Get.back(result: null), icon: Icon(Icons.cancel, size: 30.r, color: Colors.white)),
                      Row(children: [
                        IconButton(
                            icon: Icon(Icons.crop, size: 30.r, color: Colors.white),
                            onPressed: () async {
                              final newVideoFile = await Routes.videoEditorView(video: videoEditingCntrl.file);
                              if (newVideoFile is File) {
                                videoEditingCntrl.setFile(newVideoFile);
                              }
                            }),
                      ]),
                    ]),
                  );
                },
              ),
              centerTitle: true,
              backgroundColor: kBlackColor,
              elevation: 0),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Consumer<VideoEditingController>(
              builder: (_, videoEditingCntrl, child) {
                if (isFromMessageView == false) {
                  return FloatingActionButton(
                    heroTag: null,
                    onPressed: () => Get.back(result: videoEditingCntrl.file),
                    backgroundColor: kTransparentColor,
                    elevation: 0,
                    child: Container(
                        alignment: Alignment.center,
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: Center(child: SvgPicture.asset(Assets.assets.icons.send, height: 30))),
                  );
                }
                return GayaButton(
                    title: GayaStrings.continue_txt.tr,
                    primaryColor: kprimaryColor,
                    borderColor: kprimaryColor,
                    height: 40,
                    width: 100,
                    textStyle: const TextStyle(color: Colors.white, fontSize: 14),
                    onPressed: () => Get.back(result: videoEditingCntrl.file));
              },
            ),
          ),
          body: Consumer<VideoEditingController>(
            builder: (__, videoEditingCntrl, child) {
              return Container(
                key: UniqueKey(),
                constraints: BoxConstraints.expand(height: MediaQuery.sizeOf(context).height),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: <Widget>[
                    VideoPlayScreen(key: UniqueKey(), video: videoEditingCntrl.file),
                  ],
                ),
              );
            },
          ),
        ));
  }
}
