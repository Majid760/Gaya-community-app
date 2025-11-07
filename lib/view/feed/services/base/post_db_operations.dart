import 'package:gaya/model/reaction_model.dart';

import '../../../../model/local/crown_payload.dart';
import '../../../../services/services.dart';
import '../../../../shared/service/crown_service/crown_services.dart';

//contains the implementation of the methods for the firebase services interface
mixin PostDbOperationsImpl {
  Services commonServices = Services();
  CrownServices crownServices = CrownServices();

  Future<void> likeAPost(
    String postId,
    String communityId,
  ) async {
    await commonServices.likeOnPost(
      postId,
      communityId,
    );
  }

  Future<void> unlikeAPost(
    String postId,
    String communityId,
  ) async {
    await commonServices.unlikeOnPost(
      postId,
      communityId,
    );
  }

  Future<void> likeReactionAPost(
    String postId,
    String communityId,
    ReactionModel reactionModel,
  ) async {
    await commonServices.likeReactionOnPost(postId, communityId, reactionModel);
  }

  Future<void> unLikeReactionAPost(
    String postId,
    String communityId,
  ) async {
    await commonServices.unLikeReactionOnPost(
      postId,
      communityId,
    );
  }

  Future<bool> crownAPost(String postId, String receiverId, String currentUserId) async {
    final payload = CrownPayload(postId: postId, senderId: currentUserId, receiverId: receiverId);
    return await crownServices.crownOnPost(payload: payload);
  }

  Future<void> pinAPost(String communityId, String postId) async {
    await commonServices.pinAPost(communityId, postId);
  }

  Future<void> unpinAPost(String communityId, String postId) async {
    await commonServices.unpinAPost(communityId, postId);
  }
}
