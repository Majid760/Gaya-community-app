const utils = require("../../utils/methods.js");
const notificationHelper = require("./notification_utils.js");
const userServices = require("../../core/firestore/common/user_services.js");
/**
 * Send a Notification to individual person by FCM token
 * @param {string} fcm - FCM token of the user
 * @param {Object} payload - Contains Data notification and notification.
 */
const sendIndividualByFCM = async (fcm, payload) => {
  /// sending notification only if token is not empty
  if (fcm) {
    const response = await notificationHelper.sendToPayload(payload, fcm);
    if (response) {
      //log notification
      notificationHelper.logSendingNotification(payload, fcm);
    } else {
      //log error
      notificationHelper.logErrorNotification(payload, fcm);
    }
    return response;
  }
  notificationHelper.logEmptyToken(payload, fcm);
  /// if token is empty, return false
  return false;
};
/**
 * Send a Notification to individual person by passing UserId
 * @param {string} uid - uid of the user
 * @param {Object} payload - Contains Data notification and notification.
 */
const sendIndividualByUid = async (uid, payload) => {
  const fcm = await userServices.getUserFcmById(uid);
  /// sending notification only if token is not empty
  if (fcm) {
    payload.payload = JSON.stringify(payload.payload);
    const response = await notificationHelper.sendToPayload(fcm, payload);
    if (response) {
      //log notification
      notificationHelper.logSendingNotification(uid, payload);
    } else {
      //log error
      notificationHelper.logErrorNotification(uid, payload);
    }
    /// return response - true or false | case where we have the FCM token
    return response;
  }

  notificationHelper.logEmptyToken(uid, payload);
  /// if token is empty, return false
  return false;
};

/**
 * Send Bulk notification to users in chunks of 500 tokens,
 * Automatically splits the tokens into chunks of 500 and sends notification to each chunk
 * @param {Array} tokens - array of tokens
 * @param {String} title - title of notification
 * @param {String} body - body of notification
 * */
const sendBulkNotification = async (tokens, title, body) => {
  if (tokens.length == 0) return false;
  let userTokenChunks = [];
  /// if tokens are more than 500, slice them to send to first 500 only
  /// this is because firebase only allows 500 tokens at a time so we are splitting them
  if (tokens.length > 500) {
    userTokenChunks = utils.chunkArray(tokens, 499);
    /// send notification to each chunk
    userTokenChunks.forEach(async (tokens) => {
      notificationHelper.sendBulkNotification(tokens, title, body);
    });
  } else {
    /// send notification to tokens, no need to split
    notificationHelper.sendBulkNotification(tokens, title, body);
  }
};

/**
 * Send Bulk notification to users in chunks of 500 tokens,
 * Automatically splits the tokens into chunks of 500 and sends notification to each chunk
 * @param {Array} tokens - array of tokens
 * @param {String} title - title of notification
 * @param {String} body - body of notification
 * @param {String} payload - data for notification
 * */
const sendBulkNotificationWithPayload = async (
  tokens,
  title,
  body,
  payload
) => {
  if (tokens.length == 0) return false;

  let userTokenChunks = [];
  /// if tokens are more than 500, slice them to send to first 500 only
  /// this is because firebase only allows 500 tokens at a time so we are splitting them
  if (tokens.length > 500) {
    userTokenChunks = utils.chunkArray(tokens, 499);
    /// send notification to each chunk
    userTokenChunks.forEach(async (tokens) => {
      notificationHelper.sendBulkNotificationWithPayload(
        tokens,
        title,
        body,
        payload
      );
    });
  } else {
    /// send notification to tokens, no need to split
    notificationHelper.sendBulkNotificationWithPayload(
      tokens,
      title,
      body,
      payload
    );
  }
};

/**
 * Send Bulk notification to users in chunks of 500 tokens,
 * Automatically splits the tokens into chunks of 500 and sends notification to each chunk
 * @param {Array} tokens - array of tokens
 * @param {String} title - title of notification
 * @param {String} body - body of notification
 * */
const sendBulkNotificationWithoutPayload = async (tokens, title, body) => {
  if (tokens.length == 0) return false;

  let userTokenChunks = [];
  /// if tokens are more than 500, slice them to send to first 500 only
  /// this is because firebase only allows 500 tokens at a time so we are splitting them
  if (tokens.length > 500) {
    userTokenChunks = utils.chunkArray(tokens, 499);
    /// send notification to each chunk
    userTokenChunks.forEach(async (tokens) => {
      notificationHelper.sendBulkNotificationWithoutPayload(
        tokens,
        title,
        body
      );
    });
  } else {
    /// send notification to tokens, no need to split
    notificationHelper.sendBulkNotificationWithoutPayload(tokens, title, body);
  }
};

module.exports = {
  sendIndividualByFCM,
  sendIndividualByUid,
  sendBulkNotification,
  sendBulkNotificationWithPayload,
  sendBulkNotificationWithoutPayload,
};
