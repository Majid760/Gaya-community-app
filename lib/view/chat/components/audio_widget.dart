import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gaya/gen/assets.gen.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/view/chat/components/contro_buttons.dart';
import 'package:gaya/view/chat/components/seek_bart.dart';
import 'package:gaya/view/chat/components/text_link_widget.dart';
import 'package:gaya/view/chat/controllers/audio_manager.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class AudioWidget extends StatefulWidget {
  const AudioWidget({
    this.userImage,
    Key? key,
    required this.audioPath,
    required this.isCurrentUser,
    this.sentTime = '',
    this.deliveryStatus = '',
    required this.duration,
  }) : super(key: key);
  final String audioPath;
  final bool isCurrentUser;
  final Widget? userImage;
  final String sentTime;
  final String deliveryStatus;
  final String? duration;

  @override
  State<AudioWidget> createState() => _AudioWidgetState();
}

class _AudioWidgetState extends State<AudioWidget> with WidgetsBindingObserver {
  final _player = AudioPlayer();
  final Color mainColor = const Color(0xff8e412e);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _init();
    audioManager.addPlayer(_player);
  }

  // @mustCallSuper
  // @protected
  // void didUpdateWidget(covariant T oldWidget) {}

  Future<void> _init() async {
    // Try to load audio from a source and catch any errors.
    try {
      await _player.setAudioSource(AudioSource.uri(Uri.parse(widget.audioPath)));
    } catch (e) {
      debugPrint("Error loading audio source: $e");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Release decoders and buffers back to the operating system making them
    // available for other apps to use.
    _player.dispose();
    audioManager.removePlayer(_player);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Release the player's resources when not in use. We use "stop" so that
      // if the app resumes later, it will still remember what position to
      // resume from.
      _player.stop();
    }
  }

  /// Collects the data useful for displaying in a seek bar, using a handy
  /// feature of rx_dart to combine the 3 streams of interest into one.
  Stream<PositionData> get _positionDataStream => Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
      _player.positionStream,
      _player.bufferedPositionStream,
      _player.durationStream,
      (position, bufferedPosition, duration) => PositionData(position, bufferedPosition, duration ?? Duration.zero));

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
        stream: _player.playerStateStream,
        builder: (context, snapshot) {
          return Container(
            width: 240.w,
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8).r,
            decoration: BoxDecoration(
              color: widget.isCurrentUser ? kprimaryColorLight : kBaseGrey,
              borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16).r,
                  topRight: const Radius.circular(16).r,
                  bottomLeft: !widget.isCurrentUser ? Radius.circular(4.r) : Radius.circular(16.r),
                  bottomRight: !widget.isCurrentUser ? Radius.circular(16.r) : Radius.circular(4.r)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      children: [
                        widget.userImage != null
                            ? Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  widget.userImage ?? const SizedBox.shrink(),
                                  Positioned(
                                    right: -5,
                                    bottom: -1,
                                    child: SvgPicture.asset(
                                      Assets.assets.icons.filledMicrophone,
                                      color: kprimaryColor,
                                      height: 20.h,
                                      width: 20.h,
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),

                    // Display seek bar. Using StreamBuilder, this widget rebuilds
                    // each time the position, buffered position or duration changes.
                    StreamBuilder<PositionData>(
                      stream: _positionDataStream,
                      builder: (context, snapshot) {
                        PositionData? positionData = snapshot.data;
                        return Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12).r,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Display play/pause button and volume/speed sliders.
                                    ControlButtons(_player),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: SliderTheme(
                                        data: SliderThemeData(
                                          valueIndicatorColor: Colors.grey,
                                          activeTrackColor: kprimaryColor,
                                          thumbColor: const Color(0xFfB1B1B1),
                                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                                          overlayShape: SliderComponentShape.noThumb,
                                        ),
                                        child: SeekBar(
                                            duration: positionData?.duration ?? Duration.zero,
                                            position: positionData?.position ?? Duration.zero,
                                            bufferedPosition: positionData?.bufferedPosition ?? Duration.zero,
                                            onChangeEnd: _player.seek),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 25.0, right: 6).r,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${(positionData?.position.inMinutes.remainder(60) ?? 00) <= 10 ? "0${positionData?.position.inMinutes.remainder(60) ?? 00}" : positionData?.position.inMinutes.remainder(60)}:${((positionData?.position.inSeconds.remainder(60) ?? 00) <= 10 ? "0${positionData?.position.inSeconds.remainder(60) ?? 00}" : positionData?.position.inSeconds.remainder(60))}",
                                        style: TextStyle(fontSize: 12.64.sp),
                                      ),
                                      Text(
                                        widget.duration ??
                                            '${(positionData?.duration.inMinutes.remainder(60) ?? 00) <= 10 ? "0${positionData?.duration.inMinutes.remainder(60) ?? 00}" : positionData?.duration.inMinutes.remainder(60)}:${(positionData?.duration.inSeconds.remainder(60) ?? 00) <= 10 ? "0${positionData?.duration.inSeconds.remainder(60) ?? 00}" : positionData?.duration.inSeconds.remainder(60)}',
                                        style: TextStyle(fontSize: 12.64.sp),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                /// send timestamp
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      widget.sentTime,
                      style: TextStyle(color: AppColors.secondary2, fontSize: 10.0.sp, fontStyle: FontStyle.italic),
                    ),
                    (widget.isCurrentUser)
                        ? Row(
                            children: [
                              SizedBox(
                                width: 4.r,
                              ),
                              getReadDeliveredWidget(widget.deliveryStatus),
                            ],
                          )
                        : const SizedBox.shrink()
                  ],
                )
              ],
            ),
          );
        });
  }
}

/// Displays the play/pause button and volume/speed sliders.

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}
