const admin = require('firebase-admin');
const db = admin.firestore(); 
 


/**
 *  Adds a notification to the user's notification collection in firestore
 * @param {string} payload.sender_name - The name of the sender - TITLE  (REQUIRED)
 * @param {string} payload.message - The message of the notification - BODY (REQUIRED)
 * @param {string} payload.type - The type of the notification - TYPE (REQUIRED)
 * @param {string} payload.receiverUserID - The user ID of the receiver - RECEIVER (optional)
 * @param {string} payload.userImage - The image of the sender - IMAGE URL (optional)
 * 
 * @returns  {Promise} - Returns a promise with the notification ID
 */
const addNotification  = async (payload) => { 
 
    console.log("payload: ", payload);
    const notificationRef = db.collection('users').doc(payload.receiverUserID).collection('notifications');
    const notification = await notificationRef.add({
        ...payload,
        isRead: false, 
    });

    console.log("notification: ", notification);
    return notification.id;

};

module.exports = {
    addNotification,
}