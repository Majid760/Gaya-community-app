const admin = require("firebase-admin");
const db = admin.firestore();
const utils = require("../../../utils/methods.js");

/**
 * Choose a random user member from a community and assign it as admin
 * @param {string} communityId - Community ID
 * @returns {Promise}
 */
const assignRandomUserAsAdmin = async (communityId) => {
  const communityRef = db.collection("communities").doc(communityId);
  const membershipRef = communityRef.collection("communityMembers");
  const memerbshipSnapshot = await membershipRef.limit(1).get();

  if (memerbshipSnapshot.size === 0)
    return console.log("No members in this community");
  const randomMember = memerbshipSnapshot.docs[0];
  const randomMemberId = randomMember.id;

  membershipRef.doc(randomMemberId).update({ isAdmin: true });
  communityRef.update({ adminId: randomMemberId });
};

/**
 * Invoke to get community subscribed members ids (users who turned on notifications)
 * @param {String} communityId
 */
const getCommunitySubscribedMemberIds = async (communityId) => {
  const membersSnap = await db
    .collection("communities")
    .doc(communityId)
    .collection("communityMembers")
    .where("isNotificationEnabled", "==", true)
    .get();
  var memberIds = [];
  membersSnap.forEach((member) => {
    memberIds.push(member.id);
  });
  return memberIds;
};

module.exports = { assignRandomUserAsAdmin, getCommunitySubscribedMemberIds };
