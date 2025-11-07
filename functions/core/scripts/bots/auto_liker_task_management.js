
const {getFunctions} = require("firebase-admin/functions");
const randGenerator = require("./../../../utils/methods.js").getRandomInt
const logger = require("firebase-functions").logger;
const autoLikerAnalyzer = require("./auto_liker_analyzer.js");


/**
 * Enques post for reaction - auto like
 * @param {string} postId 
 */
const enquePostForReaction = async (postId) => {
    
    const queue = getFunctions().taskQueue("autoLikeCloudTaskQueue");
    const scheduleDelaySeconds = randGenerator(1,30);  
    await queue.enqueue(
        { "postId": postId },
        {
          scheduleDelaySeconds,
          dispatchDeadlineSeconds: 60 * 5 // 5 minutes
        },
      )
    
}

/**
 *  Validate and dispatch post for reaction
 * 
 * @param {requestBody} data  - request body
 */
const validateAndDispatchPostReaction = async (data) => {
  
    const { postId } = data;  /// get postId from data
    if(!postId){
        throw new Error("postId is required");
    }  
    
    await autoLikerAnalyzer(postId)

     logger.info(`autoLikeCloudTaskQueue: ${postId} executed successfully`);
    return { result: `autoLikeCloudTaskQueue: ${postId} executed successfully` };
}
 

module.exports = {
    enquePostForReaction,
    validateAndDispatchPostReaction
}