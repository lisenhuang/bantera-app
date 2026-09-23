// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'Bantera';

  @override
  String get appTagline => 'Pratica le lingue, frase per frase.';

  @override
  String get authContinueWithApple => 'Continua con Apple';

  @override
  String get authContinueWithGoogle => 'Continua con Google';

  @override
  String get authAppleUnavailable =>
      'Accedi con Apple non è disponibile su questo dispositivo.';

  @override
  String get authOrSignInEmail => 'oppure accedi con l\'email';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authSigningIn => 'Accesso in corso...';

  @override
  String get authSignIn => 'Accedi';

  @override
  String get authSignInWithEmail => 'Accedi con l\'email';

  @override
  String get validationEnterEmail => 'Inserisci la tua email.';

  @override
  String get validationValidEmail => 'Inserisci un\'email valida.';

  @override
  String get validationEnterPassword => 'Inserisci la tua password.';

  @override
  String get onboardingTitle => 'Configura il tuo profilo';

  @override
  String get onboardingSubtitle =>
      'Così Bantera può personalizzare pratica e chat.';

  @override
  String get onboardingNameTitle => 'Come vuoi che ti chiamino?';

  @override
  String get onboardingNameSubtitle =>
      'L\'abbiamo preso dal tuo account, se fornito da Apple. Puoi modificarlo ora.';

  @override
  String get onboardingClearName => 'Cancella nome';

  @override
  String get onboardingNativeLanguageTitle => 'Qual è la tua lingua madre?';

  @override
  String get onboardingNativeLanguageSubtitle =>
      'Bantera la usa per le traduzioni e i gruppi linguistici.';

  @override
  String get onboardingLearningLanguageTitle => 'Quale lingua stai imparando?';

  @override
  String get onboardingLearningLanguageSubtitle =>
      'Determina i contenuti di pratica e i gruppi di apprendimento.';

  @override
  String get onboardingAvatarTitle => 'Aggiungi un\'immagine del profilo';

  @override
  String get onboardingAvatarSubtitle =>
      'Scegli una foto, oppure continua e Bantera ne genererà una per te.';

  @override
  String get onboardingAvatarGenderTitle =>
      'Genera la tua immagine del profilo';

  @override
  String get onboardingAvatarGenderBody =>
      'Scegli come Bantera deve generare la tua immagine del profilo. Non salviamo questa scelta: serve solo per questa immagine.';

  @override
  String get onboardingAvatarGenderMale => 'Uomo';

  @override
  String get onboardingAvatarGenderFemale => 'Donna';

  @override
  String get onboardingChoosePhoto => 'Scegli foto';

  @override
  String get onboardingChangePhoto => 'Cambia foto';

  @override
  String get onboardingUseGeneratedAvatar => 'Usa invece un avatar generato';

  @override
  String get onboardingUseCurrentPhoto => 'Usa la foto attuale';

  @override
  String get onboardingChooseLanguage => 'Scegli la lingua';

  @override
  String get onboardingBack => 'Indietro';

  @override
  String get onboardingFinish => 'Fine';

  @override
  String get onboardingLoadingProfile => 'Caricamento profilo...';

  @override
  String get onboardingSavingProfile => 'Salvataggio profilo...';

  @override
  String get onboardingLoadFailed => 'Si è verificato un errore. Riprova.';

  @override
  String get onboardingSearchHint => 'Cerca lingue…';

  @override
  String get onboardingRetry => 'Riprova';

  @override
  String get onboardingNoMatching => 'Nessuna lingua trovata.';

  @override
  String get onboardingFailedSave => 'Salvataggio non riuscito.';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get sectionAppearance => 'Aspetto';

  @override
  String get sectionAccount => 'Account';

  @override
  String get sectionRateAndShare => 'Valuta e condividi';

  @override
  String get sectionLanguage => 'Lingua dell\'app';

  @override
  String get sectionPermissions => 'Autorizzazioni';

  @override
  String get sectionNotifications => 'Notifiche';

  @override
  String get languageSectionSubtitle =>
      'Scegli la lingua dell\'app. \"Sistema\" segue le impostazioni del dispositivo.';

  @override
  String get themeLabel => 'Tema';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeDark => 'Scuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get languageEnglish => 'Inglese';

  @override
  String get languageChineseSimplified => 'Cinese (semplificato)';

  @override
  String get languageKorean => 'Coreano';

  @override
  String get languageJapanese => 'Giapponese';

  @override
  String get signedOutLabel => 'Disconnesso';

  @override
  String get noActiveSession => 'Nessuna sessione Bantera attiva';

  @override
  String signedInWith(String provider) {
    return 'Accesso effettuato con $provider';
  }

  @override
  String get editProfile => 'Modifica profilo';

  @override
  String get more => 'Altro';

  @override
  String get appPermissionsTitle => 'Autorizzazioni app';

  @override
  String get appPermissionsSubtitle =>
      'Controlla gli accessi che Bantera usa su questo dispositivo.';

  @override
  String get permissionsIntro =>
      'Bantera usa queste impostazioni del dispositivo per la registrazione, il confronto vocale e l\'accesso alla rete.';

  @override
  String get permissionsOpenSettings => 'Apri Impostazioni di iPhone';

  @override
  String get permissionsRefresh => 'Aggiorna';

  @override
  String get permissionMicrophoneTitle => 'Microfono';

  @override
  String get permissionMicrophoneDescription =>
      'Registra i tuoi tentativi di pratica e i messaggi vocali.';

  @override
  String get permissionSpeechTitle => 'Riconoscimento vocale';

  @override
  String get permissionSpeechDescription =>
      'Trascrivi le registrazioni di pratica e i messaggi vocali.';

  @override
  String get permissionMobileDataTitle => 'Dati cellulare';

  @override
  String get permissionMobileDataDescription =>
      'Usa Bantera quando iPhone non è connesso al Wi-Fi.';

  @override
  String get permissionStatusAllowed => 'Consentito';

  @override
  String get permissionStatusLimited => 'Limitato';

  @override
  String get permissionStatusNotAllowed => 'Non consentito';

  @override
  String get permissionStatusUnknown => 'Sconosciuto';

  @override
  String get signOut => 'Esci';

  @override
  String get signOutDialogTitle => 'Vuoi uscire?';

  @override
  String get signOutDialogBody =>
      'Dovrai accedere di nuovo per usare il tuo account.';

  @override
  String get cancel => 'Annulla';

  @override
  String get closeLabel => 'Chiudi';

  @override
  String get navDiscover => 'Scopri';

  @override
  String get navCreate => 'Crea';

  @override
  String get navProfile => 'Profilo';

  @override
  String get chatsTitle => 'Chat';

  @override
  String get chatNoChatsYet => 'Ancora nessuna chat.';

  @override
  String get chatOnlineSection => 'Online';

  @override
  String get chatDirectMessagesSection => 'Messaggi';

  @override
  String chatAudioDuration(String duration) {
    return 'Audio $duration';
  }

  @override
  String get chatEnableNotifications => 'Attiva notifiche';

  @override
  String get chatMuteNotifications => 'Silenzia notifiche';

  @override
  String get chatBlockUser => 'Blocca utente';

  @override
  String get chatDeleteDm => 'Elimina chat';

  @override
  String get chatCall => 'Chiama';

  @override
  String get chatStartAudioCall => 'Chiamata vocale';

  @override
  String get chatStartVideoCall => 'Videochiamata';

  @override
  String get chatAudioCalling => 'Chiamata vocale in corso...';

  @override
  String get chatVideoCalling => 'Videochiamata in corso...';

  @override
  String get chatAudioIncoming => 'Chiamata vocale in arrivo';

  @override
  String get chatVideoIncoming => 'Videochiamata in arrivo';

  @override
  String get chatCallConnecting => 'Connessione...';

  @override
  String get chatCallAccept => 'Accetta';

  @override
  String get chatCallDecline => 'Rifiuta';

  @override
  String get chatCallEnd => 'Termina';

  @override
  String get chatCallMute => 'Silenzia';

  @override
  String get chatCallUnmute => 'Riattiva audio';

  @override
  String get chatCallSpeaker => 'Altoparlante';

  @override
  String get chatCallCamera => 'Fotocamera';

  @override
  String get chatCallSwitchCamera => 'Cambia';

  @override
  String get chatCallIssueTitle => 'Problema con la chiamata';

  @override
  String get chatCallMicrophoneDenied =>
      'Bantera ha bisogno dell\'accesso al microfono per avviare una chiamata.';

  @override
  String get chatCallMicrophoneSettings =>
      'L\'accesso al microfono è disattivato per Bantera. Apri Impostazioni e attivalo per le chiamate.';

  @override
  String get chatCallCameraDenied =>
      'Bantera ha bisogno dell\'accesso alla fotocamera per avviare una videochiamata.';

  @override
  String get chatCallCameraSettings =>
      'L\'accesso alla fotocamera è disattivato per Bantera. Apri Impostazioni e attivalo per le videochiamate.';

  @override
  String get chatCallBusy =>
      'Questo utente è già impegnato in un\'altra chiamata.';

  @override
  String get chatCallUnavailable =>
      'Questo utente non è disponibile per una chiamata in questo momento.';

  @override
  String get chatCallNetworkRestricted =>
      'Questa rete non riesce a connettere la chiamata. Prova con il Wi-Fi o un\'altra rete.';

  @override
  String get chatCallFailed => 'Impossibile avviare la chiamata. Riprova.';

  @override
  String get chatGroupReady => 'Questo gruppo è pronto per i messaggi vocali.';

  @override
  String get chatHoldToStartDm =>
      'Tieni premuto per registrare e iniziare la chat.';

  @override
  String get chatNoGroupAudio => 'Ancora nessun audio nel gruppo.';

  @override
  String get chatNoDmAudio => 'Ancora nessun audio in questa chat.';

  @override
  String get chatSendingAudio => 'Invio audio...';

  @override
  String get chatRecordingReleaseToSend =>
      'Registrazione... rilascia per inviare';

  @override
  String get chatHoldToRecordAudio => 'Tieni premuto per registrare';

  @override
  String get chatRecordingStatus => 'Registrazione...';

  @override
  String get chatGroupLabel => 'Gruppo';

  @override
  String get chatNotificationsEnabledForDm =>
      'Notifiche attivate per questa chat.';

  @override
  String get chatNotificationsMutedForDm =>
      'Notifiche silenziate per questa chat.';

  @override
  String chatBlockUserTitle(String user) {
    return 'Vuoi bloccare $user?';
  }

  @override
  String get chatBlockUserBody =>
      'Non vi vedrete più nei messaggi diretti e nei messaggi dei gruppi in comune finché non sblocchi questo utente.';

  @override
  String chatBlockUserSuccess(String user) {
    return 'Hai bloccato $user.';
  }

  @override
  String get chatBlockUserFailed =>
      'Impossibile bloccare questo utente. Riprova.';

  @override
  String get chatDeleteMessage => 'Elimina messaggio';

  @override
  String get chatDeleteMessageTitle => 'Vuoi eliminare questo messaggio?';

  @override
  String get chatDeleteMessageBody =>
      'Il messaggio verrà rimosso per tutti i partecipanti alla conversazione. L\'azione non può essere annullata.';

  @override
  String get chatDeleteMessageSuccess => 'Messaggio eliminato';

  @override
  String get chatDeleteMessageFailed =>
      'Impossibile eliminare il messaggio. Riprova.';

  @override
  String get chatDeleteDmTitle => 'Vuoi eliminare questa chat?';

  @override
  String get chatDeleteDmBody =>
      'Verrà rimossa solo dal tuo elenco. Un nuovo messaggio potrà riportarla indietro.';

  @override
  String get chatMicrophoneRequiredTitle => 'Microfono necessario';

  @override
  String get chatMicrophoneRequiredSettings =>
      'Bantera ha bisogno dell\'accesso al microfono per registrare audio in chat. Attivalo in Impostazioni.';

  @override
  String get chatMicrophoneRequiredBody =>
      'Bantera ha bisogno dell\'accesso al microfono per registrare audio in chat.';

  @override
  String get chatGroupNotReady => 'Questo gruppo non è ancora pronto.';

  @override
  String get chatMessageAction => 'Messaggio';

  @override
  String get chatRetranscribe => 'Trascrivi di nuovo';

  @override
  String get chatTranscribe => 'Trascrivi';

  @override
  String get chatTranscribingOnDevice => 'Trascrizione su iPhone...';

  @override
  String get chatTranscriptionFailed => 'Trascrizione non riuscita. Riprova.';

  @override
  String get chatTranslate => 'Traduci';

  @override
  String get chatRetranslate => 'Traduci di nuovo';

  @override
  String get chatTranslating => 'Traduzione su iPhone...';

  @override
  String get chatTranslationFailed => 'Traduzione non riuscita. Riprova.';

  @override
  String get chatGroupSettingsTitle => 'Impostazioni gruppo';

  @override
  String get chatNotifications => 'Notifiche';

  @override
  String get chatBlockedUsersMenu => 'Utenti bloccati';

  @override
  String get chatBlockedUsersTitle => 'Utenti bloccati';

  @override
  String get chatBlockedPeople => 'Persone bloccate';

  @override
  String get chatNoBlockedUsers => 'Nessun utente bloccato.';

  @override
  String get chatNoBlockedPeople => 'Nessuna persona bloccata.';

  @override
  String get chatUnblock => 'Sblocca';

  @override
  String chatUnblockUserTitle(String user) {
    return 'Vuoi sbloccare $user?';
  }

  @override
  String get chatUnblockUserBody =>
      'Potreste vedervi di nuovo nei messaggi diretti e nei messaggi dei gruppi in comune.';

  @override
  String get chatUnblockFailed =>
      'Impossibile sbloccare questo utente. Riprova.';

  @override
  String get chatNotificationsTitle => 'Notifiche chat';

  @override
  String get chatNotificationsSubtitle =>
      'Un unico interruttore per l\'account, valido su tutti i tuoi dispositivi.';

  @override
  String get chatNotificationsDisabledTitle => 'Notifiche disattivate';

  @override
  String get chatNotificationsDisabledSettings =>
      'Attiva le notifiche in Impostazioni per ricevere gli avvisi delle chat di Bantera.';

  @override
  String get chatNotificationsDisabledBody =>
      'Bantera ha bisogno dell\'autorizzazione alle notifiche per attivare gli avvisi delle chat.';

  @override
  String get chatNotificationUpdateFailed =>
      'Impossibile aggiornare le notifiche delle chat. Riprova.';

  @override
  String get savedTitle => 'Contenuti salvati';

  @override
  String get generateWithAiTitle => 'Genera con l\'IA';

  @override
  String get practiceLocalVideoTitle => 'Pratica con un video locale';

  @override
  String get uploadVideoTitle => 'Carica video';

  @override
  String get lessonDetailsTitle => 'Dettagli lezione';

  @override
  String get accountMoreTitle => 'Altro';

  @override
  String get deleteAccount => 'Elimina account';

  @override
  String get deleteAccountSubtitle =>
      'Rimuovi definitivamente il tuo account e i dati sul server';

  @override
  String get confirmDeletionTitle => 'Conferma eliminazione';

  @override
  String get deleteAccountImmediateBody =>
      'Il tuo account verrà eliminato subito. Per usare di nuovo Bantera dovrai creare un nuovo account.';

  @override
  String get deleteAccountConfirm => 'Elimina account';

  @override
  String get couldNotDeleteAccount =>
      'Impossibile eliminare l\'account. Riprova.';

  @override
  String get deleteAccountQuestionTitle => 'Vuoi eliminare l\'account?';

  @override
  String get deleteAccountQuestionBody =>
      'Tutte le tue informazioni personali e i tuoi dati verranno rimossi definitivamente dai nostri server e non potranno essere recuperati.';

  @override
  String get typeDeleteLabel => 'Scrivi \"DELETE\" per continuare';

  @override
  String get continueLabel => 'Continua';

  @override
  String get confirmLabel => 'Conferma';

  @override
  String get deleteLabel => 'Elimina';

  @override
  String get removeFromListLabel => 'Rimuovi dall\'elenco';

  @override
  String get startLabel => 'Inizia';

  @override
  String get doneLabel => 'Fine';

  @override
  String get discoverSearchHint => 'Cerca titolo o trascrizione…';

  @override
  String get discoverNoMoreResults => 'Nessun altro risultato';

  @override
  String get discoverSetLearningLanguagePrompt =>
      'Imposta la lingua che stai imparando per vedere i contenuti';

  @override
  String discoverNoPublicContentInLanguage(String language) {
    return 'Ancora nessun contenuto pubblico in $language';
  }

  @override
  String get discoverSetLanguageToDiscover =>
      'Imposta una lingua da imparare per scoprire i contenuti';

  @override
  String get mediaStartPractice => 'Inizia a esercitarti';

  @override
  String get mediaTranscript => 'Trascrizione';

  @override
  String mediaTranscriptLineCount(int count) {
    return '($count righe)';
  }

  @override
  String get mediaShow => 'Mostra';

  @override
  String get mediaHide => 'Nascondi';

  @override
  String get mediaNoTranscriptAvailable => 'Nessuna trascrizione disponibile.';

  @override
  String get lessonSaveTooltip => 'Salva';

  @override
  String get lessonUnsaveTooltip => 'Rimuovi dai salvati';

  @override
  String get mediaKindAudio => 'Audio';

  @override
  String get mediaKindVideo => 'Video';

  @override
  String get practiceNoCues => 'Nessuna frase';

  @override
  String get practiceTranslating => 'Traduzione…';

  @override
  String get practiceShowTranscript => 'Mostra trascrizione';

  @override
  String get practiceTranslate => 'Traduci';

  @override
  String get practiceHideText => 'Nascondi testo';

  @override
  String get practiceTextLabel => 'Testo';

  @override
  String get practiceStop => 'Stop';

  @override
  String get practicePlayAll => 'Shadowing';

  @override
  String get practiceCompare => 'Confronta';

  @override
  String get practiceRecord => 'Registra';

  @override
  String get practiceStopRecording => 'Stop';

  @override
  String get practiceRecords => 'Registrazioni';

  @override
  String get practiceRecordsLocalOnlyFooter =>
      'I tentativi vengono salvati solo su questo dispositivo e non vengono caricati.';

  @override
  String get practiceRecordsEmpty =>
      'Ancora nessun tentativo salvato per questa frase.';

  @override
  String get practiceRecordingProcessError =>
      'Si è verificato un errore durante l\'elaborazione della registrazione.';

  @override
  String get practiceStartOver => 'Ricomincia';

  @override
  String get practiceTranscriptHidden => 'Trascrizione nascosta';

  @override
  String get practiceListenCarefully => 'Ascolta con attenzione…';

  @override
  String get practiceTranslationUnavailableForCue =>
      'Traduzione non disponibile per questa frase al momento.';

  @override
  String get practiceChooseTranslationLanguageTitle =>
      'Scegli la lingua di traduzione';

  @override
  String get practiceChooseTranslationLanguageDescription =>
      'Bantera tradurrà gli esercizi di ascolto in questa lingua e la salverà nel tuo profilo per le prossime sessioni.';

  @override
  String get practiceChangeTranslationLanguageTitle =>
      'Cambia lingua di traduzione';

  @override
  String get practiceChangeTranslationLanguageDescription =>
      'Scegli la lingua in cui Bantera deve tradurre. La nuova scelta verrà salvata nel tuo profilo.';

  @override
  String get practiceConfirmTranslationLanguageTitle =>
      'Conferma lingua di traduzione';

  @override
  String get practiceConfirmTranslationLanguageBody =>
      'Bantera salverà questa lingua nel tuo profilo e la userà come lingua di traduzione predefinita nei prossimi esercizi di ascolto.';

  @override
  String get practiceCouldNotSaveTranslationLanguage =>
      'Bantera non è riuscita a salvare la lingua di traduzione.';

  @override
  String get practiceNoTranslationLanguagesFound =>
      'Bantera non ha trovato lingue di traduzione per questa trascrizione.';

  @override
  String get practicePlayAllTitle => 'Shadowing';

  @override
  String get practicePlayAllDescription =>
      'Pausa tra le frasi per lo shadowing:';

  @override
  String get practicePlayAllPauseZeroSeconds => '0 s';

  @override
  String get practicePlayAllPauseOneSecondLabel => '1 s';

  @override
  String get practicePlayAllPauseOneCuePlusOneSecond => '1 frase + 1 s';

  @override
  String get practicePlayAllPauseOneCuePlusTwoSeconds => '1 frase + 2 s';

  @override
  String get practicePlayAllTimesPerCueTitle => 'Ripetizioni per frase';

  @override
  String get practicePlayAllTimesOnce => '1×';

  @override
  String get practicePlayAllTimesTwice => '2×';

  @override
  String get practicePlayAllTimesThrice => '3×';

  @override
  String get practiceSearchLanguagesHint => 'Cerca lingue';

  @override
  String get practiceTranslationInstalled => 'Installata';

  @override
  String get practiceTranslationDownload => 'Scarica';

  @override
  String get practiceStartOverTitle => 'Vuoi ricominciare?';

  @override
  String get practiceStartOverBody => 'Tornare alla prima frase?';

  @override
  String get practiceNextFromLastTitle => 'Andare alla prima frase?';

  @override
  String get practiceNextFromLastBody =>
      'Sei all\'ultima frase. Vuoi tornare alla prima?';

  @override
  String get practiceGoToFirstCue => 'Vai alla prima frase';

  @override
  String get practiceVideoOpenError =>
      'Impossibile aprire il video selezionato per la pratica.';

  @override
  String get practiceAudioLoading => 'Caricamento audio…';

  @override
  String practiceAudioLoadingPercent(int percent) {
    return 'Caricamento audio $percent%';
  }

  @override
  String get practiceAudioError => 'Impossibile caricare l\'audio. Riprova.';

  @override
  String get compareRecordYourVersion => 'Registra la tua versione';

  @override
  String compareTranscriptionLanguage(String locale) {
    return 'Lingua di trascrizione: $locale';
  }

  @override
  String get compareOpenIphoneSettings => 'Apri Impostazioni di iPhone';

  @override
  String get comparePauseAttempt => 'Metti in pausa';

  @override
  String get comparePlayAttempt => 'Riproduci tentativo';

  @override
  String get compareYourTranscribedAttempt => 'Il tuo tentativo trascritto';

  @override
  String get compareHighlightHint =>
      'Le parole che Bantera ha riconosciuto in modo diverso sono evidenziate.';

  @override
  String get compareUncertainHint =>
      'Le parole sottolineate a puntini sono state riconosciute, ma Bantera non ne è sicura: controlla la pronuncia.';

  @override
  String get compareTryAgain => 'Riprova';

  @override
  String get compareDone => 'Fine';

  @override
  String get compareStatusTranscribing =>
      'Trascrizione del tentativo su iPhone…';

  @override
  String get compareStatusRecording =>
      'Registrazione… Tocca di nuovo per fermare.';

  @override
  String get compareStatusSavedAttempt =>
      'Stai vedendo un tentativo salvato per questa frase. Puoi riascoltarlo o riprovare.';

  @override
  String get compareStatusReplayOrRetry =>
      'Puoi riascoltare questo tentativo o riprovare la frase.';

  @override
  String get compareStatusTapToRecord =>
      'Tocca per registrare la tua versione di questa frase.';

  @override
  String get compareCouldNotStartRecording =>
      'Bantera non riesce ad avviare la registrazione in questo momento.';

  @override
  String get compareCouldNotAccessRecording =>
      'Bantera non riesce ad accedere all\'audio registrato.';

  @override
  String get compareNoTranscriptGenerated =>
      'Impossibile generare una trascrizione per questo tentativo. Riprova più vicino al microfono.';

  @override
  String get compareRecentAttempts => 'Tentativi recenti';

  @override
  String get compareAttemptsFooterNote =>
      'Bantera conserva i tuoi tentativi su questo iPhone, così puoi vedere i progressi sulla stessa frase.';

  @override
  String compareMatchedCount(int count) {
    return '$count corrette';
  }

  @override
  String compareDifferentCount(int count) {
    return '$count diverse';
  }

  @override
  String compareMissingCount(int count) {
    return '$count mancanti';
  }

  @override
  String compareUncertainCount(int count) {
    return '$count incerte';
  }

  @override
  String get compareMicrophoneDeniedPermanent =>
      'L\'accesso al microfono è disattivato per Bantera. Apri Impostazioni > Bantera > Microfono su iPhone e attivalo per registrare la tua versione.';

  @override
  String get compareMicrophoneDeniedRestricted =>
      'Questo iPhone sta limitando l\'accesso al microfono per Bantera. Controlla Tempo di utilizzo, la gestione del dispositivo o le impostazioni di sistema per attivarlo.';

  @override
  String get compareMicrophoneDeniedDefault =>
      'Serve l\'autorizzazione al microfono per registrare la tua versione. Se in precedenza hai ignorato la richiesta, apri Impostazioni > Bantera > Microfono su iPhone e attivalo.';

  @override
  String get compareSpeechRecognitionDeniedPermanent =>
      'L\'accesso al riconoscimento vocale è disattivato per Bantera. Apri Impostazioni > Bantera > Riconoscimento vocale su iPhone e attivalo per confrontare la tua registrazione.';

  @override
  String get compareSpeechRecognitionDeniedRestricted =>
      'Questo iPhone sta limitando il riconoscimento vocale per Bantera. Controlla Tempo di utilizzo, la gestione del dispositivo o le impostazioni di sistema per attivarlo.';

  @override
  String get compareSpeechRecognitionUnavailable =>
      'Il riconoscimento vocale non è disponibile su questo iPhone al momento.';

  @override
  String get compareSpeechRecognitionUnsupportedLocale =>
      'Il riconoscimento vocale non è disponibile per questa lingua su questo iPhone.';

  @override
  String get comparePlayAttemptTooltip => 'Riproduci tentativo';

  @override
  String get comparePauseAttemptTooltip => 'Metti in pausa il tentativo';

  @override
  String get createWhatToday => 'Cosa vuoi fare oggi?';

  @override
  String get createPracticeVideo => 'Pratica con un video';

  @override
  String get createYourMedia => 'I tuoi contenuti';

  @override
  String get createTryAgain => 'Riprova';

  @override
  String get createUploadedVideosEmptyHint =>
      'I video che carichi appariranno qui, così potrai riaprirli ed esercitarti frase per frase.';

  @override
  String get createUploadingTips => 'Consigli per il caricamento';

  @override
  String get createUploadingTipsBody =>
      'Mantieni l\'audio sotto i 3 minuti per un risultato migliore. I sottotitoli vengono generati automaticamente!';

  @override
  String get createOnThisIphone => 'Su questo iPhone';

  @override
  String get createLocalVideosEmptyHint =>
      'I video con cui ti eserciti in locale verranno salvati su questo iPhone, così potrai riaprirli senza trascriverli di nuovo.';

  @override
  String get createOnDeviceBadge => 'Sul dispositivo';

  @override
  String get createSignInToLoadVideos =>
      'Accedi di nuovo per caricare i tuoi video.';

  @override
  String createVideoMetaCues(int count) {
    return '$count frasi';
  }

  @override
  String get createPublicBadge => 'Pubblico';

  @override
  String get createPrivateBadge => 'Privato';

  @override
  String get createAiBadge => 'IA';

  @override
  String get createDeleteSavedVideoTitle => 'Vuoi eliminare il video salvato?';

  @override
  String createDeleteSavedVideoBody(String title) {
    return 'Bantera rimuoverà \"$title\" da questo iPhone ed eliminerà le frasi della trascrizione salvata.';
  }

  @override
  String get createDeleteMediaTitle => 'Vuoi eliminare il contenuto?';

  @override
  String createDeleteMediaBody(String title) {
    return '\"$title\" e la sua trascrizione verranno eliminati definitivamente. L\'azione non può essere annullata.';
  }

  @override
  String get removeFromListTitle => 'Vuoi rimuoverlo dall\'elenco?';

  @override
  String get removeFromListBody =>
      'Verrà rimosso dall\'elenco. L\'azione non può essere annullata.';

  @override
  String get editProfileChangeImage => 'Cambia immagine del profilo';

  @override
  String get editProfileUploading => 'Caricamento…';

  @override
  String get editProfileNameLabel => 'Nome';

  @override
  String get editProfileNameHint => 'Come vuoi che Bantera mostri il tuo nome?';

  @override
  String get editProfileSaveNameButton => 'Salva nome';

  @override
  String get editProfileSaving => 'Salvataggio…';

  @override
  String get editProfileLanguagesSection => 'Lingue';

  @override
  String get editProfileMyNativeLanguage => 'La mia lingua madre';

  @override
  String get editProfileMyNativeLanguageSubtitle =>
      'La tua lingua madre o prima lingua';

  @override
  String get editProfileLearningLanguage => 'Lingua che stai imparando';

  @override
  String get editProfileLearningLanguageSubtitle =>
      'La lingua con cui vuoi esercitarti';

  @override
  String get editProfileImageUpdated => 'Immagine del profilo aggiornata.';

  @override
  String get editProfileNameUpdated => 'Nome aggiornato.';

  @override
  String get editProfileEnterName => 'Inserisci un nome.';

  @override
  String get editProfileNameMaxLength => 'Usa al massimo 80 caratteri.';

  @override
  String get editProfileCouldNotLoadLanguages =>
      'Impossibile caricare l\'elenco delle lingue.';

  @override
  String get languagePickerNone => 'Nessuna';

  @override
  String get languagePickerClearSelection => 'Cancella selezione';

  @override
  String get languagePickerNoMatchingLanguages => 'Nessuna lingua trovata.';

  @override
  String get languagePickerMoreComingSoon => 'Altre lingue in arrivo';

  @override
  String get editProfileNativeLanguageCleared => 'Lingua madre rimossa.';

  @override
  String get editProfileLearningLanguageCleared =>
      'Lingua da imparare rimossa.';

  @override
  String editProfileNativeLanguageSetTo(String language) {
    return 'Lingua madre impostata su $language.';
  }

  @override
  String editProfileLearningLanguageSetTo(String language) {
    return 'Lingua da imparare impostata su $language.';
  }

  @override
  String get profileLanguageSettings => 'Impostazioni lingua';

  @override
  String get profileLearningLabel => 'Sto imparando';

  @override
  String get profileNotSet => 'Non impostata';

  @override
  String get uploadedDetailYourAudio => 'Il tuo audio';

  @override
  String get uploadedDetailYourVideo => 'Il tuo video';

  @override
  String get uploadedDetailDeleteAudioTitle => 'Vuoi eliminare l\'audio?';

  @override
  String get uploadedDetailDeleteAudioBody =>
      'L\'audio e la sua trascrizione verranno eliminati definitivamente. L\'azione non può essere annullata.';

  @override
  String get uploadedDetailDeleteVideoTitle => 'Vuoi eliminare il video?';

  @override
  String get uploadedDetailDeleteVideoBody =>
      'Il video e la sua trascrizione verranno eliminati definitivamente. L\'azione non può essere annullata.';

  @override
  String get uploadedDetailAiGenerated => 'Generato con IA';

  @override
  String get uploadedDetailFileSize => 'Dimensioni file';

  @override
  String get uploadedDetailResolution => 'Risoluzione';

  @override
  String get uploadedDetailResolutionUnknown => 'Sconosciuta';

  @override
  String get uploadedDetailTranscribing => 'Trascrizione…';

  @override
  String get uploadedDetailNoTranscriptCuesYet =>
      'Nessuna frase della trascrizione ancora disponibile.';

  @override
  String uploadedDetailMediaDescription(int count) {
    return 'La tua clip di pratica caricata, con $count frasi trascritte.';
  }

  @override
  String get uploadedDetailTranscriptionFailedFallback =>
      'Trascrizione non riuscita. Verranno usate frasi stimate.';

  @override
  String get uploadedDetailTranscriptionNoCues =>
      'La trascrizione non ha restituito alcuna frase.';

  @override
  String get uploadedDetailTranscriptionSourceYourUpload =>
      'Il tuo caricamento';

  @override
  String get aiGenLeaveTitle => 'Vuoi uscire da questa pagina?';

  @override
  String get aiGenLeaveBody =>
      'L\'audio è ancora in fase di generazione. Se esci ora, il processo verrà annullato.';

  @override
  String get aiGenStay => 'Resta';

  @override
  String get aiGenLeave => 'Esci';

  @override
  String get aiGenLoadingTitle => 'Creazione del tuo audio…';

  @override
  String get aiGenLoadingSubtitle =>
      'Potrebbe volerci fino a un minuto.\nResta su questa pagina durante la generazione.';

  @override
  String get aiGenStepPreparingSpeechModel =>
      'Preparazione del modello vocale sul dispositivo';

  @override
  String get aiGenStepWritingDialogue => 'Scrittura del dialogo';

  @override
  String get aiGenStepGeneratingAudio => 'Generazione dell\'audio';

  @override
  String get aiGenStepAligningAudio => 'Allineamento dell\'audio';

  @override
  String get aiGenStepTranscribing => 'Trascrizione';

  @override
  String get aiGenStepCorrectingTranscript => 'Correzione della trascrizione';

  @override
  String get aiGenLanguageSection => 'Lingua';

  @override
  String get aiGenSetLearningLanguagePrompt =>
      'Imposta la lingua che stai imparando per attivare la generazione';

  @override
  String get aiGenLoadingLanguage => 'Caricamento lingua…';

  @override
  String aiGenLanguageUnsupported(String language) {
    return 'La lingua \"$language\" non è supportata per la generazione.';
  }

  @override
  String get aiGenScenarioSection => 'Scenario';

  @override
  String get aiGenScenarioOptionalHint =>
      'Facoltativo: se non scegli nulla, lo scenario sarà casuale.';

  @override
  String get aiGenCustomScenarioHint => 'Descrivi il tuo scenario…';

  @override
  String get aiGenDurationSection => 'Durata';

  @override
  String aiGenDurationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get aiGenGenerateButton => 'Genera';

  @override
  String get aiGenOwnershipNotice =>
      'L\'audio che generi qui diventa contenuto della community di Bantera, condiviso pubblicamente come materiale di pratica per tutti gli studenti.';

  @override
  String get aiGenOwnershipCheckbox =>
      'Condividi questo audio come contenuto della community di Bantera';

  @override
  String get aiGenOwnershipConfirmTitle =>
      'Condividere come contenuto della community?';

  @override
  String get aiGenOwnershipConfirmCancel => 'Annulla';

  @override
  String get aiGenOwnershipConfirmGenerate => 'Genera';

  @override
  String get aiGenFooterNotice =>
      'L\'IA scriverà un dialogo a due voci e lo trasformerà in audio. Il risultato verrà salvato come audio di pratica pubblico.';

  @override
  String get aiScenarioCoffeeShop => 'Al bar';

  @override
  String get aiScenarioLatestNews => 'Ultime notizie';

  @override
  String get aiScenarioAirportReunion => 'Incontro in aeroporto';

  @override
  String get aiScenarioGroceryStore => 'Al supermercato';

  @override
  String get aiScenarioDoctorVisit => 'Visita dal medico';

  @override
  String get aiScenarioJobInterview => 'Colloquio di lavoro';

  @override
  String get aiScenarioNewNeighbour => 'Nuovo vicino';

  @override
  String get aiScenarioTechSupport => 'Assistenza tecnica';

  @override
  String get aiScenarioBirthdaySurprise => 'Sorpresa di compleanno';

  @override
  String get aiScenarioGymTips => 'Consigli in palestra';

  @override
  String get aiScenarioWeatherSmalltalk => 'Due chiacchiere sul tempo';

  @override
  String get aiScenarioRestaurantOrder => 'Ordinare al ristorante';

  @override
  String get aiScenarioBookRecommendation => 'Consiglio di lettura';

  @override
  String get aiScenarioBusDelay => 'Autobus in ritardo';

  @override
  String get aiScenarioMovieDebate => 'Discussione su un film';

  @override
  String get aiScenarioCustom => 'Personalizzato…';

  @override
  String get errorNetworkUnreachable =>
      'Impossibile connettersi a Bantera. Controlla la connessione a Internet.';

  @override
  String get errorNetworkCellularBlocked =>
      'I dati cellulare sono disattivati per Bantera. In Impostazioni, apri Bantera e attiva Dati cellulare, oppure connettiti a una rete Wi-Fi.';

  @override
  String get errorTlsConnection =>
      'Impossibile stabilire una connessione sicura.';

  @override
  String get settingsRateAppPrompt =>
      'Ti piace Bantera? Una valutazione veloce sull\'App Store per noi conta molto.';

  @override
  String get settingsRateAppButton => 'Valuta sull\'App Store';

  @override
  String get settingsSharePrompt =>
      'Conosci qualcuno che sta imparando una lingua? Condividi Bantera.';

  @override
  String get settingsShareButton => 'Condividi Bantera';

  @override
  String get settingsContactButton => 'Contattaci';

  @override
  String get localVideoDescription =>
      'Scegli un video da Foto, seleziona la lingua parlata e lascia che iPhone lo trascriva in background prima di esercitarti frase per frase.';

  @override
  String get localVideoStep1Title => '1. Scegli il video';

  @override
  String get localVideoChooseFromPhotos => 'Scegli da Foto';

  @override
  String get localVideoChooseDifferent => 'Scegli un altro video';

  @override
  String get localVideoSelectedFileLabel => 'File selezionato';

  @override
  String get localVideoSizeLabel => 'Dimensioni';

  @override
  String get localVideoDurationLabel => 'Durata';

  @override
  String get localVideoLongVideoWarning =>
      'Questo video dura più di 3 minuti, quindi Bantera potrebbe impiegare più tempo a preparare trascrizione e traduzione.';

  @override
  String get localVideoStep2Title => '2. Lingua di trascrizione';

  @override
  String get localVideoChooseLanguagePlaceholder => 'Scegli la lingua parlata';

  @override
  String get localVideoLanguageHint =>
      'Bantera ricorda la tua ultima scelta di lingua e, una volta iniziata la pratica, nasconde la trascrizione per impostazione predefinita.';

  @override
  String get localVideoStep3Title => '3. Esercitati';

  @override
  String get localVideoPreparing => 'Preparazione...';

  @override
  String get localVideoPracticeHint =>
      'Bantera trascrive prima sul dispositivo, poi apre la pagina di ascolto frase per frase senza caricare nulla.';

  @override
  String get localVideoStatusLongVideo =>
      'Questo video è piuttosto lungo, quindi Bantera potrebbe impiegare più tempo per trascriverlo e prepararlo.';

  @override
  String get localVideoStatusTranscribing =>
      'Trascrizione sul dispositivo e preparazione delle frasi...';

  @override
  String get localVideoStatusSaving =>
      'Salvataggio del video nella tua libreria di pratica sul dispositivo...';

  @override
  String get localVideoStatusTranslationLong =>
      'Trascrizione completata. Bantera sta preparando anche la traduzione nella lingua salvata, quindi per questo video più lungo potrebbe volerci un po\' di più.';

  @override
  String get localVideoStatusTranslation =>
      'Trascrizione completata. Preparazione della traduzione nella lingua salvata...';

  @override
  String get localVideoPickerTitle => 'Scegli la lingua dell\'audio';

  @override
  String get savedCuesTitle => 'Frasi salvate';

  @override
  String get savedCuesEmpty =>
      'Ancora nessuna frase salvata. Tocca l\'icona del segnalibro mentre ti eserciti per salvare una frase.';

  @override
  String get savedCuesDeleteTooltip => 'Rimuovi frase salvata';

  @override
  String get savedCuesDeleteConfirmTitle => 'Vuoi rimuovere questa frase?';

  @override
  String get savedCuesDeleteConfirmBody =>
      'Questa frase verrà rimossa dall\'elenco dei salvati.';

  @override
  String get savedCuesDeleteAllTooltip => 'Elimina tutte le frasi salvate';

  @override
  String get savedCuesDeleteAllConfirmTitle =>
      'Vuoi eliminare tutte le frasi salvate?';

  @override
  String get savedCuesDeleteAllConfirmBody =>
      'Tutte le frasi salvate verranno rimosse definitivamente.';

  @override
  String get updateAlertTitle => 'Aggiornamento disponibile';

  @override
  String get updateAlertMessage =>
      'È disponibile una nuova versione di Bantera. Aggiorna ora per avere le ultime funzioni e miglioramenti.';

  @override
  String get updateCurrentVersionLabel => 'Versione attuale';

  @override
  String get updateAppStoreVersionLabel => 'Versione su App Store';

  @override
  String get updateAlertUpdate => 'Aggiorna';

  @override
  String get updateAlertLater => 'Più tardi';

  @override
  String get checkForUpdateButton => 'Verifica aggiornamenti';

  @override
  String get upToDateAlertTitle => 'App aggiornata';

  @override
  String upToDateAlertMessage(Object version) {
    return 'Bantera $version è la versione più recente.';
  }

  @override
  String get sectionSupport => 'Supporto';

  @override
  String get permissionActionAllow => 'Consenti';
}
