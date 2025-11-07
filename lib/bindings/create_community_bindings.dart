import 'package:get/get.dart';

import '../view/community/create_community/controllers/community_questionnaire_controller.dart';
import '../view/community/create_community/controllers/create_community_controller.dart';

class CreateCommunityBindings extends Bindings {
  @override
  dependencies() {
    Get.lazyPut(() => CreateCommunityController(), fenix: true);
    Get.lazyPut(() => QuestionnaireController(), fenix: true);
  }
}
