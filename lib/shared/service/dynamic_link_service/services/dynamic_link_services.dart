// ignore_for_file: use_build_context_synchronously
import 'dart:async';

import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:gaya/components/check_for_app_update.dart';
import 'package:gaya/controller/app_config_controller.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/model/create.post.model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/services/services.dart';
import 'package:gaya/shared/constant/string_constant.dart';
import 'package:gaya/utils/logger.dart';
import 'package:gaya/utils/methods.dart';
import 'package:gaya/view/Auth/controller/login.controller.dart';
import 'package:gaya/view/chat/utils/configs.dart' as config;
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

import '../../../../utils/flavors/flavors.dart';
import '../enums/dynamic_link_type.dart';
import '../model/gaya_social_tag.dart';
import '../utils/dynamic_link_utils.dart';
import '../utils/query_param_consts.dart';

abstract class IDynamicLink {
  Future<void> initDynamicLinks(BuildContext context);

  Future<String?> createDynamicLink(String queryParams, {required GayaSocialTag tag});

  Future<void> onDynamicLinkNavigateTo({required Map<String, dynamic>? params, required BuildContext ctx});
}

/// * Required *PackageInfo* to create dynamic link - A Singleton class
class DynamicLinkServices implements IDynamicLink {
  static late FirebaseDynamicLinks dynamicLinks;
  static late Services services;
  static late MyLoggerServices logger;
  static late DynamicLinkUtils utils;
  final PackageInfo packageInfo;

  DynamicLinkServices._(this.packageInfo);

  static DynamicLinkServices? _dynamicLinkServices;

  factory DynamicLinkServices.init({required PackageInfo packageInfo}) {
    dynamicLinks = FirebaseDynamicLinks.instance;
    logger = MyLoggerServices.to;
    utils = DynamicLinkUtils();
    services = Services();
    return _dynamicLinkServices ??= DynamicLinkServices._(packageInfo);
  }

  final _debouncer = Debouncer(delay: 500.milliseconds);

  StreamSubscription? _subscription;

  @override
  Future<void> initDynamicLinks(BuildContext context) async {
    logger.print("initDynamicLinks");
    _subscription?.cancel();
    _subscription = dynamicLinks.onLink.listen((PendingDynamicLinkData? dynamicLink) {
      final Uri? uri = dynamicLink?.link;

      final queryParams = uri?.queryParameters;
      if (queryParams?.isNotEmpty ?? false) {
        logger.print("$queryParams <= query params onLink listen");
        // onDynamicLinkNavigateTo(params: queryParams, ctx: context);
        debounceOnDynamicLinkNavigation(params: queryParams, ctx: context);
      } else {
        logger.print("No deep link found listen");
      }
    });

    final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getInitialLink();

    final Uri? uri = data?.link;
    final queryParams = uri?.queryParameters;
    if (queryParams?.isNotEmpty ?? false) {
      logger.print("$queryParams <= query params onLink getInitialLink");
      debounceOnDynamicLinkNavigation(params: queryParams, ctx: context);
    } else {
      logger.print("No deep link found getInitialLink");
    }
  }

  @override
  Future<void> onDynamicLinkNavigateTo({required Map<String, dynamic>? params, required BuildContext ctx}) async {
    logger.print("onDynamicLinkNavigateTo");
    if (params == null) return;

    /// * if context is null/not mounted, we will use Get.context
    if (ctx.mounted == false) ctx = Get.context!;
    try {
      final type = utils.getDynamicLinkType(params[QueryParamConst.type]);
      final id = params[QueryParamConst.id];
      final isPrivate = params[QueryParamConst.isPrivate];
      final communityId = utils.isCommunityIdInvolved(type) ? _getTypeSafeCommunityId(params) : null;
      final community =
          utils.isCommunityIdInvolved(type) ? AppConfigurationController.to.getCommunityById(communityId: communityId ?? id) : null;

      switch (type) {
        case DynamicLinkType.shareCommunityPost:
          logger.print("shareCommunityPost => communityId: $communityId, id: $id, isPrivate: $isPrivate");

          /// user model will be automatically fetched in post detail screen

          final community = Community(communityId: communityId);
          Routes.postDetailsScreen(post: Post(postid: id, postedBy: UserModel(), community: community), community: community);

          // InCase community is private and user not joined: show modal sheet to join community
          // Methods.showModalSheetToJoinCommunity(communityId: communityId, ctx: ctx, isFromDeepLink: true);

          break;
        case DynamicLinkType.communityInvite:
          logger.print("communityInvite => communityId: $communityId, id: $id, isPrivate: $isPrivate");

          Methods.showModalSheetToJoinCommunity(communityId: communityId, ctx: ctx, isFromDeepLink: true);
          break;
        case DynamicLinkType.shareCommunityProfile:
          logger.print("shareCommunityProfile");
          if (isPrivate == false || AppConfigurationController.to.isMemberOfCommunity(communityId ?? id)) {
            MyLoggerServices.to.print("community is public or user is member of community");

            if (community != null) {
              logger.print("community != null => communityId: $communityId, id: $id, isPrivate: $isPrivate");
              return Methods.routeToGroup(community: community);
            } else {
              logger.print("community == null => communityId: $communityId, id: $id, isPrivate: $isPrivate");
              return Routes.groupView(community: community);
            }
          }
          MyLoggerServices.to.print("community is private and user is not member of community showModalSheetToJoinCommunity");
          // Incase community is private and user not joined: show modal sheet to join community
          Methods.showModalSheetToJoinCommunity(communityId: communityId ?? id, ctx: ctx, isFromDeepLink: true);
          break;
        case DynamicLinkType.userProfile:
          logger.print("userProfile => communityId: $communityId, id: $id, isPrivate: $isPrivate");
          Routes.viewProfile(uid: id, model: UserModel(uId: id));
          break;
        case DynamicLinkType.groupChat:
          logger.print("groupChat => groupChatId: $id, id: $id, isPrivate: $isPrivate");
          if (GayaRemoteConfig.to.isConnectyCubeEnabled) {
            openGroupChatNavigationUsingDynamicLink(ctx, id);
          }
          break;
        case DynamicLinkType.idle:
          logger.print("idle dynami link");
          break;
      }
    } catch (e) {
      debugPrint("oops: $e");
    }
  }

  String? _getTypeSafeCommunityId(params) {
    try {
      return params[QueryParamConst.communityId];
    } catch (e) {
      logger.print("_getTypeSafeCommunityId Error: $e");
      return null;
    }
  }

  @override
  Future<String?> createDynamicLink(String queryParams, {GayaSocialTag? tag, String minimumVersion = "0.0.0"}) async {
    final baseUrl = F.getDynamicLinkBaseUrl;
    debugPrint("createDynamicLink: ${baseUrl + Env.kDynamicLinkEndPoint + queryParams}");
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: baseUrl,
      link: Uri.parse(baseUrl + Env.kDynamicLinkEndPoint + queryParams),
      androidParameters: const AndroidParameters(packageName: "com.gaya.android", minimumVersion: 0),
      iosParameters: IOSParameters(appStoreId: Env.kAppStoreId, bundleId: "com.gaya.ios", minimumVersion: minimumVersion),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: tag?.title,
        description: tag?.description,
        imageUrl: tag != null && tag.pictureURL != null ? Uri.parse(tag.pictureURL!) : null,
      ),
    );

    Uri url;

    final ShortDynamicLink shortLink =
        await FirebaseDynamicLinks.instance.buildShortLink(parameters, shortLinkType: ShortDynamicLinkType.short);

    url = shortLink.shortUrl;

    return url.toString();
  }

  void debounceOnDynamicLinkNavigation({required Map<String, dynamic>? params, required BuildContext ctx}) {
    _debouncer.call(() {
      onDynamicLinkNavigateTo(params: params, ctx: ctx);
    });
  }

  openGroupChatNavigationUsingDynamicLink(ctx, dynamic id) async {
    String? userId = UserModel.to.uId;

    try {
      if (userId != null) {
        Provider.of<LoginController>(ctx ?? Get.context!, listen: false).connectyCubeLogin(
            ctx ?? Get.context!,
            CubeUser(
              login: UserModel.to.uId,
              password: UserModel.to.uId,
            ),
            saveUser: true,
            isFromDeepLink: id);
      } else {
        init(
          config.APP_ID,
          config.AUTH_KEY,
          config.AUTH_SECRET,
        );
      }
    } catch (_) {}
  }
}
