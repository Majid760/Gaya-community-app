import 'package:easy_refresh/easy_refresh.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaya/controller/communities.controller.dart';
import 'package:gaya/controller/topics.controller.dart';
import 'package:gaya/gen/assets.gen.dart';
import 'package:gaya/widgets/profile.widgets/button.widget.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../components/textfield.component.dart';
import '../../../routing/getx_route_methods.dart';
import '../../../shared/view/screen/gaya_search_screens/community_search_screen.dart';
import '../../../utils/asset_images.dart';
import '../../../utils/const.dart';
import '../../../utils/language/translation.dart';
import '../../../utils/refresh_builder_utils.dart';
import '../../../utils/textstyles.dart';
import '../../../utils/theme/app_colors.dart';
import '../../../utils/theme/app_typography.dart';
import '../../Auth/controller/require.sigin.register.dart';
import 'components/guest_communities_list.dart';
import 'components/hot_communities_list.dart';
import 'components/my_communities_list.dart';
import 'components/new_communities_list.dart';
import 'components/recommended_communities_list.dart';
import 'components/top_private_communities_list.dart';
import 'components/user_interest_communities_list.dart';
import 'controllers/guest_communities_controller.dart';
import 'controllers/hottopic_communities_controller.dart';
import 'controllers/interest_communities_controller.dart';
import 'controllers/new_communities_controller.dart';
import 'controllers/recommended_communities_controller.dart';
import 'controllers/top_private_communities_controller.dart';

class CommunitiesView extends StatefulWidget {
  const CommunitiesView({Key? key}) : super(key: key);

  @override
  State<CommunitiesView> createState() => _CommunitiesViewState();
}

class _CommunitiesViewState extends State<CommunitiesView> {
  User? user = FirebaseAuth.instance.currentUser;

  late CommunitiesController _communitiesController;

  @override
  void initState() {
    _communitiesController = context.read<CommunitiesController>();
    _communitiesController.communitiesScrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _communitiesController.communitiesScrollController.dispose();
    user = null;
    super.dispose();
  }

  Future<void> _onRefresh({bool isGuest = false}) async => setState(() {
        /// Guest Communities Refresh
        if (isGuest) {
          GuestCommunitiesController.to.onRefreshPull();
          return;
        }

        /// update my communities list to get updated stream
        /// in My Communities Horizontal list view
        if (!isGuest) {
          context.read<CommunitiesController>().updateMyCommunities();
        }

        /// User Communities Refresh
        if (InterestCommunitiesController.isRegistered) {
          InterestCommunitiesController.to.onRefreshPull();
        }
        if (RecommendedCommunitiesController.isRegistered) {
          RecommendedCommunitiesController.to.onRefreshPull();
        }
        if (HotTopicCommunitiesController.isRegistered) {
          HotTopicCommunitiesController.to.onRefreshPull();
        }
        if (TopPrivateCommunitiesController.isRegistered) {
          TopPrivateCommunitiesController.to.onRefreshPull();
        }
        if (NewCommunitiesController.isRegistered) {
          NewCommunitiesController.to.onRefreshPull();
        }
      });

  Future _onLoadMore() async {

    final isFetched = await RecommendedCommunitiesController.to.onLoadMore();

    if (!isFetched) {
      return IndicatorResult.noMore;
    }
    return isFetched;
  }

  final EasyRefreshController _controller = EasyRefreshController();

  // List<Widget> communities = [
  //   const MyCommunitiesListView(),
  //   //HOT TOPICS
  //   const HotCommunities(),
  //
  //   const UserInterestCommunities(),
  //   const RecommendedCommunities(),
  //   SizedBox(height: distance_20.r),
  // ];

  @override
  Widget build(BuildContext context) {
    final header = RefreshBuilderUtils.header;
    final footer = RefreshBuilderUtils.footer;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: kTransparentColor,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: kBaseGrey.withOpacity(0.5))),
        title: Text(
          GayaStrings.communities_txt.tr,
          style: CustomTypography.bodyStyle,
          textAlign: TextAlign.center,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4).r,
            child: CupertinoIconButton(
              icon: GayaSvgAsset(
                Assets.assets.icons.archive,
                width: 24.r,
                height: 24.r,
                color: AppColors.black,
              ),
              onPressed: Routes.seeArchivedCommunitiesView,
            ),
          )
        ],
        centerTitle: true,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: Size(0.0, distance_40.r),
          child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12).r,
              child: GayaSearchTextField(
                isEnabled: false,
                onTap: () {
                  if (user != null) {
                    if (DeviceCheck.isIOS) {
                      showCupertinoDialog(context: context, builder: (context) => const CommunitySearchScreen(), barrierDismissible: true);
                    } else {
                      Get.to(() => const CommunitySearchScreen(), transition: Transition.cupertinoDialog);
                    }
                  } else {
                    Get.to(() => const RequireSignRegisterView(userNotSigin: true), transition: Transition.cupertinoDialog);
                  }
                },
              )),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      body: user != null
          ? EasyRefresh.builder(
              controller: _controller,
              // noMoreLoad: false,
              header: header,
              footer: footer,
              onRefresh: () async => _onRefresh(),
              onLoad: _onLoadMore,
              childBuilder: (context, physics) {
                return ListView(
                  physics: physics,
                  controller: _communitiesController.communitiesScrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    const HeaderLocator(),
                    const MyCommunitiesListView(
                      isCallOnHome: false,
                      isHomeFeed: false,
                    ),
                    //HOT TOPICS
                    const HotCommunities(),

                    const NewCommunities(),
                    const TopPrivateCommunities(),
                    const UserInterestCommunities(),

                    const RecommendedCommunities(),
                    const FooterLocator(),
                    SizedBox(height: distance_10.r),
                  ],
                );
              },
            )
          :

          /// Guest User Communities -- Non-User
          RefreshIndicator(
              color: kprimaryColor,
              onRefresh: () async => await _onRefresh(isGuest: true),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _communitiesController.communitiesScrollController,
                padding: EdgeInsets.zero,
                children: [
                  const GuestCommunities(),
                  SizedBox(height: distance_20.r),
                ],
              ),
            ),
      floatingActionButton: user == null
          ? const SizedBox()
          : FloatingActionButton(
              backgroundColor: kTransparentColor,
              elevation: 0,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onPressed: () {
                HapticFeedback.mediumImpact();
                if (user == null) {
                  Routes.loginView();
                }
                /* else if (UserModel.to.userInfluenceScoreWithCrowns < 60) {
                  GayaSnackBar.show(
                      type: GayaSnackBarType.problem,
                      text: GayaStrings.community_creation_failed_due_to_low_influence_points.tr,
                      context: context);
                } */
                else {
                  context.read<TopicsController>().selectedList.clear();
                  context.read<TopicsController>().usersInterest.clear();

                  Routes.createCommunityView(ctx: context);
                }
              },
              child: Container(
                height: 48.h,
                width: 48.w,
                padding: const EdgeInsets.all(12).r,
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(borderRadius_4).r),
                child: SvgPicture.asset(Assets.assets.icons.communities, color: Colors.white, height: 24.r, width: 24.r),
              ),
            ),
    );
  }
}
