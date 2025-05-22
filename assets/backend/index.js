// assets/backend/index.js - Enhanced with streaming support
const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const { Server } = require('socket.io');
const http = require('http');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Import dei moduli AI e streaming
const router = require('./ai-handlers/router');
const streamingHandler = require('./streaming/streaming_handler');
const advancedOrchestrator = require('./ai-handlers/advanced_streaming_orchestrator');
const { router: streamingRoutes, setupWebSocketStreaming } = require('./routes/streaming_routes');

// Configurazione ambiente
dotenv.config();
const app = express();
const server = http.createServer(app);

// Setup Socket.IO con configurazioni avanzate
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  },
  transports: ['websocket', 'polling'],
  pingTimeout: 60000,
  pingInterval: 25000
});

// Configurazione middleware
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Configurazione multer per file uploads
const uploadsDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadsDir);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({
  storage: storage,
  fileFilter: (req, file, cb) => {
    const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
    cb(null, allowedTypes.includes(file.mimetype));
  },
  limits: { fileSize: 10485760 } // 10MB
});

// Memorizzazione conversazioni con TTL
const conversations = new Map();
const CONVERSATION_TTL = 24 * 60 * 60 * 1000; // 24 ore

// Cleanup automatico conversazioni
setInterval(() => {
  const now = Date.now();
  for (const [id, conversation] of conversations.entries()) {
    if (now - conversation.lastActivity > CONVERSATION_TTL) {
      conversations.delete(id);
    }
  }
}, 60 * 60 * 1000);

// Logger avanzato con livelli
const logger = {
  debug: (message, data = null) => {
    if (process.env.DEBUG_LOGS === 'true') {
      console.log(`🔍 [DEBUG] ${message}`, data ? JSON.stringify(data, null, 2) : '');
    }
  },
  info: (message, data = null) => {
    console.log(`ℹ️  [INFO] ${message}`, data ? JSON.stringify(data, null, 2) : '');
  },
  warn: (message, data = null) => {
    console.warn(`⚠️  [WARN] ${message}`, data ? JSON.stringify(data, null, 2) : '');
  },
  error: (message, error = null) => {
    console.error(`🔥 [ERROR] ${message}`, error ? error.stack || error : '');
  }
};

// Middleware per request logging con performance tracking
app.use((req, res, next) => {
  const start = Date.now();
  const requestId = `req_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

  req.requestId = requestId;
  req.startTime = start;

  res.on('finish', () => {
    const duration = Date.now() - start;
    const logLevel = res.statusCode >= 400 ? 'error' : 'info';

    logger[logLevel](`${req.method} ${req.url} - ${res.statusCode} (${duration}ms) [${requestId}]`);
  });

  next();
});

// Enhanced multi-agent endpoint with streaming fallback
app.post("/multi-agent", async (req, res) => {
  const { prompt, conversationId = 'default', mode = 'chat', modelConfig = null, customWeights = null, streamingEnabled = false } = req.body;

  // Input validation
  if (!prompt || typeof prompt !== 'string' || prompt.trim() === '') {
    return res.status(400).json({
      error: 'Prompt richiesto e deve essere una stringa non vuota',
      code: 'INVALID_PROMPT'
    });
  }

  // Initialize conversation
  if (!conversations.has(conversationId)) {
    conversations.set(conversationId, {
      messages: [],
      createdAt: Date.now(),
      lastActivity: Date.now()
    });
  }

  const conversation = conversations.get(conversationId);
  conversation.lastActivity = Date.now();

  // Add user message
  const userMessage = {
    agent: "user",
    message: prompt,
    timestamp: new Date().toISOString(),
    metadata: { mode, modelConfig: modelConfig || {}, customWeights }
  };

  conversation.messages.push(userMessage);

  try {
    // Check if streaming is requested and supported
    if (streamingEnabled && (req.headers.accept?.includes('text/event-stream') || req.headers['x-stream-mode'])) {
      logger.info(`🔄 Initiating streaming mode for conversation ${conversationId}`);
      return await handleStreamingRequest(req, res, {
        prompt,
        conversationId,
        modelConfig: modelConfig || { gpt: true, claude: true },
        customWeights,
        mode
      });
    }

    // Standard processing
    const config = modelConfig || { gpt: true, claude: true };

    // Rate limiting
    const userRequests = conversation.messages.filter(m =>
      m.agent === 'user' &&
      Date.now() - new Date(m.timestamp).getTime() < 60000
    );

    if (userRequests.length > 10) {
      return res.status(429).json({
        error: 'Troppi richieste. Attendere prima di inviare un nuovo messaggio.',
        code: 'RATE_LIMIT_EXCEEDED',
        retryAfter: 60
      });
    }

    // Process request
    const request = {
      prompt,
      conversationId,
      modelConfig: config,
      customWeights,
      mode,
      context: conversation.messages.slice(-5)
    };

    logger.debug('Processing standard AI request', {
      conversationId,
      models: Object.keys(config).filter(k => config[k]),
      requestId: req.requestId
    });

    const result = await router.processRequest(request);

    if (result.error) {
      throw new Error(result.error);
    }

    // Update conversation
    if (result.conversation && result.conversation.length > 0) {
      const newMessages = result.conversation.filter(msg =>
        msg.agent !== 'user' || msg.message !== prompt
      );
      conversation.messages.push(...newMessages);
    }

    const processingTime = Date.now() - req.startTime;

    logger.info(`✅ Request ${req.requestId} completed successfully`, {
      processingTime,
      modelsUsed: Object.keys(result.responses || {}),
      messageCount: conversation.messages.length
    });

    res.json({
      conversation: conversation.messages,
      responses: result.responses || {},
      weights: result.weights || {},
      synthesizedResponse: result.synthesizedResponse || '',
      metadata: {
        processingTime,
        modelsUsed: Object.keys(result.responses || {}),
        messageCount: conversation.messages.length,
        mode,
        requestId: req.requestId
      }
    });

  } catch (error) {
    logger.error(`Request ${req.requestId} failed:`, error);

    const errorResponse = {
      conversation: conversation.messages,
      error: 'Errore durante l\'elaborazione della richiesta',
      code: 'PROCESSING_ERROR',
      processingTime: Date.now() - req.startTime,
      requestId: req.requestId
    };

    // Categorize error
    if (error.message?.includes('API key')) {
      errorResponse.error = 'Configurazione API non valida';
      errorResponse.code = 'API_KEY_ERROR';
    } else if (error.message?.includes('quota')) {
      errorResponse.error = 'Limite di utilizzo API raggiunto';
      errorResponse.code = 'QUOTA_EXCEEDED';
    }

    // Add error message to conversation
    const errorMessage = {
      agent: "system",
      message: `Errore: ${errorResponse.error}`,
      timestamp: new Date().toISOString(),
      metadata: {
        errorCode: errorResponse.code,
        originalError: error.message,
        requestId: req.requestId
      }
    };

    conversation.messages.push(errorMessage);

    res.status(500).json(errorResponse);
  }
});

// Enhanced streaming request handler
async function handleStreamingRequest(req, res, requestData) {
  const { conversationId, prompt } = requestData;

  try {
    // Setup SSE headers for streaming response
    res.writeHead(200, {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Headers': 'Cache-Control',
      'X-Accel-Buffering': 'no' // Disable nginx buffering
    });

    // Send initial event
    res.write(`data: ${JSON.stringify({
      type: 'stream_started',
      conversationId,
      timestamp: Date.now()
    })}\n\n`);

    // Initialize stream with advanced orchestrator
    const streamInfo = await streamingHandler.initializeStream(
      conversationId,
      { type: 'sse', requestId: req.requestId },
      'sse'
    );

    // Register SSE client
    streamingHandler.registerSSEClient(res, conversationId, {
      userAgent: req.headers['user-agent'],
      ip: req.ip,
      requestId: req.requestId
    });

    // Use advanced orchestrator for intelligent streaming
    await advancedOrchestrator.startIntelligentStreaming(requestData, streamInfo);

    // Setup heartbeat
    const heartbeat = setInterval(() => {
      if (!res.destroyed) {
        res.write(`data: ${JSON.stringify({
          type: 'heartbeat',
          timestamp: Date.now()
        })}\n\n`);
      } else {
        clearInterval(heartbeat);
      }
    }, 10000);

    // Cleanup on client disconnect
    req.on('close', () => {
      clearInterval(heartbeat);
      streamingHandler.sseClients.delete(res);
      logger.debug(`SSE client disconnected for conversation ${conversationId}`);
    });

  } catch (error) {
    logger.error(`Streaming initialization failed for ${conversationId}:`, error);

    if (!res.headersSent) {
      res.status(500).json({
        error: 'Errore durante l\'inizializzazione dello streaming',
        code: 'STREAM_INIT_ERROR'
      });
    } else {
      res.write(`data: ${JSON.stringify({
        type: 'error',
        error: error.message,
        timestamp: Date.now()
      })}\n\n`);
    }
  }
}

// Mount streaming routes
app.use('/api/stream', streamingRoutes);

// WebSocket setup for real-time streaming
const wss = setupWebSocketStreaming(server);

// Socket.IO configuration for real-time updates
io.on('connection', (socket) => {
  logger.debug(`Socket.IO client connected: ${socket.id}`);

  socket.on('join_conversation', (conversationId) => {
    socket.join(conversationId);
    logger.debug(`Socket ${socket.id} joined conversation ${conversationId}`);
  });

  socket.on('start_streaming', async (data) => {
    try {
      const { conversationId, prompt, modelConfig, customWeights, mode } = data;

      // Initialize streaming with Socket.IO
      const streamInfo = await streamingHandler.initializeStream(
        conversationId,
        { type: 'socketio', socketId: socket.id },
        'socketio'
      );

      // Emit to room
      socket.to(conversationId).emit('streaming_started', {
        conversationId,
        models: Object.keys(modelConfig).filter(k => modelConfig[k])
      });

      // Start advanced streaming
      await advancedOrchestrator.startIntelligentStreaming({
        prompt,
        conversationId,
        modelConfig,
        customWeights,
        mode
      }, streamInfo);

    } catch (error) {
      socket.emit('streaming_error', {
        error: error.message,
        timestamp: Date.now()
      });
    }
  });

  socket.on('disconnect', () => {
    logger.debug(`Socket.IO client disconnected: ${socket.id}`);
  });
});

// Advanced streaming event handling
advancedOrchestrator.on('strategy_selected', (data) => {
  logger.info(`🎯 Streaming strategy selected: ${data.strategy.type} for ${data.conversationId}`);

  // Broadcast to Socket.IO clients
  io.to(data.conversationId).emit('strategy_selected', data);
});

advancedOrchestrator.on('model_chunk_with_metrics', (data) => {
  // Broadcast chunk with performance metrics
  io.to(data.conversationId).emit('model_chunk', {
    model: data.model,
    chunk: data.chunk,
    metrics: data.metrics,
    timestamp: Date.now()
  });
});

streamingHandler.on('stream_event', (event) => {
  // Broadcast all streaming events to Socket.IO
  io.to(event.conversationId).emit('stream_event', event);
});

// Additional API endpoints for streaming management
app.get('/api/streaming/stats', (req, res) => {
  const stats = {
    ...streamingHandler.getStreamingStats(),
    ...advancedOrchestrator.getPerformanceStats(),
    socketioConnections: io.engine.clientsCount,
    activeConversations: conversations.size,
    uptime: process.uptime()
  };

  res.json(stats);
});

app.get('/api/streaming/performance/:model', (req, res) => {
  const { model } = req.params;
  const performance = advancedOrchestrator.getPerformanceStats()[model];

  if (!performance) {
    return res.status(404).json({
      error: `Performance data not found for model: ${model}`,
      availableModels: Object.keys(advancedOrchestrator.getPerformanceStats())
    });
  }

  res.json({ model, performance });
});

// Error handling middleware
app.use((err, req, res, next) => {
  logger.error('Unhandled error:', err);

  const isDevelopment = process.env.NODE_ENV === 'development';

  res.status(err.status || 500).json({
    error: isDevelopment ? err.message : 'Errore interno del server',
    requestId: req.requestId,
    ...(isDevelopment && { stack: err.stack })
  });
});

// Initialize AI handlers
const initializeAI = () => {
  const apiKeys = {
    'openai': process.env.OPENAI_API_KEY,
    'anthropic': process.env.ANTHROPIC_API_KEY,
    'deepseek': process.env.DEEPSEEK_API_KEY,
    'google': process.env.GOOGLE_API_KEY,
    'mistral': process.env.MISTRAL_API_KEY,
    'ollama': process.env.OLLAMA_ENDPOINT || 'localhost:11434'
  };

  const initialized = router.initialize(apiKeys);

  logger.info('🤖 AI Models Status:');
  Object.keys(router.handlers).forEach(model => {
    const status = router.handlers[model].checkAvailability() ? '✅' : '❌';
    console.log(`   ${status} ${model.toUpperCase()}`);
  });

  return initialized;
};

// Graceful shutdown
process.on('SIGTERM', () => {
  logger.info('SIGTERM received, shutting down gracefully');

  // Close all streaming connections
  streamingHandler.sseClients.clear();
  streamingHandler.wsClients.clear();

  server.close(() => {
    logger.info('Server closed');
    process.exit(0);
  });
});

// Server startup
const startServer = async () => {
  try {
    initializeAI();

    const port = process.env.PORT || 4000;
    server.listen(port, () => {
      logger.info(`🚀 NeuronVault Enhanced Backend started`);
      logger.info(`📍 Server: http://localhost:${port}`);
      logger.info(`🔌 Socket.IO: Active (${io.engine.clientsCount} clients)`);
      logger.info(`📡 WebSocket Streaming: Active`);
      logger.info(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);

      if (process.env.NODE_ENV === 'development') {
        logger.info(`📊 Streaming Stats: http://localhost:${port}/api/streaming/stats`);
        logger.info(`🎯 Performance: http://localhost:${port}/api/streaming/performance/:model`);
      }
    });

  } catch (error) {
    logger.error('Failed to start enhanced server:', error);
    process.exit(1);
  }
};

if (process.env.NODE_ENV !== 'test') {
  startServer();
}

module.exports = app;