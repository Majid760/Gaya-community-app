import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gaya/controller/app_config_controller.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/utils/methods.dart';
import 'package:gaya/view/community/communities/services/communities_services.dart';

import '../../../../utils/logger.dart';

class CommunityArchiveServices {
  int _LIMIT = 15;
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  final CommunitiesServices _communitiesServices = CommunitiesServices();
  final _configController = AppConfigurationController.to;

  Future<List<Community>> requestMore() async {
    List<Community> _communities = [];
    try {
      var query = _communitiesServices.getArchivedCommunitiesQuery().limit(_LIMIT);

      // #5: If we have a document start the query after it
      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      if (!_hasMore) {
        return [];
      }

      final snapshot = await query.get();
      MyLoggerServices.to.print("Fetched $runtimeType data length: ${snapshot.docs.length}");
      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
      } else {
        _hasMore = false;
        return [];
      }

      QuerySnapshot<Map<String, dynamic>> querySnapshot = snapshot;

      /// remove hidden communities
      if (querySnapshot.docs.isNotEmpty) {
        print("communities: ${querySnapshot.docs.length}");
        querySnapshot.docs.removeWhere((element) => _configController.isHiddenCommunity(communityId: element.id));
        print("communities: ${querySnapshot.docs.length}");
      }

      /// Parse the data snapshot excluding hidden communities
      _communities = await Methods.parseItems(snapshot, (data) {
        if (!_configController.isHiddenCommunity(communityId: data["communityId"])) {
          return Community.fromMap(data);
        }
        return null;
      });

      _hasMore = _communities.length == _LIMIT;
    } catch (_) {
      MyLoggerServices.to.print("Err at $runtimeType _requestMore : $_");
    }
    return _communities;
  }

  void reset() {
    _lastDocument = null;
    _hasMore = true;
  }
}
