// assets/backend/index.js - SIMPLIFIED VERSION
const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const bodyParser = require('body-parser');
const http = require('http');
const socketIo = require('socket.io');

// Load environment variables
dotenv.config();

// Import modules
const streamingRoutes = require('./routes/streaming_routes');
const enhancedStreamingRouter = require('./ai-handlers/enhanced_streaming_router');

/**
 * NeuronVault Backend Server - Simplified Version
 */
class NeuronVaultServer {
  constructor() {
    this.app = express();
    this.httpPort = process.env.HTTP_PORT || 3000;
    this.wsPort = process.env.PORT || 3001;
    this.server = null;
    this.io = null;

    this._initializeMiddleware();
    this._initializeRoutes();
    this._initializeWebSocket();
  }

  _initializeMiddleware() {
    // CORS
    this.app.use(cors({
      origin: '*',
      methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
      allowedHeaders: ['Content-Type', 'Authorization'],
      credentials: true
    }));

    // Body parsing
    this.app.use(bodyParser.json({ limit: '10mb' }));
    this.app.use(bodyParser.urlencoded({ extended: true }));

    // Logging
    this.app.use((req, res, next) => {
      console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
      next();
    });
  }

  _initializeRoutes() {
    // Health check
    this.app.get('/health', (req, res) => {
      res.json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        version: '2.0.0'
      });
    });

    // API Info
    this.app.get('/', (req, res) => {
      res.json({
        name: 'NeuronVault AI Backend',
        version: '2.0.0',
        description: 'Multi-AI Orchestration with Real-time Streaming',
        endpoints: {
          health: '/health',
          streaming: '/streaming/*',
          websocket: `ws://localhost:${this.wsPort}`
        }
      });
    });

    // Streaming routes
    this.app.use('/streaming', streamingRoutes);

    // 404 handler
    this.app.use('*', (req, res) => {
      res.status(404).json({
        error: 'Endpoint not found',
        path: req.originalUrl
      });
    });

    // Error handler
    this.app.use((error, req, res, next) => {
      console.error('Server Error:', error);
      res.status(500).json({
        error: 'Internal server error',
        message: error.message
      });
    });
  }

  _initializeWebSocket() {
    // Create HTTP server
    this.server = http.createServer(this.app);

    // Create Socket.IO server
    this.io = socketIo(this.server, {
      cors: {
        origin: "*",
        methods: ["GET", "POST"]
      }
    });

    // WebSocket event handlers
    this.io.on('connection', (socket) => {
      console.log(`🔗 Client connected: ${socket.id}`);

      // Send server status
      socket.emit('server_status', {
        serverReady: true,
        timestamp: Date.now()
      });

      // Handle AI streaming requests
      socket.on('start_ai_stream', async (request) => {
        try {
          console.log(`🚀 Starting AI stream for client: ${socket.id}`);

          // Simple response simulation
          const response = `This is a test response for: "${request.prompt}"`;
          const words = response.split(' ');

          // Emit strategy selection
          socket.emit('strategy_selected', {
            strategy: 'parallel_racing',
            reasoning: 'Simple test strategy',
            timestamp: Date.now()
          });

          // Stream response word by word
          for (let i = 0; i < words.length; i++) {
            const chunk = words[i] + ' ';
            const isComplete = i === words.length - 1;

            socket.emit('stream_chunk', {
              chunk,
              buffer: words.slice(0, i + 1).join(' ') + ' ',
              model: 'test-model',
              strategy: 'parallel_racing',
              isComplete,
              progress: (i + 1) / words.length,
              timestamp: Date.now()
            });

            // Simulate delay
            await new Promise(resolve => setTimeout(resolve, 200));
          }

          // Emit completion
          socket.emit('streaming_completed', {
            finalResponse: response,
            timestamp: Date.now()
          });

        } catch (error) {
          console.error('Stream error:', error);
          socket.emit('stream_error', {
            error: error.message,
            timestamp: Date.now()
          });
        }
      });

      // Handle disconnect
      socket.on('disconnect', (reason) => {
        console.log(`🔌 Client disconnected: ${socket.id}, reason: ${reason}`);
      });
    });
  }

  async start() {
    try {
      // Start server on WebSocket port
      this.server.listen(this.wsPort, () => {
        console.log('🚀 NeuronVault Backend Server Started!');
        console.log(`📡 HTTP API: http://localhost:${this.wsPort}`);
        console.log(`🔌 WebSocket: ws://localhost:${this.wsPort}`);
        console.log('✅ Server ready for connections');
      });
    } catch (error) {
      console.error('❌ Failed to start server:', error);
      process.exit(1);
    }
  }
}

// Start server
const server = new NeuronVaultServer();
server.start();

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('\n🛑 Shutting down gracefully...');
  process.exit(0);
});

process.on('SIGTERM', () => {
  console.log('\n🛑 Shutting down gracefully...');
  process.exit(0);
});