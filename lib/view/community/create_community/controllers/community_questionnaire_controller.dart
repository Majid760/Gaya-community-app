import 'package:flutter/material.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/utils/vallidation.dart';
import 'package:gaya/view/community/create_community/services/community_questionnaire_services.dart';
import 'package:get/get.dart';

import '../../../../components/snackbar.component.dart';
import '../../../../components/textfield.component.dart';
import '../../../../model/community.model.dart';
import '../../../../utils/const.dart';
import '../../../../utils/language/translation.dart';
import '../../controllers/base_controller.dart';

class QuestionnaireController extends BaseController {
  QuestionnaireController({this.communityId}) {}
  @override
  onInit() async {
    super.onInit();
    if (communityId != null) {
      await getQuestionnaire(communityId: communityId);
    }
  }

  /// If communityId is not null, that means we will need to call INIT otherwise no need to call INIT
  String? communityId;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final validation = FormValidation();
  static QuestionnaireController get to => Get.find<QuestionnaireController>();

  static bool get isRegistered => Get.isRegistered<QuestionnaireController>();
  final questionnaireServices = QuestionnaireServices();
  UserModel userModel = UserModel.to;
  List<Questionnaire> questionnaire = [];

  ///questionnaire widget list
  List<Widget> questionWidgets = [];
  final answerController = TextEditingController();

  ///questionnaire fields controller list
  List<TextEditingController> questionControllers = [];

  ///answer fields controller list
  List<TextEditingController> answerControllers = [];
  Map<dynamic, dynamic> questionAnswerMap = {};

  /// Is Async In Process
  bool isInProcess = false;

  ///Add questionnaire widget on add new question
  void addQuestionWidget() {
    TextEditingController controller = TextEditingController();
    questionControllers.add(controller);

    questionWidgets.add(textField(
        inputType: TextInputType.text,
        hintText: GayaStrings.question_hint.tr,
        validation: validation.fieldNotEmptyValidator,
        controller: controller,
        borderColor: borderColor));
    update();
  }

  bool _isButtonLoading = false;

  bool get isButtonLoading => _isButtonLoading;

  void setButtonLoading(bool value, {bool notify = true}) {
    _isButtonLoading = value;
    if (notify) update();
  }

  @override
  void dispose() {
    for (var controller in questionControllers) {
      controller.dispose();
    }
    for (var controller in answerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  ///get questions from controller and add to list
  Future addQuestionsToList(BuildContext context) async {
    questionnaire = [];
    for (var element in questionControllers) {
      if (element.text.isNotEmpty) {
        questionnaire.insert(0, Questionnaire(question: element.text));
        update();
      } else {
        snackBar(context, GayaStrings.question_alert.tr, kRedColor);
      }
    }
  }

  /// reset questionnaire list
  void resetQuestionList() {
    questionWidgets = [];
    update();
  }

  bool get isQuestionnaireEmpty => questionnaire.isEmpty;

  List<Questionnaire> get getQuestionnaireList => questionnaire;

  ///add questionnaire to database
  Future<void> addQuestionnaire({required communityId}) async {
    await questionnaireServices.addQuestionnaire(questionnaires: questionnaire, communityId: communityId);
  }

  Future getQuestionnaire({required communityId}) async {
    setLoading(true);
    try {
      questionnaire = [];
      final data = await questionnaireServices.getQuestionnaires(communityId: communityId);
      if (data != null) {
        final questionSnap = await data.get();
        for (var element in questionSnap.docs) {
          questionnaire.add(Questionnaire.fromMap(element.data()!));
          answerControllers = List.generate(questionnaire.length, (i) => TextEditingController());
          update();
        }
      }
    } catch (_) {
      print('error in get questionnaire');
    } finally {
      setLoading(false);
    }
  }

  Future<bool> sendQuestionnaire(BuildContext context, String communityId) async {
    isInProcess = true;
    bool isSuccess = false;
    setButtonLoading(true, notify: true);
    for (int ans = 0; ans < answerControllers.length; ans++) {
      if (answerControllers[ans].text.isNotEmpty) {
        questionAnswerMap.addAll({questionnaire[ans].question: answerControllers[ans].text});
      } else {
        snackBar(context, GayaStrings.answer_alert.tr, kRedColor);
      }
    }
    if (questionAnswerMap.length == questionnaire.length) {
      isSuccess = true;
      await questionnaireServices.addAnswers(communityId: communityId, userId: userModel.uId ?? '', answer: questionAnswerMap);
    }
    isInProcess = false;
    setButtonLoading(false, notify: true);

    return isSuccess;
  }

  void clear() {
    questionnaire.clear();
  }
}
