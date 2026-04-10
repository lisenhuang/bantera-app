import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
    Locale('zh', 'CN'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Bantera'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Language practice, cue by cue.'**
  String get appTagline;

  /// No description provided for @authContinueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get authContinueWithApple;

  /// No description provided for @authAppleUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple is unavailable on this device.'**
  String get authAppleUnavailable;

  /// No description provided for @authOrSignInEmail.
  ///
  /// In en, this message translates to:
  /// **'or sign in with email'**
  String get authOrSignInEmail;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authSigningIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get authSigningIn;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authSignIn;

  /// No description provided for @authSignInWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Sign in with email'**
  String get authSignInWithEmail;

  /// No description provided for @validationEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email.'**
  String get validationEnterEmail;

  /// No description provided for @validationValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email.'**
  String get validationValidEmail;

  /// No description provided for @validationEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get validationEnterPassword;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'What language are\nyou learning?'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll use this to show you the right content.'**
  String get onboardingSubtitle;

  /// No description provided for @onboardingSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search languages…'**
  String get onboardingSearchHint;

  /// No description provided for @onboardingRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get onboardingRetry;

  /// No description provided for @onboardingNoMatching.
  ///
  /// In en, this message translates to:
  /// **'No matching languages.'**
  String get onboardingNoMatching;

  /// No description provided for @onboardingFailedSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save.'**
  String get onboardingFailedSave;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @sectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get sectionAppearance;

  /// No description provided for @sectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get sectionAccount;

  /// No description provided for @sectionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get sectionLanguage;

  /// No description provided for @languageSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose app display language. System follows your device settings.'**
  String get languageSectionSubtitle;

  /// No description provided for @themeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeLabel;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageChineseSimplified.
  ///
  /// In en, this message translates to:
  /// **'Chinese (Simplified)'**
  String get languageChineseSimplified;

  /// No description provided for @languageKorean.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get languageKorean;

  /// No description provided for @languageJapanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get languageJapanese;

  /// No description provided for @signedOutLabel.
  ///
  /// In en, this message translates to:
  /// **'Signed out'**
  String get signedOutLabel;

  /// No description provided for @noActiveSession.
  ///
  /// In en, this message translates to:
  /// **'No active Bantera session'**
  String get noActiveSession;

  /// No description provided for @signedInWith.
  ///
  /// In en, this message translates to:
  /// **'Signed in with {provider}'**
  String signedInWith(String provider);

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signOutDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutDialogTitle;

  /// No description provided for @signOutDialogBody.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again to use your account.'**
  String get signOutDialogBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @navDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get navDiscover;

  /// No description provided for @navCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get navCreate;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @chatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chatsTitle;

  /// No description provided for @savedTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedTitle;

  /// No description provided for @generateWithAiTitle.
  ///
  /// In en, this message translates to:
  /// **'Generate with AI'**
  String get generateWithAiTitle;

  /// No description provided for @practiceLocalVideoTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice Local Video'**
  String get practiceLocalVideoTitle;

  /// No description provided for @uploadVideoTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload Video'**
  String get uploadVideoTitle;

  /// No description provided for @lessonDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Lesson Details'**
  String get lessonDetailsTitle;

  /// No description provided for @accountMoreTitle.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get accountMoreTitle;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently remove your account and server data'**
  String get deleteAccountSubtitle;

  /// No description provided for @confirmDeletionTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion'**
  String get confirmDeletionTitle;

  /// No description provided for @deleteAccountImmediateBody.
  ///
  /// In en, this message translates to:
  /// **'Your account will be deleted immediately. You will need to create a new account to use Bantera again.'**
  String get deleteAccountImmediateBody;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccountConfirm;

  /// No description provided for @couldNotDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Could not delete account. Please try again.'**
  String get couldNotDeleteAccount;

  /// No description provided for @deleteAccountQuestionTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get deleteAccountQuestionTitle;

  /// No description provided for @deleteAccountQuestionBody.
  ///
  /// In en, this message translates to:
  /// **'All of your personal information and any data you\'ve generated will be permanently removed from our servers and can\'t be recovered.'**
  String get deleteAccountQuestionBody;

  /// No description provided for @typeDeleteLabel.
  ///
  /// In en, this message translates to:
  /// **'Type \"DELETE\" to continue'**
  String get typeDeleteLabel;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @confirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmLabel;

  /// No description provided for @deleteLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteLabel;

  /// No description provided for @startLabel.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startLabel;

  /// No description provided for @doneLabel.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneLabel;

  /// No description provided for @discoverSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search title or transcript…'**
  String get discoverSearchHint;

  /// No description provided for @discoverNoMoreResults.
  ///
  /// In en, this message translates to:
  /// **'No more results'**
  String get discoverNoMoreResults;

  /// No description provided for @discoverSetLearningLanguagePrompt.
  ///
  /// In en, this message translates to:
  /// **'Set your learning language to see content here'**
  String get discoverSetLearningLanguagePrompt;

  /// No description provided for @discoverNoPublicContentInLanguage.
  ///
  /// In en, this message translates to:
  /// **'No public content in {language} yet'**
  String discoverNoPublicContentInLanguage(String language);

  /// No description provided for @discoverSetLanguageToDiscover.
  ///
  /// In en, this message translates to:
  /// **'Set a learning language to discover content'**
  String get discoverSetLanguageToDiscover;

  /// No description provided for @mediaStartPractice.
  ///
  /// In en, this message translates to:
  /// **'Start Practice'**
  String get mediaStartPractice;

  /// No description provided for @mediaTranscript.
  ///
  /// In en, this message translates to:
  /// **'Transcript'**
  String get mediaTranscript;

  /// No description provided for @mediaTranscriptLineCount.
  ///
  /// In en, this message translates to:
  /// **'({count} lines)'**
  String mediaTranscriptLineCount(int count);

  /// No description provided for @mediaShow.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get mediaShow;

  /// No description provided for @mediaHide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get mediaHide;

  /// No description provided for @mediaNoTranscriptAvailable.
  ///
  /// In en, this message translates to:
  /// **'No transcript available.'**
  String get mediaNoTranscriptAvailable;

  /// No description provided for @lessonSaveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get lessonSaveTooltip;

  /// No description provided for @lessonUnsaveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Unsave'**
  String get lessonUnsaveTooltip;

  /// No description provided for @mediaKindAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get mediaKindAudio;

  /// No description provided for @mediaKindVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get mediaKindVideo;

  /// No description provided for @practiceNoCues.
  ///
  /// In en, this message translates to:
  /// **'No cues'**
  String get practiceNoCues;

  /// No description provided for @practiceTranslating.
  ///
  /// In en, this message translates to:
  /// **'Translating…'**
  String get practiceTranslating;

  /// No description provided for @practiceShowTranscript.
  ///
  /// In en, this message translates to:
  /// **'Show Transcript'**
  String get practiceShowTranscript;

  /// No description provided for @practiceTranslate.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get practiceTranslate;

  /// No description provided for @practiceHideText.
  ///
  /// In en, this message translates to:
  /// **'Hide Text'**
  String get practiceHideText;

  /// No description provided for @practiceStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get practiceStop;

  /// No description provided for @practicePlayAll.
  ///
  /// In en, this message translates to:
  /// **'Play All'**
  String get practicePlayAll;

  /// No description provided for @practiceCompare.
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get practiceCompare;

  /// No description provided for @practiceStartOver.
  ///
  /// In en, this message translates to:
  /// **'Start Over'**
  String get practiceStartOver;

  /// No description provided for @practiceTranscriptHidden.
  ///
  /// In en, this message translates to:
  /// **'Transcript hidden'**
  String get practiceTranscriptHidden;

  /// No description provided for @practiceListenCarefully.
  ///
  /// In en, this message translates to:
  /// **'Listen carefully…'**
  String get practiceListenCarefully;

  /// No description provided for @practiceTranslationUnavailableForCue.
  ///
  /// In en, this message translates to:
  /// **'Translation unavailable for this cue right now.'**
  String get practiceTranslationUnavailableForCue;

  /// No description provided for @practiceChooseTranslationLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Translation Language'**
  String get practiceChooseTranslationLanguageTitle;

  /// No description provided for @practiceChooseTranslationLanguageDescription.
  ///
  /// In en, this message translates to:
  /// **'Bantera will translate listening practice into this language and save it to your profile for future sessions.'**
  String get practiceChooseTranslationLanguageDescription;

  /// No description provided for @practiceChangeTranslationLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Translation Language'**
  String get practiceChangeTranslationLanguageTitle;

  /// No description provided for @practiceChangeTranslationLanguageDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the language Bantera should translate into. The new choice will be saved to your profile.'**
  String get practiceChangeTranslationLanguageDescription;

  /// No description provided for @practiceConfirmTranslationLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Translation Language'**
  String get practiceConfirmTranslationLanguageTitle;

  /// No description provided for @practiceConfirmTranslationLanguageBody.
  ///
  /// In en, this message translates to:
  /// **'Bantera will save this language to your profile and use it as the default translation language in future listening practice.'**
  String get practiceConfirmTranslationLanguageBody;

  /// No description provided for @practiceCouldNotSaveTranslationLanguage.
  ///
  /// In en, this message translates to:
  /// **'Bantera could not save your translation language.'**
  String get practiceCouldNotSaveTranslationLanguage;

  /// No description provided for @practiceNoTranslationLanguagesFound.
  ///
  /// In en, this message translates to:
  /// **'Bantera could not find any translation languages for this transcript.'**
  String get practiceNoTranslationLanguagesFound;

  /// No description provided for @practicePlayAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Play all'**
  String get practicePlayAllTitle;

  /// No description provided for @practicePlayAllDescription.
  ///
  /// In en, this message translates to:
  /// **'Pause between cues for shadowing (repeat aloud without tapping):'**
  String get practicePlayAllDescription;

  /// No description provided for @practicePlayAllPauseNoneTitle.
  ///
  /// In en, this message translates to:
  /// **'No extra pause (0 s)'**
  String get practicePlayAllPauseNoneTitle;

  /// No description provided for @practicePlayAllPauseNoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Play through the track continuously'**
  String get practicePlayAllPauseNoneSubtitle;

  /// No description provided for @practicePlayAllPauseOneSecond.
  ///
  /// In en, this message translates to:
  /// **'1 second'**
  String get practicePlayAllPauseOneSecond;

  /// No description provided for @practicePlayAllPauseOneCueTitle.
  ///
  /// In en, this message translates to:
  /// **'1× cue length'**
  String get practicePlayAllPauseOneCueTitle;

  /// No description provided for @practicePlayAllPauseOneCueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pause as long as the cue that just played'**
  String get practicePlayAllPauseOneCueSubtitle;

  /// No description provided for @practicePlayAllPauseTwoCuesTitle.
  ///
  /// In en, this message translates to:
  /// **'2× cue length'**
  String get practicePlayAllPauseTwoCuesTitle;

  /// No description provided for @practicePlayAllPauseTwoCuesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pause twice as long as the cue that just played'**
  String get practicePlayAllPauseTwoCuesSubtitle;

  /// No description provided for @practiceSearchLanguagesHint.
  ///
  /// In en, this message translates to:
  /// **'Search languages'**
  String get practiceSearchLanguagesHint;

  /// No description provided for @practiceTranslationInstalled.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get practiceTranslationInstalled;

  /// No description provided for @practiceTranslationDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get practiceTranslationDownload;

  /// No description provided for @practiceStartOverTitle.
  ///
  /// In en, this message translates to:
  /// **'Start over?'**
  String get practiceStartOverTitle;

  /// No description provided for @practiceStartOverBody.
  ///
  /// In en, this message translates to:
  /// **'Go back to the first cue?'**
  String get practiceStartOverBody;

  /// No description provided for @practiceVideoOpenError.
  ///
  /// In en, this message translates to:
  /// **'The selected video could not be opened for practice.'**
  String get practiceVideoOpenError;

  /// No description provided for @practiceAudioError.
  ///
  /// In en, this message translates to:
  /// **'Audio error: {message}'**
  String practiceAudioError(String message);

  /// No description provided for @compareRecordYourVersion.
  ///
  /// In en, this message translates to:
  /// **'Record your version'**
  String get compareRecordYourVersion;

  /// No description provided for @compareTranscriptionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Transcription language: {locale}'**
  String compareTranscriptionLanguage(String locale);

  /// No description provided for @compareOpenIphoneSettings.
  ///
  /// In en, this message translates to:
  /// **'Open iPhone Settings'**
  String get compareOpenIphoneSettings;

  /// No description provided for @comparePauseAttempt.
  ///
  /// In en, this message translates to:
  /// **'Pause Attempt'**
  String get comparePauseAttempt;

  /// No description provided for @comparePlayAttempt.
  ///
  /// In en, this message translates to:
  /// **'Play Attempt'**
  String get comparePlayAttempt;

  /// No description provided for @compareYourTranscribedAttempt.
  ///
  /// In en, this message translates to:
  /// **'Your transcribed attempt'**
  String get compareYourTranscribedAttempt;

  /// No description provided for @compareHighlightHint.
  ///
  /// In en, this message translates to:
  /// **'Words that Bantera recognised differently are highlighted.'**
  String get compareHighlightHint;

  /// No description provided for @compareTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get compareTryAgain;

  /// No description provided for @compareDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get compareDone;

  /// No description provided for @compareStatusTranscribing.
  ///
  /// In en, this message translates to:
  /// **'Transcribing your attempt on iPhone…'**
  String get compareStatusTranscribing;

  /// No description provided for @compareStatusRecording.
  ///
  /// In en, this message translates to:
  /// **'Recording… Tap again to stop.'**
  String get compareStatusRecording;

  /// No description provided for @compareStatusSavedAttempt.
  ///
  /// In en, this message translates to:
  /// **'Showing a saved attempt for this cue. You can replay it or try again.'**
  String get compareStatusSavedAttempt;

  /// No description provided for @compareStatusReplayOrRetry.
  ///
  /// In en, this message translates to:
  /// **'You can replay this attempt or try the cue again.'**
  String get compareStatusReplayOrRetry;

  /// No description provided for @compareStatusTapToRecord.
  ///
  /// In en, this message translates to:
  /// **'Tap to start recording your version of this cue.'**
  String get compareStatusTapToRecord;

  /// No description provided for @compareCouldNotStartRecording.
  ///
  /// In en, this message translates to:
  /// **'Bantera could not start recording right now.'**
  String get compareCouldNotStartRecording;

  /// No description provided for @compareCouldNotAccessRecording.
  ///
  /// In en, this message translates to:
  /// **'Bantera could not access the recorded audio.'**
  String get compareCouldNotAccessRecording;

  /// No description provided for @compareNoTranscriptGenerated.
  ///
  /// In en, this message translates to:
  /// **'No transcript could be generated for this attempt. Try again closer to the microphone.'**
  String get compareNoTranscriptGenerated;

  /// No description provided for @compareRecentAttempts.
  ///
  /// In en, this message translates to:
  /// **'Recent attempts'**
  String get compareRecentAttempts;

  /// No description provided for @compareAttemptsFooterNote.
  ///
  /// In en, this message translates to:
  /// **'Bantera keeps your attempts on this iPhone so you can review progress on the same cue.'**
  String get compareAttemptsFooterNote;

  /// No description provided for @compareMatchedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} matched'**
  String compareMatchedCount(int count);

  /// No description provided for @compareDifferentCount.
  ///
  /// In en, this message translates to:
  /// **'{count} different'**
  String compareDifferentCount(int count);

  /// No description provided for @compareMissingCount.
  ///
  /// In en, this message translates to:
  /// **'{count} missing'**
  String compareMissingCount(int count);

  /// No description provided for @compareMicrophoneDeniedPermanent.
  ///
  /// In en, this message translates to:
  /// **'Microphone access is turned off for Bantera. Open iPhone Settings > Bantera > Microphone and enable it to record your own version.'**
  String get compareMicrophoneDeniedPermanent;

  /// No description provided for @compareMicrophoneDeniedRestricted.
  ///
  /// In en, this message translates to:
  /// **'This iPhone is currently restricting microphone access for Bantera. Check Screen Time, device management, or system settings to enable it.'**
  String get compareMicrophoneDeniedRestricted;

  /// No description provided for @compareMicrophoneDeniedDefault.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required to record your own version. If you dismissed the prompt before, open iPhone Settings > Bantera > Microphone and enable it.'**
  String get compareMicrophoneDeniedDefault;

  /// No description provided for @comparePlayAttemptTooltip.
  ///
  /// In en, this message translates to:
  /// **'Play attempt'**
  String get comparePlayAttemptTooltip;

  /// No description provided for @comparePauseAttemptTooltip.
  ///
  /// In en, this message translates to:
  /// **'Pause attempt'**
  String get comparePauseAttemptTooltip;

  /// No description provided for @createWhatToday.
  ///
  /// In en, this message translates to:
  /// **'What would you like to do today?'**
  String get createWhatToday;

  /// No description provided for @createPracticeVideo.
  ///
  /// In en, this message translates to:
  /// **'Practice Video'**
  String get createPracticeVideo;

  /// No description provided for @createYourMedia.
  ///
  /// In en, this message translates to:
  /// **'Your Media'**
  String get createYourMedia;

  /// No description provided for @createTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get createTryAgain;

  /// No description provided for @createUploadedVideosEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Your uploaded videos will show up here so you can reopen them and practice cue by cue.'**
  String get createUploadedVideosEmptyHint;

  /// No description provided for @createUploadingTips.
  ///
  /// In en, this message translates to:
  /// **'Uploading Tips'**
  String get createUploadingTips;

  /// No description provided for @createUploadingTipsBody.
  ///
  /// In en, this message translates to:
  /// **'Keep your audio under 3 minutes for the best engagement. Clear subtitles are generated automatically!'**
  String get createUploadingTipsBody;

  /// No description provided for @createOnThisIphone.
  ///
  /// In en, this message translates to:
  /// **'On This iPhone'**
  String get createOnThisIphone;

  /// No description provided for @createLocalVideosEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Videos you practice locally will be saved on this iPhone so you can reopen them later without retranscribing.'**
  String get createLocalVideosEmptyHint;

  /// No description provided for @createOnDeviceBadge.
  ///
  /// In en, this message translates to:
  /// **'On Device'**
  String get createOnDeviceBadge;

  /// No description provided for @createSignInToLoadVideos.
  ///
  /// In en, this message translates to:
  /// **'Sign in again to load your uploaded videos.'**
  String get createSignInToLoadVideos;

  /// No description provided for @createVideoMetaCues.
  ///
  /// In en, this message translates to:
  /// **'{count} cues'**
  String createVideoMetaCues(int count);

  /// No description provided for @createPublicBadge.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get createPublicBadge;

  /// No description provided for @createPrivateBadge.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get createPrivateBadge;

  /// No description provided for @createAiBadge.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get createAiBadge;

  /// No description provided for @createDeleteSavedVideoTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Saved Video?'**
  String get createDeleteSavedVideoTitle;

  /// No description provided for @createDeleteSavedVideoBody.
  ///
  /// In en, this message translates to:
  /// **'Bantera will remove \"{title}\" from this iPhone and delete its saved transcript cues.'**
  String createDeleteSavedVideoBody(String title);

  /// No description provided for @createDeleteMediaTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete media?'**
  String get createDeleteMediaTitle;

  /// No description provided for @createDeleteMediaBody.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete \"{title}\" and its transcript. This cannot be undone.'**
  String createDeleteMediaBody(String title);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'CN':
            return AppLocalizationsZhCn();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
