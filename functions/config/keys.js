const functions = require('firebase-functions');

// Use Firebase Functions environment variables
const OPENAI_API_KEY = functions.config().openai?.api_key || process.env.OPENAI_API_KEY || "YOUR_OPENAI_API_KEY_HERE";

module.exports = {
    OPENAI_API_KEY
}