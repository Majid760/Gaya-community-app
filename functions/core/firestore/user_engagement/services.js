const admin = require('firebase-admin');
const userServices = require('../common/user_services.js');
const utils = require('../../../utils/methods.js');
const db = admin.firestore();

/**
 * Create user entry in userActivities collection of all users
 * @returns {Promise} - Returns Promise
 */
const calculateAndResetUsersActivities = async () => {
    const rawUsers = await db.collection('users').get();
    console.log("rawUsers Length: " + rawUsers.docs.length);
    const chunkedUsers = utils.chunkArray(rawUsers.docs, 499);
    console.log("chunkedUsers: " + chunkedUsers.length);
    let i = 0;
    chunkedUsers.forEach(async (chunk) => {
        // loop through chunks in batch write
        const batch = db.batch();
        console.log("chunk: " + i++);
        await Promise.all(chunk.map(async (user) => {
            try {
                console.log("user: " + user.id);
                const userActivityRef = db.collection('userActivities').doc(user.id);
                const userRef = db.collection('users').doc(user.id);

                /// update user's total score + daily score in {userRef}
                const userPayload = await _calculateAndGetPayload(user.id);
                batch.update(userRef, userPayload);

                /// reset user activity score to 0 in {userActivityRef}
                batch.update(userActivityRef, {
                    createPostScore: 0,
                    createCommunityScore: 0,
                    commentScore: 0,
                    commentReplyScore: 0,
                    likePostScore: 0,
                    likeCommentScore: 0,
                    likeCommentReplyScore: 0,
                    dislikeScore: 0,
                    dislikeCommentScore: 0,
                    dislikeCommentReplyScore: 0,
                    PostCrownScore: 0,
                    commentCrownScore: 0,
                    commentReplyCrownScore: 0,
                    shareScore: 0,
                    directMessageScore: 0,
                    sendRequestScore: 0,
                    acceptRequestScore: 0,
                    rejectRequestScore: 0,

                });
            } catch (_) {
                console.log("Error occured at calculateAndResetUsersActivities(), inside forEach where batch is update is called.: " + _);
            }
        },
        ));
        console.log("batch commit ", i);
        await batch.commit();

    });

}



/**
 * Create A User Entry In UserActivities Collection
 * @param {string} uid
 */
const insertUserIntoUserActivityCollection = async (uid) => {
    const userActivityRef = db.collection('userActivities').doc(uid);
    userActivityRef.set({
        createPostScore: 0,
        createCommunityScore: 0,
        commentScore: 0,
        commentReplyScore: 0,
        likePostScore: 0,
        likeCommentScore: 0,
        likeCommentReplyScore: 0,
        dislikeScore: 0,
        dislikeCommentScore: 0,
        dislikeCommentReplyScore: 0,
        PostCrownScore: 0,
        commentCrownScore: 0,
        commentReplyCrownScore: 0,
        shareScore: 0,
        directMessageScore: 0,
        sendRequestScore: 0,
        acceptRequestScore: 0,
        rejectRequestScore: 0,

    });
}

/**
 * Reset User Activity Score
 * @param {string} uid
 */
const _resetUserActivityScore = async (uid) => {
    const userActivityRef = db.collection('userActivities').doc(uid);
    const resetActivityPayload = {
        createPostScore: 0,
        createCommunityScore: 0,
        commentScore: 0,
        commentReplyScore: 0,
        likePostScore: 0,
        likeCommentScore: 0,
        likeCommentReplyScore: 0,
        dislikeScore: 0,
        dislikeCommentScore: 0,
        dislikeCommentReplyScore: 0,
        PostCrownScore: 0,
        commentCrownScore: 0,
        commentReplyCrownScore: 0,
        shareScore: 0,
        directMessageScore: 0,
        sendRequestScore: 0,
        acceptRequestScore: 0,
        rejectRequestScore: 0,

    }
    try {
        await userActivityRef.update(resetActivityPayload);
    } catch (_) {
        console.log("Error occured at resetUserActivityScore(): " + _);
        await userActivityRef.set(resetActivityPayload, { merge: true });
    }

}

/**
 * Calculate activity fields
 * @param {string} uid
 * @returns Promise<number> totalScore - total score of a user (daily)
 */
const _calculateActivityFields = async (uid) => {
    const userActivityRef = db.collection('userActivities').doc(uid);
    const userActivity = await userActivityRef.get();
    const userActivityData = userActivity.data();
    /// calculate with type safe so null or undefined will be 0
    let totalScore = 0;
    totalScore += userActivityData.createPostScore || 0;
    totalScore += userActivityData.createCommunityScore || 0;
    totalScore += userActivityData.commentScore || 0;
    totalScore += userActivityData.commentReplyScore || 0;
    totalScore += userActivityData.likePostScore || 0;
    totalScore += userActivityData.likeCommentScore || 0;
    totalScore += userActivityData.likeCommentReplyScore || 0;
    totalScore += userActivityData.dislikeScore || 0;
    totalScore += userActivityData.dislikeCommentScore || 0;
    totalScore += userActivityData.dislikeCommentReplyScore || 0;
    totalScore += userActivityData.PostCrownScore || 0;
    totalScore += userActivityData.commentCrownScore || 0;
    totalScore += userActivityData.commentReplyCrownScore || 0;
    totalScore += userActivityData.shareScore || 0;
    totalScore += userActivityData.directMessageScore || 0;
    totalScore += userActivityData.sendRequestScore || 0;
    totalScore += userActivityData.acceptRequestScore || 0;
    totalScore += userActivityData.rejectRequestScore || 0;

    return totalScore;

}

/**
 * Calculate and return payload to update user's total score + daily score
 * @param {string} uid
 * @returns Promise<object> payload - payload to update user's total score + daily score
 */
const _calculateAndGetPayload = async (uid) => {
    /// Calculate User Activity Score
    const dailyScoreCount = await _calculateActivityFields(uid);
    /// Make a payload to update user's total score + daily score
    const scoresPayload = {
        previousDayScore: dailyScoreCount,
        totalScore: admin.firestore.FieldValue.increment(dailyScoreCount)
    }
    return scoresPayload;
}

/**
 * Default Values for User Activity
 * @returns {object} - Returns default scores object
 */
const getDefaultScores = () => {
    return {
        createPostScore: 0,
        createCommunityScore: 0,
        commentScore: 0,
        commentReplyScore: 0,
        likePostScore: 0,
        likeCommentScore: 0,
        likeCommentReplyScore: 0,
        dislikeScore: 0,
        dislikeCommentScore: 0,
        dislikeCommentReplyScore: 0,
        PostCrownScore: 0,
        commentCrownScore: 0,
        commentReplyCrownScore: 0,
        shareScore: 0,
        directMessageScore: 0,
        sendRequestScore: 0,
        acceptRequestScore: 0,
        rejectRequestScore: 0,
    }
};

/**
 * FOR SINGLE USER
 * Calculate User Activity and updates it into user's collection and resets userActivity collection to 0
 * @param {string} uid - User ID
 * @returns {Promise} - Returns Promise
 */
const calculateAndResetUserActivityScore = async (uid) => {
    /// Calculate User Activity Score
    const dailyScoreCount = await _calculateActivityFields(uid);
    /// Make a payload to update user's total score + daily score
    const scoresPayload = {
        previousDayScore: dailyScoreCount,
        totalScore: admin.firestore.FieldValue.increment(dailyScoreCount)
    }
    /// Update User's total score + daily score
    await userServices.updateUserByFields(uid, scoresPayload);
    /// Reset User Activity Score to 0
    await _resetUserActivityScore(uid);
}


/**
 * increment/decrement profile compliment score
 * @param {string} uid
 */
const incrementProfileComplimentScore = async (uid) => {
    try{
    const userid = "XVpV4jVXrwaUwbBRvwUjG1YsvSd2";
    const userActivityRef = db.collection('userActivities').doc(userid);
    const userActivity = await userActivityRef.get();
    const userActivityData = userActivity.data();

    const complimentScore = 0.25;

    if(!userActivityData.profileComplimentScore){
      if(userActivityData.profileComplimentScore < 2){
        complimentScore += userActivityData.profileComplimentScore;
      }
      else{
        complimentScore = 2.0;
      }
    }


        /// increment Profile Compliment Score
        await db
            .collection("userActivities")
            .doc(userid)
            .set({
              profileComplimentScore: admin.firestore.FieldValue.increment(complimentScore),
            },{ merge: true });
    }
    catch(_){
        console.log("Error occured in incrementProfileComplimentScore()");
    }
}



module.exports = {
    calculateAndResetUsersActivities,
    insertUserIntoUserActivityCollection,
    incrementProfileComplimentScore
}