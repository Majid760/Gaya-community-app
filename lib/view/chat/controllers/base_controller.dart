
import 'package:get/get.dart';


class BaseController extends GetxController {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void setLoading(bool value, {bool notify = true}) {
    _isLoading = value;
   if(notify) update();
  }
}
