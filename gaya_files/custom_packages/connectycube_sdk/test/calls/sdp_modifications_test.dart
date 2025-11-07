// import 'package:connectycube_sdk/src/calls/peer_connection.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> main() async {
  group("Tests CHANGE_BITRATE", () {
    // test("testSetBandwidth", () async {
    //   var sdp = 'v=0\r\n'
    //       'o=- 5908117325320511621 2 IN IP4 127.0.0.1\r\n'
    //       's=-\r\n'
    //       't=0 0\r\n'
    //       'a=group:BUNDLE 0 1\r\n'
    //       'a=extmap-allow-mixed\r\n'
    //       'a=msid-semantic: WMS 1EC1E669-9B55-4336-AB18-47FB5249C049\r\n'
    //       'm=audio 9 UDP/TLS/RTP/SAVPF 111 63 103 104 9 102 0 8 106 105 13 110 112 113 126\r\n'
    //       'c=IN IP4 0.0.0.0\r\n'
    //       'a=rtcp:9 IN IP4 0.0.0.0\r\n'
    //       'a=ice-ufrag:x8oh\r\n'
    //       'a=ice-pwd:Msrst6J/9spLD5rnl6JuRdnG\r\n'
    //       'm=video 9 UDP/TLS/RTP/SAVPF 96 97 98 99 100 101 35 36 125 124 127\r\n'
    //       'c=IN IP4 0.0.0.0\r\n'
    //       'a=rtcp:9 IN IP4 0.0.0.0\r\n'
    //       'a=ice-ufrag:x8oh\r\n'
    //       'a=ice-pwd:Msrst6J/9spLD5rnl6JuRdnG\r\n'
    //       'a=ice-options:trickle renomination\r\n'
    //       'a=fingerprint:sha-256 F5:51:72:03:12:1C:7B:4F:5F:2D:95:FF:80:0E:EC:44:75:6A:06:69:4D:BB:B4:32:54:87:AC:15:26:A1:1F:03\r\n'
    //       'a=setup:actpass\r\n';
    //
    //   var newBandwidth = 75000;
    //   var updatedSdp = updateBandwidthRestriction(sdp, newBandwidth);
    //
    //   assert(RegExp('b=AS:$newBandwidth\r\n').hasMatch(updatedSdp));
    // });
    //
    // test("testReplaceBandwidth", () async {
    //   var sdp = 'v=0\r\n'
    //       'o=- 5908117325320511621 2 IN IP4 127.0.0.1\r\n'
    //       's=-\r\n'
    //       't=0 0\r\n'
    //       'a=group:BUNDLE 0 1\r\n'
    //       'a=extmap-allow-mixed\r\n'
    //       'a=msid-semantic: WMS 1EC1E669-9B55-4336-AB18-47FB5249C049\r\n'
    //       'm=audio 9 UDP/TLS/RTP/SAVPF 111 63 103 104 9 102 0 8 106 105 13 110 112 113 126\r\n'
    //       'c=IN IP4 0.0.0.0\r\n'
    //       'b=AS:85000\r\n'
    //       'a=rtcp:9 IN IP4 0.0.0.0\r\n'
    //       'a=ice-ufrag:x8oh\r\n'
    //       'a=ice-pwd:Msrst6J/9spLD5rnl6JuRdnG\r\n'
    //       'm=video 9 UDP/TLS/RTP/SAVPF 96 97 98 99 100 101 35 36 125 124 127\r\n'
    //       'c=IN IP4 0.0.0.0\r\n'
    //       'b=AS:950000\r\n'
    //       'a=rtcp:9 IN IP4 0.0.0.0\r\n'
    //       'a=ice-ufrag:x8oh\r\n'
    //       'a=ice-pwd:Msrst6J/9spLD5rnl6JuRdnG\r\n'
    //       'a=ice-options:trickle renomination\r\n'
    //       'a=fingerprint:sha-256 F5:51:72:03:12:1C:7B:4F:5F:2D:95:FF:80:0E:EC:44:75:6A:06:69:4D:BB:B4:32:54:87:AC:15:26:A1:1F:03\r\n'
    //       'a=setup:actpass\r\n';
    //
    //   var newBandwidth = 100000;
    //
    //   var updatedSdp = updateBandwidthRestriction(sdp, newBandwidth);
    //
    //   assert(RegExp('b=AS:$newBandwidth\r\n').hasMatch(updatedSdp));
    // });
    //
    // test("testDeleteBandwidth", () async {
    //   var sdp = 'v=0\r\n'
    //       'o=- 5908117325320511621 2 IN IP4 127.0.0.1\r\n'
    //       's=-\r\n'
    //       't=0 0\r\n'
    //       'a=group:BUNDLE 0 1\r\n'
    //       'a=extmap-allow-mixed\r\n'
    //       'a=msid-semantic: WMS 1EC1E669-9B55-4336-AB18-47FB5249C049\r\n'
    //       'm=audio 9 UDP/TLS/RTP/SAVPF 111 63 103 104 9 102 0 8 106 105 13 110 112 113 126\r\n'
    //       'c=IN IP4 0.0.0.0\r\n'
    //       'b=AS:85000\r\n'
    //       'a=rtcp:9 IN IP4 0.0.0.0\r\n'
    //       'a=ice-ufrag:x8oh\r\n'
    //       'a=ice-pwd:Msrst6J/9spLD5rnl6JuRdnG\r\n'
    //       'm=video 9 UDP/TLS/RTP/SAVPF 96 97 98 99 100 101 35 36 125 124 127\r\n'
    //       'c=IN IP4 0.0.0.0\r\n'
    //       'b=TIAS:950000\r\n'
    //       'a=rtcp:9 IN IP4 0.0.0.0\r\n'
    //       'a=ice-ufrag:x8oh\r\n'
    //       'a=ice-pwd:Msrst6J/9spLD5rnl6JuRdnG\r\n'
    //       'a=ice-options:trickle renomination\r\n'
    //       'a=fingerprint:sha-256 F5:51:72:03:12:1C:7B:4F:5F:2D:95:FF:80:0E:EC:44:75:6A:06:69:4D:BB:B4:32:54:87:AC:15:26:A1:1F:03\r\n'
    //       'a=setup:actpass\r\n';
    //
    //   var updatedSdp = removeBandwidthRestriction(sdp);
    //   assert(!RegExp('b=.*\r\n').hasMatch(updatedSdp));
    // });
  });
}
