const admin = require("firebase-admin");
const functions = require("firebase-functions");
const communityServices = require("./community_services");
const usersServices = require("./user_services");
const notificationHelper = require("../../notifications/notificationHelper");

/**
 * Invoke function to send broadcast notification via admin
 * @param {Object} req Request object contain request data from client
 * @returns Object with result
 */
async function sendBroadcastNotificationByAdmin(req) {
  /* --------------------------- EXTRACTED VARIABLES -------------------------- */
  const title = req.title; // Title of notification
  const body = req.body; // Body of the notification
  const notificationType = req.type; // The type of notification
  const communityId = req.communityId; // Community id
  const gender = req.gender; // Gender to send notifications (male, female, all)
  const fcmPayload = req.payload; // Payload (data) for FCM
  const onlyPushNotification = req.onlyPushNotification; // Whether to send only push notifications or both (push and local)
  const profilePicture = req.profilePicture; // Profile pic of notification
  const subImage = req.subImage; // Type image (sub image)
  const dateTimeString = new Date().toISOString(); // Time when notification is sending

  /* ---------------------------------- LOGIC --------------------------------- */
  // Object containing notification data
  const notificationObjectData = {
    title: title,
    body: body,
    time: dateTimeString,
    profilePicture: profilePicture,
    subImage: subImage,
    gender: gender,
    type: notificationType,
    onlyPushNotification: onlyPushNotification,
    payload: fcmPayload,
  };

  try {
    if (notificationType == "community") {
      /* --------- SENDING PUSH AND LOCAL NOTIFICATION TO COMMUNITY USERS --------- */
      // Getting all users Ids of community with [communityId]
      const allCommunityMembersIds =
        await communityServices.getCommunitySubscribedMemberIds(communityId);

      // Getting gender specific users ids
      let genderSpecificIds = await usersServices.getGenderSpecificUsersIds(
        gender,
        allCommunityMembersIds
      );

      // send push or local notifications or both
      return await notificationHelper.sendPushOrLocalNotificationsToUsers(
        notificationObjectData,
        genderSpecificIds
      );
    } else {
      /* ------------ SENDING PUSH AND LOCAL NOTIFICATION TO ALL USERS ------------ */
      // Getting all users ids
      const usersIds = await usersServices.getAllGenderSpecificMembersIds(
        gender
      );

      // send push or local notifications or both
      return await notificationHelper.sendPushOrLocalNotificationsToUsers(
        notificationObjectData,
        usersIds
      );
    }
  } catch (error) {
    functions.logger.error(error);
    return { statusCode: 100, status: false, message: JSON.stringify(error) };
  }
}

module.exports = {
  sendBroadcastNotificationByAdmin,
};
