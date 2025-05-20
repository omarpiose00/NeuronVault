import axios from "axios";

export async function askDeepSeek(prompt) {
  const apiKey = process.env.DEEPSEEK_API_KEY;
  
  if (!apiKey) {
    throw new Error("API key DeepSeek non configurata. Imposta DEEPSEEK_API_KEY nel file .env");
  }
  
  const url = "https://api.deepseek.com/v1/chat/completions";
  const headers = {
    "Authorization": `Bearer ${apiKey}`,
    "Content-Type": "application/json",
  };
  
  const data = {
    model: "deepseek-chat",
    messages: [{ role: "user", content: prompt }],
    max_tokens: 1000,
    temperature: 0.7,
  };
  
  try {
    const res = await axios.post(url, data, { headers });
    return res.data.choices[0].message.content.trim();
  } catch (error) {
    console.error('Errore nella chiamata API DeepSeek:', error.response?.data || error.message);
    throw new Error(`Errore DeepSeek: ${error.response?.data?.error?.message || error.message}`);
  }
}

// Per implementazioni future: streaming e altre funzionalità di DeepSeek