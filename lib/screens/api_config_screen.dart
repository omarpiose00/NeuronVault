import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_key_manager.dart';
import '../providers/app_state_provider.dart';
import '../widgets/ui/glass_container.dart';

class ApiConfigScreen extends StatefulWidget {
  final bool isInitialSetup;

  const ApiConfigScreen({
    Key? key,
    this.isInitialSetup = false,
  }) : super(key: key);

  @override
  State<ApiConfigScreen> createState() => _ApiConfigScreenState();
}

class _ApiConfigScreenState extends State<ApiConfigScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _enabledModels = {};
  bool _isLoading = false;
  bool _isTestingKeys = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeControllers();
    _loadSettings();
  }

  void _initializeControllers() {
    final apiKeyManager = Provider.of<ApiKeyManager>(context, listen: false);

    // Inizializza i controller per ciascun provider
    for (final provider in apiKeyManager.supportedProviders) {
      _controllers[provider] = TextEditingController();
      _enabledModels[provider] = false;
    }
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    try {
      final apiKeyManager = Provider.of<ApiKeyManager>(context, listen: false);
      await apiKeyManager.loadKeys();

      // Carica le chiavi dai controller
      for (final provider in apiKeyManager.supportedProviders) {
        _controllers[provider]?.text = apiKeyManager.getKey(provider) ?? '';
        _enabledModels[provider] = apiKeyManager.isEnabled(provider);
      }
    } catch (e) {
      _showErrorSnackbar('Errore nel caricamento delle configurazioni: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final apiKeyManager = Provider.of<ApiKeyManager>(context, listen: false);

      // Salva tutte le chiavi API
      for (final provider in apiKeyManager.supportedProviders) {
        final controller = _controllers[provider];
        if (controller != null) {
          if (controller.text.isNotEmpty) {
            await apiKeyManager.setKey(provider, controller.text);
          } else {
            await apiKeyManager.removeKey(provider);
          }

          await apiKeyManager.setEnabled(provider, _enabledModels[provider] ?? false);
        }
      }

      await apiKeyManager.saveKeys();

      // Se è il primo avvio, segna come completato
      if (widget.isInitialSetup) {
        final appState = Provider.of<AppStateProvider>(context, listen: false);
        appState.markInitialSetupComplete();

        // Vai alla home
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // Torna indietro
        Navigator.of(context).pop();
      }

      _showSuccessSnackbar('Configurazione salvata con successo!');
    } catch (e) {
      _showErrorSnackbar('Errore nel salvataggio delle configurazioni: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testApiKeys() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isTestingKeys = true);

    try {
      final apiKeyManager = Provider.of<ApiKeyManager>(context, listen: false);
      final results = <String, bool>{};

      // Testa solo le chiavi attive
      for (final provider in apiKeyManager.supportedProviders) {
        if (_controllers[provider]?.text.isEmpty != false ||
            _enabledModels[provider] != true) {
          continue;
        }

        // Salva temporaneamente la chiave per il test
        await apiKeyManager.setKey(provider, _controllers[provider]!.text);

        // Esegui test della chiave
        results[provider] = await apiKeyManager.testKey(provider);
      }

      // Mostra i risultati
      _showTestResultsDialog(results);
    } catch (e) {
      _showErrorSnackbar('Errore nel test delle chiavi API: $e');
    } finally {
      setState(() => _isTestingKeys = false);
    }
  }

  void _showTestResultsDialog(Map<String, bool> results) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Risultati del test'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: results.length,
            itemBuilder: (context, index) {
              final provider = results.keys.elementAt(index);
              final isValid = results[provider]!;

              return ListTile(
                leading: Icon(
                  isValid ? Icons.check_circle : Icons.error,
                  color: isValid ? Colors.green : Colors.red,
                ),
                title: Text(_getProviderName(provider)),
                subtitle: Text(isValid
                    ? 'Chiave API valida'
                    : 'Chiave API non valida o servizio non disponibile'
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Chiudi'),
          ),
        ],
      ),
    );
  }

  String _getProviderName(String provider) {
    switch (provider) {
      case 'openai': return 'OpenAI (GPT)';
      case 'anthropic': return 'Anthropic (Claude)';
      case 'deepseek': return 'DeepSeek';
      case 'google': return 'Google (Gemini)';
      case 'cohere': return 'Cohere';
      case 'mistral': return 'Mistral AI';
      case 'meta': return 'Meta AI (Llama)';
      case 'ollama': return 'Ollama (Locale)';
      default: return provider.toUpperCase();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: widget.isInitialSetup
          ? null
          : AppBar(
        title: const Text('Configurazione Modelli AI'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GlassContainer(
        margin: const EdgeInsets.all(16),
        borderRadius: 16,
        blur: 10,
        backgroundColor: isDark
            ? Colors.black.withOpacity(0.5)
            : Colors.white.withOpacity(0.7),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (widget.isInitialSetup) ...[
                const SizedBox(height: 40),
                Icon(
                  Icons.psychology,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                Text(
                  'Multi-AI Team',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Configura le chiavi API dei modelli di intelligenza artificiale che desideri utilizzare',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onBackground.withOpacity(0.8),
                    ),
                  ),
                ),
              ],

              // TabBar per categorizzare i provider AI
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Principali'),
                  Tab(text: 'Avanzati'),
                  Tab(text: 'Locali'),
                ],
                labelColor: theme.colorScheme.primary,
                indicatorColor: theme.colorScheme.primary,
              ),

              // TabBarView con i form per i vari provider
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Modelli principali
                    _buildMainModelsTab(),

                    // Tab 2: Modelli avanzati
                    _buildAdvancedModelsTab(),

                    // Tab 3: Modelli locali
                    _buildLocalModelsTab(),
                  ],
                ),
              ),

              // Pulsanti di azione
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (!widget.isInitialSetup)
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Annulla'),
                      )
                    else
                      const SizedBox.shrink(),

                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isTestingKeys ? null : _testApiKeys,
                          icon: _isTestingKeys
                              ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                              : const Icon(Icons.check_circle_outline),
                          label: const Text('Testa Connessioni'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.secondary,
                            foregroundColor: theme.colorScheme.onSecondary,
                          ),
                        ),

                        const SizedBox(width: 16),

                        ElevatedButton(
                          onPressed: _isLoading ? null : _saveSettings,
                          child: Text(widget.isInitialSetup ? 'Inizia' : 'Salva'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainModelsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Modelli AI Principali',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // OpenAI (GPT)
          _buildApiKeyField(
            'openai',
            'OpenAI API Key',
            'Utilizzata per GPT-3.5, GPT-4 e GPT-4o',
            'Inserisci la tua chiave API OpenAI',
            'Ottieni su: platform.openai.com',
          ),

          // Anthropic (Claude)
          _buildApiKeyField(
            'anthropic',
            'Anthropic API Key',
            'Utilizzata per i modelli Claude',
            'Inserisci la tua chiave API Anthropic',
            'Ottieni su: console.anthropic.com',
          ),

          // DeepSeek
          _buildApiKeyField(
            'deepseek',
            'DeepSeek API Key',
            'Utilizzata per i modelli DeepSeek',
            'Inserisci la tua chiave API DeepSeek',
            'Ottieni su: platform.deepseek.ai',
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedModelsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Modelli AI Avanzati',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Google (Gemini)
          _buildApiKeyField(
            'google',
            'Google AI API Key',
            'Utilizzata per i modelli Gemini',
            'Inserisci la tua chiave API Google AI (Gemini)',
            'Ottieni su: ai.google.dev',
          ),

          // Cohere
          _buildApiKeyField(
            'cohere',
            'Cohere API Key',
            'Utilizzata per i modelli Command',
            'Inserisci la tua chiave API Cohere',
            'Ottieni su: dashboard.cohere.com',
          ),

          // Mistral
          _buildApiKeyField(
            'mistral',
            'Mistral AI API Key',
            'Utilizzata per i modelli Mistral',
            'Inserisci la tua chiave API Mistral AI',
            'Ottieni su: console.mistral.ai',
          ),
        ],
      ),
    );
  }

  Widget _buildLocalModelsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Modelli AI Locali o Self-Hosted',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Meta AI (Llama)
          _buildApiKeyField(
            'meta',
            'Meta AI API Key o Endpoint',
            'Utilizzata per i modelli Llama',
            'Inserisci la tua chiave API o URL endpoint',
            'Ottieni su: ai.meta.com o specifica un endpoint locale',
            isUrlField: true,
          ),

          // Ollama (locale)
          _buildApiKeyField(
            'ollama',
            'Ollama Endpoint',
            'Endpoint per Ollama (locale)',
            'Inserisci l\'indirizzo del server Ollama (es. localhost:11434)',
            'Lascia vuoto per localhost:11434',
            isUrlField: true,
          ),

          const SizedBox(height: 24),

          // Informazioni sui modelli locali
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Supporto per modelli locali',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Multi-AI Team supporta la connessione con server locali di modelli, come Ollama. '
                      'Per utilizzare Ollama, assicurati che sia in esecuzione sul tuo sistema prima di avviare l\'app.',
                ),
                SizedBox(height: 16),
                Text(
                  'Esempio: localhost:11434 o 192.168.1.100:11434',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiKeyField(
      String provider,
      String label,
      String description,
      String hint,
      String helpText, {
        bool isUrlField = false,
      }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Switch(
                value: _enabledModels[provider] ?? false,
                onChanged: (value) {
                  setState(() {
                    _enabledModels[provider] = value;
                  });
                },
                activeColor: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: (_enabledModels[provider] ?? false)
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onBackground.withOpacity(0.6),
                ),
              ),
            ],
          ),

          if (_enabledModels[provider] ?? false) ...[
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),

            TextFormField(
              controller: _controllers[provider],
              decoration: InputDecoration(
                hintText: hint,
                helperText: helpText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(isUrlField ? Icons.link : Icons.key),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.visibility_off),
                  onPressed: () {
                    // Toggle visibility (da implementare)
                  },
                ),
              ),
              obscureText: !isUrlField,
              validator: (value) {
                if ((_enabledModels[provider] ?? false) && (value == null || value.isEmpty)) {
                  return 'Inserisci un valore valido';
                }
                return null;
              },
            ),
          ],
        ],
      ),
    );
  }
}