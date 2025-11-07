const reactionServices = require("../../../../firestore/common/post_reaction_services.js");
const commonServices = require("../../../../firestore/common/post_services.js");
const notifications = require("../../../../notifications/notificationHelper.js");
const utils = require("../../../../../utils/methods.js");

/**
 * Comments On A Post
 * @param {object} botUser - The bot who is liking the post - userObject
 * @param {string} postId - The post which is being liked
 * @param {string} comment - The actual string for a comment
 * */
const commentOnPost = async (botUser, postId, comment) => {
    // Fetch the post
    const rawPost = await commonServices.getPostById(postId);
    const post = rawPost.data();

    const communityId = post.communityId; 
    const authorId = post.memberId;

    /// Metadata for the notification
    const metadata = {
        communityId: communityId,
        postId : postId,
        name: botUser.name,
        photoURL: botUser.profilePic,
        time: utils.getDateTimeUTC().toISOString(),
        comment: comment,

    } 
 

    /// Like the post
    await Promise.all([
        /// DB call to like a post
        reactionServices.commentOnPostDB(botUser.uid, postId, comment),

        /// Send Notification to the user and add notification to the firestore
        notifications.sendCommentNotificationToUser(botUser.uid, authorId,metadata)
    ]);


    return true; 
}

module.exports =   {
    commentOnPost
};