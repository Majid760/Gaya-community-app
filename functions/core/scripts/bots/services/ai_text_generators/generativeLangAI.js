const functions = require('firebase-functions');  
const { TextServiceClient } = require('@google-ai/generativelanguage');
const { GoogleAuth } = require('google-auth-library'); 
 
const MODEL = 'models/text-bison-001';


 

class TextGenerator {
  constructor(options = {}) {
    this.temperature = options.temperature;
    this.topP = options.topP;
    this.topK = options.topK;
    this.maxOutputTokens = options.maxOutputTokens;
    this.candidateCount = options.candidateCount;
    this.instruction = options.instruction; 
    const auth = new GoogleAuth({
      scopes: [
        'https://www.googleapis.com/auth/userinfo.email',
        'https://www.googleapis.com/auth/generative-language',
      ],
    });
    this.client = new TextServiceClient({
      auth,
    });
  }

  async generate(prompt, options = {}) {
    const request = {
      prompt: {
        text: prompt,
      },
      model: this.model,
      ...options,
    };

    const [result] = await this.client.generateText(request);

    if (!result.candidates || !result.candidates.length) {
      throw new Error('No candidates returned from server.');
    }

    const candidates = result.candidates
      .map(candidate => candidate.output)
      .filter(output => !!output) || [];

    if (!candidates.length) {
      throw new Error('No candidates returned from server.');
    }

    return {
      candidates,
    };
  }
}

const generatePrompt = async (text)=>{
  const textGenerator = new TextGenerator({
    model: MODEL,
  });
  const prompt = createSummaryPrompt(text);

  const result = await textGenerator.generate(prompt);
  console.log(`Generated RESULT: ${result}`);
  console.log(`=====================`);
  console.log(`=====================`);
  console.log(`=====================`);
  console.log(`=====================`);
  console.log(`Generated RESULT: ${JSON.stringify(result)}`)
}

 

const createSummaryPrompt = (text, targetSummaryLength) => {
  if (!targetSummaryLength) {
    return `Summarize this text: "${text}"`;
  }
  return `Summarize this text in exactly ${targetSummaryLength} sentences: "${text}"`;
};

module.exports = {
  generatePrompt
}