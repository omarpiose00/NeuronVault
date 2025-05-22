// assets/backend/index.js - Convertito a CommonJS per consistenza
const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const { Server } = require('socket.io');
const http = require('http');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Import dei moduli AI
const router = require('./ai-handlers/router');

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
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Configurazione directory uploads
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
  const allowedTypes = (process.env.ALLOWED_FILE_TYPES || 'image/jpeg,image/png,image/gif,image/webp').split(',');
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

// Memorizzazione delle conversazioni con TTL
const conversations = new Map();
const CONVERSATION_TTL = 24 * 60 * 60 * 1000; // 24 ore

// Cleanup automatico delle conversazioni vecchie
setInterval(() => {
  const now = Date.now();
  for (const [id, conversation] of conversations.entries()) {
    if (now - conversation.lastActivity > CONVERSATION_TTL) {
      conversations.delete(id);
    }
  }
}, 60 * 60 * 1000); // Ogni ora

// Inizializzazione dei modelli AI con le chiavi API dall'ambiente
const initializeAI = () => {
  const apiKeys = {
    'openai': process.env.OPENAI_API_KEY,
    'anthropic': process.env.ANTHROPIC_API_KEY,
    'deepseek': process.env.DEEPSEEK_API_KEY,
    'google': process.env.GOOGLE_API_KEY,
    'mistral': process.env.MISTRAL_API_KEY,
    'ollama': process.env.OLLAMA_ENDPOINT || 'localhost:11434'
  };

  router.initialize(apiKeys);

  // Log delle API disponibili
  console.log('🤖 AI Models Status:');
  Object.keys(router.handlers).forEach(model => {
    const status = router.handlers[model].checkAvailability() ? '✅' : '❌';
    console.log(`   ${status} ${model.toUpperCase()}`);
  });
};

// Funzione di utility per il debug e logging
const logger = {
  info: (message, data = null) => {
    if (process.env.NODE_ENV !== 'test') {
      console.log(`[INFO] ${message}`, data ? JSON.stringify(data, null, 2) : '');
    }
  },
  error: (message, error = null) => {
    console.error(`[ERROR] ${message}`, error ? error.stack || error : '');
  },
  debug: (message, data = null) => {
    if (process.env.ENABLE_DEBUG_LOGS === 'true') {
      console.log(`[DEBUG] ${message}`, data ? JSON.stringify(data, null, 2) : '');
    }
  }
};

// Middleware per logging delle richieste
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    logger.info(`${req.method} ${req.url} - ${res.statusCode} (${duration}ms)`);
  });
  next();
});

// Middleware per gestione errori
const errorHandler = (err, req, res, next) => {
  logger.error('Unhandled error:', err);

  // Non esporre dettagli di errore in produzione
  const isDevelopment = process.env.NODE_ENV === 'development';

  res.status(err.status || 500).json({
    error: isDevelopment ? err.message : 'Errore interno del server',
    ...(isDevelopment && { stack: err.stack })
  });
};

// Endpoint principale per il chat multi-agent
app.post("/multi-agent", async (req, res) => {
  const startTime = Date.now();
  const { prompt, conversationId = 'default', mode = 'chat', modelConfig = null, customWeights = null } = req.body;

  // Validazione input
  if (!prompt || typeof prompt !== 'string' || prompt.trim() === '') {
    return res.status(400).json({
      error: 'Prompt richiesto e deve essere una stringa non vuota',
      code: 'INVALID_PROMPT'
    });
  }

  if (prompt.length > 10000) {
    return res.status(400).json({
      error: 'Prompt troppo lungo (massimo 10000 caratteri)',
      code: 'PROMPT_TOO_LONG'
    });
  }

  // Inizializza o recupera la conversazione
  if (!conversations.has(conversationId)) {
    conversations.set(conversationId, {
      messages: [],
      createdAt: Date.now(),
      lastActivity: Date.now()
    });
  }

  const conversation = conversations.get(conversationId);
  conversation.lastActivity = Date.now();

  // Aggiungi il messaggio dell'utente alla conversazione
  const userMessage = {
    agent: "user",
    message: prompt,
    timestamp: new Date().toISOString(),
    metadata: {
      mode,
      modelConfig: modelConfig || {},
      customWeights
    }
  };

  conversation.messages.push(userMessage);

  const socketId = req.headers['x-socket-id'];
  const socket = socketId ? io.sockets.sockets.get(socketId) : null;

  // Emetti evento di inizio elaborazione
  if (socket) {
    socket.emit('processing_started', { conversationId, prompt });
  }

  try {
    // Configurazione predefinita se non specificata
    const defaultConfig = {
      'gpt': true,
      'claude': true
    };

    // Usa la configurazione fornita o quella predefinita
    const config = modelConfig || defaultConfig;

    // Rate limiting semplice
    const userRequests = conversation.messages.filter(m =>
      m.agent === 'user' &&
      Date.now() - new Date(m.timestamp).getTime() < 60000 // ultimi 60 secondi
    );

    if (userRequests.length > 10) {
      return res.status(429).json({
        error: 'Troppi richieste. Attendere prima di inviare un nuovo messaggio.',
        code: 'RATE_LIMIT_EXCEEDED',
        retryAfter: 60
      });
    }

    // Richiesta al router AI
    const request = {
      prompt,
      conversationId,
      modelConfig: config,
      customWeights,
      mode,
      context: conversation.messages.slice(-5) // Ultimi 5 messaggi per context
    };

    logger.debug('Processing AI request', {
      conversationId,
      prompt: prompt.substring(0, 100) + '...',
      models: Object.keys(config).filter(k => config[k])
    });

    // Elabora la richiesta
    const result = await router.processRequest(request);

    if (result.error) {
      throw new Error(result.error);
    }

    // Aggiorna la conversazione con le nuove risposte
    if (result.conversation && result.conversation.length > 0) {
      // Filtra i messaggi per evitare duplicati dell'utente
      const newMessages = result.conversation.filter(msg =>
        msg.agent !== 'user' || msg.message !== prompt
      );

      conversation.messages.push(...newMessages);
    }

    const processingTime = Date.now() - startTime;

    // Emetti evento di completamento
    if (socket) {
      socket.emit('processing_completed', {
        conversationId,
        result,
        processingTime
      });
    }

    // Statistiche per monitoring
    const stats = {
      processingTime,
      modelsUsed: Object.keys(result.responses || {}),
      messageCount: conversation.messages.length,
      conversationAge: Date.now() - conversation.createdAt
    };

    logger.info('Request processed successfully', stats);

    // Rispondi con la conversazione aggiornata
    res.json({
      conversation: conversation.messages,
      responses: result.responses || {},
      weights: result.weights || {},
      synthesizedResponse: result.synthesizedResponse || '',
      metadata: {
        processingTime,
        modelsUsed: stats.modelsUsed,
        messageCount: stats.messageCount,
        mode
      }
    });

  } catch (error) {
    logger.error('Error during processing:', error);

    // Categorizza l'errore per una risposta più specifica
    let errorResponse = {
      conversation: conversation.messages,
      error: 'Errore durante l\'elaborazione della richiesta',
      code: 'PROCESSING_ERROR',
      processingTime: Date.now() - startTime
    };

    if (error.message) {
      if (error.message.includes('API key')) {
        errorResponse.error = 'Configurazione API non valida';
        errorResponse.code = 'API_KEY_ERROR';
      } else if (error.message.includes('quota') || error.message.includes('exceeded')) {
        errorResponse.error = 'Hai raggiunto il limite di utilizzo API';
        errorResponse.code = 'QUOTA_EXCEEDED';
      } else if (error.message.includes('rate limit')) {
        errorResponse.error = 'Troppe richieste. Riprova più tardi';
        errorResponse.code = 'RATE_LIMITED';
      } else if (error.code === 'ECONNREFUSED' || error.code === 'ENOTFOUND') {
        errorResponse.error = 'Impossibile connettersi ai servizi AI';
        errorResponse.code = 'CONNECTION_ERROR';
      }
    }

    // Aggiungi messaggio di errore alla conversazione
    const errorMessage = {
      agent: "system",
      message: `Errore: ${errorResponse.error}`,
      timestamp: new Date().toISOString(),
      metadata: {
        errorCode: errorResponse.code,
        originalError: error.message
      }
    };

    conversation.messages.push(errorMessage);

    // Emetti evento di errore
    if (socket) {
      socket.emit('processing_error', { conversationId, error: errorResponse });
    }

    res.status(500).json(errorResponse);
  }
});

// API per recuperare la conversazione
app.get("/multi-agent/conversation/:id", (req, res) => {
  const { id } = req.params;

  if (!conversations.has(id)) {
    return res.status(404).json({
      error: 'Conversazione non trovata',
      code: 'CONVERSATION_NOT_FOUND'
    });
  }

  const conversation = conversations.get(id);
  conversation.lastActivity = Date.now();

  res.json({
    conversation: conversation.messages,
    metadata: {
      messageCount: conversation.messages.length,
      createdAt: conversation.createdAt,
      lastActivity: conversation.lastActivity
    }
  });
});

// API per eliminare una conversazione
app.delete("/multi-agent/conversation/:id", (req, res) => {
  const { id } = req.params;

  if (!conversations.has(id)) {
    return res.status(404).json({
      error: 'Conversazione non trovata',
      code: 'CONVERSATION_NOT_FOUND'
    });
  }

  conversations.delete(id);

  logger.info(`Conversation deleted: ${id}`);

  res.json({
    success: true,
    message: 'Conversazione eliminata',
    conversationId: id
  });
});

// API per l'upload di immagini
app.post("/multi-agent/image", upload.single('image'), async (req, res) => {
  const { prompt, conversationId = 'default', modelConfig = null } = req.body;

  if (!req.file) {
    return res.status(400).json({
      error: 'Nessuna immagine caricata',
      code: 'NO_IMAGE_UPLOADED'
    });
  }

  if (!prompt || prompt.trim() === '') {
    return res.status(400).json({
      error: 'Prompt richiesto per l\'analisi dell\'immagine',
      code: 'PROMPT_REQUIRED'
    });
  }

  try {
    // Per ora, gestiamo solo l'analisi testuale dell'immagine
    // In futuro, integreremo con modelli vision
    const imageAnalysisPrompt = `Analizza questa immagine e rispondi alla seguente domanda: ${prompt}`;

    const request = {
      prompt: imageAnalysisPrompt,
      conversationId,
      modelConfig: modelConfig || { 'gpt': true, 'claude': true },
      mode: 'image_analysis',
      metadata: {
        imageFile: req.file.filename,
        imagePath: req.file.path,
        imageSize: req.file.size,
        mimeType: req.file.mimetype
      }
    };

    const result = await router.processRequest(request);

    res.json({
      conversation: result.conversation || [],
      responses: result.responses || {},
      imageUrl: `/uploads/${req.file.filename}`,
      metadata: {
        imageProcessed: true,
        fileName: req.file.filename,
        fileSize: req.file.size
      }
    });

  } catch (error) {
    logger.error('Error processing image:', error);

    // Rimuovi il file in caso di errore
    if (req.file && fs.existsSync(req.file.path)) {
      fs.unlinkSync(req.file.path);
    }

    res.status(500).json({
      error: 'Errore durante l\'elaborazione dell\'immagine',
      code: 'IMAGE_PROCESSING_ERROR'
    });
  }
});

// API per statistiche del sistema
app.get("/multi-agent/stats", (req, res) => {
  const stats = {
    activeConversations: conversations.size,
    totalHandlers: Object.keys(router.handlers).length,
    availableHandlers: Object.keys(router.handlers).filter(
      key => router.handlers[key].checkAvailability()
    ),
    systemUptime: process.uptime(),
    memoryUsage: process.memoryUsage(),
    timestamp: new Date().toISOString()
  };

  res.json(stats);
});

// API per la salute del sistema
app.get("/health", (req, res) => {
  const health = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    version: process.env.npm_package_version || '1.0.0',
    environment: process.env.NODE_ENV || 'development'
  };

  res.json(health);
});

// Servi i file statici dalla cartella uploads
app.use('/uploads', express.static(uploadsDir));

// Middleware per 404
app.use((req, res) => {
  res.status(404).json({
    error: 'Endpoint non trovato',
    code: 'ENDPOINT_NOT_FOUND',
    availableEndpoints: [
      'POST /multi-agent',
      'GET /multi-agent/conversation/:id',
      'DELETE /multi-agent/conversation/:id',
      'POST /multi-agent/image',
      'GET /multi-agent/stats',
      'GET /health'
    ]
  });
});

// Middleware per gestione errori (deve essere l'ultimo)
app.use(errorHandler);

// Gestione connessione socket.io
io.on('connection', (socket) => {
  logger.debug(`New client connected: ${socket.id}`);

  socket.on('join_conversation', (conversationId) => {
    socket.join(conversationId);
    logger.debug(`Client ${socket.id} joined conversation ${conversationId}`);
  });

  socket.on('leave_conversation', (conversationId) => {
    socket.leave(conversationId);
    logger.debug(`Client ${socket.id} left conversation ${conversationId}`);
  });

  socket.on('disconnect', () => {
    logger.debug(`Client disconnected: ${socket.id}`);
  });
});

// Gestione graceful shutdown
process.on('SIGTERM', () => {
  logger.info('SIGTERM received, shutting down gracefully');
  server.close(() => {
    logger.info('Server closed');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  logger.info('SIGINT received, shutting down gracefully');
  server.close(() => {
    logger.info('Server closed');
    process.exit(0);
  });
});

// Inizializzazione e avvio del server
const startServer = async () => {
  try {
    // Inizializza i modelli AI
    initializeAI();

    // Avvia il server
    const port = process.env.PORT || 4000;
    server.listen(port, () => {
      logger.info(`🚀 NeuronVault Backend started`);
      logger.info(`📍 Server: http://localhost:${port}`);
      logger.info(`🔌 Socket.IO: Active`);
      logger.info(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);

      if (process.env.NODE_ENV === 'development') {
        logger.info(`📊 Stats: http://localhost:${port}/multi-agent/stats`);
        logger.info(`❤️  Health: http://localhost:${port}/health`);
      }
    });

  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
};

// Avvia il server solo se non siamo in modalità test
if (process.env.NODE_ENV !== 'test') {
  startServer();
}

// Export per i test
module.exports = app;