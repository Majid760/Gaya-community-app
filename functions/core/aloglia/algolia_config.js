const algoliasearch = require("algoliasearch");
const functions = require('firebase-functions');

// Use Firebase Functions environment variables
const APP_ID = functions.config().algolia?.app_id || process.env.ALGOLIA_APP_ID || "7V8WUJ2HVJ";
const APP_ADMIN_ID = functions.config().algolia?.admin_key || process.env.ALGOLIA_ADMIN_KEY || "3490c9dbbf8a98d57849c35259816523";

var client = algoliasearch(APP_ID, APP_ADMIN_ID);

const USER_INDEX = "users";
const COMMUNITY_INDEX = "community";
const POSTS_INDEX = "posts";
const COMMUNITY_MEMBERS = "community_members";

var userIndex = client.initIndex(USER_INDEX);
var communityIndex = client.initIndex(COMMUNITY_INDEX);
var postIndex = client.initIndex(POSTS_INDEX);
var communityMembersIndex = client.initIndex(COMMUNITY_MEMBERS);

 
module.exports = {
    userIndex,
    communityIndex,
    postIndex,
    communityMembersIndex, 
}