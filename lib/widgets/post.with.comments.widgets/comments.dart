import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/image_swiper.dart';
import 'package:gaya/components/profile_image_widget.dart';
import 'package:gaya/gen/assets.gen.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/shared/view/widget/pdf_view_widget.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/gaya_text_widget.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/methods.dart';
import 'package:gaya/utils/strings.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../components/gaya_play_button.dart';
import '../../view/comments/view/video_player_from_url.dart';

class CommentSection extends StatelessWidget {
  const CommentSection({
    Key? key,
    this.name,
    this.content,
    this.time,
    this.profilepic,
    this.uId,
    this.userUid,
    this.anonymousPic,
    this.userOntap,
    this.nameOnTap,
    this.showDialogBox,
    this.videoUrl,
    this.photoUrl,
    this.photoFile,
    this.videoFile,
    this.mentionedListUsers,
    this.pdfFiles,
    this.gender,
    this.postId = '',
    this.documentFile,
  }) : super(key: key);
  final String postId;
  final String? name;
  final String? content;
  final String? profilepic;
  final String? time;
  final String? uId;
  final String? userUid;
  final bool? anonymousPic;
  final VoidCallback? userOntap, nameOnTap, showDialogBox;
  final String? photoUrl;
  final File? photoFile;
  final Map<String, dynamic>? videoUrl;
  final File? videoFile;
  final File? documentFile;
  final String? gender;
  final List<Map<String, dynamic>>? mentionedListUsers;
  final List<Map<String, dynamic>>? pdfFiles;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    (uId == userUid && anonymousPic == true)
                        ? CircleAvatar(
                            radius: 20,
                            backgroundColor: kBaseGrey,
                            backgroundImage: AssetImage(
                              gender == null
                                  ? "Assets/images/anonymous_user.png"
                                  : gender == 'male'
                                      ? "Assets/images/anonymous_boy.png"
                                      : gender == 'female'
                                          ? "Assets/images/anonymous_girl.png"
                                          : "Assets/images/anonymous_user.png",
                            ),
                          )
                        : profilepic == ''
                            ? GestureDetector(
                                onTap: userOntap,
                                child: const CircleAvatar(
                                  radius: 16,
                                  backgroundColor: kBaseGrey,
                                  backgroundImage: AssetImage('Assets/images/user.png'),
                                ),
                              )
                            : GestureDetector(
                                onTap: userOntap,
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: kBaseGrey,
                                  child: CachedNetworkImage(
                                    memCacheHeight: 50,
                                    memCacheWidth: 50,
                                    imageUrl: profilepic ?? '',
                                    imageBuilder: (context, imageProvider) {
                                      return Container(
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle, image: DecorationImage(image: imageProvider, fit: BoxFit.cover)),
                                      );
                                    },
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) => Image.asset(Assets.assets.images.userDefault),
                                    placeholder: (context, url) => Image.asset(Assets.assets.images.userDefault),
                                  ),
                                ),
                              ),
                    const SizedBox(width: distance_10),
                    Expanded(
                      child: GestureDetector(
                        onLongPress: showDialogBox,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: distance_12, vertical: distance_8).r,
                          width: double.infinity,
                          decoration: BoxDecoration(color: kBaseGrey, borderRadius: BorderRadius.circular(borderRadius_8)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: InkWell(
                                          onTap: (uId == userUid && anonymousPic == true) ? null : nameOnTap,
                                          child: Text(
                                            (uId == userUid && anonymousPic == true)
                                                ? gender == null
                                                    ? anonymousUser
                                                    : gender == 'male'
                                                        ? anonymousBoy
                                                        : gender == 'female'
                                                            ? anonymousGirl
                                                            : anonymousUser
                                                : name ?? "",
                                            style: CustomTypography.titleStyleBlack,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(time.toString(), style: CustomTypography.body3Style),
                                    ],
                                  ),
                                  SizedBox(height: distance_5.r),
                                  (mentionedListUsers != null && mentionedListUsers!.isNotEmpty)
                                      ? GayaTextWidget(content, mentionedUsers: mentionedListUsers)
                                      : content != null
                                          ? Align(
                                              alignment: Methods.isRTL((content ?? "")) ? Alignment.centerRight : Alignment.centerLeft,
                                              child: GayaTextWidget(
                                                content ?? "",
                                                style: CustomTypography.postCaptionStyle,
                                                colorClickableText: kprimaryColor,
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                  if (photoUrl != null || photoFile != null)
                                    Column(
                                      children: [
                                        const SizedBox(height: distance_10),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: ScrolledHero(
                                            tag: photoUrl ?? photoFile.toString(),
                                            child: GestureDetector(
                                              onTap: () => Routes.openImages(urls: [photoUrl!], index: 0, ctx: context),
                                              child: SizedBox(
                                                height: 132.h,
                                                width: 163.w,
                                                child: photoFile != null
                                                    ? Image.file(photoFile!, fit: BoxFit.fill, height: 132.h, width: 163.w)
                                                    : PostImageWidget(url: photoUrl, fit: BoxFit.cover, height: 132, width: 163),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (videoFile != null ||
                                      (videoUrl != null && videoUrl!['videoUrl'] != null && videoUrl!['videoUrl'].toString().isNotEmpty))
                                    Column(
                                      children: [
                                        const SizedBox(height: distance_10),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: InkWell(
                                            onTap: () {
                                              if (videoUrl != null &&
                                                  videoUrl!['videoUrl'] != null &&
                                                  videoUrl!['videoUrl'].toString().isNotEmpty) {
                                                Routes.videoPlayerView(url: videoUrl!['videoUrl']);
                                              }
                                            },
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                SizedBox(
                                                  height: 132,
                                                  width: 163,
                                                  child: videoFile != null
                                                      ? VideoPlayerFromUrl(localFile: videoFile!, url: '')
                                                      : PostImageWidget(
                                                          url: videoUrl!['thumbnailUrl'], fit: BoxFit.fill, height: 132, width: 163),
                                                ),
                                                const GayaPlayButtonWidget(iconPath: "Assets/icons/play_button.svg")
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  documentFile != null && pdfFiles?.isEmpty == true
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: LocalCustomCommentPdfviewWidget(
                                            path: documentFile?.path ?? "",
                                            documentTitle: '${GayaStrings.loading_txt.tr}...',
                                            width: 289.w,
                                          ))
                                      : (pdfFiles?.isNotEmpty ?? false)
                                          ? Column(
                                              children: [
                                                const SizedBox(height: distance_10),
                                                PdfCommentViewWidget(
                                                  path: pdfFiles?.first['fileUrl'] ?? '',
                                                  title: pdfFiles?.first['title'] ?? '',
                                                  filename: pdfFiles?.first['fileName'] ?? '',
                                                  thumbnailUrl: pdfFiles?.first['thumbnail'] ?? '',
                                                  postId: postId,
                                                  width: 289.w,
                                                )
                                                // ClipRRect(
                                                //   borderRadius: BorderRadius.circular(4),
                                                //   child: ScrolledHero(
                                                //     topOffset: 54,
                                                //     bottomOffset: 0,
                                                //     tag: photoUrl ?? photoFile.toString(),
                                                //     child: GestureDetector(
                                                //       onTap: () {},
                                                //       child: SizedBox(
                                                //         height: 177.h,
                                                //         width: 289.w,
                                                //         child: pdfFiles?.first['thumbnail'] != null
                                                //             ? Image.file(pdfFiles?.first['thumbnail'], fit: BoxFit.fill, height: 132.h, width: 163.w)
                                                //             : PostImageWidget(url: photoUrl, fit: BoxFit.cover, height: 132, width: 163),
                                                //       ),
                                                //     ),
                                                //   ),
                                                // ),
                                              ],
                                            )
                                          : const SizedBox.shrink()
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
            // SizedBox(
            //   height: distance_5.r,
            // ),
          ],
        ),
        if (videoFile != null || photoFile != null)
          Positioned.fill(
              child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200.withOpacity(0.5),
              borderRadius: BorderRadius.circular(borderRadius_8),
            ),
          )),
      ],
    );
  }
}
