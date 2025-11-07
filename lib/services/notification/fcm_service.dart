import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gaya/services/notification/cc_notif_manager.dart';
import 'package:gaya/utils/logger.dart';

import 'local_notif_services.dart';

//This provided handler must be a top-level function.
//It works outside the scope of the app in its own isolate.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('Handling a background message ${message.messageId}');
}

class FirebaseMessagingService {
  FirebaseMessagingService._();

  static FirebaseMessagingService? _instance;

  static FirebaseMessagingService get instance {
    _instance ??= FirebaseMessagingService._();
    return _instance!;
  }

  static FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  bool isPermissionGranted = false;

  Future init() async {
    if (flutterLocalNotificationsPlugin != null) return;
    MyLoggerServices.to.print('FirebaseMessagingService init');
    //On iOS, macOS & web, before FCM payloads can be received on your device
    //you must first ask the user's permission.
    //Android applications are not required to request permission.
    NotificationSettings settings = await firebaseMessaging.requestPermission(
      alert: false,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: true,
      sound: true,
    );
    log('User granted permission: ${settings.authorizationStatus}');

    /// if user denied permission then return
    if (settings.authorizationStatus != AuthorizationStatus.authorized) return;

    /// if user granted permission then set isPermissionGranted to true
    isPermissionGranted = true;

    /// init local notification
    await LocalNotificationService.instance.init();

    flutterLocalNotificationsPlugin = LocalNotificationService.instance.flutterLocalNotificationsPlugin;

    // Update the iOS foreground notification presentation options to allow
    // heads up notifications on Apple devices.
    showIosAlerts();

    /// generates and send fcm token to server
    generateFcmToken();
    //Set a message handler function which is called when the app is in the background or terminated.
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static showNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    final _messageData = message.data;
    if (notification != null && !kIsWeb) {
      LocalNotificationService.instance.showInstantNotification(
        title: notification.title,
        body: notification.body,
        payload: jsonEncode(_messageData),
      );
    }
  }

  Future<void> showIosAlerts() async {
    if (!Platform.isIOS) return;
    await firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      sound: true,
      badge: true,
    );
  }

  Future<void> stopIosAlerts() async {
    if (!Platform.isIOS) return;
    await firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: false, // Required to display a heads up notification
      sound: false,
      badge: false,
    );
  }
}

extension FCMToken on FirebaseMessagingService {
  /// generate and save fcm token if its not already generated (generate only for 1 time)
  Future<void> generateFcmToken() async {
    try {
      var token = await firebaseMessaging.getToken();
      if (token != null) {
        MyLoggerServices.to.print("fcm token: $token");
        _sendFcmTokenToServer(token);
      } else {
        // retry generating token
        await Future.delayed(const Duration(seconds: 5));
        generateFcmToken();
      }
    } catch (error) {
      MyLoggerServices.to.print(error);
    }
  }

  Future<void> clearFcmToken() async {
    try {
      await _clearFcmTokenToServer();
    } catch (error) {
      MyLoggerServices.to.print(error);
    }
  }

  /// this method will be triggered when the app generate fcm
  /// token successfully
  _sendFcmTokenToServer(String token) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (FirebaseAuth.instance.currentUser?.uid != null) {
        FirebaseFirestore.instance.collection('users').doc(user?.uid).set({'fm_token': token}, SetOptions(merge: true));

        /// subscribe to connectyCube notification
        ConnectyCubeNotification.subscribe(token: token);
      }
    } catch (error) {
      MyLoggerServices.to.print(error);
    }
  }

  _clearFcmTokenToServer() async {
    final user = FirebaseAuth.instance.currentUser;
    await firebaseMessaging.deleteToken();
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(user?.uid).set({'fm_token': ''}, SetOptions(merge: true));
    }
  }
}

extension ConnectyCubeNotifications on FirebaseMessagingService {}
