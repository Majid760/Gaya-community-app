import 'package:flutter/material.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/components/textfield.component.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/view/chat/controllers/chat_controller.dart';
import 'package:gaya/view/chat/controllers/conversation_controller.dart';
import 'package:get/get.dart';

typedef StringCallback = void Function(String reportMsg);

editTextFieldBottomModal(BuildContext context, ConversationController conversationController, {required StringCallback onSubmit}) async {
  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(13.0), topRight: Radius.circular(13.0))),
      builder: (context) => EditFieldDialog(
            onFormSubmit: onSubmit,
            conversationController: conversationController,
          ));
}

// report form view
class EditFieldDialog extends StatefulWidget {
  const EditFieldDialog({Key? key, required this.onFormSubmit, required this.conversationController}) : super(key: key);
  final StringCallback onFormSubmit;
  final ConversationController conversationController;

  @override
  State<EditFieldDialog> createState() => _EditFieldDialogState();
}

class _EditFieldDialogState extends State<EditFieldDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // late TextEditingController nameFieldController;
  // @override
  // void initState() {
  //   super.initState();
  //   nameFieldController = TextEditingController();
  // }

  // @override
  // void dispose() {
  //   super.dispose();
  //   nameFieldController.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        width: MediaQuery.sizeOf(context).width,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(13.0), topRight: Radius.circular(13.0)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Center(
                child: Container(height: 5, width: 40, decoration: const ShapeDecoration(color: kBaseGrey, shape: StadiumBorder())),
              ),
              Text(GayaStrings.edit_name.tr, style: CustomTypography.body1Style.copyWith(color: kBlackColor)),
              const SizedBox(height: distance_20),
              textField(
                  controller: widget.conversationController.groupNameTextField,
                  maxlines: null,
                  borderColor: borderColor,
                  isPassword: false,
                  autovalidateModel: AutovalidateMode.onUserInteraction,
                  inputType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  validation: (value) {
                    if (value.toString().trim().isEmpty) {
                      return GayaStrings.enter_name.tr;
                    }
                    return null;
                  },
                  onChanged: (value) {},
                  hintTextStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: Color(0xFF8E8E93)),
                  hintText: GayaStrings.enter_name_hint.tr),
              const SizedBox(height: 10),
              GayaButton(
                  title: GayaStrings.continue_txt.tr,
                  onPressed: () async {
                    // Validate returns true if the form is valid, or false otherwise.
                    if (_formKey.currentState!.validate()) {
                      widget.onFormSubmit(ChatController.to().groupNameTextField.text);
                      Navigator.pop(context);
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
    );
  }
}
