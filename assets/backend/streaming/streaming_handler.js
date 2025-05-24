// assets/backend/streaming/streaming_handler.js
const EventEmitter = require('events');

/**
 * Basic Streaming Handler per gestire streaming AI
 */
class StreamingHandler extends EventEmitter {
  constructor() {
    super();
    this.activeStreams = new Map();
    this.config = {
      maxConcurrentStreams: 10,
      streamTimeout: 30000,
      chunkDelay: 100
    };
  }

  /**
   * Inizia un nuovo stream
   */
  async startStream(streamId, request, onChunk) {
    if (this.activeStreams.has(streamId)) {
      throw new Error(`Stream ${streamId} is already active`);
    }

    const streamInfo = {
      id: streamId,
      startTime: Date.now(),
      request,
      status: 'active'
    };

    this.activeStreams.set(streamId, streamInfo);

    try {
      // Simula streaming response
      await this._simulateStreaming(streamId, request, onChunk);

      // Mark stream as completed
      streamInfo.status = 'completed';
      streamInfo.endTime = Date.now();

      this.emit('stream_completed', { streamId, streamInfo });

    } catch (error) {
      streamInfo.status = 'error';
      streamInfo.error = error.message;
      this.emit('stream_error', { streamId, error });
      throw error;
    } finally {
      // Cleanup dopo un po'
      setTimeout(() => {
        this.activeStreams.delete(streamId);
      }, 5000);
    }
  }

  /**
   * Simula streaming response
   */
  async _simulateStreaming(streamId, request, onChunk) {
    const fullText = `This is a simulated streaming response for: "${request.prompt}".
    The response is being generated in chunks to demonstrate real-time streaming capabilities.
    Each chunk arrives with a small delay to simulate network latency and processing time.`;

    const words = fullText.split(' ');

    for (let i = 0; i < words.length; i++) {
      // Check if stream is still active
      const streamInfo = this.activeStreams.get(streamId);
      if (!streamInfo || streamInfo.status !== 'active') {
        break;
      }

      const chunk = words[i] + ' ';
      const isFinished = i === words.length - 1;

      // Emit chunk event
      this.emit('chunk', {
        streamId,
        chunk,
        isFinished,
        progress: (i + 1) / words.length
      });

      // Call chunk callback
      if (onChunk) {
        onChunk(chunk, isFinished);
      }

      // Simulate processing delay
      await new Promise(resolve => setTimeout(resolve, this.config.chunkDelay));
    }
  }

  /**
   * Pausa uno stream
   */
  pauseStream(streamId) {
    const streamInfo = this.activeStreams.get(streamId);
    if (streamInfo && streamInfo.status === 'active') {
      streamInfo.status = 'paused';
      this.emit('stream_paused', { streamId });
    }
  }

  /**
   * Riprende uno stream
   */
  resumeStream(streamId) {
    const streamInfo = this.activeStreams.get(streamId);
    if (streamInfo && streamInfo.status === 'paused') {
      streamInfo.status = 'active';
      this.emit('stream_resumed', { streamId });
    }
  }

  /**
   * Ferma uno stream
   */
  stopStream(streamId) {
    const streamInfo = this.activeStreams.get(streamId);
    if (streamInfo) {
      streamInfo.status = 'stopped';
      streamInfo.endTime = Date.now();
      this.emit('stream_stopped', { streamId });
    }
  }

  /**
   * Ottieni info su stream attivo
   */
  getStreamInfo(streamId) {
    return this.activeStreams.get(streamId);
  }

  /**
   * Ottieni tutti gli stream attivi
   */
  getActiveStreams() {
    return Array.from(this.activeStreams.values());
  }

  /**
   * Pulisci stream completati
   */
  cleanup() {
    const now = Date.now();
    for (const [streamId, streamInfo] of this.activeStreams.entries()) {
      // Rimuovi stream inattivi da più di 1 ora
      if (streamInfo.endTime && (now - streamInfo.endTime) > 3600000) {
        this.activeStreams.delete(streamId);
      }
    }
  }

  /**
   * Ottieni statistiche streaming
   */
  getStats() {
    const activeCount = this.getActiveStreams().filter(s => s.status === 'active').length;
    const pausedCount = this.getActiveStreams().filter(s => s.status === 'paused').length;
    const completedCount = this.getActiveStreams().filter(s => s.status === 'completed').length;

    return {
      totalActiveStreams: this.activeStreams.size,
      activeStreams: activeCount,
      pausedStreams: pausedCount,
      completedStreams: completedCount,
      config: this.config
    };
  }
}

module.exports = new StreamingHandler();