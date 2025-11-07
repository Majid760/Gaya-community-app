const admin = require('firebase-admin');
const db = admin.firestore();
const utils = require('../../../utils/methods.js');




const addIsInFeedIntoPosts = async () => {
  
        const postRef = db.collection('communityposts');
        console.log("getLast30DaysDateTime: ", utils.getLast14DaysDateTime());
        const posts = await postRef.where("createdOn", ">=", utils.getLast14DaysDateTime()).get() 
        console.log("posts size: ", posts.size);
  


    // split users into chunks of 500
    const chunkedPosts = utils.chunkArray(posts.docs, 499);

    chunkedPosts.forEach(async (chunk) => {
        // loop through chunks in batch write
        const batch = db.batch();
        chunk.forEach((post) => {  
            console.log("postId: ", post.id);
            batch.set(post.ref, { showInFeed: true }, { merge: true }); 
        });
        await batch.commit();
    });

    console.log("done");

}

const removeIsInFeedIntoPosts = async () => {
    const postRef = db.collection('communityposts');
    const posts = await postRef.where("showInFeed", "==", true).where("createdOn", "<", utils.getLast14DaysDateTime()).get()

   console.log("posts size: ", posts.size);
     
    // split users into chunks of 500
    const chunkedPosts = utils.chunkArray(posts.docs, 499);

    chunkedPosts.forEach(async (chunk) => {
        // loop through chunks in batch write
        const batch = db.batch();

        chunk.forEach((post) => { 
            batch.update(post.ref, { showInFeed: false }); 
        });

        await batch.commit();
    });
 
}


/**
 * Fetch A Post By Id
 * @param {string} postId
 * @returns {Promise<admin.firestore.DocumentSnapshot>}
 * @throws error if post is not found
 */
const getPostById = async (postId) => {
    const postRef = db.collection('communityposts').doc(postId);
    const postSnapshot = await postRef.get();

    if (!postSnapshot.exists) throw new Error("Post not found");

    return postSnapshot;
}

module.exports = {
    getPostById, addIsInFeedIntoPosts, removeIsInFeedIntoPosts
}