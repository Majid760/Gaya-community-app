const services = require('./services.js');



/// calculateAndResetUsersActivities() test for local
const testPubsubLocally = async() => {
    await services.calculateAndResetUsersActivities();
}


module.exports = {
    testPubsubLocally
}