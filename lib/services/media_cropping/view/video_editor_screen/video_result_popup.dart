import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gaya/services/media_cropping/view/video_editor_screen/file_description.dart';
import 'package:path/path.dart' as path;
import 'package:video_player/video_player.dart';

Future<void> _getImageDimension(File file, {required Function(Size) onResult}) async {
  var decodedImage = await decodeImageFromList(file.readAsBytesSync());
  onResult(Size(decodedImage.width.toDouble(), decodedImage.height.toDouble()));
}

String _fileMBSize(File file) => ' ${(file.lengthSync() / (1024 * 1024)).toStringAsFixed(1)} MB';

class VideoResultPopup extends StatefulWidget {
  const VideoResultPopup({super.key, required this.video});
  final File video;
  @override
  State<VideoResultPopup> createState() => _VideoResultPopupState();
}

class _VideoResultPopupState extends State<VideoResultPopup> {
  VideoPlayerController? _controller;
  FileImage? _fileImage;
  Size _fileDimension = Size.zero;
  late final bool _isGif = path.extension(widget.video.path).toLowerCase() == ".gif";
  late String _fileMbSize;

  @override
  void initState() {
    super.initState();
    if (_isGif) {
      _getImageDimension(widget.video, onResult: (d) => setState(() => _fileDimension = d));
    } else {
      _controller = VideoPlayerController.file(widget.video);
      _controller?.initialize().then((_) {
        _fileDimension = _controller?.value.size ?? Size.zero;
        setState(() {});
        _controller?.play();
        _controller?.setLooping(true);
      });
    }
    _fileMbSize = _fileMBSize(widget.video);
  }

  @override
  void dispose() {
    if (_isGif) {
      _fileImage?.evict();
    } else {
      _controller?.pause();
      _controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Center(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            AspectRatio(
              aspectRatio: _fileDimension.aspectRatio == 0 ? 1 : _fileDimension.aspectRatio,
              child: _isGif ? Image.file(widget.video) : VideoPlayer(_controller!),
            ),
            Positioned(
              bottom: 0,
              child: FileDescription(
                description: {
                  // 'Video path': widget.video.path,
                  if (!_isGif) 'Video duration': '${((_controller?.value.duration.inMilliseconds ?? 0) / 1000).toStringAsFixed(2)}s',
                  // 'Video ratio': Fraction.fromDouble(_fileDimension.aspectRatio).reduce().toString(),
                  'Video dimension': _fileDimension.toString(),
                  'Video size': _fileMbSize,
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
