// import 'package:get/get.dart';
// import 'package:just_audio/just_audio.dart';
//
// class AudioController extends GetxController {
//   static AudioController get to => Get.find();
//   final _players = <AudioPlayer>[].obs;
//   AudioPlayer? _activePlayer;
//
//   void addPlayer(AudioPlayer player) {
//     _players.add(player);
//     player.playerStateStream.listen((state) {
//       if (state.playing) {
//         if (_activePlayer != null && _activePlayer != player) {
//           _activePlayer!.pause();
//         }
//         _activePlayer = player;
//       }
//     });
//   }
//
//   void removePlayer(AudioPlayer player) {
//     _players.remove(player);
//     if (_activePlayer == player) {
//       _activePlayer = null;
//     }
//   }
// }
