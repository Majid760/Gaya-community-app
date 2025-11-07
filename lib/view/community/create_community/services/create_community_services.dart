import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gaya/components/snackbar.component.dart';
import 'package:gaya/model/communities.memebers.model.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/services/notification/notification_api/notification_api.dart';
import 'package:gaya/services/services.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:get/get.dart';

abstract class ICreateComunityServices {
  Future addNewMemberInCommunity(
      {required String communityId, required CommunityMembership communitiesMembers, required BuildContext context});

  Future createNewCommunity({required Community createNewCommunity, required BuildContext context});
}

class CreateCommunityServices implements ICreateComunityServices {

  //Add new member to community
  @override
  Future addNewMemberInCommunity(
      {required String communityId, required CommunityMembership communitiesMembers, required BuildContext context}) async {
    if (FirebaseAuth.instance.currentUser == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('communities')
          .doc(communityId)
          .collection('communityMembers')
          .doc(communitiesMembers.userUid)
          .set(
            communitiesMembers.toMap(),
          );
    } catch (e) {
      snackBar(context, GayaStrings.unable_create_community_member.tr, kRedColor);
    }
  }

  //Add new community
  @override
  Future createNewCommunity({required Community createNewCommunity, required BuildContext context}) async {
    if (FirebaseAuth.instance.currentUser == null) return;

    try {
      await FirebaseFirestore.instance.collection('communities').doc(createNewCommunity.communityId).set(
        {
          ...createNewCommunity.toMap(),
          'score': 0,
        },
      );
    } catch (e) {
      snackBar(context, GayaStrings.unable_create_community.tr, kRedColor);
    }
  }
}
