// 
// Decides if the bot should react to a post or not
// It contains all of the business logic for the bot
//

const autoLiker = require('./auto_liker.js');
const countGen = require('./generator/reaction_generator.js');  

/**
 * Generates random numbers and gives reaction to post.
 * 
 * @param {string} postId - post id
 */
const shouldBotReactToPost = async (postId) => {

    const totalCrowns = countGen.genRandForCrown(); // 0-1
    const totalLikes = countGen.genRandForLike(); // 0-3

    const promises = [];

    /// check if totalCrowns is 1
    if (totalCrowns === 1) {
        promises.push(autoLiker.crownAPost(postId, totalCrowns)); 
    }

    /// check if totalLikes is greater than 0
    if (totalLikes > 0) { 
        promises.push(autoLiker.likeAPost(postId, totalLikes));
    }

    await Promise.all(promises);

    return true;

};


module.exports = shouldBotReactToPost

