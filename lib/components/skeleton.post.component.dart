import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/model/create.post.model.dart';
import 'package:gaya/utils/asset_images.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../routing/getx_route_methods.dart';
import '../utils/const.dart';
import '../utils/theme/app_typography.dart';

class PostsSkeleton extends StatelessWidget {
  final bool isTextOnly;
  final bool showTopDivider;

  const PostsSkeleton({Key? key, this.isTextOnly = false, this.showTopDivider = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTopDivider)
          Divider(
            thickness: 1,
            color: kSecondaryLightColor.withOpacity(1),
          ),
        Row(
          children: [
            Container(
              height: distance_50,
              width: distance_60,
              decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(borderRadius_8)),
            ),
            const SizedBox(width: distance_15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 20,
                  width: 115,
                  decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(borderRadius_4)),
                ),
                const SizedBox(height: distance_5),
                Container(
                  height: 20,
                  width: 115,
                  decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(borderRadius_4)),
                ),
              ],
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(borderRadius_4)),
                ),
                const SizedBox(width: distance_15),
                Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(borderRadius_4)),
                )
              ],
            )
          ],
        ),
        const SizedBox(
          height: distance_15,
        ),
        Container(
          height: 18,
          width: double.infinity,
          decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(borderRadius_4)),
        ),
        const SizedBox(
          height: distance_10,
        ),
        Container(
          height: 18,
          width: double.infinity,
          decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(borderRadius_4)),
        ),
        const SizedBox(
          height: distance_10,
        ),
        Container(
          height: 18,
          width: 160,
          decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(borderRadius_4)),
        ),
        ////////////////////////// If post type is Media ///////////////////////
        if (isTextOnly == false)
          const SizedBox(
            height: distance_10,
          ),
        if (isTextOnly == false)
          Container(
            height: 188,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius_8),
              color: const Color(0xFFECF0F3),
            ),
          ),
        Divider(
          thickness: 1,
          color: kSecondaryLightColor.withOpacity(1),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius_4),
                    color: const Color(0xFFECF0F3),
                  ),
                ),
                const SizedBox(
                  width: distance_10,
                ),
                Container(
                  height: 20,
                  width: 75,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius_4),
                    color: const Color(0xFFECF0F3),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius_4),
                    color: const Color(0xFFECF0F3),
                  ),
                ),
                const SizedBox(
                  width: distance_10,
                ),
                Container(
                  height: 20,
                  width: 75,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius_4),
                    color: const Color(0xFFECF0F3),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius_4),
                    color: const Color(0xFFECF0F3),
                  ),
                ),
                const SizedBox(
                  width: distance_10,
                ),
                Container(
                  height: 20,
                  width: 75,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius_4),
                    color: const Color(0xFFECF0F3),
                  ),
                ),
              ],
            ),
          ],
        ),
        // Divider(
        //   thickness: 1,
        //   color: kSecondaryLightColor.withOpacity(1),
        // )
      ],
    );
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!, //Color(0xFFECF0F3),
      highlightColor: Colors.grey[400]!,
      period: const Duration(milliseconds: 800),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTopDivider)
            Divider(
              thickness: 1,
              color: Colors.red.withOpacity(1),
            ),
          Row(
            children: [
              Container(
                height: distance_50,
                width: distance_60,
                decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(borderRadius_8)),
              ),
              const SizedBox(width: distance_15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 20,
                    width: 115,
                    decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(borderRadius_4)),
                  ),
                  const SizedBox(height: distance_5),
                  Container(
                    height: 20,
                    width: 115,
                    decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(borderRadius_4)),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(borderRadius_4)),
                  ),
                  const SizedBox(width: distance_15),
                  Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(borderRadius_4)),
                  )
                ],
              )
            ],
          ),
          const SizedBox(
            height: distance_15,
          ),
          Container(
            height: 18,
            width: double.infinity,
            decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(borderRadius_4)),
          ),
          const SizedBox(
            height: distance_10,
          ),
          Container(
            height: 18,
            width: double.infinity,
            decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(borderRadius_4)),
          ),
          const SizedBox(
            height: distance_10,
          ),
          Container(
            height: 18,
            width: 160,
            decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(borderRadius_4)),
          ),
          ////////////////////////// If post type is Media ///////////////////////
          if (isTextOnly == false)
            const SizedBox(
              height: distance_10,
            ),
          if (isTextOnly == false)
            Container(
              height: 188,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius_8),
                color: const Color(0xFFECF0F3),
              ),
            ),
          Divider(
            thickness: 1,
            color: kSecondaryLightColor.withOpacity(1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(borderRadius_4),
                      color: const Color(0xFFECF0F3),
                    ),
                  ),
                  const SizedBox(
                    width: distance_10,
                  ),
                  Container(
                    height: 20,
                    width: 75,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(borderRadius_4),
                      color: const Color(0xFFECF0F3),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(borderRadius_4),
                      color: const Color(0xFFECF0F3),
                    ),
                  ),
                  const SizedBox(
                    width: distance_10,
                  ),
                  Container(
                    height: 20,
                    width: 75,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(borderRadius_4),
                      color: const Color(0xFFECF0F3),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(borderRadius_4),
                      color: const Color(0xFFECF0F3),
                    ),
                  ),
                  const SizedBox(
                    width: distance_10,
                  ),
                  Container(
                    height: 20,
                    width: 75,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(borderRadius_4),
                      color: const Color(0xFFECF0F3),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Divider(
          //   thickness: 1,
          //   color: kSecondaryLightColor.withOpacity(1),
          // )
        ],
      ),
    );
  }
}

class PostThumbnailSkeleton extends StatelessWidget {
  const PostThumbnailSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius_8),
            color: kBaseGrey,
          ),
        ),
      ],
    );
  }
}

class CommunityMessageThumbnailSkeleton extends StatelessWidget {
  const CommunityMessageThumbnailSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 200.h,
          width: 150.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius_8),
            color: kBaseGrey,
          ),
        ),
      ],
    );
  }
}

class PostMessageThumbnailSkeleton extends StatelessWidget {
  const PostMessageThumbnailSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 100.h,
          width: 150.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius_8),
            color: kBaseGrey,
          ),
        ),
      ],
    );
  }
}

class PostThumbnailError extends StatelessWidget {
  final Post? post;
  final String? message;
  const PostThumbnailError({Key? key, this.post, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: post != null ? () => Routes.postDetailsScreen(post: post!, community: post!.community) : null,
      child: Column(
        children: [
          Container(
            height: 150,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8).r,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(borderRadius_8).r, color: AppColors.divider),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgIcons.problem(color: AppColors.secondary, height: 24.r, width: 24.r),
                  SizedBox(height: distance_8.r),
                  Text(
                    message ?? GayaStrings.post_deleted_not_available.tr,
                    style: GayaTypography.captionMedium.copyWith(color: AppColors.secondary, height: 1, fontWeight: FontWeight.w400),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CommentsSkeleton extends StatelessWidget {
  const CommentsSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: 5,
        shrinkWrap: true,
        // padding: const EdgeInsets.symmetric(horizontal: distance_15, vertical: distance_10),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20).r,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                //avatar
                Container(
                  height: 40.r,
                  width: 40.r,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFECF0F3),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Color(0xFFECF0F3),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: 60.r,
                        // width: 250.r,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(borderRadius_8),
                          color: const Color(0xFFECF0F3),
                        ),
                      ),
                      SizedBox(
                        height: 8.r,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: 18.r,
                            width: 40.r,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.r),
                              color: const Color(0xFFECF0F3),
                            ),
                          ),
                          Container(
                            height: 18.r,
                            width: 40.r,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.r),
                              color: const Color(0xFFECF0F3),
                            ),
                          ),
                          Container(
                            height: 18.r,
                            width: 40.r,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.r),
                              color: const Color(0xFFECF0F3),
                            ),
                          ),
                          Container(
                            height: 18.r,
                            width: 40.r,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.r),
                              color: Colors.transparent,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        });
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!, //Color(0xFFECF0F3),
      highlightColor: Colors.grey[400]!,
      period: const Duration(milliseconds: 800),
      child: ListView.builder(
          itemCount: 5,
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: distance_15, vertical: distance_10),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: <Widget>[
                  //avatar
                  Container(
                    height: 60,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFECF0F3),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundColor: Color(0xFFECF0F3),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 60,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(borderRadius_8),
                        color: const Color(0xFFECF0F3),
                      ),
                    ),
                  )
                ],
              ),
            );
          }),
    );
  }
}

class UsersSkeleton extends StatelessWidget {
  final double? trailingButtonWidth;
  final double? trailingButtonHeight;
  final double? trailingButtonRadius;
  final EdgeInsets? trailingButtonPadding;
  const UsersSkeleton(
      {Key? key, this.trailingButtonWidth, this.trailingButtonHeight, this.trailingButtonRadius, this.trailingButtonPadding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: distance_40,
          width: distance_40,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFECF0F3),
          ),
        ),
        const SizedBox(width: distance_12),
        Expanded(
          child: Container(
            height: 18,
            width: MediaQuery.sizeOf(context).width * 0.3,
            // width: 245,
            decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(borderRadius_4)),
          ),
        ),
        const SizedBox(width: distance_12),
        Container(
          height: trailingButtonHeight ?? 20,
          width: trailingButtonWidth ?? 20,
          margin: trailingButtonPadding,
          decoration:
              BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(trailingButtonRadius ?? borderRadius_4)),
        ),
      ],
    );
  }
}

class PendingUsersSkeleton extends StatelessWidget {
  final double? trailingButtonWidth;
  final double? trailingButtonHeight;
  final double? trailingButtonRadius;
  final EdgeInsets? trailingButtonPadding;
  const PendingUsersSkeleton(
      {Key? key, this.trailingButtonWidth, this.trailingButtonHeight, this.trailingButtonRadius, this.trailingButtonPadding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              backgroundColor: kBaseGrey,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: distance_16,
                          width: distance_70,
                          color: const Color(0xFFECF0F3),
                        ),
                        const Spacer(),
                        Container(
                          height: distance_16,
                          width: distance_30,
                          color: const Color(0xFFECF0F3),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GayaButton(
                            width: MediaQuery.sizeOf(context).width * 0.3,
                            height: 40,
                            title: "",
                            primaryColor: kBaseGrey,
                            textStyle: GayaTypography.subtitleMedium,
                            borderColor: kTransparentColor),
                        const SizedBox(
                          width: 10,
                        ),
                        GayaButton(
                            width: MediaQuery.sizeOf(context).width * 0.3,
                            height: 40,
                            title: "",
                            primaryColor: kBaseGrey,
                            textStyle: GayaTypography.subtitleMedium,
                            borderColor: kTransparentColor)
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        const Divider(
          color: kBaseGrey,
          thickness: 1.5,
        ),
      ],
    );
  }
}

class MessageSkeleton extends StatelessWidget {
  const MessageSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: distance_50,
              width: distance_50,
              decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(1000)),
            ),
            const SizedBox(width: distance_15),
            Expanded(
              child: SizedBox(
                // width: MediaQuery.sizeOf(context).width * 0.6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 18,
                          width: MediaQuery.sizeOf(context).width * 0.6,
                          // width: 245,
                          decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(borderRadius_4)),
                        ),
                        // const SizedBox(width: distance_15),
                        Container(
                          height: 18,
                          width: 18,
                          decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(borderRadius_4)),
                        ),
                      ],
                    ),
                    const SizedBox(height: distance_5),
                    Container(
                      height: 18,
                      width: MediaQuery.sizeOf(context).width * 0.3,
                      decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(borderRadius_4)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: distance_10,
        ),
        // Divider(
        //   thickness: 1,
        //   color: kSecondaryLightColor.withOpacity(1),
        // )
      ],
    );
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!, //Color(0xFFECF0F3),
      highlightColor: Colors.grey[400]!,
      period: const Duration(milliseconds: 800),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: distance_50,
                width: distance_50,
                decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(borderRadius_8)),
              ),
              // const SizedBox(width: distance_15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 18,
                        width: MediaQuery.sizeOf(context).width * 0.6,
                        // width: 245,
                        decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(borderRadius_4)),
                      ),
                      const SizedBox(width: distance_15),
                      Container(
                        height: 18,
                        width: 18,
                        decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(borderRadius_4)),
                      ),
                    ],
                  ),
                  const SizedBox(height: distance_5),
                  Container(
                    height: 18,
                    width: MediaQuery.sizeOf(context).width * 0.3,
                    decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(borderRadius_4)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: distance_10,
          ),
          // Divider(
          //   thickness: 1,
          //   color: kSecondaryLightColor.withOpacity(1),
          // )
        ],
      ),
    );
  }
}

class UserListTileSkeleton extends StatelessWidget {
  const UserListTileSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: distance_20, vertical: distance_10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                height: distance_30,
                width: distance_30,
                decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(borderRadius_8)),
              ),
              const SizedBox(width: distance_20),
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
            height: 30,
            width: 50,
            decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(borderRadius_4)),
          ),
        ],
      ),
    );
  }
}

class PendingPostsSkeleton extends StatelessWidget {
  const PendingPostsSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(left: distance_20, right: distance_20, top: distance_16, bottom: distance_16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: distance_20,
                width: distance_20,
                decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(borderRadius_8)),
              ),
              SizedBox(width: 5.w),
              Container(
                height: distance_20,
                width: MediaQuery.sizeOf(context).width * 0.3,
                decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(borderRadius_8)),
              ),
              const Spacer(),
              Container(
                height: distance_20,
                width: distance_20,
                decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(1000)),
              ),
            ],
          ),
        ),
        const Divider(
          height: 0.1,
        )
      ],
    );
  }
}

class CommunityTopicsSkeleton extends StatelessWidget {
  const CommunityTopicsSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          // color: Colors.red,
          padding: const EdgeInsets.all(12.0),
          height: 56.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              for (int i = 0; i < 5; i++)
                Container(
                  height: 32.0,
                  width: 50.0,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(1000)),
                ),
            ],
          ),
        ),
        const Divider(
          height: 0.1,
        )
      ],
    );
  }
}

class CountSkeletonWidget extends StatelessWidget {
  const CountSkeletonWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: 100,
      width: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 20,
            width: 20,
            decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(borderRadius_4)),
          ),
          const SizedBox(height: distance_5),
          Container(
            height: 18,
            width: 40,
            decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(borderRadius_4)),
          ),
        ],
      ),
    );
    return SizedBox(
      // height: 100,
      width: 100,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!, //Color(0xFFECF0F3),
        highlightColor: Colors.grey[400]!,
        period: const Duration(milliseconds: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(borderRadius_4)),
            ),
            const SizedBox(height: distance_5),
            Container(
              height: 18,
              width: 40,
              decoration: BoxDecoration(color: const Color(0xFFECF0F3), borderRadius: BorderRadius.circular(borderRadius_4)),
            ),
          ],
        ),
      ),
    );
  }
}
