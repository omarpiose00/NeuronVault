// lib/widgets/utils/demo_messages.dart - Make sure this file exists with this content

import 'package:flutter/material.dart';
import '../../models/conversation_mode.dart';
import '../../services/api_service.dart';

/// Genera messaggi demo di esempio per ciascuna modalità di conversazione
class DemoMessages {
  /// Ottiene una conversazione di esempio per la modalità selezionata
  static List<AiConversationMessage> getForMode(ConversationMode mode) {
    switch (mode) {
      case ConversationMode.chat:
        return _getChatModeDemo();
      case ConversationMode.debate:
        return _getDebateModeDemo();
      case ConversationMode.brainstorm:
        return _getBrainstormModeDemo();
    }
  }

  /// Esempio di conversazione in modalità Chat
  static List<AiConversationMessage> _getChatModeDemo() {
    final now = DateTime.now();
    return [
      AiConversationMessage(
        agent: 'user',
        message: 'Quali sono le differenze principali tra intelligenza artificiale e intelligenza umana?',
        timestamp: now.subtract(const Duration(minutes: 5)),
      ),
      AiConversationMessage(
        agent: 'claude',
        message: 'Le principali differenze tra l\'intelligenza artificiale e quella umana sono:\n\n'
            '**Creatività e intuizione**: Gli umani possono fare salti creativi e intuizioni che le AI attuali non riescono a replicare pienamente. Le AI sono limitate dai loro dati di addestramento e algoritmi.\n\n'
            '**Coscienza ed esperienza soggettiva**: Gli umani hanno un\'esperienza conscia e soggettiva del mondo, mentre le AI non hanno la capacità di "provare" o "sentire" le informazioni che elaborano.\n\n'
            '**Apprendimento generalizzato**: Gli umani possono apprendere da pochi esempi e trasferire conoscenze tra domini molto diversi, mentre le AI sono spesso specializzate e richiedono grandi quantità di dati per apprendere.',
        timestamp: now.subtract(const Duration(minutes: 4, seconds: 30)),
      ),
      AiConversationMessage(
        agent: 'gpt',
        message: 'Vorrei aggiungere alle ottime osservazioni di Claude:\n\n'
            '**Processo decisionale etico**: Gli umani prendono decisioni basate su valori etici, morali e considerazioni sociali complesse. Le AI possono essere programmate con linee guida etiche, ma mancano della comprensione innata di valori e moralità.\n\n'
            '**Velocità di elaborazione**: Le AI superano gli umani nella velocità di calcolo e nell\'elaborazione di grandi volumi di dati. Un modello AI può analizzare milioni di documenti in pochi secondi, mentre un umano impiegherebbe anni.\n\n'
            '**Comprensione contestuale**: Sebbene i modelli recenti siano migliorati, gli umani eccellono nella comprensione di sfumature, sarcasmo, ironia e contesto culturale in modi che le AI faticano ancora a cogliere completamente.',
        timestamp: now.subtract(const Duration(minutes: 3, seconds: 45)),
      ),
      AiConversationMessage(
        agent: 'deepseek',
        message: 'Sintetizzando quanto detto da Claude e GPT, possiamo identificare tre dimensioni fondamentali di differenza:\n\n'
            '1. **Dimensione cognitiva**: Le AI eccellono in compiti specifici con regole ben definite e nell\'elaborazione di enormi quantità di dati, mentre gli umani brillano nella generalizzazione, nel pensiero astratto e nei collegamenti interdisciplinari.\n\n'
            '2. **Dimensione esperienziale**: Gli umani hanno coscienza, emozioni e motivazioni intrinseche, mentre le AI operano senza una vera comprensione o esperienza soggettiva.\n\n'
            '3. **Dimensione sociale**: L\'intelligenza umana è intrinsecamente sociale, evoluta per la cooperazione e la comprensione delle dinamiche di gruppo. Le AI, pur potendo simulare interazioni sociali, non hanno un\'innata comprensione delle norme sociali o dei legami emotivi.\n\n'
            'Queste differenze suggeriscono che il futuro migliore non è quello in cui l\'IA sostituisce l\'intelligenza umana, ma dove le due forme di intelligenza collaborano, ciascuna compensando i limiti dell\'altra.',
        timestamp: now.subtract(const Duration(minutes: 2, seconds: 15)),
      ),
    ];
  }

  /// Esempio di conversazione in modalità Dibattito
  static List<AiConversationMessage> _getDebateModeDemo() {
    final now = DateTime.now();
    return [
      AiConversationMessage(
        agent: 'user',
        message: 'Il ruolo dei social media nella società moderna: benefici o danni?',
        timestamp: now.subtract(const Duration(minutes: 7)),
      ),
      AiConversationMessage(
        agent: 'system',
        message: '# Dibattito su: "Il ruolo dei social media nella società moderna: benefici o danni?"\n\nIl seguente è un dibattito strutturato tra diversi modelli AI sul tema proposto. Ogni AI presenterà argomentazioni distinte.',
        timestamp: now.subtract(const Duration(minutes: 6, seconds: 50)),
      ),
      AiConversationMessage(
        agent: 'claude',
        message: '**I social media hanno portato benefici fondamentali alla società moderna.**\n\n'
            'Innanzitutto, hanno democratizzato l\'informazione e dato voce a chi prima non ne aveva. Movimenti come #MeToo e Black Lives Matter hanno guadagnato forza grazie alla capacità dei social di amplificare voci marginali.\n\n'
            'In secondo luogo, i social media hanno creato connessioni globali senza precedenti. Famiglie separate da confini nazionali possono rimanere in contatto, comunità di interesse si formano oltre i limiti geografici, e la collaborazione internazionale è facilitata.\n\n'
            'Infine, i social media hanno stimolato innovazione e crescita economica. Hanno creato nuove industrie, permesso a piccole imprese di raggiungere audience globali, e promosso l\'economia delle creator economy dove milioni di persone possono monetizzare i propri talenti.\n\n'
            'I benefici superano i danni quando i social media vengono utilizzati consapevolmente e regolamentati adeguatamente.',
        timestamp: now.subtract(const Duration(minutes: 6)),
      ),
      AiConversationMessage(
        agent: 'gpt',
        message: '**I danni dei social media sulla società moderna superano i benefici.**\n\n'
            'Contrariamente a quanto afferma Claude, ritengo che i social media abbiano creato problemi significativi. In primo luogo, hanno alimentato una crisi di salute mentale senza precedenti. Numerosi studi collegano l\'uso intensivo dei social media a depressione, ansia e bassa autostima, specialmente tra adolescenti.\n\n'
            'Inoltre, lungi dal democratizzare l\'informazione, i social media hanno polarizzato il dibattito pubblico. Gli algoritmi progettati per massimizzare l\'engagement creano camere d\'eco dove gli utenti sono esposti solo a contenuti che confermano le loro convinzioni, alimentando estremismo e disinformazione.\n\n'
            'Infine, i social media hanno eroso la privacy personale. Il modello di business basato sulla sorveglianza raccoglie dati personali in modo invasivo per monetizzarli attraverso pubblicità mirata, influenzando comportamenti e opinioni in modi spesso non trasparenti.\n\n'
            'Questi danni non possono essere semplicemente risolti con un uso più consapevole, ma richiedono un ripensamento fondamentale delle piattaforme.',
        timestamp: now.subtract(const Duration(minutes: 5)),
      ),
      AiConversationMessage(
        agent: 'deepseek',
        message: '**Analisi e sintesi del dibattito sui social media nella società moderna**\n\n'
            '### Punti di accordo\nEntrambe le prospettive riconoscono che i social media hanno un impatto profondo sulla società. Concordano sul fatto che hanno trasformato il modo in cui comunichiamo e accediamo alle informazioni, e che esiste la necessità di qualche forma di regolamentazione o ripensamento.\n\n'
            '### Punti di disaccordo\nClaude enfatizza la democratizzazione dell\'informazione e le connessioni globali come benefici primari, mentre GPT sottolinea i problemi di salute mentale e polarizzazione. Claude vede i social come strumenti neutrali che possono essere migliorati con uso consapevole, mentre GPT suggerisce problemi strutturali nel loro modello di business.\n\n'
            '### Prospettiva equilibrata\nUna visione più nuancata riconosce che i social media non sono né interamente benefici né interamente dannosi, ma strumenti complessi con effetti diversi a seconda del contesto.\n\n'
            'La verità probabilmente si trova in un approccio che:\n'
            '1. Riconosce i benefici reali portati dai social media in termini di connessione e opportunità\n'
            '2. Affronta seriamente i problemi strutturali come gli algoritmi che favoriscono contenuti divisivi\n'
            '3. Sviluppa alfabetizzazione digitale per un uso più consapevole\n'
            '4. Implementa regolamentazioni che proteggano gli utenti senza soffocare l\'innovazione\n\n'
            'Questa terza via suggerisce che non dobbiamo scegliere tra rifiutare o abbracciare completamente i social media, ma piuttosto riprogettarli per massimizzare i benefici minimizzando i danni.',
        timestamp: now.subtract(const Duration(minutes: 3, seconds: 30)),
      ),
    ];
  }

  /// Esempio di conversazione in modalità Brainstorming
  static List<AiConversationMessage> _getBrainstormModeDemo() {
    final now = DateTime.now();
    return [
      AiConversationMessage(
        agent: 'user',
        message: 'Idee innovative per combattere l\'inquinamento da plastica nei mari',
        timestamp: now.subtract(const Duration(minutes: 8)),
      ),
      AiConversationMessage(
        agent: 'system',
        message: '# Sessione di brainstorming: "Idee innovative per combattere l\'inquinamento da plastica nei mari"\n\nLe AI collaboreranno per generare idee creative sul tema proposto, costruendo l\'una sulle idee dell\'altra.',
        timestamp: now.subtract(const Duration(minutes: 7, seconds: 40)),
      ),
      AiConversationMessage(
        agent: 'claude',
        message: '## Idee iniziali per combattere l\'inquinamento da plastica nei mari\n\n'
            '### 1. Droni subacquei autonomi per la raccolta\n'
            'Sciami di mini-droni sottomarini alimentati a energia solare che utilizzano AI per identificare e raccogliere microplastiche e detriti di varie dimensioni. Possono operare 24/7 con impatto minimo sulla vita marina.\n\n'
            '### 2. Bioplastiche marine biodegradabili\n'
            'Sviluppare imballaggi derivati da alghe che, se finiscono in acqua, diventano nutrimento per la vita marina invece di inquinare. Questi materiali potrebbero sostituire la plastica in molte applicazioni usa e getta.\n\n'
            '### 3. Sistema di incentivi basato su blockchain\n'
            'Una criptovaluta ecologica che premia le comunità costiere per la raccolta di plastica. La blockchain traccia il percorso del materiale fino al riciclo, garantendo trasparenza e responsabilità.\n\n'
            '### 4. Batteri ingegnerizzati per la biodegradazione\n'
            'Microorganismi geneticamente modificati che possono scomporre in modo sicuro le plastiche in sostanze non dannose. Potrebbero essere utilizzati in impianti di trattamento o in aree altamente inquinate sotto controllo.',
        timestamp: now.subtract(const Duration(minutes: 7)),
      ),
      AiConversationMessage(
        agent: 'gpt',
        message: 'Mi piacciono molto le idee di Claude, specialmente quella dei droni subacquei. Vorrei sviluppare ulteriormente quella e aggiungere alcune nuove idee:\n\n'
            '### Sviluppo dell\'idea dei droni subacquei\n'
            'Potremmo integrare i droni con un sistema di comunicazione mesh che permetta loro di coordinarsi nelle operazioni di pulizia. Inoltre, potrebbero incorporare sensori per raccogliere dati sullo stato dell\'ecosistema marino e sulle concentrazioni di inquinanti, creando mappe dettagliate dell\'inquinamento che aiuterebbero a identificare le fonti.\n\n'
            '### Nuove idee:\n\n'
            '#### 1. Filtri avanzati per lavatrici e scarichi\n'
            'Sistemi di filtrazione retrofit per lavatrici che catturano le microfibre sintetiche prima che entrino nel sistema idrico. Similmente, filtri per gli scarichi urbani che bloccano microplastiche prima che raggiungano fiumi e oceani.\n\n'
            '#### 2. Mercati circolari incentivati per plastiche\n'
            'Piattaforme che connettono produttori, consumatori e riciclatori, creando un\'economia circolare della plastica. Le aziende ricevono incentivi fiscali per utilizzare plastica riciclata e report di impatto ambientale positivo da condividere con i consumatori.\n\n'
            '#### 3. Packaging "intelligente" con memoria programmata\n'
            'Imballaggi che cambiano colore o struttura quando si avvicinano alla fine del ciclo di vita, ricordando ai consumatori di riciclarli. Potrebbero anche contenere codici QR con istruzioni specifiche di riciclo per quella particolare confezione.',
        timestamp: now.subtract(const Duration(minutes: 5, seconds: 30)),
      ),
      AiConversationMessage(
        agent: 'deepseek',
        message: '# Sintesi e piano d\'azione: Combattere l\'inquinamento da plastica nei mari\n\n'
            '## Le 3 idee più promettenti\n\n'
            '### 1. Sistema integrato di droni subacquei con rete di sensori\n'
            '**Piano d\'azione:**\n'
            '- Fase 1: Sviluppo di prototipi di droni con capacità di raccolta differenziata e sensori ambientali\n'
            '- Fase 2: Test pilota in aree costiere con alto livello di inquinamento\n'
            '- Fase 3: Implementazione di rete mesh e sistema di dati open source\n'
            '- Fase 4: Partnership con governi costieri per deployment su larga scala\n'
            '- Fase 5: Integrazione con programmi educativi e di citizen science\n\n'

            '### 2. Ecosistema di bioplastiche marine e packaging intelligente\n'
            '**Piano d\'azione:**\n'
            '- Fase 1: R&S intensiva su bioplastiche derivate da alghe con biodegradabilità verificata\n'
            '- Fase 2: Integrazione con tecnologie "intelligenti" per fine vita programmato\n'
            '- Fase 3: Collaborazione con grandi brand per test di mercato\n'
            '- Fase 4: Campagna di sensibilizzazione dei consumatori sui benefici\n'
            '- Fase 5: Lobbying per incentivi fiscali per produttori che adottano questi materiali\n\n'

            '### 3. Economia circolare della plastica basata su blockchain\n'
            '**Piano d\'azione:**\n'
            '- Fase 1: Sviluppo della piattaforma blockchain e token ecologico\n'
            '- Fase 2: Creazione di una rete di centri di raccolta in comunità costiere vulnerabili\n'
            '- Fase 3: Partnership con aziende di riciclo e produttori per chiudere il ciclo\n'
            '- Fase 4: Implementazione di app per consumatori per tracciare l\'impatto\n'
            '- Fase 5: Espansione globale con adattamenti culturali locali\n\n'

            '## Raccomandazione prioritaria\n'
            'L\'idea dei droni subacquei integrati con sensori dovrebbe essere prioritaria perché:\n'
            '1. Affronta sia la pulizia che il monitoraggio in un unico sistema\n'
            '2. Può essere implementata senza attendere cambiamenti regolamentari\n'
            '3. Genera dati preziosi che possono guidare future iniziative e politiche\n'
            '4. Ha alto potenziale di coinvolgimento pubblico attraverso visualizzazioni di dati\n'
            '5. Può operare autonomamente con supervisione minima\n\n'

            'Questa idea potrebbe essere implementata inizialmente attraverso partnership pubblico-private, con finanziamenti iniziali da fondazioni ambientali e possibile crowdfunding per una più ampia partecipazione pubblica.',
        timestamp: now.subtract(const Duration(minutes: 3)),
      ),
    ];
  }
}