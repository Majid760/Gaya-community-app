import 'package:gaya/model/community.model.dart';
import 'package:gaya/view/feed/services/local/posts/seen_unseen_post_services.dart';
import 'package:get/get.dart';

import '../../../../../services/services.dart';
import '../../../../community/controllers/base_controller.dart';

class CommunityUserFeedController extends BaseController{
  Community community;
  CommunityUserFeedController({required this.community});



  @override
  void onInit() {
    super.onInit();
    getCommunity();
  }

  bool  isCurrentCommunitySelected(String communityId){
    return community.communityId==communityId;
  }
  final _commonServices = Get.find<Services>();

  /// Fetch community if there is no detail present of community except Id
  Future<void> getCommunity() async {
    setLoading(true);
    setCommunity(community, notify: false);

    /// case where only communityId has been passed as model, so we need to fetch the community details
    if (community.communityName == null) {
      /// fetch from firebase
      final _community = await _commonServices.getCommunityDetailsModel(community.communityId ?? "");
      if (_community != null) {
        /// asign the fetched community to the local community variable
        community = _community;
      }
    }

    setLoading(false);
  }


  void setCommunity(Community community, {bool notify = true}) {
    if (this.community.communityId == community.communityId) return;

    SeenUnseenPostServices.instance.setLastVisit(this.community.communityId ?? "");
    this.community = community;
    // Get.delete<CommunityUserFeedController>(tag: this.community.communityId);
    update();
    update();
  }

}
