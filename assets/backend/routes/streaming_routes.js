// assets/backend/routes/streaming_routes.js
const express = require('express');
const router = express.Router();
const streamingHandler = require('../streaming/streaming_handler');
const enhancedStreamingRouter = require('../ai-handlers/enhanced_streaming_router');

/**
 * Routes per gestire streaming HTTP (fallback per WebSocket)
 */

// GET /streaming/status - Status del sistema streaming
router.get('/status', (req, res) => {
  try {
    const stats = {
      streaming: streamingHandler.getStats(),
      router: enhancedStreamingRouter.getEnhancedStats(),
      timestamp: Date.now()
    };

    res.json({
      status: 'operational',
      ...stats
    });
  } catch (error) {
    res.status(500).json({
      error: 'Failed to get streaming status',
      message: error.message
    });
  }
});

// GET /streaming/active - Stream attivi
router.get('/active', (req, res) => {
  try {
    const activeStreams = streamingHandler.getActiveStreams();
    res.json({
      activeStreams,
      count: activeStreams.length
    });
  } catch (error) {
    res.status(500).json({
      error: 'Failed to get active streams',
      message: error.message
    });
  }
});

// POST /streaming/start - Avvia streaming (HTTP fallback)
router.post('/start', async (req, res) => {
  try {
    const { prompt, modelConfig, conversationHistory } = req.body;

    if (!prompt || !modelConfig) {
      return res.status(400).json({
        error: 'Missing required fields: prompt, modelConfig'
      });
    }

    // Genera stream ID
    const streamId = `http_stream_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

    // Simula determinazione strategia
    const strategy = await enhancedStreamingRouter.determineStreamingStrategy(
      prompt,
      modelConfig,
      conversationHistory || []
    );

    res.json({
      streamId,
      strategy,
      message: 'Stream started. Use WebSocket for real-time updates.',
      httpFallback: true
    });

  } catch (error) {
    res.status(500).json({
      error: 'Failed to start stream',
      message: error.message
    });
  }
});

// GET /streaming/:streamId - Info su stream specifico
router.get('/:streamId', (req, res) => {
  try {
    const streamId = req.params.streamId;
    const streamInfo = streamingHandler.getStreamInfo(streamId);

    if (!streamInfo) {
      return res.status(404).json({
        error: 'Stream not found',
        streamId
      });
    }

    res.json({
      streamId,
      streamInfo
    });
  } catch (error) {
    res.status(500).json({
      error: 'Failed to get stream info',
      message: error.message
    });
  }
});

// POST /streaming/:streamId/pause - Pausa stream
router.post('/:streamId/pause', (req, res) => {
  try {
    const streamId = req.params.streamId;
    streamingHandler.pauseStream(streamId);

    res.json({
      message: 'Stream paused',
      streamId,
      timestamp: Date.now()
    });
  } catch (error) {
    res.status(500).json({
      error: 'Failed to pause stream',
      message: error.message
    });
  }
});

// POST /streaming/:streamId/resume - Riprendi stream
router.post('/:streamId/resume', (req, res) => {
  try {
    const streamId = req.params.streamId;
    streamingHandler.resumeStream(streamId);

    res.json({
      message: 'Stream resumed',
      streamId,
      timestamp: Date.now()
    });
  } catch (error) {
    res.status(500).json({
      error: 'Failed to resume stream',
      message: error.message
    });
  }
});

// POST /streaming/:streamId/stop - Ferma stream
router.post('/:streamId/stop', (req, res) => {
  try {
    const streamId = req.params.streamId;
    streamingHandler.stopStream(streamId);

    res.json({
      message: 'Stream stopped',
      streamId,
      timestamp: Date.now()
    });
  } catch (error) {
    res.status(500).json({
      error: 'Failed to stop stream',
      message: error.message
    });
  }
});

// GET /streaming/stats/detailed - Statistiche dettagliate
router.get('/stats/detailed', (req, res) => {
  try {
    const detailedStats = {
      streaming: streamingHandler.getStats(),
      router: enhancedStreamingRouter.getEnhancedStats(),
      system: {
        uptime: process.uptime(),
        memory: process.memoryUsage(),
        platform: process.platform,
        nodeVersion: process.version
      },
      timestamp: Date.now()
    };

    res.json(detailedStats);
  } catch (error) {
    res.status(500).json({
      error: 'Failed to get detailed stats',
      message: error.message
    });
  }
});

// POST /streaming/cleanup - Pulizia stream inattivi
router.post('/cleanup', (req, res) => {
  try {
    streamingHandler.cleanup();

    res.json({
      message: 'Cleanup completed',
      timestamp: Date.now()
    });
  } catch (error) {
    res.status(500).json({
      error: 'Failed to cleanup',
      message: error.message
    });
  }
});

// Error handling middleware per streaming routes
router.use((error, req, res, next) => {
  console.error('Streaming route error:', error);

  res.status(500).json({
    error: 'Streaming service error',
    message: error.message,
    path: req.path,
    timestamp: Date.now()
  });
});

module.exports = router;