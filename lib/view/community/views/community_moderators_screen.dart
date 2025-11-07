import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/components/textfield.component.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/view/community/components/paginated_community_members.dart';
import 'package:gaya/view/community/components/searched_community_members.dart';
import 'package:gaya/view/community/controllers/community_editing_controller.dart';
import 'package:gaya/view/community_setting_view.dart';
import 'package:get/get.dart';

import '../../../controller/firebase_analytics_controller.dart';
import '../../../shared/view/widget/gaya_back_button.dart';

class CommunityModeratorsScreen extends StatefulWidget {
  final String communityId;
  const CommunityModeratorsScreen({Key? key, required this.communityId}) : super(key: key);

  @override
  State<CommunityModeratorsScreen> createState() => _CommunityModeratorsScreenState();
}

class _CommunityModeratorsScreenState extends State<CommunityModeratorsScreen> {
  late TextEditingController textController;
  final GlobalKey<FormState> _reportFormKey = GlobalKey<FormState>();
  late EditCommunityController editCommunityController;

  @override
  void initState() {
    editCommunityController = EditCommunityController.to(tag: widget.communityId);
    editCommunityController.initializeCommunityMembersServices();
    editCommunityController.getCommunityMembersProfile();
    editCommunityController.requestMoreData(fromInit: true);
    super.initState();
  }

  @override
  void dispose() {
    editCommunityController.resetController(isDisposing: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          shape: Border(bottom: BorderSide(color: kBaseGrey.withOpacity(0.5))),
          automaticallyImplyLeading: false,
          leading: const GayaBackButton(),
          iconTheme: const IconThemeData(color: kBlackColor),
          title: Text(GayaStrings.manage_moderators.tr, style: CustomTypography.bodyStyle),
          centerTitle: true,
          backgroundColor: kTransparentColor,
          actions: [
            Center(
                child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: GetBuilder<EditCommunityController>(
                      autoRemove: false,
                      tag: widget.communityId,
                      init: EditCommunityController.to(tag: widget.communityId),
                      builder: (communityEditingController) {
                        return GestureDetector(
                            onTap: () async {
                              await communityEditingController.updateCommunityModerators(context);
                            },
                            child: communityEditingController.isUploadingModerator
                                ? const CircularProgressIndicator(color: kprimaryColor, backgroundColor: blueColor)
                                : Text(GayaStrings.done.tr,
                                    style: const TextStyle(color: kprimaryColor, fontWeight: FontWeight.bold, fontSize: 16)));
                      },
                    )))
          ],
          elevation: 0),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: SingleChildScrollView(
          child: GetBuilder<EditCommunityController>(
            autoRemove: false,
            tag: widget.communityId,
            init: EditCommunityController.to(tag: widget.communityId),
            builder: (communityEditCtrl) {
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CommunitySettingItem(
                  title: GayaStrings.community_moderators.tr,
                  subtitle: GayaStrings.community_moderators_desc.tr,
                  haveIcon: false,
                ),
                CommunitySettingItem(
                    title: GayaStrings.manage_moderators_tag.tr,
                    subtitle: GayaStrings.manage_moderators_tag_desc.tr,
                    onTap: () async {
                      textController =
                          TextEditingController(text: communityEditCtrl.createCommunityModel?.moderatorTagData?['moderatorTag'] ?? '');
                      addNewCommunityTopicBottomModal(context, communityEditCtrl, textController, _reportFormKey);
                    }),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5).r,
                  child: GayaSearchTextField(
                    controller: communityEditCtrl.searchFieldController,
                    onChanged: (query) {
                      communityEditCtrl.searchFeed(query);
                    },
                  ),
                ),
                const SizedBox(height: 8),
                (communityEditCtrl.searchFieldController.text.isNotEmpty)
                    ? (communityEditCtrl.searchedUsers.isNotEmpty)
                        ? SearchedCommunityMembers(communityId: widget.communityId)
                        : SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.4,
                            child: Center(child: Text(GayaStrings.no_member_found.tr, style: CustomTypography.body2DisableStyle)),
                          )
                    : PaginatedCommunityMembers(communityId: widget.communityId),
                const SizedBox(height: 20),
              ]);
            },
          ),
        ),
      ),
    );
  }
}

addNewCommunityTopicBottomModal(
    BuildContext context, EditCommunityController controller, TextEditingController textEditController, dynamic reportFormKey) async {
  String selectedTagColor = controller.createCommunityModel?.moderatorTagData?['tagColor'] ?? '';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    enableDrag: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(13.0), topRight: Radius.circular(13.0))),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        width: MediaQuery.sizeOf(context).width,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(13.0), topRight: Radius.circular(13.0)),
        ),
        child: Form(
          key: reportFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Center(
                child: Container(
                  height: 5,
                  width: 40,
                  decoration: const ShapeDecoration(color: kBaseGrey, shape: StadiumBorder()),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(GayaStrings.moderator_tag.tr, style: CustomTypography.bodyStyle),
                ],
              ),
              const SizedBox(height: 16),
              Text(GayaStrings.tag_name.tr, style: CustomTypography.body4Style),
              const SizedBox(height: distance_8),
              textField(
                controller: textEditController,
                maxlines: 1,
                maxlength: 25,
                borderColor: borderColor,
                isPassword: false,
                autovalidateModel: AutovalidateMode.onUserInteraction,
                inputType: TextInputType.text,
                validation: (value) {
                  if (value.toString().trim().isEmpty) {
                    return GayaStrings.tag_name_validation_txt.tr;
                  }
                  return null;
                },
                onChanged: (value) {},
                hintTextStyle: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xFF8E8E93),
                ),
                hintText: GayaStrings.tag_name_hint.tr,
              ),
              // const SizedBox(height: distance_20),
              Text(GayaStrings.tag_color.tr, style: CustomTypography.body4Style),
              const SizedBox(height: distance_8),

              StatefulBuilder(builder: (ctx, state) {
                return SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ListView.separated(
                    separatorBuilder: (context, index) {
                      return const Padding(
                        padding: EdgeInsets.only(right: 6),
                      );
                    },
                    itemCount: moderatortagColors.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      Color? retrieveColor = getColorFromHex(moderatortagColors[index]);
                      return GestureDetector(
                        onTap: () {
                          if (selectedTagColor == moderatortagColors[index]) {
                            state(() => selectedTagColor = '');
                          } else {
                            state(() => selectedTagColor = moderatortagColors[index]);
                          }
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                                height: 60,
                                width: 60,
                                child: CircleAvatar(
                                  backgroundColor: retrieveColor ?? kBaseGrey,
                                )),
                            if (selectedTagColor == moderatortagColors[index])
                              const Positioned(
                                left: 0,
                                right: 0,
                                top: 0,
                                bottom: 0,
                                child: Icon(
                                  Icons.check,
                                  color: kWhiteColor,
                                ),
                              )
                          ],
                        ),
                      );
                    },
                  ),
                );
              }),
              const SizedBox(height: distance_20),
              GayaButton(
                  title: GayaStrings.save_txt.tr,
                  onPressed: () async {
                    if (reportFormKey.currentState!.validate() && selectedTagColor != '') {
                      // Logging community moderator tag analytics event
                      AnalyticsController.to.instance.logCommunityModeratorTag(
                        adminId: controller.community?.adminUid ?? '',
                        communityId: controller.community?.communityId ?? '',
                        tag: textEditController.text,
                      );

                      await controller.updateModeratorsTagData(
                        context,
                        selectedTagColor,
                        moderatorTag: textEditController.text,
                      );
                      textEditController.clear();
                      Get.back();
                    }
                  },
                  borderColor: kTransparentColor,
                  height: 50,
                  primaryColor: kprimaryColor,
                  textStyle: const TextStyle(color: kWhiteColor, fontWeight: FontWeight.w500, fontSize: 14),
                  width: MediaQuery.sizeOf(context).width)
            ],
          ),
        ),
      ),
    ),
  );
}
