
const compliments = require('./../../../.././utils/string_generator.js').complimentsTypes


const complimentGenerator = () => { 
    const compliment = compliments[Math.floor(Math.random() * compliments.length)];
    return compliment;
}

module.exports = complimentGenerator;