// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Bantera';

  @override
  String get appTagline => 'Pratique ta langue, phrase par phrase.';

  @override
  String get authContinueWithApple => 'Continuer avec Apple';

  @override
  String get authContinueWithGoogle => 'Continuer avec Google';

  @override
  String get authAppleUnavailable =>
      'Se connecter avec Apple n’est pas disponible sur cet appareil.';

  @override
  String get authOrSignInEmail => 'ou connecte-toi par e-mail';

  @override
  String get authEmail => 'E-mail';

  @override
  String get authPassword => 'Mot de passe';

  @override
  String get authSigningIn => 'Connexion...';

  @override
  String get authSignIn => 'Se connecter';

  @override
  String get authSignInWithEmail => 'Se connecter par e-mail';

  @override
  String get validationEnterEmail => 'Saisis ton e-mail.';

  @override
  String get validationValidEmail => 'Saisis un e-mail valide.';

  @override
  String get validationEnterPassword => 'Saisis ton mot de passe.';

  @override
  String get onboardingTitle => 'Configure ton profil';

  @override
  String get onboardingSubtitle =>
      'Bantera pourra ainsi personnaliser ta pratique et tes discussions.';

  @override
  String get onboardingNameTitle => 'Comment veux-tu qu’on t’appelle ?';

  @override
  String get onboardingNameSubtitle =>
      'Nous l’avons rempli à partir de ton compte, quand Apple l’a fourni. Tu peux le modifier maintenant.';

  @override
  String get onboardingClearName => 'Effacer le nom';

  @override
  String get onboardingNativeLanguageTitle =>
      'Quelle est ta langue maternelle ?';

  @override
  String get onboardingNativeLanguageSubtitle =>
      'Bantera l’utilise pour les traductions et les groupes de langue.';

  @override
  String get onboardingLearningLanguageTitle => 'Quelle langue apprends-tu ?';

  @override
  String get onboardingLearningLanguageSubtitle =>
      'Elle détermine le contenu de pratique et tes groupes d’apprentissage.';

  @override
  String get onboardingAvatarTitle => 'Ajoute une photo de profil';

  @override
  String get onboardingAvatarSubtitle =>
      'Choisis une photo, ou continue et Bantera en générera une pour toi.';

  @override
  String get onboardingAvatarGenderTitle => 'Générer ta photo de profil';

  @override
  String get onboardingAvatarGenderBody =>
      'Choisis comment Bantera doit générer ta photo de profil. Ce choix n’est pas conservé ; il sert uniquement pour cette image.';

  @override
  String get onboardingAvatarGenderMale => 'Homme';

  @override
  String get onboardingAvatarGenderFemale => 'Femme';

  @override
  String get onboardingChoosePhoto => 'Choisir une photo';

  @override
  String get onboardingChangePhoto => 'Changer de photo';

  @override
  String get onboardingUseGeneratedAvatar => 'Utiliser plutôt un avatar généré';

  @override
  String get onboardingUseCurrentPhoto => 'Utiliser la photo actuelle';

  @override
  String get onboardingChooseLanguage => 'Choisir une langue';

  @override
  String get onboardingBack => 'Retour';

  @override
  String get onboardingFinish => 'Terminer';

  @override
  String get onboardingLoadingProfile => 'Chargement du profil...';

  @override
  String get onboardingSavingProfile => 'Enregistrement du profil...';

  @override
  String get onboardingLoadFailed => 'Un problème est survenu. Réessaie.';

  @override
  String get onboardingSearchHint => 'Rechercher une langue…';

  @override
  String get onboardingRetry => 'Réessayer';

  @override
  String get onboardingNoMatching => 'Aucune langue correspondante.';

  @override
  String get onboardingFailedSave => 'Échec de l’enregistrement.';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get sectionAppearance => 'Apparence';

  @override
  String get sectionAccount => 'Compte';

  @override
  String get sectionRateAndShare => 'Noter et partager';

  @override
  String get sectionLanguage => 'Langue d’affichage';

  @override
  String get sectionPermissions => 'Autorisations';

  @override
  String get sectionNotifications => 'Notifications';

  @override
  String get languageSectionSubtitle =>
      'Choisis la langue d’affichage de l’app. « Système » suit les réglages de ton appareil.';

  @override
  String get themeLabel => 'Thème';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeSystem => 'Système';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageChineseSimplified => 'Chinois (simplifié)';

  @override
  String get languageKorean => 'Coréen';

  @override
  String get languageJapanese => 'Japonais';

  @override
  String get signedOutLabel => 'Déconnecté';

  @override
  String get noActiveSession => 'Aucune session Bantera active';

  @override
  String signedInWith(String provider) {
    return 'Connecté avec $provider';
  }

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get more => 'Plus';

  @override
  String get appPermissionsTitle => 'Autorisations de l’app';

  @override
  String get appPermissionsSubtitle =>
      'Vérifie les accès utilisés par Bantera sur cet appareil.';

  @override
  String get permissionsIntro =>
      'Bantera utilise ces réglages de l’appareil pour l’enregistrement, la comparaison vocale et l’accès au réseau.';

  @override
  String get permissionsOpenSettings => 'Ouvrir les Réglages de l’iPhone';

  @override
  String get permissionsRefresh => 'Actualiser';

  @override
  String get permissionMicrophoneTitle => 'Micro';

  @override
  String get permissionMicrophoneDescription =>
      'Enregistrer tes essais et tes messages vocaux.';

  @override
  String get permissionSpeechTitle => 'Reconnaissance vocale';

  @override
  String get permissionSpeechDescription =>
      'Transcrire tes enregistrements et tes messages vocaux.';

  @override
  String get permissionMobileDataTitle => 'Données cellulaires';

  @override
  String get permissionMobileDataDescription =>
      'Utiliser Bantera quand cet iPhone n’est pas connecté au Wi-Fi.';

  @override
  String get permissionStatusAllowed => 'Autorisé';

  @override
  String get permissionStatusLimited => 'Limité';

  @override
  String get permissionStatusNotAllowed => 'Non autorisé';

  @override
  String get permissionStatusUnknown => 'Inconnu';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get signOutDialogTitle => 'Se déconnecter ?';

  @override
  String get signOutDialogBody =>
      'Tu devras te reconnecter pour utiliser ton compte.';

  @override
  String get cancel => 'Annuler';

  @override
  String get closeLabel => 'Fermer';

  @override
  String get longerDialogues => 'Dialogues plus longs';

  @override
  String get navDiscover => 'Dialogues';

  @override
  String get navCreate => 'Créer';

  @override
  String get navProfile => 'Profil';

  @override
  String get navGoal => 'Objectif';

  @override
  String get chatsTitle => 'Discussions';

  @override
  String get chatNoChatsYet => 'Aucune discussion pour l’instant.';

  @override
  String get chatHideSameNativeSpeakers =>
      'Masquer les personnes ayant ma langue maternelle';

  @override
  String get chatOnlineSection => 'En ligne';

  @override
  String get chatDirectMessagesSection => 'MP';

  @override
  String chatAudioDuration(String duration) {
    return 'Audio $duration';
  }

  @override
  String get chatEnableNotifications => 'Activer les notifications';

  @override
  String get chatMuteNotifications => 'Couper les notifications';

  @override
  String get chatBlockUser => 'Bloquer l’utilisateur';

  @override
  String get chatDeleteDm => 'Supprimer la conversation';

  @override
  String get chatCall => 'Appeler';

  @override
  String get chatStartAudioCall => 'Appel audio';

  @override
  String get chatStartVideoCall => 'Appel vidéo';

  @override
  String get chatAudioCalling => 'Appel audio...';

  @override
  String get chatVideoCalling => 'Appel vidéo...';

  @override
  String get chatAudioIncoming => 'Appel audio entrant';

  @override
  String get chatVideoIncoming => 'Appel vidéo entrant';

  @override
  String get chatCallConnecting => 'Connexion...';

  @override
  String get chatCallAccept => 'Accepter';

  @override
  String get chatCallDecline => 'Refuser';

  @override
  String get chatCallEnd => 'Raccrocher';

  @override
  String get chatCallMute => 'Couper le micro';

  @override
  String get chatCallUnmute => 'Activer le micro';

  @override
  String get chatCallSpeaker => 'Haut-parleur';

  @override
  String get chatCallCamera => 'Caméra';

  @override
  String get chatCallSwitchCamera => 'Changer';

  @override
  String get chatCallIssueTitle => 'Problème d’appel';

  @override
  String get chatCallMicrophoneDenied =>
      'Bantera doit accéder au micro pour lancer un appel.';

  @override
  String get chatCallMicrophoneSettings =>
      'L’accès au micro est désactivé pour Bantera. Ouvre les Réglages et active-le pour passer des appels.';

  @override
  String get chatCallCameraDenied =>
      'Bantera doit accéder à la caméra pour lancer un appel vidéo.';

  @override
  String get chatCallCameraSettings =>
      'L’accès à la caméra est désactivé pour Bantera. Ouvre les Réglages et active-le pour passer des appels vidéo.';

  @override
  String get chatCallBusy => 'Cette personne est déjà en ligne.';

  @override
  String get chatCallUnavailable =>
      'Cette personne n’est pas disponible pour un appel pour le moment.';

  @override
  String get chatCallNetworkRestricted =>
      'Ce réseau ne permet pas d’établir l’appel. Essaie le Wi-Fi ou un autre réseau.';

  @override
  String get chatCallFailed => 'Impossible de lancer l’appel. Réessaie.';

  @override
  String get chatGroupReady =>
      'Ce groupe est prêt à recevoir des messages audio.';

  @override
  String get chatHoldToStartDm =>
      'Maintiens pour enregistrer et démarrer la conversation.';

  @override
  String get chatNoGroupAudio => 'Aucun audio dans le groupe pour l’instant.';

  @override
  String get chatNoDmAudio =>
      'Aucun audio dans cette conversation pour l’instant.';

  @override
  String get chatSendingAudio => 'Envoi de l’audio...';

  @override
  String get chatRecordingReleaseToSend =>
      'Enregistrement... relâche pour envoyer';

  @override
  String get chatHoldToRecordAudio => 'Maintiens pour enregistrer';

  @override
  String get chatTapOrHoldToRecordAudio =>
      'Appuie ou maintiens pour enregistrer';

  @override
  String get chatTapToSendAudio => 'Appuie pour envoyer';

  @override
  String get chatRecordingStatus => 'Enregistrement...';

  @override
  String get chatGroupLabel => 'Groupe';

  @override
  String get chatNotificationsEnabledForDm =>
      'Notifications activées pour cette conversation.';

  @override
  String get chatNotificationsMutedForDm =>
      'Notifications coupées pour cette conversation.';

  @override
  String chatBlockUserTitle(String user) {
    return 'Bloquer $user ?';
  }

  @override
  String get chatBlockUserBody =>
      'Vous ne verrez plus vos messages privés ni vos messages dans les groupes communs jusqu’au déblocage.';

  @override
  String chatBlockUserSuccess(String user) {
    return '$user a été bloqué.';
  }

  @override
  String get chatBlockUserFailed =>
      'Impossible de bloquer cette personne. Réessaie.';

  @override
  String get chatDeleteMessage => 'Supprimer le message';

  @override
  String get chatDeleteMessageTitle => 'Supprimer ce message ?';

  @override
  String get chatDeleteMessageBody =>
      'Ce message sera supprimé pour tous les participants de la conversation. Cette action est irréversible.';

  @override
  String get chatDeleteMessageSuccess => 'Message supprimé';

  @override
  String get chatDeleteMessageFailed =>
      'Impossible de supprimer le message. Réessaie.';

  @override
  String get chatDeleteDmTitle => 'Supprimer cette conversation ?';

  @override
  String get chatDeleteDmBody =>
      'Elle sera seulement retirée de ta liste. Un nouveau message pourra la faire réapparaître.';

  @override
  String get chatMicrophoneRequiredTitle => 'Micro requis';

  @override
  String get chatMicrophoneRequiredSettings =>
      'Bantera doit accéder au micro pour enregistrer des messages audio. Active-le dans les Réglages.';

  @override
  String get chatMicrophoneRequiredBody =>
      'Bantera doit accéder au micro pour enregistrer des messages audio.';

  @override
  String get chatGroupNotReady => 'Ce groupe n’est pas encore prêt.';

  @override
  String get chatMessageAction => 'Message';

  @override
  String get chatRetranscribe => 'Retranscrire';

  @override
  String get chatTranscribe => 'Transcrire';

  @override
  String get chatTranscribingOnDevice => 'Transcription sur cet iPhone...';

  @override
  String get chatTranscriptionFailed => 'Échec de la transcription. Réessaie.';

  @override
  String get chatTranslate => 'Traduire';

  @override
  String get chatRetranslate => 'Retraduire';

  @override
  String get chatTranslating => 'Traduction sur cet iPhone...';

  @override
  String get chatTranslationFailed => 'Échec de la traduction. Réessaie.';

  @override
  String get chatGroupSettingsTitle => 'Réglages du groupe';

  @override
  String get chatNotifications => 'Notifications';

  @override
  String get chatBlockedUsersMenu => 'Utilisateurs bloqués';

  @override
  String get chatBlockedUsersTitle => 'Utilisateurs bloqués';

  @override
  String get chatBlockedPeople => 'Personnes bloquées';

  @override
  String get chatNoBlockedUsers => 'Aucun utilisateur bloqué.';

  @override
  String get chatNoBlockedPeople => 'Aucune personne bloquée.';

  @override
  String get chatUnblock => 'Débloquer';

  @override
  String chatUnblockUserTitle(String user) {
    return 'Débloquer $user ?';
  }

  @override
  String get chatUnblockUserBody =>
      'Vous pourrez de nouveau voir vos messages privés et vos messages dans les groupes communs.';

  @override
  String get chatUnblockFailed =>
      'Impossible de débloquer cette personne. Réessaie.';

  @override
  String get chatNotificationsTitle => 'Notifications de discussion';

  @override
  String get chatNotificationsSubtitle =>
      'Un seul réglage pour tout ton compte, sur tous tes appareils.';

  @override
  String get chatNotificationsDisabledTitle => 'Notifications désactivées';

  @override
  String get chatNotificationsDisabledSettings =>
      'Active les notifications dans les Réglages pour recevoir les alertes de discussion Bantera.';

  @override
  String get chatNotificationsDisabledBody =>
      'Bantera a besoin de l’autorisation de notifications pour activer les alertes de discussion.';

  @override
  String get chatNotificationUpdateFailed =>
      'Impossible de mettre à jour les notifications de discussion. Réessaie.';

  @override
  String get savedTitle => 'Médias sauvegardés';

  @override
  String get generateWithAiTitle => 'Générer avec l’IA';

  @override
  String get practiceLocalVideoTitle => 'Pratiquer avec une vidéo locale';

  @override
  String get uploadVideoTitle => 'Importer une vidéo';

  @override
  String get lessonDetailsTitle => 'Détails de la leçon';

  @override
  String get accountMoreTitle => 'Plus';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get deleteAccountSubtitle =>
      'Supprimer définitivement ton compte et tes données sur le serveur';

  @override
  String get confirmDeletionTitle => 'Confirmer la suppression';

  @override
  String get deleteAccountImmediateBody =>
      'Ton compte sera supprimé immédiatement. Tu devras créer un nouveau compte pour utiliser à nouveau Bantera.';

  @override
  String get deleteAccountConfirm => 'Supprimer le compte';

  @override
  String get couldNotDeleteAccount =>
      'Impossible de supprimer le compte. Réessaie.';

  @override
  String get deleteAccountQuestionTitle => 'Supprimer le compte ?';

  @override
  String get deleteAccountQuestionBody =>
      'Toutes tes informations personnelles et tes données seront définitivement supprimées de nos serveurs et ne pourront pas être récupérées.';

  @override
  String get typeDeleteLabel => 'Saisis « DELETE » pour continuer';

  @override
  String get continueLabel => 'Continuer';

  @override
  String get confirmLabel => 'Confirmer';

  @override
  String get deleteLabel => 'Supprimer';

  @override
  String get removeFromListLabel => 'Retirer de la liste';

  @override
  String get startLabel => 'Commencer';

  @override
  String get doneLabel => 'OK';

  @override
  String get discoverSearchHint => 'Rechercher un titre ou une transcription…';

  @override
  String get discoverNoMoreResults => 'Aucun autre résultat';

  @override
  String get discoverSetLearningLanguagePrompt =>
      'Choisis ta langue d’apprentissage pour voir du contenu ici';

  @override
  String discoverNoPublicContentInLanguage(String language) {
    return 'Aucun contenu public en $language pour l’instant';
  }

  @override
  String discoverNoPublicContentInLanguageAtLevel(
    String language,
    String level,
  ) {
    return 'Aucun contenu public en $language pour le niveau $level pour l’instant';
  }

  @override
  String get discoverSetLanguageToDiscover =>
      'Choisis une langue d’apprentissage pour découvrir du contenu';

  @override
  String get mediaStartPractice => 'Commencer la pratique';

  @override
  String get mediaTranscript => 'Transcription';

  @override
  String mediaTranscriptLineCount(int count) {
    return '($count lignes)';
  }

  @override
  String get mediaShow => 'Afficher';

  @override
  String get mediaHide => 'Masquer';

  @override
  String get mediaNoTranscriptAvailable => 'Aucune transcription disponible.';

  @override
  String get lessonSaveTooltip => 'Sauvegarder';

  @override
  String get lessonUnsaveTooltip => 'Retirer des sauvegardes';

  @override
  String get mediaKindAudio => 'Audio';

  @override
  String get mediaKindVideo => 'Vidéo';

  @override
  String get practiceNoCues => 'Aucune phrase';

  @override
  String get practiceTranslating => 'Traduction…';

  @override
  String get practiceShowTranscript => 'Afficher la transcription';

  @override
  String get practiceTranslate => 'Traduire';

  @override
  String get practiceHideText => 'Masquer le texte';

  @override
  String get practiceTextLabel => 'Texte';

  @override
  String get practiceStop => 'Arrêter';

  @override
  String get practicePlayAll => 'Shadowing';

  @override
  String get practiceCompare => 'Comparer';

  @override
  String get practiceRecord => 'Enregistrer';

  @override
  String get practiceStopRecording => 'Arrêter';

  @override
  String get practiceRecords => 'Essais';

  @override
  String get practiceRecordsLocalOnlyFooter =>
      'Les essais sont stockés uniquement sur cet appareil et ne sont pas envoyés en ligne.';

  @override
  String get practiceRecordsEmpty =>
      'Aucun essai enregistré pour cette phrase.';

  @override
  String get practiceRecordingProcessError =>
      'Un problème est survenu lors du traitement de ton enregistrement.';

  @override
  String get practiceStartOver => 'Recommencer';

  @override
  String get practiceTranscriptHidden => 'Transcription masquée';

  @override
  String get practiceListenCarefully => 'Écoute attentivement…';

  @override
  String get practiceTranslationUnavailableForCue =>
      'Traduction indisponible pour cette phrase pour le moment.';

  @override
  String get practiceChooseTranslationLanguageTitle =>
      'Choisir la langue de traduction';

  @override
  String get practiceChooseTranslationLanguageDescription =>
      'Bantera traduira tes exercices d’écoute dans cette langue et l’enregistrera dans ton profil pour les prochaines sessions.';

  @override
  String get practiceChangeTranslationLanguageTitle =>
      'Changer la langue de traduction';

  @override
  String get practiceChangeTranslationLanguageDescription =>
      'Choisis la langue dans laquelle Bantera doit traduire. Ce nouveau choix sera enregistré dans ton profil.';

  @override
  String get practiceConfirmTranslationLanguageTitle =>
      'Confirmer la langue de traduction';

  @override
  String get practiceConfirmTranslationLanguageBody =>
      'Bantera enregistrera cette langue dans ton profil et l’utilisera par défaut pour traduire tes prochains exercices d’écoute.';

  @override
  String get practiceCouldNotSaveTranslationLanguage =>
      'Bantera n’a pas pu enregistrer ta langue de traduction.';

  @override
  String get practiceNoTranslationLanguagesFound =>
      'Bantera n’a trouvé aucune langue de traduction pour cette transcription.';

  @override
  String get practicePlayAllTitle => 'Shadowing';

  @override
  String get practicePlayAllDescription =>
      'Pause entre les phrases pour le shadowing :';

  @override
  String get practicePlayAllPauseZeroSeconds => '0 s';

  @override
  String get practicePlayAllPauseOneSecondLabel => '1 s';

  @override
  String get practicePlayAllPauseOneCuePlusOneSecond => '1 phrase + 1 s';

  @override
  String get practicePlayAllPauseOneCuePlusTwoSeconds => '1 phrase + 2 s';

  @override
  String get practicePlayAllTimesPerCueTitle => 'Répétitions par phrase';

  @override
  String get practicePlayAllTimesOnce => '1×';

  @override
  String get practicePlayAllTimesTwice => '2×';

  @override
  String get practicePlayAllTimesThrice => '3×';

  @override
  String get practiceSearchLanguagesHint => 'Rechercher une langue';

  @override
  String get practiceTranslationInstalled => 'Installée';

  @override
  String get practiceTranslationDownload => 'Télécharger';

  @override
  String get practiceStartOverTitle => 'Recommencer ?';

  @override
  String get practiceStartOverBody => 'Revenir à la première phrase ?';

  @override
  String get practiceNextFromLastTitle => 'Aller à la première phrase ?';

  @override
  String get practiceNextFromLastBody =>
      'Tu es sur la dernière phrase. Revenir à la première ?';

  @override
  String get practiceGoToFirstCue => 'Aller à la première phrase';

  @override
  String get practiceVideoOpenError =>
      'Impossible d’ouvrir la vidéo sélectionnée pour la pratique.';

  @override
  String get practiceAudioLoading => 'Chargement de l’audio…';

  @override
  String practiceAudioLoadingPercent(int percent) {
    return 'Chargement de l’audio $percent %';
  }

  @override
  String get practiceAudioError => 'Impossible de charger l’audio. Réessaie.';

  @override
  String get compareRecordYourVersion => 'Enregistre ta version';

  @override
  String compareTranscriptionLanguage(String locale) {
    return 'Langue de transcription : $locale';
  }

  @override
  String get compareOpenIphoneSettings => 'Ouvrir les Réglages de l’iPhone';

  @override
  String get comparePauseAttempt => 'Mettre l’essai en pause';

  @override
  String get comparePlayAttempt => 'Écouter l’essai';

  @override
  String get compareYourTranscribedAttempt => 'Transcription de ton essai';

  @override
  String get compareHighlightHint =>
      'Les mots que Bantera a reconnus différemment sont surlignés.';

  @override
  String get compareUncertainHint =>
      'Les mots en pointillés ont été reconnus, mais Bantera n’en était pas sûr : vérifie ta prononciation.';

  @override
  String get compareTryAgain => 'Réessayer';

  @override
  String get compareDone => 'OK';

  @override
  String get compareStatusTranscribing =>
      'Transcription de ton essai sur l’iPhone…';

  @override
  String get compareStatusRecording =>
      'Enregistrement… Touche à nouveau pour arrêter.';

  @override
  String get compareStatusSavedAttempt =>
      'Voici un essai enregistré pour cette phrase. Tu peux le réécouter ou réessayer.';

  @override
  String get compareStatusReplayOrRetry =>
      'Tu peux réécouter cet essai ou retenter la phrase.';

  @override
  String get compareStatusTapToRecord =>
      'Touche pour enregistrer ta version de cette phrase.';

  @override
  String get compareCouldNotStartRecording =>
      'Bantera n’a pas pu lancer l’enregistrement pour le moment.';

  @override
  String get compareCouldNotAccessRecording =>
      'Bantera n’a pas pu accéder à l’audio enregistré.';

  @override
  String get compareNoTranscriptGenerated =>
      'Impossible de transcrire cet essai. Réessaie en te rapprochant du micro.';

  @override
  String get compareRecentAttempts => 'Essais récents';

  @override
  String get compareAttemptsFooterNote =>
      'Bantera conserve tes essais sur cet iPhone pour que tu puisses suivre tes progrès sur une même phrase.';

  @override
  String compareMatchedCount(int count) {
    return '$count corrects';
  }

  @override
  String compareDifferentCount(int count) {
    return '$count différents';
  }

  @override
  String compareMissingCount(int count) {
    return '$count manquants';
  }

  @override
  String compareUncertainCount(int count) {
    return '$count incertains';
  }

  @override
  String get compareMicrophoneDeniedPermanent =>
      'L’accès au micro est désactivé pour Bantera. Ouvre Réglages de l’iPhone > Bantera > Micro et active-le pour enregistrer ta propre version.';

  @override
  String get compareMicrophoneDeniedRestricted =>
      'Cet iPhone restreint actuellement l’accès au micro pour Bantera. Vérifie Temps d’écran, la gestion de l’appareil ou les réglages système pour l’activer.';

  @override
  String get compareMicrophoneDeniedDefault =>
      'L’autorisation d’accès au micro est nécessaire pour enregistrer ta propre version. Si tu as ignoré la demande, ouvre Réglages de l’iPhone > Bantera > Micro et active-le.';

  @override
  String get compareSpeechRecognitionDeniedPermanent =>
      'L’accès à la reconnaissance vocale est désactivé pour Bantera. Ouvre Réglages de l’iPhone > Bantera > Reconnaissance vocale et active-le pour comparer ton enregistrement.';

  @override
  String get compareSpeechRecognitionDeniedRestricted =>
      'Cet iPhone restreint actuellement la reconnaissance vocale pour Bantera. Vérifie Temps d’écran, la gestion de l’appareil ou les réglages système pour l’activer.';

  @override
  String get compareSpeechRecognitionUnavailable =>
      'La reconnaissance vocale n’est pas disponible sur cet iPhone pour le moment.';

  @override
  String get compareSpeechRecognitionUnsupportedLocale =>
      'La reconnaissance vocale n’est pas disponible pour cette langue sur cet iPhone.';

  @override
  String get comparePlayAttemptTooltip => 'Écouter l’essai';

  @override
  String get comparePauseAttemptTooltip => 'Mettre l’essai en pause';

  @override
  String get createWhatToday => 'Que veux-tu faire aujourd’hui ?';

  @override
  String get createPracticeVideo => 'Pratiquer une vidéo';

  @override
  String get createYourMedia => 'Tes médias';

  @override
  String get createTryAgain => 'Réessayer';

  @override
  String get createUploadedVideosEmptyHint =>
      'Tes vidéos importées apparaîtront ici pour que tu puisses les rouvrir et pratiquer phrase par phrase.';

  @override
  String get createUploadingTips => 'Conseils d’importation';

  @override
  String get createUploadingTipsBody =>
      'Garde ton audio sous les 3 minutes pour un meilleur engagement. Des sous-titres clairs sont générés automatiquement !';

  @override
  String get createOnThisIphone => 'Sur cet iPhone';

  @override
  String get createLocalVideosEmptyHint =>
      'Les vidéos que tu pratiques en local sont enregistrées sur cet iPhone pour que tu puisses les rouvrir plus tard sans nouvelle transcription.';

  @override
  String get createOnDeviceBadge => 'Sur l’appareil';

  @override
  String get createSignInToLoadVideos =>
      'Reconnecte-toi pour charger tes vidéos importées.';

  @override
  String createVideoMetaCues(int count) {
    return '$count phrases';
  }

  @override
  String get createPublicBadge => 'Public';

  @override
  String get createPrivateBadge => 'Privé';

  @override
  String get createAiBadge => 'IA';

  @override
  String get createDeleteSavedVideoTitle => 'Supprimer la vidéo enregistrée ?';

  @override
  String createDeleteSavedVideoBody(String title) {
    return 'Bantera va retirer « $title » de cet iPhone et supprimer les phrases de sa transcription.';
  }

  @override
  String get createDeleteMediaTitle => 'Supprimer le média ?';

  @override
  String createDeleteMediaBody(String title) {
    return '« $title » et sa transcription seront définitivement supprimés. Cette action est irréversible.';
  }

  @override
  String get removeFromListTitle => 'Retirer de la liste ?';

  @override
  String get removeFromListBody =>
      'Cet élément sera retiré de la liste. Cette action est irréversible.';

  @override
  String get editProfileChangeImage => 'Changer la photo de profil';

  @override
  String get editProfileUploading => 'Importation…';

  @override
  String get editProfileNameLabel => 'Nom';

  @override
  String get editProfileNameHint => 'Quel nom Bantera doit-il afficher ?';

  @override
  String get editProfileSaveNameButton => 'Enregistrer le nom';

  @override
  String get editProfileSaving => 'Enregistrement…';

  @override
  String get editProfileLanguagesSection => 'Langues';

  @override
  String get editProfileMyNativeLanguage => 'Ma langue maternelle';

  @override
  String get editProfileMyNativeLanguageSubtitle =>
      'Ta langue maternelle ou première langue';

  @override
  String get editProfileLearningLanguage => 'Langue d’apprentissage';

  @override
  String get editProfileLearningLanguageSubtitle =>
      'La langue que tu veux pratiquer';

  @override
  String get editProfileImageUpdated => 'Photo de profil mise à jour.';

  @override
  String get editProfileNameUpdated => 'Nom mis à jour.';

  @override
  String get editProfileEnterName => 'Saisis un nom.';

  @override
  String get editProfileNameMaxLength => '80 caractères maximum.';

  @override
  String get editProfileCouldNotLoadLanguages =>
      'Impossible de charger la liste des langues.';

  @override
  String get languagePickerNone => 'Aucune';

  @override
  String get languagePickerClearSelection => 'Effacer la sélection';

  @override
  String get languagePickerNoMatchingLanguages => 'Aucune langue trouvée.';

  @override
  String languagePickerTotals(int languages, int accents) {
    return '$languages langues · $accents accents';
  }

  @override
  String get editProfileNativeLanguageCleared => 'Langue maternelle effacée.';

  @override
  String get editProfileLearningLanguageCleared =>
      'Langue d’apprentissage effacée.';

  @override
  String editProfileNativeLanguageSetTo(String language) {
    return 'Langue maternelle : $language.';
  }

  @override
  String editProfileLearningLanguageSetTo(String language) {
    return 'Langue d’apprentissage : $language.';
  }

  @override
  String get profileLanguageSettings => 'Réglages de langue';

  @override
  String get profileLearningLabel => 'J’apprends';

  @override
  String get profileNotSet => 'Non défini';

  @override
  String get uploadedDetailYourAudio => 'Ton audio';

  @override
  String get uploadedDetailYourVideo => 'Ta vidéo';

  @override
  String get uploadedDetailDeleteAudioTitle => 'Supprimer l’audio ?';

  @override
  String get uploadedDetailDeleteAudioBody =>
      'L’audio et sa transcription seront définitivement supprimés. Cette action est irréversible.';

  @override
  String get uploadedDetailDeleteVideoTitle => 'Supprimer la vidéo ?';

  @override
  String get uploadedDetailDeleteVideoBody =>
      'La vidéo et sa transcription seront définitivement supprimées. Cette action est irréversible.';

  @override
  String get uploadedDetailAiGenerated => 'Généré par IA';

  @override
  String get uploadedDetailFileSize => 'Taille du fichier';

  @override
  String get uploadedDetailResolution => 'Résolution';

  @override
  String get uploadedDetailResolutionUnknown => 'Inconnue';

  @override
  String get uploadedDetailTranscribing => 'Transcription…';

  @override
  String get uploadedDetailNoTranscriptCuesYet =>
      'Aucune phrase de transcription disponible pour l’instant.';

  @override
  String uploadedDetailMediaDescription(int count) {
    return 'Ton extrait de pratique importé, avec $count phrases transcrites.';
  }

  @override
  String get uploadedDetailTranscriptionFailedFallback =>
      'Échec de la transcription. Phrases estimées utilisées.';

  @override
  String get uploadedDetailTranscriptionNoCues =>
      'La transcription n’a renvoyé aucune phrase.';

  @override
  String get uploadedDetailTranscriptionSourceYourUpload => 'Ton importation';

  @override
  String get aiGenLeaveTitle => 'Quitter cette page ?';

  @override
  String get aiGenLeaveBody =>
      'L’audio est encore en cours de génération. Si tu quittes maintenant, le processus sera annulé.';

  @override
  String get aiGenStay => 'Rester';

  @override
  String get aiGenLeave => 'Quitter';

  @override
  String get aiGenLoadingTitle => 'Création de ton audio…';

  @override
  String get aiGenLoadingSubtitle => 'Cela peut prendre jusqu’à une minute.';

  @override
  String get aiGenStepPreparingSpeechModel =>
      'Préparation du modèle vocal sur l’appareil';

  @override
  String get aiGenStepWritingDialogue => 'Rédaction du dialogue';

  @override
  String get aiGenStepGeneratingAudio => 'Génération de l’audio';

  @override
  String get aiGenStepAligningAudio => 'Alignement de l’audio';

  @override
  String get aiGenStepTranscribing => 'Transcription';

  @override
  String get aiGenStepCorrectingTranscript => 'Correction de la transcription';

  @override
  String get aiGenLanguageSection => 'Langue';

  @override
  String get aiGenSetLearningLanguagePrompt =>
      'Choisis ta langue d’apprentissage pour activer la génération';

  @override
  String get aiGenLoadingLanguage => 'Chargement de la langue…';

  @override
  String aiGenLanguageUnsupported(String language) {
    return 'La langue « $language » n’est pas prise en charge pour la génération.';
  }

  @override
  String get aiGenScenarioSection => 'Scénario';

  @override
  String get aiGenScenarioOptionalHint =>
      'Facultatif : sans sélection, un scénario sera choisi au hasard.';

  @override
  String get aiGenCustomScenarioHint => 'Décris ton scénario…';

  @override
  String get aiGenDurationSection => 'Durée';

  @override
  String aiGenDurationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get aiGenGenerateButton => 'Générer';

  @override
  String get aiGenOwnershipNotice =>
      'L’audio que tu génères ici devient du contenu communautaire Bantera, partagé publiquement comme matériel de pratique pour tous les apprenants.';

  @override
  String get aiGenOwnershipCheckbox =>
      'Partager cet audio comme contenu communautaire Bantera';

  @override
  String get aiGenOwnershipConfirmTitle =>
      'Partager comme contenu communautaire ?';

  @override
  String get aiGenOwnershipConfirmCancel => 'Annuler';

  @override
  String get aiGenOwnershipConfirmGenerate => 'Générer';

  @override
  String get aiGenFooterNotice =>
      'L’IA va écrire un dialogue à deux voix et le convertir en audio. Le résultat sera enregistré comme audio de pratique public.';

  @override
  String get aiScenarioCoffeeShop => 'Au café';

  @override
  String get aiScenarioLatestNews => 'Actualités';

  @override
  String get aiScenarioAirportReunion => 'Retrouvailles à l’aéroport';

  @override
  String get aiScenarioGroceryStore => 'À l’épicerie';

  @override
  String get aiScenarioDoctorVisit => 'Chez le médecin';

  @override
  String get aiScenarioJobInterview => 'Entretien d’embauche';

  @override
  String get aiScenarioNewNeighbour => 'Nouveau voisin';

  @override
  String get aiScenarioTechSupport => 'Assistance technique';

  @override
  String get aiScenarioBirthdaySurprise => 'Anniversaire surprise';

  @override
  String get aiScenarioGymTips => 'Conseils de salle de sport';

  @override
  String get aiScenarioWeatherSmalltalk => 'Parler de la météo';

  @override
  String get aiScenarioRestaurantOrder => 'Commander au restaurant';

  @override
  String get aiScenarioBookRecommendation => 'Recommandation de livre';

  @override
  String get aiScenarioBusDelay => 'Bus en retard';

  @override
  String get aiScenarioMovieDebate => 'Débat sur un film';

  @override
  String get aiScenarioCustom => 'Personnalisé…';

  @override
  String get errorNetworkUnreachable =>
      'Impossible de se connecter à Bantera. Vérifie ta connexion Internet.';

  @override
  String get errorNetworkCellularBlocked =>
      'Les données cellulaires sont désactivées pour Bantera. Dans Réglages, ouvre Bantera et active Données cellulaires, ou connecte-toi au Wi-Fi.';

  @override
  String get errorTlsConnection =>
      'Impossible d’établir une connexion sécurisée.';

  @override
  String get settingsRateAppPrompt =>
      'Tu aimes Bantera ? Une petite note sur l’App Store compte beaucoup pour nous.';

  @override
  String get settingsRateAppButton => 'Noter sur l’App Store';

  @override
  String get settingsSharePrompt =>
      'Tu connais quelqu’un qui apprend une langue ? Partage Bantera avec cette personne.';

  @override
  String get settingsShareButton => 'Partager Bantera';

  @override
  String get settingsContactButton => 'Nous contacter';

  @override
  String get localVideoDescription =>
      'Choisis une vidéo dans Photos et sa langue parlée, puis laisse l’iPhone la transcrire en arrière-plan avant de pratiquer phrase par phrase.';

  @override
  String get localVideoStep1Title => '1. Choisir une vidéo';

  @override
  String get localVideoChooseFromPhotos => 'Choisir dans Photos';

  @override
  String get localVideoChooseDifferent => 'Choisir une autre vidéo';

  @override
  String get localVideoSelectedFileLabel => 'Fichier sélectionné';

  @override
  String get localVideoSizeLabel => 'Taille';

  @override
  String get localVideoDurationLabel => 'Durée';

  @override
  String get localVideoLongVideoWarning =>
      'Cette vidéo dure plus de 3 minutes : Bantera aura peut-être besoin de plus de temps pour préparer la transcription et la traduction.';

  @override
  String get localVideoStep2Title => '2. Langue de transcription';

  @override
  String get localVideoChooseLanguagePlaceholder => 'Choisis la langue parlée';

  @override
  String get localVideoLanguageHint =>
      'Bantera retient ton dernier choix de langue et masque la transcription par défaut au début de la pratique.';

  @override
  String get localVideoStep3Title => '3. Pratiquer';

  @override
  String get localVideoPreparing => 'Préparation...';

  @override
  String get localVideoPracticeHint =>
      'Bantera transcrit d’abord sur l’appareil, puis ouvre la page d’écoute phrase par phrase, sans rien envoyer en ligne.';

  @override
  String get localVideoStatusLongVideo =>
      'Cette vidéo est assez longue : Bantera aura peut-être besoin de plus de temps pour la transcrire et la préparer.';

  @override
  String get localVideoStatusTranscribing =>
      'Transcription sur l’appareil et préparation des phrases...';

  @override
  String get localVideoStatusSaving =>
      'Enregistrement de la vidéo dans ta bibliothèque de pratique sur l’appareil...';

  @override
  String get localVideoStatusTranslationLong =>
      'Transcription terminée. Bantera prépare aussi la traduction dans ta langue enregistrée ; cette vidéo étant longue, cela peut prendre un peu plus de temps.';

  @override
  String get localVideoStatusTranslation =>
      'Transcription terminée. Préparation de la traduction dans ta langue enregistrée...';

  @override
  String get localVideoPickerTitle => 'Choisir la langue audio';

  @override
  String get savedCuesTitle => 'Phrases sauvegardées';

  @override
  String get savedCuesEmpty =>
      'Aucune phrase sauvegardée pour l’instant. Touche l’icône de signet pendant la pratique pour sauvegarder une phrase.';

  @override
  String get savedCuesDeleteTooltip => 'Retirer la phrase sauvegardée';

  @override
  String get savedCuesDeleteConfirmTitle => 'Retirer cette phrase ?';

  @override
  String get savedCuesDeleteConfirmBody =>
      'Cette phrase sera retirée de ta liste de sauvegardes.';

  @override
  String get savedCuesDeleteAllTooltip =>
      'Supprimer toutes les phrases sauvegardées';

  @override
  String get savedCuesDeleteAllConfirmTitle =>
      'Supprimer toutes les phrases sauvegardées ?';

  @override
  String get savedCuesDeleteAllConfirmBody =>
      'Toutes les phrases sauvegardées seront définitivement supprimées.';

  @override
  String get updateAlertTitle => 'Mise à jour disponible';

  @override
  String get updateAlertMessage =>
      'Une nouvelle version de Bantera est disponible. Mets à jour maintenant pour profiter des dernières fonctionnalités et améliorations.';

  @override
  String get updateCurrentVersionLabel => 'Version actuelle';

  @override
  String get updateAppStoreVersionLabel => 'Version sur l’App Store';

  @override
  String get updateAlertUpdate => 'Mettre à jour';

  @override
  String get updateAlertLater => 'Plus tard';

  @override
  String get checkForUpdateButton => 'Rechercher des mises à jour';

  @override
  String get upToDateAlertTitle => 'À jour';

  @override
  String upToDateAlertMessage(Object version) {
    return 'Bantera $version est la dernière version.';
  }

  @override
  String get sectionSupport => 'Assistance';

  @override
  String get permissionActionAllow => 'Autoriser';

  @override
  String get audioLevelBeginner => 'Débutant';

  @override
  String get audioLevelIntermediate => 'Intermédiaire';

  @override
  String get audioLevelAdvanced => 'Avancé';

  @override
  String get audioLevelAll => 'Tous les niveaux';

  @override
  String get audioLevelSelect => 'Choisir un niveau';

  @override
  String get audioLevelSection => 'Niveau';

  @override
  String get audioLevelRequired =>
      'Choisissez un niveau avant de générer l’audio.';

  @override
  String get wordActivityTitle => 'Mes réussites';

  @override
  String get wordActivityToday => 'Aujourd’hui';

  @override
  String get wordActivityThisWeek => 'Cette semaine';

  @override
  String get wordActivityTotal => 'Total';

  @override
  String get wordActivityListened => 'Mots écoutés';

  @override
  String get wordActivitySpoken => 'Mots prononcés';

  @override
  String get wordActivityHint =>
      'Estimation basée sur les transcriptions. Les répétitions comptent à nouveau.';

  @override
  String get dailyGoalTitle => 'Objectif quotidien';

  @override
  String get dailyGoalSet => 'Définir un objectif';

  @override
  String get dailyGoalEdit => 'Modifier l’objectif';

  @override
  String get dailyGoalChoose => 'Choisis ton objectif quotidien';

  @override
  String dailyGoalPreset(String minutes) {
    return '$minutes min par jour';
  }

  @override
  String get dailyGoalCustom => 'Personnalisé';

  @override
  String get dailyGoalListeningTarget => 'Mots écoutés par jour';

  @override
  String get dailyGoalSpeakingTarget => 'Mots prononcés par jour';

  @override
  String dailyGoalEstimate(String minutes) {
    return 'Environ $minutes min';
  }

  @override
  String dailyGoalTimeTotal(String minutes) {
    return 'Environ $minutes min au total';
  }

  @override
  String get dailyGoalTimeHint =>
      'Estimation : 120 mots écoutés et 60 prononcés par minute. Les pauses et ton rythme peuvent prendre plus de temps. Les objectifs sont enregistrés sur cet appareil pour ton compte.';

  @override
  String get dailyGoalValidation =>
      'Saisis un entier de 0 à 100 000. Mets 0 pour ne pas fixer d’objectif.';

  @override
  String get dailyGoalRemove => 'Supprimer l’objectif';

  @override
  String get dailyGoalRemoveConfirmation =>
      'Supprimer votre objectif quotidien et ses rappels ? Vos nombres de mots resteront enregistrés.';

  @override
  String get dailyGoalReached => 'Objectifs du jour atteints';

  @override
  String dailyGoalProgress(String count, String target) {
    return '$count/$target mots';
  }

  @override
  String get dailyGoalSaveFailed =>
      'Impossible d’enregistrer l’objectif. Réessaie.';

  @override
  String get wordActivityShare => 'Partager';

  @override
  String get wordActivityPreview => 'Aperçu';

  @override
  String wordActivityShareHeading(String language) {
    return 'Exprime-toi.\nÀ voix haute.';
  }

  @override
  String get wordActivitySavePhotos => 'Enregistrer dans Photos';

  @override
  String get wordActivitySaved => 'Enregistré dans Photos';

  @override
  String get wordActivitySaveFailed =>
      'Impossible d’enregistrer l’image. Réessaie.';

  @override
  String get wordActivityShareFailed =>
      'Impossible de partager l’image. Réessaie.';

  @override
  String get wordActivityPhotoPermission =>
      'Autorise Bantera à ajouter des photos dans les réglages, puis réessaie.';

  @override
  String get wordActivityScanToJoin => 'Scannez pour pratiquer';

  @override
  String get dailyGoalNoRequirement => 'Aucun objectif requis';

  @override
  String wordActivityLearningLanguage(String language) {
    return 'J’apprends $language';
  }

  @override
  String get wordActivityLegacyLabel => 'Activité antérieure (langue inconnue)';

  @override
  String get saveLabel => 'Enregistrer';

  @override
  String get wordActivityShareToNativeGroup => 'Partager au groupe natif';

  @override
  String get wordActivitySentToGroup => 'Partagé dans le groupe';

  @override
  String get dailyGoalNotificationLabel => 'Rappel de l’objectif quotidien';

  @override
  String get dailyGoalNotificationHint =>
      'Me rappeler si mes objectifs quotidiens ne sont pas atteints. Utilise mon fuseau horaire.';

  @override
  String get dailyGoalReminderTitle => 'Encore un peu de pratique aujourd’hui';

  @override
  String get dailyGoalReminderBody =>
      'Tes objectifs quotidiens ne sont pas encore atteints. Continue à écouter et à parler.';

  @override
  String get dailyGoalNotificationTime => 'Heure du rappel';

  @override
  String get dailyGoalRepeatLabel => 'Répéter';

  @override
  String get dailyGoalRepeatNever => 'Jamais';

  @override
  String get dailyGoalRepeatEveryDay => 'Tous les jours';

  @override
  String get dailyGoalRepeatWeekdays => 'En semaine';

  @override
  String get dailyGoalRepeatWeekends => 'Le week-end';

  @override
  String get dailyGoalRepeatOnceHint =>
      'Un rappel à la prochaine heure choisie, sans répétition.';

  @override
  String get discoverAllAccents => 'Tous les accents';

  @override
  String get wordActivityShareToday => 'Pratique du jour';

  @override
  String get wordActivityShareSpokenToday => 'Aujourd’hui, j’ai dit';

  @override
  String wordActivityShareWordUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'mots',
      one: 'mot',
    );
    return '$_temp0';
  }

  @override
  String wordActivityShareListened(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'J’ai aussi écouté $countString mots',
      one: 'J’ai aussi écouté $countString mot',
    );
    return '$_temp0';
  }

  @override
  String get wordActivityShareEncouragement => 'Chaque mot prononcé compte.';

  @override
  String get wordActivityShareInvitation =>
      'Pratiquons ensemble. Osons parler.';

  @override
  String wordActivityListeningSummary(
    String period,
    String progress,
    int count,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Aujourd’hui, j’ai écouté $progress mots',
      one: 'Aujourd’hui, j’ai écouté $progress mot',
    );
    String _temp1 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cette semaine, j’ai écouté $progress mots',
      one: 'Cette semaine, j’ai écouté $progress mot',
    );
    String _temp2 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Au total, j’ai écouté $progress mots',
      one: 'Au total, j’ai écouté $progress mot',
    );
    String _temp3 = intl.Intl.selectLogic(period, {
      'today': '$_temp0',
      'week': '$_temp1',
      'other': '$_temp2',
    });
    return '$_temp3';
  }

  @override
  String wordActivitySpeakingSummary(
    String period,
    String progress,
    int count,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Aujourd’hui, j’ai prononcé $progress mots',
      one: 'Aujourd’hui, j’ai prononcé $progress mot',
    );
    String _temp1 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cette semaine, j’ai prononcé $progress mots',
      one: 'Cette semaine, j’ai prononcé $progress mot',
    );
    String _temp2 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Au total, j’ai prononcé $progress mots',
      one: 'Au total, j’ai prononcé $progress mot',
    );
    String _temp3 = intl.Intl.selectLogic(period, {
      'today': '$_temp0',
      'week': '$_temp1',
      'other': '$_temp2',
    });
    return '$_temp3';
  }

  @override
  String get wordActivityListening => 'Écoute';

  @override
  String get wordActivitySpeaking => 'Expression orale';

  @override
  String get wordActivityTrend => 'Évolution de la pratique';

  @override
  String get wordActivitySevenDays => '7 jours';

  @override
  String get wordActivityThirtyDays => '30 jours';

  @override
  String get wordActivityWords => 'Mots';

  @override
  String get wordActivityTrendEmpty =>
      'Aucune pratique enregistrée pour cette période.';

  @override
  String get wordActivityAllTime => 'Tout';

  @override
  String get profileLibraryTitle => 'Votre bibliothèque';

  @override
  String get practiceHistoryTitle => 'Historique de pratique';

  @override
  String get practiceHistorySubtitle =>
      'Consultez vos progrès et reprenez la pratique';

  @override
  String get profileSavedMediaSubtitle => 'Vos audios et vidéos enregistrés';

  @override
  String get profileSavedCuesSubtitle => 'Révisez les phrases à pratiquer';

  @override
  String practiceHistoryProgress(String completed, String total) {
    return '$completed/$total extraits écoutés';
  }

  @override
  String get practiceHistoryEmpty => 'Votre prochaine séance commence ici';

  @override
  String get practiceHistoryDeviceNote =>
      'Pratiquez une leçon pour voir vos progrès ici. L’historique est enregistré sur cet appareil.';

  @override
  String get practiceHistoryRemoveBody =>
      'Retirer cette leçon de l’historique et réinitialiser sa progression et son point de reprise ? Vos médias, phrases enregistrées et totaux de mots seront conservés.';

  @override
  String get practiceHistoryUnavailable =>
      'Ce média n’est plus sur cet appareil. Vous pouvez le retirer de l’historique.';

  @override
  String get aiClearHistory => 'Effacer l’historique';

  @override
  String get aiClearHistoryBody =>
      'Supprimer les messages, audios et souvenirs de conversation de l’IA sur cet appareil ? L’appel sera terminé. Votre bibliothèque, profil et rappels programmés seront conservés.';

  @override
  String get aiLocalHistory =>
      'Les échanges IA reçus restent sur cet appareil. Le contexte utile est envoyé à l’IA. Les horaires et notes des rappels sont sur le serveur. Leur audio y reste temporairement jusqu’à réception ou annulation, pendant sept jours au maximum.';

  @override
  String get aiSayingGoodbye => 'Au revoir';

  @override
  String get aiSend => 'Envoyer';

  @override
  String get aiPlayAudio => 'Lire l’audio';

  @override
  String get aiWelcome =>
      'Votre partenaire de pratique linguistique. Envoyez un message vocal ou lancez un appel audio de neuf minutes.';

  @override
  String get aiChatSubtitle => 'Messages vocaux et appels audio';

  @override
  String get aiRecordVoiceMessage => 'Enregistrer un message vocal';

  @override
  String get aiPrivacyNotice => 'Avis de confidentialité';

  @override
  String get aiUsageTitle => 'Utilisation';

  @override
  String get aiUsageBody =>
      'Maintenez le bouton vocal puis relâchez pour envoyer, ou touchez le micro pour enregistrer. L’envoi est automatique après 3 minutes. Pratiquez l’expression et la compréhension orales avec Bantera AI dans la langue et l’accent que vous apprenez.\n\nTouchez le téléphone pour un appel audio de 9 minutes. L’IA vous salue en premier. Touchez Traduire sur un message si nécessaire.\n\nDites « Appelle-moi dans 10 minutes pour me rappeler de pratiquer l’anglais », ou indiquez une heure précise. Donnez aussi le sujet du rappel. Sinon, l’IA vous le demandera avant de programmer l’appel.\n\nActivez les notifications d’appel sur votre iPhone et restez connecté à Internet. Répondez à l’appel pour entendre le rappel. L’appel peut être retardé.\n\nDemandez un rappel dans dix minutes pour recevoir un message vocal. Dites « Appelle-moi » uniquement pour un appel. Les heures suivent votre fuseau actuel. Les rappels restent visibles sept jours.\n\nLes échanges IA reçus restent sur cet appareil. Le contexte utile est envoyé à l’IA. Les horaires et notes des rappels sont sur le serveur. Leur audio y reste temporairement jusqu’à réception ou annulation, pendant sept jours au maximum.';

  @override
  String get aiCallConfirmTitle => 'Démarrer un appel audio ?';

  @override
  String get aiCallConfirmBody =>
      'Discutez avec Bantera AI pendant 9 minutes maximum. L’IA vous salue en premier.';

  @override
  String get aiCallConfirmStart => 'Démarrer l’appel';

  @override
  String get aiReplying => 'Bantera AI répond…';

  @override
  String get aiRemindersTitle => 'Rappels';

  @override
  String get aiReminderMessage => 'Message vocal';

  @override
  String get aiReminderCall => 'Appel audio';

  @override
  String get aiReminderEmpty => 'Aucun rappel';

  @override
  String get aiReminderCancelTitle => 'Annuler ce rappel ?';

  @override
  String get aiReminderPending => 'Programmé';

  @override
  String get aiReminderPreparing => 'En cours';

  @override
  String get aiReminderReady => 'Prêt';

  @override
  String get aiReminderDelivered => 'Remis';

  @override
  String get aiReminderCancelled => 'Annulé';

  @override
  String get aiReminderFailed => 'Non remis';

  @override
  String get aiReminderScheduleHelp =>
      'Demandez un rappel dans dix minutes pour recevoir un message vocal. Dites « Appelle-moi » uniquement pour un appel. Les heures suivent votre fuseau actuel. Les rappels restent visibles sept jours.';

  @override
  String get aiReplyInterrupted => 'Réponse interrompue.';

  @override
  String get aiWebSearching => 'Recherche sur le Web…';

  @override
  String get aiWebUnavailable => 'Recherche indisponible';

  @override
  String get aiWebSources => 'Sources';

  @override
  String get aiWebSearchHelp =>
      'Demandez à Bantera AI de chercher sur le Web. Cet appareil envoie la recherche à DuckDuckGo, puis les extraits à l’IA. Touchez une source pour l’ouvrir. La recherche peut être indisponible.';

  @override
  String get aiImages => 'Images';

  @override
  String get aiImagesSearching => 'Recherche d’images…';

  @override
  String get aiImagesUnavailable => 'Images indisponibles. Réessaie plus tard.';

  @override
  String get aiImageShare => 'Enregistrer ou partager l’image';

  @override
  String get aiImagesHelp =>
      'Les recherches d’images s’effectuent sur cet appareil. Vous pouvez joindre jusqu’à 4 images depuis l’appareil photo, Photos ou Fichiers à un message vocal. Les pièces jointes et la voix sont transmises à l’IA via Bantera pour traitement ; Bantera ne stocke pas ces images sur ses serveurs. Les copies restent dans l’historique de cet appareil. Touchez une image pour l’agrandir. Les images web incluent des liens vers leurs sources pour consulter les droits d’utilisation.';

  @override
  String get aiImagesRights => 'Consulter les droits auprès de la source';

  @override
  String get vocabTitle => 'Vocabulaire';

  @override
  String get vocabAdd => 'Ajouter un mot';

  @override
  String get vocabEdit => 'Modifier le mot';

  @override
  String get vocabRemove => 'Supprimer ce mot ?';

  @override
  String get vocabWord => 'Mot ou expression';

  @override
  String get vocabMeaning => 'Définition courte';

  @override
  String get vocabExample => 'Exemple (facultatif)';

  @override
  String get vocabRequired => 'Veuillez remplir ce champ.';

  @override
  String get vocabSaved => 'mots enregistrés';

  @override
  String get vocabDue => 'À réviser';

  @override
  String get vocabAll => 'Tous les mots';

  @override
  String get vocabNewest => 'Plus récents';

  @override
  String get vocabOldest => 'Plus anciens';

  @override
  String get vocabLearned => 'Ajouté le';

  @override
  String get vocabReviewed => 'Révisé';

  @override
  String get vocabMarkReviewed => 'Marquer comme révisé';

  @override
  String get vocabSearch => 'Rechercher un mot ou une définition';

  @override
  String get vocabEmpty => 'Votre prochain mot commence ici';

  @override
  String get vocabNoMatches => 'Aucun mot correspondant';

  @override
  String get vocabDuplicate => 'Ce mot est déjà enregistré.';

  @override
  String get vocabHelp =>
      'Demandez à Bantera AI de retenir un mot, d’expliquer le dernier ou de réviser votre vocabulaire. Vous pouvez aussi ajouter et modifier des mots ici.';

  @override
  String get vocabPrivacy =>
      'Enregistré uniquement sur cet appareil. Le vocabulaire demandé est partagé avec l’IA pour répondre. Effacer le chat conserve votre vocabulaire.';

  @override
  String get aiKeysTitle => 'Préférence de clé IA';

  @override
  String get aiKeysDescription =>
      'Pour les leçons et conversations vocales Google. Les changements concernent les nouvelles demandes. L’administrateur gère l’accès et la clé.';

  @override
  String get aiKeysRegular => 'Clés standard uniquement';

  @override
  String get aiKeysFallback => 'Clé payante en secours';

  @override
  String get aiKeysPaidOnly => 'Clé payante uniquement';

  @override
  String get aiAttachImages => 'Joindre des images';

  @override
  String get aiAttachmentHint =>
      'Ajoutez jusqu’à 4 images, puis enregistrez un message vocal.';

  @override
  String get aiAttachmentLocked =>
      'Les images sont verrouillées pendant l’enregistrement. Annulez pour les modifier.';

  @override
  String get aiAttachmentError =>
      'Impossible d’ajouter cette image. Essayez une photo plus petite ou une autre image.';

  @override
  String get aiCamera => 'Appareil photo';

  @override
  String get aiPhotos => 'Photos';

  @override
  String get aiFiles => 'Fichiers';

  @override
  String get aiRemoveImage => 'Retirer l’image';

  @override
  String get aiConsentTitle => 'Autoriser le partage avec l’IA ?';

  @override
  String get aiConsentIntro =>
      'Avec votre accord, Bantera transmet les données suivantes via ses serveurs aux fournisseurs d’IA pour les fonctions utilisées.';

  @override
  String get aiConsentGoogle =>
      'Conversations, leçons et rappels : voix, transcriptions, images jointes, consignes, historique et résumés pertinents, nom, langues et niveau, activité d’apprentissage, leçons et phrases enregistrées, vocabulaire demandé, fuseau horaire et détails des rappels. Google les utilise pour comprendre vos demandes et générer des réponses personnalisées, des textes de leçons et de la parole. Google peut aussi utiliser les données traitées gratuitement pour améliorer ses produits et les faire examiner par des personnes. Ne partagez pas d’informations sensibles ou confidentielles.';

  @override
  String get aiConsentCloudflare =>
      'Avatars : nom, genre choisi et langues. Couvertures de leçons : titre et langue. Cloudflare utilise ces données pour générer des images.';

  @override
  String get aiConsentChoice =>
      'Seules les données nécessaires sont envoyées. « Pas maintenant » permet de continuer sans les fonctions d’IA. Désactivez les futurs partages sur cet appareil dans Paramètres > Partage de données avec l’IA.';

  @override
  String get aiConsentPolicy => 'Politique de confidentialité';

  @override
  String get aiConsentDecline => 'Pas maintenant';

  @override
  String get aiConsentAgree => 'Accepter et continuer';

  @override
  String get aiConsentSettings => 'Partage de données avec l’IA';

  @override
  String get aiConsentEnabled =>
      'Le partage avec l’IA est autorisé sur cet appareil.';

  @override
  String get aiConsentDisabled =>
      'Le partage avec l’IA est désactivé sur cet appareil.';

  @override
  String get aiConsentRevoke => 'Désactiver le partage avec l’IA';

  @override
  String get aiConsentExistingRequests =>
      'Les demandes déjà envoyées peuvent aboutir. Les rappels programmés peuvent continuer ; gérez-les et annulez-les ci-dessous. La désactivation ne supprime pas les données déjà envoyées.';

  @override
  String get aiConsentSaveFailed =>
      'Impossible d’enregistrer votre choix. Réessayez.';

  @override
  String get aiConsentSearch =>
      'Avec la recherche web ou d’images IA, les requêtes sont aussi envoyées à Microsoft Bing, DuckDuckGo ou Wikimedia Commons, et les résultats peuvent être partagés avec Google.';

  @override
  String get navPractice => 'Pratique';

  @override
  String get quickInstruction => 'Écoutez, puis dites votre réponse.';

  @override
  String get quickPreparing => 'Préparation de votre exercice…';

  @override
  String get quickPreparingHint =>
      'Une courte conversation arrive. Nous préparons la suite pendant votre entraînement.';

  @override
  String get quickCue1 => 'Réplique 1 · Écouter';

  @override
  String get quickCue2 => 'Réplique 2 · Votre réponse';

  @override
  String get quickSpeakHint =>
      'Touchez pour commencer, puis à nouveau pour vérifier. Ou maintenez en parlant et relâchez pour vérifier.';

  @override
  String get quickSpeak => 'Touchez ou maintenez pour parler';

  @override
  String get quickChecking => 'Vérification de votre réponse…';

  @override
  String get quickCorrect => 'Cette réponse convient. Bien joué.';

  @override
  String get quickIncorrect => 'Essayez l’autre réponse.';

  @override
  String get quickUnclear => 'Je n’ai pas bien entendu. Réessayez.';

  @override
  String get quickNext => 'Exercice suivant';

  @override
  String get quickAgain => 'Dire à nouveau';

  @override
  String get quickUnavailable =>
      'La préparation prend un peu plus de temps. Réessayez.';

  @override
  String get quickStart => 'Commencer';

  @override
  String get quickChooseLanguage =>
      'Choisissez une langue à apprendre dans Modifier le profil.';

  @override
  String get quickCallActive => 'Terminez votre appel avant de vous entraîner.';

  @override
  String get goalCelebrationMessage =>
      'Vous avez pris du temps pour apprendre aujourd’hui. Chaque mot compte.';

  @override
  String get goalCelebrationContinue => 'Continuer à pratiquer';

  @override
  String get quickHeard => 'Ce que nous avons entendu';

  @override
  String get quickCompareReply => 'Comparez avec cette réponse';

  @override
  String get quickDifferenceHint =>
      'Les passages surlignés indiquent des différences ou une reconnaissance incertaine, pas des erreurs de prononciation avérées.';

  @override
  String get quickRecognitionNote =>
      'La reconnaissance vocale peut se tromper.';

  @override
  String get quickLevelsLink => 'Comment fonctionnent les niveaux?';

  @override
  String get quickLevelsIntro =>
      'Chaque langue commence au niveau A0. Ton niveau s’adapte automatiquement au fil des exercices.';

  @override
  String get quickLevelsWindow =>
      'Après 12 exercices évalués à ton niveau actuel, nous examinons tes 12 derniers résultats.';

  @override
  String get quickLevelsUp => '10–12 bonnes réponses : niveau validé.';

  @override
  String get quickLevelsStay =>
      '5–9 réponses correctes : tu restes à ce niveau.';

  @override
  String get quickLevelsDown =>
      '0–4 réponses correctes : tu descends d’un niveau.';

  @override
  String get quickLevelsScoring =>
      'Seule ta première réponse clairement reconnue à chaque exercice compte. Les enregistrements peu clairs et les exercices ignorés ne comptent pas.\n\nA1–C2: Les exercices avec traduction ne comptent pas pour les changements de niveau. Les résultats sans traduction comptent au passage à l’exercice suivant.';

  @override
  String get quickLevelsReset =>
      'Après un changement de niveau, une nouvelle série de 12 commence. A0 est le niveau le plus bas et C2 le plus élevé.';

  @override
  String get quickSkipTitle => 'Passer cet exercice ?';

  @override
  String get quickSkipMessage =>
      'Tu n’as pas encore réussi cet exercice. Passer au suivant ?';

  @override
  String get quickSkipAction => 'Passer l’exercice';

  @override
  String get quickSetGoal => 'Fixer un objectif';

  @override
  String get quickShowTranslation => 'Afficher la traduction';

  @override
  String get quickTranslationHint =>
      'Afficher la traduction exclut cet exercice des changements de niveau.';

  @override
  String get quickTranslationExcluded =>
      'Traduction consultée · Cet exercice ne changera pas votre niveau.';

  @override
  String get quickCompletedToday => 'Terminés aujourd’hui';

  @override
  String get quickChooseLevel => 'Choisir le niveau';

  @override
  String quickCurrentLevel(String level) {
    return 'Niveau actuel : $level';
  }

  @override
  String get quickLevelLocked => 'Niveau pas encore atteint';

  @override
  String quickSwitchLevel(String level) {
    return 'Pratiquer au niveau $level ?';
  }

  @override
  String quickLevelLockedBody(String level, String current) {
    return 'Atteins $level en pratiquant pour le débloquer. Ton niveau actuel est $current.';
  }

  @override
  String quickReviewLevelBody(String current) {
    return 'Ton niveau $current et ta progression sont conservés. Les exercices plus faciles ne changent pas ton niveau. Tu peux revenir à $current à tout moment.';
  }

  @override
  String get quickReturnLevelBody =>
      'Continue à ton niveau actuel. Les réponses sans traduction compteront de nouveau pour les changements de niveau.';

  @override
  String quickReviewMode(String level) {
    return 'Révision · Niveau actuel : $level';
  }

  @override
  String get quickA0Label => 'Partir de zéro';

  @override
  String get quickA0Description =>
      'A0 est l’étape de découverte de Bantera avant A1, inspirée du pré-A1. Ce n’est pas un niveau officiel du CECR. Commencez par des mots et de courtes expressions du quotidien.';

  @override
  String get quickA0Hint =>
      'Écoutez les exemples et consultez leur sens, puis répondez. A0 inclut une aide à l’apprentissage ; votre première réponse clairement reconnue compte.';

  @override
  String get quickSave => 'Enregistrer l’exercice';

  @override
  String get quickUnsave => 'Retirer des favoris';

  @override
  String get quickSaved => 'Exercices enregistrés';

  @override
  String get quickSavedEmpty =>
      'Aucun exercice enregistré. Choisis « Enregistrer l’exercice » dans le menu … pendant la pratique.';

  @override
  String get quickSavedDeviceNote =>
      'Enregistrés sur cet appareil pour ton compte. Réécoute la question et les réponses. Une connexion Internet est nécessaire pour l’audio.';

  @override
  String get quickSavedError =>
      'Impossible de mettre à jour les exercices enregistrés. Réessaie.';

  @override
  String get leaderboardTitle => 'Classement à l’oral';

  @override
  String get leaderboardScope => '30 derniers jours';

  @override
  String get leaderboardYourPosition => 'Ta position';

  @override
  String get leaderboardSpokenWords => 'mots prononcés';

  @override
  String get leaderboardOpen => 'Voir le classement';

  @override
  String get leaderboardError => 'Impossible d’actualiser. Réessaie.';

  @override
  String get leaderboardLearner => 'Apprenant';

  @override
  String get leaderboardYou => 'Toi';

  @override
  String get leaderboardRefresh => 'Actualiser';

  @override
  String get leaderboardLoading => 'Chargement du classement';

  @override
  String get leaderboardEncouragement =>
      'Chaque conversation compte. Avance à ton rythme.';

  @override
  String get leaderboardUpdate =>
      'Un classement actualisé est disponible. Actualise quand tu veux.';

  @override
  String get leaderboardEmpty =>
      'Pas encore d’activité orale. Commence par une conversation.';

  @override
  String get leaderboardNoActivity =>
      'Parle dans Pratique ou Chats pour obtenir une place.';

  @override
  String get leaderboardFootnote =>
      'Les totaux égaux partagent le même rang. Aujourd’hui et les 29 jours précédents en UTC. Les mots hors ligne sont ajoutés après synchronisation.';

  @override
  String get leaderboardLegacy =>
      'L’activité passée conserve sa date d’origine. La nouvelle utilise UTC.';

  @override
  String get leaderboardLoadMore => 'Charger plus';

  @override
  String quickLevelUpTitle(String level) {
    return 'Vous avez atteint le niveau $level';
  }

  @override
  String get quickLevelUpBody =>
      'Votre pratique de l’écoute et de la parole porte ses fruits. Prenez confiance, une conversation à la fois.';

  @override
  String get quickTranslationLanguageLabel => 'Langue de traduction';

  @override
  String get quickTranslationLanguageBody =>
      'Choisissez la langue de traduction pour cette langue d’apprentissage. Votre choix sera mémorisé sur cet appareil.';

  @override
  String get quickTranslationFallbackBody =>
      'La traduction de cette langue d’apprentissage vers votre langue maternelle est indisponible. Choisissez une autre langue. Ce choix sera mémorisé pour cette langue d’apprentissage sur cet appareil.';

  @override
  String get quickTranslationDownloadTitle =>
      'Télécharger les langues de traduction ?';

  @override
  String get quickTranslationDownloadBody =>
      'Votre téléphone a besoin de fichiers de langue pour traduire. Leur téléchargement nécessite une connexion Internet.';

  @override
  String get quickTranslationPreparing =>
      'Préparation des langues de traduction…';

  @override
  String get quickTranslationChoosePrompt =>
      'Choisissez une langue de traduction pour continuer.';

  @override
  String get quickTranslationDownloadNeeded =>
      'Téléchargez les langues de traduction pour continuer.';

  @override
  String practiceExplainTitle(String word) {
    return 'Faire expliquer « $word » par Bantera AI ?';
  }

  @override
  String get practiceExplainAction => 'Demander à l’IA';

  @override
  String practiceExplainMessage(String word, String sentence) {
    return 'Explique « $word » dans cette phrase : $sentence';
  }

  @override
  String get aiVideosSearching => 'Recherche de vidéos…';

  @override
  String get aiVideosUnavailable =>
      'Aucune vidéo trouvée. Réessayez plus tard.';

  @override
  String get aiPlayVideo => 'Lire la vidéo';

  @override
  String get aiVideoEmbedUnavailable =>
      'Cette vidéo ne peut pas être lue ici. Ouvrez-la dans le navigateur.';

  @override
  String get aiOpenVideoBrowser => 'Ouvrir dans le navigateur';

  @override
  String quickPlaybackSpeed(String speed) {
    return 'Vitesse de lecture : $speed×. Touchez pour changer.';
  }

  @override
  String get quickPauseAudio => 'Mettre en pause';

  @override
  String get quickResumeAudio => 'Reprendre la lecture';

  @override
  String get quickClearSavedTitle =>
      'Supprimer tous les exercices enregistrés ?';

  @override
  String get quickClearSavedBody =>
      'Supprimer de cet appareil tous les exercices enregistrés pour ce compte ?';

  @override
  String get practicePronunciation => 'Prononciation';

  @override
  String get practicePronunciationPreparing =>
      'Préparation de la prononciation…';

  @override
  String get practicePronunciationUnavailable =>
      'La prononciation est indisponible pour le moment.';

  @override
  String get practicePronunciationSaveFailed =>
      'Impossible d’enregistrer le réglage de prononciation.';

  @override
  String get practiceReleaseToCheck => 'Relâchez pour vérifier';

  @override
  String get practiceTapToCheck => 'Touchez pour vérifier';

  @override
  String get practiceMicStarting => 'Démarrage du micro…';

  @override
  String get quickLevelStateLocked => 'Verrouillé';

  @override
  String get quickLevelPracticing => 'En cours';

  @override
  String get quickLevelPassed => 'Réussi';

  @override
  String get quickLevelStatesExplanation =>
      'Commencez à A0. Réussissez au moins 10 des 12 derniers exercices évalués pour valider un niveau et débloquer le suivant. Atteindre C2 le débloque ; il faut aussi réussir 10 exercices sur 12 pour le terminer. Les niveaux validés le restent, même si un niveau plus facile est conseillé pour réviser.';
}
