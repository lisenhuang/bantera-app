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
  String get sectionRateAndShare => 'Rate & Share';

  @override
  String get sectionLanguage => 'Display Language';

  @override
  String get sectionPermissions => 'Permissions';

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
  String get appPermissionsTitle => 'App Permissions';

  @override
  String get appPermissionsSubtitle =>
      'Review access Bantera uses on this device.';

  @override
  String get permissionsIntro =>
      'Bantera uses these device settings for recording, speech comparison, and network access.';

  @override
  String get permissionsOpenSettings => 'Open iPhone Settings';

  @override
  String get permissionsRefresh => 'Refresh';

  @override
  String get permissionMicrophoneTitle => 'Microphone';

  @override
  String get permissionMicrophoneDescription =>
      'Record practice attempts and voice messages.';

  @override
  String get permissionSpeechTitle => 'Speech Recognition';

  @override
  String get permissionSpeechDescription =>
      'Transcribe practice recordings and uploaded audio.';

  @override
  String get permissionMobileDataTitle => 'Mobile Data';

  @override
  String get permissionMobileDataDescription =>
      'Use Bantera when this iPhone is not connected to Wi-Fi.';

  @override
  String get permissionStatusAllowed => 'Allowed';

  @override
  String get permissionStatusLimited => 'Limited';

  @override
  String get permissionStatusNotAllowed => 'Not Allowed';

  @override
  String get permissionStatusUnknown => 'Unknown';

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
  String get savedTitle => 'Saved Media';

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
      'All of your personal information and data will be permanently removed from our servers and can\'t be recovered.';

  @override
  String get typeDeleteLabel => 'Type \"DELETE\" to continue';

  @override
  String get continueLabel => 'Continue';

  @override
  String get confirmLabel => 'Confirm';

  @override
  String get deleteLabel => 'Delete';

  @override
  String get removeFromListLabel => 'Remove from list';

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
  String get practiceTextLabel => 'Text';

  @override
  String get practiceStop => 'Stop';

  @override
  String get practicePlayAll => 'Play All';

  @override
  String get practiceCompare => 'Compare';

  @override
  String get practiceRecord => 'Record';

  @override
  String get practiceStopRecording => 'Stop';

  @override
  String get practiceRecords => 'Records';

  @override
  String get practiceRecordsLocalOnlyFooter =>
      'Attempts are stored only on this device and are not uploaded.';

  @override
  String get practiceRecordsEmpty => 'No saved attempts for this cue yet.';

  @override
  String get practiceRecordingProcessError =>
      'Something went wrong while processing your recording.';

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
  String get practicePlayAllDescription => 'Pause between cues for shadowing:';

  @override
  String get practicePlayAllPauseZeroSeconds => '0 s';

  @override
  String get practicePlayAllPauseOneSecondLabel => '1 s';

  @override
  String get practicePlayAllPauseOneCuePlusOneSecond => '1 cue + 1 s';

  @override
  String get practicePlayAllPauseOneCuePlusTwoSeconds => '1 cue + 2 s';

  @override
  String get practicePlayAllTimesPerCueTitle => 'Times per cue';

  @override
  String get practicePlayAllTimesOnce => '1×';

  @override
  String get practicePlayAllTimesTwice => '2×';

  @override
  String get practicePlayAllTimesThrice => '3×';

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
  String get practiceNextFromLastTitle => 'Go to first cue?';

  @override
  String get practiceNextFromLastBody =>
      'You\'re on the last cue. Return to the first cue?';

  @override
  String get practiceGoToFirstCue => 'Go to first cue';

  @override
  String get practiceVideoOpenError =>
      'The selected video could not be opened for practice.';

  @override
  String get practiceAudioLoading => 'Loading audio…';

  @override
  String practiceAudioLoadingPercent(int percent) {
    return 'Loading audio $percent%';
  }

  @override
  String get practiceAudioError => 'Could not load audio. Please try again.';

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
  String get compareSpeechRecognitionDeniedPermanent =>
      'Speech Recognition access is turned off for Bantera. Open iPhone Settings > Bantera > Speech Recognition and enable it to compare your recording.';

  @override
  String get compareSpeechRecognitionDeniedRestricted =>
      'This iPhone is currently restricting Speech Recognition for Bantera. Check Screen Time, device management, or system settings to enable it.';

  @override
  String get compareSpeechRecognitionUnavailable =>
      'Speech Recognition is not available on this iPhone right now.';

  @override
  String get compareSpeechRecognitionUnsupportedLocale =>
      'Speech Recognition is not available for this practice language on this iPhone.';

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

  @override
  String get removeFromListTitle => 'Remove from list?';

  @override
  String get removeFromListBody =>
      'This will be removed from the list and cannot be undone.';

  @override
  String get editProfileChangeImage => 'Change Profile Image';

  @override
  String get editProfileUploading => 'Uploading…';

  @override
  String get editProfileNameLabel => 'Name';

  @override
  String get editProfileNameHint => 'How should Bantera show your name?';

  @override
  String get editProfileSaveNameButton => 'Save Name';

  @override
  String get editProfileSaving => 'Saving…';

  @override
  String get editProfileLanguagesSection => 'Languages';

  @override
  String get editProfileMyNativeLanguage => 'My Native Language';

  @override
  String get editProfileMyNativeLanguageSubtitle =>
      'Your native or first language';

  @override
  String get editProfileLearningLanguage => 'Learning Language';

  @override
  String get editProfileLearningLanguageSubtitle =>
      'The language you want to practice';

  @override
  String get editProfileImageUpdated => 'Profile image updated.';

  @override
  String get editProfileNameUpdated => 'Name updated.';

  @override
  String get editProfileEnterName => 'Enter a name.';

  @override
  String get editProfileNameMaxLength => 'Use 80 characters or fewer.';

  @override
  String get editProfileCouldNotLoadLanguages =>
      'Could not load language list.';

  @override
  String get languagePickerNone => 'None';

  @override
  String get languagePickerClearSelection => 'Clear selection';

  @override
  String get languagePickerNoMatchingLanguages => 'No languages found.';

  @override
  String get languagePickerMoreComingSoon => 'More languages coming soon';

  @override
  String get editProfileNativeLanguageCleared => 'Native language cleared.';

  @override
  String get editProfileLearningLanguageCleared => 'Learning language cleared.';

  @override
  String editProfileNativeLanguageSetTo(String language) {
    return 'Native language set to $language.';
  }

  @override
  String editProfileLearningLanguageSetTo(String language) {
    return 'Learning language set to $language.';
  }

  @override
  String get profileLanguageSettings => 'Language Settings';

  @override
  String get profileLearningLabel => 'Learning';

  @override
  String get profileNotSet => 'Not set';

  @override
  String get uploadedDetailYourAudio => 'Your Audio';

  @override
  String get uploadedDetailYourVideo => 'Your Video';

  @override
  String get uploadedDetailDeleteAudioTitle => 'Delete audio?';

  @override
  String get uploadedDetailDeleteAudioBody =>
      'This will permanently delete the audio and its transcript. This cannot be undone.';

  @override
  String get uploadedDetailDeleteVideoTitle => 'Delete video?';

  @override
  String get uploadedDetailDeleteVideoBody =>
      'This will permanently delete the video and its transcript. This cannot be undone.';

  @override
  String get uploadedDetailAiGenerated => 'AI Generated';

  @override
  String get uploadedDetailFileSize => 'File size';

  @override
  String get uploadedDetailResolution => 'Resolution';

  @override
  String get uploadedDetailResolutionUnknown => 'Unknown';

  @override
  String get uploadedDetailTranscribing => 'Transcribing…';

  @override
  String get uploadedDetailNoTranscriptCuesYet =>
      'No transcript cues are available yet.';

  @override
  String uploadedDetailMediaDescription(int count) {
    return 'Your uploaded practice clip with $count transcript cues.';
  }

  @override
  String get uploadedDetailTranscriptionFailedFallback =>
      'Transcription failed. Using estimated cues.';

  @override
  String get uploadedDetailTranscriptionNoCues =>
      'The transcription returned no cues.';

  @override
  String get uploadedDetailTranscriptionSourceYourUpload => 'Your Upload';

  @override
  String get aiGenLeaveTitle => 'Leave this page?';

  @override
  String get aiGenLeaveBody =>
      'Audio is still being generated. Leaving now will cancel the process.';

  @override
  String get aiGenStay => 'Stay';

  @override
  String get aiGenLeave => 'Leave';

  @override
  String get aiGenLoadingTitle => 'Creating your audio…';

  @override
  String get aiGenLoadingSubtitle =>
      'This may take up to a minute.\nPlease stay on this page while generating.';

  @override
  String get aiGenStepPreparingSpeechModel =>
      'Preparing on-device speech model';

  @override
  String get aiGenStepWritingDialogue => 'Writing dialogue';

  @override
  String get aiGenStepGeneratingAudio => 'Generating audio';

  @override
  String get aiGenStepAligningAudio => 'Aligning audio';

  @override
  String get aiGenStepTranscribing => 'Transcribing';

  @override
  String get aiGenStepCorrectingTranscript => 'Correcting transcript';

  @override
  String get aiGenLanguageSection => 'Language';

  @override
  String get aiGenSetLearningLanguagePrompt =>
      'Set your learning language to enable generation';

  @override
  String get aiGenLoadingLanguage => 'Loading language…';

  @override
  String aiGenLanguageUnsupported(String language) {
    return 'Language \"$language\" is not supported for generation.';
  }

  @override
  String get aiGenScenarioSection => 'Scenario';

  @override
  String get aiGenScenarioOptionalHint =>
      'Optional — leave unselected for a random scenario.';

  @override
  String get aiGenCustomScenarioHint => 'Describe your scenario…';

  @override
  String get aiGenDurationSection => 'Duration';

  @override
  String aiGenDurationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get aiGenGenerateButton => 'Generate';

  @override
  String get aiGenOwnershipNotice =>
      'Audio you generate here becomes Bantera community content — shared publicly as practice material for all learners.';

  @override
  String get aiGenOwnershipCheckbox =>
      'Share this audio as Bantera community content';

  @override
  String get aiGenOwnershipConfirmTitle => 'Share as community content?';

  @override
  String get aiGenOwnershipConfirmCancel => 'Cancel';

  @override
  String get aiGenOwnershipConfirmGenerate => 'Generate';

  @override
  String get aiGenFooterNotice =>
      'AI will write a two-speaker dialogue and synthesise it as audio. The result will be saved as a public practice audio.';

  @override
  String get aiScenarioCoffeeShop => 'Coffee shop';

  @override
  String get aiScenarioLatestNews => 'Latest News';

  @override
  String get aiScenarioAirportReunion => 'Airport reunion';

  @override
  String get aiScenarioGroceryStore => 'Grocery store';

  @override
  String get aiScenarioDoctorVisit => 'Doctor visit';

  @override
  String get aiScenarioJobInterview => 'Job interview';

  @override
  String get aiScenarioNewNeighbour => 'New neighbour';

  @override
  String get aiScenarioTechSupport => 'Tech support';

  @override
  String get aiScenarioBirthdaySurprise => 'Birthday surprise';

  @override
  String get aiScenarioGymTips => 'Gym tips';

  @override
  String get aiScenarioWeatherSmalltalk => 'Weather small talk';

  @override
  String get aiScenarioRestaurantOrder => 'Restaurant order';

  @override
  String get aiScenarioBookRecommendation => 'Book recommendation';

  @override
  String get aiScenarioBusDelay => 'Bus delay';

  @override
  String get aiScenarioMovieDebate => 'Movie debate';

  @override
  String get aiScenarioCustom => 'Custom…';

  @override
  String get errorNetworkUnreachable =>
      'Could not connect to Bantera. Check your internet connection.';

  @override
  String get errorNetworkCellularBlocked =>
      'Mobile data is turned off for Bantera. In Settings, open Bantera and turn on Mobile Data, or connect to Wi-Fi.';

  @override
  String get errorTlsConnection => 'Could not establish a secure connection.';

  @override
  String get settingsRateAppPrompt =>
      'Enjoying Bantera? A quick rating on the App Store means a lot to us.';

  @override
  String get settingsRateAppButton => 'Rate on the App Store';

  @override
  String get settingsSharePrompt =>
      'Know someone learning a language? Share Bantera with them.';

  @override
  String get settingsShareButton => 'Share Bantera';

  @override
  String get settingsContactButton => 'Contact us';

  @override
  String get localVideoDescription =>
      'Choose a video from Photos, pick the spoken language, then let iPhone transcribe it in the background before cue-by-cue practice.';

  @override
  String get localVideoStep1Title => '1. Choose video';

  @override
  String get localVideoChooseFromPhotos => 'Choose from Photos';

  @override
  String get localVideoChooseDifferent => 'Choose a Different Video';

  @override
  String get localVideoSelectedFileLabel => 'Selected file';

  @override
  String get localVideoSizeLabel => 'Size';

  @override
  String get localVideoDurationLabel => 'Duration';

  @override
  String get localVideoLongVideoWarning =>
      'This video is longer than 3 minutes, so Bantera may need longer to prepare the transcript and translation.';

  @override
  String get localVideoStep2Title => '2. Transcription language';

  @override
  String get localVideoChooseLanguagePlaceholder =>
      'Choose the spoken language';

  @override
  String get localVideoLanguageHint =>
      'Bantera remembers your last language choice and keeps transcription hidden by default once practice starts.';

  @override
  String get localVideoStep3Title => '3. Practice';

  @override
  String get localVideoPreparing => 'Preparing...';

  @override
  String get localVideoPracticeHint =>
      'Bantera transcribes on device first, then opens the cue-by-cue listening page without uploading anything.';

  @override
  String get localVideoStatusLongVideo =>
      'This is a longer video, so Bantera may need extra time to transcribe and prepare it.';

  @override
  String get localVideoStatusTranscribing =>
      'Transcribing on device and preparing practice cues...';

  @override
  String get localVideoStatusSaving =>
      'Saving this video to your on-device practice library...';

  @override
  String get localVideoStatusTranslationLong =>
      'Transcription finished. Bantera is also preparing translation for your saved language, so this longer video may take a bit more time.';

  @override
  String get localVideoStatusTranslation =>
      'Transcription finished. Preparing translation for your saved language...';

  @override
  String get localVideoPickerTitle => 'Choose Audio Language';

  @override
  String get savedCuesTitle => 'Saved Cues';

  @override
  String get savedCuesEmpty =>
      'No saved cues yet. Tap the bookmark icon while practicing to save a cue.';

  @override
  String get savedCuesDeleteTooltip => 'Remove saved cue';

  @override
  String get savedCuesDeleteConfirmTitle => 'Remove this cue?';

  @override
  String get savedCuesDeleteConfirmBody =>
      'This cue will be removed from your saved list.';

  @override
  String get savedCuesDeleteAllTooltip => 'Delete all saved cues';

  @override
  String get savedCuesDeleteAllConfirmTitle => 'Delete all saved cues?';

  @override
  String get savedCuesDeleteAllConfirmBody =>
      'All saved cues will be permanently removed.';

  @override
  String get updateAlertTitle => 'Update Available';

  @override
  String get updateAlertMessage =>
      'A new version of Bantera is available. Update now to get the latest features and improvements.';

  @override
  String get updateAlertUpdate => 'Update';

  @override
  String get updateAlertLater => 'Later';

  @override
  String get checkForUpdateButton => 'Check for Updates';

  @override
  String get upToDateAlertTitle => 'Up to Date';

  @override
  String upToDateAlertMessage(Object version) {
    return 'Bantera $version is the latest version.';
  }
}
