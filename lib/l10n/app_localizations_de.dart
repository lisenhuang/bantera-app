// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Bantera';

  @override
  String get appTagline => 'Sprachtraining, Satz für Satz.';

  @override
  String get authContinueWithApple => 'Weiter mit Apple';

  @override
  String get authContinueWithGoogle => 'Weiter mit Google';

  @override
  String get authAppleUnavailable =>
      '„Mit Apple anmelden“ ist auf diesem Gerät nicht verfügbar.';

  @override
  String get authOrSignInEmail => 'oder mit E-Mail anmelden';

  @override
  String get authEmail => 'E-Mail';

  @override
  String get authPassword => 'Passwort';

  @override
  String get authSigningIn => 'Anmelden …';

  @override
  String get authSignIn => 'Anmelden';

  @override
  String get authSignInWithEmail => 'Mit E-Mail anmelden';

  @override
  String get validationEnterEmail => 'Gib deine E-Mail-Adresse ein.';

  @override
  String get validationValidEmail => 'Gib eine gültige E-Mail-Adresse ein.';

  @override
  String get validationEnterPassword => 'Gib dein Passwort ein.';

  @override
  String get onboardingTitle => 'Profil einrichten';

  @override
  String get onboardingSubtitle =>
      'So kann Bantera Training und Chat an dich anpassen.';

  @override
  String get onboardingNameTitle => 'Wie sollen andere dich nennen?';

  @override
  String get onboardingNameSubtitle =>
      'Wir haben den Namen aus deinem Apple-Account übernommen. Du kannst ihn jetzt ändern.';

  @override
  String get onboardingClearName => 'Name löschen';

  @override
  String get onboardingNativeLanguageTitle => 'Was ist deine Muttersprache?';

  @override
  String get onboardingNativeLanguageSubtitle =>
      'Bantera nutzt sie für Übersetzungen und Sprachgruppen.';

  @override
  String get onboardingLearningLanguageTitle => 'Welche Sprache lernst du?';

  @override
  String get onboardingLearningLanguageSubtitle =>
      'Davon hängen deine Übungsinhalte und Lerngruppen ab.';

  @override
  String get onboardingAvatarTitle => 'Profilbild hinzufügen';

  @override
  String get onboardingAvatarSubtitle =>
      'Wähle ein Foto oder fahre fort – dann erstellt Bantera eins für dich.';

  @override
  String get onboardingAvatarGenderTitle => 'Profilbild erstellen';

  @override
  String get onboardingAvatarGenderBody =>
      'Wähle, wie Bantera dein Profilbild erstellen soll. Wir speichern diese Auswahl nicht; sie wird nur für dieses Bild verwendet.';

  @override
  String get onboardingAvatarGenderMale => 'Männlich';

  @override
  String get onboardingAvatarGenderFemale => 'Weiblich';

  @override
  String get onboardingChoosePhoto => 'Foto wählen';

  @override
  String get onboardingChangePhoto => 'Foto ändern';

  @override
  String get onboardingUseGeneratedAvatar => 'Stattdessen Avatar erstellen';

  @override
  String get onboardingUseCurrentPhoto => 'Aktuelles Foto verwenden';

  @override
  String get onboardingChooseLanguage => 'Sprache wählen';

  @override
  String get onboardingBack => 'Zurück';

  @override
  String get onboardingFinish => 'Fertig';

  @override
  String get onboardingLoadingProfile => 'Profil wird geladen …';

  @override
  String get onboardingSavingProfile => 'Profil wird gesichert …';

  @override
  String get onboardingLoadFailed =>
      'Etwas ist schiefgelaufen. Bitte versuch es noch einmal.';

  @override
  String get onboardingSearchHint => 'Sprachen suchen …';

  @override
  String get onboardingRetry => 'Erneut versuchen';

  @override
  String get onboardingNoMatching => 'Keine passenden Sprachen.';

  @override
  String get onboardingFailedSave => 'Sichern fehlgeschlagen.';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get sectionAppearance => 'Darstellung';

  @override
  String get sectionAccount => 'Account';

  @override
  String get sectionRateAndShare => 'Bewerten & teilen';

  @override
  String get sectionLanguage => 'App-Sprache';

  @override
  String get sectionPermissions => 'Berechtigungen';

  @override
  String get sectionNotifications => 'Mitteilungen';

  @override
  String get languageSectionSubtitle =>
      'Wähle die Sprache der App. „System“ folgt den Einstellungen deines Geräts.';

  @override
  String get themeLabel => 'Design';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get themeSystem => 'System';

  @override
  String get languageEnglish => 'Englisch';

  @override
  String get languageChineseSimplified => 'Chinesisch (vereinfacht)';

  @override
  String get languageKorean => 'Koreanisch';

  @override
  String get languageJapanese => 'Japanisch';

  @override
  String get signedOutLabel => 'Abgemeldet';

  @override
  String get noActiveSession => 'Keine aktive Bantera-Sitzung';

  @override
  String signedInWith(String provider) {
    return 'Angemeldet mit $provider';
  }

  @override
  String get editProfile => 'Profil bearbeiten';

  @override
  String get more => 'Mehr';

  @override
  String get appPermissionsTitle => 'App-Berechtigungen';

  @override
  String get appPermissionsSubtitle =>
      'Sieh dir an, worauf Bantera auf diesem Gerät zugreift.';

  @override
  String get permissionsIntro =>
      'Bantera nutzt diese Geräteeinstellungen für Aufnahmen, Sprachvergleich und Netzwerkzugriff.';

  @override
  String get permissionsOpenSettings => 'iPhone-Einstellungen öffnen';

  @override
  String get permissionsRefresh => 'Aktualisieren';

  @override
  String get permissionMicrophoneTitle => 'Mikrofon';

  @override
  String get permissionMicrophoneDescription =>
      'Übungsversuche und Sprachnachrichten aufnehmen.';

  @override
  String get permissionSpeechTitle => 'Spracherkennung';

  @override
  String get permissionSpeechDescription =>
      'Übungsaufnahmen und Sprachnachrichten transkribieren.';

  @override
  String get permissionMobileDataTitle => 'Mobile Daten';

  @override
  String get permissionMobileDataDescription =>
      'Bantera nutzen, wenn dieses iPhone nicht mit WLAN verbunden ist.';

  @override
  String get permissionStatusAllowed => 'Erlaubt';

  @override
  String get permissionStatusLimited => 'Eingeschränkt';

  @override
  String get permissionStatusNotAllowed => 'Nicht erlaubt';

  @override
  String get permissionStatusUnknown => 'Unbekannt';

  @override
  String get signOut => 'Abmelden';

  @override
  String get signOutDialogTitle => 'Abmelden?';

  @override
  String get signOutDialogBody =>
      'Du musst dich erneut anmelden, um deinen Account zu nutzen.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get closeLabel => 'Schließen';

  @override
  String get navDiscover => 'Entdecken';

  @override
  String get navCreate => 'Erstellen';

  @override
  String get navProfile => 'Profil';

  @override
  String get chatsTitle => 'Chats';

  @override
  String get chatNoChatsYet => 'Noch keine Chats.';

  @override
  String get chatOnlineSection => 'Online';

  @override
  String get chatDirectMessagesSection => 'DMs';

  @override
  String chatAudioDuration(String duration) {
    return 'Audio $duration';
  }

  @override
  String get chatEnableNotifications => 'Mitteilungen aktivieren';

  @override
  String get chatMuteNotifications => 'Stummschalten';

  @override
  String get chatBlockUser => 'Nutzer blockieren';

  @override
  String get chatDeleteDm => 'DM löschen';

  @override
  String get chatCall => 'Anrufen';

  @override
  String get chatStartAudioCall => 'Audioanruf';

  @override
  String get chatStartVideoCall => 'Videoanruf';

  @override
  String get chatAudioCalling => 'Audioanruf …';

  @override
  String get chatVideoCalling => 'Videoanruf …';

  @override
  String get chatAudioIncoming => 'Eingehender Audioanruf';

  @override
  String get chatVideoIncoming => 'Eingehender Videoanruf';

  @override
  String get chatCallConnecting => 'Verbinden …';

  @override
  String get chatCallAccept => 'Annehmen';

  @override
  String get chatCallDecline => 'Ablehnen';

  @override
  String get chatCallEnd => 'Beenden';

  @override
  String get chatCallMute => 'Stumm';

  @override
  String get chatCallUnmute => 'Ton an';

  @override
  String get chatCallSpeaker => 'Lautsprecher';

  @override
  String get chatCallCamera => 'Kamera';

  @override
  String get chatCallSwitchCamera => 'Wechseln';

  @override
  String get chatCallIssueTitle => 'Problem beim Anruf';

  @override
  String get chatCallMicrophoneDenied =>
      'Bantera braucht Zugriff auf dein Mikrofon, bevor du einen Anruf starten kannst.';

  @override
  String get chatCallMicrophoneSettings =>
      'Der Mikrofonzugriff ist für Bantera deaktiviert. Öffne die Einstellungen und aktiviere ihn für Anrufe.';

  @override
  String get chatCallCameraDenied =>
      'Bantera braucht Zugriff auf deine Kamera, bevor du einen Videoanruf starten kannst.';

  @override
  String get chatCallCameraSettings =>
      'Der Kamerazugriff ist für Bantera deaktiviert. Öffne die Einstellungen und aktiviere ihn für Videoanrufe.';

  @override
  String get chatCallBusy => 'Diese Person ist gerade in einem anderen Anruf.';

  @override
  String get chatCallUnavailable =>
      'Diese Person ist gerade nicht für einen Anruf erreichbar.';

  @override
  String get chatCallNetworkRestricted =>
      'Über dieses Netzwerk kann der Anruf nicht verbunden werden. Versuch es über WLAN oder ein anderes Netzwerk.';

  @override
  String get chatCallFailed =>
      'Der Anruf konnte nicht gestartet werden. Bitte versuch es noch einmal.';

  @override
  String get chatGroupReady => 'Diese Gruppe ist bereit für Sprachnachrichten.';

  @override
  String get chatHoldToStartDm =>
      'Halten, um aufzunehmen und die DM zu starten.';

  @override
  String get chatNoGroupAudio => 'Noch keine Sprachnachrichten in der Gruppe.';

  @override
  String get chatNoDmAudio => 'Noch keine Sprachnachrichten in dieser DM.';

  @override
  String get chatSendingAudio => 'Audio wird gesendet …';

  @override
  String get chatRecordingReleaseToSend => 'Aufnahme … zum Senden loslassen';

  @override
  String get chatHoldToRecordAudio => 'Zum Aufnehmen halten';

  @override
  String get chatRecordingStatus => 'Aufnahme …';

  @override
  String get chatGroupLabel => 'Gruppe';

  @override
  String get chatNotificationsEnabledForDm =>
      'Mitteilungen für diese DM aktiviert.';

  @override
  String get chatNotificationsMutedForDm =>
      'Mitteilungen für diese DM stummgeschaltet.';

  @override
  String chatBlockUserTitle(String user) {
    return '$user blockieren?';
  }

  @override
  String get chatBlockUserBody =>
      'Ihr seht euch dann weder in DMs noch in gemeinsamen Gruppennachrichten, bis du die Blockierung aufhebst.';

  @override
  String chatBlockUserSuccess(String user) {
    return '$user wurde blockiert.';
  }

  @override
  String get chatBlockUserFailed =>
      'Nutzer konnte nicht blockiert werden. Bitte versuch es noch einmal.';

  @override
  String get chatDeleteMessage => 'Nachricht löschen';

  @override
  String get chatDeleteMessageTitle => 'Diese Nachricht löschen?';

  @override
  String get chatDeleteMessageBody =>
      'Die Nachricht wird für alle in dieser Unterhaltung entfernt. Das kann nicht rückgängig gemacht werden.';

  @override
  String get chatDeleteMessageSuccess => 'Nachricht gelöscht';

  @override
  String get chatDeleteMessageFailed =>
      'Nachricht konnte nicht gelöscht werden. Bitte versuch es noch einmal.';

  @override
  String get chatDeleteDmTitle => 'Diese DM löschen?';

  @override
  String get chatDeleteDmBody =>
      'Sie wird nur aus deiner Liste entfernt. Eine neue Nachricht kann sie später zurückbringen.';

  @override
  String get chatMicrophoneRequiredTitle => 'Mikrofon erforderlich';

  @override
  String get chatMicrophoneRequiredSettings =>
      'Bantera braucht Zugriff auf dein Mikrofon, um Sprachnachrichten aufzunehmen. Aktiviere ihn in den Einstellungen.';

  @override
  String get chatMicrophoneRequiredBody =>
      'Bantera braucht Zugriff auf dein Mikrofon, um Sprachnachrichten aufzunehmen.';

  @override
  String get chatGroupNotReady => 'Diese Gruppe ist noch nicht bereit.';

  @override
  String get chatMessageAction => 'Nachricht';

  @override
  String get chatRetranscribe => 'Neu transkribieren';

  @override
  String get chatTranscribe => 'Transkribieren';

  @override
  String get chatTranscribingOnDevice =>
      'Wird auf diesem iPhone transkribiert …';

  @override
  String get chatTranscriptionFailed =>
      'Transkription fehlgeschlagen. Versuch es noch einmal.';

  @override
  String get chatTranslate => 'Übersetzen';

  @override
  String get chatRetranslate => 'Neu übersetzen';

  @override
  String get chatTranslating => 'Wird auf diesem iPhone übersetzt …';

  @override
  String get chatTranslationFailed =>
      'Übersetzung fehlgeschlagen. Bitte versuch es noch einmal.';

  @override
  String get chatGroupSettingsTitle => 'Gruppeneinstellungen';

  @override
  String get chatNotifications => 'Mitteilungen';

  @override
  String get chatBlockedUsersMenu => 'Blockierte Nutzer';

  @override
  String get chatBlockedUsersTitle => 'Blockierte Nutzer';

  @override
  String get chatBlockedPeople => 'Blockierte Personen';

  @override
  String get chatNoBlockedUsers => 'Noch keine blockierten Nutzer.';

  @override
  String get chatNoBlockedPeople => 'Noch keine blockierten Personen.';

  @override
  String get chatUnblock => 'Freigeben';

  @override
  String chatUnblockUserTitle(String user) {
    return '$user freigeben?';
  }

  @override
  String get chatUnblockUserBody =>
      'Ihr könnt euch dann wieder in DMs und gemeinsamen Gruppennachrichten sehen.';

  @override
  String get chatUnblockFailed =>
      'Blockierung konnte nicht aufgehoben werden. Bitte versuch es noch einmal.';

  @override
  String get chatNotificationsTitle => 'Chat-Mitteilungen';

  @override
  String get chatNotificationsSubtitle =>
      'Ein Schalter für deinen Account – auf all deinen Geräten.';

  @override
  String get chatNotificationsDisabledTitle => 'Mitteilungen deaktiviert';

  @override
  String get chatNotificationsDisabledSettings =>
      'Aktiviere Mitteilungen in den Einstellungen, um Chat-Benachrichtigungen von Bantera zu erhalten.';

  @override
  String get chatNotificationsDisabledBody =>
      'Bantera braucht die Berechtigung für Mitteilungen, bevor Chat-Benachrichtigungen aktiviert werden können.';

  @override
  String get chatNotificationUpdateFailed =>
      'Chat-Mitteilungen konnten nicht aktualisiert werden. Bitte versuch es noch einmal.';

  @override
  String get savedTitle => 'Gemerkte Medien';

  @override
  String get generateWithAiTitle => 'Mit KI erstellen';

  @override
  String get practiceLocalVideoTitle => 'Lokales Video üben';

  @override
  String get uploadVideoTitle => 'Video hochladen';

  @override
  String get lessonDetailsTitle => 'Lektionsdetails';

  @override
  String get accountMoreTitle => 'Mehr';

  @override
  String get deleteAccount => 'Account löschen';

  @override
  String get deleteAccountSubtitle =>
      'Account und Serverdaten endgültig entfernen';

  @override
  String get confirmDeletionTitle => 'Löschen bestätigen';

  @override
  String get deleteAccountImmediateBody =>
      'Dein Account wird sofort gelöscht. Um Bantera wieder zu nutzen, musst du einen neuen Account erstellen.';

  @override
  String get deleteAccountConfirm => 'Account löschen';

  @override
  String get couldNotDeleteAccount =>
      'Account konnte nicht gelöscht werden. Bitte versuch es noch einmal.';

  @override
  String get deleteAccountQuestionTitle => 'Account löschen?';

  @override
  String get deleteAccountQuestionBody =>
      'Alle deine persönlichen Informationen und Daten werden endgültig von unseren Servern entfernt und können nicht wiederhergestellt werden.';

  @override
  String get typeDeleteLabel => 'Gib „DELETE“ ein, um fortzufahren';

  @override
  String get continueLabel => 'Weiter';

  @override
  String get confirmLabel => 'Bestätigen';

  @override
  String get deleteLabel => 'Löschen';

  @override
  String get removeFromListLabel => 'Aus Liste entfernen';

  @override
  String get startLabel => 'Starten';

  @override
  String get doneLabel => 'Fertig';

  @override
  String get discoverSearchHint => 'Titel oder Transkript suchen …';

  @override
  String get discoverNoMoreResults => 'Keine weiteren Ergebnisse';

  @override
  String get discoverSetLearningLanguagePrompt =>
      'Lege deine Lernsprache fest, um hier Inhalte zu sehen';

  @override
  String discoverNoPublicContentInLanguage(String language) {
    return 'Noch keine öffentlichen Inhalte auf $language';
  }

  @override
  String get discoverSetLanguageToDiscover =>
      'Lege eine Lernsprache fest, um Inhalte zu entdecken';

  @override
  String get mediaStartPractice => 'Üben';

  @override
  String get mediaTranscript => 'Transkript';

  @override
  String mediaTranscriptLineCount(int count) {
    return '($count Zeilen)';
  }

  @override
  String get mediaShow => 'Einblenden';

  @override
  String get mediaHide => 'Ausblenden';

  @override
  String get mediaNoTranscriptAvailable => 'Kein Transkript verfügbar.';

  @override
  String get lessonSaveTooltip => 'Merken';

  @override
  String get lessonUnsaveTooltip => 'Nicht mehr merken';

  @override
  String get mediaKindAudio => 'Audio';

  @override
  String get mediaKindVideo => 'Video';

  @override
  String get practiceNoCues => 'Keine Sätze';

  @override
  String get practiceTranslating => 'Übersetzen …';

  @override
  String get practiceShowTranscript => 'Transkript zeigen';

  @override
  String get practiceTranslate => 'Übersetzen';

  @override
  String get practiceHideText => 'Text ausblenden';

  @override
  String get practiceTextLabel => 'Text';

  @override
  String get practiceStop => 'Stopp';

  @override
  String get practicePlayAll => 'Shadowing';

  @override
  String get practiceCompare => 'Vergleichen';

  @override
  String get practiceRecord => 'Aufnehmen';

  @override
  String get practiceStopRecording => 'Stopp';

  @override
  String get practiceRecords => 'Aufnahmen';

  @override
  String get practiceRecordsLocalOnlyFooter =>
      'Versuche werden nur auf diesem Gerät gespeichert und nicht hochgeladen.';

  @override
  String get practiceRecordsEmpty =>
      'Noch keine gespeicherten Versuche für diesen Satz.';

  @override
  String get practiceRecordingProcessError =>
      'Beim Verarbeiten deiner Aufnahme ist etwas schiefgelaufen.';

  @override
  String get practiceStartOver => 'Neu starten';

  @override
  String get practiceTranscriptHidden => 'Transkript ausgeblendet';

  @override
  String get practiceListenCarefully => 'Hör genau hin …';

  @override
  String get practiceTranslationUnavailableForCue =>
      'Für diesen Satz ist gerade keine Übersetzung verfügbar.';

  @override
  String get practiceChooseTranslationLanguageTitle =>
      'Übersetzungssprache wählen';

  @override
  String get practiceChooseTranslationLanguageDescription =>
      'Bantera übersetzt deine Hörübungen in diese Sprache und speichert sie in deinem Profil für künftige Sitzungen.';

  @override
  String get practiceChangeTranslationLanguageTitle =>
      'Übersetzungssprache ändern';

  @override
  String get practiceChangeTranslationLanguageDescription =>
      'Wähle die Sprache, in die Bantera übersetzen soll. Deine Auswahl wird in deinem Profil gespeichert.';

  @override
  String get practiceConfirmTranslationLanguageTitle =>
      'Übersetzungssprache bestätigen';

  @override
  String get practiceConfirmTranslationLanguageBody =>
      'Bantera speichert diese Sprache in deinem Profil und nutzt sie künftig als Standard-Übersetzungssprache für Hörübungen.';

  @override
  String get practiceCouldNotSaveTranslationLanguage =>
      'Bantera konnte deine Übersetzungssprache nicht speichern.';

  @override
  String get practiceNoTranslationLanguagesFound =>
      'Bantera konnte keine Übersetzungssprachen für dieses Transkript finden.';

  @override
  String get practicePlayAllTitle => 'Shadowing';

  @override
  String get practicePlayAllDescription =>
      'Pause zwischen den Sätzen fürs Shadowing:';

  @override
  String get practicePlayAllPauseZeroSeconds => '0 s';

  @override
  String get practicePlayAllPauseOneSecondLabel => '1 s';

  @override
  String get practicePlayAllPauseOneCuePlusOneSecond => '1 Satz + 1 s';

  @override
  String get practicePlayAllPauseOneCuePlusTwoSeconds => '1 Satz + 2 s';

  @override
  String get practicePlayAllTimesPerCueTitle => 'Wiederholungen pro Satz';

  @override
  String get practicePlayAllTimesOnce => '1×';

  @override
  String get practicePlayAllTimesTwice => '2×';

  @override
  String get practicePlayAllTimesThrice => '3×';

  @override
  String get practiceSearchLanguagesHint => 'Sprachen suchen';

  @override
  String get practiceTranslationInstalled => 'Installiert';

  @override
  String get practiceTranslationDownload => 'Laden';

  @override
  String get practiceStartOverTitle => 'Neu starten?';

  @override
  String get practiceStartOverBody => 'Zurück zum ersten Satz?';

  @override
  String get practiceNextFromLastTitle => 'Zum ersten Satz?';

  @override
  String get practiceNextFromLastBody =>
      'Du bist beim letzten Satz. Zurück zum ersten?';

  @override
  String get practiceGoToFirstCue => 'Zum ersten Satz';

  @override
  String get practiceVideoOpenError =>
      'Das ausgewählte Video konnte nicht zum Üben geöffnet werden.';

  @override
  String get practiceAudioLoading => 'Audio wird geladen …';

  @override
  String practiceAudioLoadingPercent(int percent) {
    return 'Audio wird geladen … $percent %';
  }

  @override
  String get practiceAudioError =>
      'Audio konnte nicht geladen werden. Bitte versuch es noch einmal.';

  @override
  String get compareRecordYourVersion => 'Nimm deine Version auf';

  @override
  String compareTranscriptionLanguage(String locale) {
    return 'Transkriptionssprache: $locale';
  }

  @override
  String get compareOpenIphoneSettings => 'iPhone-Einstellungen öffnen';

  @override
  String get comparePauseAttempt => 'Versuch pausieren';

  @override
  String get comparePlayAttempt => 'Versuch abspielen';

  @override
  String get compareYourTranscribedAttempt => 'Dein transkribierter Versuch';

  @override
  String get compareHighlightHint =>
      'Wörter, die Bantera anders erkannt hat, sind markiert.';

  @override
  String get compareUncertainHint =>
      'Gepunktete Wörter wurden erkannt, aber Bantera war unsicher – prüf deine Aussprache.';

  @override
  String get compareTryAgain => 'Nochmal';

  @override
  String get compareDone => 'Fertig';

  @override
  String get compareStatusTranscribing =>
      'Dein Versuch wird auf dem iPhone transkribiert …';

  @override
  String get compareStatusRecording => 'Aufnahme … Tippe erneut zum Stoppen.';

  @override
  String get compareStatusSavedAttempt =>
      'Ein gespeicherter Versuch für diesen Satz wird angezeigt. Du kannst ihn abspielen oder es erneut versuchen.';

  @override
  String get compareStatusReplayOrRetry =>
      'Du kannst diesen Versuch abspielen oder den Satz erneut üben.';

  @override
  String get compareStatusTapToRecord =>
      'Tippe, um deine Version dieses Satzes aufzunehmen.';

  @override
  String get compareCouldNotStartRecording =>
      'Bantera konnte die Aufnahme gerade nicht starten.';

  @override
  String get compareCouldNotAccessRecording =>
      'Bantera konnte nicht auf die Aufnahme zugreifen.';

  @override
  String get compareNoTranscriptGenerated =>
      'Für diesen Versuch konnte kein Transkript erstellt werden. Versuch es noch einmal näher am Mikrofon.';

  @override
  String get compareRecentAttempts => 'Letzte Versuche';

  @override
  String get compareAttemptsFooterNote =>
      'Bantera speichert deine Versuche auf diesem iPhone, damit du deinen Fortschritt beim selben Satz verfolgen kannst.';

  @override
  String compareMatchedCount(int count) {
    return '$count richtig';
  }

  @override
  String compareDifferentCount(int count) {
    return '$count abweichend';
  }

  @override
  String compareMissingCount(int count) {
    return '$count fehlend';
  }

  @override
  String compareUncertainCount(int count) {
    return '$count unklar';
  }

  @override
  String get compareMicrophoneDeniedPermanent =>
      'Der Mikrofonzugriff ist für Bantera deaktiviert. Öffne „iPhone-Einstellungen“ > „Bantera“ > „Mikrofon“ und aktiviere ihn, um deine eigene Version aufzunehmen.';

  @override
  String get compareMicrophoneDeniedRestricted =>
      'Dieses iPhone schränkt den Mikrofonzugriff für Bantera derzeit ein. Prüfe Bildschirmzeit, Geräteverwaltung oder Systemeinstellungen, um ihn zu aktivieren.';

  @override
  String get compareMicrophoneDeniedDefault =>
      'Um deine eigene Version aufzunehmen, braucht Bantera Zugriff auf das Mikrofon. Falls du die Anfrage abgelehnt hast, öffne „iPhone-Einstellungen“ > „Bantera“ > „Mikrofon“ und aktiviere ihn.';

  @override
  String get compareSpeechRecognitionDeniedPermanent =>
      'Die Spracherkennung ist für Bantera deaktiviert. Öffne „iPhone-Einstellungen“ > „Bantera“ > „Spracherkennung“ und aktiviere sie, um deine Aufnahme zu vergleichen.';

  @override
  String get compareSpeechRecognitionDeniedRestricted =>
      'Dieses iPhone schränkt die Spracherkennung für Bantera derzeit ein. Prüfe Bildschirmzeit, Geräteverwaltung oder Systemeinstellungen, um sie zu aktivieren.';

  @override
  String get compareSpeechRecognitionUnavailable =>
      'Die Spracherkennung ist auf diesem iPhone gerade nicht verfügbar.';

  @override
  String get compareSpeechRecognitionUnsupportedLocale =>
      'Die Spracherkennung ist für diese Übungssprache auf diesem iPhone nicht verfügbar.';

  @override
  String get comparePlayAttemptTooltip => 'Versuch abspielen';

  @override
  String get comparePauseAttemptTooltip => 'Versuch pausieren';

  @override
  String get createWhatToday => 'Was möchtest du heute machen?';

  @override
  String get createPracticeVideo => 'Video üben';

  @override
  String get createYourMedia => 'Deine Medien';

  @override
  String get createTryAgain => 'Erneut versuchen';

  @override
  String get createUploadedVideosEmptyHint =>
      'Deine hochgeladenen Videos erscheinen hier – so kannst du sie wieder öffnen und Satz für Satz üben.';

  @override
  String get createUploadingTips => 'Tipps zum Hochladen';

  @override
  String get createUploadingTipsBody =>
      'Halte dein Audio unter 3 Minuten, dann bleibst du am besten dran. Klare Untertitel werden automatisch erstellt!';

  @override
  String get createOnThisIphone => 'Auf diesem iPhone';

  @override
  String get createLocalVideosEmptyHint =>
      'Videos, die du lokal übst, werden auf diesem iPhone gespeichert, damit du sie später ohne erneute Transkription öffnen kannst.';

  @override
  String get createOnDeviceBadge => 'Auf dem Gerät';

  @override
  String get createSignInToLoadVideos =>
      'Melde dich erneut an, um deine hochgeladenen Videos zu laden.';

  @override
  String createVideoMetaCues(int count) {
    return '$count Sätze';
  }

  @override
  String get createPublicBadge => 'Öffentlich';

  @override
  String get createPrivateBadge => 'Privat';

  @override
  String get createAiBadge => 'KI';

  @override
  String get createDeleteSavedVideoTitle => 'Gespeichertes Video löschen?';

  @override
  String createDeleteSavedVideoBody(String title) {
    return 'Bantera entfernt „$title“ von diesem iPhone und löscht die gespeicherten Transkript-Sätze.';
  }

  @override
  String get createDeleteMediaTitle => 'Medium löschen?';

  @override
  String createDeleteMediaBody(String title) {
    return '„$title“ und das zugehörige Transkript werden endgültig gelöscht. Das kann nicht rückgängig gemacht werden.';
  }

  @override
  String get removeFromListTitle => 'Aus Liste entfernen?';

  @override
  String get removeFromListBody =>
      'Der Eintrag wird aus der Liste entfernt. Das kann nicht rückgängig gemacht werden.';

  @override
  String get editProfileChangeImage => 'Profilbild ändern';

  @override
  String get editProfileUploading => 'Wird hochgeladen …';

  @override
  String get editProfileNameLabel => 'Name';

  @override
  String get editProfileNameHint => 'Wie soll Bantera deinen Namen anzeigen?';

  @override
  String get editProfileSaveNameButton => 'Name sichern';

  @override
  String get editProfileSaving => 'Wird gesichert …';

  @override
  String get editProfileLanguagesSection => 'Sprachen';

  @override
  String get editProfileMyNativeLanguage => 'Meine Muttersprache';

  @override
  String get editProfileMyNativeLanguageSubtitle =>
      'Deine Mutter- oder Erstsprache';

  @override
  String get editProfileLearningLanguage => 'Lernsprache';

  @override
  String get editProfileLearningLanguageSubtitle =>
      'Die Sprache, die du üben möchtest';

  @override
  String get editProfileImageUpdated => 'Profilbild aktualisiert.';

  @override
  String get editProfileNameUpdated => 'Name aktualisiert.';

  @override
  String get editProfileEnterName => 'Gib einen Namen ein.';

  @override
  String get editProfileNameMaxLength => 'Verwende höchstens 80 Zeichen.';

  @override
  String get editProfileCouldNotLoadLanguages =>
      'Sprachliste konnte nicht geladen werden.';

  @override
  String get languagePickerNone => 'Keine';

  @override
  String get languagePickerClearSelection => 'Auswahl löschen';

  @override
  String get languagePickerNoMatchingLanguages => 'Keine Sprachen gefunden.';

  @override
  String get languagePickerMoreComingSoon => 'Weitere Sprachen folgen bald';

  @override
  String get editProfileNativeLanguageCleared => 'Muttersprache entfernt.';

  @override
  String get editProfileLearningLanguageCleared => 'Lernsprache entfernt.';

  @override
  String editProfileNativeLanguageSetTo(String language) {
    return 'Muttersprache auf $language gesetzt.';
  }

  @override
  String editProfileLearningLanguageSetTo(String language) {
    return 'Lernsprache auf $language gesetzt.';
  }

  @override
  String get profileLanguageSettings => 'Spracheinstellungen';

  @override
  String get profileLearningLabel => 'Lernt';

  @override
  String get profileNotSet => 'Nicht festgelegt';

  @override
  String get uploadedDetailYourAudio => 'Dein Audio';

  @override
  String get uploadedDetailYourVideo => 'Dein Video';

  @override
  String get uploadedDetailDeleteAudioTitle => 'Audio löschen?';

  @override
  String get uploadedDetailDeleteAudioBody =>
      'Das Audio und das zugehörige Transkript werden endgültig gelöscht. Das kann nicht rückgängig gemacht werden.';

  @override
  String get uploadedDetailDeleteVideoTitle => 'Video löschen?';

  @override
  String get uploadedDetailDeleteVideoBody =>
      'Das Video und das zugehörige Transkript werden endgültig gelöscht. Das kann nicht rückgängig gemacht werden.';

  @override
  String get uploadedDetailAiGenerated => 'KI-generiert';

  @override
  String get uploadedDetailFileSize => 'Dateigröße';

  @override
  String get uploadedDetailResolution => 'Auflösung';

  @override
  String get uploadedDetailResolutionUnknown => 'Unbekannt';

  @override
  String get uploadedDetailTranscribing => 'Wird transkribiert …';

  @override
  String get uploadedDetailNoTranscriptCuesYet =>
      'Noch keine Transkript-Sätze verfügbar.';

  @override
  String uploadedDetailMediaDescription(int count) {
    return 'Dein hochgeladener Übungsclip mit $count Transkript-Sätzen.';
  }

  @override
  String get uploadedDetailTranscriptionFailedFallback =>
      'Transkription fehlgeschlagen. Geschätzte Sätze werden verwendet.';

  @override
  String get uploadedDetailTranscriptionNoCues =>
      'Die Transkription hat keine Sätze ergeben.';

  @override
  String get uploadedDetailTranscriptionSourceYourUpload => 'Dein Upload';

  @override
  String get aiGenLeaveTitle => 'Seite verlassen?';

  @override
  String get aiGenLeaveBody =>
      'Das Audio wird noch erstellt. Wenn du die Seite jetzt verlässt, wird der Vorgang abgebrochen.';

  @override
  String get aiGenStay => 'Bleiben';

  @override
  String get aiGenLeave => 'Verlassen';

  @override
  String get aiGenLoadingTitle => 'Dein Audio wird erstellt …';

  @override
  String get aiGenLoadingSubtitle =>
      'Das kann bis zu einer Minute dauern.\nBitte bleib während der Erstellung auf dieser Seite.';

  @override
  String get aiGenStepPreparingSpeechModel =>
      'Sprachmodell auf dem Gerät vorbereiten';

  @override
  String get aiGenStepWritingDialogue => 'Dialog schreiben';

  @override
  String get aiGenStepGeneratingAudio => 'Audio erstellen';

  @override
  String get aiGenStepAligningAudio => 'Audio abgleichen';

  @override
  String get aiGenStepTranscribing => 'Transkribieren';

  @override
  String get aiGenStepCorrectingTranscript => 'Transkript korrigieren';

  @override
  String get aiGenLanguageSection => 'Sprache';

  @override
  String get aiGenSetLearningLanguagePrompt =>
      'Lege deine Lernsprache fest, um Audio zu erstellen';

  @override
  String get aiGenLoadingLanguage => 'Sprache wird geladen …';

  @override
  String aiGenLanguageUnsupported(String language) {
    return 'Die Sprache „$language“ wird für die Erstellung nicht unterstützt.';
  }

  @override
  String get aiGenScenarioSection => 'Szenario';

  @override
  String get aiGenScenarioOptionalHint =>
      'Optional – ohne Auswahl gibt es ein zufälliges Szenario.';

  @override
  String get aiGenCustomScenarioHint => 'Beschreib dein Szenario …';

  @override
  String get aiGenDurationSection => 'Dauer';

  @override
  String aiGenDurationMinutes(int minutes) {
    return '$minutes Min.';
  }

  @override
  String get aiGenGenerateButton => 'Erstellen';

  @override
  String get aiGenOwnershipNotice =>
      'Audio, das du hier erstellst, wird zu Bantera-Community-Inhalten – öffentlich geteilt als Übungsmaterial für alle Lernenden.';

  @override
  String get aiGenOwnershipCheckbox =>
      'Dieses Audio als Bantera-Community-Inhalt teilen';

  @override
  String get aiGenOwnershipConfirmTitle => 'Als Community-Inhalt teilen?';

  @override
  String get aiGenOwnershipConfirmCancel => 'Abbrechen';

  @override
  String get aiGenOwnershipConfirmGenerate => 'Erstellen';

  @override
  String get aiGenFooterNotice =>
      'Die KI schreibt einen Dialog für zwei Sprecher und vertont ihn. Das Ergebnis wird als öffentliches Übungsaudio gespeichert.';

  @override
  String get aiScenarioCoffeeShop => 'Im Café';

  @override
  String get aiScenarioLatestNews => 'Aktuelle Nachrichten';

  @override
  String get aiScenarioAirportReunion => 'Wiedersehen am Flughafen';

  @override
  String get aiScenarioGroceryStore => 'Im Supermarkt';

  @override
  String get aiScenarioDoctorVisit => 'Beim Arzt';

  @override
  String get aiScenarioJobInterview => 'Vorstellungsgespräch';

  @override
  String get aiScenarioNewNeighbour => 'Neue Nachbarn';

  @override
  String get aiScenarioTechSupport => 'Technischer Support';

  @override
  String get aiScenarioBirthdaySurprise => 'Geburtstagsüberraschung';

  @override
  String get aiScenarioGymTips => 'Tipps im Fitnessstudio';

  @override
  String get aiScenarioWeatherSmalltalk => 'Smalltalk übers Wetter';

  @override
  String get aiScenarioRestaurantOrder => 'Im Restaurant bestellen';

  @override
  String get aiScenarioBookRecommendation => 'Buchempfehlung';

  @override
  String get aiScenarioBusDelay => 'Bus hat Verspätung';

  @override
  String get aiScenarioMovieDebate => 'Filmdiskussion';

  @override
  String get aiScenarioCustom => 'Eigenes …';

  @override
  String get errorNetworkUnreachable =>
      'Keine Verbindung zu Bantera. Prüfe deine Internetverbindung.';

  @override
  String get errorNetworkCellularBlocked =>
      'Mobile Daten sind für Bantera deaktiviert. Öffne in den Einstellungen „Bantera“ und aktiviere „Mobile Daten“ oder verbinde dich mit einem WLAN.';

  @override
  String get errorTlsConnection =>
      'Es konnte keine sichere Verbindung hergestellt werden.';

  @override
  String get settingsRateAppPrompt =>
      'Gefällt dir Bantera? Eine kurze Bewertung im App Store bedeutet uns viel.';

  @override
  String get settingsRateAppButton => 'Im App Store bewerten';

  @override
  String get settingsSharePrompt =>
      'Kennst du jemanden, der eine Sprache lernt? Teile Bantera mit ihm oder ihr.';

  @override
  String get settingsShareButton => 'Bantera teilen';

  @override
  String get settingsContactButton => 'Kontakt';

  @override
  String get localVideoDescription =>
      'Wähle ein Video aus „Fotos“ und die gesprochene Sprache. Das iPhone transkribiert es dann im Hintergrund, bevor du Satz für Satz übst.';

  @override
  String get localVideoStep1Title => '1. Video wählen';

  @override
  String get localVideoChooseFromPhotos => 'Aus „Fotos“ wählen';

  @override
  String get localVideoChooseDifferent => 'Anderes Video wählen';

  @override
  String get localVideoSelectedFileLabel => 'Ausgewählte Datei';

  @override
  String get localVideoSizeLabel => 'Größe';

  @override
  String get localVideoDurationLabel => 'Dauer';

  @override
  String get localVideoLongVideoWarning =>
      'Dieses Video ist länger als 3 Minuten. Bantera braucht daher eventuell länger, um Transkript und Übersetzung vorzubereiten.';

  @override
  String get localVideoStep2Title => '2. Transkriptionssprache';

  @override
  String get localVideoChooseLanguagePlaceholder =>
      'Gesprochene Sprache wählen';

  @override
  String get localVideoLanguageHint =>
      'Bantera merkt sich deine letzte Sprachauswahl und blendet das Transkript beim Üben standardmäßig aus.';

  @override
  String get localVideoStep3Title => '3. Üben';

  @override
  String get localVideoPreparing => 'Wird vorbereitet …';

  @override
  String get localVideoPracticeHint =>
      'Bantera transkribiert zuerst auf dem Gerät und öffnet dann die Hörübung Satz für Satz – ohne etwas hochzuladen.';

  @override
  String get localVideoStatusLongVideo =>
      'Das ist ein längeres Video. Bantera braucht eventuell etwas mehr Zeit, um es zu transkribieren und vorzubereiten.';

  @override
  String get localVideoStatusTranscribing =>
      'Wird auf dem Gerät transkribiert und Übungssätze werden vorbereitet …';

  @override
  String get localVideoStatusSaving =>
      'Video wird in deiner Übungsbibliothek auf dem Gerät gespeichert …';

  @override
  String get localVideoStatusTranslationLong =>
      'Transkription abgeschlossen. Bantera bereitet auch die Übersetzung in deine gespeicherte Sprache vor – bei diesem längeren Video kann das etwas dauern.';

  @override
  String get localVideoStatusTranslation =>
      'Transkription abgeschlossen. Übersetzung in deine gespeicherte Sprache wird vorbereitet …';

  @override
  String get localVideoPickerTitle => 'Audiosprache wählen';

  @override
  String get savedCuesTitle => 'Gemerkte Sätze';

  @override
  String get savedCuesEmpty =>
      'Noch keine gemerkten Sätze. Tippe beim Üben auf das Lesezeichen, um dir einen Satz zu merken.';

  @override
  String get savedCuesDeleteTooltip => 'Gemerkten Satz entfernen';

  @override
  String get savedCuesDeleteConfirmTitle => 'Diesen Satz entfernen?';

  @override
  String get savedCuesDeleteConfirmBody =>
      'Dieser Satz wird aus deiner Merkliste entfernt.';

  @override
  String get savedCuesDeleteAllTooltip => 'Alle gemerkten Sätze löschen';

  @override
  String get savedCuesDeleteAllConfirmTitle => 'Alle gemerkten Sätze löschen?';

  @override
  String get savedCuesDeleteAllConfirmBody =>
      'Alle gemerkten Sätze werden endgültig entfernt.';

  @override
  String get updateAlertTitle => 'Update verfügbar';

  @override
  String get updateAlertMessage =>
      'Eine neue Version von Bantera ist verfügbar. Aktualisiere jetzt, um die neuesten Funktionen und Verbesserungen zu erhalten.';

  @override
  String get updateCurrentVersionLabel => 'Aktuelle Version';

  @override
  String get updateAppStoreVersionLabel => 'Version im App Store';

  @override
  String get updateAlertUpdate => 'Aktualisieren';

  @override
  String get updateAlertLater => 'Später';

  @override
  String get checkForUpdateButton => 'Nach Updates suchen';

  @override
  String get upToDateAlertTitle => 'Auf dem neuesten Stand';

  @override
  String upToDateAlertMessage(Object version) {
    return 'Bantera $version ist die neueste Version.';
  }

  @override
  String get sectionSupport => 'Support';

  @override
  String get permissionActionAllow => 'Erlauben';
}
