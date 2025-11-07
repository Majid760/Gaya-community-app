///
/// This class creates a bot user with a random profile data
/// It only contains creation methods only.
///

const admin = require('firebase-admin');
const profileGen = require('../../scripts/bots/generator/profile_generator.js');
const auth = require('./services/auth/auth.js')

const generateProfiles = () => { 

    const tempArr = []

    const total = 10; // Total number of bots to be created
    const bioPercentage = 0.4; // 40% of bots will have bio - 60% will not have bio
    const avatarPercentage = 0.5; // 50% of bots will have avatar - 50% will not have avatar
    const genderFemalePercentage = 0.6; // 60% Female profiles - out of 100%
    const genderMalePercentage = 0.2; // 20% Male profiles -  out of 100%
    const genderNBPercentage = 0.2; // 20% Non Binary profiles - out of 100%
    const interestsPercentage = 0.6; // 60% of bots will have interests - 40% will not have interests

    for (let i = 0; i < total; i++) {
        const email = `bot${i}@gaya.app`;
        const password = `bot${i}gaya!`;

        // Determine gender on basis of percentage
        const gender = __getGender(i, total, genderFemalePercentage, genderMalePercentage, genderNBPercentage)
        
        // Determine bio presence based on percentage
        const hasBio = i < total * bioPercentage;

        // Determine avatar presence based on percentage
        const hasAvatar = i < total * avatarPercentage;

        // Determine interests presence based on percentage
        const hasInterests = i < total * interestsPercentage;

        // creating user.
        createUserWithEmailAndPass(email, password, gender, hasInterests, hasBio, hasAvatar);

        /// Pushing data into temp array for logging purpose
        tempArr.push({
            "email" : email,
            "password" : password,
            "gender" : gender,
            "hasInterests" : hasInterests,
            "hasBio" : hasBio,
            "hasAvatar" : hasAvatar
        })
    }

    /// Logging the data
    console.table(tempArr)

}


/**
 * Generates random profile data and creates a user with email and password
 * and stores it into firestore + auth
 * @param {string} email 
 * @param {string} password 
 * @returns {Promise<admin.auth.UserRecord>} authUser
 */
const createUserWithEmailAndPass = async (email, password, gender, hasInterests, hasBio, hasAvatar) => {

      
    let user = {};
    if (gender == 'male') {
        user = profileGen.generateMaleProfile(hasBio, hasInterests, false);
    } else if (gender == 'female') {
        user = profileGen.generateFemaleProfile(hasBio, hasInterests, false);
    } else {
        user = profileGen.generateNBProfile(hasBio, hasInterests, false);
    }
    user.email = email;
    user.password = password;
     return await auth.createAppUser(user);
};


// Generates gender based on percentage.
const __getGender = (index, total, genderFemalePercentage, genderMalePercentage, genderNBPercentage) => {
    const femaleCount = Math.floor(total * genderFemalePercentage);
    const maleCount = Math.floor(total * genderMalePercentage);
    const nbCount = Math.floor(total * genderNBPercentage);
  
    if (index < femaleCount) {
      return 'female';
    } else if (index < femaleCount + maleCount) {
      return 'male';
    } else if (index < femaleCount + maleCount + nbCount) {
      return 'nb';
    }
  
    // Default to 'female' if the index exceeds the total count based on the provided percentages
    return 'female';
  };

module.exports = {
    createUserWithEmailAndPass,
    generateProfiles
}