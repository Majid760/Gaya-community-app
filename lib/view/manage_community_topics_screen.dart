import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/components/textfield.component.dart';
import 'package:gaya/shared/view/widget/gaya_alert_dialog.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/view/community/controllers/community_editing_controller.dart';
import 'package:gaya/widgets/profile.widgets/button.widget.dart';
import 'package:get/get.dart';

import '../components/gradient_text_widget.dart';
import '../shared/view/widget/gaya_back_button.dart';
import '../utils/theme/app_colors.dart';

class ManageCommunityTopicsScreen extends StatefulWidget {
  final String communityId;

  const ManageCommunityTopicsScreen({Key? key, required this.communityId}) : super(key: key);

  @override
  State<ManageCommunityTopicsScreen> createState() => _ManageCommunityTopicsScreenState();
}

class _ManageCommunityTopicsScreenState extends State<ManageCommunityTopicsScreen> {
  TextEditingController textController = TextEditingController();
  final GlobalKey<FormState> _reportFormKey = GlobalKey<FormState>();
  late EditCommunityController editCommunityController;

  @override
  void initState() {
    super.initState();
    editCommunityController = EditCommunityController.to(tag: widget.communityId);
  }

  @override
  Widget build(BuildContext context) {
    // final editCommunityProvider = Provider.of<CommunityEditingController>(context, listen: false);

    return WillPopScope(
      onWillPop: () async {
        // final editCommunityProvider = Provider.of<CommunityEditingController>(context, listen: false);
        bool shouldPop = await editCommunityController.areTopicListsEquals();
        if (shouldPop) return shouldPop;
        // ignore: use_build_context_synchronously
        showGayaAlertDialogButton(
          context: context,
          actionText: GayaStrings.discard_changes.tr,
          tapOnYes: () async {
            Navigator.pop(context);
            await editCommunityController.resetCommunityTopics();
            // ignore: use_build_context_synchronously
            Navigator.pop(context);
          },
          tapOnNo: () {
            Navigator.pop(context);
          },
        );
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            shape: Border(bottom: BorderSide(color: kBaseGrey.withOpacity(0.5))),
            automaticallyImplyLeading: false,
            leading: GayaBackButton(onPop: () => checkTopicChanges()),
            iconTheme: const IconThemeData(color: kBlackColor),
            title: Text(GayaStrings.manage_topic.tr, style: CustomTypography.bodyStyle),
            centerTitle: true,
            backgroundColor: kTransparentColor,
            actions: [
              Center(
                  child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: GetBuilder<EditCommunityController>(
                        init: editCommunityController,
                        autoRemove: false,
                        tag: widget.communityId,
                        builder: (communityEditingController) {
                          // Consumer<CommunityEditingController>(
                          // builder: (context, communityEditingController, __) {
                          return GestureDetector(
                              onTap: () async {
                                await communityEditingController.updateCommunityTopics(context);
                              },
                              child: communityEditingController.isLoading
                                  ? const CircularProgressIndicator(color: kprimaryColor, backgroundColor: blueColor)
                                  : GradientTextWidget(
                                GayaStrings.done.tr,
                                      style: CustomTypography.body2EnableStyle1.copyWith(color: kprimaryColor, fontWeight: FontWeight.bold),
                                      gradient: AppColors.textGradient,
                                    ));
                        },
                      ))),

            ],
            elevation: 0),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16).r,
          child: SingleChildScrollView(
            child: GetBuilder<EditCommunityController>(
              init: editCommunityController,
              autoRemove: false,
              tag: widget.communityId,
              builder: (communityEditCtrl) {
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(GayaStrings.arrange_community_knowledge.tr, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14.sp)),
                  SizedBox(height: 20.h),
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.6,
                    child: ListView.builder(
                      itemCount: communityEditCtrl.topics.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          horizontalTitleGap: 10,
                          leading: const Icon(Icons.menu, color: borderColor),
                          title: Container(
                              alignment: Alignment.topLeft,
                              child: Text(communityEditCtrl.topics[index], style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600))),
                          trailing: InkWell(
                            child: Icon(Icons.cancel_rounded, size: 22.r, color: kPrimaryBackgroundBtnColor),
                            onTap: () => communityEditCtrl.deleteCommunityTopic(index),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ButtonWidget(
                    onTap: () async {
                      addNewCommunityTopicBottomModal(context, communityEditCtrl, textController, _reportFormKey);
                      // textController.clear();
                    },
                    buttonColor: kBaseGrey,
                    color: kSecondaryColor.withOpacity(0.6),
                    title: GayaStrings.add_new_topic.tr,
                    style: CustomTypography.body4Style,
                  ),
                ]);
              },
            ),
          ),
        ),
      ),
    );
  }

  addNewCommunityTopicBottomModal(
      BuildContext context, EditCommunityController controller, TextEditingController textEditController, dynamic reportFormKey) async {
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
                const SizedBox(height: distance_20),
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
                        return GayaStrings.enter_topic.tr;
                      }
                      return null;
                    },
                    onChanged: (value) {},
                    hintTextStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: Color(0xFF8E8E93)),
                    hintText: GayaStrings.choose_topic_name.tr),
                const SizedBox(height: 10),
                GayaButton(
                    title: GayaStrings.add_txt.tr,
                    onPressed: () async {
                      // Validate returns true if the form is valid, or false otherwise.
                      if (reportFormKey.currentState!.validate()) {
                        Get.back();
                        await controller.addNewCommunityTopic(context, topic: textEditController.text);
                        textEditController.clear();
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

  // checking changes in topics and resetting it
  checkTopicChanges() async {
    // final editCommunityProvider = Provider.of<CommunityEditingController>(context, listen: false);
    if (await editCommunityController.areTopicListsEquals()) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } else {
      // ignore: use_build_context_synchronously
      showGayaAlertDialogButton(
        context: context,
        actionText: GayaStrings.discard_changes.tr,
        tapOnYes: () async {
          Navigator.pop(context);
          await editCommunityController.resetCommunityTopics();
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
        },
        tapOnNo: () {
          Navigator.pop(context);
        },
      );
    }
  }
}
