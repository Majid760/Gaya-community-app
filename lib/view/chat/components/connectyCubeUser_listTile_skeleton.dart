import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/const.dart';

class ConnectyCubeUserListTileSkeleton extends StatelessWidget {
  const ConnectyCubeUserListTileSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                height: 40.r,
                width: 40.r,
                decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(1000)),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 20,
                    width: MediaQuery.sizeOf(context).width * 0.3,
                    decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(borderRadius_4)),
                  ),
                ],
              ),
            ],
          ),
          Container(
            height: 24.h,
            width: 24.w,
            decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(1000)),
          ),
        ],
      ),
    );
  }
}
