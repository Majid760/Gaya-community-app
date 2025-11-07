import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/components/progress.indicator.component.dart';
import 'package:gaya/components/snackbar.component.dart';
import 'package:gaya/controller/app_config_controller.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/shared/view/widget/gaya_alert_dialog.dart';
import 'package:gaya/shared/view/widget/gaya_back_button.dart';
import 'package:gaya/utils/app_data.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/enum.dart';
import 'package:gaya/utils/helpers.functions.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/view/community/create_community/components/commnity.view1.widget.dart';
import 'package:gaya/view/community/create_community/components/community.view2.widget.dart';
import 'package:gaya/view/community/create_community/components/community.view3.widget.dart';
import 'package:gaya/view/community/create_community/components/community.view4.widget.dart';
import 'package:gaya/view/community/create_community/components/create_community_theme_widget.dart';
import 'package:gaya/view/community/create_community/controllers/community_questionnaire_controller.dart';
import 'package:gaya/view/community/create_community/controllers/create_community_controller.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../controller/topics.controller.dart';

class CreateCommunityView extends GetView<CreateCommunityController> {
  CreateCommunityView({Key? key}) : super(key: key);

  bool isLoading = false;

  // checking changes while creating new community and resetting its state
  checkCreateCommunityChanges(context) async {
    final CreateCommunityController createCommunityController = Get.find();

    bool shouldPop = await createCommunityController.shouldPop(context);
    if (shouldPop) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } else {
      // ignore: use_build_context_synchronously
      showGayaAlertDialogButton(
        context: context,
        actionText: GayaStrings.discard_changes.tr,
        tapOnYes: () async {
          Navigator.pop(context);
          await createCommunityController.resetState(context);
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
        },
        tapOnNo: () {
          Navigator.pop(context);
        },
      );
    }
  }

  _disposeControllers() {
    Get.delete<CreateCommunityController>();
    Get.delete<QuestionnaireController>();
  }

  @override
  Widget build(BuildContext context) {
    // final CreateCommunityController postController = Get.find();
    final topicController = Provider.of<TopicsController>(context, listen: true);

    return WillPopScope(
      onWillPop: () async {
        final CreateCommunityController createCommunityController = Get.find();
        bool shouldPop = await createCommunityController.shouldPop(context);
        if (shouldPop) return shouldPop;
        // ignore: use_build_context_synchronously
        showGayaAlertDialogButton(
          context: context,
          actionText: GayaStrings.discard_changes.tr,
          tapOnYes: () async {
            Navigator.pop(context);
            await createCommunityController.resetState(context);
            // ignore: use_build_context_synchronously
            Navigator.pop(context);
            _disposeControllers();
          },
          tapOnNo: () {
            Navigator.pop(context);
          },
        );
        return true;
      },
      child: Scaffold(
        appBar: getAppbar(context),
        body: getBody(context, topicController),
      ),
    );
  }

  PreferredSizeWidget getAppbar(BuildContext context) {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      shape: Border(bottom: BorderSide(color: kBaseGrey.withOpacity(0.5))),
      automaticallyImplyLeading: false,
      leading: GayaBackButton(onPop: () => checkCreateCommunityChanges(context)),
      iconTheme: const IconThemeData(color: kBlackColor),
      actions: [
        GetBuilder<CreateCommunityController>(builder: (controller) {
          return controller.getCommunityViewPage == CreateCommunityViewEnum.CommunityView5
              ? controller.skip == true
                  ? const Center(
                      child: CircularProgressIndicator.adaptive(
                        backgroundColor: kprimaryColor,
                      ),
                    )
                  : StatefulBuilder(builder: (context, setState) {
                      return isLoading
                          ? Padding(
                              padding: const EdgeInsets.only(right: 20).r,
                              child: AppData.loadingAsyncWidget,
                            )
                          : TextButton(
                              onPressed: () async {
                                setState(() => isLoading = true);
                                try {
                                  final imageUpload = Provider.of<HelpersFunctions>(context, listen: false);
                                  final Community? newCommunity = await controller.createACommunity(context, imageUpload, controller.skip);
                                  if (newCommunity != null) {
                                    Routes.succesfullyJoinedCommunity(community: newCommunity, shouldReplace: true);
                                    controller.communityViewPage = CreateCommunityViewEnum.CommunityView1;
                                    _disposeControllers();
                                  }
                                  // Routes.succesfullyJoinedCommunity();
                                  // controller.communityViewPage = CreateCommunityViewEnum.CommunityView1;
                                } catch (_) {
                                  debugPrint(_.toString());
                                } finally {
                                  setState(() => isLoading = false);
                                }
                              },
                              child: Text(GayaStrings.skip_btn.tr, style: CustomTypography.body2StyleWeightkPrimary),
                            );
                    })
              : const SizedBox.shrink();
        })
      ],
      title: Text(GayaStrings.create_community.tr, style: CustomTypography.bodyStyle),
      centerTitle: true,
      backgroundColor: kTransparentColor,
      elevation: 0,
    );
  }

  Widget getBody(BuildContext context, TopicsController topicController) {
    final helperFunctionController = Provider.of<HelpersFunctions>(context);
    // final communityController = Provider.of<CommunitiesController>(context, listen: true);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: distance_20),
      child: SingleChildScrollView(child: GetBuilder<CreateCommunityController>(
                builder: (controller) {

              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: distance_20),
                Row(
                  children: [
                    progressIndicator(ontap: () {}, color: getProgressIndicatorColor(1)),
                    const SizedBox(width: distance_5),
                    progressIndicator(ontap: () {}, color: getProgressIndicatorColor(2)),
                    const SizedBox(width: distance_5),
                    progressIndicator(ontap: () {}, color: getProgressIndicatorColor(3)),
                    const SizedBox(width: distance_5),
                    progressIndicator(ontap: () {}, color: getProgressIndicatorColor(4)),
                    const SizedBox(width: distance_5),
                    progressIndicator(ontap: () {}, color: getProgressIndicatorColor(5))
                  ],
                ),
                const SizedBox(height: distance_20),
                getCreateCommunity(controller.getCommunityViewPage),
                const SizedBox(
                  height: distance_10,
                ),
                controller.createPostLoader == false
                    ? controller.getCommunityViewPage == CreateCommunityViewEnum.CommunityView5
                        ? controller.skip == true
                            ? const SizedBox.shrink()
                            : SizedBox(
                                height: 40,
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(backgroundColor: kBaseGrey, elevation: 0),
                                    onPressed: () async {
                                      if (isLoading == true) return;
                                      isLoading = true;
                                      try {
                                        final imageUpload = Provider.of<HelpersFunctions>(context, listen: false);
                                        final Community? newCommunity =
                                            await controller.createACommunity(context, imageUpload, controller.createPostLoader);

                                        if (newCommunity != null) {
                                          AppConfigurationController.to.asAdminCommunities.add(newCommunity);
                                    Routes.createPost(community: newCommunity, from: PostCreationFrom.CommunityCreation, replace: true);
                                  }
                                      } catch (_) {
                                      } finally {
                                        isLoading = false;
                                      }
                                    },
                                    icon: SvgIconWidget.editOutline(height: 20.h),
                                    // SvgPicture.asset(Assets.assets.icons.write),
                                    label: Text(
                                      GayaStrings.create_post.tr,
                                style: CustomTypography.body4Style,
                              )),
                              )
                        : GayaButton(
                            height: 40.h,
                      textStyle: CustomTypography.body2Style,
                      borderColor: kTransparentColor,
                      title: GayaStrings.continue_txt.tr,
                      onPressed: () async {
                        if (controller.getCommunityViewPage == CreateCommunityViewEnum.CommunityView1) {
                          debugPrint("${controller.communityName.text}");
                          if (controller.communityName.text.isNotEmpty && topicController.selectedList.isNotEmpty) {
                            controller.setCommunityViewPage(CreateCommunityViewEnum.CommunityView2);
                          } else {
                            snackBar(context, GayaStrings.enter_community_name_topic.tr, kprimaryColor);
                          }
                        } else if (controller.getCommunityViewPage == CreateCommunityViewEnum.CommunityView2) {
                                if (helperFunctionController.communityImage != null && helperFunctionController.communityCoverImage != null) {
                                  controller.setCommunityViewPage(CreateCommunityViewEnum.CommunityView3);
                                } else {
                                  snackBar(context, GayaStrings.select_profile_pic_continue.tr, kprimaryColor);
                                }
                              } else if (controller.getCommunityViewPage == CreateCommunityViewEnum.CommunityView3) {
                                if (controller.description.value.text.isNotEmpty) {
                                  controller.setCommunityViewPage(CreateCommunityViewEnum.CommunityView4);
                                } else {
                                  snackBar(context, GayaStrings.empty_description.tr, kprimaryColor);
                                }
                              } else if (controller.getCommunityViewPage == CreateCommunityViewEnum.CommunityView4) {
                                controller.setCommunityViewPage(CreateCommunityViewEnum.CommunityView5);
                              }
                            },
                            primaryColor: kprimaryColor)
                    : const Center(
                        child: CircularProgressIndicator.adaptive(
                        backgroundColor: kprimaryColor,
                      )),
                const SizedBox(
                  height: distance_20,
                ),
              ]);
            })),
    );
  }

  Widget getCreateCommunity(CreateCommunityViewEnum getView) {
    switch (getView) {
      case CreateCommunityViewEnum.CommunityView1:
        return const CommunityView1();
      case CreateCommunityViewEnum.CommunityView2:
        return const CommunityView2();
      case CreateCommunityViewEnum.CommunityView3:
        return const CommunityView3();
      case CreateCommunityViewEnum.CommunityView4:
        return const CommunityView4();
      case CreateCommunityViewEnum.CommunityView5:
        return const CreateCommunityThemeWidget();
    }
  }

  Color getProgressIndicatorColor(int progressBarNo) {
    Color barColor = borderColor;
    if (progressBarNo == 1) {
      if (controller.getCommunityViewPage == CreateCommunityViewEnum.CommunityView1 ||
          controller.getCommunityViewPage == CreateCommunityViewEnum.CommunityView2 ||
          controller.getCommunityViewPage == CreateCommunityViewEnum.CommunityView3 ||
          controller.getCommunityViewPage == CreateCommunityViewEnum.CommunityView4 ||
          controller.getCommunityViewPage == CreateCommunityViewEnum.CommunityView5) {
        barColor = kprimaryColor;
      } else {
        barColor = borderColor;
      }
    } else if (progressBarNo == 2) {
      if (controller.getCommunityViewPage == CreateCommunityViewEnum.CommunityView2 ||
          controller.getCommunityViewPage == CreateCommunityViewEnum.CommunityView3 ||
          controller.getCommunityViewPage == CreateCommunityViewEnum.CommunityView4 ||
          controller.getCommunityViewPage == CreateCommunityViewEnum.CommunityView5) {
        barColor = kprimaryColor;
      } else {
        barColor = borderColor;
      }
    } else if (progressBarNo == 3) {
      if (controller.getCommunityViewPage == CreateCommunityViewEnum.CommunityView3 ||
          controller.getCommunityViewPage == CreateCommunityViewEnum.CommunityView4 ||
          controller.getCommunityViewPage == CreateCommunityViewEnum.CommunityView5) {
        barColor = kprimaryColor;
      } else {
        barColor = borderColor;
      }
    } else if (progressBarNo == 4) {
      if (controller.getCommunityViewPage == CreateCommunityViewEnum.CommunityView4 ||
          controller.getCommunityViewPage == CreateCommunityViewEnum.CommunityView5) {
        barColor = kprimaryColor;
      } else {
        barColor = borderColor;
      }
    } else if (progressBarNo == 5) {
      if (controller.getCommunityViewPage == CreateCommunityViewEnum.CommunityView5) {
        barColor = kprimaryColor;
      } else {
        barColor = borderColor;
      }
    }

    return barColor;
  }
}
