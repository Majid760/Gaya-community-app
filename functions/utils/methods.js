
const admin = require('firebase-admin');
const db = admin.firestore();
/*
* split array into 500 chunks
* @param {array} array
* @param {number} size
* @return {array} chunked array
*/
const chunkArray = (array, size) => {
    const chunked_arr = [];
    let index = 0;
    while (index < array.length) {
        chunked_arr.push(array.slice(index, size + index));
        index += size;
    }
    return chunked_arr;
}

/**
 * 
 * @param {num} min 
 * @param {num} max 
 * @returns  {num} random number between min and max
 */
const getRandomInt = (min, max) => {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}
/**
 * Add a asterisk to the specific word in a string
 * @param {string} str - string to be modified
 * @param {string} word - word to Highlight
 * @returns {string} modified string
 */
const addAsteriskToWord = (str, word) => {

    try {
        const modifiedStr = str.replace(
            new RegExp(`\\b${word}\\b`, "g"),
            `**$&**`
        );
        return modifiedStr;
    } catch (_) {
        console.log("Error occured at addAsteriskToWord(): ", _);
        return str;
    }

}

/**
 * Get current datetime in UTC
 * @returns {Date} current datetime in UTC
 */
const getDateTimeUTC = () => {
    const currentDatetimeUTC = new Date();
    const currentDatetimeUTCObj = new Date(currentDatetimeUTC.toISOString());
    return currentDatetimeUTCObj;
}

/**
 * Fetches current datetime
 * @returns {Date} current datetime
 */
const getCurrentDateTime = () => {
    const currentTime = new Date();
    return currentTime;
}

const getLast14DaysDateTime = () => {
    const currentTime = getCurrentDateTime();
    currentTime.setDate(currentTime.getDate() - 14);
    return currentTime;
}

const generateFirestoreDocId = () => {
    const documentRef = db.collection('users').doc();
    return documentRef.id;

}

/**
 * 
 * @param {int} ms - milliseconds to wait 
 * @returns 
 */
const waitAsync = (ms = 1000) => {
    return new Promise(resolve => {
        setTimeout(resolve, ms);
    });
}

/**
 * Generate AGE DateTime object
 * @param {int} age - age of the user
 */
const generateAgeDateTime = (age) => { 
    const ageDateTime = new Date();
    ageDateTime.setFullYear(ageDateTime.getFullYear() - age);
    return ageDateTime;
}


/**
 * Generates a random number between min and max
 * @param {int} min 
 * @param {int} max 
 * @returns 
 */
const generateRandomNumber = (min, max) => {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

module.exports = {
    chunkArray, getRandomInt, addAsteriskToWord, getDateTimeUTC, getCurrentDateTime, getLast14DaysDateTime,
    generateFirestoreDocId,
    waitAsync,
    generateAgeDateTime,
    generateRandomNumber,

}