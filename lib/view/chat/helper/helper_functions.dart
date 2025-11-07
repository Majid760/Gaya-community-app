import 'dart:io';

import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gaya/components/image_swiper.dart';
import 'package:gaya/components/profile_image_widget.dart';
import 'package:gaya/gen/assets.gen.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/view/chat/components/named_icon_widget.dart';
import 'package:gaya/view/chat/controllers/conversation_controller.dart';
import 'package:gaya/widgets/profile.widgets/button.widget.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../../shared/service/cache_service/cache_services.dart';
import '../../../utils/theme/app_colors.dart';

class CubeUtils {
  final CacheServices _cacheService = CacheServices();

  Future<String> downloadAndCachePdf({required String url}) async {
    return await _cacheService.downloadAndCachePdf(url: url);
  }

  Future<File?> generateThumbnailFile({required String url}) async {
    return await _cacheService.generateThumbnailFile(url: url);
  }

  Future<Uint8List?> generateLocalPdfThumbnail({required String url}) async {
    CacheServices cacheService = CacheServices();
    return await cacheService.generatelocalPdfThumbnail(url: url);
  }
}

enum MessageType { text, image, post, audio, video, community, document, link, nullAttachment }

MessageType getMessageTypes(String? type) {
  switch (type) {
    case "text":
      return MessageType.text;
    case "image":
      return MessageType.image;
    case "audio":
      return MessageType.audio;
    case "video":
      return MessageType.video;
    case "post":
      return MessageType.post;
    case "community":
      return MessageType.community;
    case "document":
      return MessageType.document;
    case "link":
      return MessageType.link;
    case "null":
      return MessageType.nullAttachment;
    default:
      return MessageType.text;
  }
}

// uri parse throwing error for emojis and emoticons so guarded with try cathc
bool isAbsolute(data) {
  try {
    return Uri.parse(data.toString()).isAbsolute;
  } catch (_) {
    return false;
  }
}

bool isListEmptyOrNull(List? list) {
  return list?.isEmpty ?? true;
}

Widget singleImage(List<dynamic> images, context) {
  return GestureDetector(
    onTap: () {
      Routes.openImages(urls: images as List<String>, index: 0, ctx: context);
    },
    child: Container(
        width: 150.w,
        height: 200.h,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12).r),
        child: ScrolledHero(
            tag: images.first, transitionOnUserGestures: true, child: PostImageWidget(url: images.first)) //PostImageModifiedWidget(url: e),
    ),
  );
}

// checkMessageType is a function that checks whether this is audio,vido,post,community....
MessageType checkMessageType(CubeMessage currentMessage) {
  MessageType typeOfAttachment =
  getMessageTypes(isListEmptyOrNull(currentMessage.attachments) ? 'null' : getAttachmentType(currentMessage));
  return typeOfAttachment;
}

String getAttachmentType(CubeMessage currentMessage) {
  // currentMessage.attachments!.first.type
  String? type = currentMessage.attachments!.first.type;
  if (type == null || type.isEmpty) {
    if (currentMessage.attachments!.first.name == 'community') {
      return 'community';
    } else if (currentMessage.attachments!.first.name == 'post') {
      return 'post';
    } else if (currentMessage.attachments!.first.name == 'document') {
      return 'document';
    } else if (currentMessage.attachments!.first.name == 'link') {
      return 'link';
    } else {}
  }
  return type!;
}

final List<NamedIconWidget> iconData = [
  NamedIconWidget(
    assetPath: Assets.assets.icons.cameraIcon,
    nameOfIcon: GayaStrings.photo.tr,
    onPressed: (cont) async {},
  ),
  NamedIconWidget(
    assetPath: Assets.assets.icons.videoPickerIcon,
    nameOfIcon: GayaStrings.video_library.tr,
    onPressed: (cont) async {},
  ),
  NamedIconWidget(
    assetPath: Assets.assets.icons.documentIcon,
    nameOfIcon: GayaStrings.document.tr,
    onPressed: (cont) async {},
  ),
];

typedef StringCallback = void Function(String reportMsg);

showAttachmentBottomSheet(BuildContext context, ConversationController conversationController) {
  HapticFeedback.mediumImpact();
  showModalBottomSheet(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15.0),
    ),
    context: context,
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          height: MediaQuery.sizeOf(context).height * 0.2,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 5.h,
                width: 40.w,
                margin: const EdgeInsets.only(top: 12, bottom: 8).r,
                decoration: ShapeDecoration(color: AppColors.divider, shape: const StadiumBorder()),
              ),
              const SizedBox(height: 10),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: iconData.map((icon) {
                    final index = iconData.indexOf(icon);
                    return CupertinoIconButton(
                        icon: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              icon.assetPath,
                              width: index == 0 ? 20.r : 24.r,
                              height: index == 0 ? 20.r : 24.r,
                              fit: BoxFit.scaleDown,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              icon.nameOfIcon,
                              textAlign: TextAlign.center,
                              style: CustomTypography.body4StyleHeight,
                            )
                          ],
                        ),
                        onPressed: () async {
                          if (index == 0) {
                            await conversationController.pickGalleryImage(context: context).then((messageImage) {
                              if (messageImage != null) {
                                Navigator.of(context).pop();
                              }
                            });
                          } else if (index == 1) {
                            await conversationController.pickVideo(context: context).then((messageImage) {
                              if (messageImage != null) {
                                Navigator.of(context).pop();
                              }
                            });
                          } else if (index == 2) {
                            await conversationController.getPdfDocument(context: context).then((pdfDocument) {
                              if (pdfDocument != null) {
                                Navigator.of(context).pop();
                              }
                            });
                          }
                        });
                  }).toList())
            ],
          ),
        ),
      );
    },
  );
}
