## 2.5.7
* Fixes and improvements:
  - Chat:
    - fixed parsing of messages created via REST API request;

## 2.5.6
* Fixes and improvements:
  - Chat:
    - fixed the `login` method calling if call it a few times without waiting for the result;

## 2.5.5
* Fixes and improvements:
  - Calls:
      - fixed `micLevel` reports for P2P Calls;
  - Chat:
    - fixed the Messaging feature for the multidevice logged user;

## 2.5.4
* Fixes and improvements:
    - update dependencies to latest possible versions;

## 2.5.3
* Fixes and improvements:
    - Calls:
        * fixed local media stream initialisation;

## 2.5.2
* Fixes and improvements:
    - Calls:
        * fixed callback `onSubscriberAttached` of the `ConferenceSession`;

## 2.5.1
* Fixes and improvements:
    - Calls:
      * fixed Conference calls when start call with the **callType: `CallType.AUDIO_CALL`**;
    - Chat:
      * fixed Message Reactions for the multidevice logged user;

## 2.5.0
* New:
    - Calls:
      - Conference Calls:
        * implemented the [Simulcasting](https://developers.connectycube.com/flutter/videocalling-conference?id=simulcasting) feature;
      - added the `requestAudioForScreenSharing` parameter to the `enableScreenSharing` method;
      - added `getAudioInputs()` and `getAudioOutputs()` methods for requesting the lists of the input/output audio devices;
    - Users:
      - implemented the [Guest session](https://developers.connectycube.com/flutter/authentication-and-users?id=create-session-token) feature; 

  
* Broken and deprecated API:
    - the callback `onRemoteStreamReceived` is not available for the `ConferenceSession` anymore, use the `onRemoteStreamTrackReceived` callback instead;
    - the callback-listener `RTCSessionStateCallback` is deprecated in the `ConferenceSession` for now and the callbacks `onSubscribedOnPublisher`, `onSubscriberAttached` and `onPublisherLeft` should be used;
    - the SDK automatically subscribes on active publishers and you shouldn't do it by yourself in the `ConferenceSession`;

## 2.4.2
* Fixes and improvements:
    - [Android] fixed the compatibility with Gradle plugin `v7.3.+`;

## 2.4.1
* Fixes and improvements:
    - fixed Android build issues;

## 2.4.0
* New:
    - Chat:
        - implemented [**Message Reactions**](https://developers.connectycube.com/flutter/messaging?id=message-reactions) feature;

## 2.3.0
* Add Linux support;

* New:
    - Calls:
        - added the `maxBandwidth` configuration to the `RTCMediaConfig` for setting the maximum **bandwidth** during the call initialization;
        - added the method `setMaxBandwidth(int? bandwidth)` for changing the value of **bandwidth** during the call;
  
    - Meetings:
      - added new parameters like:
        - `public` - allows not attendee users to join the meeting;
        - `scheduled` - indicates meeting is scheduled or not;
        - `notify` - send a notification after the meeting is created (available starting from the [Hobby plan](https://connectycube.com/pricing/));
        - `notifyBefore` - timing before the meeting start to send notification (available starting from the [Hobby plan](https://connectycube.com/pricing/));
      - added method `updateMeetingById` for updating only needed [fields](https://developers.connectycube.com/server/meetings?id=parameters-2) in the meeting model;
      - added method `getMeetingsPaged` which allow to get meetings using the pagination;

## 2.2.3
* Fixes and improvements:
    - Chat:
        - improve login flow in some cases;
      
    - Other:
        - update dependencies to the latest possible versions;

## 2.2.2
* Fixes and improvements:
    - Calls:
        - update the `flutter_webrtc` lib to the latest ([0.9.5](https://pub.dev/packages/flutter_webrtc/versions/0.9.5)) version;
        - improvements for `ScreenSelectDialog` widget;
    - Chat:
        - improve restoring the Chat-connection;

## 2.2.1
* New:
    - Calls:
        - Add the Screen sharing feature support for desktop. See our [documentation](https://developers.connectycube.com/flutter/videocalling?id=requesting-desktop-capture-source) on how to request the Capture source and set it as the source of the Screen sharing;

* Fixes and improvements:
    - Calls:
        - update the `flutter_webrtc` lib to the latest ([0.9.1](https://pub.dev/packages/flutter_webrtc/versions/0.9.1)) version;


## 2.2.0
* New:
    - Calls:
        - Implemented the iOS Screen sharing feature using Screen Broadcasting. See our [step-by-step guide](https://developers.connectycube.com/flutter/videocalling?id=ios-screen-sharing-using-the-screen-broadcasting-feature) on how to integrate the Screen Broadcasting feature into your iOS app;
        - Added the API for [rejecting](https://developers.connectycube.com/flutter/videocalling?id=reject-a-call) the P2PSession via HTTP request.
      
* Broken API:
    - Calls:
        - rewritten the method `createCallSession` of `ConferenceClient` for using named parameters.

## 2.1.2
* New:
    - Calls:
        - Implemented [WebRTC Stats reports](https://developers.connectycube.com/flutter/videocalling?id=webrtc-stats-reporting) feature;
        - Added [API for getting the mic level and video bitrate](https://developers.connectycube.com/flutter/videocalling?id=monitoring-mic-level-and-video-bitrate-using-stats);
      
* Fixes and improvements:
    - Calls:
        - update the `flutter_webrtc` lib to the latest ([0.8.12](https://pub.dev/packages/flutter_webrtc/versions/0.8.12)) version;

## 2.1.1
* Fixes and improvements:
    - Other:
        - update the `flutter_webrtc` lib to the latest ([0.8.6](https://pub.dev/packages/flutter_webrtc/versions/0.8.6)) version;


## 2.1.0
* New:
    - Chats:
        - Auto mark messages as 'Delivered' for all `markable` messages 
          (use `CubeSettings.instance.autoMarkDelivered = false` for disabling it);
        - Add methods `sendDeliveredStatus(CubeMessage)` and `sendReadStatus(CubeMessage)` to 
          the `ChatMessagesManager` to mark messages without the `CubeDialog` model;

## 2.0.14
* Fixes and improvements:
    - Calls:
        - fixed the join to a conference as a `ConferenceRole.LISTENER` ([#195](https://github.com/ConnectyCube/connectycube-flutter-samples/issues/195));

## 2.0.13
* Fixes and improvements:
    - Other:
        - update `flutter_webrtc` lib to the latest ([0.8.5](https://pub.dev/packages/flutter_webrtc/versions/0.8.5)) version;

## 2.0.12
* Fixes and improvements:
    - Other:
        - update `flutter_webrtc`, `http`, `uuid` to latest versions;

## 2.0.11
* Fixes and improvements:
    - Calls:
        - fixes and improvements for working on Safari browser;
        - update `flutter_webrtc` lib to the latest ([0.8.2](https://pub.dev/packages/flutter_webrtc/versions/0.8.2)) version;

## 2.0.10
* Fixes and improvements:
    - Calls:
        - fixed opponent's sound on the Web platform during the AUDIO call ([#187](https://github.com/ConnectyCube/connectycube-flutter-samples/issues/187));

## 2.0.9
* Fixes and improvements:
    - Calls:
        - fixes and improvements for the replacing streams feature;

## 2.0.8
* New:
    - Chat:
        - implemented the [Privacy lists](https://developers.connectycube.com/flutter/messaging?id=privacy-black-list) feature;

    - Calls:
        - implemented the [Screen sharing](https://developers.connectycube.com/flutter/videocalling?id=screen-sharing) feature;
        - added method `setTorchEnabled(bool)` for enabling/disabling the torch on the call;
        - added method `replaceMediaStream(MediaStream)` for using own MediaStream on the call;

## 2.0.7
* Fixes and improvements:
    - Users:
        - added method `getUsersByFilter(RequestFilter)` for requesting users using custom filters (see available filters [here](https://developers.connectycube.com/server/users?id=parameters-1));
        - fixed work of the `getAllUsersByIds(Set<int>)` method;
    - Calls:
        - fixed the Archiving iOS builds;

## 2.0.6
* Update dependencies to the latest versions;

## 2.0.5
* New:
    - Added support for the Web platform;
    - Added `uploadRawFile(List<int>, String, {bool?, String?, Function(int progress)?})` method for uploading files from the raw bytes data;
    - Implemented the Active/Inactive feature for the Chat connection;

* Fixes and improvements:
    - Users:
        - deprecated the `int` field `externalId` of `CubeUser` model, use the `String` field `externalUserId` instead;
    - Push notifications:
        - improvements for parsing the `CubeSubscription` model after the subscription creation;

## 2.0.4

* Fixes and improvements:
    - Calls:
        - improved compatibility with JS SDK (some browsers send wrong Ice Candidates and it broke the Flutter SDK);
    - Other:
        - dependencies were updated to the latest versions;

## 2.0.3

* New:
    - Added desktop support (macOS and Windows);

* Fixes and improvements:
    - Push notifications:
        - fixed parsing of the response of event creation;
    - Other:
        - dependencies were updated to the latest versions;

## 2.0.2

* Fixes and improvements:
    - Storage:
        - added new parameter `mimeType` to method `uploadFile(...)` for manual setting the content type for the file which you upload (it will be helpful if SDK can not get the content type from the extension);

## 2.0.1

* Fixes and improvements;

## 2.0.0

* New:
    - Implemented Dart [null-safety](https://dart.dev/null-safety) feature;
    - Implemented Meetings API ([create](https://developers.connectycube.com/flutter/videocalling-conference?id=create-meeting), [get](https://developers.connectycube.com/flutter/videocalling-conference?id=retrieve-meetings), [update](https://developers.connectycube.com/flutter/videocalling-conference?id=edit-meeting), [delete](https://developers.connectycube.com/flutter/videocalling-conference?id=delete-meeting));
    - Implemented [Whiteboard](https://developers.connectycube.com/flutter/whiteboard?id=whiteboard) feature;
    - Iimplemented [editing](https://developers.connectycube.com/flutter/messaging?id=via-chat-connection) and [deleting](https://developers.connectycube.com/flutter/messaging?id=via-chat-connection-1) messages via Chat connection;

* Fixes and improvements:
    - Calls:
        - fixed work of the `onCallAcceptedByUser` callback for P2P calls;
        - fixed rejoin to a Conference call;

    - Chat:
        - fixed sending group chat messages (were issues in some cases);
        - fixed the compatibility with JS SDK;

    - Core:
        - disabled XMPP stanzas logging if `CubeSettings.instance.isDebugEnabled = false`;

    - Other:
        - dependencies were updated to the latest versions;
        - minor adaptations for updated Server API;

## 1.1.3

* Calls:
    - improvements for the getting `localMediaStrem` (there were problems on some devices);

* Chat:
    - fixed login to the chat with the same user but with different passwords;
	- improved sending asynchronous packages (group messages, join group, leave group, get last user activity);
	- disabled join to the group chat by default before sending group message. Now it is not required on the shared server. But if your server requires it, you can enable join via `CubeSettings.instance.isJoinEnabled = true`;

## 1.1.2

* Bugfix

## 1.1.1

* Improvements for background calls;
* Improved parsing of `CubeSubscription` model;
* Fixed conflicts when connecting some dependencies;

## 1.1.0

* New API:
    - added new function `uploadFileWithProgress(File, {bool, Function(int)}` which provides possibility for listening progress of file uploading process;
    - added field `addressBookName` to `CubeUser` model (this field is received on request `getRegisteredUsersFromAddressBook(bool, [String])` in **compact** mode);

* Fixed:
    - receiving same call after it rejection (in some cases);
    - chat reconnection feature;
    - serialization/deserialization for `CubeSession` and `CubeUser` models;

* Improvements:
    - improved data exchange for some signaling messages during P2P calls;
    - update [flutter_webrtc](https://pub.dev/packages/flutter_webrtc) to version 0.5.7;

## 1.0.0

Stable release.

* Added automatic session restoring logic ([details](https://developers.connectycube.com/flutter/authentication-and-users?id=session-expiration));
* Updated all dependencies to actual versions;

## 0.6.0

* Implemented API for [Custom objects](https://developers.connectycube.com/server/custom_objects)

## 0.5.1

* Fixed saving token's expiration date after the session creation.

* Deprecated API:
    - method `saveActiveSession(CubeSession session)` from `CubeSessionManager` - now used just setter for `activeSession` field;
    - method `getActiveSession()` from `CubeSessionManager` - now used just getter for `activeSession` field;

## 0.5.0

* Update dependencies to latest versions;

* Removed API:
    - removed paremeter `objectFit` from `RTCVideoRenderer`;
    - removed paremeter `mirror` from `RTCVideoRenderer`;
* Added API:
    - added paremeter `objectFit` to `RTCVideoView` constructor;
    - added paremeter `mirror` to `RTCVideoView` constructor;

## 0.4.2

* Fixed group chatting after relogin with different users;

## 0.4.1

* Fixed work of chat managers after relogin with different users;
* Fixed receiving calls after relogin with different users;

## 0.4.0

* Added Chat [connection state listener](https://developers.connectycube.com/flutter/messaging?id=connect-to-chat);
* Added Chat [reconnection](https://developers.connectycube.com/flutter/messaging?id=reconnection) functionality;
* Fixed relogin to the Chat;
* Fixed Sign Up users with tags;
* Fixed parsing Attachments during realtime communication;

## 0.3.0-beta1

* Implemented Conference Calls ([documentation](https://developers.connectycube.com/flutter/videocalling-conference), [code sample](https://github.com/ConnectyCube/connectycube-flutter-samples/tree/master/conf_call_sample));

## 0.2.0-beta3

* Improvements for crossplatform calls;

## 0.2.0-beta2

* Fixed 'Accept call' issue when call from Web;

## 0.2.0-beta1

* Implemented P2P Calls ([documentation](https://developers.connectycube.com/flutter/videocalling), [code sample](https://github.com/ConnectyCube/connectycube-flutter-samples/tree/master/p2p_call_sample));
* Improvements for CubeChatConnection;

## 0.1.0-beta5

* Update documentation link

## 0.1.0-beta4

This is a 1st public release.

The following features are covered:

* Authentication and Users;
* Messaging;
* Address Book;
* Push Notifications.

## 0.1.0-beta3

* Add minimal examples.

## 0.1.0-beta2

* Updates by pub.dev recommendations.

## 0.1.0-beta1

* Initial release.
