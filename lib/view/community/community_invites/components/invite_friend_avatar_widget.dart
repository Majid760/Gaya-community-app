import 'dart:typed_data' as td;

import 'package:fast_contacts/fast_contacts.dart';
import 'package:flutter/material.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/view/community/community_invites/controllers/community_invites_controller.dart';
import 'package:get/get.dart';
// import 'package:gaya/view/community/community_invites/models/contact_model.dart';

class InviteFriendAvatarWidget extends StatelessWidget {
  // final String? profileImg;
  // final String? name;
  final Contact contactInfo;
  bool isActive;

  InviteFriendAvatarWidget({Key? key, required this.contactInfo, this.isActive = false}) : super(key: key);

  getName(String friendName) {
    return friendName.isNotEmpty ? friendName.trim().split(RegExp(' +')).map((s) => s[0]).take(2).join() : '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 88,
          height: 88,
          child: Stack(
            children: [
              buildFutureBuilder(),
              GetBuilder<CommunityInvitesController>(
                  id: 'checkboxid',
                  init: Get.find<CommunityInvitesController>(),
                  builder: (inviteController) {
                    return Positioned(
                        bottom: 0,
                        right: 0,
                        child: Checkbox(
                          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          checkColor: kWhiteColor,
                          activeColor: kprimaryColor,
                          fillColor: MaterialStateProperty.resolveWith((Set states) {
                            if (states.contains(MaterialState.disabled)) {
                              return kprimaryColor;
                            }
                            return kprimaryColor;
                          }),
                          value: inviteController.isContactInList(contactInfo.phones.first.number),
                          side: BorderSide(
                            color: kBlackColor.withOpacity(0.3),
                            width: 1.0,
                            style: BorderStyle.solid,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          // we need it on gesture detector
                          onChanged: null,
                        ));
                  }),
            ],
          ),
        ),
      ],
    );
  }

  FutureBuilder<td.Uint8List?> buildFutureBuilder() {
    return FutureBuilder<td.Uint8List?>(
        future: FastContacts.getContactImage(contactInfo.id),
        builder: (context, snapshot) => snapshot.hasData
            ? Container(
                height: 88,
                width: 88,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    border: Border.all(
                      color: kBaseGrey,
                      width: 1,
                    ),
                    shape: BoxShape.circle,
                    image: DecorationImage(image: MemoryImage(snapshot.data!), fit: BoxFit.cover)))
            : Container(
                height: 88,
                width: 88,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    border: Border.all(
                      color: kBaseGrey,
                      width: 1,
                    ),
                    shape: BoxShape.circle,
                    color: kprimaryColorLight),
                child: Text(
                  getName(contactInfo.displayName),
                  textAlign: TextAlign.center,
                  style: CustomTypography.subHeading.copyWith(color: kprimaryColor),
                ),
              ));
  }
}
