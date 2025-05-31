// assets/backend/ai-handlers/athena_meta_orchestrator.js
// 🧠 ATHENA META-ORCHESTRATOR - AI AUTONOMY INTELLIGENCE ENGINE
// Revolutionary AI that selects AI - Phase 3.4 Neural Luxury Implementation

const axios = require('axios');
const EventEmitter = require('events');
const fs = require('fs-extra');
const path = require('path');
const { v4: uuidv4 } = require('uuid');
const _ = require('lodash');
const BaseAIHandler = require('./base_handler');

/**
 * 🧠 Athena Meta-Orchestrator - AI Autonomy Intelligence
 * World's first AI that intelligently selects and orchestrates other AIs
 */
class AthenaMetaOrchestrator extends BaseAIHandler {
    constructor() {
        super('Athena Intelligence');

        // 🔧 Configuration
        this.enabled = false;
        this.miniLLMProvider = 'claude-haiku'; // Fast analysis model
        this.confidence_threshold = 0.8;
        this.learning_enabled = true;

        // 📊 Analytics & Learning
        this.decisionHistory = [];
        this.promptCategories = new Map();
        this.modelPerformance = new Map();
        this.learningPatterns = new Map();

        // 🎯 Available Models Registry
        this.availableModels = new Map([
            ['claude', {
                strengths: ['reasoning', 'analysis', 'creativity', 'safety'],
                speed: 0.7,
                cost: 0.8,
                reliability: 0.95
            }],
            ['gpt', {
                strengths: ['coding', 'math', 'general', 'conversation'],
                speed: 0.6,
                cost: 0.7,
                reliability: 0.92
            }],
            ['gemini', {
                strengths: ['creativity', 'multimodal', 'math', 'search'],
                speed: 0.8,
                cost: 0.9,
                reliability: 0.89
            }],
            ['deepseek', {
                strengths: ['coding', 'math', 'reasoning', 'efficiency'],
                speed: 0.9,
                cost: 0.95,
                reliability: 0.94
            }],
            ['mistral', {
                strengths: ['multilingual', 'coding', 'reasoning'],
                speed: 0.8,
                cost: 0.85,
                reliability: 0.88
            }]
        ]);

        // 🧠 Prompt Categories with Enhanced Classification
        this.promptCategories = new Map([
            ['reasoning', {
                keywords: ['analyze', 'explain', 'reasoning', 'logic', 'because', 'therefore', 'conclude'],
                patterns: /\b(why|how|analyze|reason|logic|conclusion|proof)\b/gi,
                recommendedModels: ['claude', 'deepseek', 'gpt'],
                strategy: 'consensus'
            }],
            ['creative', {
                keywords: ['create', 'write', 'story', 'poem', 'creative', 'imagine', 'design'],
                patterns: /\b(write|create|story|creative|imagine|design|brainstorm)\b/gi,
                recommendedModels: ['claude', 'gemini', 'gpt'],
                strategy: 'parallel'
            }],
            ['coding', {
                keywords: ['code', 'program', 'function', 'algorithm', 'debug', 'script', 'develop'],
                patterns: /\b(code|function|program|debug|algorithm|javascript|python|react)\b/gi,
                recommendedModels: ['deepseek', 'gpt', 'claude'],
                strategy: 'weighted'
            }],
            ['math', {
                keywords: ['calculate', 'solve', 'equation', 'formula', 'mathematics', 'compute'],
                patterns: /\b(calculate|solve|equation|math|formula|compute|number)\b/gi,
                recommendedModels: ['deepseek', 'gemini', 'gpt'],
                strategy: 'consensus'
            }],
            ['conversation', {
                keywords: ['chat', 'talk', 'discuss', 'conversation', 'opinion', 'think'],
                patterns: /\b(chat|talk|discuss|opinion|think|feel|believe)\b/gi,
                recommendedModels: ['claude', 'gpt', 'gemini'],
                strategy: 'parallel'
            }],
            ['analysis', {
                keywords: ['analyze', 'compare', 'evaluate', 'assess', 'review', 'examine'],
                patterns: /\b(analyze|compare|evaluate|assess|review|examine|contrast)\b/gi,
                recommendedModels: ['claude', 'gpt', 'deepseek'],
                strategy: 'consensus'
            }],
            ['general', {
                keywords: ['what', 'who', 'when', 'where', 'tell', 'explain'],
                patterns: /\b(what|who|when|where|tell|explain|describe)\b/gi,
                recommendedModels: ['gpt', 'claude', 'gemini'],
                strategy: 'parallel'
            }]
        ]);

        // 📁 File paths for persistence
        this.dataDir = path.join(__dirname, '..', 'data', 'athena');
        this.decisionsFile = path.join(this.dataDir, 'decision_history.json');
        this.patternsFile = path.join(this.dataDir, 'learning_patterns.json');
        this.metricsFile = path.join(this.dataDir, 'performance_metrics.json');

        this._initializeDataDirectory();
        this._loadPersistedData();

        console.log('🧠 Athena Meta-Orchestrator initialized - AI Autonomy ready');
    }

    /**
     * 🚀 Initialize Athena with API configurations
     */
    async initialize(apiKey, config = {}) {
        try {
            // Use Claude API key for mini-LLM analysis
            this.apiKey = apiKey || process.env.ANTHROPIC_API_KEY;

            if (!this.apiKey) {
                console.warn('⚠️ Athena: No Claude API key provided - analysis features limited');
                this.isAvailable = false;
                return false;
            }

            // Configuration
            this.enabled = config.enabled !== false;
            this.confidence_threshold = config.confidence_threshold || 0.8;
            this.learning_enabled = config.learning_enabled !== false;

            // Test mini-LLM connection
            await this._testMiniLLMConnection();

            this.isAvailable = true;
            console.log('✅ Athena Meta-Orchestrator initialized successfully');

            return true;
        } catch (error) {
            console.error('❌ Athena initialization failed:', error.message);
            this.isAvailable = false;
            return false;
        }
    }

    /**
     * 🧠 CORE METHOD: Analyze prompt and generate AI recommendations
     */
    async analyzePromptAndRecommend(prompt, context = {}) {
        if (!this.enabled || !this.isAvailable) {
            return this._createDisabledResponse();
        }

        const analysisId = uuidv4();
        const startTime = Date.now();

        try {
            console.log(`🔍 Athena analyzing prompt: "${prompt.substring(0, 100)}..."`);

            // Step 1: Fast prompt categorization
            const quickCategory = this._quickCategorizePrompt(prompt);

            // Step 2: Deep AI analysis with mini-LLM
            const aiAnalysis = await this._deepAnalyzeWithMiniLLM(prompt, context);

            // Step 3: Generate model recommendations
            const recommendations = this._generateModelRecommendations(
                aiAnalysis,
                quickCategory,
                context
            );

            // Step 4: Calculate confidence scores
            const confidenceScore = this._calculateOverallConfidence(
                aiAnalysis,
                recommendations,
                context
            );

            // Step 5: Create decision tree for transparency
            const decisionTree = this._createDecisionTree(
                prompt,
                aiAnalysis,
                recommendations,
                confidenceScore
            );

            // Step 6: Generate reasoning explanation
            const reasoning = this._generateReasoning(
                aiAnalysis,
                recommendations,
                confidenceScore
            );

            const result = {
                analysis_id: analysisId,
                timestamp: new Date().toISOString(),
                analysis: {
                    primary_category: aiAnalysis.category,
                    confidence: aiAnalysis.confidence,
                    complexity: aiAnalysis.complexity,
                    intent: aiAnalysis.intent,
                    keywords: aiAnalysis.keywords
                },
                recommendations: {
                    models: recommendations.models,
                    strategy: recommendations.strategy,
                    weights: recommendations.weights,
                    reasoning: reasoning
                },
                decision_tree: decisionTree,
                confidence_score: confidenceScore,
                auto_apply_recommended: confidenceScore >= this.confidence_threshold,
                processing_time_ms: Date.now() - startTime
            };

            // Step 7: Store decision for learning
            this._storeDecision(result, prompt, context);

            console.log(`✅ Athena analysis complete: ${aiAnalysis.category.name} (${(confidenceScore * 100).toFixed(1)}% confidence)`);

            return result;

        } catch (error) {
            console.error('❌ Athena analysis failed:', error);
            return this._createErrorResponse(analysisId, error, Date.now() - startTime);
        }
    }

    /**
     * 🎯 Quick prompt categorization using pattern matching
     */
    _quickCategorizePrompt(prompt) {
        const promptLower = prompt.toLowerCase();
        const scores = new Map();

        // Score each category
        for (const [categoryName, categoryData] of this.promptCategories) {
            let score = 0;

            // Keyword matching
            categoryData.keywords.forEach(keyword => {
                if (promptLower.includes(keyword)) {
                    score += 2;
                }
            });

            // Pattern matching
            const patternMatches = (prompt.match(categoryData.patterns) || []).length;
            score += patternMatches * 3;

            scores.set(categoryName, score);
        }

        // Find best match
        const sortedScores = Array.from(scores.entries())
            .sort((a, b) => b[1] - a[1]);

        const bestMatch = sortedScores[0];
        const confidence = bestMatch[1] > 0 ? Math.min(bestMatch[1] / 10, 1.0) : 0.3;

        return {
            name: bestMatch[0],
            confidence: confidence,
            all_scores: Object.fromEntries(scores)
        };
    }

    /**
     * 🔬 Deep analysis using mini-LLM (Claude Haiku for speed)
     */
    async _deepAnalyzeWithMiniLLM(prompt, context) {
        const analysisPrompt = `# AI Prompt Analysis Task

You are Athena, an AI meta-orchestrator that analyzes prompts to recommend optimal AI models and strategies.

**Prompt to analyze:** "${prompt}"

**Context:** ${JSON.stringify(context, null, 2)}

**Available AI Models:**
- Claude: Excellent for reasoning, analysis, creativity, safety-focused
- GPT-4: Strong at coding, math, general knowledge, conversation
- Gemini: Creative, multimodal, mathematical, search-capable
- DeepSeek: Fast coding, mathematical reasoning, efficiency-focused
- Mistral: Multilingual, coding, reasoning

**Analysis Categories:**
- reasoning, creative, coding, math, conversation, analysis, general

**Your task:** Analyze this prompt and provide a JSON response with:

\`\`\`json
{
  "category": {
    "name": "primary_category_name",
    "confidence": 0.85
  },
  "complexity": "low|medium|high",
  "intent": "brief description of user intent",
  "keywords": ["key", "relevant", "words"],
  "recommended_strategy": "parallel|consensus|weighted|adaptive",
  "reasoning": "Brief explanation of your analysis"
}
\`\`\`

Be concise and accurate. Focus on the core task type and optimal orchestration approach.`;

        try {
            const response = await axios.post(
                'https://api.anthropic.com/v1/messages',
                {
                    model: 'claude-3-haiku-20240307', // Fast model for analysis
                    max_tokens: 500,
                    messages: [{ role: 'user', content: analysisPrompt }],
                    temperature: 0.3 // Low temperature for consistency
                },
                {
                    headers: {
                        'x-api-key': this.apiKey,
                        'anthropic-version': '2023-06-01',
                        'Content-Type': 'application/json',
                    },
                    timeout: 10000 // 10 second timeout for speed
                }
            );

            // Parse JSON response
            const aiResponse = response.data.content[0].text.trim();
            const jsonMatch = aiResponse.match(/```json\n([\s\S]*?)\n```/);

            if (jsonMatch) {
                const analysisResult = JSON.parse(jsonMatch[1]);

                return {
                    category: analysisResult.category,
                    complexity: analysisResult.complexity || 'medium',
                    intent: analysisResult.intent || 'General assistance',
                    keywords: analysisResult.keywords || [],
                    confidence: analysisResult.category.confidence || 0.7,
                    ai_reasoning: analysisResult.reasoning || 'AI analysis complete',
                    recommended_strategy: analysisResult.recommended_strategy || 'parallel'
                };
            } else {
                throw new Error('Invalid JSON response from mini-LLM');
            }

        } catch (error) {
            console.warn('⚠️ Mini-LLM analysis failed, using fallback:', error.message);

            // Fallback to quick categorization
            const quickResult = this._quickCategorizePrompt(prompt);
            return {
                category: quickResult,
                complexity: 'medium',
                intent: 'General assistance (fallback)',
                keywords: [],
                confidence: quickResult.confidence * 0.8, // Reduced confidence for fallback
                ai_reasoning: 'Fallback analysis due to mini-LLM unavailability',
                recommended_strategy: 'parallel'
            };
        }
    }

    /**
     * 🎯 Generate model recommendations based on analysis
     */
    _generateModelRecommendations(aiAnalysis, quickCategory, context) {
        const categoryName = aiAnalysis.category.name;
        const categoryData = this.promptCategories.get(categoryName);

        if (!categoryData) {
            console.warn(`⚠️ Unknown category: ${categoryName}, using general recommendations`);
            return this._getDefaultRecommendations();
        }

        // Base recommendations from category
        let recommendedModels = [...categoryData.recommendedModels];
        let strategy = aiAnalysis.recommended_strategy || categoryData.strategy;

        // Apply learning patterns if available
        if (this.learning_enabled) {
            const learningAdjustments = this._applyLearningPatterns(
                categoryName,
                aiAnalysis,
                context
            );

            if (learningAdjustments.models.length > 0) {
                recommendedModels = learningAdjustments.models;
            }

            if (learningAdjustments.strategy) {
                strategy = learningAdjustments.strategy;
            }
        }

        // Generate weights based on model strengths for this category
        const weights = this._calculateModelWeights(recommendedModels, categoryData);

        // Limit to top 3 models for performance
        const topModels = recommendedModels.slice(0, 3);

        return {
            models: topModels,
            strategy: strategy,
            weights: weights,
            category_data: categoryData
        };
    }

    /**
     * 📊 Calculate model weights based on strengths and performance
     */
    _calculateModelWeights(models, categoryData) {
        const weights = {};

        models.forEach(modelName => {
            const modelData = this.availableModels.get(modelName);
            if (!modelData) {
                weights[modelName] = 1.0;
                return;
            }

            // Base weight from model reliability
            let weight = modelData.reliability;

            // Adjust based on category fit
            const categoryKeywords = categoryData.keywords || [];
            const strengthMatches = modelData.strengths.filter(strength =>
                categoryKeywords.some(keyword =>
                    keyword.includes(strength) || strength.includes(keyword)
                )
            ).length;

            // Boost weight for strength matches
            weight += strengthMatches * 0.1;

            // Historical performance adjustment
            const historicalPerformance = this.modelPerformance.get(modelName);
            if (historicalPerformance) {
                weight *= (historicalPerformance.success_rate || 1.0);
            }

            weights[modelName] = Math.min(weight, 2.0); // Cap at 2.0
        });

        return weights;
    }

    /**
     * 🎯 Calculate overall confidence score
     */
    _calculateOverallConfidence(aiAnalysis, recommendations, context) {
        let confidence = 0;

        // Base confidence from AI analysis
        confidence += aiAnalysis.confidence * 0.4;

        // Model availability confidence
        const availableModels = recommendations.models.filter(model =>
            this.availableModels.has(model)
        );
        const availabilityScore = availableModels.length / recommendations.models.length;
        confidence += availabilityScore * 0.3;

        // Historical success rate
        const avgSuccessRate = this._getAverageSuccessRate(recommendations.models);
        confidence += avgSuccessRate * 0.2;

        // Complexity adjustment
        const complexityMultiplier = {
            'low': 1.1,
            'medium': 1.0,
            'high': 0.9
        };
        confidence *= complexityMultiplier[aiAnalysis.complexity] || 1.0;

        // Learning pattern confidence boost
        if (this.learning_enabled && this._hasRelevantLearningData(aiAnalysis.category.name)) {
            confidence += 0.1;
        }

        return Math.min(Math.max(confidence, 0.0), 1.0);
    }

    /**
     * 🌳 Create decision tree for transparency
     */
    _createDecisionTree(prompt, aiAnalysis, recommendations, confidenceScore) {
        return {
            root: {
                type: 'analysis',
                description: 'Prompt Analysis',
                children: [
                    {
                        type: 'category',
                        description: `Categorized as: ${aiAnalysis.category.name}`,
                        confidence: aiAnalysis.category.confidence,
                        children: [
                            {
                                type: 'model_selection',
                                description: 'Model Selection Process',
                                children: recommendations.models.map(model => ({
                                    type: 'model',
                                    name: model,
                                    weight: recommendations.weights[model] || 1.0,
                                    reasoning: this._getModelSelectionReasoning(model, aiAnalysis.category.name)
                                }))
                            },
                            {
                                type: 'strategy',
                                description: `Strategy: ${recommendations.strategy}`,
                                reasoning: this._getStrategyReasoning(recommendations.strategy, aiAnalysis)
                            }
                        ]
                    },
                    {
                        type: 'confidence',
                        description: `Overall Confidence: ${(confidenceScore * 100).toFixed(1)}%`,
                        auto_apply: confidenceScore >= this.confidence_threshold
                    }
                ]
            },
            metadata: {
                created_at: new Date().toISOString(),
                analysis_id: uuidv4(),
                prompt_length: prompt.length,
                processing_time: Date.now() - Date.now()
            }
        };
    }

    /**
     * 💭 Generate human-readable reasoning
     */
    _generateReasoning(aiAnalysis, recommendations, confidenceScore) {
        const category = aiAnalysis.category.name;
        const models = recommendations.models.join(', ');
        const strategy = recommendations.strategy;

        let reasoning = `Based on analysis, this appears to be a ${category} task with ${(aiAnalysis.confidence * 100).toFixed(1)}% confidence. `;

        reasoning += `Recommended models: ${models} using ${strategy} strategy. `;

        if (confidenceScore >= this.confidence_threshold) {
            reasoning += `High confidence (${(confidenceScore * 100).toFixed(1)}%) suggests auto-apply is appropriate.`;
        } else {
            reasoning += `Moderate confidence (${(confidenceScore * 100).toFixed(1)}%) recommends manual review.`;
        }

        if (aiAnalysis.ai_reasoning) {
            reasoning += ` AI Analysis: ${aiAnalysis.ai_reasoning}`;
        }

        return reasoning;
    }

    /**
     * 📚 Apply learning patterns from historical data
     */
    _applyLearningPatterns(categoryName, aiAnalysis, context) {
        const patterns = this.learningPatterns.get(categoryName);

        if (!patterns || patterns.decisions.length < 5) {
            return { models: [], strategy: null };
        }

        // Find most successful pattern
        const successfulDecisions = patterns.decisions
            .filter(d => d.success_score > 0.8)
            .sort((a, b) => b.success_score - a.success_score);

        if (successfulDecisions.length > 0) {
            const bestPattern = successfulDecisions[0];
            return {
                models: bestPattern.models,
                strategy: bestPattern.strategy
            };
        }

        return { models: [], strategy: null };
    }

    /**
     * 💾 Store decision for learning and analytics
     */
    _storeDecision(analysisResult, prompt, context) {
        const decision = {
            id: analysisResult.analysis_id,
            timestamp: analysisResult.timestamp,
            prompt_hash: this._hashPrompt(prompt),
            category: analysisResult.analysis.primary_category.name,
            models: analysisResult.recommendations.models,
            strategy: analysisResult.recommendations.strategy,
            confidence: analysisResult.confidence_score,
            auto_applied: analysisResult.auto_apply_recommended,
            context: context
        };

        // Add to in-memory history
        this.decisionHistory.push(decision);

        // Limit history size
        if (this.decisionHistory.length > 1000) {
            this.decisionHistory = this.decisionHistory.slice(-500);
        }

        // Update learning patterns
        this._updateLearningPatterns(decision);

        // Persist to disk (async)
        this._persistDecisionHistory().catch(console.error);
    }

    /**
     * 🧠 Update learning patterns based on new decisions
     */
    _updateLearningPatterns(decision) {
        const categoryName = decision.category;

        if (!this.learningPatterns.has(categoryName)) {
            this.learningPatterns.set(categoryName, {
                decisions: [],
                success_rate: 0,
                last_updated: new Date().toISOString()
            });
        }

        const pattern = this.learningPatterns.get(categoryName);
        pattern.decisions.push(decision);
        pattern.last_updated = new Date().toISOString();

        // Calculate success rate (placeholder - would need feedback mechanism)
        pattern.success_rate = pattern.decisions.length > 0 ?
            pattern.decisions.filter(d => d.confidence > 0.8).length / pattern.decisions.length : 0;

        // Limit pattern history
        if (pattern.decisions.length > 100) {
            pattern.decisions = pattern.decisions.slice(-50);
        }
    }

    /**
     * 🔄 Get Athena statistics and analytics
     */
    getAnalytics() {
        const totalDecisions = this.decisionHistory.length;
        const recentDecisions = this.decisionHistory.slice(-50);

        const categoryBreakdown = {};
        const strategyBreakdown = {};
        const modelUsage = {};

        recentDecisions.forEach(decision => {
            // Category breakdown
            categoryBreakdown[decision.category] = (categoryBreakdown[decision.category] || 0) + 1;

            // Strategy breakdown
            strategyBreakdown[decision.strategy] = (strategyBreakdown[decision.strategy] || 0) + 1;

            // Model usage
            decision.models.forEach(model => {
                modelUsage[model] = (modelUsage[model] || 0) + 1;
            });
        });

        const avgConfidence = recentDecisions.length > 0 ?
            recentDecisions.reduce((sum, d) => sum + d.confidence, 0) / recentDecisions.length : 0;

        const autoApplyRate = recentDecisions.length > 0 ?
            recentDecisions.filter(d => d.auto_applied).length / recentDecisions.length : 0;

        return {
            enabled: this.enabled,
            available: this.isAvailable,
            total_decisions: totalDecisions,
            recent_decisions: recentDecisions.length,
            average_confidence: avgConfidence,
            auto_apply_rate: autoApplyRate,
            confidence_threshold: this.confidence_threshold,
            category_breakdown: categoryBreakdown,
            strategy_breakdown: strategyBreakdown,
            model_usage: modelUsage,
            learning_patterns: this.learningPatterns.size,
            last_analysis: this.decisionHistory.length > 0 ?
                this.decisionHistory[this.decisionHistory.length - 1].timestamp : null
        };
    }

    // ===========================================
    // UTILITY & HELPER METHODS
    // ===========================================

    _createDisabledResponse() {
        return {
            analysis_id: uuidv4(),
            timestamp: new Date().toISOString(),
            enabled: false,
            message: 'Athena Intelligence is currently disabled',
            recommendations: {
                models: ['claude', 'gpt'],
                strategy: 'parallel',
                weights: { claude: 1.0, gpt: 1.0 },
                reasoning: 'Default fallback recommendations'
            },
            confidence_score: 0.5,
            auto_apply_recommended: false
        };
    }

    _createErrorResponse(analysisId, error, processingTime) {
        return {
            analysis_id: analysisId,
            timestamp: new Date().toISOString(),
            error: true,
            message: error.message,
            recommendations: {
                models: ['claude', 'gpt'],
                strategy: 'parallel',
                weights: { claude: 1.0, gpt: 1.0 },
                reasoning: 'Error fallback recommendations'
            },
            confidence_score: 0.3,
            auto_apply_recommended: false,
            processing_time_ms: processingTime
        };
    }

    _getDefaultRecommendations() {
        return {
            models: ['claude', 'gpt', 'gemini'],
            strategy: 'parallel',
            weights: { claude: 1.0, gpt: 1.0, gemini: 1.0 }
        };
    }

    _getAverageSuccessRate(models) {
        let totalRate = 0;
        let count = 0;

        models.forEach(model => {
            const performance = this.modelPerformance.get(model);
            if (performance) {
                totalRate += performance.success_rate || 0.8;
                count++;
            }
        });

        return count > 0 ? totalRate / count : 0.8; // Default 80%
    }

    _hasRelevantLearningData(categoryName) {
        const pattern = this.learningPatterns.get(categoryName);
        return pattern && pattern.decisions.length >= 5;
    }

    _getModelSelectionReasoning(model, category) {
        const modelData = this.availableModels.get(model);
        if (!modelData) return 'Model data unavailable';

        const relevantStrengths = modelData.strengths.filter(strength =>
            category.includes(strength) || strength.includes(category)
        );

        return relevantStrengths.length > 0 ?
            `Strong in: ${relevantStrengths.join(', ')}` :
            `General capability (${modelData.reliability * 100}% reliability)`;
    }

    _getStrategyReasoning(strategy, aiAnalysis) {
        const strategyReasons = {
            'parallel': 'Multiple perspectives enhance output quality',
            'consensus': 'Agreement between models increases reliability',
            'weighted': 'Model strengths vary for this task type',
            'sequential': 'Complex task benefits from iterative refinement',
            'adaptive': 'Dynamic strategy selection based on prompt analysis'
        };

        return strategyReasons[strategy] || 'Optimal for this task type';
    }

    async _testMiniLLMConnection() {
        const testPrompt = 'Respond with just "OK" to confirm connection.';

        const response = await axios.post(
            'https://api.anthropic.com/v1/messages',
            {
                model: 'claude-3-haiku-20240307',
                max_tokens: 10,
                messages: [{ role: 'user', content: testPrompt }]
            },
            {
                headers: {
                    'x-api-key': this.apiKey,
                    'anthropic-version': '2023-06-01',
                    'Content-Type': 'application/json',
                },
                timeout: 5000
            }
        );

        if (!response.data.content[0].text.includes('OK')) {
            throw new Error('Mini-LLM connection test failed');
        }
    }

    _hashPrompt(prompt) {
        // Simple hash for prompt deduplication
        let hash = 0;
        for (let i = 0; i < prompt.length; i++) {
            const char = prompt.charCodeAt(i);
            hash = ((hash << 5) - hash) + char;
            hash = hash & hash; // Convert to 32-bit integer
        }
        return hash.toString(36);
    }

    async _initializeDataDirectory() {
        try {
            await fs.ensureDir(this.dataDir);
        } catch (error) {
            console.warn('⚠️ Could not create Athena data directory:', error.message);
        }
    }

    async _loadPersistedData() {
        try {
            // Load decision history
            if (await fs.pathExists(this.decisionsFile)) {
                const data = await fs.readJson(this.decisionsFile);
                this.decisionHistory = data.decisions || [];
            }

            // Load learning patterns
            if (await fs.pathExists(this.patternsFile)) {
                const data = await fs.readJson(this.patternsFile);
                this.learningPatterns = new Map(Object.entries(data.patterns || {}));
            }

            // Load performance metrics
            if (await fs.pathExists(this.metricsFile)) {
                const data = await fs.readJson(this.metricsFile);
                this.modelPerformance = new Map(Object.entries(data.metrics || {}));
            }

            console.log(`📚 Loaded ${this.decisionHistory.length} decisions, ${this.learningPatterns.size} patterns`);

        } catch (error) {
            console.warn('⚠️ Could not load Athena persisted data:', error.message);
        }
    }

    async _persistDecisionHistory() {
        try {
            const data = {
                decisions: this.decisionHistory.slice(-500), // Keep last 500
                last_updated: new Date().toISOString(),
                version: '1.0'
            };

            await fs.writeJson(this.decisionsFile, data, { spaces: 2 });

            // Also persist learning patterns
            const patternsData = {
                patterns: Object.fromEntries(this.learningPatterns),
                last_updated: new Date().toISOString()
            };

            await fs.writeJson(this.patternsFile, patternsData, { spaces: 2 });

        } catch (error) {
            console.warn('⚠️ Could not persist Athena data:', error.message);
        }
    }

    /**
     * 🧹 Clear all stored data and reset Athena
     */
    async clearAllData() {
        this.decisionHistory = [];
        this.learningPatterns.clear();
        this.modelPerformance.clear();

        try {
            await fs.remove(this.dataDir);
            await this._initializeDataDirectory();
            console.log('🧹 Athena data cleared successfully');
        } catch (error) {
            console.warn('⚠️ Could not clear Athena data directory:', error.message);
        }
    }

    /**
     * ⚙️ Update Athena configuration
     */
    updateConfig(config) {
        if (config.enabled !== undefined) this.enabled = config.enabled;
        if (config.confidence_threshold !== undefined) this.confidence_threshold = config.confidence_threshold;
        if (config.learning_enabled !== undefined) this.learning_enabled = config.learning_enabled;

        console.log('⚙️ Athena configuration updated:', {
            enabled: this.enabled,
            confidence_threshold: this.confidence_threshold,
            learning_enabled: this.learning_enabled
        });
    }
}

// Export singleton instance
module.exports = new AthenaMetaOrchestrator();