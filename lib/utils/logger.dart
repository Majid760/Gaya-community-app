import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class MyLoggerServices extends GetxService {
  static MyLoggerServices get to => Get.find();

  void print(msg) {
    kDebugMode ? log('$msg', name: 'GAYA_DEBUG', level: 1000) : null;
  }

  void printError(msg, {String? info}) {
    kDebugMode ? log('INFO: $info => $msg', name: 'GAYA_ERROR') : null;
  }
}
