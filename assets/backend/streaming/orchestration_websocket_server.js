// assets/backend/streaming/orchestration_websocket_server.js
const WebSocket = require('ws');
const EventEmitter = require('events');
const TransparentAISynthesizer = require('../ai-handlers/enhanced_transparent_synthesizer');

/**
 * 🧠 NeuronVault WebSocket Orchestration Server
 * Real-time communication hub for transparent AI orchestration
 */
class OrchestrationWebSocketServer extends EventEmitter {
    constructor(port = 3001) {
        super();
        this.port = port;
        this.wss = null;
        this.clients = new Map();
        this.synthesizer = new TransparentAISynthesizer();
        this.aiHandlers = new Map();

        this.setupSynthesizerEvents();
        this.loadAIHandlers();
    }

    /**
     * Start WebSocket server
     */
    start() {
        this.wss = new WebSocket.Server({
            port: this.port,
            perMessageDeflate: false // Better for real-time communication
        });

        this.wss.on('connection', (ws, req) => {
            const clientId = this.generateClientId();

            console.log(`🔗 Client connected: ${clientId} from ${req.socket.remoteAddress}`);

            // Initialize client
            const client = {
                id: clientId,
                ws: ws,
                connectedAt: Date.now(),
                activeOrchestrations: new Set()
            };

            this.clients.set(clientId, client);

            // Setup client message handler
            ws.on('message', (message) => {
                this.handleClientMessage(clientId, message);
            });

            // Handle client disconnect
            ws.on('close', () => {
                console.log(`🔌 Client disconnected: ${clientId}`);
                this.clients.delete(clientId);
            });

            // Handle errors
            ws.on('error', (error) => {
                console.error(`❌ WebSocket error for client ${clientId}:`, error);
            });

            // Send welcome message
            this.sendToClient(clientId, {
                type: 'connection_established',
                data: {
                    client_id: clientId,
                    server_time: new Date().toISOString(),
                    available_models: Array.from(this.aiHandlers.keys())
                }
            });
        });

        console.log(`🚀 NeuronVault Orchestration Server running on ws://localhost:${this.port}`);

        this.emit('server_started', { port: this.port });
    }

    /**
     * Handle incoming client messages
     */
    async handleClientMessage(clientId, message) {
        try {
            const data = JSON.parse(message.toString());
            const { type, data: messageData } = data;

            console.log(`📥 Message from ${clientId}: ${type}`);

            switch (type) {
                case 'orchestration_request':
                    await this.handleOrchestrationRequest(clientId, messageData);
                    break;

                case 'get_model_status':
                    await this.handleModelStatusRequest(clientId);
                    break;

                case 'ping':
                    this.sendToClient(clientId, { type: 'pong', data: { timestamp: Date.now() } });
                    break;

                default:
                    console.warn(`🤔 Unknown message type: ${type}`);
            }

        } catch (error) {
            console.error(`❌ Error handling message from ${clientId}:`, error);
            this.sendToClient(clientId, {
                type: 'error',
                data: {
                    message: 'Failed to process message',
                    code: 'MESSAGE_PROCESSING_ERROR'
                }
            });
        }
    }

    /**
     * Handle AI orchestration request
     */
    async handleOrchestrationRequest(clientId, requestData) {
        const {
            prompt,
            models,
            strategy = 'parallel',
            weights = {},
            conversation_id
        } = requestData;

        try {
            // Validate request
            if (!prompt || !models || models.length === 0) {
                throw new Error('Invalid orchestration request: missing prompt or models');
            }

            // Track client orchestration
            const client = this.clients.get(clientId);
            if (client) {
                client.activeOrchestrations.add(conversation_id);
            }

            console.log(`🧠 Starting orchestration for ${clientId}: ${models.join(', ')} using ${strategy} strategy`);

            // Start individual AI requests
            const modelPromises = models.map(modelName =>
                this.requestAIResponse(conversation_id, modelName, prompt, clientId)
            );

            // Start orchestration (non-blocking)
            const orchestrationPromise = this.synthesizer.orchestrate({
                conversationId: conversation_id,
                prompt,
                models,
                strategy,
                weights,
                metadata: { clientId }
            });

            // Wait for AI responses
            await Promise.allSettled(modelPromises);

            // Complete orchestration
            await orchestrationPromise;

        } catch (error) {
            console.error(`❌ Orchestration failed for ${clientId}:`, error);
            this.sendToClient(clientId, {
                type: 'orchestration_error',
                data: {
                    conversation_id,
                    message: error.message,
                    code: 'ORCHESTRATION_FAILED'
                }
            });
        }
    }

    /**
     * Request response from specific AI model
     */
    async requestAIResponse(conversationId, modelName, prompt, clientId) {
        const handler = this.aiHandlers.get(modelName.toLowerCase());

        if (!handler) {
            console.warn(`⚠️ No handler found for model: ${modelName}`);
            return;
        }

        const startTime = Date.now();

        try {
            console.log(`🤖 Requesting response from ${modelName}...`);

            // Send status update
            this.sendToClient(clientId, {
                type: 'model_status_update',
                data: {
                    model_name: modelName,
                    status: 'processing',
                    conversation_id: conversationId
                }
            });

            // Get AI response
            const response = await handler.generateResponse(prompt, {
                temperature: 0.7,
                max_tokens: 2000
            });

            const responseTime = Date.now() - startTime;

            // Add response to synthesizer
            this.synthesizer.addResponse(conversationId, modelName, {
                content: response.content,
                confidence: response.confidence || 0.8,
                responseTime: responseTime,
                metadata: response.metadata || {}
            });

            console.log(`✅ ${modelName} response received (${responseTime}ms)`);

        } catch (error) {
            console.error(`❌ Error getting response from ${modelName}:`, error);

            // Send error status
            this.sendToClient(clientId, {
                type: 'model_status_update',
                data: {
                    model_name: modelName,
                    status: 'error',
                    error: error.message,
                    conversation_id: conversationId
                }
            });
        }
    }

    /**
     * Handle model status request
     */
    async handleModelStatusRequest(clientId) {
        const modelStatuses = {};

        for (const [modelName, handler] of this.aiHandlers) {
            try {
                // Test model availability
                const isAvailable = await this.testModelAvailability(handler);
                modelStatuses[modelName] = {
                    available: isAvailable,
                    last_checked: new Date().toISOString()
                };
            } catch (error) {
                modelStatuses[modelName] = {
                    available: false,
                    error: error.message,
                    last_checked: new Date().toISOString()
                };
            }
        }

        this.sendToClient(clientId, {
            type: 'model_status_response',
            data: { models: modelStatuses }
        });
    }

    /**
     * Setup synthesizer event listeners
     */
    setupSynthesizerEvents() {
        // Individual response received
        this.synthesizer.on('individual_response', (data) => {
            this.broadcastToRelevantClients(data.conversation_id, {
                type: 'individual_response',
                data: data
            });
        });

        // Orchestration progress update
        this.synthesizer.on('orchestration_progress', (data) => {
            this.broadcastToRelevantClients(data.conversation_id, {
                type: 'orchestration_progress',
                data: data
            });
        });

        // Synthesis complete
        this.synthesizer.on('orchestration_complete', (data) => {
            this.broadcastToRelevantClients(data.conversation_id, {
                type: 'synthesis_complete',
                data: data
            });
        });

        // Orchestration error
        this.synthesizer.on('orchestration_error', (data) => {
            this.broadcastToRelevantClients(data.conversation_id, {
                type: 'orchestration_error',
                data: data
            });
        });
    }

    /**
     * Load AI handlers
     */
    loadAIHandlers() {
        const handlerConfigs = [
            { name: 'claude', file: './claude_handler' },
            { name: 'gpt', file: './gpt_handler' },
            { name: 'openai', file: './gpt_handler' }, // Alias for GPT
            { name: 'deepseek', file: './deepseek_handler' },
            { name: 'gemini', file: './gemini_handler' },
            { name: 'mistral', file: './mistral_handler' },
            { name: 'llama', file: './llama_handler' },
            { name: 'ollama', file: './ollama_handler' }
        ];

        handlerConfigs.forEach(config => {
            try {
                const handler = require(`../ai-handlers/${config.file}`);
                this.aiHandlers.set(config.name, handler);
                console.log(`✅ Loaded AI handler: ${config.name}`);
            } catch (error) {
                console.warn(`⚠️ Failed to load AI handler ${config.name}:`, error.message);
            }
        });

        console.log(`🤖 Loaded ${this.aiHandlers.size} AI handlers`);
    }

    /**
     * Test model availability
     */
    async testModelAvailability(handler) {
        try {
            // Simple test request
            await handler.generateResponse('Test', {
                max_tokens: 10,
                timeout: 5000
            });
            return true;
        } catch (error) {
            return false;
        }
    }

    /**
     * Send message to specific client
     */
    sendToClient(clientId, message) {
        const client = this.clients.get(clientId);
        if (client && client.ws.readyState === WebSocket.OPEN) {
            client.ws.send(JSON.stringify(message));
        }
    }

    /**
     * Broadcast to clients with active orchestration
     */
    broadcastToRelevantClients(conversationId, message) {
        for (const [clientId, client] of this.clients) {
            if (client.activeOrchestrations.has(conversationId)) {
                this.sendToClient(clientId, message);
            }
        }
    }

    /**
     * Generate unique client ID
     */
    generateClientId() {
        return `client_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    }

    /**
     * Stop server
     */
    stop() {
        return new Promise((resolve) => {
            if (this.wss) {
                this.wss.close(() => {
                    console.log('🛑 Orchestration WebSocket server stopped');
                    resolve();
                });
            } else {
                resolve();
            }
        });
    }

    /**
     * Get server statistics
     */
    getStats() {
        return {
            connected_clients: this.clients.size,
            active_orchestrations: Array.from(this.clients.values())
                .reduce((sum, client) => sum + client.activeOrchestrations.size, 0),
            available_models: this.aiHandlers.size,
            uptime: process.uptime()
        };
    }
}

module.exports = OrchestrationWebSocketServer;

// Auto-start if run directly
if (require.main === module) {
    const server = new OrchestrationWebSocketServer();
    server.start();

    // Graceful shutdown
    process.on('SIGINT', async () => {
        console.log('\n🛑 Shutting down gracefully...');
        await server.stop();
        process.exit(0);
    });
}