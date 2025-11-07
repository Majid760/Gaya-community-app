import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/view/community/communities/components/community_item.dart';
import 'package:gaya/widgets/community_view_widgets/community.row.widget.dart';
import 'package:provider/provider.dart';

import '../../controller/communities.controller.dart';
import '../../model/community.model.dart';
import '../../model/topic.model.dart';
import '../../utils/textstyles.dart';

class ShowCommunitiesWhenUserNull extends StatefulWidget {
  const ShowCommunitiesWhenUserNull({super.key});

  @override
  State<ShowCommunitiesWhenUserNull> createState() => _ShowCommunitiesWhenUserNullState();
}

class _ShowCommunitiesWhenUserNullState extends State<ShowCommunitiesWhenUserNull> {
  @override
  void initState() {
    final communitiesList = context.read<CommunitiesController>().listOfCommunitiesNames;
    communitiesList.clear();
    for (var i in topicsList) {
      communitiesList.add(i.title);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<CommunitiesController>(context, listen: false);

    return ListView.builder(
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
        itemCount: controller.listOfCommunitiesNames.length,
        itemBuilder: (context, index) {
          return CommunityViewWidgetForNonUser(interestName: controller.listOfCommunitiesNames[index]);
        });
  }
}

class CommunityViewWidgetForNonUser extends StatefulWidget {
  final String interestName;

  const CommunityViewWidgetForNonUser({Key? key, required this.interestName}) : super(key: key);

  @override
  State<CommunityViewWidgetForNonUser> createState() => _CommunityViewWidgetForNonUserState();
}

class _CommunityViewWidgetForNonUserState extends State<CommunityViewWidgetForNonUser> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final controller = Provider.of<CommunitiesController>(context, listen: false);
    return Column(
      children: [
        FutureBuilder(
            future: controller.allCommunitiesCategories(widget.interestName),
            builder: (context, recommenedSnapshot) {
              if (recommenedSnapshot.hasData) {
                QuerySnapshot snap = recommenedSnapshot.data as QuerySnapshot;
                return snap.docs.isEmpty
                    ? const SizedBox()
                    : CommunityRow(

                  onTap: () {
                    Routes.seeAllInterestCommunitiesView(communityName: widget.interestName);
                  },
                  style: CustomTypography.bodyStyle,
                  typeOfCommunity: widget.interestName,
                );

              }

              return const SizedBox();
            }),
        FutureBuilder(
            future: controller.allCommunitiesCategories(widget.interestName),
            builder: (context, recommendedsnapShot) {
              if (recommendedsnapShot.hasData) {
                QuerySnapshot getFilercommunities = recommendedsnapShot.data as QuerySnapshot;

                int recommendedLength = getFilercommunities.docs.length;
                return getFilercommunities.docs.isEmpty
                    ? const Center(child: SizedBox.shrink())
                    : SizedBox(
                        height: getFilercommunities.docs.isEmpty ? 0 : 112.h,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: recommendedLength > 8 ? 8 : recommendedLength,
                            itemBuilder: (context, index) {
                              Community showCommunities =
                                  Community.fromMap(getFilercommunities.docs[index].data() as Map<String, dynamic>);
                              return  CommunityItem(community: showCommunities,onHideCommunity: (){}, );
                            }),
                      );
              }
              return const SizedBox();
            }),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

