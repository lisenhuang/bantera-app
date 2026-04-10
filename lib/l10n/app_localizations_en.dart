// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Bantera';

  @override
  String get appTagline => 'Language practice, cue by cue.';

  @override
  String get authContinueWithApple => 'Continue with Apple';

  @override
  String get authAppleUnavailable =>
      'Sign in with Apple is unavailable on this device.';

  @override
  String get authOrSignInEmail => 'or sign in with email';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authSigningIn => 'Signing in...';

  @override
  String get authSignIn => 'Sign In';

  @override
  String get authSignInWithEmail => 'Sign in with email';

  @override
  String get validationEnterEmail => 'Enter your email.';

  @override
  String get validationValidEmail => 'Enter a valid email.';

  @override
  String get validationEnterPassword => 'Enter your password.';

  @override
  String get onboardingTitle => 'What language are\nyou learning?';

  @override
  String get onboardingSubtitle =>
      'We\'ll use this to show you the right content.';

  @override
  String get onboardingSearchHint => 'Search languages…';

  @override
  String get onboardingRetry => 'Retry';

  @override
  String get onboardingNoMatching => 'No matching languages.';

  @override
  String get onboardingFailedSave => 'Failed to save.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get sectionAppearance => 'Appearance';

  @override
  String get sectionAccount => 'Account';

  @override
  String get sectionLanguage => 'Language';

  @override
  String get languageSectionSubtitle =>
      'Choose app display language. System follows your device settings.';

  @override
  String get themeLabel => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChineseSimplified => 'Chinese (Simplified)';

  @override
  String get languageKorean => 'Korean';

  @override
  String get languageJapanese => 'Japanese';

  @override
  String get signedOutLabel => 'Signed out';

  @override
  String get noActiveSession => 'No active Bantera session';

  @override
  String signedInWith(String provider) {
    return 'Signed in with $provider';
  }

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get more => 'More';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signOutDialogTitle => 'Sign out?';

  @override
  String get signOutDialogBody =>
      'You will need to sign in again to use your account.';

  @override
  String get cancel => 'Cancel';

  @override
  String get navDiscover => 'Discover';

  @override
  String get navCreate => 'Create';

  @override
  String get navProfile => 'Profile';

  @override
  String get chatsTitle => 'Chats';

  @override
  String get savedTitle => 'Saved';

  @override
  String get generateWithAiTitle => 'Generate with AI';

  @override
  String get practiceLocalVideoTitle => 'Practice Local Video';

  @override
  String get uploadVideoTitle => 'Upload Video';

  @override
  String get lessonDetailsTitle => 'Lesson Details';

  @override
  String get accountMoreTitle => 'More';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountSubtitle =>
      'Permanently remove your account and server data';

  @override
  String get confirmDeletionTitle => 'Confirm deletion';

  @override
  String get deleteAccountImmediateBody =>
      'Your account will be deleted immediately. You will need to create a new account to use Bantera again.';

  @override
  String get deleteAccountConfirm => 'Delete account';

  @override
  String get couldNotDeleteAccount =>
      'Could not delete account. Please try again.';

  @override
  String get deleteAccountQuestionTitle => 'Delete account?';

  @override
  String get deleteAccountQuestionBody =>
      'All of your personal information and any data you\'ve generated will be permanently removed from our servers and can\'t be recovered.';

  @override
  String get typeDeleteLabel => 'Type \"DELETE\" to continue';

  @override
  String get continueLabel => 'Continue';

  @override
  String get confirmLabel => 'Confirm';

  @override
  String get deleteLabel => 'Delete';

  @override
  String get startLabel => 'Start';

  @override
  String get doneLabel => 'Done';

  @override
  String get discoverSearchHint => 'Search title or transcript…';

  @override
  String get discoverNoMoreResults => 'No more results';

  @override
  String get discoverSetLearningLanguagePrompt =>
      'Set your learning language to see content here';

  @override
  String discoverNoPublicContentInLanguage(String language) {
    return 'No public content in $language yet';
  }

  @override
  String get discoverSetLanguageToDiscover =>
      'Set a learning language to discover content';

  @override
  String get mediaStartPractice => 'Start Practice';

  @override
  String get mediaTranscript => 'Transcript';

  @override
  String mediaTranscriptLineCount(int count) {
    return '($count lines)';
  }

  @override
  String get mediaShow => 'Show';

  @override
  String get mediaHide => 'Hide';

  @override
  String get mediaNoTranscriptAvailable => 'No transcript available.';

  @override
  String get lessonSaveTooltip => 'Save';

  @override
  String get lessonUnsaveTooltip => 'Unsave';

  @override
  String get mediaKindAudio => 'Audio';

  @override
  String get mediaKindVideo => 'Video';

  @override
  String get practiceNoCues => 'No cues';

  @override
  String get practiceTranslating => 'Translating…';

  @override
  String get practiceShowTranscript => 'Show Transcript';

  @override
  String get practiceTranslate => 'Translate';

  @override
  String get practiceHideText => 'Hide Text';

  @override
  String get practiceStop => 'Stop';

  @override
  String get practicePlayAll => 'Play All';

  @override
  String get practiceCompare => 'Compare';

  @override
  String get practiceStartOver => 'Start Over';

  @override
  String get practiceTranscriptHidden => 'Transcript hidden';

  @override
  String get practiceListenCarefully => 'Listen carefully…';

  @override
  String get practiceTranslationUnavailableForCue =>
      'Translation unavailable for this cue right now.';

  @override
  String get practiceChooseTranslationLanguageTitle =>
      'Choose Translation Language';

  @override
  String get practiceChooseTranslationLanguageDescription =>
      'Bantera will translate listening practice into this language and save it to your profile for future sessions.';

  @override
  String get practiceChangeTranslationLanguageTitle =>
      'Change Translation Language';

  @override
  String get practiceChangeTranslationLanguageDescription =>
      'Choose the language Bantera should translate into. The new choice will be saved to your profile.';

  @override
  String get practiceConfirmTranslationLanguageTitle =>
      'Confirm Translation Language';

  @override
  String get practiceConfirmTranslationLanguageBody =>
      'Bantera will save this language to your profile and use it as the default translation language in future listening practice.';

  @override
  String get practiceCouldNotSaveTranslationLanguage =>
      'Bantera could not save your translation language.';

  @override
  String get practiceNoTranslationLanguagesFound =>
      'Bantera could not find any translation languages for this transcript.';

  @override
  String get practicePlayAllTitle => 'Play all';

  @override
  String get practicePlayAllDescription =>
      'Pause between cues for shadowing (repeat aloud without tapping):';

  @override
  String get practicePlayAllPauseNoneTitle => 'No extra pause (0 s)';

  @override
  String get practicePlayAllPauseNoneSubtitle =>
      'Play through the track continuously';

  @override
  String get practicePlayAllPauseOneSecond => '1 second';

  @override
  String get practicePlayAllPauseOneCueTitle => '1× cue length';

  @override
  String get practicePlayAllPauseOneCueSubtitle =>
      'Pause as long as the cue that just played';

  @override
  String get practicePlayAllPauseTwoCuesTitle => '2× cue length';

  @override
  String get practicePlayAllPauseTwoCuesSubtitle =>
      'Pause twice as long as the cue that just played';

  @override
  String get practiceSearchLanguagesHint => 'Search languages';

  @override
  String get practiceTranslationInstalled => 'Installed';

  @override
  String get practiceTranslationDownload => 'Download';

  @override
  String get practiceStartOverTitle => 'Start over?';

  @override
  String get practiceStartOverBody => 'Go back to the first cue?';

  @override
  String get practiceVideoOpenError =>
      'The selected video could not be opened for practice.';

  @override
  String practiceAudioError(String message) {
    return 'Audio error: $message';
  }

  @override
  String get compareRecordYourVersion => 'Record your version';

  @override
  String compareTranscriptionLanguage(String locale) {
    return 'Transcription language: $locale';
  }

  @override
  String get compareOpenIphoneSettings => 'Open iPhone Settings';

  @override
  String get comparePauseAttempt => 'Pause Attempt';

  @override
  String get comparePlayAttempt => 'Play Attempt';

  @override
  String get compareYourTranscribedAttempt => 'Your transcribed attempt';

  @override
  String get compareHighlightHint =>
      'Words that Bantera recognised differently are highlighted.';

  @override
  String get compareTryAgain => 'Try Again';

  @override
  String get compareDone => 'Done';

  @override
  String get compareStatusTranscribing =>
      'Transcribing your attempt on iPhone…';

  @override
  String get compareStatusRecording => 'Recording… Tap again to stop.';

  @override
  String get compareStatusSavedAttempt =>
      'Showing a saved attempt for this cue. You can replay it or try again.';

  @override
  String get compareStatusReplayOrRetry =>
      'You can replay this attempt or try the cue again.';

  @override
  String get compareStatusTapToRecord =>
      'Tap to start recording your version of this cue.';

  @override
  String get compareCouldNotStartRecording =>
      'Bantera could not start recording right now.';

  @override
  String get compareCouldNotAccessRecording =>
      'Bantera could not access the recorded audio.';

  @override
  String get compareNoTranscriptGenerated =>
      'No transcript could be generated for this attempt. Try again closer to the microphone.';

  @override
  String get compareRecentAttempts => 'Recent attempts';

  @override
  String get compareAttemptsFooterNote =>
      'Bantera keeps your attempts on this iPhone so you can review progress on the same cue.';

  @override
  String compareMatchedCount(int count) {
    return '$count matched';
  }

  @override
  String compareDifferentCount(int count) {
    return '$count different';
  }

  @override
  String compareMissingCount(int count) {
    return '$count missing';
  }

  @override
  String get compareMicrophoneDeniedPermanent =>
      'Microphone access is turned off for Bantera. Open iPhone Settings > Bantera > Microphone and enable it to record your own version.';

  @override
  String get compareMicrophoneDeniedRestricted =>
      'This iPhone is currently restricting microphone access for Bantera. Check Screen Time, device management, or system settings to enable it.';

  @override
  String get compareMicrophoneDeniedDefault =>
      'Microphone permission is required to record your own version. If you dismissed the prompt before, open iPhone Settings > Bantera > Microphone and enable it.';

  @override
  String get comparePlayAttemptTooltip => 'Play attempt';

  @override
  String get comparePauseAttemptTooltip => 'Pause attempt';

  @override
  String get createWhatToday => 'What would you like to do today?';

  @override
  String get createPracticeVideo => 'Practice Video';

  @override
  String get createYourMedia => 'Your Media';

  @override
  String get createTryAgain => 'Try Again';

  @override
  String get createUploadedVideosEmptyHint =>
      'Your uploaded videos will show up here so you can reopen them and practice cue by cue.';

  @override
  String get createUploadingTips => 'Uploading Tips';

  @override
  String get createUploadingTipsBody =>
      'Keep your audio under 3 minutes for the best engagement. Clear subtitles are generated automatically!';

  @override
  String get createOnThisIphone => 'On This iPhone';

  @override
  String get createLocalVideosEmptyHint =>
      'Videos you practice locally will be saved on this iPhone so you can reopen them later without retranscribing.';

  @override
  String get createOnDeviceBadge => 'On Device';

  @override
  String get createSignInToLoadVideos =>
      'Sign in again to load your uploaded videos.';

  @override
  String createVideoMetaCues(int count) {
    return '$count cues';
  }

  @override
  String get createPublicBadge => 'Public';

  @override
  String get createPrivateBadge => 'Private';

  @override
  String get createAiBadge => 'AI';

  @override
  String get createDeleteSavedVideoTitle => 'Delete Saved Video?';

  @override
  String createDeleteSavedVideoBody(String title) {
    return 'Bantera will remove \"$title\" from this iPhone and delete its saved transcript cues.';
  }

  @override
  String get createDeleteMediaTitle => 'Delete media?';

  @override
  String createDeleteMediaBody(String title) {
    return 'This will permanently delete \"$title\" and its transcript. This cannot be undone.';
  }
}
