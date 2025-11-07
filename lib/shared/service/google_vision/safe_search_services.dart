import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../controller/firebase_analytics_controller.dart';
import '../../../utils/logger.dart';

class SafeServicesSearch {
  static Future<bool> isImageViolent(File file) async {
    bool isViolent = false;
    try {
      String base64Image = SafeServicesUtils.getBase64Image(file);
      final requestBody = jsonEncode({
        'requests': [
          {
            'image': {'content': base64Image},
            'features': [
              {'type': 'SAFE_SEARCH_DETECTION'}
            ]
          }
        ]
      });
      final response = await http.post(
        Uri.parse(SafeServicesUtils.requestUrl),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      MyLoggerServices.to.print("response.statusCode ${response.body}");
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final safeSearchAnnotation = responseBody['responses'][0]['safeSearchAnnotation'];
        String violence = safeSearchAnnotation['violence'];

        if (violence == "LIKELY" || violence == "VERY_LIKELY") {
          isViolent = true;
        }
      }
      return isViolent;
    } catch (_, s) {
      isViolent = false;
      MyLoggerServices.to.print("Error in checking image violence _ $_");
      CrashlyticsController.to.instance.recordError(_, stackTrace: s, reason: "Error in checking image violence");
    }
    return isViolent;
  }
}

class SafeServicesUtils {
  // String android = 'AIzaSyCtutjc0kaQyPjuu1wu_r5xB0l6GCUI4MU';
  // String iOS = 'AIzaSyCvy9tBf6nSivwAUQTe3xYcbv7uzkVjVUM';
  static const _baseUrl = "https://vision.googleapis.com/v1/";
  static const _apiKey = "AIzaSyCtutjc0kaQyPjuu1wu_r5xB0l6GCUI4MU";
  static const requestUrl = "${_baseUrl}images:annotate?key=$_apiKey";

  static getBase64Image(File file) {
    List<int> imageBytes = file.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);
    return base64Image;
  }
}
