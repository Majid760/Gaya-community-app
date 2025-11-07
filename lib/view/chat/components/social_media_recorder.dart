library social_media_recorder;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/view/chat/components/lock_record.dart';
import 'package:gaya/view/chat/components/show_counter.dart';
import 'package:gaya/view/chat/components/show_mic_with_text.dart';
import 'package:gaya/view/chat/components/sound_recorder_when_locked_design.dart';
import 'package:gaya/view/chat/controllers/sound_record_notifier.dart';
import 'package:gaya/view/chat/models/audio_encoder_type.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../utils/theme/app_colors.dart';

class SocialMediaRecorder extends StatefulWidget {
  /// use it for change back ground of cancel
  final Color? cancelTextBackGroundColor;

  /// function reture the recording sound file
  final Function(File soundFile, String duration) sendRequestFunction;

  /// recording Icon That pressesd to start record
  final Widget? recordIcon;

  /// recording Icon when user locked the record
  final Widget? recordIconWhenLockedRecord;

  /// use to change the backGround Icon when user recording sound
  final Color? recordIconBackGroundColor;

  /// use to change the Icon backGround color when user locked the record
  final Color? recordIconWhenLockBackGroundColor;

  /// use to change all recording widget color
  final Color? backGroundColor;

  /// use to change the counter style
  final TextStyle? counterTextStyle;

  /// use to change slide to cancel textstyle
  final TextStyle? slideToCancelTextStyle;

  /// this text show when lock record and to tell user should press in this text to cancel recod
  final String? cancelText;

  /// use to change cancel text style
  final TextStyle? cancelTextStyle;

  /// put you file directory storage path if you didn't pass it take deafult path
  final String? storeSoundRecoringPath;

  /// Chose the encode type
  final AudioEncoderType encode;

  /// use if you want change the raduis of un record
  final BorderRadius? radius;

  // use to change the counter back ground color
  final Color? counterBackGroundColor;

  // use to change lock icon to design you need it
  final Widget? lockButton;

  // use it to change send button when user lock the record
  final Widget? sendButtonIcon;

  // ignore: sort_constructors_first
  const SocialMediaRecorder({
    this.sendButtonIcon,
    this.storeSoundRecoringPath = "",
    required this.sendRequestFunction,
    this.recordIcon,
    this.lockButton,
    this.counterBackGroundColor,
    this.recordIconWhenLockedRecord,
    this.recordIconBackGroundColor = Colors.white,
    this.recordIconWhenLockBackGroundColor = Colors.white,
    this.backGroundColor,
    this.cancelTextStyle,
    this.counterTextStyle,
    this.slideToCancelTextStyle,
    this.cancelText = "Cancel",
    this.encode = AudioEncoderType.AAC,
    this.cancelTextBackGroundColor,
    this.radius,
    Key? key,
  }) : super(key: key);

  @override
  State<SocialMediaRecorder> createState() => _SocialMediaRecorder();
}

class _SocialMediaRecorder extends State<SocialMediaRecorder> with WidgetsBindingObserver {
  late SoundRecordNotifier soundRecordNotifier;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    /// if user close app or go to background reset edge padding - Stop Record
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached || state == AppLifecycleState.inactive) {
      soundRecordNotifier.resetEdgePadding();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    soundRecordNotifier = SoundRecordNotifier();
    soundRecordNotifier.initialStorePathRecord = widget.storeSoundRecoringPath ?? "";
    soundRecordNotifier.isShow = false;
    // soundRecordNotifier.voidInitialSound()
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [ChangeNotifierProvider(create: (context) => soundRecordNotifier)],
        child: Consumer<SoundRecordNotifier>(
          builder: (context, value, _) {
            return Directionality(textDirection: TextDirection.rtl, child: makeBody(value));
          },
        ));
  }

  Widget makeBody(SoundRecordNotifier state) {
    return GestureDetector(
      onHorizontalDragUpdate: (scrollEnd) {
        // HapticFeedback.lightImpact();
        state.updateScrollValue(scrollEnd.globalPosition, context);
      },
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        child: recordVoice(state),
      ),
    );
  }

  Widget recordVoice(SoundRecordNotifier state) {
    if (state.lockScreenRecord == true) {
      return SoundRecorderWhenLockedDesign(
        cancelText: GayaStrings.cancel_txt.tr,
        sendButtonIcon: widget.sendButtonIcon,
        cancelTextBackGroundColor: widget.cancelTextBackGroundColor,
        cancelTextStyle: widget.cancelTextStyle,
        counterBackGroundColor: widget.counterBackGroundColor,
        recordIconWhenLockBackGroundColor: AppColors.white,
        counterTextStyle: widget.counterTextStyle,
        recordIconWhenLockedRecord: widget.recordIconWhenLockedRecord,
        sendRequestFunction: widget.sendRequestFunction,
        soundRecordNotifier: state,
      );
    }

    return Listener(
      onPointerDown: (details) async {
        HapticFeedback.lightImpact();
        state.setNewInitialDraggableHeight(details.position.dy);
        state.resetEdgePadding();
        soundRecordNotifier.isShow = true;
        state.record(context: context);
      },
      onPointerUp: (details) async {
        if (!state.isLocked) {
          if (state.buttonPressed) {
            if (state.second > 1 || state.minute > 0) {
              String path = state.mPath;
              widget.sendRequestFunction(
                  File.fromUri(Uri(path: path)), getTimeDurationString(minute: state.minute, second: state.second - 1));
            }
          }
          state.resetEdgePadding();
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: soundRecordNotifier.isShow ? 0 : 300),
        height: soundRecordNotifier.isShow ? 70 : 40,
        padding: const EdgeInsets.only(bottom: 10),
        width: (soundRecordNotifier.isShow) ? MediaQuery.sizeOf(context).width : 40,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(right: state.edge),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: soundRecordNotifier.isShow
                      ? BorderRadius.circular(12)
                      : widget.radius != null && !soundRecordNotifier.isShow
                          ? widget.radius
                          : BorderRadius.circular(0),
                  color: !soundRecordNotifier.isShow
                      ? AppColors.transparrent
                      : !soundRecordNotifier.startRecord
                          ? Colors.grey.shade100
                          : Colors.transparent,
                ),
                child: Stack(
                  children: [
                    ShowMicWithText(
                      counterBackGroundColor: widget.counterBackGroundColor,
                      backGroundColor: widget.recordIconBackGroundColor,
                      recordIcon: widget.recordIcon,
                      shouldShowText: soundRecordNotifier.isShow,
                      soundRecorderState: state,
                      slideToCancelTextStyle: widget.slideToCancelTextStyle,
                      slideToCancelText: " ${GayaStrings.slide_cancel.tr} >",
                    ),
                    if (soundRecordNotifier.isShow)
                      ShowCounter(counterBackGroundColor: widget.counterBackGroundColor, soundRecorderState: state),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 60,
              child: LockRecord(
                soundRecorderState: state,
                lockIcon: widget.lockButton,
              ),
            )
          ],
        ),
      ),
    );
  }
}

String getTimeDurationString({required int minute, required int second}) {
  String minuteString = minute.toString();
  String secondString = second.toString();
  if (minute == 0 && second == 0) {
    return "00:00";
  }

  /// remove -1 from second
  second = second > 0 ? second - 1 : second;
  if (minute < 10) {
    minuteString = "0$minuteString";
  }
  if (second < 10) {
    secondString = "0$secondString";
  }
  return "$minuteString:$secondString";
}
