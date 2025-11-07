import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/shared/service/base/easy_refresh_impl.dart';
import 'package:gaya/utils/logger.dart';
import 'package:gaya/view/community/controllers/base_controller.dart';
import 'package:get/get.dart' show Get, Inst;
import 'package:get/get_navigation/get_navigation.dart';
import 'package:helpers/helpers.dart';

import '../services/membership_approval_services.dart';
import '../view/user_submitted_form_view.dart';

class MembershipApprovalController extends BaseController implements EasyRefreshImpl {
  static MembershipApprovalController to({required String tag}) => Get.find(tag: tag);
  final String communityId;

  MembershipApprovalController({required this.communityId});

  late final _membershipApprovalServices = MembershipApprovalServices(communityId: communityId);
  final _logger = MyLoggerServices.to;

  bool get isApprovalsEmpty => _members.isEmpty;

  bool isFirstTime = false;

  List<UserMembershipModel> _members = [];

  List<UserMembershipModel> get members => _members;

  @override
  void onInit() {
    super.onInit();
    getApprovalMembers(isInitial: true);
  }

  @override
  Future<void> onPullRefresh() async {
    _members = [];
    isFirstTime = false;

    /// set isLoading false - no need to notify because we already have a setLoadingTrue in [getApprovalPosts]
    setLoading(false, notify: false);

    /// reset service to initial state
    _membershipApprovalServices.reset();

    /// get posts as initial
    await getApprovalMembers(isInitial: true);
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
      return isListHalf ? await getApprovalMembers() : -1;
    }

    return await getApprovalMembers();
  }

  bool get isListHalf => members.length / 2 == _membershipApprovalServices.membersLimitSize;
  @override
  EasyRefreshController refreshController = EasyRefreshController(
    controlFinishLoad: true,
  );

  /// Get Approval Posts - Adds the Approval posts to the list and returns the length of the new posts
  Future<int> getApprovalMembers({bool isInitial = false}) async {
    try {
      MyLoggerServices.to.print(" requestMoreData called");
      if (isInitial) setLoading(true);
      isFirstTime = true;
      final newPosts = await _membershipApprovalServices.requestMoreData();
      _members.addAll(newPosts);
      setLoading(false);
      return newPosts.length;
    } catch (_) {
      _logger.printError(_, info: "getApprovalMembers");
      setLoading(false);
    }
    return 0;
  }

  /// To Approve Post both locally and in the DB
  Future<bool> approveUser({required UserModel user, required String communityId, required String communityName}) async {
    bool isSuccessful = false;
    int? removedIndex = _members.removeFirstWhere((element) => element.user.uId == user.uId);

    /// if removedIndex is not null, that means its successfully approved so removed the post from the list.
    /// This will remove the post from the DB.
    if (removedIndex != null) {
      isSuccessful = await _membershipApprovalServices.approveUser(user: user, communityId: communityId, communityName: communityName);
    }

    /// if the list is half, then we need to call the [onLoadMore] to get the next set of members
    if (isSuccessful) onLoadMore(isNatural: false);

    update();
    return isSuccessful;
  }

  Future<bool> rejectUser({required UserMembershipModel user, required String communityId, required String communityName}) async {
    bool isSuccessful = false;
    int? removedIndex = _members.removeFirstWhere((element) => element.user.uId == user.user.uId);

    /// if removedIndex is not null, that means its successfully approved so removed the post from the list.
    /// This will remove the post from the DB.
    if (removedIndex != null) {
      isSuccessful = await _membershipApprovalServices.rejectUser(user: user.user, communityId: communityId, communityName: communityName);
    }

    /// if the list is half, then we need to call the [onLoadMore] to get the next set of members
    if (isSuccessful) onLoadMore(isNatural: false);

    update();
    return isSuccessful;
  }

  Future<void> onViewForm({required UserMembershipModel membership, required BuildContext ctx}) async {
    return Get.to(UserSubmittedFormView(communityMembership: membership.communityMembership, userName: (membership.user.name ?? "")));
  }
}
