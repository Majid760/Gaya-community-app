import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gaya/components/snackbar.component.dart';
import 'package:gaya/controller/firebase_analytics_controller.dart';
import 'package:gaya/services/media_cropping/view/video_editor_screen/cover_result_popup.dart';
import 'package:gaya/utils/const.dart';
import 'package:get/get.dart';
import 'package:video_editor/video_editor.dart';

import '../../../model/user.model.dart';

class VideoEditingController extends ChangeNotifier {
  VideoEditingController({required File fileTE}) {
    try {
      file = fileTE;
      controller = VideoEditorController.file(fileTE, minDuration: const Duration(seconds: 1), maxDuration: const Duration(seconds: 25));
      controller.initialize(aspectRatio: 9 / 16).then((_) => notifyListeners()).catchError((error) {
        // handle minumum duration bigger than video duration error
        Get.back();
      }, test: (e) => e is VideoMinDurationError);
    } catch (e) {
      debugPrint('error thrown from VideoController constructor');
    }
  }

  final exportingProgress = ValueNotifier<double>(0.0);
  late File file;
  final isExporting = ValueNotifier<bool>(false);
  late VideoEditorController controller;

  @override
  void dispose() {
    exportingProgress.dispose();
    isExporting.dispose();
    controller.dispose();
    super.dispose();
  }

  // set file
  void setFile(File filee) {
    file = filee;
    notifyListeners();
  }

  // exporting trimmed video
  Future<void> exportVideo(BuildContext context) async {
    try {
      exportingProgress.value = 0;
      isExporting.value = true;
      notifyListeners();
      // NOTE: To use `-crf 1` and [VideoExportPreset] you need `ffmpeg_kit_flutter_min_gpl` package (with `ffmpeg_kit` only it won't work)
      controller.exportVideo(
        // format: VideoExportFormat.gif,
        // preset: VideoExportPreset.medium,
        // customInstruction: "-crf 17",
        onProgress: (stats, value) => exportingProgress.value = value,
        onError: (e, s) => snackBar(
          context,
          "Error on export video :",
          kprimaryColor,
          borderRadius: 8,
        ),
        onCompleted: (editedFile) async {
          debugPrint('this is original:${file.path}');
          debugPrint('this is edited:${editedFile.path}');
          isExporting.value = false;
          file = editedFile;

          // Logging crop video analytics event
          AnalyticsController.to.instance.cropVideo(
            userId: UserModel.to.uId ?? '',
          );
          Get.back(result: file);
        },
      );
      notifyListeners();
    } catch (e) {
      snackBar(context, "Error on export video :", kprimaryColor, borderRadius: 8);
    }
  }

  // exporting cover photo from video
  Future<void> exportCover(BuildContext context) async {
    try {
      await controller.extractCover(
        onError: (e, s) => snackBar(context, "Error on cover exportation :(", kprimaryColor, borderRadius: 8),
        onCompleted: (cover) {
          // if (!mounted) return;
          showDialog(context: context, builder: (_) => CoverResultPopup(cover: cover));
        },
      );
    } catch (e) {
      snackBar(context, "Error on cover exportation :(", kprimaryColor, borderRadius: 8);
    }
  }
}
