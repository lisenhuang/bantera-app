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

  /// No description provided for @sectionRateAndShare.
  ///
  /// In en, this message translates to:
  /// **'Rate & Share'**
  String get sectionRateAndShare;

  /// No description provided for @sectionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Display Language'**
  String get sectionLanguage;

  /// No description provided for @sectionPermissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get sectionPermissions;

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

  /// No description provided for @appPermissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'App Permissions'**
  String get appPermissionsTitle;

  /// No description provided for @appPermissionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review access Bantera uses on this device.'**
  String get appPermissionsSubtitle;

  /// No description provided for @permissionsIntro.
  ///
  /// In en, this message translates to:
  /// **'Bantera uses these device settings for recording, speech comparison, and network access.'**
  String get permissionsIntro;

  /// No description provided for @permissionsOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open iPhone Settings'**
  String get permissionsOpenSettings;

  /// No description provided for @permissionsRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get permissionsRefresh;

  /// No description provided for @permissionMicrophoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get permissionMicrophoneTitle;

  /// No description provided for @permissionMicrophoneDescription.
  ///
  /// In en, this message translates to:
  /// **'Record practice attempts and voice messages.'**
  String get permissionMicrophoneDescription;

  /// No description provided for @permissionSpeechTitle.
  ///
  /// In en, this message translates to:
  /// **'Speech Recognition'**
  String get permissionSpeechTitle;

  /// No description provided for @permissionSpeechDescription.
  ///
  /// In en, this message translates to:
  /// **'Transcribe practice recordings and uploaded audio.'**
  String get permissionSpeechDescription;

  /// No description provided for @permissionMobileDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Mobile Data'**
  String get permissionMobileDataTitle;

  /// No description provided for @permissionMobileDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Use Bantera when this iPhone is not connected to Wi-Fi.'**
  String get permissionMobileDataDescription;

  /// No description provided for @permissionStatusAllowed.
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get permissionStatusAllowed;

  /// No description provided for @permissionStatusLimited.
  ///
  /// In en, this message translates to:
  /// **'Limited'**
  String get permissionStatusLimited;

  /// No description provided for @permissionStatusNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Not Allowed'**
  String get permissionStatusNotAllowed;

  /// No description provided for @permissionStatusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get permissionStatusUnknown;

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
  /// **'Saved Media'**
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
  /// **'All of your personal information and data will be permanently removed from our servers and can\'t be recovered.'**
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

  /// No description provided for @removeFromListLabel.
  ///
  /// In en, this message translates to:
  /// **'Remove from list'**
  String get removeFromListLabel;

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

  /// No description provided for @practiceTextLabel.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get practiceTextLabel;

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

  /// No description provided for @practiceRecord.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get practiceRecord;

  /// No description provided for @practiceStopRecording.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get practiceStopRecording;

  /// No description provided for @practiceRecords.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get practiceRecords;

  /// No description provided for @practiceRecordsLocalOnlyFooter.
  ///
  /// In en, this message translates to:
  /// **'Attempts are stored only on this device and are not uploaded.'**
  String get practiceRecordsLocalOnlyFooter;

  /// No description provided for @practiceRecordsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No saved attempts for this cue yet.'**
  String get practiceRecordsEmpty;

  /// No description provided for @practiceRecordingProcessError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while processing your recording.'**
  String get practiceRecordingProcessError;

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
  /// **'Pause between cues for shadowing:'**
  String get practicePlayAllDescription;

  /// No description provided for @practicePlayAllPauseZeroSeconds.
  ///
  /// In en, this message translates to:
  /// **'0 s'**
  String get practicePlayAllPauseZeroSeconds;

  /// No description provided for @practicePlayAllPauseOneSecondLabel.
  ///
  /// In en, this message translates to:
  /// **'1 s'**
  String get practicePlayAllPauseOneSecondLabel;

  /// No description provided for @practicePlayAllPauseOneCuePlusOneSecond.
  ///
  /// In en, this message translates to:
  /// **'1 cue + 1 s'**
  String get practicePlayAllPauseOneCuePlusOneSecond;

  /// No description provided for @practicePlayAllPauseOneCuePlusTwoSeconds.
  ///
  /// In en, this message translates to:
  /// **'1 cue + 2 s'**
  String get practicePlayAllPauseOneCuePlusTwoSeconds;

  /// No description provided for @practicePlayAllTimesPerCueTitle.
  ///
  /// In en, this message translates to:
  /// **'Times per cue'**
  String get practicePlayAllTimesPerCueTitle;

  /// No description provided for @practicePlayAllTimesOnce.
  ///
  /// In en, this message translates to:
  /// **'1×'**
  String get practicePlayAllTimesOnce;

  /// No description provided for @practicePlayAllTimesTwice.
  ///
  /// In en, this message translates to:
  /// **'2×'**
  String get practicePlayAllTimesTwice;

  /// No description provided for @practicePlayAllTimesThrice.
  ///
  /// In en, this message translates to:
  /// **'3×'**
  String get practicePlayAllTimesThrice;

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

  /// No description provided for @practiceNextFromLastTitle.
  ///
  /// In en, this message translates to:
  /// **'Go to first cue?'**
  String get practiceNextFromLastTitle;

  /// No description provided for @practiceNextFromLastBody.
  ///
  /// In en, this message translates to:
  /// **'You\'re on the last cue. Return to the first cue?'**
  String get practiceNextFromLastBody;

  /// No description provided for @practiceGoToFirstCue.
  ///
  /// In en, this message translates to:
  /// **'Go to first cue'**
  String get practiceGoToFirstCue;

  /// No description provided for @practiceVideoOpenError.
  ///
  /// In en, this message translates to:
  /// **'The selected video could not be opened for practice.'**
  String get practiceVideoOpenError;

  /// No description provided for @practiceAudioLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading audio…'**
  String get practiceAudioLoading;

  /// No description provided for @practiceAudioLoadingPercent.
  ///
  /// In en, this message translates to:
  /// **'Loading audio {percent}%'**
  String practiceAudioLoadingPercent(int percent);

  /// No description provided for @practiceAudioError.
  ///
  /// In en, this message translates to:
  /// **'Could not load audio. Please try again.'**
  String get practiceAudioError;

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

  /// No description provided for @compareSpeechRecognitionDeniedPermanent.
  ///
  /// In en, this message translates to:
  /// **'Speech Recognition access is turned off for Bantera. Open iPhone Settings > Bantera > Speech Recognition and enable it to compare your recording.'**
  String get compareSpeechRecognitionDeniedPermanent;

  /// No description provided for @compareSpeechRecognitionDeniedRestricted.
  ///
  /// In en, this message translates to:
  /// **'This iPhone is currently restricting Speech Recognition for Bantera. Check Screen Time, device management, or system settings to enable it.'**
  String get compareSpeechRecognitionDeniedRestricted;

  /// No description provided for @compareSpeechRecognitionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Speech Recognition is not available on this iPhone right now.'**
  String get compareSpeechRecognitionUnavailable;

  /// No description provided for @compareSpeechRecognitionUnsupportedLocale.
  ///
  /// In en, this message translates to:
  /// **'Speech Recognition is not available for this practice language on this iPhone.'**
  String get compareSpeechRecognitionUnsupportedLocale;

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

  /// No description provided for @removeFromListTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove from list?'**
  String get removeFromListTitle;

  /// No description provided for @removeFromListBody.
  ///
  /// In en, this message translates to:
  /// **'This will be removed from the list and cannot be undone.'**
  String get removeFromListBody;

  /// No description provided for @editProfileChangeImage.
  ///
  /// In en, this message translates to:
  /// **'Change Profile Image'**
  String get editProfileChangeImage;

  /// No description provided for @editProfileUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading…'**
  String get editProfileUploading;

  /// No description provided for @editProfileNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get editProfileNameLabel;

  /// No description provided for @editProfileNameHint.
  ///
  /// In en, this message translates to:
  /// **'How should Bantera show your name?'**
  String get editProfileNameHint;

  /// No description provided for @editProfileSaveNameButton.
  ///
  /// In en, this message translates to:
  /// **'Save Name'**
  String get editProfileSaveNameButton;

  /// No description provided for @editProfileSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get editProfileSaving;

  /// No description provided for @editProfileLanguagesSection.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get editProfileLanguagesSection;

  /// No description provided for @editProfileMyNativeLanguage.
  ///
  /// In en, this message translates to:
  /// **'My Native Language'**
  String get editProfileMyNativeLanguage;

  /// No description provided for @editProfileMyNativeLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your native or first language'**
  String get editProfileMyNativeLanguageSubtitle;

  /// No description provided for @editProfileLearningLanguage.
  ///
  /// In en, this message translates to:
  /// **'Learning Language'**
  String get editProfileLearningLanguage;

  /// No description provided for @editProfileLearningLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The language you want to practice'**
  String get editProfileLearningLanguageSubtitle;

  /// No description provided for @editProfileImageUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile image updated.'**
  String get editProfileImageUpdated;

  /// No description provided for @editProfileNameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Name updated.'**
  String get editProfileNameUpdated;

  /// No description provided for @editProfileEnterName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name.'**
  String get editProfileEnterName;

  /// No description provided for @editProfileNameMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Use 80 characters or fewer.'**
  String get editProfileNameMaxLength;

  /// No description provided for @editProfileCouldNotLoadLanguages.
  ///
  /// In en, this message translates to:
  /// **'Could not load language list.'**
  String get editProfileCouldNotLoadLanguages;

  /// No description provided for @languagePickerNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get languagePickerNone;

  /// No description provided for @languagePickerClearSelection.
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get languagePickerClearSelection;

  /// No description provided for @languagePickerNoMatchingLanguages.
  ///
  /// In en, this message translates to:
  /// **'No languages found.'**
  String get languagePickerNoMatchingLanguages;

  /// No description provided for @languagePickerMoreComingSoon.
  ///
  /// In en, this message translates to:
  /// **'More languages coming soon'**
  String get languagePickerMoreComingSoon;

  /// No description provided for @editProfileNativeLanguageCleared.
  ///
  /// In en, this message translates to:
  /// **'Native language cleared.'**
  String get editProfileNativeLanguageCleared;

  /// No description provided for @editProfileLearningLanguageCleared.
  ///
  /// In en, this message translates to:
  /// **'Learning language cleared.'**
  String get editProfileLearningLanguageCleared;

  /// No description provided for @editProfileNativeLanguageSetTo.
  ///
  /// In en, this message translates to:
  /// **'Native language set to {language}.'**
  String editProfileNativeLanguageSetTo(String language);

  /// No description provided for @editProfileLearningLanguageSetTo.
  ///
  /// In en, this message translates to:
  /// **'Learning language set to {language}.'**
  String editProfileLearningLanguageSetTo(String language);

  /// No description provided for @profileLanguageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get profileLanguageSettings;

  /// No description provided for @profileLearningLabel.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get profileLearningLabel;

  /// No description provided for @profileNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get profileNotSet;

  /// No description provided for @uploadedDetailYourAudio.
  ///
  /// In en, this message translates to:
  /// **'Your Audio'**
  String get uploadedDetailYourAudio;

  /// No description provided for @uploadedDetailYourVideo.
  ///
  /// In en, this message translates to:
  /// **'Your Video'**
  String get uploadedDetailYourVideo;

  /// No description provided for @uploadedDetailDeleteAudioTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete audio?'**
  String get uploadedDetailDeleteAudioTitle;

  /// No description provided for @uploadedDetailDeleteAudioBody.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete the audio and its transcript. This cannot be undone.'**
  String get uploadedDetailDeleteAudioBody;

  /// No description provided for @uploadedDetailDeleteVideoTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete video?'**
  String get uploadedDetailDeleteVideoTitle;

  /// No description provided for @uploadedDetailDeleteVideoBody.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete the video and its transcript. This cannot be undone.'**
  String get uploadedDetailDeleteVideoBody;

  /// No description provided for @uploadedDetailAiGenerated.
  ///
  /// In en, this message translates to:
  /// **'AI Generated'**
  String get uploadedDetailAiGenerated;

  /// No description provided for @uploadedDetailFileSize.
  ///
  /// In en, this message translates to:
  /// **'File size'**
  String get uploadedDetailFileSize;

  /// No description provided for @uploadedDetailResolution.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get uploadedDetailResolution;

  /// No description provided for @uploadedDetailResolutionUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get uploadedDetailResolutionUnknown;

  /// No description provided for @uploadedDetailTranscribing.
  ///
  /// In en, this message translates to:
  /// **'Transcribing…'**
  String get uploadedDetailTranscribing;

  /// No description provided for @uploadedDetailNoTranscriptCuesYet.
  ///
  /// In en, this message translates to:
  /// **'No transcript cues are available yet.'**
  String get uploadedDetailNoTranscriptCuesYet;

  /// No description provided for @uploadedDetailMediaDescription.
  ///
  /// In en, this message translates to:
  /// **'Your uploaded practice clip with {count} transcript cues.'**
  String uploadedDetailMediaDescription(int count);

  /// No description provided for @uploadedDetailTranscriptionFailedFallback.
  ///
  /// In en, this message translates to:
  /// **'Transcription failed. Using estimated cues.'**
  String get uploadedDetailTranscriptionFailedFallback;

  /// No description provided for @uploadedDetailTranscriptionNoCues.
  ///
  /// In en, this message translates to:
  /// **'The transcription returned no cues.'**
  String get uploadedDetailTranscriptionNoCues;

  /// No description provided for @uploadedDetailTranscriptionSourceYourUpload.
  ///
  /// In en, this message translates to:
  /// **'Your Upload'**
  String get uploadedDetailTranscriptionSourceYourUpload;

  /// No description provided for @aiGenLeaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave this page?'**
  String get aiGenLeaveTitle;

  /// No description provided for @aiGenLeaveBody.
  ///
  /// In en, this message translates to:
  /// **'Audio is still being generated. Leaving now will cancel the process.'**
  String get aiGenLeaveBody;

  /// No description provided for @aiGenStay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get aiGenStay;

  /// No description provided for @aiGenLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get aiGenLeave;

  /// No description provided for @aiGenLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Creating your audio…'**
  String get aiGenLoadingTitle;

  /// No description provided for @aiGenLoadingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This may take up to a minute.\nPlease stay on this page while generating.'**
  String get aiGenLoadingSubtitle;

  /// No description provided for @aiGenStepPreparingSpeechModel.
  ///
  /// In en, this message translates to:
  /// **'Preparing on-device speech model'**
  String get aiGenStepPreparingSpeechModel;

  /// No description provided for @aiGenStepWritingDialogue.
  ///
  /// In en, this message translates to:
  /// **'Writing dialogue'**
  String get aiGenStepWritingDialogue;

  /// No description provided for @aiGenStepGeneratingAudio.
  ///
  /// In en, this message translates to:
  /// **'Generating audio'**
  String get aiGenStepGeneratingAudio;

  /// No description provided for @aiGenStepAligningAudio.
  ///
  /// In en, this message translates to:
  /// **'Aligning audio'**
  String get aiGenStepAligningAudio;

  /// No description provided for @aiGenStepTranscribing.
  ///
  /// In en, this message translates to:
  /// **'Transcribing'**
  String get aiGenStepTranscribing;

  /// No description provided for @aiGenStepCorrectingTranscript.
  ///
  /// In en, this message translates to:
  /// **'Correcting transcript'**
  String get aiGenStepCorrectingTranscript;

  /// No description provided for @aiGenLanguageSection.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get aiGenLanguageSection;

  /// No description provided for @aiGenSetLearningLanguagePrompt.
  ///
  /// In en, this message translates to:
  /// **'Set your learning language to enable generation'**
  String get aiGenSetLearningLanguagePrompt;

  /// No description provided for @aiGenLoadingLanguage.
  ///
  /// In en, this message translates to:
  /// **'Loading language…'**
  String get aiGenLoadingLanguage;

  /// No description provided for @aiGenLanguageUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Language \"{language}\" is not supported for generation.'**
  String aiGenLanguageUnsupported(String language);

  /// No description provided for @aiGenScenarioSection.
  ///
  /// In en, this message translates to:
  /// **'Scenario'**
  String get aiGenScenarioSection;

  /// No description provided for @aiGenScenarioOptionalHint.
  ///
  /// In en, this message translates to:
  /// **'Optional — leave unselected for a random scenario.'**
  String get aiGenScenarioOptionalHint;

  /// No description provided for @aiGenCustomScenarioHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your scenario…'**
  String get aiGenCustomScenarioHint;

  /// No description provided for @aiGenDurationSection.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get aiGenDurationSection;

  /// No description provided for @aiGenDurationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String aiGenDurationMinutes(int minutes);

  /// No description provided for @aiGenGenerateButton.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get aiGenGenerateButton;

  /// No description provided for @aiGenOwnershipNotice.
  ///
  /// In en, this message translates to:
  /// **'Audio generated here is created by Bantera AI. All generated content is owned by Bantera and shared as public practice material — it is not associated with your personal account.'**
  String get aiGenOwnershipNotice;

  /// No description provided for @aiGenOwnershipCheckbox.
  ///
  /// In en, this message translates to:
  /// **'I understand this audio belongs to Bantera, not me'**
  String get aiGenOwnershipCheckbox;

  /// No description provided for @aiGenOwnershipConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Generate as Bantera content?'**
  String get aiGenOwnershipConfirmTitle;

  /// No description provided for @aiGenOwnershipConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This audio will be owned by Bantera and shared publicly. It won\'t appear as your personal content. Do you want to continue?'**
  String get aiGenOwnershipConfirmBody;

  /// No description provided for @aiGenOwnershipConfirmCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get aiGenOwnershipConfirmCancel;

  /// No description provided for @aiGenOwnershipConfirmGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get aiGenOwnershipConfirmGenerate;

  /// No description provided for @aiGenFooterNotice.
  ///
  /// In en, this message translates to:
  /// **'AI will write a two-speaker dialogue and synthesise it as audio. The result will be saved as a public practice audio.'**
  String get aiGenFooterNotice;

  /// No description provided for @aiScenarioCoffeeShop.
  ///
  /// In en, this message translates to:
  /// **'Coffee shop'**
  String get aiScenarioCoffeeShop;

  /// No description provided for @aiScenarioLatestNews.
  ///
  /// In en, this message translates to:
  /// **'Latest News'**
  String get aiScenarioLatestNews;

  /// No description provided for @aiScenarioAirportReunion.
  ///
  /// In en, this message translates to:
  /// **'Airport reunion'**
  String get aiScenarioAirportReunion;

  /// No description provided for @aiScenarioGroceryStore.
  ///
  /// In en, this message translates to:
  /// **'Grocery store'**
  String get aiScenarioGroceryStore;

  /// No description provided for @aiScenarioDoctorVisit.
  ///
  /// In en, this message translates to:
  /// **'Doctor visit'**
  String get aiScenarioDoctorVisit;

  /// No description provided for @aiScenarioJobInterview.
  ///
  /// In en, this message translates to:
  /// **'Job interview'**
  String get aiScenarioJobInterview;

  /// No description provided for @aiScenarioNewNeighbour.
  ///
  /// In en, this message translates to:
  /// **'New neighbour'**
  String get aiScenarioNewNeighbour;

  /// No description provided for @aiScenarioTechSupport.
  ///
  /// In en, this message translates to:
  /// **'Tech support'**
  String get aiScenarioTechSupport;

  /// No description provided for @aiScenarioBirthdaySurprise.
  ///
  /// In en, this message translates to:
  /// **'Birthday surprise'**
  String get aiScenarioBirthdaySurprise;

  /// No description provided for @aiScenarioGymTips.
  ///
  /// In en, this message translates to:
  /// **'Gym tips'**
  String get aiScenarioGymTips;

  /// No description provided for @aiScenarioWeatherSmalltalk.
  ///
  /// In en, this message translates to:
  /// **'Weather small talk'**
  String get aiScenarioWeatherSmalltalk;

  /// No description provided for @aiScenarioRestaurantOrder.
  ///
  /// In en, this message translates to:
  /// **'Restaurant order'**
  String get aiScenarioRestaurantOrder;

  /// No description provided for @aiScenarioBookRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Book recommendation'**
  String get aiScenarioBookRecommendation;

  /// No description provided for @aiScenarioBusDelay.
  ///
  /// In en, this message translates to:
  /// **'Bus delay'**
  String get aiScenarioBusDelay;

  /// No description provided for @aiScenarioMovieDebate.
  ///
  /// In en, this message translates to:
  /// **'Movie debate'**
  String get aiScenarioMovieDebate;

  /// No description provided for @aiScenarioCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom…'**
  String get aiScenarioCustom;

  /// No description provided for @errorNetworkUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to Bantera. Check your internet connection.'**
  String get errorNetworkUnreachable;

  /// No description provided for @errorNetworkCellularBlocked.
  ///
  /// In en, this message translates to:
  /// **'Mobile data is turned off for Bantera. In Settings, open Bantera and turn on Mobile Data, or connect to Wi-Fi.'**
  String get errorNetworkCellularBlocked;

  /// No description provided for @errorTlsConnection.
  ///
  /// In en, this message translates to:
  /// **'Could not establish a secure connection.'**
  String get errorTlsConnection;

  /// No description provided for @settingsRateAppPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enjoying Bantera? A quick rating on the App Store means a lot to us.'**
  String get settingsRateAppPrompt;

  /// No description provided for @settingsRateAppButton.
  ///
  /// In en, this message translates to:
  /// **'Rate on the App Store'**
  String get settingsRateAppButton;

  /// No description provided for @settingsSharePrompt.
  ///
  /// In en, this message translates to:
  /// **'Know someone learning a language? Share Bantera with them.'**
  String get settingsSharePrompt;

  /// No description provided for @settingsShareButton.
  ///
  /// In en, this message translates to:
  /// **'Share Bantera'**
  String get settingsShareButton;

  /// No description provided for @settingsContactButton.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get settingsContactButton;

  /// No description provided for @localVideoDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose a video from Photos, pick the spoken language, then let iPhone transcribe it in the background before cue-by-cue practice.'**
  String get localVideoDescription;

  /// No description provided for @localVideoStep1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Choose video'**
  String get localVideoStep1Title;

  /// No description provided for @localVideoChooseFromPhotos.
  ///
  /// In en, this message translates to:
  /// **'Choose from Photos'**
  String get localVideoChooseFromPhotos;

  /// No description provided for @localVideoChooseDifferent.
  ///
  /// In en, this message translates to:
  /// **'Choose a Different Video'**
  String get localVideoChooseDifferent;

  /// No description provided for @localVideoSelectedFileLabel.
  ///
  /// In en, this message translates to:
  /// **'Selected file'**
  String get localVideoSelectedFileLabel;

  /// No description provided for @localVideoSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get localVideoSizeLabel;

  /// No description provided for @localVideoDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get localVideoDurationLabel;

  /// No description provided for @localVideoLongVideoWarning.
  ///
  /// In en, this message translates to:
  /// **'This video is longer than 3 minutes, so Bantera may need longer to prepare the transcript and translation.'**
  String get localVideoLongVideoWarning;

  /// No description provided for @localVideoStep2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Transcription language'**
  String get localVideoStep2Title;

  /// No description provided for @localVideoChooseLanguagePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Choose the spoken language'**
  String get localVideoChooseLanguagePlaceholder;

  /// No description provided for @localVideoLanguageHint.
  ///
  /// In en, this message translates to:
  /// **'Bantera remembers your last language choice and keeps transcription hidden by default once practice starts.'**
  String get localVideoLanguageHint;

  /// No description provided for @localVideoStep3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Practice'**
  String get localVideoStep3Title;

  /// No description provided for @localVideoPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing...'**
  String get localVideoPreparing;

  /// No description provided for @localVideoPracticeHint.
  ///
  /// In en, this message translates to:
  /// **'Bantera transcribes on device first, then opens the cue-by-cue listening page without uploading anything.'**
  String get localVideoPracticeHint;

  /// No description provided for @localVideoStatusLongVideo.
  ///
  /// In en, this message translates to:
  /// **'This is a longer video, so Bantera may need extra time to transcribe and prepare it.'**
  String get localVideoStatusLongVideo;

  /// No description provided for @localVideoStatusTranscribing.
  ///
  /// In en, this message translates to:
  /// **'Transcribing on device and preparing practice cues...'**
  String get localVideoStatusTranscribing;

  /// No description provided for @localVideoStatusSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving this video to your on-device practice library...'**
  String get localVideoStatusSaving;

  /// No description provided for @localVideoStatusTranslationLong.
  ///
  /// In en, this message translates to:
  /// **'Transcription finished. Bantera is also preparing translation for your saved language, so this longer video may take a bit more time.'**
  String get localVideoStatusTranslationLong;

  /// No description provided for @localVideoStatusTranslation.
  ///
  /// In en, this message translates to:
  /// **'Transcription finished. Preparing translation for your saved language...'**
  String get localVideoStatusTranslation;

  /// No description provided for @localVideoPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Audio Language'**
  String get localVideoPickerTitle;

  /// No description provided for @savedCuesTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved Cues'**
  String get savedCuesTitle;

  /// No description provided for @savedCuesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No saved cues yet. Tap the bookmark icon while practicing to save a cue.'**
  String get savedCuesEmpty;

  /// No description provided for @savedCuesDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove saved cue'**
  String get savedCuesDeleteTooltip;

  /// No description provided for @savedCuesDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this cue?'**
  String get savedCuesDeleteConfirmTitle;

  /// No description provided for @savedCuesDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This cue will be removed from your saved list.'**
  String get savedCuesDeleteConfirmBody;

  /// No description provided for @savedCuesDeleteAllTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete all saved cues'**
  String get savedCuesDeleteAllTooltip;

  /// No description provided for @savedCuesDeleteAllConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all saved cues?'**
  String get savedCuesDeleteAllConfirmTitle;

  /// No description provided for @savedCuesDeleteAllConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'All saved cues will be permanently removed.'**
  String get savedCuesDeleteAllConfirmBody;
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
