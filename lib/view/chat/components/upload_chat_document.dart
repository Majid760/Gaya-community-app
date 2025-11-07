// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:gaya/components/button.component.dart';
// import 'package:gaya/components/textfield.component.dart';
// import 'package:gaya/shared/view/widget/pdf_view_widget.dart';
// import 'package:gaya/utils/const.dart';
// import 'package:gaya/utils/textstyles.dart';
// import 'package:gaya/utils/theme/app_colors.dart';
// import 'package:gaya/view/chat_ubaid/controllers/new_chat_controller.dart';
// import 'package:gaya/view/chat/helper/helper_functions.dart';
// import 'package:provider/provider.dart';

// // upload documents form view
// class UploadChatDocument extends StatefulWidget {
//   const UploadChatDocument({Key? key, required this.onFormSubmit}) : super(key: key);
//   final StringCallback onFormSubmit;

//   @override
//   State<UploadChatDocument> createState() => _UploadChatDocumentState();
// }

// class _UploadChatDocumentState extends State<UploadChatDocument> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
//       child: Consumer<NewChatController>(builder: (_, controller, __) {
//         return Container(
//           padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 24).r,
//           width: MediaQuery.sizeOf(context).width,
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.only(topLeft: Radius.circular(13.0), topRight: Radius.circular(13.0)),
//           ),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 Center(
//                   child: Container(height: 5, width: 40, decoration: const ShapeDecoration(color: kBaseGrey, shape: StadiumBorder())),
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text("Add new document", style: CustomTypography.body1Style.copyWith(color: kBlackColor)),
//                   ],
//                 ),
//                 SizedBox(height: 8.h),
//                 textField(
//                     controller: controller.documentTextField,
//                     maxlines: null,
//                     borderColor: MyColorHex().blackShade2,
//                     isPassword: false,
//                     autovalidateModel: AutovalidateMode.onUserInteraction,
//                     inputType: TextInputType.text,
//                     textInputAction: TextInputAction.done,
//                     validation: (value) {
//                       if (value.toString().trim().isEmpty) {
//                         return "Please enter document title";
//                       }
//                       return null;
//                     },
//                     enableBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.divider)),
//                     onChanged: (value) {},
//                     hintTextStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: Color(0xFF8E8E93)),
//                     hintText: "Type document name"),
//                 SizedBox(height: 8.h),
//                 (controller.pdfFiles.isNotEmpty)
//                     ? LocalPdfviewWidget(
//                         path: controller.pdfFiles.first.path,
//                       )
//                     : const SizedBox.shrink(),
//                 SizedBox(height: 8.h),
//                 button(
//                     title: "Upload",
//                     onPressed: () async {
//                       // Validate returns true if the form is valid, or false otherwise.
//                       if (_formKey.currentState!.validate() && controller.pdfFiles.isNotEmpty) {
//                         Navigator.pop(context);
//                         controller.updateDocumentUploadStatus();
//                       }
//                     },
//                     borderColor: kTransparentColor,
//                     height: 50,
//                     primaryColor: kprimaryColor,
//                     textStyle: const TextStyle(color: kWhiteColor, fontWeight: FontWeight.w500, fontSize: 14),
//                     width: MediaQuery.sizeOf(context).width)
//               ],
//             ),
//           ),
//         );
//       }),
//     );
//   }
// }
