import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:gaya/components/snackbar.component.dart';
import 'package:gaya/model/topic.model.dart';
import 'package:gaya/services/topic_services.dart/topicService.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/local.storage.dart';
import 'package:gaya/utils/logger.dart';
import 'package:gaya/view/community/controllers/base_controller.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';

class InterestController extends BaseController {
  late List<TopicsModel> interests;

  late TextEditingController textController;

  final int minimumInterest = 5;
  List<TopicsModel> selectedInterests = [];
  final GetInterestStorageController getStorage = Get.find<GetInterestStorageController>();

  @override
  onInit() {
    super.onInit();
    interests = TopicsUtils.getTopicsList();
    textController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    selectedInterests = [];
    interests = [];
    textController.dispose();
  }

  // search the interest
  List<TopicsModel> filteredList = [];
  final Debouncer _debouncer = Debouncer(delay: const Duration(milliseconds: 500));
  final TopicServices _topicServices = TopicServices();

  void searchInterest(String query) {
    try {
      _debouncer.call(() {
        filteredList = [];
        if (interests.isEmpty) return;
        final suggestion = interests.where((element) {
          final interest = element.title.toLowerCase();
          return interest.contains(query.toLowerCase()) ?? false;
        }).toList();
        filteredList = suggestion;
        update();
      });
    } catch (_) {
      MyLoggerServices.to.print('error caught during getting interests');
    }
  }

  // add interests
  void addInterest(TopicsModel item) {
    try {
      if (selectedInterests.contains(item)) {
        selectedInterests.remove(item);
      } else {
        selectedInterests.add(item);
      }
      update();
      MyLoggerServices.to.print('length is :${selectedInterests.length}');
    } catch (_) {
      MyLoggerServices.to.print('error caught during getting interests');
    }
  }

  /// Save the selected interests into local storage
  void saveToLocalStorage() {
    try {
      if (getStorage.getInterestList()?.isEmpty ?? true) {
        List items = selectedInterests.map((e) => e.toMap()).toList();
        getStorage.storeInterestList(recentInterests: items);
      }
    } catch (_) {
      MyLoggerServices.to.print('error caught during getting interests');
    }
  }

  List<TopicsModel> get getSelectedInterests => getStorage.getSavedInterestList();

  // update the user interests

  Future<void> updateInterest({required BuildContext context, required List<Map<String, dynamic>> intrests}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await _topicServices.saveUserIntrests(intrests: intrests, userId: user.uid);
      // selectedInterests.clear();
      update();
    } catch (e) {
      MyLoggerServices.to.print('error caught during updation of  intrest =>${e.toString()}');
      snackBar(context, GayaStrings.unable_update_user_interest.tr, kRedColor);
    }
  }
}
