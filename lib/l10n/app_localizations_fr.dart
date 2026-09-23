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
  String get navDiscover => 'Découvrir';

  @override
  String get navCreate => 'Créer';

  @override
  String get navProfile => 'Profil';

  @override
  String get chatsTitle => 'Discussions';

  @override
  String get chatNoChatsYet => 'Aucune discussion pour l’instant.';

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
  String get languagePickerMoreComingSoon =>
      'D’autres langues arrivent bientôt';

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
  String get aiGenLoadingSubtitle =>
      'Cela peut prendre jusqu’à une minute.\nReste sur cette page pendant la génération.';

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
}
