import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/gen/assets.gen.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_spaces.dart';
import 'package:gaya/utils/theme/button_styles.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../utils/methods.dart';
import '../../../utils/textstyles.dart';
import '../controller/login.controller.dart';

class RequireSignRegisterView extends StatefulWidget {
  final bool? isButtonLiked;
  final bool? isflower;
  final bool? isComment;
  final bool? userNotSigin;

  const RequireSignRegisterView({Key? key, this.isButtonLiked, this.isflower, this.isComment, this.userNotSigin}) : super(key: key);

  @override
  State<RequireSignRegisterView> createState() => _RequireSignRegisterViewState();
}

class _RequireSignRegisterViewState extends State<RequireSignRegisterView> {
  @override
  Widget build(BuildContext context) {
    // log("Inside Require Sign In Register Page");
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height,
          width: MediaQuery.sizeOf(context).width,
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: getBody(context, widget.isButtonLiked ?? true, widget.isflower ?? true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getBody(BuildContext context, bool isButtonLiked, bool isflower) {
    final authProvider = Provider.of<LoginController>(context, listen: false);
    final gap15 = SizedBox(height: MySpaces.gap4.h);
    final bodySecondaryText =
        GayaTypography.subtitleMedium.copyWith(fontSize: 14.sp, color: AppColors.secondary, fontWeight: FontWeight.w600, height: 1.5);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: distance_20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: distance_15),
          const MainHeader(),
          SizedBox(height: 20.h),
          widget.userNotSigin == true ? const Spacer(flex: 1) : const SizedBox.shrink(),
          widget.userNotSigin == true
              ? const SizedBox.shrink()
              : !isButtonLiked == true
                  ? SvgPicture.asset(Assets.assets.images.hearts)
                  : !isflower == true
                      ? SvgPicture.asset(Assets.assets.images.flowers)
                      : Column(
                          children: [
                            SvgPicture.asset(Assets.assets.images.post),
                            const SizedBox(height: distance_15),
                            SvgPicture.asset(Assets.assets.images.reply),
                          ],
                        ),
          Text(
            !isButtonLiked
                ? GayaStrings.signup_like_post.tr
                : !isflower
                    ? GayaStrings.sing_up_to_give_flower.tr
                    : widget.userNotSigin == true
                        ? GayaStrings.signup_gaya.tr
                        : GayaStrings.signup_reply_comment.tr,
            style: GayaTypography.h1.copyWith(fontWeight: FontWeight.w600, fontSize: 24.sp, height: 1.66),
          ),
          const SizedBox(height: distance_10),
          widget.userNotSigin == true
              ? Text(GayaStrings.sing_up_browse_communities.tr,
                  style: GayaTypography.subtitleRegular.copyWith(fontSize: 16.sp, height: 1.8, color: AppColors.secondary),
                  textAlign: TextAlign.center)
              : Text(GayaStrings.signup_to_interact.tr,
                  style: GayaTypography.subtitleRegular.copyWith(fontSize: 16.sp, height: 1.8, color: AppColors.secondary),
                  textAlign: TextAlign.center),

          widget.userNotSigin == true ? const Spacer(flex: 2) : const SizedBox(height: distance_25),
          buttonIcon(
            iconString: 'Assets/icons/friend.svg',
            height: 50.h,
            primaryColor: AppColors.primary,
            title: GayaStrings.use_phone_email.tr,
            onPressed: () {
              Routes.registerEmailView();
              //Navigator.of(context).pushNamed(routes.registerEmail);
            },
            borderColor: const Color.fromRGBO(255, 255, 255, 0.0),
            textStyle: GayaTypography.h2.copyWith(fontSize: 16.sp, color: kWhiteColor, letterSpacing: 0),
          ),
          gap15,

          Row(
            children: [
              const Expanded(child: Divider(thickness: 2, color: kBaseGrey)),
              const SizedBox(width: 10),
              Text(GayaStrings.or.tr,
                  style: GayaTypography.h2
                      .copyWith(fontSize: 16.sp, color: AppColors.secondary, letterSpacing: 0, fontWeight: FontWeight.w400)),
              const SizedBox(width: 10),
              const Expanded(child: Divider(thickness: 2, color: kBaseGrey)),
            ],
          ),

          gap15,
          Consumer<LoginController>(builder: (context, logInCtrl, child) {
            return logInCtrl.socialSignInError == null || logInCtrl.socialSignInError!.isEmpty
                ? const SizedBox.shrink()
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: distance_30.h),
                        Center(
                            child: Text(logInCtrl.socialSignInError ?? '', style: CustomTypography.body3Style.copyWith(color: kRedColor))),
                        SizedBox(height: distance_30.h),
                      ],
                    ),
                  );
          }),
          Consumer<LoginController>(builder: ((context, loginController, child) {
            return loginController.isLoading
                ? Column(mainAxisSize: MainAxisSize.min, children: [
                    Center(child: CircularProgressIndicator.adaptive(backgroundColor: AppColors.primary)),
                    const SizedBox(height: distance_10)
                  ])
                : Column(
                    children: [
                      SocialMediaButtons(
                          borderColor: AppColors.secondary,
                          textStyle: GayaTypography.h2.copyWith(fontSize: 16.sp, color: kprimaryColor, letterSpacing: 0),
                          backgroundColor: kWhiteColor,
                          onPressFunction: () => authProvider.logInWithGoogle(context: context),
                          text: GayaStrings.continue_with_google.tr,
                          imageAsset: 'Assets/icons/google.png'),
                      const SizedBox(height: distance_10),
                      Visibility(
                        visible: DeviceCheck.isIOS,
                        child: SocialMediaButtons(
                            textStyle: GayaTypography.h2.copyWith(fontSize: 16.sp, color: kWhiteColor, letterSpacing: 0),
                            backgroundColor: kBlackColor,
                            onPressFunction: () async {
                              final userModel = await authProvider.signInWithAppleFirebase(context);
                              if (userModel != null) {
                                if (userModel.dob == null ||
                                    userModel.phoneNumber == null ||
                                    userModel.phoneNumber == '' ||
                                    userModel.name == null ||
                                    userModel.name?.trim() == '') {
                                  // go to splash screen only if we have name, phonenumber and dob
                                  Routes.askNameFieldView();
                                } else {
                                  Routes.splash();
                                }
                              }
                            },
                            text: GayaStrings.continue_with_apple.tr,
                            imageAsset: 'Assets/images/apple_logo.png'),
                      ),
                    ],
                  );
          })),

          gap15,

          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(GayaStrings.by_registering_agree.tr, style: bodySecondaryText),
            ],
          ),
          const SizedBox(height: distance_5),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                  onTap: () => Methods.openTermsAndConditions(context),
                  child: Text("${GayaStrings.term_Of_Service.tr} ", style: bodySecondaryText.copyWith(color: kprimaryColor))),
              Text(GayaStrings.and.tr, style: bodySecondaryText),
              InkWell(
                  onTap: () => Methods.openPrivacyPolicy(context),
                  child: Text("${GayaStrings.privacy_policy.tr}.", style: bodySecondaryText.copyWith(color: kprimaryColor))),
              const SizedBox(height: distance_40),
            ],
          ),
          const Spacer(),
          // already have an account
          SafeArea(
            minimum: const EdgeInsets.only(bottom: 20).r,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${GayaStrings.have_account.tr} ', style: bodySecondaryText),
                TextButton(
                    style: GayaButtonStyles.actionRowTextButtonStyle2,
                    onPressed: () => Routes.loginView(),
                    child: Text(GayaStrings.login_here.tr, style: bodySecondaryText.copyWith(color: AppColors.primary)))
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MainHeader extends StatelessWidget {
  const MainHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        Image.asset(Assets.assets.images.gayaLogo.path, fit: BoxFit.scaleDown, height: 35.h, width: 50.w),
        const SizedBox(width: distance_15),
        Text('Gaya', style: GayaFontTheme.lexendDecaFont.copyWith(fontSize: 32.sp, fontWeight: FontWeight.w500, height: 1.25)),
        const Spacer(),
        IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close))
      ],
    );
  }
}
