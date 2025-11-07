import 'package:gaya/controller/app_config_controller.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/services/services.dart';
import 'package:gaya/utils/logger.dart';
import 'package:get/get.dart';

class CrownsController extends GetxController {
  static CrownsController get to => Get.find();
  UserModel get myAppUser => UserModel.to;

  final Services _commonService = Services();
  AppConfigurationController config = AppConfigurationController.to;

  updateCurrentUser() {
    MyLoggerServices.to.print('updated user is: ${UserModel.to}');
    update();
  }

  Future<void> checkUpdatedCrownsInDb() async {
    MyLoggerServices.to.print('checking updated crowns.');
    if (myAppUser.uId == null) return;
    final user = await _commonService.getUserById(myAppUser.uId, forcefullyServer: true);
    MyLoggerServices.to.print('updated user is: ${user?.userDailyCrowns}');
    if (user == null) return;
    UserModel.to.update(user);
    update();
  }

  getCrownServerTimeStamp() async {
    update();
    return;
    // await config.getCrownServerTimeStamp();
    // if (config.serverDateTime != null) {
    //   config.getCrownRemainingTimeDuration();
    // }
    // update();
  }
}
