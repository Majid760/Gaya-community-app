import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gaya/components/profile_image_widget.dart';
import 'package:gaya/model/create.post.model.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/textstyles.dart';

import '../../../components/skeleton.post.component.dart';
import '../../../controller/app_config_controller.dart';
import '../../../model/community.model.dart';
import '../../../routing/getx_route_methods.dart';

class CommunityPostWidget extends StatefulWidget {
  final String? postId;
  final bool isCurrentUser;

  ///Loads the post preview with future builder to avoid extra network calls
    CommunityPostWidget({Key? key, required this.postId, this.isCurrentUser = true}) : super(key:   UniqueKey());

  @override
  State<CommunityPostWidget> createState() => _CommunityPostWidgetState();
}

class _CommunityPostWidgetState extends State<CommunityPostWidget> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> loadPostQuery;

  @override
  void initState() {
    super.initState();
    loadPostQuery = _getPostFromCacheOrServer(postId: widget.postId!);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _getPostFromCacheOrServer({required String postId}) async {
      DocumentSnapshot<Map<String, dynamic>>? post;
    try{
      post =
      await FirebaseFirestore.instance.collection("communityposts").doc(postId).get(const GetOptions(source: Source.cache));
    }catch(_){}

    if (!(post?.exists ?? true) || post?.data() == null) {
      debugPrint("Post not found in cache, fetching from server: $postId");
      post = await FirebaseFirestore.instance.collection("communityposts").doc(postId).get(const GetOptions(source: Source.server));
    }

    return post!;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: 150,
      child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
          future: loadPostQuery,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const PostThumbnailSkeleton();
            }
            if (snapshot.hasError || snapshot.data == null || !snapshot.data!.exists || snapshot.data!.data() == null) {
              return const PostThumbnailError();
            }
            Post createPostModel = Post.fromMap(snapshot.data!.data()!);

            /// Check if the community is private and the user is not a member
            if(createPostModel.community.isCommunityPrivate && AppConfigurationController.to.isMemberOfCommunity(createPostModel.communityId ?? "", includesAll: true) == false){

              return   PostThumbnailError(post: createPostModel, message: "You don't have permission to view",);
            }
            return PostMessageThumbnailWidget(createPostModel: createPostModel, isCurrentUser: widget.isCurrentUser);
          }),
    );
  }
}

class PostMessageThumbnailWidget extends StatelessWidget {
  final Post createPostModel;
  final bool isCurrentUser;

  const PostMessageThumbnailWidget({Key? key, required this.createPostModel, required this.isCurrentUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Community createCommunityModel = createPostModel.community;

    if (isCurrentUser == true) {
      /// For Current User
      return createPostModel.multipleImages?.isEmpty == true
          ? InkWell(
              onTap: () {
                Routes.postDetailsScreen(post: createPostModel, community: createCommunityModel);
              },
              child: Container(
                padding: const EdgeInsets.only(left: 10),
                height: 60,
                width: 150,
                decoration: BoxDecoration(color: kBaseGrey, borderRadius: BorderRadius.circular(8)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      createCommunityModel.communityName.toString(),
                      style: CustomTypography.body2StyleWeightBlack,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      createPostModel.postDescription.toString(),
                      style: CustomTypography.body4StyleLowWeight,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () {
                  Routes.postDetailsScreen(post: createPostModel, community: createCommunityModel);
                  // Get.to(() => CommentWithPostScreen(postModel: createPostModel, userModel: userModel));

                  // Navigator.of(context).pushNamed(route.postWithComments, arguments: {
                  //   'userModel': userModel,
                  //   'postModel': createPostModel,
                  //   'communityModel': createCommunityModel,
                  // });
                },
                child: SizedBox(
                  height: 188,
                  width: 150,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      PostImageWidget(url: createPostModel.multipleImages?[0] ?? "", height: 188, width: 150, size: const Size(150, 188)),
                      Container(
                        color: const Color.fromRGBO(0, 0, 0, 0.4),
                        height: 188,
                        width: 150,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              createPostModel.postDescription.toString(),
                              style: CustomTypography.body2StyleWeight,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              createCommunityModel.communityName.toString(),
                              style: CustomTypography.body4StyleWhiteLessWeight,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
    } else {
      /// For Other User
      return createPostModel.multipleImages!.isEmpty
          ? InkWell(
              onTap: () {
                Routes.postDetailsScreen(post: createPostModel, community: createCommunityModel);
                // Get.to(() => CommentWithPostScreen(postModel: createPostModel, userModel: userModel));

                // Navigator.of(context).pushNamed(route.postWithComments, arguments: {
                //   'userModel': userModel,
                //   'postModel': createPostModel,
                //   'communityModel': createCommunityModel,
                // });
              },
              child: Container(
                padding: const EdgeInsets.only(left: 10),
                height: 60,
                width: 150,
                decoration: BoxDecoration(color: kBaseGrey, borderRadius: BorderRadius.circular(8)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      createCommunityModel.communityName.toString(),
                      style: CustomTypography.body2StyleWeightBlack,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      createPostModel.postDescription.toString(),
                      style: CustomTypography.body4StyleLowWeight,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          :   ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () {
                  Routes.postDetailsScreen(post: createPostModel, community: createCommunityModel);
                  // Get.to(() => CommentWithPostScreen(postModel: createPostModel, userModel: userModel));

                  // Navigator.of(context).pushNamed(route.postWithComments, arguments: {
                  //   'userModel': userModel,
                  //   'postModel': createPostModel,
                  //   'communityModel': createCommunityModel,
                  // });
                },
                child: SizedBox(
                  height: 188,
                  width: 150,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      PostImageWidget(url: createPostModel.multipleImages?[0] ?? "", height: 188, width: 150, size: const Size(150, 188)),
                      Container(
                        color: const Color.fromRGBO(0, 0, 0, 0.4),
                        height: 188,
                        width: 150,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              createPostModel.postDescription.toString(),
                              style: CustomTypography.body2StyleWeight,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              createCommunityModel.communityName.toString(),
                              style: CustomTypography.body4StyleWhiteLessWeight,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )  ;
    }
  }
}
