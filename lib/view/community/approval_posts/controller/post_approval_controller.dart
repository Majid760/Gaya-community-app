import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:gaya/model/create.post.model.dart';
import 'package:gaya/shared/service/base/easy_refresh_impl.dart';
import 'package:gaya/utils/logger.dart';
import 'package:gaya/view/community/controllers/base_controller.dart';
import 'package:get/get.dart' show Get, Inst;
import 'package:helpers/helpers.dart';

import '../../../../model/user.model.dart';
import '../../../../services/services.dart';
import '../../../feed/services/post_isolations.dart';
import '../services/post_approval_services.dart';

class PostApprovalController extends BaseController implements EasyRefreshImpl {
  static PostApprovalController to({required String tag}) => Get.find(tag: tag);
  final String communityId;
  final _commonServices = Services();

  PostApprovalController({required this.communityId});

  late final _postApprovalServices = PostApprovalServices(communityId: communityId);
  final _logger = MyLoggerServices.to;

  bool get isFeedEmpty => _posts.isEmpty;

  bool isFirstTime = false;

  List<Post> _posts = [];

  List<Post> get posts => _posts;

  @override
  void onInit() {
    super.onInit();
    getApprovalPosts(isInitial: true);
  }

  @override
  Future<void> onPullRefresh() async {
    _posts = [];
    isFirstTime = false;

    /// set isLoading false - no need to notify because we already have a setLoadingTrue in [getApprovalPosts]
    setLoading(false, notify: false);

    /// reset service to initial state
    _postApprovalServices.reset();

    /// get posts as initial
    await getApprovalPosts(isInitial: true);
  }

  @override

  /// [isNatural] decides when call approval ie:
  /// we are invoking this from both accept/reject button so we
  /// need to call the [onLoadMore] only when we are at the bottom of the list or
  /// at least half of the list.
  ///
  /// * returns `-1` if called from accept/reject button and not from the bottom of the list
  Future<int> onLoadMore({bool isNatural = true}) async {
    if (!isNatural) {
      /// invoke only if we are at half of the list
      return isListHalf ? await getApprovalPosts() : -1;
    }
    return await getApprovalPosts();
  }

  bool get isListHalf {
    debugPrint(
        "Half Post: ${(posts.length / 2).floor()} and Total Posts: ${posts.length} && condition: ${posts.length == _postApprovalServices.postLimitSize / 2}, MAX: ${_postApprovalServices.postLimitSize}");
    return (posts.length) == (_postApprovalServices.postLimitSize / 2).ceil();
  }

  @override
  EasyRefreshController refreshController = EasyRefreshController(
    controlFinishLoad: true,
  );

  /// Get Approval Posts - Adds the Approval posts to the list and returns the length of the new posts
  Future<int> getApprovalPosts({bool isInitial = false}) async {
    try {
      MyLoggerServices.to.print(" requestMoreData called");
      if (isInitial) setLoading(true);
      isFirstTime = true;
      final newPosts = await _postApprovalServices.requestMoreData();

      /* ---------------------- GETTER USERS WHO POSTED POSTS --------------------- */
      for (var post in newPosts) {
        UserModel? userModel = await _commonServices.getUserById(
          post.postedBy.uId,
          forcefullyServer: true,
        );
        if (userModel != null) {
          post.postedBy = userModel;
        }
      }

      /* ------------------------------------ . ----------------------------------- */

      MyLoggerServices.to.print("newPosts.length ${newPosts.length}");
      _posts.addAll(newPosts);
      //sort posts in thread
      _posts = await CustomIsolatePost.sortPostInThread(_posts);

      setLoading(false);
      return newPosts.length;
    } catch (_) {
      _logger.printError(_, info: "getApprovalPosts");
      setLoading(false);
    }
    return 0;
  }

  /// To Approve Post both locally and in the DB
  Future<bool> approvePost(
      {required String userId, required String postId, required String communityId, required String communityName}) async {
    bool isSuccessful = false;
    int? removedIndex = _posts.removeFirstWhere((element) => element.postid == postId);

    /// if removedIndex is not null, that means its successfully approved so removed the post from the list.
    /// This will remove the post from the DB.
    if (removedIndex != null) {
      isSuccessful =
          await _postApprovalServices.approvePost(userId: userId, postId: postId, communityId: communityId, communityName: communityName);
    }

    /// if the list is half, then we need to call the [onLoadMore] to get the next set of posts
    if (isSuccessful) onLoadMore(isNatural: false);
    update();
    return isSuccessful;
  }

  Future<bool> rejectPost(
      {required String userId, required String postId, required String communityId, required String communityName}) async {
    bool isSuccessful = false;
    int? removedIndex = _posts.removeFirstWhere((element) => element.postid == postId);

    /// if removedIndex is not null, that means its successfully approved so removed the post from the list.
    /// This will remove the post from the DB.
    if (removedIndex != null) {
      isSuccessful =
          await _postApprovalServices.rejectPost(userId: userId, postId: postId, communityId: communityId, communityName: communityName);
    }

    /// if the list is half, then we need to call the [onLoadMore] to get the next set of posts
    if (isSuccessful) onLoadMore(isNatural: false);

    update();
    return isSuccessful;
  }
}
