import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gaya/shared/view/widget/gaya_snackbar.dart';
import 'package:gaya/view/chat/controllers/base_controller.dart';
import 'package:gaya/view/profile/contact_us/model/contact_us.dart';

import '../services/contact_us_services.dart';

class ContactUsController extends BaseController {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController messageController;
  late final GlobalKey<FormState> formKey;

  ContactUs? contactUs;
  final ContactUsServices _contactUsServices = ContactUsServices();

  @override
  void onInit() {
    super.onInit();
    formKey = GlobalKey<FormState>();
    nameController = TextEditingController();
    emailController = TextEditingController();
    messageController = TextEditingController();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    messageController.dispose();
    super.onClose();
  }

  Future<bool> onSubmit({required BuildContext context}) async {
    bool isValid = formKey.currentState?.validate() ?? false;

    if (isValid) {
      setLoading(true);
      contactUs = ContactUs(name: nameController.text, email: emailController.text, message: messageController.text);
      try {
        await _contactUsServices.letsTalk(contactUsModel: contactUs!);
      } on FirebaseException catch (e) {
        setLoading(false);
        GayaSnackBar.show(context: context, type: GayaSnackBarType.error, text: e.message ?? "Something went wrong");

        /// * Return false to update the UI
        return false;
      }

      setLoading(false);
      return isValid;
    }
    return isValid;
  }
}
