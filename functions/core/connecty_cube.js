const connectycube = require('connectycube');
const APP_ID = "7048";
const AUTH_KEY = "BxHaPKRRbT6cWP2";
const AUTH_SECRET = "MzAWjJAbfBNHQhF";
const admin = require('firebase-admin');
const db = admin.firestore();
connectycube.init({
    appId: APP_ID,
    authKey: AUTH_KEY,
    authSecret: AUTH_SECRET
});

/**
 * ONE TIME FUNCTION TO SHIFT USERS FROM FIREBASE TO CONNECTY CUBE
 * @returns {Promise<void>}
 */
const shiftUsersToConnectyCube = async () => {

 

    const allUsers = await db.collection("users").get();
    console.log("allUsers length", allUsers.size);

    allUsers.forEach(async (user) => {
        // await createUserInConnectyCube(user.data());
        await updateUsersInConnectyCube(user.data());
    });
    console.log("Executed Successfully");

}

 
/**
 * Create a user in connecty cube from firebase user
 * @param {Object} user -- user object from firebase (user.data())
 * @returns {Promise<void>}
 */
const createUserInConnectyCube = async (user) => {
    try {
        console.log("creating a user", user.email);
        const token = (await connectycube.createSession()).token
        const connectyCubeUser = {
            login: user.uid,
            password: user.uid,
            email: user.email,
            phone: user.phoneNumber,
            avatar: user.profilePic ?? '',
            full_name: user.name
        };
        console.log(connectyCubeUser)
        
        await connectycube.users.signup(connectyCubeUser);
        console.log("user created", user.email);
    } catch (_) {
        console.log("user error", _);
    }
}

/**
 * A function to update users in connecty cube
 * @param {Object} user - user object from firebase (user.data())
 * Updates only the following fields: full_name, avatar, phone
 */
const updateUsersInConnectyCube = async (user) => {
    try {
        const credetials =  {login: user.uid,
        password: user.uid, }
        console.log("updating a user", user.email);
         (await connectycube.createSession(credetials)).token
        const connectyCubeUser = {
            login: user.uid,
            password: user.uid, 
            phone: user.phoneNumber,
            avatar:  user.profilePic ?? '',
            full_name: user.name
        }; 
        const loggedUser =  await connectycube.users.update(connectyCubeUser)  
        
       
    } catch (_) {
        console.log("user error JSOn", JSON.stringify(_));
        console.log("user error", _);
    }
}

/**
 * A Function to to delete a user from connecty cube
 * @param {string} userId - user id  
 */
const deleteUserInConnectyCube = async (userId) => {
    try {
        const credetials =  {login: userId,
        password: userId } 
         (await connectycube.createSession(credetials)).token
        const connectyCubeUser = {
            login: userId,
            password: userId,  
        }; 
         await connectycube.users.delete(connectyCubeUser)  
        
       console.log("Succesfully deleted user from connecty cube :" , userId)
    } catch (_) {
        console.log("user error JSOn", JSON.stringify(_));
        console.log("user error", _);
    }
}
/// Path: functions/index.js
module.exports = {
    shiftUsersToConnectyCube,
    createUserInConnectyCube,
    deleteUserInConnectyCube,
    updateUsersInConnectyCube
}
