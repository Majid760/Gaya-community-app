const validations = require('../validators/community_validator.js');

/**
 * This Class is used to test the community validator functions
 */


const testCommunityValidator = async () => {
    const oldCommunity = {
        name: "Test Community",
        description: "This is a test community",
        type: "Public",
        topics: ["Test", "Community"],
        totalmembers: 0,
    }

    const newCommunity = {
        name: "Test Community",
        description: "This is a test community",
        type: "Public",
        topics: ["Test", "Community"],
        totalmembers: 0,

    }
    ///case 0: No Change
    const map0 = validations.validateCommunityProfileChangedFields(oldCommunity, newCommunity);
    console.log("Test0: Expect No Change, Result-> " + JSON.stringify(map0));


    ///case 1: Name Change
   newCommunity.name = "Community";
   const map = validations.validateCommunityProfileChangedFields(oldCommunity, newCommunity);
    console.log("Test1: Expect Name, Result-> " + JSON.stringify(map));
   

    ///case 2: Name and Description Change
    newCommunity.description = "This is a test community 2";
    const map2 = validations.validateCommunityProfileChangedFields(oldCommunity, newCommunity);
    console.log("Test2:Description changed, expect Same as above, Result-> " + JSON.stringify(map2));


    ///case 3: Name, Description and Type Change
    newCommunity.type = "Private";
    const map3 = validations.validateCommunityProfileChangedFields(oldCommunity, newCommunity);
    console.log("Test3: Expect  Name, Description, Type, Result-> " + JSON.stringify(map3));
 

}

const testCommunityTypeValidator = async () => {

    ///case 0: No Change
    const type0 = validations.validateCommunityType("Public");
    console.log("Test0: Expect Public, Result-> " + type0 );


    ///case 1: Name Change
    const type1 = validations.validateCommunityType("ציבורי");
    console.log("Test1: Expect Public, Result-> " + type1);


    ///case 2: Name and Description Change
    const type2 = validations.validateCommunityType("פרטי");
    console.log("Test2: Expect Private, Result-> " + type2);


    ///case 3: Name, Description and Type Change

    const type3 = validations.validateCommunityType("סוֹד");
    console.log("Test3: Expect Secret, Result-> " + type3);


    ///case 4: Name, Description and Type Change

    const type4 = validations.validateCommunityType("secret");
    console.log("Test4: Expect Secret, Result-> " + type4);


    ///case 5: Name, Description and Type Change

    const type5 = validations.validateCommunityType("private");
    console.log("Test5: Expect Private, Result-> " + type5);


    ///case 6: Name, Description and Type Change

    const type6 = validations.validateCommunityType("public");
    console.log("Test6: Expect Public, Result-> " + type6);


    ///case 7: Name, Description and Type Change

    const type7 = validations.validateCommunityType("Private");

    console.log("Test7: Expect Private, Result-> " + type7);


    ///case 8: Name, Description and Type Change

    const type8 = validations.validateCommunityType("Public");
    console.log("Test8: Expect Public, Result-> " + type8);


    ///case 9: Name, Description and Type Change

    const type9 = validations.validateCommunityType("Secret");
    console.log("Test9: Expect Secret, Result-> " + type9);


    ///case 10: Name, Description and Type Change

   const type10 = validations.validateCommunityType("HIDDEN");
    console.log("Test10: Expect Private DefaultCase, Result-> " + type10);


    ///case 13: Name, Description and Type Change


}

module.exports = {testCommunityValidator,testCommunityTypeValidator}