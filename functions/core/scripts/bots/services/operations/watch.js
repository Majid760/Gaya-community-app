///
/// See User Profile as Anonymousely
/// 

const admin = require('firebase-admin');
const db = admin.firestore();
const utils = require('../../../../../utils/methods.js');

/**
 * Just add the document to the watch collection
 * @param {string} userWhoViewedProfileId  -  User who viewed the profile
 * @param {string} userWhoseProfileViewedId -  User whose profile was viewed
 */
const watchAUserDB = async (userWhoViewedProfileId, userWhoseProfileViewedId) => {

    const watches = db.collection('userProfileWatches');
    const complimentPayload = { 
        'userWhoViewedProfileId': userWhoViewedProfileId,
        'userWhoseProfileViewedId':  userWhoseProfileViewedId,
        'visitedTime': utils.getDateTimeUTC(),
    }
   return await watches.add(complimentPayload);
}

module.exports = watchAUserDB