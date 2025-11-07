const communityTypePossibilies = {
    "ציבורי": "Public",
    "פרטי": "Private",
    "סוֹד": "Secret",
    'Public': 'Public',
    'Private': 'Private',
    'Secret' : 'Secret',
    'public': 'Public',
    'private': 'Private',
    'secret' : 'Secret',
}
/**
 * Validates changes to a community profile. Validates community type
 * @param {Object} oldCommunity - The original community profile.
 * @param {Object} newCommunity - The updated community profile.
 * @returns {Object} - A payload object containing only the changed fields.
 */
const validateCommunityProfileChangedFields = (oldCommunity, newCommunity) => {


    const oldCommunityName = oldCommunity.name;
    const newCommunityName = newCommunity.name;



    const oldCommunityType = oldCommunity.type;
    const newCommunityType = newCommunity.type;

    const payload = {};

    if (oldCommunityName !== newCommunityName) {
        payload.name = newCommunityName;
    }

    if (oldCommunityType !== newCommunityType) {
        payload.type =  validateCommunityType(newCommunityType);
    }

    return payload;
}


 /**
  * 
  * @param {String} type - Communtiy type [ציבורי, פרטי, סוֹד, Public, Private, Secret, public, private, secret] 
  * @returns {String} - A valid community type [Public, Private, Secret] otherwise by default Private
  */
const validateCommunityType = (type) => {
    
    type = communityTypePossibilies[type];
    if(type !== undefined){
        return type;
    }else{
        //// fallback community type
        return 'Private';
    }
}


module.exports = { validateCommunityProfileChangedFields, validateCommunityType }