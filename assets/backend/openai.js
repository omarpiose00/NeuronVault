import axios from 'axios';

export async function askOpenAI(prompt) {
  const apiKey = process.env.OPENAI_API_KEY;
  
  if (!apiKey) {
    throw new Error("API key OpenAI non configurata. Imposta OPENAI_API_KEY nel file .env");
  }
  
  const url = 'https://api.openai.com/v1/chat/completions';
  const headers = {
    'Authorization': `Bearer ${apiKey}`,
    'Content-Type': 'application/json',
  };
  
  const data = {
    model: 'gpt-4o',
    messages: [{ role: 'user', content: prompt }],
    max_tokens: 1000,
    temperature: 0.7,
  };
  
  try {
    const res = await axios.post(url, data, { headers });
    return res.data.choices[0].message.content.trim();
  } catch (error) {
    console.error('Errore nella chiamata API OpenAI:', error.response?.data || error.message);
    throw new Error(`Errore OpenAI: ${error.response?.data?.error?.message || error.message}`);
  }
}

export async function askOpenAIWithImage(prompt, imageBase64) {
  const apiKey = process.env.OPENAI_API_KEY;
  
  if (!apiKey) {
    throw new Error("API key OpenAI non configurata. Imposta OPENAI_API_KEY nel file .env");
  }
  
  const url = 'https://api.openai.com/v1/chat/completions';
  const headers = {
    'Authorization': `Bearer ${apiKey}`,
    'Content-Type': 'application/json',
  };
  
  const data = {
    model: 'gpt-4o',
    messages: [
      {
        role: 'user',
        content: [
          { type: 'text', text: prompt },
          {
            type: 'image_url',
            image_url: {
              url: `data:image/jpeg;base64,${imageBase64}`
            }
          }
        ]
      }
    ],
    max_tokens: 1000,
  };
  
  try {
    const res = await axios.post(url, data, { headers });
    return res.data.choices[0].message.content.trim();
  } catch (error) {
    console.error('Errore nella chiamata API OpenAI con immagine:', error.response?.data || error.message);
    throw new Error(`Errore OpenAI: ${error.response?.data?.error?.message || error.message}`);
  }
}

// Funzione per lo streaming delle risposte (per implementazioni future)
export async function streamOpenAI(prompt, callback) {
  const apiKey = process.env.OPENAI_API_KEY;
  
  if (!apiKey) {
    throw new Error("API key OpenAI non configurata. Imposta OPENAI_API_KEY nel file .env");
  }
  
  const url = 'https://api.openai.com/v1/chat/completions';
  const headers = {
    'Authorization': `Bearer ${apiKey}`,
    'Content-Type': 'application/json',
  };
  
  const data = {
    model: 'gpt-4o',
    messages: [{ role: 'user', content: prompt }],
    max_tokens: 1000,
    temperature: 0.7,
    stream: true,
  };
  
  try {
    const response = await axios.post(url, data, { 
      headers,
      responseType: 'stream'
    });
    
    response.data.on('data', (chunk) => {
      const lines = chunk.toString().split('\n').filter(line => line.trim() !== '');
      for (const line of lines) {
        if (line.includes('[DONE]')) {
          callback(null, true); // Segnale di completamento
          return;
        }
        
        if (line.startsWith('data:')) {
          try {
            const jsonData = JSON.parse(line.substring(5).trim());
            const content = jsonData.choices[0]?.delta?.content;
            if (content) {
              callback(content, false);
            }
          } catch (e) {
            console.error('Errore nel parsing dello stream OpenAI:', e);
          }
        }
      }
    });
    
    response.data.on('end', () => {
      callback(null, true); // Segnale di completamento se non è stato ricevuto prima
    });
  } catch (error) {
    console.error('Errore nello stream OpenAI:', error);
    throw new Error(`Errore nello stream OpenAI: ${error.message}`);
  }
}