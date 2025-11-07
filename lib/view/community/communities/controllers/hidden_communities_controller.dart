import 'package:flutter/cupertino.dart';
import 'package:gaya/controller/app_config_controller.dart';
import 'package:gaya/view/community/controllers/base_controller.dart';
import 'package:get/get.dart';

import '../../../../model/community.model.dart';
import '../../../../services/services.dart';
import '../../../../utils/methods.dart';

class HiddenCommunitiesController extends BaseController {
  @override
  void onInit() {
    super.onInit();
    getAllHiddenCommunities();
  }

  final services = Get.find<Services>();

  final List<Community> _communities = [];

  List<Community> get communities => _communities;

  Future<void> getAllHiddenCommunities() async {
    setLoading(true);
    List<String> ids = AppConfigurationController.to.getHiddenCommunitiesIds();

    if (ids.isEmpty) {
      /// if the ids are empty, then get the ids from the server
      ids = (await services.getHiddenCommunities()).map((e) => e.communityId ?? "").toList();
    }

    /// if the ids are still empty, then return
    if (ids.isEmpty) {
      setLoading(false);
      return;
    }

    /// split the list into chunks of 10
    /// then get the users by ids
    /// then add the users to the list
    /// then return the list
    Methods.generateListOfChunks(ids).forEach((communityIdsChunk) async {
      final chunkedCommunities = await services.getCommunitiesByIds(communityIdsChunk);
      _communities.addAll(chunkedCommunities);
      debugPrint("length: ${_communities.length}");
      setLoading(false);
    });


  }

  /// unhide the community with appConfig
  Future<void> onUnHide({required String id}) async {
    AppConfigurationController.to.hideOrUnHideCommunity(communityId: id, isUnhideOperation: true);
    _communities.removeWhere((element) => element.communityId == id);
    update();
  }
}
