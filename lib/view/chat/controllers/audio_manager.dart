import 'package:just_audio/just_audio.dart';

class AudioManager {
  final _players = <AudioPlayer>[];
  AudioPlayer? _activePlayer;

  void addPlayer(AudioPlayer player) {
    _players.add(player);
    player.playerStateStream.listen((state) {
      if (state.playing) {
        if (_activePlayer != null && _activePlayer != player) {
          _activePlayer!.pause();
        }
        _activePlayer = player;
      }
    });
  }

  void removePlayer(AudioPlayer player) {
    _players.remove(player);
    if (_activePlayer == player) {
      _activePlayer = null;
    }
  }
}

final audioManager = AudioManager();
