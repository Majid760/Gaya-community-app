const { getMessaging } = require("firebase-admin/messaging");
const { logger } = require("firebase-functions");
/// private function to send notification to tokens - Bulk notification
const sendBulkNotification = async (tokens, title, body) => {
  try {
    const message = {
      notification: {
        title: title,
        body: body,
      },
      android: {
        notification: { channel_id: "high_importance_channel" },
      },
      apns: {
        payload: {
          aps: { sound: "default" },
        },
      },
      tokens: tokens,
    };
    const response = await getMessaging().sendMulticast(message);
    console.log("Successfully sent message:", response);
    return true;
  } catch (error) {
    console.log("Error sending message:", error);
    return false;
  }
};
/// private function to send notification to tokens with payload - Bulk notification
const sendBulkNotificationWithPayload = async (
  userTokens,
  title,
  body,
  payload
) => {
  try {
    // Remove empty tokens
    userTokens = userTokens.filter((token) => token != "");

    const message = {
      tokens: userTokens,
      notification: {
        title: title,
        body: body,
      },
      data: {
        click_action: "FLUTTER_NOTIFICATION_CLICK",
        sound: "default",
        body: body,
        title: title,
        priority: "high",
        payload: JSON.stringify(payload),
      },
      android: {
        notification: { channel_id: "high_importance_channel" },
      },
      apns: {
        payload: {
          aps: { sound: "default" },
        },
      },
    };
    const response = await getMessaging().sendMulticast(message);
    console.log("Successfully sent message:", response);
    return true;
  } catch (error) {
    console.log("Error sending message:", error);
    return false;
  }
};

/// private function to send notification to tokens with payload - Bulk notification
const sendBulkNotificationWithoutPayload = async (userTokens, title, body) => {
  try {
    // Remove empty tokens
    userTokens = userTokens.filter((token) => token != "");

    const message = {
      tokens: userTokens,
      notification: {
        title: title,
        body: body,
      },
      data: {
        click_action: "FLUTTER_NOTIFICATION_CLICK",
        sound: "default",
        body: body,
        title: title,
        priority: "high",
      },
      android: {
        notification: { channel_id: "high_importance_channel" },
      },
      apns: {
        payload: {
          aps: { sound: "default" },
        },
      },
    };
    const response = await getMessaging().sendMulticast(message);
    console.log("Successfully sent message:", response);
    return true;
  } catch (error) {
    console.log("Error sending message:", error);
    return false;
  }
};

/// sends notification with data payload to token
const sendNotificationData = async (token, title, body, data) => {
  try {
    const message = {
      data: data,
      android: {
        notification: { channel_id: "high_importance_channel" },
      },
      apns: {
        payload: {
          aps: { sound: "default" },
        },
      },
      notification: {
        title: title,
        body: body,
      },
      token: token,
    };
    const response = await getMessaging().send(message);
    console.log("Successfully sent message:", response);
    return true;
  } catch (error) {
    console.log("Error sending message:", error);
    return false;
  }
};
/// sends only notification to token **Doesnt work with data payload**
const sendNotification = async (token, title, body) => {
  try {
    const message = {
      notification: {
        title: title,
        body: body,
      },
      android: {
        notification: { channel_id: "high_importance_channel" },
      },
      apns: {
        payload: {
          aps: { sound: "default" },
        },
      },
      token: token,
    };
    const response = await getMessaging().send(message);
    console.log("Successfully sent message:", response);
    return true;
  } catch (error) {
    console.log("Error sending message:", error);
    return false;
  }
};
const sendToPayload = async (token, payload) => {
  try {
    const message = {
      data: payload,
      android: {
        notification: { channel_id: "high_importance_channel" },
      },
      apns: {
        payload: {
          aps: { sound: "default" },
          content_available: true,
        },
      },
      notification: {
        title: payload.title,
        body: payload.body,
      },
      token: token,
    };
    const response = await getMessaging().send(message);
    console.log("Successfully sent message:", response);
    return true;
  } catch (error) {
    console.log("Error sending message:", error);
    return false;
  }
};

const logSendingNotification = async (uid, payload) => {
  logger.info(
    ":bell::bell: Sending notification to user with uid: " +
      JSON.stringify(uid) +
      " ",
    JSON.stringify(payload)
  );
};
const logErrorNotification = async (uid, payload) => {
  logger.error(
    "🔔❌ Error sending notification to user with uid: " +
      JSON.stringify(uid) +
      "❌❌ ",
    payload
  );
};
const logEmptyToken = async (uid, payload) => {
  logger.error(
    ":bell::neutral_face: Token Empty while sending notification to user with uid: " +
      JSON.stringify(uid) +
      ":neutral_face::neutral_face: ",
    JSON.stringify(payload)
  );
};
module.exports = {
  sendBulkNotification,
  sendNotificationData,
  sendNotification,
  sendToPayload,
  logSendingNotification,
  logErrorNotification,
  logEmptyToken,
  sendBulkNotificationWithPayload,
  sendBulkNotificationWithoutPayload,
};
