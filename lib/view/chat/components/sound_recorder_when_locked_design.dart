library social_media_recorder;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/view/chat/components/show_counter.dart';
import 'package:gaya/view/chat/components/social_media_recorder.dart';
import 'package:gaya/view/chat/controllers/sound_record_notifier.dart';

// ignore: must_be_immutable
class SoundRecorderWhenLockedDesign extends StatelessWidget {
  final SoundRecordNotifier soundRecordNotifier;
  final String? cancelText;
  final Function sendRequestFunction;
  final Widget? recordIconWhenLockedRecord;
  final TextStyle? cancelTextStyle;
  final TextStyle? counterTextStyle;
  final Color recordIconWhenLockBackGroundColor;
  final Color? counterBackGroundColor;
  final Color? cancelTextBackGroundColor;
  final Widget? sendButtonIcon;
  // ignore: sort_constructors_first
  const SoundRecorderWhenLockedDesign({
    Key? key,
    required this.sendButtonIcon,
    required this.soundRecordNotifier,
    required this.cancelText,
    required this.sendRequestFunction,
    required this.recordIconWhenLockedRecord,
    required this.cancelTextStyle,
    required this.counterTextStyle,
    required this.recordIconWhenLockBackGroundColor,
    required this.counterBackGroundColor,
    required this.cancelTextBackGroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      padding: const EdgeInsets.all(2).r,
      decoration: BoxDecoration(
        color: cancelTextBackGroundColor ?? Colors.grey.shade100,
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: InkWell(
        onTap: () {
          soundRecordNotifier.isShow = false;
          soundRecordNotifier.resetEdgePadding();
        },
        child: Padding(
          padding: EdgeInsets.only(bottom: 20.0.h),
          child: Row(
            children: [
              InkWell(
                onTap: () async {
                  soundRecordNotifier.isShow = false;
                  if (soundRecordNotifier.second > 1 || soundRecordNotifier.minute > 0) {
                    String path = soundRecordNotifier.mPath;
                    await Future.delayed(const Duration(milliseconds: 500));
                    sendRequestFunction(File.fromUri(Uri(path: path)),
                        getTimeDurationString(minute: soundRecordNotifier.minute, second: soundRecordNotifier.second));
                  }
                  soundRecordNotifier.resetEdgePadding();
                },
                child: Transform.scale(
                  scale: 0.85,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(600),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeIn,
                      width: 50,
                      height: 50,
                      child: Container(
                        color: recordIconWhenLockBackGroundColor,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: recordIconWhenLockedRecord ??
                              sendButtonIcon ??
                              Icon(
                                Icons.send,
                                textDirection: TextDirection.ltr,
                                size: 28,
                                color: (soundRecordNotifier.buttonPressed) ? AppColors.primary : Colors.black,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                    onTap: () {
                      soundRecordNotifier.isShow = false;
                      soundRecordNotifier.resetEdgePadding();
                    },
                    child: Text(
                      cancelText ?? "",
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.clip,
                      style: cancelTextStyle ??
                          const TextStyle(
                            color: Colors.black,
                          ),
                    )),
              ),
              ShowCounter(
                soundRecorderState: soundRecordNotifier,
                counterTextStyle: counterTextStyle,
                counterBackGroundColor: counterBackGroundColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
