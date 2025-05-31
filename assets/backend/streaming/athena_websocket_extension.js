// assets/backend/streaming/athena_websocket_extension.js
// 🧠 ATHENA WEBSOCKET INTEGRATION - Real-time AI Autonomy Communication
// Extension for orchestration_websocket_server.js - Phase 3.4

const AthenaMetaOrchestrator = require('../ai-handlers/athena_meta_orchestrator');

/**
 * 🧠 Athena WebSocket Extension
 * Adds AI autonomy intelligence events to existing orchestration server
 */
class AthenaWebSocketExtension {
    constructor(webSocketServer) {
        this.wss = webSocketServer;
        this.athena = AthenaMetaOrchestrator;
        this.activeAnalyses = new Map(); // Track active analyses per client

        this._setupAthenaIntegration();
        console.log('🧠 Athena WebSocket Extension initialized');
    }

    /**
     * 🚀 Setup Athena integration with existing WebSocket server
     */
    _setupAthenaIntegration() {
        // Extend server with Athena message handlers
        const originalHandleMessage = this.wss.handleClientMessage.bind(this.wss);

        // Override message handler to include Athena events
        this.wss.handleClientMessage = async (clientId, message) => {
            try {
                const data = JSON.parse(message.toString());
                const { type, data: messageData } = data;

                // Handle Athena-specific messages
                if (type.startsWith('athena:')) {
                    await this._handleAthenaMessage(clientId, type, messageData);
                    return;
                }

                // Enhanced orchestration request with Athena intelligence
                if (type === 'orchestration_request' && messageData.use_athena) {
                    await this._handleIntelligentOrchestration(clientId, messageData);
                    return;
                }

                // Fall back to original handler
                await originalHandleMessage(clientId, message);

            } catch (error) {
                console.error(`❌ Athena message handling error for ${clientId}:`, error);
                this._sendAthenaError(clientId, error.message);
            }
        };

        // Initialize Athena with environment configuration
        this._initializeAthena();
    }

    /**
     * 🧠 Handle Athena-specific WebSocket messages
     */
    async _handleAthenaMessage(clientId, messageType, messageData) {
        console.log(`🧠 Athena message from ${clientId}: ${messageType}`);

        switch (messageType) {
            case 'athena:analyze_prompt':
                await this._handlePromptAnalysis(clientId, messageData);
                break;

            case 'athena:get_analytics':
                await this._handleAnalyticsRequest(clientId);
                break;

            case 'athena:configure':
                await this._handleConfigurationUpdate(clientId, messageData);
                break;

            case 'athena:clear_history':
                await this._handleClearHistory(clientId);
                break;

            case 'athena:apply_recommendation':
                await this._handleApplyRecommendation(clientId, messageData);
                break;

            case 'athena:get_decision_tree':
                await this._handleDecisionTreeRequest(clientId, messageData);
                break;

            default:
                console.warn(`🤔 Unknown Athena message type: ${messageType}`);
                this._sendAthenaError(clientId, `Unknown message type: ${messageType}`);
        }
    }

    /**
     * 🔍 Handle intelligent prompt analysis request
     */
    async _handlePromptAnalysis(clientId, requestData) {
        const { prompt, context = {}, analysis_id } = requestData;

        try {
            // Validate request
            if (!prompt || prompt.trim().length === 0) {
                throw new Error('Empty prompt provided for analysis');
            }

            console.log(`🔍 Starting Athena analysis for client ${clientId}`);

            // Send analysis started event
            this._sendToClient(clientId, {
                type: 'athena:analysis_started',
                data: {
                    analysis_id: analysis_id || this._generateAnalysisId(),
                    prompt_length: prompt.length,
                    timestamp: new Date().toISOString()
                }
            });

            // Track active analysis
            this.activeAnalyses.set(clientId, {
                analysis_id,
                started_at: Date.now(),
                prompt: prompt.substring(0, 100) + '...'
            });

            // Perform Athena analysis
            const analysisResult = await this.athena.analyzePromptAndRecommend(prompt, {
                ...context,
                client_id: clientId,
                websocket_request: true
            });

            // Send analysis complete event
            this._sendToClient(clientId, {
                type: 'athena:analysis_complete',
                data: analysisResult
            });

            // Send individual events for real-time updates
            this._sendAnalysisEvents(clientId, analysisResult);

            console.log(`✅ Athena analysis complete for ${clientId}: ${analysisResult.analysis.primary_category.name}`);

        } catch (error) {
            console.error(`❌ Athena analysis failed for ${clientId}:`, error);

            this._sendToClient(clientId, {
                type: 'athena:analysis_error',
                data: {
                    analysis_id,
                    error: error.message,
                    timestamp: new Date().toISOString()
                }
            });
        } finally {
            // Clean up active analysis tracking
            this.activeAnalyses.delete(clientId);
        }
    }

    /**
     * 🤖 Handle intelligent orchestration with Athena recommendations
     */
    async _handleIntelligentOrchestration(clientId, requestData) {
        const { prompt, conversation_id, context = {} } = requestData;

        try {
            console.log(`🤖 Starting intelligent orchestration for ${clientId}`);

            // Step 1: Get Athena recommendations
            this._sendToClient(clientId, {
                type: 'athena:orchestration_analysis_started',
                data: {
                    conversation_id,
                    phase: 'analyzing_prompt',
                    timestamp: new Date().toISOString()
                }
            });

            const athenaAnalysis = await this.athena.analyzePromptAndRecommend(prompt, {
                ...context,
                orchestration_mode: true,
                client_id: clientId
            });

            // Step 2: Apply Athena recommendations or send for review
            if (athenaAnalysis.auto_apply_recommended) {
                console.log(`🤖 Auto-applying Athena recommendations (${(athenaAnalysis.confidence_score * 100).toFixed(1)}% confidence)`);

                // Auto-apply recommendations
                const orchestrationRequest = {
                    prompt,
                    models: athenaAnalysis.recommendations.models,
                    strategy: athenaAnalysis.recommendations.strategy,
                    weights: athenaAnalysis.recommendations.weights,
                    conversation_id,
                    athena_analysis: athenaAnalysis
                };

                // Send recommendations applied event
                this._sendToClient(clientId, {
                    type: 'athena:recommendations_applied',
                    data: {
                        conversation_id,
                        analysis: athenaAnalysis,
                        auto_applied: true,
                        timestamp: new Date().toISOString()
                    }
                });

                // Start orchestration with Athena recommendations
                await this._startIntelligentOrchestration(clientId, orchestrationRequest);

            } else {
                console.log(`🤖 Athena recommendations require review (${(athenaAnalysis.confidence_score * 100).toFixed(1)}% confidence)`);

                // Send recommendations for manual review
                this._sendToClient(clientId, {
                    type: 'athena:recommendations_ready',
                    data: {
                        conversation_id,
                        analysis: athenaAnalysis,
                        requires_approval: true,
                        timestamp: new Date().toISOString()
                    }
                });
            }

        } catch (error) {
            console.error(`❌ Intelligent orchestration failed for ${clientId}:`, error);

            this._sendToClient(clientId, {
                type: 'athena:orchestration_error',
                data: {
                    conversation_id,
                    error: error.message,
                    timestamp: new Date().toISOString()
                }
            });
        }
    }

    /**
     * 🎯 Apply Athena recommendation manually
     */
    async _handleApplyRecommendation(clientId, requestData) {
        const { analysis_id, conversation_id, approved_models, approved_strategy } = requestData;

        try {
            console.log(`🎯 Applying Athena recommendation manually for ${clientId}`);

            // Find the analysis (in a real implementation, you'd store these)
            // For now, we'll create a new orchestration request
            const orchestrationRequest = {
                conversation_id,
                models: approved_models,
                strategy: approved_strategy,
                manual_approval: true,
                analysis_id
            };

            this._sendToClient(clientId, {
                type: 'athena:recommendation_applied',
                data: {
                    conversation_id,
                    analysis_id,
                    manual_approval: true,
                    timestamp: new Date().toISOString()
                }
            });

            // Note: Would integrate with existing orchestration system here
            console.log(`✅ Athena recommendation applied manually for ${clientId}`);

        } catch (error) {
            console.error(`❌ Failed to apply Athena recommendation for ${clientId}:`, error);
            this._sendAthenaError(clientId, error.message);
        }
    }

    /**
     * 📊 Handle analytics request
     */
    async _handleAnalyticsRequest(clientId) {
        try {
            const analytics = this.athena.getAnalytics();

            this._sendToClient(clientId, {
                type: 'athena:analytics_response',
                data: {
                    analytics,
                    timestamp: new Date().toISOString()
                }
            });

        } catch (error) {
            console.error(`❌ Failed to get Athena analytics for ${clientId}:`, error);
            this._sendAthenaError(clientId, error.message);
        }
    }

    /**
     * ⚙️ Handle configuration updates
     */
    async _handleConfigurationUpdate(clientId, configData) {
        try {
            this.athena.updateConfig(configData);

            this._sendToClient(clientId, {
                type: 'athena:configuration_updated',
                data: {
                    config: configData,
                    timestamp: new Date().toISOString()
                }
            });

            console.log(`⚙️ Athena configuration updated for ${clientId}:`, configData);

        } catch (error) {
            console.error(`❌ Failed to update Athena configuration for ${clientId}:`, error);
            this._sendAthenaError(clientId, error.message);
        }
    }

    /**
     * 🧹 Handle clear history request
     */
    async _handleClearHistory(clientId) {
        try {
            await this.athena.clearAllData();

            this._sendToClient(clientId, {
                type: 'athena:history_cleared',
                data: {
                    timestamp: new Date().toISOString()
                }
            });

            console.log(`🧹 Athena history cleared for ${clientId}`);

        } catch (error) {
            console.error(`❌ Failed to clear Athena history for ${clientId}:`, error);
            this._sendAthenaError(clientId, error.message);
        }
    }

    /**
     * 🌳 Handle decision tree request
     */
    async _handleDecisionTreeRequest(clientId, requestData) {
        const { analysis_id } = requestData;

        try {
            // In a full implementation, you'd retrieve the stored decision tree
            // For now, return a sample tree structure
            const decisionTree = {
                analysis_id,
                tree: {
                    root: {
                        type: 'analysis',
                        description: 'Athena Decision Process',
                        children: [
                            {
                                type: 'category_analysis',
                                description: 'Prompt Categorization',
                                confidence: 0.85
                            },
                            {
                                type: 'model_selection',
                                description: 'AI Model Selection',
                                children: [
                                    { type: 'model', name: 'claude', reasoning: 'Strong reasoning capabilities' },
                                    { type: 'model', name: 'gpt', reasoning: 'Excellent general performance' }
                                ]
                            }
                        ]
                    }
                },
                timestamp: new Date().toISOString()
            };

            this._sendToClient(clientId, {
                type: 'athena:decision_tree_response',
                data: decisionTree
            });

        } catch (error) {
            console.error(`❌ Failed to get decision tree for ${clientId}:`, error);
            this._sendAthenaError(clientId, error.message);
        }
    }

    /**
     * 📡 Send individual analysis events for real-time updates
     */
    _sendAnalysisEvents(clientId, analysisResult) {
        // Send category detected event
        this._sendToClient(clientId, {
            type: 'athena:category_detected',
            data: {
                category: analysisResult.analysis.primary_category,
                confidence: analysisResult.analysis.confidence,
                timestamp: new Date().toISOString()
            }
        });

        // Send models recommended event
        this._sendToClient(clientId, {
            type: 'athena:models_recommended',
            data: {
                models: analysisResult.recommendations.models,
                strategy: analysisResult.recommendations.strategy,
                weights: analysisResult.recommendations.weights,
                timestamp: new Date().toISOString()
            }
        });

        // Send confidence calculated event
        this._sendToClient(clientId, {
            type: 'athena:confidence_calculated',
            data: {
                confidence_score: analysisResult.confidence_score,
                auto_apply_recommended: analysisResult.auto_apply_recommended,
                timestamp: new Date().toISOString()
            }
        });

        // Send decision tree event
        if (analysisResult.decision_tree) {
            this._sendToClient(clientId, {
                type: 'athena:decision_tree_generated',
                data: {
                    decision_tree: analysisResult.decision_tree,
                    timestamp: new Date().toISOString()
                }
            });
        }
    }

    /**
     * 🚀 Start intelligent orchestration with Athena recommendations
     */
    async _startIntelligentOrchestration(clientId, orchestrationRequest) {
        try {
            // This would integrate with the existing orchestration system
            // For now, we'll send a simulated orchestration start event

            this._sendToClient(clientId, {
                type: 'athena:intelligent_orchestration_started',
                data: {
                    conversation_id: orchestrationRequest.conversation_id,
                    models: orchestrationRequest.models,
                    strategy: orchestrationRequest.strategy,
                    athena_guided: true,
                    timestamp: new Date().toISOString()
                }
            });

            // Note: Here you would call the existing orchestration system
            // Example:
            // await this.wss.handleOrchestrationRequest(clientId, orchestrationRequest);

            console.log(`🚀 Intelligent orchestration started for ${clientId}`);

        } catch (error) {
            console.error(`❌ Failed to start intelligent orchestration for ${clientId}:`, error);
            this._sendAthenaError(clientId, error.message);
        }
    }

    /**
     * 🏗️ Initialize Athena with environment configuration
     */
    async _initializeAthena() {
        try {
            const athenaConfig = {
                enabled: process.env.ATHENA_ENABLED !== 'false',
                confidence_threshold: parseFloat(process.env.ATHENA_CONFIDENCE_THRESHOLD) || 0.8,
                learning_enabled: process.env.ATHENA_LEARNING !== 'false'
            };

            const initialized = await this.athena.initialize(
                process.env.ANTHROPIC_API_KEY,
                athenaConfig
            );

            if (initialized) {
                console.log('✅ Athena Meta-Orchestrator ready for WebSocket integration');
            } else {
                console.warn('⚠️ Athena Meta-Orchestrator initialization failed');
            }

        } catch (error) {
            console.error('❌ Athena WebSocket initialization error:', error);
        }
    }

    /**
     * 📤 Send message to specific client
     */
    _sendToClient(clientId, message) {
        if (this.wss.sendToClient) {
            this.wss.sendToClient(clientId, message);
        } else {
            // Fallback for direct WebSocket access
            const client = this.wss.clients.get(clientId);
            if (client && client.ws.readyState === 1) { // WebSocket.OPEN
                client.ws.send(JSON.stringify(message));
            }
        }
    }

    /**
     * ❌ Send Athena error to client
     */
    _sendAthenaError(clientId, errorMessage) {
        this._sendToClient(clientId, {
            type: 'athena:error',
            data: {
                message: errorMessage,
                timestamp: new Date().toISOString()
            }
        });
    }

    /**
     * 🆔 Generate unique analysis ID
     */
    _generateAnalysisId() {
        return `athena_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    }

    /**
     * 📊 Get Athena extension statistics
     */
    getStats() {
        return {
            active_analyses: this.activeAnalyses.size,
            athena_enabled: this.athena.enabled,
            athena_available: this.athena.isAvailable,
            total_decisions: this.athena.decisionHistory.length,
            learning_patterns: this.athena.learningPatterns.size
        };
    }

    /**
     * 🛑 Shutdown Athena extension
     */
    async shutdown() {
        try {
            // Clear active analyses
            this.activeAnalyses.clear();

            // Persist any remaining data
            await this.athena._persistDecisionHistory();

            console.log('🛑 Athena WebSocket Extension shutdown complete');
        } catch (error) {
            console.error('❌ Error during Athena extension shutdown:', error);
        }
    }
}

module.exports = AthenaWebSocketExtension;

// Integration helper function for existing WebSocket server
function integrateAthenaWithWebSocket(webSocketServer) {
    const athenaExtension = new AthenaWebSocketExtension(webSocketServer);

    // Add Athena stats to server stats
    const originalGetStats = webSocketServer.getStats.bind(webSocketServer);
    webSocketServer.getStats = function() {
        const baseStats = originalGetStats();
        const athenaStats = athenaExtension.getStats();

        return {
            ...baseStats,
            athena: athenaStats
        };
    };

    // Add Athena shutdown to server shutdown
    const originalStop = webSocketServer.stop.bind(webSocketServer);
    webSocketServer.stop = async function() {
        await athenaExtension.shutdown();
        return await originalStop();
    };

    return athenaExtension;
}

module.exports.integrateAthenaWithWebSocket = integrateAthenaWithWebSocket;