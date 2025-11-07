const admin = require('firebase-admin');
const utils = require('../../../utils/methods.js');
const db = admin.firestore();

/**
 * Create user entry in userActivities collection of all users
 */
const shiftAllUsersToUserActivityCollection = async () => {

    const rawUsers = await db.collection('users').get();

    // split users into chunks of 500
    const chunkedPosts = utils.chunkArray(rawUsers.docs, 499);
    chunkedPosts.forEach(async (chunk) => {
        // loop through chunks in batch write
        const batch = db.batch();
        chunk.forEach((rawUser) => {
            try {
                const resetValue = 0;
                const userActivityRef = db.collection('userActivities').doc(rawUser.id);
                batch.set(userActivityRef, {
                    createPostScore: resetValue,
                    createCommunityScore: resetValue,
                    commentScore: resetValue,
                    commentReplyScore: resetValue,
                    likePostScore: resetValue,
                    likeCommentScore: resetValue,
                    likeCommentReplyScore: resetValue,
                    dislikeScore: resetValue,
                    dislikeCommentScore: resetValue,
                    dislikeCommentReplyScore: resetValue,
                    PostCrownScore: resetValue,
                    commentCrownScore: resetValue,
                    commentReplyCrownScore: resetValue,
                    shareScore: resetValue,
                    directMessageScore: resetValue,
                    sendRequestScore: resetValue,
                    acceptRequestScore: resetValue,
                    rejectRequestScore: resetValue,
                });


            } catch (_) {
                console.log("Error occured at resetAndAddDailyFreeCrowns(): " + _);
            }

        },

        );
        await batch.commit();

    });
}


/**
 * Add previousDayScore Field into users collection
 * Add totalScore Field into users collection
 */
const addFieldsToUsersCollection = async () => {
    const rawUsers = await db.collection('users').get();

    // split users into chunks of 500
    const chunkedUsers = utils.chunkArray(rawUsers.docs, 499);
    chunkedUsers.forEach(async (chunk) => {
        // loop through chunks in batch write
        const batch = db.batch();
        chunk.forEach((rawUser) => {
            try {
                const userRef = db.collection('users').doc(rawUser.id);
                batch.set(userRef, {
                    previousDayScore: 0,
                    totalScore: 0,

                }, { merge: true });
            }
            catch (_) {
                console.log("Error occured at addFieldsToUsersCollection(): " + _);
            }
        },
        );
        await batch.commit();
    });


}


/**
 * Add score Field into posts collection
 */
const addScoreFieldsToPostsCollection = async () => {
    const rawPosts = await db.collection('communityposts').get();
    console.log(rawPosts.docs.length);
    rawPosts.docs.forEach((doc) => {
        console.log("DOC ID: " + doc.id, " =>descreiption:  ", doc.data().postDescription);
    });

    // split users into chunks of 500
    const chunkedPosts = utils.chunkArray(rawPosts.docs, 499);
    chunkedPosts.forEach(async (chunk) => {
        // loop through chunks in batch write
        const batch = db.batch();
        chunk.forEach((rawPost) => {
            try {
                rawPost.id;
                const postRef = db.collection('communityposts').doc(rawPost.id);
                batch.set(postRef, {
                    score: 0,

                }, { merge: true });
            }
            catch (_) {
                console.log("Error occured at addScoreFieldsToPostsCollection(): " + _);
            }
        },
        );
        await batch.commit();
    });


}


const addScoreFieldsToCommentsCollection = async () => {
    const batch = db.batch();
    const rawCommunities = await db.collection('communities').get();
    rawCommunities.docs.forEach(async (community) => {
        batch.set(community.ref, { score: 0 }, { merge: true });
    });
    await batch.commit();
}


const addWeightageToPosts = async () => {
    const rawPosts = await db.collection('communityposts').get();
    // split users into chunks of 500
    const chunkedPosts = utils.chunkArray(rawPosts.docs, 499);
    try{
        chunkedPosts.forEach(async (singleBatch) => {
            // loop through chunk of post in batch
            const firestoreBatch = db.batch();
            singleBatch.forEach((rawPost) => {
                try {
                    const postRef = db.collection('communityposts').doc(rawPost.id);
                    /// calculate weightage of post
                    const weightage = _caluclatePostScore(rawPost.data()); 
                    if (weightage > 0) {
                        firestoreBatch.update(postRef, { score: weightage });
                    }
    
                }
                catch (_) {
                    console.log("Error occured at addScoreFieldsToPostsCollection(): " + _);
                }
            },
            );
            await firestoreBatch.commit();
        }
        );
    }catch(_){
        console.log("Error occured: " + _);
    }
  
}


/**  
 *  @DESCRIPTION
 * Calculates a post's score based on the following formula:      
 [totalScore = (postLikesCount * kLikeScore) + (postCrownCount * kCrownScore) + (postCommentCount * kCommentScore)]
 * @param {Object} post - post.data() The actual post object from firestore 
 * @returns {number} totalScore - The total score of the post
  */
const _caluclatePostScore = (post) => {
    /// constants
    const kCommentScore = 20;
    const kCrownScore = 5;
    const kLikeScore = 2;
 
    /// aggregate post likes count
    let postLikesCount, postCommentCount, postCrownCount = 0;
    if (post.likedBy) {
        postLikesCount = (post.likedBy.length ?? 0) * kLikeScore;
    }
    if (post.crownsBy) {
        postCrownCount = (post.crownsBy.length ?? 0) * kCrownScore;
    }
    if (post.totalCommentsCount) {
        postCommentCount = (post.totalCommentsCount ?? 0) * kCommentScore;
    }

    /// calculate total score
    const totalScore = postLikesCount + postCrownCount + postCommentCount; 
    /// check if totalScore is number and return 0 if not.
    if (isNaN(totalScore) || totalScore === null || totalScore === undefined) {
        console.log("Total Score is not a number");
        return 0;
    } else {
        return totalScore;
    }

}

module.exports = {
    shiftAllUsersToUserActivityCollection,
    addFieldsToUsersCollection,
    addScoreFieldsToPostsCollection,
    addScoreFieldsToCommentsCollection,
    addWeightageToPosts
}