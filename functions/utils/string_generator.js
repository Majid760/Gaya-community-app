/// All Possible Compliments

//const complimentsSentences = [
//    "Someone thinks you're cool.",
//    "Someone thinks you have a positive vibe.",
//    "Someone thinks you're confident.",
//    "Someone thinks you're creative.",
//    "Someone thinks you're a leader.",
//    "Someone thinks you're stylish.",
//    "Someone thinks you're pleasant.",
//    "Someone thinks you're shining.",
//    "Someone thinks you're energetic.",
//    "Someone thinks you're unique.",
//    "Someone thinks you're friendly.",
//    "Someone thinks you're cheerful.",
//    "Someone finds you inspiring.",
//    "Someone finds you neat.",
//]
 const complimentsSentences = [
     "מישהו חושב שאתה מגניב!", // "Someone thinks you're cool!",
     "מישהו חושב שיש לך אווירה חיובית!", // "Someone thinks you have a positive vibe!",
     "מישהו חושב שיש לך בטחון עצמי!", // "Someone thinks you're confident!",
     "מישהו חושב שאתה יצירתי!",// "Someone thinks you're creative!",
     "מישהו חושב שאתה מנהיג!", // "Someone thinks you're a leader!",
     "מישהו חושב שיש לך סטייל!", //  "Someone thinks you're stylish!",
     "מישהו חושב שאתה אדם נעים!",// "Someone thinks you're pleasant!",
     "מישהו חושב שאתה מלא אור!",//  "Someone thinks you're shining!",
     "מישהו חושב שאתה אנרגטי!", // "Someone thinks you're energetic!",
     "מישהו חושב שאתה יחיד במינו!", // "Someone thinks you're unique!",
     "מישהו חושב שאתה חברותי!", //  "Someone thinks you're friendly!",
     "מישהו חושב שאתה מלא חיים!", // "Someone thinks you're cheerful!",
     "מישהו מוצא בך השראה!", //  "Someone finds you inspiring!",
     "מישהו חושב שאתה מתוקתק!", // "Someone finds you neat!",
 ]

/**
 * This makes a sentence out of a compliment type.
 * @param {string} complimentType - The type of the compliment A key basically. 
 * @returns 
 */
const getComplimentStringFromType = (type) => {
    switch (type) {
        case "cool":
            return complimentsSentences[0];
        case "positive":
            return complimentsSentences[1];
        case "confident":
            return complimentsSentences[2];
        case "creative":
            return complimentsSentences[3];
        case "leader":
            return complimentsSentences[4];
        case "stylish":
            return complimentsSentences[5];
        case "pleasant":
            return complimentsSentences[6];
        case "shining":
            return complimentsSentences[7];
        case "energetic":
            return complimentsSentences[8];
        case "unique":
            return complimentsSentences[9];
        case "friendly":
            return complimentsSentences[10];
        case "cheerful":
            return complimentsSentences[11];
        case "inspiring":
            return complimentsSentences[12];
        case "neat":
            return complimentsSentences[13];
        default:
            return complimentsSentences[0];
    }
}

const complimentsTypes = [
    "cool",
    "positive",
    "confident",
    "creative",
    "leader",
    "stylish",
    "pleasant",
    "shining",
    "energetic",
    "unique",
    "friendly",
    "cheerful",
    "inspiring",
    "neat",
]
module.exports = {
    getComplimentStringFromType, 
    complimentsTypes
}