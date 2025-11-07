import 'package:firebase_core/firebase_core.dart';

class SharedString {
  SharedString._();

  static const String cancel = "Cancel";
  static const String continuee = "Continue";
  static const String enablePermission = "Enable Permission!";
  static const String cameraPermissionMsg = "Allow the Camera to take photos on you devices";
  static const String galleryPermissionMsg = "Allow the Permissions to access photos,media, and files on your devices";
  static const String postHasBeenRemovedOrNoPermission = "Post has been removed or you don't have permission to view it";
}

class Env {
  // FCM API Key
  /// debug key
  static const String fcmDebugServerKey =
      "AAAAp3_8N4g:APA91bHLd61dm6sxM--N-PzO4S_YjWGjQHFm6ewzTIvsC2lZTRB-dwEFPd9w3CbYQiiz-l4G4eMmyyIOAierghK0at6SL1mt7m4LiGlvFxk7LgVkvvTtnDwC--34FBzRZY4BkmUfrgy0";

  /// production key
  static const String fcmServerKey =
      "AAAAUjsLo_c:APA91bH-nhaKXnEZJJf8bxHPwSO3LZ8yBDRMUAJt75LhPgNZ29wRalF7hIqvK6PUJ52zH2jDEVt683KKzmr7-7Fw_jMC9E0lDvOtDAj2nZcX0xEkAZjD2A1suQo2cZ2fM6Vy4kzW19Io";

  //Dynamic links
  /// production base url
  // static const String kDynamicLinkBaseUrl = "https://gaya.app";
  static const String kDynamicLinkBaseUrl = "https://gayaapp.page.link";

  /// debug base url
  static const String kDynamicLinkDebugBaseUrl = "https://testgaya.page.link";

  static const String kDynamicLinkEndPoint = "/share";

  static const String kAppStoreId = "1662332476";

  static const String kPrivacyPolicyUrl = "https://gaya.app/privacy-policy.html";
  static const String kTermsAndConditionsUrl = "https://gaya.app/terms-condition.html";

  static FirebaseOptions get firebaseProject => const FirebaseOptions(
      apiKey: "AIzaSyDMUbvC7tODkadWx8k32HT4hPnysjAx80w",
      authDomain: "gaya-5876c.firebaseapp.com",
      databaseURL: "https://gaya-5876c-default-rtdb.europe-west1.firebasedatabase.app",
      projectId: "gaya-5876c",
      storageBucket: "gaya-5876c.appspot.com",
      messagingSenderId: "353177936887",
      appId: "1:353177936887:web:18930368f17435e797c4f2",
      measurementId: "G-GYC29R375X");
}
