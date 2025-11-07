///
/// Auth Services for Creating a User
/// and storing it into firestore.
/// This contains all the methods for creating a user and DB operation for storing user.
///


const admin = require("firebase-admin");
const db = admin.firestore();


/**
 * create user with email and password and store it into firestore
 * @param {object} user - Map of user data
 * @returns {Promise<admin.auth.UserRecord>} authUser
 */
const createAppUser = async (user) => {

    /// creating auth user
    const authUser = await _createUserWithEmailAndPass(user.email, user.password, user.name, user.photoURL);
    user.uid = authUser.uid;

    /// storing auth user into firestore
    await _storeIntoFirestore(user);
    return authUser;
};


/**
 * @private - Create user with email and password
 * @param {string} email 
 * @param {string} password 
 * @param {string} name 
 * @param {string} photoURL 
 * @returns {Promise<admin.auth.UserRecord>} userdata
 */
const _createUserWithEmailAndPass = async (email, password, name, photoURL) => {
    return admin.auth().createUser({
        email: email,
        name: name,
        photoURL: photoURL,
        emailVerified: true,
        password: password,
        disabled: false,
    }).then((userRecord) => {
        console.log('Successfully created new user:', userRecord.uid);
        return userRecord;
    });
};

/**
 * @private - Store entry of user into firestore
 * @param {object} user - Map of user data
 * @returns  {Promise<admin.firestore.DocumentReference>} 
 */
const _storeIntoFirestore = async (user) => {
    console.log("Storing into firestore", user)
    return await db.collection("users").doc(user.uid).set(user);
};



module.exports = {
    createAppUser
}



