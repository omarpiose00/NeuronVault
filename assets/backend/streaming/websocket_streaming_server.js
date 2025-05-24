// assets/backend/streaming/websocket_streaming_server.js
const http = require('http');
const socketIo = require('socket.io');
const enhancedStreamingRouter = require('../ai-handlers/enhanced_streaming_router');
const cors = require('cors');

/**
 * WebSocket Streaming Server per NeuronVault
 * Gestisce connessioni real-time con l'app Flutter
 */
class WebSocketStreamingServer {
  constructor(expressApp, port = 3001) {
    this.expressApp = expressApp;
    this.port = port;
    this.server = null;
    this.io = null;
    this.activeConnections = new Map();
    this.streamingStats = {
      totalConnections: 0,
      activeStreams: 0,
      completedStreams: 0,
      errorCount: 0
    };

    this._initializeServer();
    this._setupEventHandlers();
  }

  /**
   * Inizializza server HTTP e Socket.IO
   */
  _initializeServer() {
    // Crea server HTTP
    this.server = http.createServer(this.expressApp);

    // Configura Socket.IO con CORS per Flutter
    this.io = socketIo(this.server, {
      cors: {
        origin: "*", // In produzione, specificare domini Flutter
        methods: ["GET", "POST"],
        allowedHeaders: ["*"],
        credentials: true
      },
      transports: ['websocket', 'polling'],
      pingTimeout: 60000,
      pingInterval: 25000
    });

    console.log('🔌 WebSocket Streaming Server initialized');
  }

  /**
   * Configura event handlers per Socket.IO
   */
  _setupEventHandlers() {
    this.io.on('connection', (socket) => {
      console.log(`🔗 Client connected: ${socket.id}`);
      this.streamingStats.totalConnections++;

      this._handleClientConnection(socket);
      this._registerClientEvents(socket);
    });

    // Event handlers per Enhanced Streaming Router
    this._setupRouterEventHandlers();
  }

  /**
   * Gestisce nuova connessione client
   */
  _handleClientConnection(socket) {
    const clientInfo = {
      id: socket.id,
      connectedAt: Date.now(),
      activeStreams: new Set(),
      clientType: 'flutter_app', // Potrebbe essere determinato dinamicamente
      lastActivity: Date.now()
    };

    this.activeConnections.set(socket.id, clientInfo);

    // Invia stato server al client
    socket.emit('server_status', {
      serverReady: true,
      availableStrategies: Object.keys(enhancedStreamingRouter.strategies),
      serverStats: this.getServerStats(),
      timestamp: Date.now()
    });

    // Gestisci disconnessione
    socket.on('disconnect', (reason) => {
      console.log(`🔌 Client disconnected: ${socket.id}, reason: ${reason}`);
      this._handleClientDisconnection(socket.id);
    });
  }

  /**
   * Registra eventi client specifici
   */
  _registerClientEvents(socket) {
    const clientInfo = this.activeConnections.get(socket.id);

    // Richiesta streaming AI
    socket.on('start_ai_stream', async (request) => {
      try {
        await this._handleStreamRequest(socket, request);
      } catch (error) {
        console.error('Error handling stream request:', error);
        socket.emit('stream_error', {
          error: error.message,
          timestamp: Date.now()
        });
      }
    });

    // Pausa/riprendi streaming
    socket.on('pause_stream', (data) => {
      this._handleStreamPause(socket, data);
    });

    socket.on('resume_stream', (data) => {
      this._handleStreamResume(socket, data);
    });

    // Interruzione streaming
    socket.on('stop_stream', (data) => {
      this._handleStreamStop(socket, data);
    });

    // Heartbeat per mantenere connessione
    socket.on('heartbeat', () => {
      clientInfo.lastActivity = Date.now();
      socket.emit('heartbeat_ack', { timestamp: Date.now() });
    });

    // Richiesta statistiche streaming
    socket.on('get_streaming_stats', () => {
      socket.emit('streaming_stats', {
        ...this.streamingStats,
        routerStats: enhancedStreamingRouter.getEnhancedStats(),
        timestamp: Date.now()
      });
    });

    // Configurazione client preferences
    socket.on('update_preferences', (preferences) => {
      this._updateClientPreferences(socket, preferences);
    });
  }

  /**
   * Gestisce richiesta di streaming AI
   */
  async _handleStreamRequest(socket, request) {
    const clientInfo = this.activeConnections.get(socket.id);
    const streamId = this._generateStreamId();

    console.log(`🚀 Starting AI stream: ${streamId} for client: ${socket.id}`);

    // Valida richiesta
    if (!this._validateStreamRequest(request)) {
      throw new Error('Invalid stream request format');
    }

    // Aggiungi stream alle attive del client
    clientInfo.activeStreams.add(streamId);
    this.streamingStats.activeStreams++;

    // Prepara configurazione stream
    const streamConfig = {
      streamId,
      clientId: socket.id,
      ...request,
      startTime: Date.now()
    };

    try {
      // Emetti inizio streaming
      socket.emit('stream_started', {
        streamId,
        config: streamConfig,
        timestamp: Date.now()
      });

      // Avvia streaming tramite Enhanced Router
      const result = await enhancedStreamingRouter.startStreamingSession(
        request,
        socket // Passa socket per emissioni real-time
      );

      // Stream completato con successo
      this._handleStreamCompletion(socket, streamId, result);

    } catch (error) {
      // Gestisci errori streaming
      this._handleStreamError(socket, streamId, error);
    }
  }

  /**
   * Valida richiesta streaming
   */
  _validateStreamRequest(request) {
    const required = ['prompt', 'modelConfig'];
    return required.every(field => request.hasOwnProperty(field));
  }

  /**
   * Gestisce completamento streaming
   */
  _handleStreamCompletion(socket, streamId, result) {
    const clientInfo = this.activeConnections.get(socket.id);

    if (clientInfo) {
      clientInfo.activeStreams.delete(streamId);
    }

    this.streamingStats.activeStreams--;
    this.streamingStats.completedStreams++;

    socket.emit('stream_completed', {
      streamId,
      result,
      completedAt: Date.now()
    });

    console.log(`✅ Stream completed: ${streamId}`);
  }

  /**
   * Gestisce errori streaming
   */
  _handleStreamError(socket, streamId, error) {
    const clientInfo = this.activeConnections.get(socket.id);

    if (clientInfo) {
      clientInfo.activeStreams.delete(streamId);
    }

    this.streamingStats.activeStreams--;
    this.streamingStats.errorCount++;

    socket.emit('stream_error', {
      streamId,
      error: error.message,
      timestamp: Date.now()
    });

    console.error(`❌ Stream error: ${streamId}:`, error.message);
  }

  /**
   * Gestisce pausa streaming
   */
  _handleStreamPause(socket, data) {
    console.log(`⏸️ Pausing stream: ${data.streamId}`);
    socket.emit('stream_paused', {
      streamId: data.streamId,
      timestamp: Date.now()
    });
  }

  /**
   * Gestisce ripresa streaming
   */
  _handleStreamResume(socket, data) {
    console.log(`▶️ Resuming stream: ${data.streamId}`);
    socket.emit('stream_resumed', {
      streamId: data.streamId,
      timestamp: Date.now()
    });
  }

  /**
   * Gestisce interruzione streaming
   */
  _handleStreamStop(socket, data) {
    const clientInfo = this.activeConnections.get(socket.id);

    if (clientInfo && clientInfo.activeStreams.has(data.streamId)) {
      clientInfo.activeStreams.delete(data.streamId);
      this.streamingStats.activeStreams--;
    }

    console.log(`⏹️ Stopping stream: ${data.streamId}`);
    socket.emit('stream_stopped', {
      streamId: data.streamId,
      timestamp: Date.now()
    });
  }

  /**
   * Aggiorna preferenze client
   */
  _updateClientPreferences(socket, preferences) {
    const clientInfo = this.activeConnections.get(socket.id);
    if (clientInfo) {
      clientInfo.preferences = { ...clientInfo.preferences, ...preferences };
      socket.emit('preferences_updated', {
        preferences: clientInfo.preferences,
        timestamp: Date.now()
      });
    }
  }

  /**
   * Setup event handlers per Enhanced Streaming Router
   */
  _setupRouterEventHandlers() {
    // Strategy execution eventi
    enhancedStreamingRouter.on('strategy_execution_started', (data) => {
      this._broadcastToClient(data.conversationId, 'strategy_execution_started', data);
    });

    // Race winner eventi
    enhancedStreamingRouter.on('race_winner', (data) => {
      this._broadcastToClient(data.conversationId, 'race_winner', data);
    });

    // Consensus completion eventi
    enhancedStreamingRouter.on('consensus_completed', (data) => {
      this._broadcastToClient(data.conversationId, 'consensus_completed', data);
    });

    // Cascade stage completion eventi
    enhancedStreamingRouter.on('cascade_stage_completed', (data) => {
      this._broadcastToClient(data.conversationId, 'cascade_stage_completed', data);
    });

    // Diversity sampling completion eventi
    enhancedStreamingRouter.on('diversity_sampling_completed', (data) => {
      this._broadcastToClient(data.conversationId, 'diversity_sampling_completed', data);
    });

    // Hybrid synthesis completion eventi
    enhancedStreamingRouter.on('hybrid_synthesis_completed', (data) => {
      this._broadcastToClient(data.conversationId, 'hybrid_synthesis_completed', data);
    });
  }

  /**
   * Broadcast evento a client specifico basato su conversationId
   */
  _broadcastToClient(conversationId, eventName, data) {
    // Trova client basato su conversationId
    for (const [socketId, clientInfo] of this.activeConnections.entries()) {
      const socket = this.io.sockets.sockets.get(socketId);
      if (socket) {
        socket.emit(eventName, data);
      }
    }
  }

  /**
   * Gestisce disconnessione client
   */
  _handleClientDisconnection(socketId) {
    const clientInfo = this.activeConnections.get(socketId);

    if (clientInfo) {
      // Pulisci stream attivi
      this.streamingStats.activeStreams -= clientInfo.activeStreams.size;

      // Rimuovi client
      this.activeConnections.delete(socketId);
    }
  }

  /**
   * Genera ID univoco per stream
   */
  _generateStreamId() {
    return `stream_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * Avvia server
   */
  async start() {
    return new Promise((resolve, reject) => {
      try {
        this.server.listen(this.port, () => {
          console.log(`🚀 NeuronVault WebSocket Streaming Server running on port ${this.port}`);
          console.log(`📡 Socket.IO ready for Flutter connections`);
          resolve();
        });
      } catch (error) {
        console.error('Failed to start WebSocket server:', error);
        reject(error);
      }
    });
  }

  /**
   * Ferma server
   */
  async stop() {
    return new Promise((resolve) => {
      if (this.server) {
        this.server.close(() => {
          console.log('🛑 WebSocket Streaming Server stopped');
          resolve();
        });
      } else {
        resolve();
      }
    });
  }

  /**
   * Ottieni statistiche server
   */
  getServerStats() {
    return {
      ...this.streamingStats,
      activeConnections: this.activeConnections.size,
      uptime: process.uptime(),
      routerStats: enhancedStreamingRouter.getEnhancedStats()
    };
  }

  /**
   * Broadcast messaggio a tutti i client connessi
   */
  broadcastToAll(eventName, data) {
    this.io.emit(eventName, data);
  }

  /**
   * Ottieni info su client specifico
   */
  getClientInfo(socketId) {
    return this.activeConnections.get(socketId);
  }

  /**
   * Ottieni lista di tutti i client attivi
   */
  getActiveClients() {
    return Array.from(this.activeConnections.entries()).map(([id, info]) => ({
      id,
      ...info,
      activeStreamCount: info.activeStreams.size
    }));
  }
}

module.exports = WebSocketStreamingServer;