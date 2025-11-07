const indexServices = require('./algolia_config.js'); 
const admin = require('firebase-admin');
const services = require('./algolia_services.js'); 
const db = admin.firestore();
/// Request for cloning all users to algolia with single hit.
const addAllUsersCollectionDataToAlgolia = async (req, res) => {
    var arr = [];
    const batch = db.batch();
    db.collection('users').get().then((docs) => {
        docs.forEach((rawUser) => {
            let user = rawUser.data();
            const userObject = {
                objectID : user.uid,
                name: user.name, 
                email: user.email,
                createdAt: user.createdAt,
                interests: user.interests,
                phoneNumber: user.phoneNumber,
                profilePic: user.profilePic,
                coverphoto: user.coverphoto,
                isActive: user.isActive,
            }
          
            if(user.uid){
                arr.push(userObject);
            }
           
        })
         batch.commit();

        // cloning to alglolia index
        indexServices.userIndex
            .saveObjects(arr, { autoGenerateObjectIDIfNotExist: true })
            .then(({ objectIDs }) => {
                console.log(objectIDs);
            })
            .catch(err => {
                console.log(err);
            });
    })
}

const addAllCommunitiesCollectionDataToAlgolia = async (req, res) => {
    var arr = [];
    db.collection('communities').where("type","!=", "Secret").get().then((docs) => {
        docs.forEach((rawCommunity) => {
            let community = rawCommunity.data(); 
            const updatedCommunityPayload = { 
                objectID : community.communityId,
                name: community.name,
                profilePicture: community.profilePicture,
                communitypic: community.communitypic,
                description: community.description,
                topics: community.topics,
                type: community.type, 
                totalmembers : community.totalmembers,
            }
            if(updatedCommunityPayload.objectID){
                arr.push(updatedCommunityPayload);
            } 
        })


        // cloning to alglolia index
        indexServices.communityIndex
            .saveObjects(arr, { autoGenerateObjectIDIfNotExist: true })
            .then(({ objectIDs }) => {
                console.log(objectIDs);
            })
            .catch(err => {
                console.log(err);
            });
    })
}



const addAllPostsCollectionDataToAlgolia = async () => {
    var arr = [];  
 
    await db.collection('communityposts').where("isDeleted", "==", false).where("community.type", "==", "Public").orderBy('createdOn',  'desc').limit(5000).get().then((docs) => {
        docs.forEach((rawPost) => {
            let post = rawPost.data();
            post.objectID = rawPost.id;
            const algoliaPost = {
                objectID: rawPost.id,
                caption: post.postDescription,
                communityId: post.community.communityId, 
                postedBy: post.postedBy.uid,
            };
            arr.push(algoliaPost);
        })


        /// print last value of arr
        console.log("arr last : ", arr[arr.length - 1]);
        // cloning to alglolia index
        indexServices.postIndex
            .saveObjects(arr, { autoGenerateObjectIDIfNotExist: true })
            .then(({ objectIDs }) => {
                console.log(objectIDs);
            })
            .catch(err => {
                console.log(err);
            });
    })
}

const addAllCommunityMembersCollectionDataToAlgolia = async () => {
    /// Get all communities
    const communities = await db.collection('communities').get();

    /// Get all community members
    communities.forEach(async (community) => {
        try{
            const communityMembers = await db.collection('communities').doc(community.id).collection('communityMembers').get();
            communityMembers.forEach(async(communityMember) => {
                try{
    
                    const response = await  indexServices.communityIndex.partialUpdateObject({
                        createIfNotExists: true,
                        // members
                        members: {
                          _operation: 'AddUnique',
                          value: communityMember.id,
                        },
                        objectID: community.id,
                      })  
                }catch(_){
                    console.log("Error in addAllCommunityMembersCollectionDataToAlgolia: ", _);
                }
            
            });
            // cloning to alglolia index
            // const operations = arr.map(userId => ({
            //     objectID: community.id,
            //     members: { _operation: 'AddUnique', _value: userId }
            // }));
            // console.log(operations);
            // await indexServices.communityIndex.partialUpdateObjects(operations);
        }catch(_){
            console.log("Error in addAllCommunityMembersCollectionDataToAlgolia: ", _);
        }
     
    });


}

//TESTING`
const addSingleCommunityMembersCollectionDataToAlgolia = async () => {
    var arr = [];
    /// Get all communities
    const community = await db.collection('communities').doc("61287920-6e43-11ed-a393-35a7084c7d25").get();

    try{
        const communityMembers = await db.collection('communities').doc(community.id).collection('communityMembers').get();
        communityMembers.forEach(async(communityMember) => {
            try{

                const response = await  indexServices.communityIndex.partialUpdateObject({
                    createIfNotExists: true,
                    // members
                    members: {
                      _operation: 'AddUnique',
                      value: communityMember.id,
                    },
                    objectID: community.id,
                  })
                // const response = await indexServices.communityIndex.partialUpdateObject({
                //     createIfNotExists: true,
                    
                //     members: { _operation: 'AddUnique', _value: communityMember.id } }, community.id);
                arr.push(communityMember.id);
                console.log(response);
            }catch(_){
                console.log("Error in addAllCommunityMembersCollectionDataToAlgolia: ", _);
            }
        
        });
        // cloning to alglolia index
        // const operations = arr.map(userId => ({
        //     objectID: community.id,
        //     members: { _operation: 'AddUnique', _value: userId }
        // }));
        // console.log(operations);
        // await indexServices.communityIndex.partialUpdateObjects(operations);
    }catch(_){
        console.log("Error in addAllCommunityMembersCollectionDataToAlgolia: ", _);
    }


}


const updateAllCommunitiesMemberCount = async () => {
    /// Get all communities
    const communities = await db.collection('communities') .get();
  
    console.log("communities: ", communities.docs);
    
    /// Get all community members
    communities.docs.forEach(async (community) => {
        try{
            const count =     community.data().totalmembers;
            console.log("count: ", count);
            if(count === undefined) return;
            services.updateCommunityMemberCountInIndex(community.id, count)
           }catch(_){
               console.log("Error in updateAllCommunitiesMemberCount: ", _);
           }
    });
    
}

 

module.exports = {
    addAllUsersCollectionDataToAlgolia,
    addAllCommunitiesCollectionDataToAlgolia,
    addAllPostsCollectionDataToAlgolia, 
    addAllCommunityMembersCollectionDataToAlgolia,
    /// todo : remove
    addSingleCommunityMembersCollectionDataToAlgolia,
    updateAllCommunitiesMemberCount,
}