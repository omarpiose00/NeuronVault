import axios from 'axios';

export async function askClaude(prompt) {
  const apiKey = process.env.ANTHROPIC_API_KEY;
  
  if (!apiKey) {
    throw new Error("API key Anthropic non configurata. Imposta ANTHROPIC_API_KEY nel file .env");
  }
  
  const url = 'https://api.anthropic.com/v1/messages';
  const headers = {
    'x-api-key': apiKey,
    'anthropic-version': '2023-06-01',
    'content-type': 'application/json',
  };
  
  const data = {
  model: "claude-3-opus-20240229",
  max_tokens: 900,
  messages: [{ role: "user", content: prompt }],
};
  
  try {
    const res = await axios.post(url, data, { headers });
    return res.data.content[0].text.trim();
  } catch (error) {
    console.error('Errore nella chiamata API Claude:', error.response?.data || error.message);
    throw new Error(`Errore Claude: ${error.response?.data?.error?.message || error.message}`);
  }
}

// Funzione sperimentale per Claude con immagini (richiede Claude 3)
export async function askClaudeWithImage(prompt, imageBase64, mimeType = 'image/jpeg') {
  const apiKey = process.env.ANTHROPIC_API_KEY;
  
  if (!apiKey) {
    throw new Error("API key Anthropic non configurata. Imposta ANTHROPIC_API_KEY nel file .env");
  }
  
  const url = 'https://api.anthropic.com/v1/messages';
  const headers = {
    'x-api-key': apiKey,
    'anthropic-version': '2023-06-01',
    'content-type': 'application/json',
  };
  
  const data = {
    model: 'claude-3-sonnet-20240229',
    max_tokens: 1000,
    messages: [
      {
        role: 'user',
        content: [
          {
            type: 'image',
            source: {
              type: 'base64',
              media_type: mimeType,
              data: imageBase64
            }
          },
          {
            type: 'text',
            text: prompt
          }
        ]
      }
    ]
  };
  
  try {
    const res = await axios.post(url, data, { headers });
    return res.data.content[0].text.trim();
  } catch (error) {
    console.error('Errore nella chiamata API Claude con immagine:', error.response?.data || error.message);
    throw new Error(`Errore Claude: ${error.response?.data?.error?.message || error.message}`);
  }
}