import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/contact_us.dart';

abstract class ContactUsImplement {
  Future<void> letsTalk({required ContactUs contactUsModel});

  Future<void> reportAProblem({required ContactUs contactUsModel});
}

class ContactUsServices implements ContactUsImplement {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> letsTalk({required ContactUs contactUsModel}) async {
    _firestore.collection("contactUs").add({
      ...contactUsModel.toJson(),
      "type": "contactUs",
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> reportAProblem({required ContactUs contactUsModel}) async {
    _firestore.collection("contactUs").add({
      ...contactUsModel.toJson(),
      "type": "reportAProblem",
      "createdAt": FieldValue.serverTimestamp(),
    });
  }
}
