import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/controller/message.controller.dart';
import 'package:gaya/gen/assets.gen.dart';
import 'package:gaya/model/messaging.model/messages.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/utils/helper/helper.functions.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/show.full.picture.dart';
import '../../model/user.model.dart';
import '../../utils/const.dart';
import '../../utils/methods.dart';
import '../../utils/textstyles.dart';
import '../../view/messaging/components/load_message_as_communitypreview.dart';
import '../../view/messaging/components/load_message_as_postpreview.dart';
import 'currentuser.messages.section.dart';
import 'package:gaya/routing/routes.dart' as route;

class OtherUserMessageSection extends StatelessWidget {
  final String profilePicture;
  final String uid;
  final MessageModel currentMessage;
  final int index;
  final MessageController messageController;
  final List<DocumentSnapshot<Object?>> listenForChat;

  const OtherUserMessageSection(
      {super.key,
      required this.profilePicture,
      required this.uid,
      required this.currentMessage,
      required this.index,
      required this.messageController,
      required this.listenForChat});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: distance_10),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Row(
          children: [
            index == 0
                ? profilePicture == ''
                    ? buildWithOnTapDp(
                        child: const CircleAvatar(radius: 10, backgroundImage: AssetImage('Assets/images/user.png')),
                        onTap: () => openProfile(uid: uid, name: "", profilepic: profilePicture, context: context))
                    : buildWithOnTapDp(
                        onTap: () => openProfile(uid: uid, name: "", profilepic: profilePicture, context: context),
                        child: CircleAvatar(
                          radius: 10,
                          child: CachedNetworkImage(
                            memCacheHeight: 50,
                            memCacheWidth: 50,
                            imageUrl: profilePicture,
                            imageBuilder: (context, imageProvider) {
                              return Container(
                                decoration:
                                    BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: imageProvider, fit: BoxFit.cover)),
                              );
                            },
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(
                              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade200),
                              child: const Center(child: Icon(Icons.error, color: Colors.red)),
                            ),
                            placeholder: (context, url) => Image.asset(Assets.assets.images.userDefault),
                          ),
                        ),
                      )
                : (listenForChat[index - 1 < 0 ? 0 : index - 1]['sender'] != uid)
                    ? profilePicture == ''
                        ? buildWithOnTapDp(
                            child: const CircleAvatar(radius: 10, backgroundImage: AssetImage('Assets/images/user.png')),
                            onTap: () => openProfile(uid: uid, name: "", profilepic: profilePicture, context: context))
                        : buildWithOnTapDp(
                            onTap: () => openProfile(uid: uid, name: "", profilepic: profilePicture, context: context),
                            child: CircleAvatar(
                              radius: 10,
                              child: CachedNetworkImage(
                                memCacheHeight: 50,
                                memCacheWidth: 50,
                                imageUrl: profilePicture,
                                imageBuilder: (context, imageProvider) {
                                  return Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle, image: DecorationImage(image: imageProvider, fit: BoxFit.cover)),
                                  );
                                },
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => Container(
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade200),
                                  child: const Center(child: Icon(Icons.error, color: Colors.red)),
                                ),
                                placeholder: (context, url) => Image.asset(Assets.assets.images.userDefault),
                              ),
                            ),
                          )
                    : buildWithOnTapDp(
                        child: const CircleAvatar(
                          radius: 10,
                          backgroundColor: kTransparentColor,
                          foregroundColor: kTransparentColor,
                        ),
                        onTap: null),
            const SizedBox(width: 10),
            currentMessage.message.toString().length > 30
                ? Expanded(
                    child: Container(
                      alignment: Methods.isRTL(currentMessage.message ?? "") ? Alignment.centerRight : Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: distance_20, vertical: distance_10),
                      decoration: BoxDecoration(
                          color: (currentMessage.messageType == MessageType.post || currentMessage.messageType == MessageType.community)
                              ? kTransparentColor
                              : isAbsolute(currentMessage.message.toString())
                                  ? kTransparentColor
                                  : kBaseGrey,
                          borderRadius: isAbsolute(currentMessage.message.toString())
                              ? BorderRadius.circular(borderRadius_8)
                              : const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(16),
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16))),
                      child: currentMessage.messageType == MessageType.community
                          ? LoadCommunityMessage(communityId: currentMessage.message)
                          : currentMessage.messageType == MessageType.post
                              ? LoadPostMessage(postId: currentMessage.message, isCurrentUser: false)
                              : currentMessage.messageType == MessageType.post
                                  ? LoadPostMessage(postId: currentMessage.message, isCurrentUser: false)
                                  : isAbsolute(currentMessage.message.toString())
                                      ? CachedNetworkImage(
                                          memCacheHeight: 50,
                                          memCacheWidth: 50,
                                          imageUrl: currentMessage.message.toString(),
                                          fit: BoxFit.cover,
                                          imageBuilder: (BuildContext ctx, img) {
                                            return GestureDetector(
                                              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                                                  builder: (context) => FullPicture(photo: currentMessage.message.toString()))),
                                              child: SizedBox(
                                                height: 150,
                                                width: 150,
                                                // constraints: const BoxConstraints(maxWidth: 150, maxHeight: 150),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(borderRadius_8),
                                                  child: Image.network(
                                                    currentMessage.message.toString(),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          // imageBuilder: (BuildContext ctx, img) {
                                          //   return SizedBox(
                                          //       height: 150,
                                          //       child: ClipRRect(
                                          //           borderRadius: BorderRadius.circular(8),
                                          //           child: GestureDetector(
                                          //               onTap: () => Navigator.of(context).push(MaterialPageRoute(
                                          //                   builder: (context) => FullPicture(photo: currentMessage.message.toString()))),
                                          //               child: Container(
                                          //                 constraints: const BoxConstraints(maxHeight: 150, maxWidth: 150),
                                          //                 decoration: BoxDecoration(image: DecorationImage(image: img)),
                                          //               ))));
                                          // },
                                          errorWidget: (_, __, ___) {
                                            print("error builder otheruserdart");
                                            return InkWell(
                                                onTap: () {
                                                  launchUrl(Uri.parse(currentMessage.message.toString()),
                                                      mode: LaunchMode.externalApplication);
                                                },
                                                child: Container(
                                                  alignment: Alignment.centerLeft,
                                                  padding: const EdgeInsets.symmetric(horizontal: distance_20, vertical: distance_10),
                                                  decoration: const BoxDecoration(
                                                      color: kBaseGrey,
                                                      borderRadius: BorderRadius.only(
                                                          topLeft: Radius.circular(4),
                                                          topRight: Radius.circular(16),
                                                          bottomLeft: Radius.circular(16),
                                                          bottomRight: Radius.circular(16))),
                                                  child: Text(
                                                    currentMessage.message.toString(),
                                                    style: const TextStyle(
                                                      color: Colors.blueAccent,
                                                      fontFamily: GayaFontTheme.primaryFont,
                                                    ),
                                                  ),
                                                ));
                                          },
                                        )
                                      : GetUtils.isURL(currentMessage.message.toString())
                                          ? InkWell(
                                              onTap: () {
                                                String url = currentMessage.message.toString();
                                                if (url.contains("http")) {
                                                  Methods.launchMyUrl(url, context: context);
                                                } else {
                                                  url = "https://$url";
                                                  Methods.launchMyUrl(url, context: context);
                                                }
                                              },
                                              child: SelectableText(
                                                currentMessage.message.toString(),
                                                style: const TextStyle(
                                                  color: Colors.blueAccent,
                                                  fontFamily: GayaFontTheme.primaryFont,
                                                ),
                                              ))
                                          : SelectableText(
                                              currentMessage.message.toString(),
                                              textDirection:
                                                  Methods.isRTL(currentMessage.message ?? "") ? TextDirection.rtl : TextDirection.ltr,
                                            ),
                    ),
                  )
                : Container(
                    alignment: Methods.isRTL(currentMessage.message ?? "") ? Alignment.centerRight : Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(horizontal: distance_20, vertical: distance_12.h),
                    decoration: BoxDecoration(
                        color: currentMessage.messageType == MessageType.post || currentMessage.messageType == MessageType.community
                            ? kTransparentColor
                            : isAbsolute(currentMessage.message.toString())
                                ? kTransparentColor
                                : kBaseGrey,
                        borderRadius: isAbsolute(currentMessage.message.toString())
                            ? BorderRadius.circular(borderRadius_8)
                            : const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16))),
                    child: currentMessage.messageType == MessageType.community
                        ? LoadCommunityMessage(communityId: currentMessage.message)
                        : currentMessage.messageType == MessageType.community
                            ? LoadCommunityMessage(communityId: currentMessage.message)
                            : currentMessage.messageType == MessageType.post
                                ? LoadPostMessage(postId: currentMessage.message, isCurrentUser: false)
                                : isAbsolute(currentMessage.message.toString())
                                    ? CachedNetworkImage(
                                        memCacheHeight: 50,
                                        memCacheWidth: 50,
                                        imageUrl: currentMessage.message.toString(),
                                        fit: BoxFit.cover,
                                        imageBuilder: (BuildContext ctx, img) {
                                          return SizedBox(
                                              height: 150,
                                              child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: GestureDetector(
                                                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                                                          builder: (context) => FullPicture(photo: currentMessage.message.toString()))),
                                                      child: Container(
                                                        constraints: const BoxConstraints(maxHeight: 150, maxWidth: 150).r,
                                                        decoration: BoxDecoration(image: DecorationImage(image: img)),
                                                      ))));
                                        },
                                        errorWidget: (_, __, ___) {
                                          print("error builder otheruserdart");
                                          return InkWell(
                                              onTap: () {
                                                launchUrl(Uri.parse(currentMessage.message.toString()),
                                                    mode: LaunchMode.externalApplication);
                                              },
                                              child: Container(
                                                alignment: Alignment.centerLeft,
                                                padding: const EdgeInsets.symmetric(horizontal: distance_20, vertical: distance_10),
                                                decoration: const BoxDecoration(
                                                    color: kBaseGrey,
                                                    borderRadius: BorderRadius.only(
                                                        topLeft: Radius.circular(4),
                                                        topRight: Radius.circular(16),
                                                        bottomLeft: Radius.circular(16),
                                                        bottomRight: Radius.circular(16))),
                                                child: SelectableText(
                                                  currentMessage.message.toString(),
                                                  style: const TextStyle(
                                                    color: Colors.blueAccent,
                                                    fontFamily: GayaFontTheme.primaryFont,
                                                  ),
                                                ),
                                              ));
                                        },
                                      )
                                    : GetUtils.isURL(currentMessage.message.toString())
                                        ? InkWell(
                                            onTap: () {
                                              String url = currentMessage.message.toString();
                                              if (url.contains("http")) {
                                                Methods.launchMyUrl(url, context: context);
                                              } else {
                                                url = "https://$url";
                                                Methods.launchMyUrl(url, context: context);
                                              }
                                            },
                                            child: SelectableText(
                                              currentMessage.message.toString(),
                                              style: const TextStyle(
                                                color: Colors.blueAccent,
                                                fontFamily: GayaFontTheme.primaryFont,
                                              ),
                                            ))
                                        : SelectableText(
                                            currentMessage.message.toString(),
                                            textDirection:
                                                Methods.isRTL(currentMessage.message ?? "") ? TextDirection.rtl : TextDirection.ltr,
                                          ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget buildWithOnTapDp({required Widget child, required VoidCallback? onTap}) {
    return InkWell(customBorder: const CircleBorder(), onTap: onTap, child: child);
  }

  void openProfile({required String uid, required String name, required String profilepic, required BuildContext context}) {
    final user = UserModel(uId: uid, name: name, profilePicture: profilepic);
    Routes.viewProfile(uid: user.uId, model: user);
  }
}
