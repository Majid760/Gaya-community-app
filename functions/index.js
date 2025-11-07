const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");
const { getMessaging } = require("firebase-admin/messaging");
admin.initializeApp();
const db = admin.firestore();
const fieldValue = admin.firestore.FieldValue;
const deleteField = admin.firestore.deleteField;
const moment = require("moment");
const alogliaServices = require("./core/aloglia/algolia_services");
const algoliaScripts = require("./core/aloglia/scripts");
const connectyCubeServices = require("./core/connecty_cube");
const engagementServices = require("./core/firestore/user_engagement/services.js");
const communityServices = require("./core/firestore/common/community_services.js");
const communityValidator = require("./core/validations/validators/community_validator.js");
const communityScripts = require("./core/scripts/community/community_scripts.js");
const userServices = require("./core/firestore/common/user_services.js");
const notificationHelper = require("./core/notifications/notificationHelper.js");

const postServices = require("./core/firestore/common/post_services.js");
const autoLiker = require("./core/scripts/bots/auto_liker.js");
const generateAIBot = require("./core/scripts/bots/create_bots.js");
const fcmServices =
  require("./core/notifications/fcm_services").sendBulkNotificationWithPayload;
const adminService = require("./core/firestore/common/admin_services");

const utils = require("./utils/methods.js");
const crownServices = require("./core/firestore/common/crown_services.js");

const autoLikerTaskManagement = require("./core/scripts/bots/auto_liker_task_management.js");

/********************************************************************************************
                                 DUMMY TEST FUNCTIONS
*********************************************************************************************/
// Testable Https function
exports.testFunction = functions
  .runWith({
    timeoutSeconds: 540,
    memory: "8GB",
  })
  .https.onRequest(async (req, res) => {
    try {
      // for(let i=7; i<=14; i++){
      //     const email = "bot+"+ i.toString()+ "@gaya.app"
      //     const password = "Bot" + i.toString() + "gaya!";
      //     try{
      //         await generateAIBot.createUserWithEmailAndPass(email, password);
      //     }catch(_){
      //         console.log(_);
      //     }

      // }

      // const postId = "6ea233a0-0b7f-11ee-ac40-c599e6f0749e";
      // await generateAIBot.createUserWithEmailAndPass(email, password);
      // await autoLiker.likeAPost(postId);
      res.send({ message: "success" });
      const postId = "874a7d90-0d1e-11ee-8b9e-ab46a40549be";
      //    await autoLiker.crownAPost(postId, 1)
      // await crownServices.giveCrownToPostAndUser(postId,   "zeudqGtXrSPSdb03bOl8ZaBf8zs1");
      // await generateAIBot.createUserWithEmailAndPass(email, password);
      //   await autoLiker.likeAPost(postId)

      /// generate random comments
      //  await autoLiker.commentsOnAPost(postId,2)
      res.send({ message: "Executed successfully" });
    } catch (_) {
      console.log(_);
      res.send("something went wrong" + _);
    }
  });

/********************************************************************************************
                                 CLOUD TASK FUNCTIONS - ENQUEUE DEQUEUE
*********************************************************************************************/
/**
 * Cloud Task - Dispatch post for reaction after random delay of 1-30 seconds
 *
 * @param {String} postId - post id
 * @returns {Object} - {result: String}
 */
exports.autoLikeCloudTaskQueue = functions
  .runWith({ timeoutSeconds: 540, memory: "1GB" })
  .tasks.taskQueue()
  .onDispatch(async (data) => {
    return await autoLikerTaskManagement.validateAndDispatchPostReaction(data);
  });

/********************************************************************************************
                                   PUB SUB FUNCTIONS
*********************************************************************************************/

/// CROWN RELATED FUNCTIONS
// Daily Scheduler to send 3 crowns to all users
exports.resetCreditsForFreeUsers = functions.pubsub
  .schedule("0 */3 * * *")
  .onRun(async (context) => {
    await resetAndAddDailyFreeCrowns(3, false);
    return {
      statusCode: 200,
      status: true,
      message:
        "Crown reset successfully and " + 3 + " crowns added to all users.",
    };
  });

/// Post Score Related Functions
// Daily Scheduler to reset post score to 0
exports.resetPostScore = functions.pubsub
  .schedule("0 0 * * *")
  .onRun(async (context) => {
    await engagementServices.calculateAndResetUsersActivities();
    functions.logger.info("Daily Post score reset successfully.");
    return {
      statusCode: 200,
      status: true,
      message: "Post score reset successfully.",
    };
  });

/** 
/// Manages the isInFeed field in communityposts collection
/// Runs every 24 hours
exports.manageIsInFeedPosts = functions.pubsub
  .schedule("0 0 * * *")
  .onRun(async (context) => {
    postServices.removeIsInFeedIntoPosts();
    postServices.addIsInFeedIntoPosts();
    functions.logger.info("Daily Sort FeedInPost ran successfully.");
    return {
      statusCode: 200,
      status: true,
      message: "Daily Sort FeedInPost ran successfully.",
    };
  });

/********************************************************************************************
                                   CALLABLE FUNCTIONS
*********************************************************************************************/

/**
 * Get Timestamp from server
 * @returns {Object} - {timestamp: number, status: boolean}
 * */
exports.getServerTimeStamp = functions.https.onCall((data, context) => {
  const body = { timestamp: new Date().getTime().toString(), status: true };
  return body;
});

/**
 * Callable function to send broadcast notification via admin
 */
exports.sendBroadcastNotification = functions.https.onCall(async (req, res) => {
  // Sending broadcast/multicast notification via admin
  adminService.sendBroadcastNotificationByAdmin(req);
});

// callable function to give crown to post
exports.giveCrownToPost = functions.https.onCall(async (req, res) => {
  const postId = req.postId;
  const userId = req.userId;
  const recieverUserId = req.recieverUserId;
  // console.log('postId is:', postId);
  try {
    // check and deduct crown from crown giving user
    const isCrownDeducted = await checkAndDeductUserCrown(userId);
    // if crown is deducted then give crown to post and user
    if (isCrownDeducted == true) {
      const response = await giveCrownToCommunityPost(postId, userId);
      if (response == true) {
        await giveCrownToUser(recieverUserId);
        return {
          statusCode: 200,
          status: true,
          message: "Crown given successfully.",
        };
      }
    }
    /// if crown is not deducted then return error message
    return {
      statusCode: 501,
      status: false,
      message: "You don't have enough crowns to give.",
    };
  } catch (error) {
    functions.logger.error(error);
    return { statusCode: 400, status: false, message: error };
  }
});

// callable function to give crown to comment
exports.giveCrownToComment = functions.https.onCall(async (req, res) => {
  const postId = req.postId;
  const userId = req.userId;
  const recieverUserId = req.recieverUserId;
  const commentId = req.commentId;

  /// check if all required params are present
  if (!postId || !userId || !recieverUserId || !commentId) {
    if (!postId) {
      return { statusCode: 400, status: false, message: "postId is required." };
    } else if (!userId) {
      return { statusCode: 400, status: false, message: "userId is required." };
    } else if (!recieverUserId) {
      return {
        statusCode: 400,
        status: false,
        message: "recieverUserId is required.",
      };
    } else if (!commentId) {
      return {
        statusCode: 400,
        status: false,
        message: "commentId is required.",
      };
    }
    return { statusCode: 400, status: false, message: "Invalid request." };
  }
  try {
    // check and deduct crown from crown giving user
    const isCrownDeducted = await checkAndDeductUserCrown(userId);
    // if crown is deducted then give crown to post and user
    if (isCrownDeducted == true) {
      await giveCrownToAComment(postId, commentId, userId);
      await giveCrownToUser(recieverUserId);
      return {
        statusCode: 200,
        status: true,
        message: "Crown given to comment successfully.",
      };
    }
    /// if crown is not deducted then return error message
    return {
      statusCode: 501,
      status: false,
      message: "You don't have enough crowns to give.",
    };
  } catch (error) {
    functions.logger.error(error);
    return { statusCode: 400, status: false, message: error };
  }
});

/// callable function to give crown to comment
exports.giveCrownToReplyComment = functions.https.onCall(async (req, res) => {
  const postId = req.postId;
  const userId = req.userId;
  const recieverUserId = req.recieverUserId;
  const commentId = req.commentId;
  const replyCommentId = req.replyCommentId;

  /// check if all required params are present
  if (!postId || !userId || !recieverUserId || !commentId || !replyCommentId) {
    /// returns a missing field names
    if (!postId) {
      return { statusCode: 400, status: false, message: "postId is missing." };
    } else if (!userId) {
      return { statusCode: 400, status: false, message: "userId is missing." };
    } else if (!recieverUserId) {
      return {
        statusCode: 400,
        status: false,
        message: "recieverUserId is missing.",
      };
    } else if (!commentId) {
      return {
        statusCode: 400,
        status: false,
        message: "commentId is missing.",
      };
    } else if (!replyCommentId) {
      return {
        statusCode: 400,
        status: false,
        message: "replyCommentId is missing.",
      };
    }

    return { statusCode: 400, status: false, message: "Invalid request." };
  }

  try {
    // check and deduct crown from crown giving user
    const isCrownDeducted = await checkAndDeductUserCrown(userId);
    // if crown is deducted then give crown to post and user
    if (isCrownDeducted == true) {
      await giveCrownToAReplyComment(postId, commentId, replyCommentId, userId);
      await giveCrownToUser(recieverUserId);
      return {
        statusCode: 200,
        status: true,
        message: "Crown given to comment reply successfully.",
      };
    }
    /// if crown is not deducted then return error message
    return {
      statusCode: 501,
      status: false,
      message: "You don't have enough crowns to give.",
    };
  } catch (error) {
    functions.logger.error(error);
    return { statusCode: 400, status: false, message: error };
  }
});

/********************************************************************************************
                               Triggers FUNCTIONS
*********************************************************************************************/

/// USER RELATED FUNCTIONS

// On Auth user created - in firebase auth
exports.onAuthUserCreated = functions.auth.user().onCreate(async (user) => {
  try {
    const uid = user.uid;
    const res = await axios.post(
      "https://api-prod-ws7ku6426a-nw.a.run.app/api/users?apiKey=cV4vB2RkcJYaASzfyBU4",
      {
        uid: uid,
      }
    );
    if (res.data.failed) {
      functions.logger.error(res.data.message);
      return new Error(res.data.message);
    } else {
      functions.logger.info(res.data.message);
      return res.data.message;
    }
  } catch (error) {
    functions.logger.error(error);
    return new Error(error);
  }
});

/**
 * Send Crown Airdrop by user id
 * @param {String} userId - user id
 * @param {Number} crowns - number of crowns to add
 * @param {Boolean} shouldNotify - send notification to user or not by default true
 * */

const sendCelebrationOf10kUsersNotificationByToken = async (token, userId) => {
  /// if token is not present then get token from firestore
  if (!token) {
    const userToken = await getFcmToken(userId);
    token = userToken;
  }

  const dateTimeString = new Date().toISOString();
  const notificationObject = {
    sender_name: "מזל טוב 🥳",
    message: "קיבלת 11 כתרים מהצוות של Gaya👑 עכשיו תוכל להקים קהילה משלך😍",
    time: dateTimeString,
    type: "crownAirdrop",
    isRead: false,
    receiverUserID: "", // will be set in loop
    userImage:
      "https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/assets%2Fdownload%20(1).jpeg?alt=media&token=d0d4098e-a757-4f7e-a79a-ab47fcbb50a6",
  };
  const userRef = db
    .collection("users")
    .doc(userId)
    .collection("notifications")
    .add(notificationObject);

  const payload = {
    notification: {
      title: notificationObject.sender_name,
      body: notificationObject.message,
    },
  };

  if (!token) {
    await admin
      .messaging()
      .sendToDevice(token, payload)
      .then((response) => {
        console.log("Successfully sent message:", response);
      })
      .catch((error) => {
        console.log("Error sending message:", error);
      });
  }
};

const give10CrownsToAllUsers = async (uid) => {
  const rawUsers = await db.collection("users").get();
  rawUsers.docs.forEach(async (user) => {
    try {
      user.ref.set(
        { userTotalCrowns: fieldValue.increment(1) },
        { merge: true }
      );
    } catch (_) {
      user.ref.set({ userTotalCrowns: 1 }, { merge: true });
    }

    //  sendCelebrationOf10kUsersNotificationByToken(user.data().fm_token, user.id);
  });
};

// when user account is created - in firestore
exports.onUserAccountCreated = functions.firestore
  .document("users/{userId}")
  .onCreate(async (snap, context) => {
    const userData = snap.data();
    /// get user id
    const userId = context.params.userId;

    /// give newly created user a default of 3 crowns
    await snap.ref.set(
      {
        userDailyCrowns: 3,
        previousDayScore: 0,
        totalScore: 0,
        /// give 10 total crowns on celebration of 10,000 users
        userTotalCrowns: 11,
      },
      { merge: true }
    );

    console.log("triggered!!!!");
    /// algolia indexing
    if (
      userData.name == undefined ||
      userData.name == null ||
      userData.name == ""
    ) {
      console.log(" ouldnt create: this was data: ", userData);
      return {};
    } else {
      await connectyCubeServices.createUserInConnectyCube(userData);
      await alogliaServices.insertUserInIndex(userData);
      await engagementServices.insertUserIntoUserActivityCollection(userId);

      console.log("created! ", JSON.stringify(userData));
    }

    ///
    await sendCelebrationOf10kUsersNotificationByToken(
      userData.fm_token,
      userId
    );
    return {
      statusCode: 200,
      message: "User account created successfully.",
    };
  });

/// A friendship request is created
exports.onFriendshipRequestCreated = functions.firestore
  .document("friendship/{friendshipId}")
  .onCreate(async (snap, context) => {
    try {
      const friendship = snap.data();
      const modifiedFriendship = {
        fromUid: friendship.senderUid,
        toUid: friendship.Recieveruid,
        status: friendship.isaccepted ? "accepted" : "pending",
      };
      const res = await axios.post(
        `https://api-prod-ws7ku6426a-nw.a.run.app/api/friendships/migrate?apiKey=4MnDqFRLBGZDqxljDdSM8Rzfwcl2`,
        {
          ...modifiedFriendship,
        }
      );

      if (res.data.failed) {
        console.log("failed to migrate friendship: ", modifiedFriendship);
      } else {
        console.log("success migrating friendship: ", modifiedFriendship);
      }
      return res.data;
    } catch (error) {
      functions.logger.error(error);
      return new Error(error);
    }
  });

/// A friendship request is updated
exports.onFriendshipRequestUpdated = functions.firestore
  .document("friendship/{friendshipId}")
  .onUpdate(async (change, context) => {
    try {
      const friendship = change.after.data();
      const modifiedFriendship = {
        fromUid: friendship.senderUid,
        toUid: friendship.Recieveruid,
        status: friendship.isaccepted ? "accepted" : "pending",
      };
      const res = await axios.post(
        `https://api-prod-ws7ku6426a-nw.a.run.app/api/friendships/migrate?apiKey=4MnDqFRLBGZDqxljDdSM8Rzfwcl2`,
        {
          ...modifiedFriendship,
        }
      );

      if (res.data.failed) {
        console.log(
          "failed to migrate friendship update: ",
          modifiedFriendship
        );
      } else {
        console.log(
          "success migrating friendship update: ",
          modifiedFriendship
        );
      }
      return res.data;
    } catch (error) {
      functions.logger.error(error);
      return new Error(error);
    }
  });

/// When a user updates their profile
exports.onUserProfileUpdated = functions.firestore
  .document("users/{userId}")
  .onUpdate(async (change, context) => {
    try {
      const uid = context.params.userId;
      const data = change.after.data();
      const gender =
        data.gender === "male" ? 0 : data.gender === "female" ? 1 : 2;

      await alogliaServices.updateUserProfileInIndex(data);
      await connectyCubeServices.updateUsersInConnectyCube(data);
      // update user profile in chatrooms
      await userServices.updateUserProfileInChatrooms(data);

      // set bio to max 150 characters
      const res = await axios.put(
        `https://api-prod-ws7ku6426a-nw.a.run.app/api/users/${uid}?apiKey=cV4vB2RkcJYaASzfyBU4`,
        {
          bio: data.bio.substring(0, 150) ?? null,
          coverPhoto: data.coverphoto,
          displayName: data.name,
          gender: gender,
          dateOfBirth: data.dob ?? null,
          interests: data.interests ?? null,
          fcmToken: data.fm_token,
          photoURL: data.profilePic,
        }
      );

      if (res.data.failed) {
        functions.logger.error(res.data.message);
        return new Error(res.data.message);
      } else {
        functions.logger.info(res.data.message);
        return res.data.message;
      }
    } catch (error) {
      functions.logger.error(error);
      return new Error(error);
    }
  });

/// When a user deletes their account
exports.onUserDeleted = functions.firestore
  .document("users/{userId}")
  .onDelete(async (snap, context) => {
    const userId = context.params.userId;

    try {
      await alogliaServices.removeUserInIndex(userId);
      await connectyCubeServices.deleteUserInConnectyCube(userId);
    } catch (_) {
      functions.logger.error(_);
      console.log(_);
    }
    return { message: "User deleted successfully." };
  });

/// COMMUNITY RELATED FUNCTIONS

// when community is created
exports.onCommunityCreated = functions.firestore
  .document("communities/{communityId}")
  .onCreate(async (snap, context) => {
    try {
      const community = snap.data();
      community.createdOn = fieldValue.serverTimestamp();
      //validate cimmunity type
      community.type = communityValidator.validateCommunityType(community.type);

      /// admin is always a member of community
      community.totalmembers = 1;
      /// add community to algolia index
      await alogliaServices.insertCommunityInIndex(community);
      /// add new field to community of score - Temporary Solution
      await snap.ref.set({ score: 0, type: community.type }, { merge: true });
      return { message: "Community created successfully." };
    } catch (error) {
      console.log("Error occured at onCommunityCreated(): " + error);
      functions.logger.error(error);
      return new Error(error);
    }
  });

// when community is deleted
exports.onCommunityDeleted = functions.firestore
  .document("communities/{communityId}")
  .onDelete(async (snap, context) => {
    try {
      const communtiyId = context.params.communityId;
      await alogliaServices.removeCommunityInIndex(communtiyId);
      return { message: "Community deleted successfully." };
    } catch (error) {
      functions.logger.error(error);
      return new Error(error);
    }
  });

// when community profile is updated.
exports.onCommunityProfileUpdated = functions.firestore
  .document("communities/{communtyId}")
  .onUpdate(async (change, context) => {
    try {
      // get communityId
      const communityId = context.params.communtyId;
      // get old and new community name
      const oldCommunity = change.before.data();
      const newCommunity = change.after.data();

      const changedFields =
        communityValidator.validateCommunityProfileChangedFields(
          oldCommunity,
          newCommunity
        );

      /// check if community name is not null or undefined or empty
      if (!newCommunity.name) {
        // change.after.ref.update(changedFields);
        functions.logger.info(
          "Cant change community name as its empty.",
          communityId
        );
        return {
          statusCode: 400,
          status: true,
          message: "Cant change community name as its empty.",
        };
      }
      /// check if createdOn is not null or undefined or empty
      if (oldCommunity.createdOn !== newCommunity.createdOn) {
        ///replace createdOn of older community with the new one as we dont want it to be change it
        // change.after.ref.update({createdOn: oldCommunity.createdOn});
        functions.logger.info(
          "Cant change community createdOn as its empty.",
          communityId
        );
        functions.logger.info(
          "oldCommunity.createdOn: ",
          oldCommunity.createdOn,
          " newCommunity.createdOn: ",
          newCommunity.createdOn
        );
      }
      ///case where only total members count is changed
      if (oldCommunity.totalmembers !== newCommunity.totalmembers) {
        /// update community member count in algolia index
        await alogliaServices.updateCommunityMemberCountInIndex(
          communityId,
          newCommunity.totalmembers
        );
        functions.logger.info("Updated total Members for ", communityId);
      }

      if (changedFields) {
        console.log("changedFields: ", changedFields);

        /// update community changed fields in all posts
        await updateCommunityFieldsInAllPosts(communityId, changedFields);

        /// aloglia indexing -- only index public and private communities {never index secret communities}
        if (newCommunity.type == "Public" || newCommunity.type == "Private") {
          await alogliaServices.updateCommunityProfileInIndex(newCommunity);
        }
        functions.logger.info("Community name updated successfully.");
        return {
          statusCode: 200,
          status: true,
          message: "Community name updated successfully.",
        };
      } else {
        functions.logger.info("Community is same as before.", communityId);
        functions.logger.info(JSON.stringify(newCommunity));
        functions.logger.info(JSON.stringify(oldCommunity));
        return {
          statusCode: 200,
          status: true,
          message: "Community name is same as before.",
        };
      }
    } catch (error) {
      console.log("Error occured at onCommunityNameUpdated(): " + error);
      functions.logger.error(error);
      return new Error(error);
    }
  });

// when user joins community
exports.onCommunityJoined = functions.firestore
  .document("communities/{communtyId}/communityMembers/{userId}")
  .onCreate(async (snap, context) => {
    try {
      // get userId and communityId
      const userId = context.params.userId;
      const membership = snap.data();
      const communityId = context.params.communtyId;
      // get community profile to check if its private or public
      const community = await getCommunityProfile(communityId);

      // if community is public then add user to community members list and increament community member count by 1
      // and subscribe to community topic.
      if (membership.isAdmin == true || community.type == "Public") {
        // get total members count of community as int value
        const communityMemberCount = community.totalmembers;

        // update total members count in community, incase if NAN or null or undefined just set it to 1
        if (
          communityMemberCount == undefined ||
          communityMemberCount == null ||
          communityMemberCount == "" ||
          communityMemberCount == 0 ||
          communityMemberCount == NaN
        ) {
          community.totalmembers = 1;
          functions.logger.info(
            "increamenting community member count ",
            communityId
          );
          setCommunityMemberCount(communityId, community.totalmembers);
        } else {
          increamentCommunityMemberCount(communityId);
        }
        functions.logger.info(
          "increamenting community member count " +
            community.totalmembers +
            " communityId: " +
            communityId
        );
        // /// Update community member count in algolia index
        // await alogliaServices.updateCommunityMemberCountInIndex(communityId, community.totalmembers);
        // by default subscribe to topic when user joins community if community is private [public communities are not subscribed to]
        // if communinity memeber is less than 1000, automatically subscribe to topic
        // if (community.type == "Private" && communityMemberCount <= 1000) {
        if (communityMemberCount <= 1000) {
          await updateNotificationSubscription(userId, communityId, true);
        }

        /*
         * TODO:  Will have to de-normalize the data and store in algolia as algolia limit 10KB per record
         */
        /// aloglia indexing -- only index public and private communities {never index secret communities}
        // if (community.type == "Public") {

        //     await alogliaServices.insertCommunityMemberInIndex(userId, community.communityId);
        // }
      }
    } catch (error) {
      console.log("Error occured at onCommunityJoined(): " + error);
      functions.logger.error(error);
      return new Error(error);
    }
  });

// when user leaves community
exports.onCommunityLeft = functions.firestore
  .document("communities/{communtyId}/communityMembers/{userId}")
  .onDelete(async (snap, context) => {
    try {
      const membership = snap.data();
      // get userId and communityId
      const userId = context.params.userId;
      const communityId = context.params.communtyId;

      const community = await getCommunityProfile(communityId);
      /// if user is admin of community then choose another admin and assign him as admin
      if (membership.isAdmin == true) {
        await communityServices.assignRandomUserAsAdmin(communityId);
      }

      // update total members count in community, incase if NAN or null or undefined just set it to 1
      if (
        community.totalmembers == undefined ||
        community.totalmembers == null ||
        community.totalmembers == "" ||
        community.totalmembers == 0 ||
        community.totalmembers == NaN ||
        community.totalmembers == 1
      ) {
        community.totalmembers = 0;
        setCommunityMemberCount(communityId, community.totalmembers);
      } else {
        decreamentCommunityMemberCount(communityId);
      }
      functions.logger.info(
        "increamenting community member count " +
          community.totalmembers +
          " communityId: " +
          communityId
      );
      // //updat in algolia
      // await alogliaServices.updateCommunityMemberCountInIndex(communityId, community.totalmembers);

      // unsubscribe from topic when user leaves community
      await updateNotificationSubscription(userId, communityId, false);

      /*
       * TODO:  Will have to de-normalize the data and store in algolia as algolia limit 10KB per record
       */
      /// aloglia indexing -- only index public and private communities {never index secret communities}
      // if (community.type == "Public" || community.type == "Private") {

      //     await alogliaServices.removeCommunityMemberInIndex(userId, community.communityId);

      // }
      return { message: "onCommunityLeft executed succesfully" };
    } catch (error) {
      console.log("Error occured at onCommunityLeft(): " + error);
      functions.logger.error(error);
      return new Error(error);
    }
  });

// when community membership is updated.
exports.onMembershipUpdate = functions.firestore
  .document("communities/{communtyId}/communityMembers/{userId}")
  .onUpdate(async (snap, context) => {
    try {
      // get userId and communityId
      const userId = context.params.userId;
      const communityId = context.params.communtyId;

      const oldCommunity = snap.before.data();
      const newCommunity = snap.after.data();

      /// if user is not a member of community and now he is a member of community
      if (oldCommunity.isMember == false && newCommunity.isMember == true) {
        // get community profile
        const community = await getCommunityProfile(communityId);
        // get total members count of community as int value
        const communityMemberCount = community.totalmembers;

        // update total members count in community, incase if NAN or null or undefined just set it to 1
        if (
          communityMemberCount == undefined ||
          communityMemberCount == null ||
          communityMemberCount == "" ||
          communityMemberCount == 0 ||
          communityMemberCount == NaN
        ) {
          community.totalmembers = 1;
          functions.logger.info(
            "increamenting community member count By 1 => ",
            communityId
          );
          setCommunityMemberCount(communityId, community.totalmembers);
        } else {
          functions.logger.info(
            "increamenting community member count ",
            communityId
          );
          increamentCommunityMemberCount(communityId);
          // /// Update community member count in algolia index
          // await alogliaServices.updateCommunityMemberCountInIndex(communityId, community.totalmembers);
        }
        //  add this specific community in user's community list
        await addCommunityIdToUserCollection(communityId, userId);

        // by default subscribe to topic when user joins community
        // if communinity memeber is less than 1000, automatically subscribe to topic
        // if (community.type == "Private" && communityMemberCount <= 1000) {
        if (communityMemberCount <= 999) {
          if (community.adminUid != userId) {
            await updateNotificationSubscription(userId, communityId, true);
          }
        }
        /*
         * TODO:  Will have to de-normalize the data and store in algolia as algolia limit 10KB per record
         */
        /// aloglia indexing -- only index public and private communities {never index secret communities}
        // if (community.type == "Public" || community.type == "Private") {

        //     await alogliaServices.insertCommunityMemberInIndex(userId, community.communityId);
        // }
      }
      return { message: "onMembershipUpdate executed succesfully" };
    } catch (error) {
      console.log("Error occured at onCommunityJoined(): " + error);
      functions.logger.error(error);
      return new Error(error);
    }
  });

// when community post {{is created
exports.onCommunityPostCreated = functions.firestore
  .document("communityposts/{postId}")
  .onCreate(async (snap, context) => {
    try {
      const post = snap.data();
      const postId = context.params.postId;
      const payload = {
        lastPostCreatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };
      /// check if community type is not null, otherwise add it [case where some communities in post didnt had type field]
      if (!post.community.type) {
        const community = await getCommunityProfile(post.communityId);
        if (community) {
          post.community = community;
          payload.community = community;
        }
      }

      if (post.approve == true) {
        ///TODO : Remove from here and do it on client side after 1 - MONTH (13 MAY)

        try {
          await db
            .collection("communities")
            .doc(post.communityId)
            .update(payload);
        } catch (_) {
          await db
            .collection("communities")
            .doc(post.communityId)
            .set(payload, { merge: true });
        } finally {
          /// AUTO LIKER - Enqueue task to react
          autoLikerTaskManagement.enquePostForReaction(postId);

          /// INDEXING ONLY PUBLIC COMMUNITIES POSTS
          if (post.community.type == "Public") {
            /// Index into aloglia
            await alogliaServices.insertPostInIndex(post);
          } else {
            console.log(
              "Not indexing as community is not public, postId: ",
              postId
            );
          }

          // in either case, send notification
          await sendNotificationToCommunityMembersByFCM(post);
          functions.logger.info("onCommunityPostCreated executed succesfully");
          return { message: "onCommunityPostCreated executed succesfully" };
        }
      } else {
        functions.logger.info(
          "onCommunityPostCreated executed but post is not approved yet."
        );
        return { message: "onCommunityPostCreated executed succesfully" };
      }
    } catch (error) {
      functions.logger.error(error);
      return new Error(error);
    }
  });

// when community post is updated [ Most probably, when its approved by moderators/admins ]
exports.onCommunityPostUpdate = functions.firestore
  .document("communityposts/{postId}")
  .onUpdate(async (change, context) => {
    // Get an object representing the current document
    const newDoc = change.after.data();
    const postId = context.params.postId;
    // ...or the previous value before this update
    const previousDoc = change.before.data();
    
    // decrement -5 when valid post is deleted
    if(previousDoc.isDeleted == false && newDoc.isDeleted == true){
      const memberId = newDoc.memberId;
      if(memberId != null){
        try {
          await db
            .collection("userActivities")
            .doc(memberId)
            .set({
              deletePostScore: fieldValue.increment(-5),
            },{ merge: true });
        } catch (error) {
          console.log("Error occured at deletePost decrement score: " + error);
        }
      }
    }
    if (previousDoc.approve == false && newDoc.approve == true) {
      /// post has been approved now

      /// AUTO LIKER - Enqueue task to react
      autoLikerTaskManagement.enquePostForReaction(postId);

      /// send notification to community members
      await sendNotificationToCommunityMembersByFCM(newDoc);
      change.after.ref.set(
        { score: 0, approvedAt: admin.firestore.FieldValue.serverTimestamp() },
        { merge: true }
      );

      if (newDoc.community.type == "Public") {
        /// Index into aloglia
        await alogliaServices.insertPostInIndex(post);
      } else {
        console.log(
          "Not indexing as community is not public, postId: ",
          postId
        );
      }

      // await alogliaServices.insertPostInIndex(newDoc);
      return { message: "succesfully approved!" };
    }

    return { message: "nothing to do!" };
  });

/// when a comment is created on a post
exports.onPostCommentCreated = functions.firestore
  .document("communityposts/{postId}/comments/{commentId}")
  .onCreate(async (snap, context) => {
    const comment = snap.data();
    const postId = context.params.postId;
    const commentId = context.params.commentId;

    ///TODO : Remove from here and do it on client side after 1 - MONTH (13 MAY)
    return await snap.ref.set({ score: 0 }, { merge: true });
  });

/// Compliment related Functions

/// when a compliment is created
exports.onComplimentCreated = functions.firestore
  .document(
    "users/{userId}/compliments/{senderUid}/all_compliments/{complimentId}"
  )
  .onCreate(async (snap, context) => {
    const compliment = snap.data(); // compliment object - contains compliment type and compliment message, time
    const senderUid = compliment.senderUid; // the one who is giving compliment
    const userId = context.params.userId; // reciever uid - the one who is recieving compliment
    const complimentType = compliment.compliment;
    const metadata = {
      time: new Date().toISOString(),
    };

    // increment profile compliment score
    engagementServices.incrementProfileComplimentScore(userId);

    /// check if compliment type is valid
    if (complimentType) {
      return await notificationHelper.sendComplimentNotificationToUser(
        senderUid,
        userId,
        complimentType,
        metadata
      );
    }

  });

/// User Watch related Functions

/// when the user visits other's user profile
exports.onUserProfileWatchCreated = functions.firestore
  .document("userProfileWatches/{userProfileWatchesDocId}")
  .onCreate(async (snap, context) => {
    // user profile visit doc object
    const userProfileVisit = snap.data();
    const userWhoViewedProfileId = userProfileVisit.userWhoViewedProfileId; // the one who is viewing profile
    const userWhoseProfileViewedId = userProfileVisit.userWhoseProfileViewedId; // reciever uid - the one who is getting viewed
    const metadata = {
      time: new Date().toISOString(),
    };

    return await notificationHelper.sendProfileWatchNotificationToUser(
      userWhoViewedProfileId,
      userWhoseProfileViewedId,
      metadata
    );
  });

/********************************************************************************************
                                   UTILS FUNCTIONS
*********************************************************************************************/

/**
A function to send notification to a topic [required Post DocumentData]
* sends notification only if post is approved
* @param {DocumentData} post - post snapshot
*/
const sendNotificationToTopic = async (post) => {
  if (post.approve == true) {
    const topic = post.communityId;
    const community = post.community;
    const posterBy = post.postedBy;
    // navigation to community
    const messagePayload = {
      topic: topic, // add extra to know if its a groupNotification or multicast [if null its multicast -- client side.]
      senderProfilePicture: posterBy.profilePic,
      senderProfileUid: posterBy.uid,
      senderProfileName: posterBy.name,
      postId: post.postId,
      messageType: "post",
    };
    const messagePayloadString = JSON.stringify(messagePayload); // convert to string [as firebase only accepts string in payload]
    const messageBody = "New Post in " + community.name + " community.";
    const messageTitle = "New Post Alert";
    const message = {
      notification: {
        body: messageBody,
        title: messageTitle,
      },
      data: {
        click_action: "FLUTTER_NOTIFICATION_CLICK",
        sound: "default",
        body: messageBody, //Generic message
        title: messageTitle, // community Name
        priority: "high",
        payload: messagePayloadString,
      },
      android: {
        notification: { channel_id: "high_importance_channel" },
      },
      apns: {
        payload: {
          aps: { sound: "default" },
        },
      },
      topic: "/topics/" + topic,
    };

    getMessaging()
      .send(message)
      .then((response) => {
        // Response is a message ID string.
        console.log("Successfully sent message:", response);
      })
      .catch((error) => {
        console.log("Error sending message:", error);
      });
  } else {
    console.log("Post is not approved");
  }
};

/**
 * Get user profile from firestore by UID
 * @param {string} uid - user id
 */
const getUserProfile = async (uid) => {
  try {
    const user = await db.collection("users").doc(uid).get();
    return user.data();
  } catch (error) {
    console.log("Error occured at getUserProfile(): " + error);
    functions.logger.error(error);
    return new Error(error);
  }
};

/**
 * Add Community ID to user's community list
 * @param {string} uid - user id
 * @param {string} communityId - community id
 */
const addCommunityIdToUserCollection = async (uid, communityId) => {
  const userRef = db.collection("users").doc(uid);
  return await userRef
    .collection("communities")
    .doc(communityId)
    .set({ communityId: communityId }, { merge: true });
};
/**
 * Get community profile from firestore by communityId
 * @param {string} communityId - community id
 */
const getCommunityProfile = async (communityId) => {
  try {
    const community = await db.collection("communities").doc(communityId).get();
    return community.data();
  } catch (error) {
    functions.logger.error(error);
    return new Error(error);
  }
};

/**
 * get user FCM token from firestore by UID
 * @param {string} uid - user id
 */
const getFcmToken = async (uid) => {
  try {
    const user = await getUserProfile(uid);
    return user.fm_token;
  } catch (error) {
    functions.logger.error(error);
    return new Error(error);
  }
};

/**
 * Subscribe to topic
 * @param {string | string[]} uid - user id(s)
 * @param {string} topic - topic name ~ communityId
 * */
const subscribeToTopic = async (uid, topic) => {
  try {
    const fcmToken = await getFcmToken(uid);
    if (fcmToken) {
      getMessaging()
        .subscribeToTopic(fcmToken, topic)
        .then(function (response) {
          console.log("Successfully subscribed to topic:", response);
        })
        .catch(function (error) {
          console.log("Error subscribing to topic:", JSON.stringify(error));
        });
    }
  } catch (error) {
    console.log("Error occured at subscribeToTopic(): " + error);
    functions.logger.error(error);
    return new Error(error);
  }
};

/**
 * Unsubscribe from topic
 * @param {string} uid - user id
 * @param {string} topic - topic name ~ communityId
 * */
const unsubscribeFromTopic = async (uid, topic) => {
  try {
    const fcmToken = await getFcmToken(uid);
    if (fcmToken) {
      getMessaging()
        .unsubscribeFromTopic(fcmToken, topic)
        .then(function (response) {
          console.log("Successfully unsubscribed from topic:", response);
        })
        .catch(function (error) {
          console.log("Error unsubscribing from topic:", JSON.stringify(error));
        });
    }
  } catch (error) {
    console.log("Error occured at unsubscribeFromTopic(): " + error);
    functions.logger.error(error);
    return new Error(error);
  }
};

/**
 * Subscribe to topic in firestore
 * @param {string} uid - user id
 * @param {string} communityId - community id
 */
const subscribeToTopicFirestore = async (uid, communityId) => {
  // firestore operation, if document doesn't exist, create it with try catch
  try {
    await db
      .collection("communities")
      .doc(communityId)
      .collection("communityMembers")
      .doc(uid)
      .update({
        isNotificationEnabled: true,
      });
  } catch (_) {
    await db
      .collection("communities")
      .doc(communityId)
      .collection("communityMembers")
      .doc(uid)
      .set(
        {
          isNotificationEnabled: true,
        },
        { merge: true }
      );
  }
};

/**
 * unsubscribe from topic in firestore
 * @param {string} uid - user id
 * @param {string} communityId - community id
 */
const unsubscribeFromTopicFirestore = async (uid, communityId) => {
  try {
    await db
      .collection("communities")
      .doc(communityId)
      .collection("communityMembers")
      .doc(uid)
      .update({
        isNotificationEnabled: false,
      });
  } catch (error) {
    console.log("Error occured at unsubscribeFromTopicFirestore(): " + error);
    functions.logger.error(error);
    return new Error(error);
  }
};

/**
 *  Update notification subscription in firestore and FCM
 *
 * @param {String} uid
 * @param {String} communityId
 * @param {Boolean} shouldSubcribe
 */
const updateNotificationSubscription = async (
  uid,
  communityId,
  shouldSubcribe
) => {
  if (shouldSubcribe) {
    // subscribe to topic in FCM
    // await subscribeToTopic(uid, communityId);
    // subscribe to topic in firestore
    await subscribeToTopicFirestore(uid, communityId);
  } else {
    // unsubscribe from topic in FCM
    // await unsubscribeFromTopic(uid, communityId);
    // unsubscribe from topic in firestore
    await unsubscribeFromTopicFirestore(uid, communityId);
  }
};

//// Crowns related functions

/**
 * Try to parse int, if failed return 3
 */
const tryCrownsParseInt = (crowns) => {
  try {
    crowns = parseInt(crowns);
    if (isNaN(crowns)) {
      crowns = 3;
    }
    return crowns;
  } catch (error) {
    return 3;
  }
};

/**
 * Add crowns to users in firestore in user collection
 * @param {number} crowns - number of crowns to add
 * @param {boolean} shouldNotify - should notify users
 * @returns {boolean} - true if success
 * @returns {Error} - error if failed
 */
const resetAndAddDailyFreeCrowns = async (crowns, shouldNotify) => {
  try {
    const crownsToAdd = tryCrownsParseInt(crowns);
    const dateTimeString = new Date().toISOString();
    const users = await db
      .collection("users")
      .where("userDailyCrowns", "!=", 3)
      .get();
    const notificationObject = {
      sender_name: "Gaya Team",
      message: "You got " + crownsToAdd + " crowns, use them now!",
      time: dateTimeString,
      type: "crownAirdrop",
      isRead: false,
      receiverUserID: "", // will be set in loop
      userImage:
        "https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/images%2Fapp_images%2Fpurple_color.png?alt=media&token=ab3af66c-e156-4f8e-b606-92753628ae98",
    };
    // split users into chunks of 250
    // 250 = for notification add batch write limit
    // 250 = for crown add batch write limit
    const chunkedUsers = chunkArray(users.docs, 240);

    chunkedUsers.forEach(async (chunk) => {
      // loop through chunks in batch write
      const batch = db.batch();
      const chunkUserTokens = [];
      chunk.forEach((user) => {
        try {
          // add [crownToAdd] crowns to user
          batch.set(
            db.collection("users").doc(user.id),
            {
              userDailyCrowns: crownsToAdd,
            },
            { merge: true }
          );

          // set receiverUserID in notification object
          notificationObject.receiverUserID = user.id;

          // add notification to user
          batch.set(
            db
              .collection("users")
              .doc(user.id)
              .collection("notifications")
              .doc(),
            notificationObject
          );

          // add token to array for bulk notification
          if (user.data().fm_token) {
            chunkUserTokens.push(user.data().fm_token);
          }
        } catch (_) {
          console.log("Error occured at resetAndAddDailyFreeCrowns(): " + _);
        }
      });
      await batch.commit();
      // send bulk notification to all users in chunk
      if (shouldNotify && chunkUserTokens.length > 0) {
        await sendBulkNotification(
          chunkUserTokens,
          notificationObject.sender_name,
          notificationObject.message
        );
      }
    });

    return true;
  } catch (error) {
    functions.logger.error(error);
    return false;
  }
};

/**
 * Send Crown Airdrop by user id
 * @param {String} userId - user id
 * @param {Number} crowns - number of crowns to add
 * @param {Boolean} shouldNotify - send notification to user or not by default true
 * */
const resetAndAddDailyFreeCrownsByUserId = async (
  userId,
  crowns,
  shouldNotify
) => {
  try {
    const crownsToAdd = tryCrownsParseInt(crowns);
    console.log(
      "resetAndAddDailyFreeCrownsByUserId() called with userId: " +
        userId +
        " and crowns: " +
        crownsToAdd
    );
    // add [crownToAdd] crowns to user
    db.collection("users").doc(userId).set(
      {
        userDailyCrowns: crownsToAdd,
      },
      { merge: true }
    );

    const userData = await getUserProfile(userId);
    const notificationObject = {
      sender_name: "Gaya Team",
      message: "You got " + crownsToAdd + " crowns, use them now!",
      time: new Date().toISOString(),
      type: "crownAirdrop",
      isRead: false,
      receiverUserID: userId,
      userImage:
        "https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/images%2Fapp_images%2Fpurple_color.png?alt=media&token=ab3af66c-e156-4f8e-b606-92753628ae98",
    };
    await db
      .collection("users")
      .doc(userId)
      .collection("notifications")
      .add(notificationObject)
      .then((docRef) => {
        console.log("Notification added with id: " + docRef.id);
      });
    if (userData.fm_token && shouldNotify) {
      await sendBulkNotification(
        [userData.fm_token],
        notificationObject.sender_name,
        notificationObject.message
      );
    }

    return true;
  } catch (error) {
    functions.logger.error(error);
    console.log(
      "Error occured at resetAndAddDailyFreeCrownsByUserId(): " + error
    );
    return false;
  }
};

/**
 * Send Builk notification to all users in chunks of 500
 * @param {Array} tokens - array of tokens
 * @param {String} title - title of notification
 * @param {String} body - body of notification
 * */
const sendBulkNotification = async (tokens, title, body) => {
  try {
    const message = {
      notification: {
        title: title,
        body: body,
      },
      android: {
        notification: { channel_id: "high_importance_channel" },
      },
      apns: {
        payload: {
          aps: { sound: "default" },
        },
      },

      tokens: tokens,
    };
    const response = await getMessaging().sendMulticast(message);
    console.log("Successfully sent message:", response);
    return true;
  } catch (error) {
    console.log("Error sending message:", error);
    return false;
  }
};

// split array into 500 chunks
const chunkArray = (array, size) => {
  const chunked_arr = [];
  let index = 0;
  while (index < array.length) {
    chunked_arr.push(array.slice(index, size + index));
    index += size;
  }
  return chunked_arr;
};

/**
 * get current date time string
 * in formate of YYYY-MM-DD HH:mm:ss
 */
const getCurrentDateTimeString = () => {
  return new Date().getTime().toString();
};

/**
 * Give crown to community post in firestore by userId
 * @param {string} postId - post id
 * @param {string} userId - user id
 */
const giveCrownToCommunityPost = async (postId, userId) => {
  try {
    const response = await db
      .collection("communityposts")
      .doc(postId)
      .set(
        {
          crownsBy: fieldValue.arrayUnion(userId),
        },
        { merge: true }
      );

    return true;
  } catch (error) {
    console.log("Error occured at giveCrownToCommunityPost(): " + error);
    functions.logger.error(error);
    return new Error(error);
  }
};

/**
* Give crown to comment in firestore by userId
* @param {string} postId - post id
* @param {string} commentId - comment id
* @param {string} userId - user id

*/
const giveCrownToAComment = async (postId, commentId, userId) => {
  try {
    const response = await db
      .collection("communityposts")
      .doc(postId)
      .collection("comments")
      .doc(commentId)
      .collection("crownOnComment")
      .doc(userId)
      .set({
        userId: userId,
        crownCommentId: userId,
      });
    return true;
  } catch (error) {
    console.log("Error occured at giveCrownToCommunityPost(): " + error);
    functions.logger.error(error);
    return new Error(error);
  }
};

/**
* Give crown to comment in firestore by userId
* @param {string} postId - post id
* @param {string} commentId - comment id
* @param {string} replyCommentId - reply id
* @param {string} userId - user id

*/
const giveCrownToAReplyComment = async (
  postId,
  commentId,
  replyCommentId,
  userId
) => {
  try {
    const response = await db
      .collection("communityposts")
      .doc(postId)
      .collection("comments")
      .doc(commentId)
      .collection("replies")
      .doc(replyCommentId)
      .collection("crownOnComment")
      .doc(userId)
      .set({
        userId: userId,
        crownCommentId: userId,
      });

    return true;
  } catch (error) {
    console.log("Error occured at giveCrownToCommunityPost(): " + error);
    functions.logger.error(error);
    return new Error(error);
  }
};

/**
 * Check and Deduct crown from firestore user by userId
 * @param {string} userId - user id
 */
const checkAndDeductUserCrown = async (userId) => {
  try {
    const user = await db.collection("users").doc(userId).get();
    const userModel = user.data();

    if (userModel.userDailyCrowns == null) {
      return false;
    }

    var crownsCount = userModel.userDailyCrowns;

    if (crownsCount == 0 || crownsCount < 0) {
      return false;
    }
    crownsCount = crownsCount - 1;
    await db.collection("users").doc(userId).set(
      {
        userDailyCrowns: crownsCount,
      },
      { merge: true }
    );
    return true;
  } catch (error) {
    functions.logger.error(error);
    return false;
  }
};

/**
 * add crown to user in firestore by userId
 * @param {string} userId - user id
 */
const giveCrownToUser = async (userId) => {
  try {
    const user = await db.collection("users").doc(userId).get();
    const userModel = user.data();

    var crownsCount = userModel.userTotalCrowns;
    if (
      crownsCount == null ||
      crownsCount < 0 ||
      crownsCount == undefined ||
      crownsCount == NaN
    ) {
      crownsCount = 0;
    }
    crownsCount = crownsCount + 1;

    await db.collection("users").doc(userId).set(
      {
        userTotalCrowns: crownsCount,
      },
      { merge: true }
    );
    return true;
  } catch (error) {
    functions.logger.error(error);
    return false;
  }
};
/**
 * get all communities from firestore
 * update name of community in all posts of community
 **/
const syncAllCommuitiesNames = async () => {
  try {
    const communities = await db.collection("communities").get();
    communities.forEach(async (community) => {
      const communityModel = community.data();
      const communityId = community.id;
      const communityName = communityModel.name;
      await updateCommunityNameInAllPosts(communityId, communityName);
    });
  } catch (error) {
    console.log("Error occured at syncAllCommuitiesNames(): " + error);
    functions.logger.error(error);
    return new Error(error);
  }
};

/**
 * update name of community in all posts of community
 * @param {string} communityId - community Id
 * @param {JSON} payload - Fields to update
 **/
const updateCommunityFieldsInAllPosts = async (communityId, payload) => {
  try {
    /// if payload is empty return false
    if (Object.keys(payload).length == 0) {
      return false;
    }
    const posts = await db
      .collection("communityposts")
      .where("communityId", "==", communityId)
      .get();
    //add community string at start of payload keys
    const newPayload = {};
    Object.keys(payload).forEach((key) => {
      newPayload["community." + key] = payload[key];
    });

    // split users into chunks of 500
    const chunkedPosts = chunkArray(posts.docs, 499);

    chunkedPosts.forEach(async (chunk) => {
      // loop through chunks in batch write
      const batch = db.batch();
      chunk.forEach((post) => {
        try {
          const postRef = db.collection("communityposts").doc(post.id);
          batch.update(postRef, newPayload, { merge: true });
        } catch (_) {
          console.log(
            "Error occured at updateCommunityFieldsInAllPosts(): " + _
          );
        }
      });
      await batch.commit();
    });

    return true;
  } catch (error) {
    functions.logger.error(error);
    return false;
  }
};

/**
 * increament total member count of community
 * @param {string} communityId - community Id
 * @param {}
 */
const increamentCommunityMemberCount = async (communityId) => {
  try {
    await db
      .collection("communities")
      .doc(communityId)
      .update({
        totalmembers: fieldValue.increment(1),
      });
    return true;
  } catch (error) {
    functions.logger.error(error);
    return false;
  }
};
const decreamentCommunityMemberCount = async (communityId) => {
  try {
    await db
      .collection("communities")
      .doc(communityId)
      .update({
        totalmembers: fieldValue.increment(-1),
      });
    return true;
  } catch (error) {
    functions.logger.error(error);
    return false;
  }
};

const setCommunityMemberCount = async (communityId, count) => {
  try {
    await db.collection("communities").doc(communityId).set(
      {
        totalmembers: count,
      },
      { merge: true }
    );
    return true;
  } catch (error) {
    functions.logger.error(error);
    return false;
  }
};

/**
 * sync all communities total members count
 */
const syncAllCommunitiesTotalMembers = async () => {
  try {
    const communities = await db.collection("communities").get();
    communities.forEach(async (community) => {
      const communityModel = community.data();
      const communityId = community.id;
      const totalMembers = await getCommunityMembersCount(communityId);
      await setCommunityMemberCount(communityId, totalMembers);
      console.log(
        "total members of community " + communityId + " is " + totalMembers
      );
    });
  } catch (error) {
    console.log("Error occured at syncAllCommuitiesNames(): " + error);
    functions.logger.error(error);
    return new Error(error);
  }
};
/**
 * returns total members count of community
 */
const getCommunityMembersCount = async (communityId) => {
  try {
    const community = await db
      .collection("communities")
      .doc(communityId)
      .collection("communityMembers")
      .get();
    return community.size;
  } catch (error) {
    functions.logger.error(error);
    return 0;
  }
};

//////////////////// NOTIFICATIONS  FOR COMMUNITY ///////////////////////
const sendNotificationToCommunityMembersByFCM = async (post) => {
  if (post.approve == true) {
    const topic = post.communityId;
    const community = post.community;
    const posterBy = post.postedBy;
    // navigation to community
    const messagePayload = {
      topic: topic, // add extra to know if its a groupNotification or multicast [if null its multicast -- client side.]
      senderProfilePicture: posterBy.profilePic,
      senderProfileUid: posterBy.uid,
      senderProfileName: posterBy.name,
      postId: post.postId,
      messageType: "post",
    };
    const messagePayloadString = JSON.stringify(messagePayload); // convert to string [as firebase only accepts string in payload]
    const messageBody = "פורסם פוסט חדש ב " + community.name + ".";
    const messageTitle = "פוסט חדש!";
    const message = {
      notification: {
        body: messageBody,
        title: messageTitle,
      },
      data: {
        click_action: "FLUTTER_NOTIFICATION_CLICK",
        sound: "default",
        body: messageBody, //Generic message
        title: messageTitle, // community Name
        priority: "high",
        payload: messagePayloadString,
      },
      android: {
        notification: { channel_id: "high_importance_channel" },
      },
      apns: {
        payload: {
          aps: { sound: "default" },
        },
      },
    };

    //      <--------------------------  // send a notification via FCM -- New Post Alert--------------------------->
    const memberIds = await communityServices.getCommunitySubscribedMemberIds(
      post.communityId
    );
    // remove author user id from memberIds -- we dont want to send notification to author
    const index = memberIds.indexOf(post.postedBy.uid);
    if (index > -1) {
      memberIds.splice(index, 1);
    }

    const membersTokens = await getMembersTokens(memberIds);

    /// split into chunks of 499 and get tokens of each chunk 500 -- bcs firebase only allows 500 tokens in one batch
    // if membertokens are greater than 500 and make it chunks.
    const chunkedTokens = chunkArray(membersTokens, 499);

    chunkedTokens.forEach(async (chunk) => {
      // add each chunk of 499 tokens to message
      message.tokens = chunk;
      const response = await getMessaging().sendMulticast(message);
      console.log("Successfully sent message:", response);
    });

    //      <--------------------------  // ENDS here -- New Post Alert--------------------------->
  } else {
    console.log("Post is not approved");
  }
};
/// splits userIds into chunks of 10 for batch processing --- where in clause only allows 10 ids at a time.
/// returns tokens array.
const getMembersTokens = async (memberIds) => {
  const membersTokens = [];

  const chunkedMemberIds = chunkArray(memberIds, 10);
  for (const tenUsers of chunkedMemberIds) {
    //  where in clause only allows 10 ids at a time.
    const usersSnap = await db
      .collection("users")
      .where("uid", "in", tenUsers)
      .get();
    const batch = db.batch();
    usersSnap.forEach(async (user) => {
      try {
        const userModel = user.data();
        // if userModel.lastCommunityPostNotificationTime is less than 3 hours then dont send notification
        if (
          userModel.fm_token != null &&
          userModel.fm_token != undefined &&
          userModel.fm_token != "" &&
          canSendNotification(userModel.lastCommunityPostNotificationTime)
        ) {
          membersTokens.push(userModel.fm_token);
          const userRef = db.collection("users").doc(user.id);
          batch.update(userRef, {
            lastCommunityPostNotificationTime: fieldValue.serverTimestamp(),
          });
        }
      } catch (error) {
        console.log("Error occured at getMembersTokens(): " + error);
        functions.logger.error(error);
      }
    });
    await batch.commit();
  }
  return membersTokens;
};

/**
 * A function to tell if we can send notification to user or not based on last notification time received.
 * returns true if lastNotificationTime is null or undefined or empty string
 * else returns true if lastNotificationTime is greater than 6 hours
 * @param {Date?} lastPostAlerRecievedAt
 * @returns {Boolean}
 * */
const canSendNotification = (lastPostAlerRecievedAt) => {
  if (!lastPostAlerRecievedAt) return true;

  const currentTime = admin.firestore.Timestamp.now();
  const timeDifferenceInHours =
    (currentTime.toMillis() - lastPostAlerRecievedAt.toMillis()) /
    (1000 * 60 * 60);

  if (timeDifferenceInHours >= 6) {
    return true;
  }
  return false;
};
