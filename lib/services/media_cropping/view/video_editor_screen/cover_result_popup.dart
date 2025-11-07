import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fraction/fraction.dart';
import 'package:gaya/services/media_cropping/view/video_editor_screen/file_description.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<void> _getImageDimension(File file, {required Function(Size) onResult}) async {
  var decodedImage = await decodeImageFromList(file.readAsBytesSync());
  onResult(Size(decodedImage.width.toDouble(), decodedImage.height.toDouble()));
}

String _fileMBSize(File file) => ' ${(file.lengthSync() / (1024 * 1024)).toStringAsFixed(1)} MB';

class CoverResultPopup extends StatefulWidget {
  const CoverResultPopup({super.key, required this.cover});

  final File cover;

  @override
  State<CoverResultPopup> createState() => _CoverResultPopupState();
}

class _CoverResultPopupState extends State<CoverResultPopup> {
  late final Uint8List _imagebytes = widget.cover.readAsBytesSync();
  Size? _fileDimension;
  late String _fileMbSize;
  late String path;
  Future<void> saveImageToGallery() async {
    try {
      Directory directory = await getApplicationDocumentsDirectory();
      path = directory.path;
      String filePath = '$path/${p.basename(widget.cover.path)}${p.extension(widget.cover.path)}';
      File file = File(filePath);
      if (await file.exists()) {
        file.delete();
      }
      file.copy(filePath);
    } catch (e) {
      debugPrint('exception thrown during file saving');
    }
  }

  @override
  void initState() {
    super.initState();
    saveImageToGallery();
    _getImageDimension(
      widget.cover,
      onResult: (d) => setState(() => _fileDimension = d),
    );
    _fileMbSize = _fileMBSize(widget.cover);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Center(
        child: Stack(
          children: [
            Image.memory(_imagebytes),
            Positioned(
              bottom: 0,
              child: FileDescription(
                description: {
                  'Cover path': GayaStrings.file_saved_msg.tr,
                  'Cover ratio': Fraction.fromDouble(_fileDimension?.aspectRatio ?? 0).reduce().toString(),
                  'Cover dimension': _fileDimension.toString(),
                  'Cover size': _fileMbSize,
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
