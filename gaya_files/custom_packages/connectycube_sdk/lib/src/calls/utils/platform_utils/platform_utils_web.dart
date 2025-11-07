import 'dart:html' as html;

import 'package:dart_webrtc/src/media_stream_impl.dart';
import 'package:webrtc_interface/webrtc_interface.dart';

export 'platform_utils.dart';

Future<MediaStream> createMediaStream(String label) {
  final jsMs = html.MediaStream();
  return Future.value(MediaStreamWeb(jsMs, label));
}
