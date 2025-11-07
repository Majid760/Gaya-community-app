import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../peer_connection.dart';
import '../utils/rtc_media_config.dart';

class ConferencePeerConnection extends PeerConnection {
  static const TAG = 'ConferencePeerConnection';

  ConferencePeerConnection(
      int userId, CubePeerConnectionStateCallback peerConnectionStateCallback)
      : super(userId, peerConnectionStateCallback, false);

  @override
  void setMediaStream(RTCPeerConnection pc, MediaStream? mediaStream) {
    if (mediaStream == null) return;

    MediaStreamTrack? videoTrack = mediaStream.getVideoTracks().firstOrNull;

    if (videoTrack != null) {
      var simulcastConfig = RTCMediaConfig.instance.simulcastConfig;

      var sendEncodings = [
        RTCRtpEncoding()
          ..rid = 'h'
          ..active = true
          ..maxBitrate = simulcastConfig.highVideoBitrate * 1000,
        RTCRtpEncoding()
          ..rid = 'm'
          ..active = true
          ..maxBitrate = simulcastConfig.mediumVideoBitrate * 1000
          ..scaleResolutionDownBy = 2,
        RTCRtpEncoding()
          ..rid = 'l'
          ..active = true
          ..maxBitrate = simulcastConfig.lowVideoBitrate * 1000
          ..scaleResolutionDownBy = 4,
      ];

      RTCRtpTransceiverInit initVideo = RTCRtpTransceiverInit(
        direction: TransceiverDirection.SendOnly,
        streams: [mediaStream],
        sendEncodings: kIsWeb ? sendEncodings : sendEncodings.reversed.toList(),
      );

      pc.addTransceiver(
        track: videoTrack,
        kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
        init: initVideo,
      );
    }

    MediaStreamTrack? audioTrack = mediaStream.getAudioTracks().firstOrNull;

    if (audioTrack != null) {
      RTCRtpTransceiverInit initAudio = RTCRtpTransceiverInit(
        direction: TransceiverDirection.SendOnly,
        streams: [mediaStream],
      );

      pc.addTransceiver(
        track: audioTrack,
        kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
        init: initAudio,
      );
    }
  }

  @override
  void setMaxBandwidth(int? bandwidth) {
    // ignoring for conference calls
  }

  @override
  bool isAnswerShouldBeIgnored() {
    return false;
  }
}
