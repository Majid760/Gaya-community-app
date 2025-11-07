const utils = require('../../../../utils/methods.js');

/**
 * Generates a random count for total likes
 * @returns {int} random number between 0 and 3
 */
const genRandForLike = ()=>{
    return utils.generateRandomNumber(0,3);
}
/**
 * Generates a random count for total Crowns
 * @returns {int} random number between 0 and 1
 */
const genRandForCrown = ()=>{
    return utils.generateRandomNumber(0,1);
}

/**
 * Generates a Milliseconds wait time to wait before reacting to a post, to simulate a user's reaction time
 * @returns {int} random number between 0 and 30
 * @description This is used to simulate a user's reaction time
*/
const genRandTimeDurationInMs = ()=>{
    return utils.generateRandomNumber(0,30);
}

module.exports = {
    genRandForLike,
    genRandForCrown,
    genRandTimeDurationInMs,
}