import 'package:flutter/cupertino.dart';

import '../../../../widgets/community_view_widgets/communities.skeleton.widget.dart';

class LoadingCommunitiesSkeletonGridView extends StatelessWidget {
  const LoadingCommunitiesSkeletonGridView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        Padding(padding: EdgeInsets.all(4.0), child: ShowCommunityShimmer()),
        Padding(padding: EdgeInsets.all(8.0), child: ShowCommunityShimmer()),
        Padding(padding: EdgeInsets.all(8.0), child: ShowCommunityShimmer()),
      ],
    );
  }
}
