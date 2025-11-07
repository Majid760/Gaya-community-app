
const admin = require('firebase-admin');
const fieldValue = admin.firestore.FieldValue;
const db = admin.firestore();
const utils = require('../../../utils/methods.js');
const crownServices = require("./../../firestore/./common/./crown_services.js");

/**
 * Like A Post - DB Operation
 * @param {string} uid
 * @param {string} postId
 * @returns {Promise<admin.firestore.WriteResult>} 
*/
const likePostDB = async (uid, postId) => {
 
    return db.collection('communityposts').doc(postId).update({
        likedBy: fieldValue.arrayUnion(uid)
    });
}

/**
 * Comment On A Post - DB Operation
 * It will create a comment with firestore doc id as commentId, and update total comments count
 * @param {string} uid - The user who is commenting
 * @param {string} postId - The post which is being commented on
 * @param {string} comment - A Comment!
 * @returns {Promise<admin.firestore.WriteResult>}
 */
const commentOnPostDB = async (uid, postId, comment) => {
    const postRef = db.collection('communityposts').doc(postId);
    const newCommentId = utils.generateFirestoreDocId();
    const batch = db.batch();


    const commentPayload = {
        'userId': uid,
        'comment': comment,
        'commentId': newCommentId,
        'commentTime': utils.getDateTimeUTC(),
        'videoUrl': null,
        'photoUrl': null,
        'mentionedUsers': null,
        'pdfFiles': [],
        'score': 0,
    }

    const postPayload = {
        "totalCommentsCount": fieldValue.increment(1)
    }

    /// creates a comment
    batch.set(postRef.collection('comments').doc(newCommentId), commentPayload);

    /// updates/set the totalCommentsCount
    batch.set(postRef, postPayload, { merge: true })

    return batch.commit();
}


/**
 * Crown On A Post - DB Operation 
 * @param {string} postId - The post which is being crowned 
 * @param {string} senderId - The user who is crowning 
 * @param {FirebaseFirestore.DocumentSnapshot<FirebaseFirestore.DocumentData>} rawPost - Snapshot of the post
 */
const crownOnPostDB = async (postId,  senderId, rawPost) => {
     return await crownServices.giveCrownToPostAndUser(postId,  senderId, rawPost); 
}


module.exports = {
    likePostDB,
    commentOnPostDB,
    crownOnPostDB
}

 


/**  
///In Dart 

*  PATH: communityposts/{postId}/comments/{commentId}

* JSON: 
 
      'userId': userId,
      'comment': comment,
      'commentId': commentId,
      'commentTime': commentTime,
      'videoUrl': videoUrl,
      'photoUrl': photoUrl,
      'mentionedUsers': mentionedUsers?.toList(),
      'pdfFiles': (pdfFiles == null || pdfFiles!.isEmpty) ? [] : pdfFiles?.toList(),
      'score':0,
 */