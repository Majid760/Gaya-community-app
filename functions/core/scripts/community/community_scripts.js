const admin = require('firebase-admin');
const db = admin.firestore();
const validator = require("../../validations/validators/community_validator.js");


const updateCommunityType = async () => {
    /// Update all communities type to be one of the following: Public, Private, Secret
    const communityRef = db.collection('communities').where("type", "not-in", ["Public", "Private", "Secret"]);
    const snapshot = await communityRef.get();

    console.log("snapshot size: ", snapshot.size);
    snapshot.forEach(async (doc) => {
        const type = doc.data().type;

        /// Update community type to be one of the following: Public, Private, Secret
        doc.ref.update({ type: validator.validateCommunityType(type) });
        //   console.log("docId: ", doc.id + " type: ",validator.validateCommunityType(doc.data().type) );


    });



}

const updateSingleCommunityType = async (communityId) => {
    /// Update all communities type to be one of the following: Public, Private, Secret
    const communityRef = db.collection('communities').doc(communityId);
    const snapshot = await communityRef.get();
    snapshot.ref.update({ type: validator.validateCommunityType(snapshot.data().type) });

}

/**
 * For Single Community
 * @param {String} communityId 
 */
const fetchAndUpdateCreateOnSingleCommunity = async (communityId) => {
    /// Update all communities type to be one of the following: Public, Private, Secret
    const communityRef = db.collection('communities').doc(communityId);
    const snapshot = await communityRef.get();
    const createdOn = await fetchCommunityAdminCreatedOn(communityId);
    snapshot.ref.update({ createdOn: createdOn });
}
/**
 * For All Communities
 */
const fetchAndUpdateCreateOnAllCommunities = async () => {
    /// Update all communities type to be one of the following: Public, Private, Secret
    const communityRef = db.collection('communities').where("createdOn", "==", null);
    const snapshot = await communityRef.get();
    console.log("snapshot size: ", snapshot.size);
    for await (const doc of snapshot.docs) {
        const createdOn = await fetchCommunityAdminCreatedOn(doc.id);
        await doc.ref.update({ createdOn: createdOn });
    }
}


/**
 * fetches admin createdOn from communityMembers collection as its  community creation date
 * @param {String} communityId 
 * @returns  {Promise<Time>} admin createdOn
 */
const fetchCommunityAdminCreatedOn = async (communityId) => {

    const communityRef = db.collection('communities').doc(communityId).collection('communityMembers').where("isAdmin", "==", true);
    const snapshot = await communityRef.get();
    console.log("snapshot size: ", snapshot.size);
    return snapshot.docs[0].data().createdOn;
}

/**
 * a function to fetch all communities with null createdOn
 * @returns {Promise<[]>} all communities with null createdOn
 */
const _getAllCommunitiesWithNullCreatedOn = async () => {
    const communityRef = db.collection('communities').where("createdOn", "==", null);
    const snapshot = await communityRef.get();
    return snapshot.docs;
}
module.exports = {
    updateCommunityType, updateSingleCommunityType, fetchCommunityAdminCreatedOn, fetchAndUpdateCreateOnSingleCommunity,
    fetchAndUpdateCreateOnAllCommunities
}