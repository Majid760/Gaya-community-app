// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/components/profile_image_widget.dart';
import 'package:gaya/components/snackbar.component.dart';
import 'package:gaya/controller/app_config_controller.dart';
import 'package:gaya/controller/communities.controller.dart';
import 'package:gaya/controller/group.controller.dart';
import 'package:gaya/gen/assets.gen.dart';
import 'package:gaya/model/communities.memebers.model.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/methods.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/view/chat/components/text_link_widget.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../components/skeleton.post.component.dart';
import '../../../model/community.model.dart';

class LoadCommunityMessage extends StatefulWidget {
  final String? communityId;
  final bool isCurrentUser;
  String sentTime = '';
  String deliveryStatus = '';

  ///Loads the community preview with future builder to avoid extra network calls
  LoadCommunityMessage({Key? key, required this.communityId, this.isCurrentUser = true}) : super(key: UniqueKey());

  @override
  State<LoadCommunityMessage> createState() => _LoadCommunityMessageState();
}

class _LoadCommunityMessageState extends State<LoadCommunityMessage> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> loadCommunityQuery;

  @override
  void initState() {
    super.initState();
    if (widget.communityId.isBlank == false) {
      loadCommunityQuery = FirebaseFirestore.instance.collection("communities").doc(widget.communityId).get();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.communityId.isBlank == true) {
      return const SizedBox();
    }
    return SizedBox(
      height: 200.h,
      width: 150.w,
      child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
          future: loadCommunityQuery,
          initialData: null,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const PostThumbnailSkeleton();
            }
            if (snapshot.hasError || snapshot.data == null || !snapshot.data!.exists || snapshot.data!.data() == null) {
              return Center(child: Text(GayaStrings.could_not_preview_community.tr));
            }
            Community createCommunityModel = Community.fromMap(snapshot.data!.data() as Map<String, dynamic>);
            return CommunityMessageThumbnail(createCommunityModel: createCommunityModel, isCurrentUser: widget.isCurrentUser);
          }),
    );
  }
}

//widget for community preview
class CommunityMessageThumbnail extends StatelessWidget {
  final Community createCommunityModel;
  final bool isCurrentUser;

  const CommunityMessageThumbnail({Key? key, required this.createCommunityModel, required this.isCurrentUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isCurrentUser == true) {
      //Current user View
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () async {
            if (createCommunityModel.communityId == null) return;
            return Methods.showModalSheetToJoinCommunity(communityId: createCommunityModel.communityId, ctx: context);
            /*GroupController groupController = GroupController();

            QuerySnapshot<Object?>? data = await groupController.checkJoinOrNot(createCommunityModel.communityId);

            bool isjoined = (data?.docs.length ?? 0) > 0;

            if (isjoined) {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                Methods.routeToGroup(community: createCommunityModel);
                // Routes.groupView(community: createCommunityModel);
              });
            } else {
              Services sharedServices = Services();

              //get total members
              try {
                int totalMembers = await sharedServices.getCommunityMembersCount(createCommunityModel.communityId ?? "");
                createCommunityModel.communityMembers = totalMembers;
              } catch (_) {}
              return Methods.showModalSheetToJoinCommunity(communityId: createCommunityModel.communityId, ctx: context);
              joinCommunitySheet(context, communityModel: createCommunityModel, onJoinedSuccessCallback: () {
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  Methods.routeToGroup(community: createCommunityModel);
                  // Routes.groupView(community: createCommunityModel);
                });
              });
            }*/
          },
          child: SizedBox(
            height: 188,
            width: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                PostImageWidget(
                  url: createCommunityModel.CommunityPic.toString(),
                  size: const Size(150, 188),
                ),
                Container(
                  color: const Color.fromRGBO(0, 0, 0, 0.4),
                  height: 188,
                  width: 150,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        createCommunityModel.communityDescription.toString().toString(),
                        style: CustomTypography.body2StyleWeight,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        createCommunityModel.communityName.toString(),
                        style: CustomTypography.body4StyleWhiteLessWeight,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      //Other user View
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () async {
            return Methods.showModalSheetToJoinCommunity(communityId: createCommunityModel.communityId, ctx: context);
/*
            {
              if (createCommunityModel.communityId == null) return;

              QuerySnapshot<Object?>? data = await GroupController().checkJoinOrNot(createCommunityModel.communityId);

              bool isjoined = (data?.docs.length ?? 0) > 0;

              if (isjoined) {
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  Methods.routeToGroup(community: createCommunityModel);

                  // Routes.groupView(community: createCommunityModel);
                });
              } else {
                Services sharedServices = Services();
                //get total members
                try {
                  int totalMembers = await sharedServices.getCommunityMembersCount(createCommunityModel.communityId ?? "");
                  createCommunityModel.communityMembers = totalMembers;
                } catch (_) {}
                return Methods.showModalSheetToJoinCommunity(communityId: createCommunityModel.communityId, ctx: context);
                joinCommunitySheet(context, communityModel: createCommunityModel, onJoinedSuccessCallback: () {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    Methods.routeToGroup(community: createCommunityModel);

                    // Routes.groupView(community: createCommunityModel);
                  });
                });
              }
            }*/
          },
          child: SizedBox(
            height: 188,
            width: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  memCacheHeight: 80,
                  memCacheWidth: 80,
                  fit: BoxFit.cover,
                  imageUrl: createCommunityModel.CommunityPic ?? "",
                  errorWidget: (context, url, error) => Container(
                    decoration: BoxDecoration(
                        // shape: BoxShape.circle,
                        color: Colors.grey.shade200),
                    child: const Center(
                        child: Icon(
                      Icons.error,
                      color: Colors.red,
                    )),
                  ),
                ),
                Container(
                  color: const Color.fromRGBO(0, 0, 0, 0.4),
                  height: 188,
                  width: 150,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        createCommunityModel.communityDescription.toString(),
                        style: CustomTypography.body2StyleWeight,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        createCommunityModel.communityName.toString(),
                        style: CustomTypography.body4StyleWhiteLessWeight,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  joinCommunitySheet(rootContext, {required Community communityModel, required onJoinedSuccessCallback}) async {
    // final rootContext = ;
    // String communityName, String communityType,
    //   int totalMembers, String communityDescription, String communityId,

    showModalBottomSheet(
      context: Get.context ?? rootContext,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        width: MediaQuery.sizeOf(context).width,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(13.0), topRight: Radius.circular(13.0)),
        ),
        child: StatefulBuilder(builder: (context, readMore) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(communityModel.communityName ?? '', style: CustomTypography.headingStyle),
                const SizedBox(height: 10),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      SvgPicture.asset(communityModel.communityType == "Private" ? "Assets/icons/lock.svg" : "Assets/icons/unlock.svg"),
                      const SizedBox(width: 10),
                      Text(communityModel.communityType ?? '', style: CustomTypography.dark12),
                      const VerticalDivider(color: kBaseGrey, thickness: 2),
                      Text("${communityModel.communityMembers ?? 0} members", style: CustomTypography.dark12),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(GayaStrings.about.tr, style: CustomTypography.body2StyleWeightBlack),
                const SizedBox(height: 20),
                Text(
                  communityModel.communityDescription ?? '',
                  textDirection: Methods.isRTL(communityModel.communityDescription ?? '') ? TextDirection.rtl : TextDirection.ltr,
                  style: CustomTypography.body4StyleLowWeight,
                  maxLines: context.read<CommunitiesController>().isReadMore == true ? null : 3,
                  overflow: context.read<CommunitiesController>().isReadMore == false ? TextOverflow.ellipsis : TextOverflow.visible,
                ),
                const SizedBox(height: 10),
                GayaButton(
                    onPressed: () {
                      readMore(() {
                        context.read<CommunitiesController>().isReadMore = !context.read<CommunitiesController>().isReadMore;
                      });
                    },
                    height: 40,
                    title: context.read<CommunitiesController>().isReadMore == false ? "Read more" : "Read less",
                    textStyle: CustomTypography.body4Style,
                    primaryColor: kBaseGrey,
                    borderColor: const Color.fromRGBO(255, 255, 255, 0.0)),
                const SizedBox(height: 10),
                Consumer<GroupController>(builder: (context, joinCommunity, _) {
                  bool isLoading = false;
                  return StatefulBuilder(
                    builder: (BuildContext context, update) {
                      return isLoading == true
                          ? const Center(child: CircularProgressIndicator.adaptive())
                          : FutureBuilder<CommunityMembership?>(
                              future: joinCommunity.getUserMembershipByCommunityId(communityId: communityModel.communityId ?? ''),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator.adaptive());
                                }
                                final CommunityMembership? communityMembership = snapshot.data;
                                return SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(backgroundColor: kprimaryColor),
                                    onPressed: () async {
                                      bool shouldNavigateToGroup = false;
                                      Community? community;

                                      try {
                                        isLoading = true;
                                        update(() {});
                                        community = communityModel;
                                        if (communityMembership?.isMember == true) {
                                          SchedulerBinding.instance
                                              .addPostFrameCallback((_) => Methods.routeToGroup(community: community!));
                                          return;
                                        }
                                        if (joinCommunity.communityType == "Public") {
                                          AppConfigurationController.to.joinPublicCommunity(communityModel);
                                          await joinCommunity.joinThePublicGroup(communityModel.communityId ?? '');
                                          await joinCommunity.addCommunityToUserList(
                                              communityModel.communityName ?? '', communityModel.communityId ?? '');
                                          shouldNavigateToGroup = true;

                                          snackBar(context, GayaStrings.join_community_success.tr, kprimaryColor);
                                          onJoinedSuccessCallback();
                                        } else {
                                          await joinCommunity.joinTheGroup(communityModel.communityId ?? '');
                                          await joinCommunity.sendCommunityJoiningApprovalNotificationToAdmin(community);

                                          snackBar(context, GayaStrings.request_send_success.tr, kprimaryColor);
                                        }
                                      } catch (e) {
                                        snackBar(context, GayaStrings.unable_join_community.tr, kRedColor);
                                      } finally {
                                        isLoading = false;
                                        try {
                                          update(() {});
                                        } on Exception catch (_) {
                                          // log(e.toString());
                                        }
                                        Navigator.pop(context);
                                        if (shouldNavigateToGroup && community != null) {
                                          SchedulerBinding.instance.addPostFrameCallback((_) {
                                            Methods.routeToGroup(community: community!);

                                            // Routes.groupView(community: community);
                                          });
                                        }
                                      }
                                    },
                                    label: Consumer<QuerySnapshot?>(builder: (context, value, _) {
                                      return value == null
                                          ? const SizedBox()
                                          : Text(
                                              (communityMembership?.isMember == true)
                                                  ? GayaStrings.view_community.tr
                                                  : communityMembership?.isMember == false
                                                      ? GayaStrings.waiting_approval.tr
                                                      : GayaStrings.join_community.tr,
                                              style: CustomTypography.body4StyleWhite);
                                    }),
                                    icon: SvgPicture.asset(Assets.assets.icons.communities, color: kWhiteColor),
                                  ),
                                );
                              });
                    },
                  );
                }),
                const SizedBox(height: distance_15),
              ],
            ),
          );
        }),
      ),
    );
  }
}

////////////////////

class LoadCommunityMessageWidget extends StatelessWidget {
  final CubeMessage? message;

  final bool isCurrentUser;
  String sentTime = '';
  String deliveryStatus = '';

  ///Loads the community preview with future builder to avoid extra network calls
  LoadCommunityMessageWidget(
      {Key? key, required this.message, this.isCurrentUser = true, required this.sentTime, required this.deliveryStatus})
      : super(key: UniqueKey());

  late Future<DocumentSnapshot<Map<String, dynamic>>> loadCommunityQuery;

  // @override
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200.h,
      width: 150.w,
      child: CommunityMessageThumbnailWidget(
        message: message,
        isCurrentUser: isCurrentUser,
        sentTime: sentTime,
        deliveryStatus: deliveryStatus,
      ),

      //   FutureBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
      //       future: loadCommunityQuery,
      //       initialData: null,
      //       builder: (context, snapshot) {
      //         if (snapshot.connectionState == ConnectionState.waiting) {
      //           return const CommunityMessageThumbnailSkeleton();
      //         }
      //         if (snapshot.hasError || snapshot.data == null || !snapshot.data!.exists || snapshot.data!.data() == null) {
      //           return Center(child: Text(GayaStrings.could_not_preview_community.tr));
      //         }
      //         Community createCommunityModel = Community.fromMap(snapshot.data!.data() as Map<String, dynamic>);
      //         return CommunityMessageThumbnail(createCommunityModel: createCommunityModel, isCurrentUser: widget.isCurrentUser);
      //       }),
    );
  }
}

//widget for community preview
class CommunityMessageThumbnailWidget extends StatelessWidget {
  // final Community createCommunityModel;
  final CubeMessage? message;

  final bool isCurrentUser;
  String sentTime = '';
  String deliveryStatus = '';
  CommunityMessageThumbnailWidget(
      {Key? key, required this.message, required this.isCurrentUser, required this.sentTime, required this.deliveryStatus})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Community createCommunityModel = Community(
        communityId: message?.properties['communityId'] ?? '',
        communityDescription: message?.properties['communityDescription'] ?? '',
        communityName: message?.properties['communityName'] ?? '',
        CommunityPic: message?.properties['communityImage'] ?? '');

    if (isCurrentUser == true) {
      //Current user View
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () async {
            if (createCommunityModel.communityId == null) return;
            return Methods.showModalSheetToJoinCommunity(communityId: createCommunityModel.communityId, ctx: context);
            /*GroupController groupController = GroupController();

            QuerySnapshot<Object?>? data = await groupController.checkJoinOrNot(createCommunityModel.communityId);

            bool isjoined = (data?.docs.length ?? 0) > 0;

            if (isjoined) {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                Methods.routeToGroup(community: createCommunityModel);
                // Routes.groupView(community: createCommunityModel);
              });
            } else {
              Services sharedServices = Services();

              //get total members
              try {
                int totalMembers = await sharedServices.getCommunityMembersCount(createCommunityModel.communityId ?? "");
                createCommunityModel.communityMembers = totalMembers;
              } catch (_) {}
              return Methods.showModalSheetToJoinCommunity(communityId: createCommunityModel.communityId, ctx: context);
              joinCommunitySheet(context, communityModel: createCommunityModel, onJoinedSuccessCallback: () {
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  Methods.routeToGroup(community: createCommunityModel);
                  // Routes.groupView(community: createCommunityModel);
                });
              });
            }*/
          },
          child: SizedBox(
            height: 188,
            width: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                PostImageWidget(
                  url: createCommunityModel.CommunityPic.toString(),
                  size: const Size(150, 188),
                ),
                Container(
                  color: const Color.fromRGBO(0, 0, 0, 0.4),
                  height: 188,
                  width: 150,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        createCommunityModel.communityDescription.toString().toString(),
                        style: CustomTypography.body2StyleWeight,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        createCommunityModel.communityName.toString(),
                        style: CustomTypography.body4StyleWhiteLessWeight,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
                Positioned(
                    bottom: 4.r,
                    right: 4.r,
                    child: Row(
                      children: [
                        Text(
                          sentTime,
                          style: TextStyle(color: AppColors.white, fontSize: 10.0.sp, fontStyle: FontStyle.italic),
                        ),
                        (isCurrentUser)
                            ? Row(
                                children: [
                                  SizedBox(
                                    width: 4.r,
                                  ),
                                  getReadDeliveredWidget(deliveryStatus),
                                ],
                              )
                            : const SizedBox.shrink()
                      ],
                    ))
              ],
            ),
          ),
        ),
      );
    } else {
      //Other user View
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () async {
            return Methods.showModalSheetToJoinCommunity(communityId: createCommunityModel.communityId, ctx: context);
/*
            {
              if (createCommunityModel.communityId == null) return;

              QuerySnapshot<Object?>? data = await GroupController().checkJoinOrNot(createCommunityModel.communityId);

              bool isjoined = (data?.docs.length ?? 0) > 0;

              if (isjoined) {
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  Methods.routeToGroup(community: createCommunityModel);

                  // Routes.groupView(community: createCommunityModel);
                });
              } else {
                Services sharedServices = Services();
                //get total members
                try {
                  int totalMembers = await sharedServices.getCommunityMembersCount(createCommunityModel.communityId ?? "");
                  createCommunityModel.communityMembers = totalMembers;
                } catch (_) {}
                return Methods.showModalSheetToJoinCommunity(communityId: createCommunityModel.communityId, ctx: context);
                joinCommunitySheet(context, communityModel: createCommunityModel, onJoinedSuccessCallback: () {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    Methods.routeToGroup(community: createCommunityModel);

                    // Routes.groupView(community: createCommunityModel);
                  });
                });
              }
            }*/
          },
          child: SizedBox(
            height: 188,
            width: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  memCacheHeight: 80,
                  memCacheWidth: 80,
                  fit: BoxFit.cover,
                  imageUrl: createCommunityModel.CommunityPic ?? "",
                  errorWidget: (context, url, error) => Container(
                    decoration: BoxDecoration(
                        // shape: BoxShape.circle,
                        color: Colors.grey.shade200),
                    child: const Center(
                        child: Icon(
                      Icons.error,
                      color: Colors.red,
                    )),
                  ),
                ),
                Container(
                  color: const Color.fromRGBO(0, 0, 0, 0.4),
                  height: 188,
                  width: 150,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        createCommunityModel.communityDescription.toString(),
                        style: CustomTypography.body2StyleWeight,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        createCommunityModel.communityName.toString(),
                        style: CustomTypography.body4StyleWhiteLessWeight,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
                Positioned(
                    bottom: 4.r,
                    right: 4.r,
                    child: Row(
                      children: [
                        Text(
                          sentTime,
                          style: TextStyle(color: AppColors.white, fontSize: 10.0.sp, fontStyle: FontStyle.italic),
                        ),
                        (isCurrentUser)
                            ? Row(
                                children: [
                                  SizedBox(
                                    width: 4.r,
                                  ),
                                  getReadDeliveredWidget(deliveryStatus),
                                ],
                              )
                            : const SizedBox.shrink()
                      ],
                    ))
              ],
            ),
          ),
        ),
      );
    }
  }

  joinCommunitySheet(rootContext, {required Community communityModel, required onJoinedSuccessCallback}) async {
    // final rootContext = ;
    // String communityName, String communityType,
    //   int totalMembers, String communityDescription, String communityId,

    showModalBottomSheet(
      context: Get.context ?? rootContext,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        width: MediaQuery.sizeOf(context).width,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(13.0), topRight: Radius.circular(13.0)),
        ),
        child: StatefulBuilder(builder: (context, readMore) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(communityModel.communityName ?? '', style: CustomTypography.headingStyle),
                const SizedBox(height: 10),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      communityModel.communityType == "Private" ? SvgIconWidget.lockOutline1() : SvgIconWidget.lockUnlockedOutline(),
                      // SvgPicture.asset(communityModel.communityType == "Private" ? "Assets/icons/lock.svg" : "Assets/icons/unlock.svg"),
                      const SizedBox(width: 10),
                      Text(communityModel.communityType ?? '', style: CustomTypography.dark12),
                      const VerticalDivider(color: kBaseGrey, thickness: 2),
                      Text("${communityModel.communityMembers ?? 0} members", style: CustomTypography.dark12),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(GayaStrings.about.tr, style: CustomTypography.body2StyleWeightBlack),
                const SizedBox(height: 20),
                Text(
                  communityModel.communityDescription ?? '',
                  textDirection: Methods.isRTL(communityModel.communityDescription ?? '') ? TextDirection.rtl : TextDirection.ltr,
                  style: CustomTypography.body4StyleLowWeight,
                  maxLines: context.read<CommunitiesController>().isReadMore == true ? null : 3,
                  overflow: context.read<CommunitiesController>().isReadMore == false ? TextOverflow.ellipsis : TextOverflow.visible,
                ),
                const SizedBox(height: 10),
                GayaButton(
                    onPressed: () {
                      readMore(() {
                        context.read<CommunitiesController>().isReadMore = !context.read<CommunitiesController>().isReadMore;
                      });
                    },
                    height: 40,
                    title: context.read<CommunitiesController>().isReadMore == false ? "Read more" : "Read less",
                    textStyle: CustomTypography.body4Style,
                    primaryColor: kBaseGrey,
                    borderColor: const Color.fromRGBO(255, 255, 255, 0.0)),
                const SizedBox(height: 10),
                Consumer<GroupController>(builder: (context, joinCommunity, _) {
                  bool isLoading = false;
                  return StatefulBuilder(
                    builder: (BuildContext context, update) {
                      return isLoading == true
                          ? const Center(child: CircularProgressIndicator.adaptive())
                          : FutureBuilder<CommunityMembership?>(
                              future: joinCommunity.getUserMembershipByCommunityId(communityId: communityModel.communityId ?? ''),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator.adaptive());
                                }
                                final CommunityMembership? communityMembership = snapshot.data;
                                return SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(backgroundColor: kprimaryColor),
                                      onPressed: () async {
                                        bool shouldNavigateToGroup = false;
                                        Community? community;

                                        try {
                                          isLoading = true;
                                          update(() {});
                                          community = communityModel;
                                          if (communityMembership?.isMember == true) {
                                            SchedulerBinding.instance
                                                .addPostFrameCallback((_) => Methods.routeToGroup(community: community!));
                                            return;
                                          }
                                          if (joinCommunity.communityType == "Public") {
                                            AppConfigurationController.to.joinPublicCommunity(communityModel);
                                            await joinCommunity.joinThePublicGroup(communityModel.communityId ?? '');
                                            await joinCommunity.addCommunityToUserList(
                                                communityModel.communityName ?? '', communityModel.communityId ?? '');
                                            shouldNavigateToGroup = true;

                                            snackBar(context, GayaStrings.join_community_success.tr, kprimaryColor);
                                            onJoinedSuccessCallback();
                                          } else {
                                            await joinCommunity.joinTheGroup(communityModel.communityId ?? '');
                                            await joinCommunity.sendCommunityJoiningApprovalNotificationToAdmin(community);

                                            snackBar(context, GayaStrings.request_send_success.tr, kprimaryColor);
                                          }
                                        } catch (e) {
                                          snackBar(context, GayaStrings.unable_join_community.tr, kRedColor);
                                        } finally {
                                          isLoading = false;
                                          try {
                                            update(() {});
                                          } on Exception catch (_) {
                                            // log(e.toString());
                                          }
                                          Navigator.pop(context);
                                          if (shouldNavigateToGroup && community != null) {
                                            SchedulerBinding.instance.addPostFrameCallback((_) {
                                              Methods.routeToGroup(community: community!);

                                              // Routes.groupView(community: community);
                                            });
                                          }
                                        }
                                      },
                                      label: Consumer<QuerySnapshot?>(builder: (context, value, _) {
                                        return value == null
                                            ? const SizedBox()
                                            : Text(
                                                (communityMembership?.isMember == true)
                                                    ? GayaStrings.view_community.tr
                                                    : communityMembership?.isMember == false
                                                        ? GayaStrings.waiting_approval.tr
                                                        : GayaStrings.join_community.tr,
                                                style: CustomTypography.body4StyleWhite);
                                      }),
                                      // icon: SvgPicture.asset(Assets.assets.icons.communities, color: kWhiteColor),
                                      icon: SvgIconWidget.usersPlusOutline(color: kWhiteColor)),
                                );
                              });
                    },
                  );
                }),
                const SizedBox(height: distance_15),
              ],
            ),
          );
        }),
      ),
    );
  }
}
