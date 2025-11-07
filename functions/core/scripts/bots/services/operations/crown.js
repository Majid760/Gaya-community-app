const reactionServices = require("../../../../firestore/common/post_reaction_services.js");
const commonServices = require("../../../../firestore/common/post_services.js");
const notifications = require("../../../../notifications/notificationHelper.js");
const utils = require("../../../../../utils/methods.js");

/**
 * crown A Post
 * @param {object} botUser - The bot who is liking the post - userObject
 * @param {string} postId - The post which will be crown
 * */
const CrownPost = async (botUser, postId) => {
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
        time: utils.getDateTimeUTC().toISOString()
    } 
 

    /// Like the post
    await Promise.all([
        /// DB call to like a post
        reactionServices.crownOnPostDB(postId,botUser.uid,  rawPost),

        /// Send Notification to the user and add notification to the firestore
         notifications.sendCrownNotificationToUser(botUser.uid, authorId,metadata)
    ]);


    return true; 
}

module.exports =   {
    CrownPost
};