const { userIndex, communityIndex, postIndex, communityMembersIndex } = require('./algolia_config.js');



/************************************************************************************************************************** 
 *                      USER INDEX SERVICES                                                                               *            
 **************************************************************************************************************************/


/** 
 * @param {Object} user  - user object from firestore (user.data())
 * Inserting a new user in algolia index
 ** Fields: name, uid, email, createdAt, interests, phoneNumber, profilePic, coverPic, isActive
 */
const insertUserInIndex = async (user) => {

    try {
        const id = user.uid;
        console.log("userID: ", id);
        console.log("user: ", user);
        const updatedUserInfo = {
            name: user.name, 
            email: user.email,
            createdAt: user.createdAt,
            interests: user.interests,
            phoneNumber: user.phoneNumber,
            profilePic: user.profilePic,
            coverphoto: user.coverphoto,
            isActive: user.isActive,
        }
        const createdInfo = await userIndex.saveObject({ ...updatedUserInfo, objectID: id });
        console.log("createUserIndex createdInfo: ", createdInfo);


    } catch (_) {
        console.log("Error in creating user index algolia: ", _);
    }
}

/**
 * @param {Object} user  - user object from firestore (user.data())
 * Updates only the following fields: name, bio, interests,phoneNumber, profilePic, coverphoto,  isActive
 */

const updateUserProfileInIndex = async (user) => {

    try {
        const id = user.uid;
        console.log("userID: ", id);
        console.log("user: ", user);

        const updatedUserInfo = {
            name: user.name,
            bio: user.bio,
            phoneNumber: user.phoneNumber,
            profilePic: user.profilePic,
            coverphoto: user.coverphoto,
            interests: user.interests,
            isActive: user.isActive,
        }
        const updatedInfo = await userIndex.partialUpdateObject({ ...updatedUserInfo, id, objectID: id });
        console.log("createUserIndex updatedInfo: ", updatedInfo);
    } catch (_) {
        console.log("Error in updateUserProfileInIndex algolia: ", _);
    }
}

/** 
 * @param {string} userId  -  user id
 */
const removeUserInIndex = async (userId) => {

    try {
        console.log("userID: ", userId);

        await userIndex.deleteObject(userId);


    } catch (_) {
        console.log("Error in removeUserInIndex   algolia: ", _);
    }
}


/**************************************************************************************************************************
 *                      Community INDEX SERVICES                                                                          *            
 **************************************************************************************************************************/

/** 
 * @param {Object} community -- community object from firestore (community.data())
 * Inserting a new community in algolia index
 * Field communityId, name, profilePicture, communitypic, description, topics, type, members
 */
const insertCommunityInIndex = async (community) => {
    try {
        
        const id = community.communityId ?? community.id;
        const updatedCommunityPayload = {
            communityId: id,
            name: community.name,
            profilePicture: community.profilePicture,
            communitypic: community.communitypic,
            description: community.description,
            topics: community.topics,
            type: community.type, 
            totalmembers : community.totalmembers,
            isCommQNeeded : community.isCommQNeeded  ?? false,

        }

        await communityIndex.saveObject({ ...updatedCommunityPayload, objectID: id });
        console.log("New Community Indexed: " + community.name + ", Id:", id);
    } catch (_) {
        console.log("Error in creating community index algolia: ", _);
    }
}

/**
 * @param {Object} community -- community object from firestore (community.data())
 ** Updates only the following fields: name, profilePicture, communitypic, description, topics, type
*/
const updateCommunityProfileInIndex = async (community) => {

    try {
        const updatedCommunityPayload = {
            name: community.name,
            profilePicture: community.profilePicture,
            communitypic: community.communitypic,
            description: community.description,
            topics: community.topics,
            type: community.type,

        }
        const id = community.communityId ?? community.id;

        await communityIndex.partialUpdateObject({ ...updatedCommunityPayload, objectID: id });

    } catch (_) {
        console.log("Error in updateCommunityInIndex algolia: ", _);
    }
}

/**
 * Update Community Total Members count
 * @param {string} communityId -- communityId
 * @param {number} totalmembers -- totalmembers
 */

const updateCommunityMemberCountInIndex = async (communityId, totalmembers) => {
    
        try {
            const updatedCommunityPayload = { 
                totalmembers: totalmembers,
            }
            console.log("updatedCommunityPayload: ", updatedCommunityPayload, " communityId: ", communityId);
            await communityIndex.partialUpdateObject({ ...updatedCommunityPayload, objectID: communityId });
    
        } catch (_) {
            console.log("Error in updateCommunityTotalMembersInIndex algolia: ", _);
        }
}
/** 
 * Delete a community from algolia index
 * @param {string} communtiyId -- communtiyId
 */
const removeCommunityInIndex = async (communtiyId) => {

    try { 
        return await communityIndex.deleteObject(communtiyId);

    } catch (_) {
        console.log("Error in removeCommunityInIndex algolia: ", _);
    }
}



/**************************************************************************************************************************
 *                      COMMUNITY MEMBERSHIP SERVICES                                                                      *            
 **************************************************************************************************************************/


            /*
            * TODO:  Will have to de-normalize the data and store in algolia as algolia limit 10KB per record 
            * Commented out for now
            */
/**
 * Merging members array into the community profile in algolia  
 * Adds the user to the members array in the community profile in algolia - Distinctively
 * @param {Object} userId  -- user object from firestore (user.data())
 * @param {String} communityId  -- communityId of the community the user is a member of
 */
const insertCommunityMemberInIndex = async (userId, communityId) => {
    // if (!userId) return;

    // try {

    //     const response =
    //         await indexServices.communityIndex.partialUpdateObject({
    //             createIfNotExists: true,
    //             members: {
    //                 _operation: 'AddUnique',
    //                 value: userId
    //             },
    //             objectID: communityId
    //         })
    //     console.log("response insertCommunityMemberInIndex: ", response);
    // } catch (_) {
    //     console.log("Error in creating community members index algolia: ", _);
    // }
}


            /*
            * TODO:  Will have to de-normalize the data and store in algolia as algolia limit 10KB per record 
            * Commented out for now
            */
/**
 * Removes the user from the members array in the community profile in algolia
 * @param {Object} userId  -- user object from firestore (user.data())
 * @param {String} communityId  -- communityId of the community the user is a member of
 */
const removeCommunityMemberInIndex = async (userId, communityId) => {
    // try {
    //     communityIndex.partialUpdateObject({
    //         members: {
    //             _operation: 'Remove',
    //             value: userId
    //         },
    //         objectID: communityId
    //     }, communityId)

    // } catch (_) {
    //     console.log("Error in removing community members index algolia: ", _);
    // }
}


/**************************************************************************************************************************
 *                      POST INDEX SERVICES                                                                                *            
 **************************************************************************************************************************/


/**
 * @param {Object} post -- post object from firestore (post.data()) 
 ** [caption, communityId, communityName, communityTopics, postedBy] will be indexed in algolia
 */
const insertPostInIndex = async (post) => {
    try {
        const algoliaPost = {
            objectID: post.id,
            caption: post.postDescription,
            communityId: post.communityId, 
            postedBy: post.postedBy.uid,
        };
        const id = post.postId ?? post.id;
        console.log("algoliaPost Model: ", algoliaPost);
        await postIndex.saveObject({ ...algoliaPost, objectID: id });
    } catch (_) {
        console.log("Error in creating post index algolia: ", _);
    }
}

/**
 * @param {Object} post -- post object from firestore (post.data()) 
 ** [caption, communityId, communityName, communityTopics, postedBy] will be indexed in algolia
 */
const removePostInIndex = async (post) => {
    try {

        const id = post.postId ?? post.id;
        console.log("algoliaPost Model: ", algoliaPost);
        await postIndex.saveObject(id);
    } catch (_) {
        console.log("Error in remove post index algolia: ", _);
    }
}






module.exports = {
    insertUserInIndex,
    updateUserProfileInIndex,
    removeUserInIndex,
    insertCommunityInIndex,
    removeCommunityInIndex,
    insertPostInIndex,
    removePostInIndex,
    insertCommunityMemberInIndex,
    removeCommunityMemberInIndex,
    updateCommunityProfileInIndex,
    updateCommunityMemberCountInIndex,
}