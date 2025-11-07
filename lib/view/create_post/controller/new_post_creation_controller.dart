import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class PostWithVibeController extends GetxController{
  static PostWithVibeController get to => Get.find();
  var currentExtent = 0.0.obs;






/// this method is to hide the bottom sheet on create post view page.
  dropSheet(){
    currentExtent.value=60.0;
    update();
  }
}