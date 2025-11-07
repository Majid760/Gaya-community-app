import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:gaya/controller/crowns_controller.dart';
import 'package:gaya/utils/logger.dart';
import 'package:gaya/utils/methods.dart';
import 'package:get/get.dart';

import '../../../model/local/crown_payload.dart';

abstract class ICrownServices {
  Future<bool> crownOnPost({required CrownPayload payload});

  Future<String?> getServerTimeStamp();

  Future<bool> crownOnComment({required CrownPayload payload});

  Future<bool> crownOnCommentReply({required CrownPayload payload});
}

class CrownServices implements ICrownServices {
  final _logger = MyLoggerServices.to;

  @override
  Future<bool> crownOnPost({required CrownPayload payload}) async {
    try {
      HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'giveCrownToPost',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
      );
      HttpsCallableResult response = await callable.call(payload.toPostJson());

      if (response.data["status"] == true) {
        return true;
      } else {
        _logger.print(response.data["message"]);
        if (response.data["statusCode"].toString() == "501") {
          await CrownsController.to.checkUpdatedCrownsInDb();
          Methods.showCrownsTotalModalSheet(ctx: Get.context);
        }
        return false;
      }
    } on FirebaseFunctionsException catch (ex) {
      _logger.print("Inside Catch Statement ${ex.details} ${ex.code}");
      return false;
    } catch (e) {
      _logger.print("catch Error crownOnPost(): $e");
    }
    return false;
  }

  @override
  Future<String?> getServerTimeStamp() async {
    return null;
  }

  @override
  Future<bool> crownOnComment({required CrownPayload payload}) async {
    try {
      debugPrint("this is payload ${payload.toCommentJson()}");
      HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'giveCrownToComment',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 30),
        ),
      );
      HttpsCallableResult response = await callable.call(payload.toCommentJson());
      debugPrint("this is respose=> ${response.data}");
      if (response.data["status"] == true) {
        return true;
      } else {
        _logger.print(response.data["message"]);
        if (response.data["statusCode"].toString() == "501") {
          await CrownsController.to.checkUpdatedCrownsInDb();
          Methods.showCrownsTotalModalSheet(ctx: Get.context);
        }
        return false;
      }
    } on FirebaseFunctionsException catch (ex) {
      _logger.print("Inside Catch Statement ${ex.details} ${ex.code}");
      return false;
    } catch (e) {
      _logger.print("catchedErrorcrownOnPost(): $e");
    }
    return false;
  }

  @override
  Future<bool> crownOnCommentReply({required CrownPayload payload}) async {
    try {
      debugPrint("this is payload ${payload.toReplyJson()}");
      HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'giveCrownToReplyComment',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 30),
        ),
      );
      HttpsCallableResult response = await callable.call(payload.toReplyJson());
      debugPrint("this is respose ${response.data["status"]}");
      if (response.data["status"] == true) {
        return true;
      } else {
        _logger.print(response.data["message"]);
        if (response.data["statusCode"].toString() == "501") {
          await CrownsController.to.checkUpdatedCrownsInDb();
          Methods.showCrownsTotalModalSheet(ctx: Get.context);
        }
        return false;
      }
    } on FirebaseFunctionsException catch (ex) {
      _logger.print("Inside Catch Statement ${ex.details} ${ex.code}");
      return false;
    } catch (e) {
      _logger.print("catch Error crownOnCommentReply(): $e");
    }
    return false;
  }
}
