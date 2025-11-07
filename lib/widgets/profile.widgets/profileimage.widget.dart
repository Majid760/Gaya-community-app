import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/profile_image_widget.dart';
import 'package:gaya/controller/profile.controller.dart';
import 'package:provider/provider.dart';

import '../../components/image_swiper.dart';
import '../../utils/const.dart';

class ProfilePicWidget extends StatelessWidget {
  final String? profilePic;
  final String? coverPhoto;
  final Widget? camera;
  final oncovertap;
  final onproftap;
  final Widget? streakIcon;

  const ProfilePicWidget({Key? key, this.profilePic, this.coverPhoto, this.oncovertap, this.onproftap, this.camera, this.streakIcon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profileController = Provider.of<ProfileController>(context, listen: true);

    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          profileController.coverPercentage == null
              ? Column(
                  children: [
                    coverPhoto != ''
                        ? InkWell(
                            onTap: oncovertap,
                            child: ScrolledHero(
                              tag: coverPhoto ?? '',
                              child: Container(
                                height: 112,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(borderRadius_8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(borderRadius_8),
                                  child: coverPhoto == null || coverPhoto == ''
                                      ? FittedBox(fit: BoxFit.cover, child: Container(color: Colors.grey[400]))
                                      :
                                      //PostImageModifiedWidget(url: coverPhoto, size: const Size(112, 300)),
                                      PostImageWidget(url: coverPhoto, size: const Size(112, 300)),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            height: 112,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(borderRadius_8), color: kSecondaryColor),
                          ),
                  ],
                )
              : LinearProgressIndicator(
                  value: profileController.coverPercentage,
                  minHeight: 3.0,
                  color: kprimaryColor,
                ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Center(
                child: profilePic != '' && profilePic != null
                    ? InkWell(
                        splashColor: kTransparentColor,
                        highlightColor: kTransparentColor,
                        onTap: onproftap,
                        child: ScrolledHero(
                          tag: profilePic ?? '',
                          child: Stack(
                            children: [
                              CircleAvatar(
                                backgroundColor: kBaseGrey,
                                radius: 58,
                                child: ProfileImageWidget(
                                  url: profilePic,
                                  maxDiskCacheHeight: 300,
                                  maxDiskCacheWidth: 300,
                                ),
                              ),

                              /// COMMENTED For INFLUENCE BAR
                              // Positioned(
                              //   right: 20.r,
                              //   bottom: 3.r,
                              //   child: streakIcon ?? const SizedBox(),
                              // )
                            ],
                          ),
                        ),
                      )
                    : Stack(
                        children: [
                          const CircleAvatar(
                            radius: 58,
                            backgroundImage: AssetImage('Assets/images/user.png'),
                          ),
                          Positioned(
                            right: 20.r,
                            bottom: 3.r,
                            child: streakIcon ?? const SizedBox(),
                          )
                        ],
                      ),
              ),
              const SizedBox(height: distance_30),
            ],
          ),
          profileController.coverPercentage == null ? camera ?? const SizedBox() : const SizedBox(),
        ],
      ),
    );
  }
}
