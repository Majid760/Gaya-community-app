const admin = require("firebase-admin");
const fcm = require("./fcm_services.js");
const firestore = require("./firestore_notification.js");
const stringGenerator = require("../../utils/string_generator.js");
const utils = require("../../utils/methods.js");
const db = admin.firestore();
const userServices = require("./../firestore/common/user_services.js");
const fcmServices = require("./../notifications/fcm_services.js");

///////////////////////////////////////////////////////////////////////////
///////////////////////// User Related Notification /////////////////////////
///////////////////////////////////////////////////////////////////////////

/**
 * Send Compliment Notification to a user
 * @param {string} senderUid -  The user ID of the sender - [Currently not used]
 * @param {string} receiverUid - The user ID of the receiver
 * @param {string} complimentType - The type of the compliment
 * @param {Object} metadata - The metadata of the compliment
 */
const sendComplimentNotificationToUser = async (
  senderUid,
  receiverUid,
  complimentType,
  metadata
) => {
  const TITLE = "קיבלת מחמאה חדשה!";
  const BODY = stringGenerator.getComplimentStringFromType(complimentType);

  /// payload for firestore
  const firestorePayload = {
    sender_name: TITLE,
    /// adding ** to the compliment ** like this.
    message: utils.addAsteriskToWord(BODY, complimentType),
    type: "compliment", /// Type of notification
    receiverUserID: receiverUid,
    time: metadata.time,
    /// Thumbs UP image for compliment
    userImage:
      "https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/assets%2Fcompliment.png?alt=media&token=13bc4df0-ed0f-47aa-be17-617906a40112",
  };

  /// payload for FCM - No need to send Data Notification as we dont want to navigate to any screen on click
  const fcmPayload = { title: TITLE, body: BODY };

  /// Sending + Adding notification simultaneously
  const firestorePromise = firestore.addNotification(firestorePayload);
  const fcmPromise = fcm.sendIndividualByUid(receiverUid, fcmPayload);

  await Promise.all([firestorePromise, fcmPromise]);

  return true;
};

/**
 * Send Profile Watch (Profile Visit) Notification to a user
 * @param {string} userWhoViewedProfileId -  The user Id who viewed other person profile
 * @param {string} userWhoseProfileViewedId - The user Id whose profile has been viewed
 * @param {Object} metadata - The metadata of the profile visit
 */
const sendProfileWatchNotificationToUser = async (
  userWhoViewedProfileId,
  userWhoseProfileViewedId,
  metadata
) => {
  const TITLE = "משתמש אנונימי צפה בפרופיל שלך";

  /// payload for firestore
  const firestorePayload = {
    sender_name: "",
    message: TITLE,
    type: "watches", /// Type of notification
    receiverUserID: userWhoseProfileViewedId,
    sender_user_id: userWhoViewedProfileId,
    time: metadata.time,
    userImage:
      "https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/assets%2Fwatches_2.png?alt=media&token=e80a6d7c-8805-4ec4-9b2c-c2a49046d9c2&_gl=1*vv95nr*_ga*ODA0NjA2MjQ0LjE2ODM1MzI3ODY.*_ga_CW55HF8NVT*MTY4NjAyNTc4Ni40Ny4xLjE2ODYwMjk1MTkuMC4wLjA.",
  };

  /// payload for FCM - No need to send Data Notification as we dont want to navigate to any screen on click
  const fcmPayload = { title: TITLE, body: "" };

  /// Sending + Adding notification simultaneously
  const firestorePromise = firestore.addNotification(firestorePayload);
  const fcmPromise = fcm.sendIndividualByUid(
    userWhoseProfileViewedId,
    fcmPayload
  );

  await Promise.all([firestorePromise, fcmPromise]);

  return true;
};

///////////////////////////////////////////////////////////////////////////
///////////////////////// Post Related Notifications //////////////////////
///////////////////////////////////////////////////////////////////////////
/**
 * Send Like Notification to a user
 * @param {string} senderUid -  The user ID of the sender
 * @param {string} receiverUid - The user ID of the receiver
 * @param {string} postId - The post ID of the post
 * @param {Object} metadata - The metadata of the like - {communityId, photoURL}
 */
const sendLikeNotificationToUser = async (senderUid, receiverUid, metadata) => {
  console.log("sendLikeNotificationToUser: ", metadata);
  const TITLE = metadata.name + "אהב את הפוסט שלך."; // dash liked your post.
  const BODY = "הפוסט שלך נלייק! בדוק את זה"; // Your post was liked! Check it out

  /// payload for firestore
  const firestorePayload = {
    sender_name: TITLE,
    message: BODY,
    sender_user_id: senderUid,
    userImage: metadata.photoURL,
    receiverUserID: receiverUid,
    time: metadata.time,
    type: "postLiked",
    postId: metadata.postId,
    communityId: metadata.communityId,
    metadata: {
      generatedBy: "server",
    },
  };

  /// payload for FCM
  const fcmPayload = {
    click_action: "FLUTTER_NOTIFICATION_CLICK",
    sound: "default",
    body: BODY,
    title: TITLE,

    priority: "high",
    payload: {
      postId: metadata.postId,
      communtiyId: metadata.communityId,
      messageType: "post",
    },
  };

  /// Sending + Adding notification simultaneously
  const firestorePromise = firestore.addNotification(firestorePayload);
  const fcmPromise = fcm.sendIndividualByUid(receiverUid, fcmPayload);

  await Promise.all([firestorePromise, fcmPromise]);

  return true;
};

/**
 * Send Like Notification to a user
 * @param {string} senderUid -  The user ID of the sender
 * @param {string} receiverUid - The user ID of the receiver
 * @param {string} postId - The post ID of the post
 * @param {Object} metadata - The metadata of the like - {communityId, photoURL, comment, etc}
 */
const sendCommentNotificationToUser = async (
  senderUid,
  receiverUid,
  metadata
) => {
  console.log("sendLikeNotificationToUser: ", metadata);
  const TITLE = metadata.name; // commentAuthorName - maker of the comment
  const BODY = "יש לך תגובה חדשה" + " " + metadata.comment; // new comment + $comment

  /// payload for firestore
  const firestorePayload = {
    sender_name: TITLE,
    message: BODY,
    sender_user_id: senderUid,
    userImage: metadata.photoURL,
    receiverUserID: receiverUid,
    time: metadata.time,
    type: "postCommented",
    postId: metadata.postId,
    communityId: metadata.communityId,
    metadata: {
      generatedBy: "server",
    },
  };

  /// payload for FCM
  const fcmPayload = {
    click_action: "FLUTTER_NOTIFICATION_CLICK",
    sound: "default",
    body: BODY,
    title: TITLE,
    priority: "high",
    payload: {
      postId: metadata.postId,
      communtiyId: metadata.communityId,
      messageType: "post",
    },
  };

  /// Sending + Adding notification simultaneously
  const firestorePromise = firestore.addNotification(firestorePayload);
  const fcmPromise = fcm.sendIndividualByUid(receiverUid, fcmPayload);

  await Promise.all([firestorePromise, fcmPromise]);

  return true;
};

/**
 * Send Crown Notification to a user
 * @param {string} senderUid -  The user ID of the sender
 * @param {string} receiverUid - The user ID of the receiver - the one who got crowned
 * @param {Object} metadata - The metadata of the crown - {communityId, photoURL}
 */
const sendCrownNotificationToUser = async (
  senderUid,
  receiverUid,
  metadata
) => {
  console.log("sendLikeNotificationToUser: ", metadata);
  const TITLE = "כתר חדש"; // newcrown.
  const BODY = metadata.name + " מעניק כתר לפוסט שלך."; // ${myAppUser.name} ${GayaStrings.crowned_post.tr}

  /// payload for firestore
  const firestorePayload = {
    sender_name: TITLE,
    message: BODY,
    sender_user_id: senderUid,
    userImage: metadata.photoURL,
    receiverUserID: receiverUid,
    time: metadata.time,
    type: "postCrowned",
    postId: metadata.postId,
    communityId: metadata.communityId,
    metadata: {
      generatedBy: "server",
    },
  };

  /// payload for FCM
  const fcmPayload = {
    click_action: "FLUTTER_NOTIFICATION_CLICK",
    sound: "default",
    body: BODY,
    title: TITLE,
    priority: "high",
    payload: {
      postId: metadata.postId,
      communtiyId: metadata.communityId,
      messageType: "post",
    },
  };

  /// Sending + Adding notification simultaneously
  const firestorePromise = firestore.addNotification(firestorePayload);
  const fcmPromise = fcm.sendIndividualByUid(receiverUid, fcmPayload);

  await Promise.all([firestorePromise, fcmPromise]);

  return true;
};

/**
 * Invoke function to send local and push notification to users
 * @param {Object} notificationObjectData Object containing data for notification
 * @param {string[]} usersIds List of users ids to send notification
 * @returns Object containing result
 */
async function sendPushOrLocalNotificationsToUsers(
  notificationObjectData,
  usersIds
) {
  // Notification object
  const notificationObject = {
    sender_name: notificationObjectData.title,
    message: notificationObjectData.body,
    time: notificationObjectData.time,
    type: notificationObjectData.type,
    isRead: false,
    receiverUserID: "",
    userImage: notificationObjectData.profilePicture,
    subImage: notificationObjectData.subImage,
  };

  // split users into chunks of 500
  // 500 = for notification add batch write limit
  const usersIdsLists = utils.chunkArray(usersIds, 499);
  for (const usersIdsList of usersIdsLists) {
    // loop through chunks in batch write
    const batch = db.batch();

    for (const userId of usersIdsList) {
      try {
        // Set receiverUserID in notification object
        notificationObject.receiverUserID = userId;

        // Checking whether to send only push notification
        if (!notificationObjectData.onlyPushNotification) {
          /* ------------------------ ADDING LOCAL NOTIFICATION ----------------------- */
          batch.set(
            db
              .collection("users")
              .doc(userId)
              .collection("notifications")
              .doc(),
            notificationObject
          );
        }
      } catch (e) {
        console.log("Error occurred while adding local notifications", e);
      }
    }
    // Checking whether to send only push notification
    if (!notificationObjectData.onlyPushNotification) {
      await batch.commit();
    }

    /* ----------------------- SENDING PUSH NOTIFICATIONS ----------------------- */
    // Getting all users tokens
    const tokens = await userServices.getMultipleUsersTokens(usersIdsList);
    if (notificationObjectData.type == "community") {
      // send bulk notification to all users in chunks
      await fcmServices.sendBulkNotificationWithPayload(
        tokens,
        notificationObject.sender_name,
        notificationObject.message,
        notificationObjectData.payload
      );
    } else {
      // send bulk notification to all users in chunks
      await fcmServices.sendBulkNotificationWithoutPayload(
        tokens,
        notificationObject.sender_name,
        notificationObject.message
      );
    }
  }

  return {
    statusCode: 200,
    status: true,
    message: "Notifications sent successfully.",
  };
}

module.exports = {
  sendComplimentNotificationToUser,
  sendProfileWatchNotificationToUser,
  sendLikeNotificationToUser,
  sendCommentNotificationToUser,
  sendCrownNotificationToUser,
  sendPushOrLocalNotificationsToUsers,
};
