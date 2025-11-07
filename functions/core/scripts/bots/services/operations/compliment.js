///
/// Give a compliment to a user DB operation
/// 

const admin = require('firebase-admin');
const db = admin.firestore();
const utils = require('../../../../../utils/methods.js');

/**
 * Compliment A user in the DB - Just add the document to the compliments collection
 * @param {string} userId  - Receiver of the compliment
 * @param {string} senderUid - Sender of the compliment
 * @param {string} compliment - Should be a valid Compliment
 * @returns 
 */
const complimentUserDB = async (userId, senderUid, compliment) => {

    const complimentsRef = db.collection('users').doc(userId).collection('compliments').doc(senderUid).collection('all_compliments');
    const complimentPayload = { 
        'compliment': compliment,
        'createdOn': utils.getDateTimeUTC(),
        'senderUid': senderUid,
    }
   return await complimentsRef.add(complimentPayload);
}

module.exports = complimentUserDB