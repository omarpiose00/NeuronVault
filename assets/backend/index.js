// assets/backend/index.js - versione aggiornata
import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { Server } from 'socket.io';
import http from 'http';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';

// Import dei nuovi moduli
import router from './ai-handlers/router.js';

// Configurazione ambiente
dotenv.config();
const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

// Configurazione middleware
app.use(cors());
app.use(express.json());

// Configurazione directory uploads
const __dirname = path.dirname(fileURLToPath(import.meta.url));
const uploadsDir = path.join(__dirname, 'uploads');

if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

// Configurazione multer per l'upload dei file
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadsDir);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  }
});

const fileFilter = (req, file, cb) => {
  const allowedTypes = (process.env.ALLOWED_FILE_TYPES || 'image/jpeg,image/png,image/gif').split(',');
  if (allowedTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error('Tipo di file non supportato'), false);
  }
};

const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: parseInt(process.env.MAX_FILE_SIZE || '10485760') // 10MB default
  }
});

// Memorizzazione delle conversazioni
const conversations = {};

// Inizializzazione dei modelli AI con le chiavi API dall'ambiente
router.initialize({
  'gpt': process.env.OPENAI_API_KEY,
  'claude': process.env.ANTHROPIC_API_KEY,
  'deepseek': process.env.DEEPSEEK_API_KEY,
  'gemini': process.env.GOOGLE_API_KEY,
  'mistral': process.env.MISTRAL_API_KEY,
  'ollama': process.env.OLLAMA_ENDPOINT || 'localhost:11434'
});

// Funzione di utility per il debug
function debug(message) {
  if (process.env.ENABLE_DEBUG_LOGS === 'true') {
    console.log(`[DEBUG] ${message}`);
  }
}

// Endpoint per il chat multi-agent
app.post("/multi-agent", async (req, res) => {
  const { prompt, conversationId = 'default', mode = 'chat', modelConfig = null } = req.body;

  if (!prompt || typeof prompt !== 'string' || prompt.trim() === '') {
    return res.status(400).json({ error: 'Prompt non valido' });
  }

  // Inizializza la conversazione se non esiste
  if (!conversations[conversationId]) {
    conversations[conversationId] = [];
  }

  // Aggiungi il messaggio dell'utente alla conversazione
  conversations[conversationId].push({
    agent: "user",
    message: prompt,
    timestamp: new Date().toISOString()
  });

  const socketId = req.headers['x-socket-id'];
  const socket = socketId ? io.sockets.sockets.get(socketId) : null;

  try {
    // Configurazione predefinita se non specificata
    const defaultConfig = {
      'gpt': true,
      'claude': true
    };

    // Usa la configurazione fornita o quella predefinita
    const config = modelConfig || defaultConfig;

    // Richiesta al router AI
    const request = {
      prompt,
      conversationId,
      modelConfig: config,
      mode
    };

    // Elabora la richiesta
    const result = await router.processRequest(request);

    // Aggiorna la conversazione
    if (result.conversation && result.conversation.length > 0) {
      for (const message of result.conversation) {
        // Aggiungi solo se non è già presente (evita duplicati)
        if (message.agent !== 'user' || message.message !== prompt) {
          conversations[conversationId].push(message);
        }
      }
    }

    // Rispondi con la conversazione aggiornata
    res.json({
      conversation: conversations[conversationId],
      responses: result.responses, // Include le singole risposte
      weights: router.getWeights(), // Include i pesi
    });
  } catch (e) {
    console.error('Errore durante l\'elaborazione:', e);

    // Formatta il messaggio di errore in modo più user-friendly
    let errorMessage = 'Si è verificato un errore sconosciuto';

    if (e.message) {
      if (e.message.includes('API key')) {
        errorMessage = 'Errore di configurazione API: chiave non valida';
      } else if (e.message.includes('quota') || e.message.includes('exceeded')) {
        errorMessage = 'Hai raggiunto il limite di utilizzo API. Controlla il tuo piano.';
      } else if (e.message.includes('rate limit')) {
        errorMessage = 'Troppe richieste. Riprova più tardi';
      } else if (e.code === 'ECONNREFUSED' || e.code === 'ENOTFOUND') {
        errorMessage = 'Impossibile connettersi al servizio AI';
      } else {
        // Utilizza un messaggio generico per altri errori
        errorMessage = "Problema di comunicazione con i servizi AI";
      }
    }

    // Aggiungi messaggio di errore alla conversazione
    conversations[conversationId].push({
      agent: "system",
      message: `Errore: ${errorMessage}`,
      timestamp: new Date().toISOString()
    });

    res.status(500).json({ conversation: conversations[conversationId] });
  }
});

// API per recuperare la conversazione
app.get("/multi-agent/conversation/:id", (req, res) => {
  const { id } = req.params;
  
  if (!conversations[id]) {
    return res.status(404).json({ error: 'Conversazione non trovata' });
  }
  
  res.json({ conversation: conversations[id] });
});

// API per eliminare una conversazione
app.delete("/multi-agent/conversation/:id", (req, res) => {
  const { id } = req.params;
  
  if (!conversations[id]) {
    return res.status(404).json({ error: 'Conversazione non trovata' });
  }
  
  delete conversations[id];
  res.json({ success: true, message: 'Conversazione eliminata' });
});

// Servi i file statici dalla cartella uploads
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Gestione connessione socket.io
io.on('connection', (socket) => {
  debug(`Nuovo client connesso: ${socket.id}`);
  
  socket.on('disconnect', () => {
    debug(`Client disconnesso: ${socket.id}`);
  });
});

// Avvio del server
const port = process.env.PORT || 4000;
server.listen(port, () => {
  console.log(`Backend Multi-AI pronto su http://localhost:${port}`);
  console.log(`Socket.IO attivo per aggiornamenti in tempo reale`);
});