// // ignore_for_file: use_build_context_synchronously

// import 'dart:io';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:gaya/components/button.component.dart';
// import 'package:gaya/components/snackbar.component.dart';
// import 'package:gaya/gen/assets.gen.dart';
// import 'package:gaya/model/community.model.dart';
// import 'package:gaya/model/create.post.model.dart';
// import 'package:gaya/shared/view/widget/gaya_alert_dialog.dart';
// import 'package:gaya/shared/view/widget/gaya_back_button.dart';
// import 'package:gaya/shared/view/widget/gaya_upload_document_madalsheet.dart';
// import 'package:gaya/shared/view/widget/pdf_view_widget.dart';
// import 'package:gaya/utils/app_data.dart';
// import 'package:gaya/utils/assets_icons.dart';
// import 'package:gaya/utils/const.dart';
// import 'package:gaya/utils/gaya_text_widget.dart';
// import 'package:gaya/utils/helper/pick.image.dart';
// import 'package:gaya/utils/language/translation.dart';
// import 'package:gaya/utils/methods.dart';
// import 'package:gaya/utils/textstyles.dart';
// import 'package:gaya/utils/theme/app_colors.dart';
// import 'package:gaya/utils/theme/app_spaces.dart';
// import 'package:gaya/utils/theme/app_typography.dart';
// import 'package:gaya/widgets/create_recipe_widgets/choose.group.sheet.dart';
// import 'package:gaya/widgets/create_recipe_widgets/multiple_files_post.dart';
// import 'package:gaya/widgets/create_recipe_widgets/pick.button.dart';
// import 'package:gaya/widgets/create_recipe_widgets/picked.video.widget.dart';
// import 'package:gaya/widgets/post.with.comments.widgets/reply_comment_post_widget.dart';
// import 'package:get/get.dart';
// import 'package:provider/provider.dart';

// import '../components/gradient_text_widget.dart';
// import '../controller/app_config_controller.dart';
// import '../controller/create.post.controller.dart';
// import '../model/communities.memebers.model.dart';
// import '../utils/enum.dart';
// import '../widgets/create_recipe_widgets/show.groups.dart';

// class CreatePostView extends StatefulWidget {
//   final Community? communityModel;
//   final PostCreationFrom from;
//   final PostReplyDataType? commentData;

//   const CreatePostView({Key? key, this.communityModel, this.commentData, required this.from}) : super(key: key);

//   @override
//   State<CreatePostView> createState() => _CreatePostViewState();
// }

// class _CreatePostViewState extends State<CreatePostView> {
//   late CreatePostController createPostController;
//   final user = FirebaseAuth.instance.currentUser;
//   late Future<List<Community>> joinedCommunitiesQuery;

//   @override
//   void initState() {
//     joinedCommunitiesQuery = AppConfigurationController.to.getMyJoinedCommunities();
//     createPostController = Provider.of<CreatePostController>(context, listen: false);
//     context.read<CreatePostController>().indexe = 0;
//     context.read<CreatePostController>().selectedCommunity.clear();
//     context.read<CreatePostController>().getAllUserCommunities();
//     context.read<CreatePostController>().userDetails();
//     context.read<CreatePostController>().userCommuniteis;
//     context.read<CreatePostController>().getAdmin(widget.communityModel?.communityId);
//     super.initState();
//   }

//   /// close keyboard before going from this screen

//   @override
//   void dispose() {
//     FocusManager.instance.primaryFocus?.unfocus();
//     super.dispose();
//   }

//   final ImagePickerHelper imagePickerHelper = ImagePickerHelper();

//   // checking changes while creating new post and resetting its state
//   void checkCreatePostChanges(context) async {
//     bool shouldPop = Provider.of<CreatePostController>(context, listen: false).shouldPop(context);
//     if (shouldPop) {
//       // ignore: use_build_context_synchronously
//       Navigator.pop(context);
//     } else {
//       // ignore: use_build_context_synchronously
//       showGayaAlertDialogButton(
//         context: context,
//         actionText: GayaStrings.discard_changes.tr,
//         tapOnYes: () async {
//           Navigator.pop(context);
//           await Provider.of<CreatePostController>(context, listen: false).resetState();
//           // ignore: use_build_context_synchronously
//           Navigator.pop(context);
//         },
//         tapOnNo: () {
//           Navigator.pop(context);
//         },
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final createPostController = Provider.of<CreatePostController>(context, listen: true);

//     return WillPopScope(
//         onWillPop: () async {
//           bool shouldPop = context.read<CreatePostController>().shouldPop(context);
//           if (shouldPop) return shouldPop;
//           // ignore: use_build_context_synchronously
//           showGayaAlertDialogButton(
//             context: context,
//             actionText: GayaStrings.discard_changes.tr,
//             tapOnYes: () async {
//               Navigator.pop(context);
//               await context.read<CreatePostController>().resetState();
//               // ignore: use_build_context_synchronously
//               Navigator.pop(context);
//             },
//             tapOnNo: () {
//               Navigator.pop(context);
//             },
//           );
//           return true;
//         },
//         child: Scaffold(
//             resizeToAvoidBottomInset: true,
//             appBar: AppBar(
//               systemOverlayStyle: SystemUiOverlayStyle.dark,
//               shape: Border(bottom: BorderSide(color: kBaseGrey.withOpacity(0.5))),
//               automaticallyImplyLeading: false,
//               leading: GayaBackButton(onPop: () => checkCreatePostChanges(context)),
//               iconTheme: const IconThemeData(color: kBlackColor),
//               actions: [
//                 Consumer<CreatePostController>(builder: (context, controller, _) {
//                   return createPostController.isloadingPost == true
//                       ? const Center(
//                           child: Padding(
//                             padding: EdgeInsets.only(right: 10),
//                             child: CircularProgressIndicator.adaptive(backgroundColor: kprimaryColor),
//                           ),
//                         )
//                       : TextButton(
//                           onPressed: (controller.aboutPostController.text.isNotEmpty)
//                               ? () async {
//                                   if (createPostController.selectedCommunity.isEmpty && widget.from == PostCreationFrom.Home) {
//                                     snackBar(context, GayaStrings.select_community.tr, kprimaryColor);
//                                   } else {
//                                     if (widget.from == PostCreationFrom.Home) {
//                                       await FirebaseFirestore.instance
//                                           .collection("communities")
//                                           .doc(createPostController.selectedCommunity[0].communityId)
//                                           .collection("communityMembers")
//                                           .where("isAdmin", isEqualTo: true)
//                                           .get()
//                                           .then(
//                                         (value) {
//                                           if (value.docs.isEmpty) return;
//                                           CommunityMembership communitiesMembers = CommunityMembership.fromMap(
//                                             value.docs[0].data(),
//                                           );
//                                           controller.communityAdmin = communitiesMembers.userUid;
//                                         },
//                                       );
//                                     }
//                                     await createPostController.postInCommunity(
//                                         context,
//                                         widget.from != PostCreationFrom.Home
//                                             ? widget.communityModel!
//                                             : createPostController.selectedCommunity[0],

//                                         ///TODO: refactor this check
//                                         /*  widget.fromHome == true
//                                           ? controller.communityAdmin == user?.uid
//                                               ? true
//                                               : false
//                                           : (controller.adminUid == user?.uid ||
//                                                   (widget.communityModel != null
//                                                       ? widget.communityModel!.moderators?.contains(user?.uid) ?? false
//                                                       : false) ||
//                                                   widget.communityModel?.isPostApprovalNeeded != true)
//                                               ? true
//                                               : false,*/
//                                         from: widget.from,
//                                         postTypeData: widget.commentData);
//                                     createPostController.aboutPostController.clear();
//                                   }
//                                 }
//                               : null,
//                           child: createPostController.shouldPop(context)
//                               ? Text(GayaStrings.post_done.tr, style: CustomTypography.body2StyleWeightkPrimary.copyWith(color: AppColors.secondary))
//                               : GradientTextWidget(
//                                   GayaStrings.post_done.tr,
//                                   style: CustomTypography.body2StyleWeightkPrimary,
//                                   gradient: AppColors.textGradient,
//                                 ));
//                 })
//               ],
//               title: Text(GayaStrings.create_post.tr, style: CustomTypography.bodyStyle),
//               centerTitle: true,
//               backgroundColor: kTransparentColor,
//               elevation: 0,
//             ),
//             body: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 0),
//               child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
//                 return SingleChildScrollView(
//                     reverse: true,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(height: distance_20),

//                         /// post anonymously
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: MySpaces.gap5).r,
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(GayaStrings.post_anonymously.tr, style: CustomTypography.body4StyleHeight),
//                               Consumer<CreatePostController>(builder: (context, switchController, _) {
//                                 return Switch.adaptive(
//                                   activeColor: kprimaryColor,
//                                   value: switchController.switchAnon,
//                                   onChanged: (isSwitched) {
//                                     if (isSwitched) {
//                                       showConfirmationModalSheetAnonymouslyPost(
//                                           context: context,
//                                           onSubmit: () {
//                                             Navigator.pop(context);
//                                             switchController.toggleSwitch(isSwitched);
//                                           });
//                                     } else {
//                                       switchController.toggleSwitch(isSwitched);
//                                     }
//                                   },
//                                 );
//                               })
//                             ],
//                           ),
//                         ),
//                         const Divider(),

//                         /// topics horizontal list
//                         Consumer<CreatePostController>(builder: (context, controller, _) {
//                           /// if topics are available and community is selected
//                           /// then show the topics of that community
//                           if ((widget.communityModel?.communityTopicList?.isNotEmpty ?? false)) {
//                             return Row(
//                               children: [
//                                 SizedBox(width: MediaQuery.sizeOf(context).width * 0.05),
//                                 SizedBox(
//                                     width: (MediaQuery.sizeOf(context).width * 0.13),
//                                     child: Text(GayaStrings.topic.tr, style: GayaTypography.subtitleMedium)),
//                                 SizedBox(
//                                   height: 40.h,
//                                   width: (MediaQuery.sizeOf(context).width * 0.82),
//                                   child: ListView.builder(
//                                       itemCount: widget.communityModel?.communityTopicList?.length ?? 0,
//                                       scrollDirection: Axis.horizontal,
//                                       physics: const BouncingScrollPhysics(),
//                                       // padding: const EdgeInsets.all(0),
//                                       itemBuilder: (ctx, index) {
//                                         final topicName = widget.communityModel?.communityTopicList?[index] ?? "";
//                                         bool isCurrentTopicSelected = createPostController.preSelectedTopics.contains(topicName);
//                                         return CommunityTopicListTile(
//                                             onPressed: (_) {
//                                               /// if already contains, remove it
//                                               if (createPostController.preSelectedTopics.contains(topicName)) {
//                                                 createPostController.preSelectedTopics.remove(topicName);
//                                                 setState(() {});
//                                                 return;
//                                               }

//                                               /// otherwise add it, clear list and add it
//                                               createPostController.preSelectedTopics.clear();
//                                               setState(() => createPostController.preSelectedTopics.add(topicName));
//                                             },
//                                             topicName: topicName,
//                                             topics: widget.communityModel?.communityTopicList ?? [],
//                                             isSelected: isCurrentTopicSelected,
//                                             backgroundColor: widget.communityModel?.communityThemeModel?.toColor);
//                                       }),
//                                 ),
//                               ],
//                             );
//                           }
//                           return const SizedBox();
//                         }),

//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: MySpaces.gap5).r,
//                           child: Column(
//                             children: [
//                               Row(
//                                 children: [
//                                   createPostController.profilePicture?.toString().trim().isBlank ?? true
//                                       ? CircleAvatar(backgroundColor: kBaseGrey, radius: 24, child: AppData.defaultUserProfileWidget())
//                                       : CircleAvatar(
//                                           backgroundColor: kBaseGrey,
//                                           radius: 24,
//                                           child: CachedNetworkImage(
//                                             memCacheHeight: 100,
//                                             memCacheWidth: 100,
//                                             imageUrl: createPostController.profilePicture ?? '',
//                                             imageBuilder: (context, imageProvider) {
//                                               return Container(
//                                                 decoration: BoxDecoration(
//                                                     shape: BoxShape.circle,
//                                                     image: DecorationImage(image: imageProvider, fit: BoxFit.cover)),
//                                               );
//                                             },
//                                             fit: BoxFit.cover,
//                                             errorWidget: (context, url, error) => AppData.defaultUserProfileWidget(),
//                                             placeholder: (context, url) => AppData.defaultUserProfileWidget(),
//                                           ),
//                                         ),
//                                   const SizedBox(width: distance_10),
//                                   Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Padding(
//                                         padding: const EdgeInsets.symmetric(horizontal: 4.0).r,
//                                         child: Text(createPostController.name ?? '', style: CustomTypography.bodyStyle),
//                                       ),
//                                       if (widget.from != PostCreationFrom.Home)
//                                         Padding(
//                                           padding: const EdgeInsets.symmetric(horizontal: 4.0).r,
//                                           child: Text("• ${widget.communityModel?.communityName}", style: CustomTypography.body1Style),
//                                         ),
//                                       const SizedBox(height: 5),
//                                       SizedBox(height: 5.h),
//                                       widget.from != PostCreationFrom.Home
//                                           ? const SizedBox.shrink()
//                                           : FutureBuilder<List<Community>?>(
//                                               future: joinedCommunitiesQuery,
//                                               builder: (ctx, snap) {
//                                                 if (snap.connectionState == ConnectionState.waiting) {
//                                                   return Container(
//                                                     height: 40.h,
//                                                     width: 150.w,
//                                                     decoration: BoxDecoration(
//                                                       color: kBaseGrey,
//                                                       borderRadius: BorderRadius.circular(12).r,
//                                                     ),
//                                                     child: const Center(child: CupertinoActivityIndicator()),
//                                                   );
//                                                 }
//                                                 final joinedCommunities = snap.data ?? [];
//                                                 return InkWell(
//                                                   onTap: () {
//                                                     if (joinedCommunities.isEmpty) {
//                                                       snackBar(context, GayaStrings.not_community_member.tr, kprimaryColor);
//                                                       return;
//                                                     }
//                                                     chooseGroup(
//                                                       context,
//                                                       createPostController,
//                                                       communities: joinedCommunities,
//                                                     );
//                                                   },
//                                                   child: Container(
//                                                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12).r,
//                                                     decoration: BoxDecoration(
//                                                       color: kBaseGrey,
//                                                       borderRadius: BorderRadius.circular(12).r,
//                                                     ),
//                                                     child: Row(
//                                                       children: [
//                                                         SvgIconWidget.usersFilled(height: 16, width: 16),
//                                                         // SvgPicture.asset(Assets.assets.icons.user_solid),
//                                                         const SizedBox(width: 15),
//                                                         Text(createPostController.selectedCommunity.isEmpty
//                                                             ? GayaStrings.select_community_txt.tr
//                                                             : createPostController.selectedCommunity[0].communityName ?? ""),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 );
//                                               }),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(
//                                 height: distance_10,
//                               ),
//                               TextFormField(
//                                 autofocus: true,
//                                 autocorrect: false,
//                                 enableSuggestions: true,
//                                 textDirection:
//                                     Methods.isRTL(createPostController.aboutPostController.text) ? TextDirection.rtl : TextDirection.ltr,
//                                 onChanged: (String value) {
//                                   createPostController.onChanged(value);
//                                 },
//                                 controller: createPostController.aboutPostController,
//                                 maxLines: null,
//                                 style: createPostController.aboutPostController.text.length > 120
//                                     ? CustomTypography.bodyStyle.copyWith(
//                                         fontSize: 14.sp,
//                                       )
//                                     : CustomTypography.bodyStyle.copyWith(
//                                         fontSize: 18.sp,
//                                       ),
//                                 decoration: InputDecoration(
//                                     hintStyle: CustomTypography.bodyStyle.copyWith(color: AppColors.secondary),
//                                     hintText:
//                                         (widget.commentData != null && widget.commentData?.postType == PostCreationFrom.postReply.name)
//                                             ? GayaStrings.add_comment.tr
//                                             : GayaStrings.talk_to.tr,
//                                     border: const OutlineInputBorder(borderSide: BorderSide.none)),
//                               ),
//                               const SizedBox(
//                                 height: distance_10,
//                               ),
//                               createPostController.images.isEmpty
//                                   ? const SizedBox.shrink()
//                                   : MultipleImageShow(
//                                       controller: createPostController,
//                                     ),
//                               Consumer<CreatePostController>(builder: (_, controller, __) {
//                                 return (controller.videoPlayerController != null && controller.videoFile != null)
//                                     ? VideoPlayerWidget(
//                                         controller: createPostController,
//                                       )
//                                     : const SizedBox.shrink();
//                               }),
//                               Consumer<CreatePostController>(builder: (_, controller, __) {
//                                 return (controller.pdfFiles.isNotEmpty && controller.documentUploadStatus == true)
//                                     ? LocalPdfviewWidget(
//                                         path: controller.pdfFiles.first.path,
//                                       )
//                                     : const SizedBox.shrink();
//                               }), // ],
//                               const SizedBox(
//                                 height: distance_20,
//                               ),
//                               createPostController.videoUploadingPercentage == null
//                                   ? const SizedBox.shrink()
//                                   : LinearProgressIndicator(value: createPostController.videoUploadingPercentage),
//                             ],
//                           ),
//                         ),
//                         widget.commentData?.mentionedUsersList != null
//                             ? ReplyCommentPostWidget(
//                                 commentData: widget.commentData,
//                               )
//                             : const SizedBox.shrink()
//                       ],
//                     ));
//               }),
//             ),
//             floatingActionButton: floatingPickButton(createPostController)));
//   }

// // IOS SHEET TO PICK
//   showIosStyleSheet(CreatePostController createPostController) {
//     final mediaPickerWidget = CupertinoActionSheet(
//       title: Text(GayaStrings.choose_media_type.tr,
//           style: GayaTypography.titleMedium.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w400)),
//       actions: [
//         CupertinoActionSheetAction(
//           child: CupertinoListTile(
//             title: Text(GayaStrings.pick_img.tr,
//                 style: GayaTypography.titleMedium.copyWith(color: AppColors.cupertinoBlue, fontWeight: FontWeight.w400)),
//             leading: SvgIconWidget.imageOutline(color: AppColors.cupertinoBlue),
//           ),
//           onPressed: () async {
//             final files = await imagePickerHelper.pickImage(multiple: true);
//             context.read<CreatePostController>().videoFile = null;
//             setState(() {
//               if (files.length > 4) {
//                 snackBar(context, GayaStrings.select_4_items.tr, kRedColor);
//               } else {
//                 createPostController.images.clear();
//                 createPostController.images.addAll(files.map((e) => File(e.path)).toList());
//               }
//             });
//             if (createPostController.images.isNotEmpty) {
//               await createPostController.cropPhoto();
//             }
//             Navigator.of(context, rootNavigator: true).pop("1");
//           },
//         ),
//         CupertinoActionSheetAction(
//           child: CupertinoListTile(
//             title: Text(GayaStrings.pick_video.tr,
//                 style: GayaTypography.titleMedium.copyWith(color: AppColors.cupertinoBlue, fontWeight: FontWeight.w400)),
//             // leading: SvgPicture.asset(Assets.assets.icons.videoPickerIcon, color: AppColors.cupertinoBlue),
//             leading: Icon(
//               Icons.video_collection_outlined,
//               color: AppColors.cupertinoBlue,
//               size: 24.r,
//             ), //SvgPicture.asset(Assets.assets.icons.videoPickerIcon),
//           ),
//           onPressed: () async {
//             Navigator.pop(context);
//             await createPostController.getVideo(context);
//           },
//         ),
// // pdf document from storage
//         CupertinoActionSheetAction(
//           child: CupertinoListTile(
//             title:
//                 Text('Document', style: GayaTypography.titleMedium.copyWith(color: AppColors.cupertinoBlue, fontWeight: FontWeight.w400)),
//             // leading: SvgPicture.asset(Assets.assets.icons.videoPickerIcon, color: AppColors.cupertinoBlue),
//             leading: SvgIconWidget.fileOutline(color: AppColors.cupertinoBlue),
//             // leading: GayaSvgAsset(
//             //   'Assets/images/doc.svg',
//             //   height: 24.r,
//             //   width: 24.r,
//             //   color: AppColors.cupertinoBlue,
//             // )
//           ),
//           onPressed: () async {
//             Navigator.pop(context);
//             final docFile = await createPostController.getPdfDocument(context);
//             if (docFile == null) return;
//             // ignore: use_build_context_synchronously
//             uploadDocumentModelSheet(context, onSubmit: (String reportMsg) async {
//               Navigator.pop(context);
//             });
//           },
//         ),
//       ],
//       cancelButton: CupertinoActionSheetAction(
//           child: Text(GayaStrings.cancel_txt.tr,
//               style: GayaTypography.titleMedium.copyWith(color: AppColors.error, fontWeight: FontWeight.w400)),
//           onPressed: () => Navigator.pop(context)),
//     );

//     showCupertinoModalPopup(context: context, builder: (BuildContext context) => mediaPickerWidget);
//   }

// // ANDROID SHEET TO PICK
//   showAndroidSheet(CreatePostController createPostController) {
//     final mediaPickerWidget = Material(
//       color: kWhiteColor,
//       child: SingleChildScrollView(
//         child: Column(
//           children: [
//             // image from gallery
//             ListTile(
//                 leading: SvgIconWidget.imageOutline(color: AppColors.primary),
//                 // leading: Icon(
//                 //   Icons.image,
//                 //   color: AppColors.primary,
//                 // ), //SvgPicture.asset(Assets.assets.icons.picturePickerIcon),
//                 title: Text(
//                   GayaStrings.pick_img.tr,
//                   style: GayaTypography.subtitleMedium,
//                 ),
//                 onTap: () async {
//                   final files = await imagePickerHelper.pickImage(multiple: true);
//                   context.read<CreatePostController>().videoFile = null;
//                   setState(() {
//                     if (files.length > 4) {
//                       snackBar(context, GayaStrings.select_4_items.tr, kRedColor);
//                     } else {
//                       createPostController.images.clear();
//                       createPostController.images.addAll(files.map((e) => File(e.path)).toList());
//                     }
//                   });
//                   if (createPostController.images.isNotEmpty) {
//                     await createPostController.cropPhoto();
//                   }
//                   Navigator.of(context, rootNavigator: true).pop("1");
//                 }),

//             // video from camera
//             ListTile(
//               onTap: () async {
//                 Navigator.pop(context);
//                 await createPostController.getVideo(context);
//               },
//               leading: Icon(
//                 Icons.video_collection_outlined,
//                 color: AppColors.primary,
//               ), //SvgPicture.asset(Assets.assets.icons.videoPickerIcon),
//               title: Text(GayaStrings.pick_video.tr, style: GayaTypography.subtitleMedium),
//             ),
//             // pdf document from storage
//             ListTile(
//               onTap: () async {
//                 Navigator.pop(context);
//                 final docFile = await createPostController.getPdfDocument(context);
//                 if (docFile == null) return;
//                 // ignore: use_build_context_synchronously
//                 uploadDocumentModelSheet(context, onSubmit: (String reportMsg) async {
//                   Navigator.pop(context);
//                 });
//               },
//               title: Text(GayaStrings.document.tr, style: GayaTypography.titleMedium.copyWith(fontWeight: FontWeight.w400)),
//               leading: SvgIconWidget.fileOutline(color: AppColors.primary),
//               // leading: GayaSvgAsset(
//               //   'Assets/images/doc.svg',
//               //   height: 20.r,
//               //   width: 20.r,
//               //   color: AppColors.primary,
//               // )
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10).r,
//               child: GayaButton(
//                   height: 40.h,
//                   borderColor: kTransparentColor,
//                   // textStyle: loginController.styleEmail,
//                   textStyle: GayaTypography.titleMedium.copyWith(color: AppColors.black, fontSize: 14.sp),
//                   title: GayaStrings.cancel_txt.tr,
//                   onPressed: () {
//                     Navigator.of(context, rootNavigator: true).pop("1");
//                   },
//                   primaryColor: AppColors.divider),
//             ),
//             SizedBox(
//               height: 15.h,
//             )
//           ],
//         ),
//       ),
//     );

//     Methods.showCircularModalSheet(context, mediaPickerWidget);
//   }

// // FLOATING BUTTON TO PICK
//   Widget floatingPickButton(CreatePostController createPostController) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: distance_40),
//       child: Row(
//         children: [
//           PickImageButtonWidget(onTap: () {
//             HapticFeedback.mediumImpact();
//             DeviceCheck.isIOS ? showIosStyleSheet(createPostController) : showAndroidSheet(createPostController);
//           }),
//           const SizedBox(
//             width: distance_10,
//           ),
//         ],
//       ),
//     );
//   }
// }

// showConfirmationModalSheetAnonymouslyPost({required BuildContext context, required VoidCallback onSubmit}) {
//   final gap = SizedBox(height: MySpaces.gap3.h);
//   return Methods.showCircularModalSheet(
//       context,
//       SingleChildScrollView(
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: MySpaces.gap5).r,
//               child: Text(GayaStrings.anonymous_post.tr, style: GayaTypography.h4),
//             ),
//             gap,
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: MySpaces.gap5).r,
//               child: Text(
//                 GayaStrings.anonymous_post_desc.tr,
//                 textAlign: TextAlign.center,
//                 style: GayaTypography.subtitleRegular.copyWith(color: AppColors.secondary),
//               ),
//             ),
//             gap,
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: MySpaces.gap5).r,
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SvgIconWidget.lockOutline1(),
//                   SizedBox(width: MySpaces.gap3.w),
//                   Flexible(
//                     child: Text(
//                       GayaStrings.anonymous_post_desc_2.tr,
//                       style: GayaTypography.subtitleRegular.copyWith(color: AppColors.black),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             gap,
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: MySpaces.gap5).r,
//               child: GayaButton(
//                   height: 40.h,
//                   borderColor: kTransparentColor,
//                   // textStyle: loginController.styleEmail,
//                   textStyle: GayaTypography.titleMedium.copyWith(color: AppColors.white, fontSize: 14.sp),
//                   title: GayaStrings.i_want_to_post_anonymously.tr,
//                   onPressed: onSubmit,
//                   primaryColor: AppColors.primary),
//             ),
//             SizedBox(
//               height: 20.h,
//             )
//           ],
//         ),
//       ));
// }
