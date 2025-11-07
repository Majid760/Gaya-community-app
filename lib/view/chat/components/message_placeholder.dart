import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/view/chat/helper/helper_functions.dart';

class MessagePlaceholder extends StatelessWidget {
  const MessagePlaceholder({super.key, required this.messagetype});
  final MessageType messagetype;

  @override
  Widget build(BuildContext context) {
    switch (messagetype) {
      case MessageType.image:
        return Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: kBaseGrey,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                height: 200.h,
                width: 150.w,
                child: const Center(
                  child: CupertinoActivityIndicator(),
                ),
              ),
            ],
          ),
        );
      case MessageType.video:
        return Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: Container(
                  decoration: const BoxDecoration(
                    color: kBaseGrey,
                  ),
                  height: 150.h,
                  width: 160.w,
                  child: const Center(
                    child: CupertinoActivityIndicator(),
                  ),
                ),
              ),
            ],
          ),
        );
      // case MessageType.post:
      //   return Align(
      //     alignment: Alignment.centerRight,
      //     child: SizedBox(
      //       height: 100.h,
      //       width: 150.w,
      //       child: const Center(
      //         child: CupertinoActivityIndicator(),
      //       ),
      //     ),
      //   );
      // case MessageType.community:
      //   return Align(
      //     alignment: Alignment.centerRight,
      //     child: SizedBox(
      //       height: 100.h,
      //       width: 150.w,
      //       child: const Center(
      //         child: CupertinoActivityIndicator(),
      //       ),
      //     ),
      //   );
      case MessageType.document:
        return Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12).r, color: kBaseGrey),
                height: 140.h,
                width: 230.w,
                child: const Center(
                  child: CupertinoActivityIndicator(),
                ),
              ),
            ],
          ),
        );
      case MessageType.text:
        return Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              Center(
                child: CupertinoActivityIndicator(),
              ),
            ],
          ),
        );
      case MessageType.link:
        return const Align(
          alignment: Alignment.centerRight,
          child: Center(
            child: CupertinoActivityIndicator(),
          ),
        );
      case MessageType.audio:
        return Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 20.h),
                decoration: BoxDecoration(
                  color: kprimaryColorLight,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                      bottomLeft: Radius.circular(16.r),
                      bottomRight: Radius.circular(4.r)),
                ),
                // height: 50.h,
                width: 240.w,
                child: const Center(
                  child: CupertinoActivityIndicator(),
                ),
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}