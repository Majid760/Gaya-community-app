import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../components/button.component.dart';
import '../../../components/textfield.component.dart';
import '../../../utils/const.dart';
import '../../../utils/textstyles.dart';
import '../../../utils/vallidation.dart';
import '../controller/login.controller.dart';

class CreatePasswordView extends StatefulWidget {
  const CreatePasswordView({Key? key}) : super(key: key);

  @override
  State<CreatePasswordView> createState() => _CreatePasswordViewState();
}

class _CreatePasswordViewState extends State<CreatePasswordView> {
  final validation = FormValidation();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resetController = Provider.of<LoginController>(context, listen: true);

    return Scaffold(
      appBar: getAppbar(),
      body: getBody(validation, resetController, context),
    );
  }

//Appbar
  PreferredSizeWidget getAppbar() {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      shape: Border(
          bottom: BorderSide(
        color: kBaseGrey.withOpacity(0.25),
      )),
      iconTheme: const IconThemeData(color: kBlackColor),
      title: Text(
        GayaStrings.create_new_password.tr,
        style: CustomTypography.bodyStyle,
      ),
      centerTitle: true,
      backgroundColor: kTransparentColor,
      elevation: 0,
    );
  }

//body
  Widget getBody(FormValidation validation, LoginController resetController, BuildContext context) {
    final loginController = Provider.of<LoginController>(context, listen: true);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: distance_20),
      child: Form(
        key: resetController.createPasswordKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: distance_20),
              Container(
                padding: const EdgeInsets.only(right: distance_25),
                width: double.infinity,
                child: Text(GayaStrings.password_must_be_different.tr, style: CustomTypography.body1Style),
              ),
              const SizedBox(height: distance_10),
              Text(GayaStrings.password.tr, style: CustomTypography.body4Style),
              const SizedBox(height: distance_10),
              textField(
                  maxlines: 1,
                  borderColor: borderColor,
                  isPassword: loginController.isPasswordVisible == true ? true : false,
                  inputType: TextInputType.text,
                  validation: validation.loginPasswordValidation,
                  controller: passwordController,
                  hintText: GayaStrings.type_password_hint.tr,
                  suffixIcon: loginController.isPasswordVisible == true
                      ? Consumer<LoginController>(builder: (context, passwordVisible, child) {
                          return IconButton(
                              onPressed: () {
                                passwordVisible.passwordVisibility();
                              },
                              icon: (const Icon(
                                Icons.visibility,
                                color: kBlackColor,
                              )));
                        })
                      : Consumer<LoginController>(builder: (context, passwordVisibleOff, child) {
                          return IconButton(
                            onPressed: () {
                              passwordVisibleOff.passwordVisibility();
                            },
                            icon: const Icon(
                              Icons.visibility_off,
                              color: kBlackColor,
                            ),
                          );
                        })),
              const SizedBox(
                height: distance_20,
              ),
              Text(GayaStrings.password.tr, style: CustomTypography.body4Style),
              const SizedBox(
                height: distance_10,
              ),
              textField(
                  maxlines: 1,
                  borderColor: borderColor,
                  isPassword: loginController.isPasswordVisible == true ? true : false,
                  inputType: TextInputType.text,
                  validation: passwordController.value.text != confirmPasswordController.value.text
                      ? validation.passwordDoesnotMatch
                      : validation.passwordDoesnotMatch,
                  controller: confirmPasswordController,
                  hintText: GayaStrings.type_password_hint.tr,
                  suffixIcon: loginController.isPasswordVisible == true
                      ? Consumer<LoginController>(builder: (context, passwordVisible, child) {
                          return IconButton(
                              onPressed: () {
                                passwordVisible.passwordVisibility();
                              },
                              icon: (const Icon(
                                Icons.visibility,
                                color: kBlackColor,
                              )));
                        })
                      : Consumer<LoginController>(builder: (context, passwordVisibleOff, child) {
                          return IconButton(
                            onPressed: () {
                              passwordVisibleOff.passwordVisibility();
                            },
                            icon: const Icon(
                              Icons.visibility_off,
                              color: kBlackColor,
                            ),
                          );
                        })),
              const SizedBox(
                height: distance_20,
              ),
              resetController.isResetLoading
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : GayaButton(
                      height: 50,
                      borderColor: kTransparentColor,
                      textStyle: CustomTypography.body2EnableStyle,
                      title: GayaStrings.create_new_password.tr,
                      primaryColor: AppColors.primary,
                      onPressed: () async {
                        // if (resetController.createPasswordKey.currentState!
                        //     .validate()) {
                        //   await resetController.updatePassword(context);
                        // } else {}
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
