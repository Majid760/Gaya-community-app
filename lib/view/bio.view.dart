import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gaya/components/textfield.component.dart';
import 'package:gaya/controller/profile.controller.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../shared/view/widget/gaya_back_button.dart';
import '../utils/const.dart';
import '../utils/theme/app_typography.dart';

class BioView extends StatelessWidget {
  const BioView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profileController = Provider.of<ProfileController>(context, listen: true);
    return CupertinoPageScaffold(
        backgroundColor: AppColors.white,
        navigationBar: CupertinoNavigationBar(
            backgroundColor: AppColors.white,
            leading: const GayaBackButton(),
            middle: Text(GayaStrings.edit_txt.tr, style: GayaTypography.titleMedium),
            trailing: TextButton(
                // autofocus: true,
                onPressed: () => Navigator.of(context).pop(),
                child:  Text(GayaStrings.save_txt.tr, style: const TextStyle(color: kprimaryColor)))),
        child: Material(
          color: AppColors.white,
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: distance_20),
              child: textField(
                maxlength: 150,
                maxlines: 8,
                inputType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                controller: profileController.bioController,
                border: const OutlineInputBorder(borderSide: BorderSide.none),
                focusBorder: const OutlineInputBorder(borderSide: BorderSide.none),
                hintText: GayaStrings.add_bio.tr,
                borderColor: AppColors.transparrent,
                autoFocus: true,
                hintTextStyle: GayaTypography.body2.copyWith(fontWeight: FontWeight.w300, color: AppColors.secondary),
              )

              // TextField(
              //   controller: profileController.bioController,
              //   maxLines: null,
              //   decoration: const InputDecoration(hintText: 'Add Bio', border: OutlineInputBorder(borderSide: BorderSide.none)),
              // ),
              ),
        ));
  }
}
