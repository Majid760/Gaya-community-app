import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/skeleton.post.component.dart';
import 'package:gaya/components/textfield.component.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/shared/controller/mentioned_user_controller.dart';
import 'package:gaya/shared/view/widget/gaya_back_button.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/utils/theme/app_spaces.dart';
import 'package:gaya/view/profile/components/user_list_view.dart';
import 'package:get/get.dart';

class MyFriendView extends StatefulWidget {
  const MyFriendView({Key? key}) : super(key: key);

  @override
  State<MyFriendView> createState() => _MyFriendViewState();
}

class _MyFriendViewState extends State<MyFriendView> {
  TextEditingController searchCntrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Get.lazyPut(() => MentionedUserController());
  }

  @override
  void dispose() {
    searchCntrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = const EdgeInsets.symmetric(horizontal: 20).r;

    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.viewInsetsOf(context).top),
      child: Scaffold(
          backgroundColor: kWhiteColor,
          body: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    systemOverlayStyle: SystemUiOverlayStyle.dark,
                    centerTitle: true,
                    backgroundColor: kWhiteColor,
                    elevation: 0,
                    title: Text(GayaStrings.my_friends.tr, style: CustomTypography.bodyStyle),
                    pinned: true,
                    floating: true,
                    snap: true,
                    automaticallyImplyLeading: false,
                    leading: const GayaBackButton(),
                  ),
                ];
              },
              body: GetBuilder<UserFriendsController>(
                  init: UserFriendsController(),
                  autoRemove: false,
                  builder: (controller) {
                    if (controller.isLoading) {
                      return Padding(
                        padding: padding,
                        child: Column(
                          children: [
                            SizedBox(height: 20.h),
                            for (int i = 0; i < 8; i++) ...[
                              UsersSkeleton(
                                trailingButtonHeight: 30.h,
                                trailingButtonWidth: MediaQuery.sizeOf(context).width * 0.25,
                                trailingButtonPadding: EdgeInsets.only(left: 70.r),
                              ),
                              SizedBox(height: 24.h),
                            ]
                          ],
                        ),
                      );
                    }
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20).r,
                          child: GayaSearchTextField(controller: searchCntrl, onChanged: (text) => controller.searchFriend(text)),
                        ),
                        SizedBox(height: 12.h),
                        MyDividers.postFeed,
                        Expanded(
                          child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20).r,
                              child: searchCntrl.text.isNotEmpty
                                  ? controller.searchedUsers.isNotEmpty
                                      ? ListView.separated(
                                          padding: EdgeInsets.symmetric(vertical: 8.h),
                                          itemCount: controller.searchedUsers.length,
                                          itemBuilder: (context, index) {
                                            UserModel userModel = UserModel(
                                                uId: controller.searchedUsers[index]['id'],
                                                name: controller.searchedUsers[index]['display'],
                                                profilePicture: controller.searchedUsers[index]['senderProfile']);
                                            return UserListTileView(
                                              userModel: userModel,
                                              tapOnViewProfile: () => Routes.viewProfile(uid: userModel.uId, model: userModel),
                                            );
                                          },
                                          separatorBuilder: (BuildContext context, int index) => SizedBox(height: 8.h),
                                        )
                                      : SizedBox(
                                height: MediaQuery.sizeOf(context).height * 0.4,
                                          child: Center(
                                              child: Text(GayaStrings.no_friend_found.tr, style: CustomTypography.body2DisableStyle)),
                                        )
                                  : controller.userFriends.isEmpty
                                      ? Center(child: Text(GayaStrings.no_friend_found.tr, style: CustomTypography.body2DisableStyle))
                                      : ListView.separated(
                                          itemCount: controller.userFriends.length,
                                          padding: EdgeInsets.symmetric(vertical: 8.h),
                                          itemBuilder: (context, index) {
                                            UserModel userModel = UserModel(
                                                uId: controller.userFriends[index]['id'],
                                                name: controller.userFriends[index]['display'],
                                                profilePicture: controller.userFriends[index]['senderProfile']);
                                            return UserListTileView(
                                              userModel: userModel,
                                              tapOnViewProfile: () => Routes.viewProfile(uid: userModel.uId, model: userModel),
                                            );
                                          },
                                          separatorBuilder: (BuildContext context, int index) => SizedBox(height: 8.h),
                                        )),
                        ),
                      ],
                    );
                  }))),
    );
  }
}
