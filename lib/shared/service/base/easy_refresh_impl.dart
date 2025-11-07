import 'package:easy_refresh/easy_refresh.dart';

abstract class EasyRefreshImpl {
  EasyRefreshController refreshController = EasyRefreshController();

  Future<void> onPullRefresh();

  Future<void> onLoadMore();
}
