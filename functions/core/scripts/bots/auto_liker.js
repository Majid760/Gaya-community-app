const postLiker = require('./services/operations/like.js');
const postCommenter = require('./services/operations/comment.js');
const postCrowner = require('./services/operations/crown.js');
const userServices = require('./../../firestore/common/user_services.js')
const commentGenerator = require('./generator/new_comment_generator.js')
const compliments = require('../bots/services/operations/compliment.js')
const complimentGenerator = require('./generator/compliment_generator.js')
const watchAUser = require('./services/operations/watch.js')
const utils = require('./../../../utils/methods.js')

/**
 * A function to like a post by a user
 * @param {string} postId - The post which is being liked
 * @param {number} limit - The number of bots to like the post - default `1`
 */
const likeAPost = async (postId, limit = 1) => {
    const bots = (await userServices.getBotUsers(limit)).docs;

    console.log("bot Users", bots.length)
    for await (const bot of bots) {
        await postLiker.likePost(bot.data(), postId)
        console.log("liked post with: ", bot.data().name)
    }

}

/**
 * A function to comment on a post by a Bot User
 * @param {string} postId - The post which is being liked 
 * @param {number} limit - The number of bots to comment the post - default `1`
 */
const commentsOnAPost = async (postId, limit = 1) => {
    const bots = (await userServices.getBotUsers(limit)).docs;

    console.log("Total fetched bot users", bots.length)

    for await (const bot of bots) {
        /// generate random comment
        const comment = commentGenerator()
        await postCommenter.commentOnPost(bot.data(), postId, comment)
        console.log("commented with: ", comment)
    }
}

/**
 * A function to crown a post by a Bot User
 * @param {string} postId - The post which is being liked
 * @param {number} limit - The number of bots to crown the post - default `1`
 */
const crownAPost = async (postId, limit = 1) => {
    const bots = (await userServices.getBotUsers(limit)).docs;

    console.log("Total fetched bot users", bots.length)

    for await (const bot of bots) {
        try {
            await postCrowner.CrownPost(bot.data(), postId)
            console.log("crowned post with: ", bot.data().name)
        } catch (_) {
            console.error("Error while crowning post with: ", bot.data().name, " Error: ", _)
        }

    }
}





/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
////////////////////////// NON-Post Related //////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////


/**
 * A Function to Compliment a user
 * @param {string} userId - The user to compliment
 * @param {number} limit - The number of bots to compliment the user - default `1` 
 */ 
const complimentAUser = async (userId, limit = 1) => {
    const bots = (await userServices.getBotUsers(limit)).docs;

    console.log("Total fetched bot users", bots.length)

    for await (const bot of bots) {
        try {
            const compliment = complimentGenerator()
            await compliments(userId, bot.data().uid, compliment)
            console.log("complimented with: ", bot.data().name)
        } catch (_) {
             console.error("Error while complimenting user with: ", bot.data().name, " Error: ", _)
        } 
    }
}


/**
 * A Function to Watch a user
 * @param {string} userId - The user to be watched
 * @param {number} limit -  The number of bots to watch the user - default `1`
 */ 
const watchUser = async (userId, limit = 1) => {
    const bots = (await userServices.getBotUsers(limit)).docs;

    console.log("Total fetched bot users", bots.length)

    for await (const bot of bots) {
        try { 
            await watchAUser(bot.data().uid, userId)
            console.log("watched with: ", bot.data().name)
        } catch (_) {
             console.error("Error while Watching user with: ", bot.data().name, " Error: ", _)
        } 
    }
}



module.exports = {
    likeAPost,
    commentsOnAPost,
    crownAPost,
    complimentAUser,
    watchUser,
}