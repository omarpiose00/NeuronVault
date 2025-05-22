// assets/backend/routes/streaming_routes.js
const express = require('express');
const WebSocket = require('ws');
const streamingHandler = require('../streaming/streaming_handler');
const router = express.Router();

/**
 * Endpoint per avviare streaming tramite Server-Sent Events (SSE)
 */
router.post('/stream/sse/:conversationId', async (req, res) => {
  const { conversationId } = req.params;
  const { prompt, modelConfig, customWeights, mode } = req.body;

  // Validazione input
  if (!prompt || typeof prompt !== 'string' || prompt.trim() === '') {
    return res.status(400).json({
      error: 'Prompt richiesto e deve essere una stringa non vuota',
      code: 'INVALID_PROMPT'
    });
  }

  try {
    // Setup SSE headers
    res.writeHead(200, {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Headers': 'Cache-Control',
    });

    // Heartbeat per mantenere la connessione
    const heartbeat = setInterval(() => {
      if (!res.destroyed) {
        res.write('data: {"type":"heartbeat","timestamp":' + Date.now() + '}\n\n');
      } else {
        clearInterval(heartbeat);
      }
    }, 30000);

    // Registra client SSE
    streamingHandler.registerSSEClient(res, conversationId, {
      userAgent: req.headers['user-agent'],
      ip: req.ip
    });

    // Inizializza stream
    const streamInfo = await streamingHandler.initializeStream(
      conversationId,
      { type: 'sse', req: req.headers },
      'sse'
    );

    // Avvia processing streaming
    const request = {
      prompt: prompt.trim(),
      conversationId,
      modelConfig: modelConfig || { gpt: true },
      customWeights,
      mode: mode || 'chat'
    };

    // Processa in background
    streamingHandler.processStreamingRequest(request, streamInfo)
      .catch(error => {
        console.error(`Errore processing stream SSE ${conversationId}:`, error);
        if (!res.destroyed) {
          res.write(`data: {"type":"error","error":"${error.message}"}\n\n`);
        }
      });

    // Cleanup quando client disconnette
    req.on('close', () => {
      clearInterval(heartbeat);
      streamingHandler.sseClients.delete(res);
    });

  } catch (error) {
    console.error('Errore setup SSE stream:', error);
    res.status(500).json({
      error: 'Errore durante l\'inizializzazione dello streaming',
      code: 'STREAM_INIT_ERROR'
    });
  }
});

/**
 * Endpoint per ottenere lo stato di uno stream
 */
router.get('/stream/status/:conversationId', (req, res) => {
  const { conversationId } = req.params;
  const streamInfo = streamingHandler.activeStreams.get(conversationId);

  if (!streamInfo) {
    return res.status(404).json({
      error: 'Stream non trovato',
      code: 'STREAM_NOT_FOUND'
    });
  }

  // Calcola progresso totale
  const modelProgresses = Object.values(streamInfo.modelProgress);
  const totalProgress = modelProgresses.length > 0
    ? modelProgresses.reduce((sum, mp) => sum + mp.progress, 0) / modelProgresses.length
    : 0;

  res.json({
    conversationId,
    isActive: streamInfo.isActive,
    startTime: streamInfo.startTime,
    duration: Date.now() - streamInfo.startTime,
    totalProgress,
    modelProgress: streamInfo.modelProgress,
    streamType: streamInfo.streamType
  });
});

/**
 * Endpoint per interrompere uno stream
 */
router.delete('/stream/:conversationId', (req, res) => {
  const { conversationId } = req.params;
  const streamInfo = streamingHandler.activeStreams.get(conversationId);

  if (!streamInfo) {
    return res.status(404).json({
      error: 'Stream non trovato',
      code: 'STREAM_NOT_FOUND'
    });
  }

  // Interrompi stream
  streamInfo.isActive = false;
  streamingHandler._completeStream(conversationId);

  res.json({
    success: true,
    message: 'Stream interrotto',
    conversationId
  });
});

/**
 * Endpoint per statistiche streaming
 */
router.get('/stream/stats', (req, res) => {
  const stats = streamingHandler.getStreamingStats();

  res.json({
    ...stats,
    uptime: process.uptime(),
    memoryUsage: process.memoryUsage(),
    timestamp: new Date().toISOString()
  });
});

/**
 * Setup WebSocket server per streaming
 */
function setupWebSocketStreaming(server) {
  const wss = new WebSocket.Server({
    server,
    path: '/ws/stream'
  });

  wss.on('connection', (ws, request) => {
    console.log('🔌 Nuova connessione WebSocket streaming');

    ws.on('message', async (message) => {
      try {
        const data = JSON.parse(message.toString());

        switch (data.type) {
          case 'start_stream':
            await handleWebSocketStreamStart(ws, data);
            break;

          case 'ping':
            ws.send(JSON.stringify({ type: 'pong', timestamp: Date.now() }));
            break;

          case 'stop_stream':
            handleWebSocketStreamStop(ws, data);
            break;

          default:
            ws.send(JSON.stringify({
              type: 'error',
              error: 'Tipo di messaggio non riconosciuto'
            }));
        }

      } catch (error) {
        console.error('Errore parsing messaggio WebSocket:', error);
        ws.send(JSON.stringify({
          type: 'error',
          error: 'Messaggio non valido'
        }));
      }
    });

    ws.on('close', () => {
      console.log('🔌 Connessione WebSocket chiusa');
      streamingHandler.wsClients.delete(ws);
    });

    ws.on('error', (error) => {
      console.error('Errore WebSocket:', error);
      streamingHandler.wsClients.delete(ws);
    });
  });

  return wss;
}

/**
 * Gestisce inizio stream via WebSocket
 */
async function handleWebSocketStreamStart(ws, data) {
  const { conversationId, prompt, modelConfig, customWeights, mode } = data;

  try {
    // Validazione
    if (!conversationId || !prompt) {
      ws.send(JSON.stringify({
        type: 'error',
        error: 'conversationId e prompt sono richiesti'
      }));
      return;
    }

    // Registra client WebSocket
    streamingHandler.registerWebSocketClient(ws, conversationId, {
      startedAt: Date.now()
    });

    // Inizializza stream
    const streamInfo = await streamingHandler.initializeStream(
      conversationId,
      { type: 'websocket' },
      'websocket'
    );

    // Conferma inizio
    ws.send(JSON.stringify({
      type: 'stream_initialized',
      conversationId,
      timestamp: Date.now()
    }));

    // Avvia processing
    const request = {
      prompt: prompt.trim(),
      conversationId,
      modelConfig: modelConfig || { gpt: true },
      customWeights,
      mode: mode || 'chat'
    };

    await streamingHandler.processStreamingRequest(request, streamInfo);

  } catch (error) {
    console.error('Errore avvio stream WebSocket:', error);
    ws.send(JSON.stringify({
      type: 'error',
      error: error.message,
      conversationId
    }));
  }
}

/**
 * Gestisce stop stream via WebSocket
 */
function handleWebSocketStreamStop(ws, data) {
  const { conversationId } = data;

  if (streamingHandler.activeStreams.has(conversationId)) {
    streamingHandler._completeStream(conversationId);
    ws.send(JSON.stringify({
      type: 'stream_stopped',
      conversationId,
      timestamp: Date.now()
    }));
  }
}

module.exports = { router, setupWebSocketStreaming };