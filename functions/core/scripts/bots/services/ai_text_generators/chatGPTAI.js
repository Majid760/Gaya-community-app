const axios = require("axios");
const apiKey = require("./../../../../../config/keys.js").OPENAI_API_KEY;


async function generateComment(postContent) {
    // Refine the prompt to include requirements
    const prompt = `Write a comment that is appealing, interesting, on point, and fun for teenagers. Original post: ${postContent}`;

    const data = {
        'prompt': prompt,
        'max_tokens': 60, // adjust this to limit the output size
        'temperature': 0.6
    };

    const config = {
        headers: {
            'Authorization': `Bearer ${apiKey}`,
            'Content-Type': 'application/json'
        }
    };

    const response = await axios.post('https://api.openai.com/v1/engines/davinci-codex/completions', data, config);

    // Return the first generated message
    return response.data.choices[0].text.trim();
}

module.exports = generateComment