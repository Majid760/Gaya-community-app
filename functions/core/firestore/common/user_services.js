const admin = require("firebase-admin");
const db = admin.firestore();
const utils = require("../../../utils/methods.js");

/**
 * Updates User Profile
 * @param {string} uid - User ID
 * @param {object} payload - User Profile Data in Map Format
 * @returns {Promise}
 */
const updateUserByFields = async (uid, payload) => {
  const userRef = db.collection("users").doc(uid);
  return await userRef.update(payload);
};

/**
 * Get All User Data
 * @returns {Promise<[]>} all users
 */
const getAllUsers = async () => {
  const userRef = db.collection("users");
  const snapshot = await userRef.get();
  return snapshot.docs;
};

/**
 * Update User Profile in Chat Rooms
 * @param {object} payload - User Profile Data in Map Format
 * @returns {Promise}
 */
const updateUserProfileInChatrooms = async (payload) => {
  try {
    const userId = payload.uid;
    const chatroomRef = db
      .collection("chatrooms")
      .where("userIds", "array-contains", userId);
    const snapshot = await chatroomRef.get();
    if (snapshot.empty) {
      console.log("No matching documents.");
      return;
    }
    snapshot.forEach(async (doc) => {
      await doc.ref.update({
        userId: {
          name: payload.name,
          profilePic: payload.profilePic,
          uid: payload.uid,
        },
      });
    });
  } catch (_) {
    console.log("Error occured at updateUserProfileInChatrooms(): ", _);
  }
};

/**
 * Get user profile from firestore by UID
 * @param {string} uid - user id
 */
const getUserById = async (uid) => {
  try {
    if (!uid) throw new Error("uid is empty");
    const user = await db.collection("users").doc(uid).get();
    return user.data();
  } catch (error) {
    console.log("Error occured at getUserProfile(): " + error);
    functions.logger.error(error);
    return new Error(error);
  }
};

/**
 * get user FCM token from firestore by UID
 * @param {string} uid - user id
 */
const getUserFcmById = async (uid) => {
  try {
    const user = await getUserById(uid);
    return user.fm_token;
  } catch (error) {
    functions.logger.error(error);
    return new Error(error);
  }
};

/**
 * Gets a random Bot User
 * By default it will fetch 1 bot user.
 * @param {number} size - Number of bot users to fetch - By default: 1
 * @returns {Promise<admin.firestore.QuerySnapshot<admin.firestore.DocumentData>>} bot user - UserObject
 */
const getBotUsers = async (size = 1) => {
  console.log("Fetching bot users ", size, " in number");
  return await db
    .collection("users")
    .where("isBot", "==", true)
    .limit(size)
    .get();
};

/**
 * Function invoke to get multiple users ids
 * @param {string[]} usersIds Array of user ids to get tokens
 * @returns Array/List of user tokens with usersIds
 */
const getMultipleUsersTokens = async (usersIds) => {
  // Breaking userIds whole list/array into chunk of 10 10
  const chunkedTenUsersIdsLists = utils.chunkArray(usersIds, 10);
  // Declaring promises list for chunked users array
  const chunkedTenUserIdsPromisesLists = [];
  // List gonna contain all users fcm tokens
  const fcmTokens = [];

  // Iterating over all chunked user array promises list
  for (const chunkedTenUsersIdsList of chunkedTenUsersIdsLists) {
    //  Where in clause only allows 10 ids at a time
    chunkedTenUserIdsPromisesLists.push(
      db.collection("users").where("uid", "in", chunkedTenUsersIdsList).get()
    );
  }

  // Getting all users with data in chunked users lists
  const chunkedUsersLists = await Promise.all(chunkedTenUserIdsPromisesLists);
  if (!chunkedUsersLists) return [];

  chunkedUsersLists.forEach((chunkedUsersList) => {
    chunkedUsersList.forEach((user) => {
      fcmTokens.push(user.data().fm_token);
    });
  });

  return fcmTokens;
};

/**
 * Function invoke to get all users id (gender specific)
 * @param {string} gender Gender of the user to whom we are gonna send notifications
 * @returns List/array containing all users uIds
 */
const getAllGenderSpecificMembersIds = async (gender) => {
  let usersSnaps;

  // If gender is male we are getting all users who are male as well other one except female
  if (gender === "male") {
    usersSnaps = await db
      .collection("users")
      .where("gender", "!=", "female")
      .get();
  }

  // If gender is male we are getting all users who are female as well other one except male
  if (gender === "female") {
    usersSnaps = await db
      .collection("users")
      .where("gender", "!=", "male")
      .get();
  }

  // Getting all users if gender is all
  if (gender === "all") {
    usersSnaps = await db.collection("users").get();
  }

  var usersIds = [];
  usersSnaps.forEach((user) => {
    usersIds.push(user.id);
  });
  return usersIds;
};

/**
 * Invoke method to get gender specific members ids from all community members ids
 * @param {string} gender Admin selected gender whom he wants to send notifications
 * @param {string[]} userIds All community members user ids
 * @returns Array/List of all gender specific member ids
 */
const getGenderSpecificUsersIds = async (gender, userIds) => {
  let genderSpecificUserIds;

  // Getting all community users
  if (gender === "all") {
    genderSpecificUserIds = userIds;
  } else {
    // Getting female users (as well as other users ids except male)
    // Getting male users (as well as other users ids except female)
    genderSpecificUserIds = await getUsersIdsWithGender(gender, userIds);
  }

  return genderSpecificUserIds;
};

/**
 * Invoke method to get gender specific members ids from all community members ids
 * @param {string} gender Admin selected gender whom he wants to send notifications
 * @param {string[]} userIds All community members user ids
 * @returns Array/List of all gender specific member ids
 */
const getUsersIdsWithGender = async (gender, usersIds) => {
  // Breaking userIds whole list/array into chunk of 10 10
  const chunkedTenUsersIdsLists = utils.chunkArray(usersIds, 10);
  // Declaring promises list for chunked users array
  const chunkedTenUserIdsPromisesLists = [];
  // List gonna contain all users fcm tokens
  const genderSpecificUsersIds = [];

  // Iterating over all chunked user array promises list
  for (const chunkedTenUsersIdsList of chunkedTenUsersIdsLists) {
    //  Where in clause only allows 10 ids at a time
    chunkedTenUserIdsPromisesLists.push(
      db
        .collection("users")
        .where("uid", "in", chunkedTenUsersIdsList)
        .where("gender", "!=", gender === "male" ? "female" : "male")
        .get()
    );
  }

  // Getting all users with data in chunked users lists
  const chunkedUsersLists = await Promise.all(chunkedTenUserIdsPromisesLists);
  if (!chunkedUsersLists) return [];

  chunkedUsersLists.forEach((chunkedUsersList) => {
    chunkedUsersList.forEach((user) => {
      genderSpecificUsersIds.push(user.data().uid);
    });
  });

  return genderSpecificUsersIds;
};

module.exports = {
  updateUserByFields,
  getAllUsers,
  updateUserProfileInChatrooms,
  getUserById,
  getUserFcmById,
  getBotUsers,
  getMultipleUsersTokens,
  getAllGenderSpecificMembersIds,
  getGenderSpecificUsersIds,
};
