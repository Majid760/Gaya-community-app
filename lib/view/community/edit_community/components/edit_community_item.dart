import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/textfield.component.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/view/community/edit_community/components/edit_title_subtitle.dart';

import '../../../../utils/methods.dart';

class EditCommunityItem extends StatelessWidget {
  final TextEditingController controller;
  final String title;
  final String subtitle;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;

  const EditCommunityItem({
    Key? key,
    required this.controller,
    required this.title,
    required this.subtitle,
    this.keyboardType,
    this.maxLines,
    this.minLines,
    this.maxLength,
    this.validator,
    this.textInputAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleAndSubtitle(title: title, subtitle: subtitle),
        SizedBox(height: 4.h),
        GayaMultiLineTextField(
          keyboardType: keyboardType,
          controller: controller,
          validator: validator,
          textInputAction: textInputAction ?? TextInputAction.done,
          maxLines: maxLines,
          maxLength: maxLength,
          minLines: minLines,
        ),
      ],
    );
  }
}
