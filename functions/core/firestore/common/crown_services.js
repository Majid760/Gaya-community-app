///
///
///  This file contains all the crown related services
///
/// 
// Path: core/firestore/common/crown_services.js


const admin = require('firebase-admin');
const db = admin.firestore();
const fieldValue = admin.firestore.FieldValue;

/**
 * Give Crown to post + Add into user's crown count
 * @param {string} postId - post id 
 * @param {string} senderId - sender user id - crown sender
 * @param {FirebaseFirestore.DocumentSnapshot<FirebaseFirestore.DocumentData>} rawPost -  raw post object
 * @param {Boolean} bypassExistingCrowns - It will not check if sender have any crowns or not.
 */
const giveCrownToPostAndUser = async (postId, senderId, rawPost, bypassExistingCrowns = false) => {
    console.log("Params: ", postId, senderId,  bypassExistingCrowns)

    // references
    const postRef = db.collection('communityposts').doc(postId); 

    // transaction batch
 return   await db.runTransaction(async (t) => {

        const postData = rawPost;
        console.info("postData: ", postData.data().postDescription);
        const crownsBy = postData.data().crownsBy ?? [];
        const receiverId = postData.data().postedBy.uid;

        const senderRef = db.collection('users').doc(senderId);
        const receiverRef = db.collection('users').doc(receiverId);


        const receiverData = await t.get(receiverRef);
        const senderData = await t.get(senderRef);
 

        let receiverTotalCrowns = _validateCrownCount(receiverData.data().userTotalCrowns ?? 0);
        let userDailyCrowns = _validateCrownCount(senderData.data().userDailyCrowns ?? 0);

        /// check if user already gave crown to this post throw an error to abort.
        if (crownsBy.includes(senderId)) {
            throw new Error('User already gave crown to this post');
        }

        /// check if user have enough crowns to give.
        if(bypassExistingCrowns == false && userDailyCrowns <=0){
            throw new Error("User is having not enough daily crowns")
        }


        /// Write batches
        /// Add crown to post
        t.update(postRef, { crownsBy: fieldValue.arrayUnion(senderId) });

        // update receiver crowns
        receiverTotalCrowns = receiverTotalCrowns + 1;
        t.update(receiverData.ref, { userTotalCrowns: receiverTotalCrowns });

        //update sender crowns 
        userDailyCrowns = userDailyCrowns - 1;
        /// make sure crowns count is not negative
        userDailyCrowns = userDailyCrowns < 0 ? 0 : userDailyCrowns;
        t.update(senderData.ref, { userDailyCrowns: userDailyCrowns }); 
    });


}









/**
* Give crown to comment in firestore by userId
* @param {string} postId - post id
* @param {string} commentId - comment id
* @param {string} replyCommentId - reply id
* @param {string} userId - user id

*/
const giveCrownToAReplyComment = async (
    postId,
    commentId,
    replyCommentId,
    userId
) => {
    try {
        const response = await db
            .collection("communityposts")
            .doc(postId)
            .collection("comments")
            .doc(commentId)
            .collection("replies")
            .doc(replyCommentId)
            .collection("crownOnComment")
            .doc(userId)
            .set({
                userId: userId,
                crownCommentId: userId,
            });

        return true;
    } catch (error) {
        console.log("Error occured at giveCrownToCommunityPost(): " + error);
        functions.logger.error(error);
        return new Error(error);
    }
};

/**
* Give crown to comment in firestore by userId
* @param {string} postId - post id
* @param {string} commentId - comment id
* @param {string} userId - user id

*/
const giveCrownToAComment = async (postId, commentId, userId) => {
    try {
        const response = await db
            .collection("communityposts")
            .doc(postId)
            .collection("comments")
            .doc(commentId)
            .collection("crownOnComment")
            .doc(userId)
            .set({
                userId: userId,
                crownCommentId: userId,
            });
        return true;
    } catch (error) {
        console.log("Error occured at giveCrownToCommunityPost(): " + error);
        functions.logger.error(error);
        return new Error(error);
    }
};


const _validateCrownCount = (crownsCount) => {
    if (crownsCount == null || crownsCount < 0 || crownsCount == undefined || crownsCount == NaN) {
        crownsCount = 0;
    }
    return crownsCount;
}

module.exports = {
    giveCrownToPostAndUser,
    giveCrownToAReplyComment,
    giveCrownToAComment

}