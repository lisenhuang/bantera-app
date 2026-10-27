import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_th.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_vi.dart';
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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pl'),
    Locale('pt'),
    Locale('ru'),
    Locale('th'),
    Locale('tr'),
    Locale('uk'),
    Locale('vi'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
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

  /// No description provided for @authContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueWithGoogle;

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
  /// **'Set up your profile'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This helps Bantera personalize practice and chat.'**
  String get onboardingSubtitle;

  /// No description provided for @onboardingNameTitle.
  ///
  /// In en, this message translates to:
  /// **'What should people call you?'**
  String get onboardingNameTitle;

  /// No description provided for @onboardingNameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We filled this from your account when Apple provided it. You can change it now.'**
  String get onboardingNameSubtitle;

  /// No description provided for @onboardingClearName.
  ///
  /// In en, this message translates to:
  /// **'Clear name'**
  String get onboardingClearName;

  /// No description provided for @onboardingNativeLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'What is your native language?'**
  String get onboardingNativeLanguageTitle;

  /// No description provided for @onboardingNativeLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bantera uses this for translation and language groups.'**
  String get onboardingNativeLanguageSubtitle;

  /// No description provided for @onboardingLearningLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'What language are you learning?'**
  String get onboardingLearningLanguageTitle;

  /// No description provided for @onboardingLearningLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This controls practice content and learning groups.'**
  String get onboardingLearningLanguageSubtitle;

  /// No description provided for @onboardingAvatarTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a profile image'**
  String get onboardingAvatarTitle;

  /// No description provided for @onboardingAvatarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a photo, or continue and Bantera will generate one for you.'**
  String get onboardingAvatarSubtitle;

  /// No description provided for @onboardingAvatarGenderTitle.
  ///
  /// In en, this message translates to:
  /// **'Generate your profile image'**
  String get onboardingAvatarGenderTitle;

  /// No description provided for @onboardingAvatarGenderBody.
  ///
  /// In en, this message translates to:
  /// **'Choose how Bantera should generate your profile image. We do not store this choice; it is only used for this image.'**
  String get onboardingAvatarGenderBody;

  /// No description provided for @onboardingAvatarGenderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get onboardingAvatarGenderMale;

  /// No description provided for @onboardingAvatarGenderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get onboardingAvatarGenderFemale;

  /// No description provided for @onboardingChoosePhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose Photo'**
  String get onboardingChoosePhoto;

  /// No description provided for @onboardingChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get onboardingChangePhoto;

  /// No description provided for @onboardingUseGeneratedAvatar.
  ///
  /// In en, this message translates to:
  /// **'Use generated avatar instead'**
  String get onboardingUseGeneratedAvatar;

  /// No description provided for @onboardingUseCurrentPhoto.
  ///
  /// In en, this message translates to:
  /// **'Use current photo'**
  String get onboardingUseCurrentPhoto;

  /// No description provided for @onboardingChooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get onboardingChooseLanguage;

  /// No description provided for @onboardingBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingBack;

  /// No description provided for @onboardingFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get onboardingFinish;

  /// No description provided for @onboardingLoadingProfile.
  ///
  /// In en, this message translates to:
  /// **'Loading profile...'**
  String get onboardingLoadingProfile;

  /// No description provided for @onboardingSavingProfile.
  ///
  /// In en, this message translates to:
  /// **'Saving profile...'**
  String get onboardingSavingProfile;

  /// No description provided for @onboardingLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get onboardingLoadFailed;

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

  /// No description provided for @sectionNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get sectionNotifications;

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
  /// **'Transcribe practice recordings and voice messages.'**
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

  /// No description provided for @closeLabel.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeLabel;

  /// No description provided for @longerDialogues.
  ///
  /// In en, this message translates to:
  /// **'Longer dialogues'**
  String get longerDialogues;

  /// No description provided for @navDiscover.
  ///
  /// In en, this message translates to:
  /// **'Dialogues'**
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

  /// No description provided for @navGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get navGoal;

  /// No description provided for @chatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chatsTitle;

  /// No description provided for @chatNoChatsYet.
  ///
  /// In en, this message translates to:
  /// **'No chats yet.'**
  String get chatNoChatsYet;

  /// No description provided for @chatHideSameNativeSpeakers.
  ///
  /// In en, this message translates to:
  /// **'Hide people with my native language'**
  String get chatHideSameNativeSpeakers;

  /// No description provided for @chatOnlineSection.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get chatOnlineSection;

  /// No description provided for @chatDirectMessagesSection.
  ///
  /// In en, this message translates to:
  /// **'DM'**
  String get chatDirectMessagesSection;

  /// No description provided for @chatAudioDuration.
  ///
  /// In en, this message translates to:
  /// **'Audio {duration}'**
  String chatAudioDuration(String duration);

  /// No description provided for @chatEnableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get chatEnableNotifications;

  /// No description provided for @chatMuteNotifications.
  ///
  /// In en, this message translates to:
  /// **'Mute notifications'**
  String get chatMuteNotifications;

  /// No description provided for @chatBlockUser.
  ///
  /// In en, this message translates to:
  /// **'Block user'**
  String get chatBlockUser;

  /// No description provided for @chatDeleteDm.
  ///
  /// In en, this message translates to:
  /// **'Delete DM'**
  String get chatDeleteDm;

  /// No description provided for @chatCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get chatCall;

  /// No description provided for @chatStartAudioCall.
  ///
  /// In en, this message translates to:
  /// **'Audio Call'**
  String get chatStartAudioCall;

  /// No description provided for @chatStartVideoCall.
  ///
  /// In en, this message translates to:
  /// **'Video Call'**
  String get chatStartVideoCall;

  /// No description provided for @chatAudioCalling.
  ///
  /// In en, this message translates to:
  /// **'Audio calling...'**
  String get chatAudioCalling;

  /// No description provided for @chatVideoCalling.
  ///
  /// In en, this message translates to:
  /// **'Video calling...'**
  String get chatVideoCalling;

  /// No description provided for @chatAudioIncoming.
  ///
  /// In en, this message translates to:
  /// **'Incoming audio call'**
  String get chatAudioIncoming;

  /// No description provided for @chatVideoIncoming.
  ///
  /// In en, this message translates to:
  /// **'Incoming video call'**
  String get chatVideoIncoming;

  /// No description provided for @chatCallConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get chatCallConnecting;

  /// No description provided for @chatCallAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get chatCallAccept;

  /// No description provided for @chatCallDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get chatCallDecline;

  /// No description provided for @chatCallEnd.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get chatCallEnd;

  /// No description provided for @chatCallMute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get chatCallMute;

  /// No description provided for @chatCallUnmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get chatCallUnmute;

  /// No description provided for @chatCallSpeaker.
  ///
  /// In en, this message translates to:
  /// **'Speaker'**
  String get chatCallSpeaker;

  /// No description provided for @chatCallCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get chatCallCamera;

  /// No description provided for @chatCallSwitchCamera.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get chatCallSwitchCamera;

  /// No description provided for @chatCallIssueTitle.
  ///
  /// In en, this message translates to:
  /// **'Call issue'**
  String get chatCallIssueTitle;

  /// No description provided for @chatCallMicrophoneDenied.
  ///
  /// In en, this message translates to:
  /// **'Bantera needs microphone access before starting a call.'**
  String get chatCallMicrophoneDenied;

  /// No description provided for @chatCallMicrophoneSettings.
  ///
  /// In en, this message translates to:
  /// **'Microphone access is turned off for Bantera. Open Settings and enable it for calls.'**
  String get chatCallMicrophoneSettings;

  /// No description provided for @chatCallCameraDenied.
  ///
  /// In en, this message translates to:
  /// **'Bantera needs camera access before starting a video call.'**
  String get chatCallCameraDenied;

  /// No description provided for @chatCallCameraSettings.
  ///
  /// In en, this message translates to:
  /// **'Camera access is turned off for Bantera. Open Settings and enable it for video calls.'**
  String get chatCallCameraSettings;

  /// No description provided for @chatCallBusy.
  ///
  /// In en, this message translates to:
  /// **'This user is already on another call.'**
  String get chatCallBusy;

  /// No description provided for @chatCallUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This user is not available for a call right now.'**
  String get chatCallUnavailable;

  /// No description provided for @chatCallNetworkRestricted.
  ///
  /// In en, this message translates to:
  /// **'This network can\'t connect the call. Try Wi-Fi or another network.'**
  String get chatCallNetworkRestricted;

  /// No description provided for @chatCallFailed.
  ///
  /// In en, this message translates to:
  /// **'The call couldn\'t be started. Please try again.'**
  String get chatCallFailed;

  /// No description provided for @chatGroupReady.
  ///
  /// In en, this message translates to:
  /// **'This group is ready for audio messages.'**
  String get chatGroupReady;

  /// No description provided for @chatHoldToStartDm.
  ///
  /// In en, this message translates to:
  /// **'Hold to record and start the DM.'**
  String get chatHoldToStartDm;

  /// No description provided for @chatNoGroupAudio.
  ///
  /// In en, this message translates to:
  /// **'No group audio yet.'**
  String get chatNoGroupAudio;

  /// No description provided for @chatNoDmAudio.
  ///
  /// In en, this message translates to:
  /// **'No audio in this DM yet.'**
  String get chatNoDmAudio;

  /// No description provided for @chatSendingAudio.
  ///
  /// In en, this message translates to:
  /// **'Sending audio...'**
  String get chatSendingAudio;

  /// No description provided for @chatRecordingReleaseToSend.
  ///
  /// In en, this message translates to:
  /// **'Recording... release to send'**
  String get chatRecordingReleaseToSend;

  /// No description provided for @chatHoldToRecordAudio.
  ///
  /// In en, this message translates to:
  /// **'Hold to record audio'**
  String get chatHoldToRecordAudio;

  /// No description provided for @chatTapOrHoldToRecordAudio.
  ///
  /// In en, this message translates to:
  /// **'Tap or hold to record'**
  String get chatTapOrHoldToRecordAudio;

  /// No description provided for @chatTapToSendAudio.
  ///
  /// In en, this message translates to:
  /// **'Tap to send'**
  String get chatTapToSendAudio;

  /// No description provided for @chatRecordingStatus.
  ///
  /// In en, this message translates to:
  /// **'Recording...'**
  String get chatRecordingStatus;

  /// No description provided for @chatGroupLabel.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get chatGroupLabel;

  /// No description provided for @chatNotificationsEnabledForDm.
  ///
  /// In en, this message translates to:
  /// **'Notifications enabled for this DM.'**
  String get chatNotificationsEnabledForDm;

  /// No description provided for @chatNotificationsMutedForDm.
  ///
  /// In en, this message translates to:
  /// **'Notifications muted for this DM.'**
  String get chatNotificationsMutedForDm;

  /// No description provided for @chatBlockUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Block {user}?'**
  String chatBlockUserTitle(String user);

  /// No description provided for @chatBlockUserBody.
  ///
  /// In en, this message translates to:
  /// **'You will stop seeing each other in DM sends and shared group messages until you unblock.'**
  String get chatBlockUserBody;

  /// No description provided for @chatBlockUserSuccess.
  ///
  /// In en, this message translates to:
  /// **'{user} has been blocked.'**
  String chatBlockUserSuccess(String user);

  /// No description provided for @chatBlockUserFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not block this user. Please try again.'**
  String get chatBlockUserFailed;

  /// No description provided for @chatDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete message'**
  String get chatDeleteMessage;

  /// No description provided for @chatDeleteMessageTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this message?'**
  String get chatDeleteMessageTitle;

  /// No description provided for @chatDeleteMessageBody.
  ///
  /// In en, this message translates to:
  /// **'This message will be removed for everyone in the conversation. This can\'t be undone.'**
  String get chatDeleteMessageBody;

  /// No description provided for @chatDeleteMessageSuccess.
  ///
  /// In en, this message translates to:
  /// **'Message deleted'**
  String get chatDeleteMessageSuccess;

  /// No description provided for @chatDeleteMessageFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete the message. Please try again.'**
  String get chatDeleteMessageFailed;

  /// No description provided for @chatDeleteDmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this DM?'**
  String get chatDeleteDmTitle;

  /// No description provided for @chatDeleteDmBody.
  ///
  /// In en, this message translates to:
  /// **'This only removes it from your list. A new message can bring it back later.'**
  String get chatDeleteDmBody;

  /// No description provided for @chatMicrophoneRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Microphone required'**
  String get chatMicrophoneRequiredTitle;

  /// No description provided for @chatMicrophoneRequiredSettings.
  ///
  /// In en, this message translates to:
  /// **'Bantera needs microphone access to record chat audio. Enable it in Settings.'**
  String get chatMicrophoneRequiredSettings;

  /// No description provided for @chatMicrophoneRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'Bantera needs microphone access to record chat audio.'**
  String get chatMicrophoneRequiredBody;

  /// No description provided for @chatGroupNotReady.
  ///
  /// In en, this message translates to:
  /// **'This group is not ready yet.'**
  String get chatGroupNotReady;

  /// No description provided for @chatMessageAction.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get chatMessageAction;

  /// No description provided for @chatRetranscribe.
  ///
  /// In en, this message translates to:
  /// **'Retranscribe'**
  String get chatRetranscribe;

  /// No description provided for @chatTranscribe.
  ///
  /// In en, this message translates to:
  /// **'Transcribe'**
  String get chatTranscribe;

  /// No description provided for @chatTranscribingOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Transcribing on this iPhone...'**
  String get chatTranscribingOnDevice;

  /// No description provided for @chatTranscriptionFailed.
  ///
  /// In en, this message translates to:
  /// **'Transcription failed. Try again.'**
  String get chatTranscriptionFailed;

  /// No description provided for @chatTranslate.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get chatTranslate;

  /// No description provided for @chatRetranslate.
  ///
  /// In en, this message translates to:
  /// **'Retranslate'**
  String get chatRetranslate;

  /// No description provided for @chatTranslating.
  ///
  /// In en, this message translates to:
  /// **'Translating on this iPhone...'**
  String get chatTranslating;

  /// No description provided for @chatTranslationFailed.
  ///
  /// In en, this message translates to:
  /// **'Translation failed. Please try again.'**
  String get chatTranslationFailed;

  /// No description provided for @chatGroupSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Group settings'**
  String get chatGroupSettingsTitle;

  /// No description provided for @chatNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get chatNotifications;

  /// No description provided for @chatBlockedUsersMenu.
  ///
  /// In en, this message translates to:
  /// **'Blocked Users'**
  String get chatBlockedUsersMenu;

  /// No description provided for @chatBlockedUsersTitle.
  ///
  /// In en, this message translates to:
  /// **'Blocked Users'**
  String get chatBlockedUsersTitle;

  /// No description provided for @chatBlockedPeople.
  ///
  /// In en, this message translates to:
  /// **'Blocked people'**
  String get chatBlockedPeople;

  /// No description provided for @chatNoBlockedUsers.
  ///
  /// In en, this message translates to:
  /// **'No blocked users yet.'**
  String get chatNoBlockedUsers;

  /// No description provided for @chatNoBlockedPeople.
  ///
  /// In en, this message translates to:
  /// **'No blocked people yet.'**
  String get chatNoBlockedPeople;

  /// No description provided for @chatUnblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get chatUnblock;

  /// No description provided for @chatUnblockUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Unblock {user}?'**
  String chatUnblockUserTitle(String user);

  /// No description provided for @chatUnblockUserBody.
  ///
  /// In en, this message translates to:
  /// **'You may see each other again in DMs and shared group messages.'**
  String get chatUnblockUserBody;

  /// No description provided for @chatUnblockFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not unblock this user. Please try again.'**
  String get chatUnblockFailed;

  /// No description provided for @chatNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat notifications'**
  String get chatNotificationsTitle;

  /// No description provided for @chatNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use one account-wide switch across your devices.'**
  String get chatNotificationsSubtitle;

  /// No description provided for @chatNotificationsDisabledTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications disabled'**
  String get chatNotificationsDisabledTitle;

  /// No description provided for @chatNotificationsDisabledSettings.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications in Settings to receive Bantera chat alerts.'**
  String get chatNotificationsDisabledSettings;

  /// No description provided for @chatNotificationsDisabledBody.
  ///
  /// In en, this message translates to:
  /// **'Bantera needs notification permission before chat alerts can be enabled.'**
  String get chatNotificationsDisabledBody;

  /// No description provided for @chatNotificationUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update chat notifications. Please try again.'**
  String get chatNotificationUpdateFailed;

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

  /// Discover empty state when a specific difficulty level is selected.
  ///
  /// In en, this message translates to:
  /// **'No public content in {language} for {level} level yet'**
  String discoverNoPublicContentInLanguageAtLevel(
    String language,
    String level,
  );

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
  /// **'Shadowing'**
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
  /// **'Shadowing'**
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

  /// No description provided for @compareUncertainHint.
  ///
  /// In en, this message translates to:
  /// **'Dotted words were recognised but Bantera wasn\'t sure — check your pronunciation.'**
  String get compareUncertainHint;

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

  /// No description provided for @compareUncertainCount.
  ///
  /// In en, this message translates to:
  /// **'{count} unclear'**
  String compareUncertainCount(int count);

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

  /// No description provided for @languagePickerTotals.
  ///
  /// In en, this message translates to:
  /// **'{languages, plural, =1{1 language} other{{languages} languages}} · {accents, plural, =1{1 accent} other{{accents} accents}}'**
  String languagePickerTotals(int languages, int accents);

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
  /// **'This may take up to a minute.'**
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
  /// **'Audio you generate here becomes Bantera community content — shared publicly as practice material for all learners.'**
  String get aiGenOwnershipNotice;

  /// No description provided for @aiGenOwnershipCheckbox.
  ///
  /// In en, this message translates to:
  /// **'Share this audio as Bantera community content'**
  String get aiGenOwnershipCheckbox;

  /// No description provided for @aiGenOwnershipConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Share as community content?'**
  String get aiGenOwnershipConfirmTitle;

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

  /// No description provided for @updateAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get updateAlertTitle;

  /// No description provided for @updateAlertMessage.
  ///
  /// In en, this message translates to:
  /// **'A new version of Bantera is available. Update now to get the latest features and improvements.'**
  String get updateAlertMessage;

  /// No description provided for @updateCurrentVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Current version'**
  String get updateCurrentVersionLabel;

  /// No description provided for @updateAppStoreVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'App Store version'**
  String get updateAppStoreVersionLabel;

  /// No description provided for @updateAlertUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateAlertUpdate;

  /// No description provided for @updateAlertLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get updateAlertLater;

  /// No description provided for @checkForUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'Check for Updates'**
  String get checkForUpdateButton;

  /// No description provided for @upToDateAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'Up to Date'**
  String get upToDateAlertTitle;

  /// No description provided for @upToDateAlertMessage.
  ///
  /// In en, this message translates to:
  /// **'Bantera {version} is the latest version.'**
  String upToDateAlertMessage(Object version);

  /// No description provided for @sectionSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get sectionSupport;

  /// No description provided for @permissionActionAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get permissionActionAllow;

  /// No description provided for @audioLevelBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get audioLevelBeginner;

  /// No description provided for @audioLevelIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get audioLevelIntermediate;

  /// No description provided for @audioLevelAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get audioLevelAdvanced;

  /// No description provided for @audioLevelAll.
  ///
  /// In en, this message translates to:
  /// **'All levels'**
  String get audioLevelAll;

  /// No description provided for @audioLevelSelect.
  ///
  /// In en, this message translates to:
  /// **'Select level'**
  String get audioLevelSelect;

  /// No description provided for @audioLevelSection.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get audioLevelSection;

  /// No description provided for @audioLevelRequired.
  ///
  /// In en, this message translates to:
  /// **'Select a level before generating audio.'**
  String get audioLevelRequired;

  /// No description provided for @wordActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'My Achievements'**
  String get wordActivityTitle;

  /// No description provided for @wordActivityToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get wordActivityToday;

  /// No description provided for @wordActivityThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get wordActivityThisWeek;

  /// No description provided for @wordActivityTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get wordActivityTotal;

  /// No description provided for @wordActivityListened.
  ///
  /// In en, this message translates to:
  /// **'Words listened'**
  String get wordActivityListened;

  /// No description provided for @wordActivitySpoken.
  ///
  /// In en, this message translates to:
  /// **'Words spoken'**
  String get wordActivitySpoken;

  /// No description provided for @wordActivityHint.
  ///
  /// In en, this message translates to:
  /// **'Estimated from transcripts. Replays count again.'**
  String get wordActivityHint;

  /// No description provided for @dailyGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get dailyGoalTitle;

  /// No description provided for @dailyGoalSet.
  ///
  /// In en, this message translates to:
  /// **'Set daily goal'**
  String get dailyGoalSet;

  /// No description provided for @dailyGoalEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit goal'**
  String get dailyGoalEdit;

  /// No description provided for @dailyGoalChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose your daily goal'**
  String get dailyGoalChoose;

  /// No description provided for @dailyGoalPreset.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min / day'**
  String dailyGoalPreset(String minutes);

  /// No description provided for @dailyGoalHourPreset.
  ///
  /// In en, this message translates to:
  /// **'1 h / day'**
  String get dailyGoalHourPreset;

  /// No description provided for @dailyGoalCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get dailyGoalCustom;

  /// No description provided for @dailyGoalListeningTarget.
  ///
  /// In en, this message translates to:
  /// **'Listening words per day'**
  String get dailyGoalListeningTarget;

  /// No description provided for @dailyGoalSpeakingTarget.
  ///
  /// In en, this message translates to:
  /// **'Speaking words per day'**
  String get dailyGoalSpeakingTarget;

  /// No description provided for @dailyGoalEstimate.
  ///
  /// In en, this message translates to:
  /// **'About {minutes} min'**
  String dailyGoalEstimate(String minutes);

  /// No description provided for @dailyGoalTimeTotal.
  ///
  /// In en, this message translates to:
  /// **'About {minutes} min in total'**
  String dailyGoalTimeTotal(String minutes);

  /// No description provided for @dailyGoalTimeHint.
  ///
  /// In en, this message translates to:
  /// **'Estimates use 120 listening words and 60 speaking words per minute. Pauses and your pace may take longer. Goals are saved on this device for your account.'**
  String get dailyGoalTimeHint;

  /// No description provided for @dailyGoalValidation.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number from 0 to 100,000. Set 0 for no requirement.'**
  String get dailyGoalValidation;

  /// No description provided for @dailyGoalRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove goal'**
  String get dailyGoalRemove;

  /// No description provided for @dailyGoalRemoveConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Remove your daily goal and its reminders? Your word counts will stay saved.'**
  String get dailyGoalRemoveConfirmation;

  /// No description provided for @dailyGoalReached.
  ///
  /// In en, this message translates to:
  /// **'Today’s goals reached'**
  String get dailyGoalReached;

  /// No description provided for @dailyGoalProgress.
  ///
  /// In en, this message translates to:
  /// **'{count}/{target} words'**
  String dailyGoalProgress(String count, String target);

  /// No description provided for @dailyGoalSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save your goal. Please try again.'**
  String get dailyGoalSaveFailed;

  /// No description provided for @wordActivityShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get wordActivityShare;

  /// No description provided for @wordActivityPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get wordActivityPreview;

  /// Share headline. language is the catalog language name with spaces replaced by underscores, for localized Chinese select variants. Other locales may keep a language-neutral headline.
  ///
  /// In en, this message translates to:
  /// **'Say it.\nOut loud.'**
  String wordActivityShareHeading(String language);

  /// No description provided for @wordActivitySavePhotos.
  ///
  /// In en, this message translates to:
  /// **'Save to Photos'**
  String get wordActivitySavePhotos;

  /// No description provided for @wordActivitySaved.
  ///
  /// In en, this message translates to:
  /// **'Saved to Photos'**
  String get wordActivitySaved;

  /// No description provided for @wordActivitySaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the image. Please try again.'**
  String get wordActivitySaveFailed;

  /// No description provided for @wordActivityShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not share the image. Please try again.'**
  String get wordActivityShareFailed;

  /// No description provided for @wordActivityPhotoPermission.
  ///
  /// In en, this message translates to:
  /// **'Allow Bantera to add photos in Settings, then try again.'**
  String get wordActivityPhotoPermission;

  /// No description provided for @wordActivityScanToJoin.
  ///
  /// In en, this message translates to:
  /// **'Scan to practise'**
  String get wordActivityScanToJoin;

  /// No description provided for @dailyGoalNoRequirement.
  ///
  /// In en, this message translates to:
  /// **'No goal requirement'**
  String get dailyGoalNoRequirement;

  /// No description provided for @wordActivityLearningLanguage.
  ///
  /// In en, this message translates to:
  /// **'Learning {language}'**
  String wordActivityLearningLanguage(String language);

  /// No description provided for @wordActivityLegacyLabel.
  ///
  /// In en, this message translates to:
  /// **'Earlier activity (language unknown)'**
  String get wordActivityLegacyLabel;

  /// No description provided for @saveLabel.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveLabel;

  /// No description provided for @wordActivityShareToNativeGroup.
  ///
  /// In en, this message translates to:
  /// **'Share to native group'**
  String get wordActivityShareToNativeGroup;

  /// No description provided for @wordActivitySentToGroup.
  ///
  /// In en, this message translates to:
  /// **'Shared to the group'**
  String get wordActivitySentToGroup;

  /// No description provided for @dailyGoalNotificationLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily goal reminder'**
  String get dailyGoalNotificationLabel;

  /// No description provided for @dailyGoalNotificationHint.
  ///
  /// In en, this message translates to:
  /// **'Remind me when my daily goals are unfinished. Uses my timezone.'**
  String get dailyGoalNotificationHint;

  /// No description provided for @dailyGoalReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'A little more practice today'**
  String get dailyGoalReminderTitle;

  /// No description provided for @dailyGoalReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Your daily goals are still unfinished. Keep listening and speaking.'**
  String get dailyGoalReminderBody;

  /// No description provided for @dailyGoalNotificationTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get dailyGoalNotificationTime;

  /// No description provided for @dailyGoalRepeatLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get dailyGoalRepeatLabel;

  /// No description provided for @dailyGoalRepeatNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get dailyGoalRepeatNever;

  /// No description provided for @dailyGoalRepeatEveryDay.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get dailyGoalRepeatEveryDay;

  /// No description provided for @dailyGoalRepeatWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Weekdays'**
  String get dailyGoalRepeatWeekdays;

  /// No description provided for @dailyGoalRepeatWeekends.
  ///
  /// In en, this message translates to:
  /// **'Weekends'**
  String get dailyGoalRepeatWeekends;

  /// No description provided for @dailyGoalRepeatOnceHint.
  ///
  /// In en, this message translates to:
  /// **'One reminder at the next chosen time, without repeating.'**
  String get dailyGoalRepeatOnceHint;

  /// No description provided for @discoverAllAccents.
  ///
  /// In en, this message translates to:
  /// **'All accents'**
  String get discoverAllAccents;

  /// No description provided for @wordActivityShareToday.
  ///
  /// In en, this message translates to:
  /// **'Today’s practice'**
  String get wordActivityShareToday;

  /// No description provided for @wordActivityShareSpokenToday.
  ///
  /// In en, this message translates to:
  /// **'Today I spoke'**
  String get wordActivityShareSpokenToday;

  /// Standalone unit beside the spoken total. Pluralize using the unformatted count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{word} other{words}}'**
  String wordActivityShareWordUnit(int count);

  /// Complete listening caption. Keep count anywhere required by local grammar.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Also listened to {count} word} other{Also listened to {count} words}}'**
  String wordActivityShareListened(int count);

  /// No description provided for @wordActivityShareEncouragement.
  ///
  /// In en, this message translates to:
  /// **'Every word you say counts.'**
  String get wordActivityShareEncouragement;

  /// No description provided for @wordActivityShareInvitation.
  ///
  /// In en, this message translates to:
  /// **'Practice together. Speak freely.'**
  String get wordActivityShareInvitation;

  /// Complete activity sentence. period is today, week, or total. progress is a locale-formatted count or count/goal. count selects plural forms (the goal when progress is a ratio).
  ///
  /// In en, this message translates to:
  /// **'{period, select, today{{count, plural, one{Heard {progress} word today} other{Heard {progress} words today}}} week{{count, plural, one{Heard {progress} word this week} other{Heard {progress} words this week}}} other{{count, plural, one{Heard {progress} word in total} other{Heard {progress} words in total}}}}'**
  String wordActivityListeningSummary(
    String period,
    String progress,
    int count,
  );

  /// Complete activity sentence. period is today, week, or total. progress is a locale-formatted count or count/goal. count selects plural forms (the goal when progress is a ratio).
  ///
  /// In en, this message translates to:
  /// **'{period, select, today{{count, plural, one{Said {progress} word today} other{Said {progress} words today}}} week{{count, plural, one{Said {progress} word this week} other{Said {progress} words this week}}} other{{count, plural, one{Said {progress} word in total} other{Said {progress} words in total}}}}'**
  String wordActivitySpeakingSummary(String period, String progress, int count);

  /// No description provided for @wordActivityListening.
  ///
  /// In en, this message translates to:
  /// **'Listening'**
  String get wordActivityListening;

  /// No description provided for @wordActivitySpeaking.
  ///
  /// In en, this message translates to:
  /// **'Speaking'**
  String get wordActivitySpeaking;

  /// No description provided for @wordActivityTrend.
  ///
  /// In en, this message translates to:
  /// **'Practice over time'**
  String get wordActivityTrend;

  /// No description provided for @wordActivitySevenDays.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get wordActivitySevenDays;

  /// No description provided for @wordActivityThirtyDays.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get wordActivityThirtyDays;

  /// No description provided for @wordActivityWords.
  ///
  /// In en, this message translates to:
  /// **'Words'**
  String get wordActivityWords;

  /// No description provided for @wordActivityTrendEmpty.
  ///
  /// In en, this message translates to:
  /// **'No practice recorded in this period yet.'**
  String get wordActivityTrendEmpty;

  /// No description provided for @wordActivityAllTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get wordActivityAllTime;

  /// No description provided for @profileLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Your practice library'**
  String get profileLibraryTitle;

  /// No description provided for @practiceHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice History'**
  String get practiceHistoryTitle;

  /// No description provided for @practiceHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'See your progress and pick up where you left off'**
  String get practiceHistorySubtitle;

  /// No description provided for @profileSavedMediaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your collection of audio and video'**
  String get profileSavedMediaSubtitle;

  /// No description provided for @profileSavedCuesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Revisit phrases you want to practise'**
  String get profileSavedCuesSubtitle;

  /// Original transcript cues actually heard, not a fluency score. Counts are locale-formatted.
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total} cues heard'**
  String practiceHistoryProgress(String completed, String total);

  /// No description provided for @practiceHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your next practice starts here'**
  String get practiceHistoryEmpty;

  /// No description provided for @practiceHistoryDeviceNote.
  ///
  /// In en, this message translates to:
  /// **'Practice a lesson to see your progress here. History is saved on this device.'**
  String get practiceHistoryDeviceNote;

  /// No description provided for @practiceHistoryRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'Remove this lesson from history and reset its progress and resume point? Your saved media, saved cues and word totals will stay.'**
  String get practiceHistoryRemoveBody;

  /// No description provided for @practiceHistoryUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This media is no longer on this device. You can remove it from history.'**
  String get practiceHistoryUnavailable;

  /// No description provided for @aiClearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear chat'**
  String get aiClearHistory;

  /// No description provided for @aiClearHistoryBody.
  ///
  /// In en, this message translates to:
  /// **'Delete this device’s AI messages, audio and conversation memory? This ends the current call. Your learning library, profile and scheduled callbacks stay unchanged.'**
  String get aiClearHistoryBody;

  /// No description provided for @aiLocalHistory.
  ///
  /// In en, this message translates to:
  /// **'Received AI chat history stays on this device. Relevant context is sent to AI to reply. Reminder schedules and notes are stored on the server. Voice reminder audio is stored temporarily until received or cancelled, for up to seven days.'**
  String get aiLocalHistory;

  /// No description provided for @aiSayingGoodbye.
  ///
  /// In en, this message translates to:
  /// **'Saying goodbye'**
  String get aiSayingGoodbye;

  /// No description provided for @aiSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get aiSend;

  /// No description provided for @aiPlayAudio.
  ///
  /// In en, this message translates to:
  /// **'Play audio'**
  String get aiPlayAudio;

  /// No description provided for @aiWelcome.
  ///
  /// In en, this message translates to:
  /// **'Your language practice partner. Send a voice message or start a nine-minute audio call.'**
  String get aiWelcome;

  /// No description provided for @aiChatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Voice messages and audio calls'**
  String get aiChatSubtitle;

  /// No description provided for @aiRecordVoiceMessage.
  ///
  /// In en, this message translates to:
  /// **'Record a voice message'**
  String get aiRecordVoiceMessage;

  /// No description provided for @aiPrivacyNotice.
  ///
  /// In en, this message translates to:
  /// **'Privacy notice'**
  String get aiPrivacyNotice;

  /// No description provided for @aiUsageTitle.
  ///
  /// In en, this message translates to:
  /// **'How to Use'**
  String get aiUsageTitle;

  /// No description provided for @aiUsageBody.
  ///
  /// In en, this message translates to:
  /// **'Hold the voice button and release to send, or tap the microphone to record. Recordings send automatically after 3 minutes. Bantera AI helps you practise speaking and listening in your learning language and accent.\n\nTap the phone for a 9-minute audio call. AI greets you first. Tap Translate on a message whenever you need help.\n\nAsk “Call me in 10 minutes to remind me to practise English,” or give a specific time. Include what you want to be reminded about. If you only give a time, AI will ask what the reminder is for before scheduling.\n\nFor callbacks, enable call notifications on your iPhone and keep an internet connection. Answer the incoming call to hear your reminder; delivery may be delayed.\n\nAsk “Remind me in 10 minutes to practise” for a voice message. Say “Call me” only if you want a call. Times below use your current timezone. Recent reminders stay here for seven days.\n\nReceived AI chat history stays on this device. Relevant context is sent to AI to reply. Reminder schedules and notes are stored on the server. Voice reminder audio is stored temporarily until received or cancelled, for up to seven days.'**
  String get aiUsageBody;

  /// No description provided for @aiCallConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Start an audio call?'**
  String get aiCallConfirmTitle;

  /// No description provided for @aiCallConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Talk with Bantera AI for up to 9 minutes. It will greet you first.'**
  String get aiCallConfirmBody;

  /// No description provided for @aiCallConfirmStart.
  ///
  /// In en, this message translates to:
  /// **'Start call'**
  String get aiCallConfirmStart;

  /// No description provided for @aiReplying.
  ///
  /// In en, this message translates to:
  /// **'Bantera AI is replying…'**
  String get aiReplying;

  /// No description provided for @aiRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get aiRemindersTitle;

  /// No description provided for @aiReminderMessage.
  ///
  /// In en, this message translates to:
  /// **'Voice message'**
  String get aiReminderMessage;

  /// No description provided for @aiReminderCall.
  ///
  /// In en, this message translates to:
  /// **'Audio call'**
  String get aiReminderCall;

  /// No description provided for @aiReminderEmpty.
  ///
  /// In en, this message translates to:
  /// **'No reminders yet'**
  String get aiReminderEmpty;

  /// No description provided for @aiReminderCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this reminder?'**
  String get aiReminderCancelTitle;

  /// No description provided for @aiReminderPending.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get aiReminderPending;

  /// No description provided for @aiReminderPreparing.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get aiReminderPreparing;

  /// No description provided for @aiReminderReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get aiReminderReady;

  /// No description provided for @aiReminderDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get aiReminderDelivered;

  /// No description provided for @aiReminderCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get aiReminderCancelled;

  /// No description provided for @aiReminderFailed.
  ///
  /// In en, this message translates to:
  /// **'Not delivered'**
  String get aiReminderFailed;

  /// No description provided for @aiReminderScheduleHelp.
  ///
  /// In en, this message translates to:
  /// **'Ask “Remind me in 10 minutes to practise” for a voice message. Say “Call me” only if you want a call. Times below use your current timezone. Recent reminders stay here for seven days.'**
  String get aiReminderScheduleHelp;

  /// No description provided for @aiReplyInterrupted.
  ///
  /// In en, this message translates to:
  /// **'Reply interrupted.'**
  String get aiReplyInterrupted;

  /// No description provided for @aiWebSearching.
  ///
  /// In en, this message translates to:
  /// **'Searching the web…'**
  String get aiWebSearching;

  /// No description provided for @aiWebUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Search unavailable'**
  String get aiWebUnavailable;

  /// No description provided for @aiWebSources.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get aiWebSources;

  /// No description provided for @aiWebSearchHelp.
  ///
  /// In en, this message translates to:
  /// **'You can ask Bantera AI to search the web. Searches run on this device: queries go to DuckDuckGo, and result excerpts go to AI. Tap a source to open it. Search may sometimes be unavailable.'**
  String get aiWebSearchHelp;

  /// No description provided for @aiImages.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get aiImages;

  /// No description provided for @aiImagesSearching.
  ///
  /// In en, this message translates to:
  /// **'Finding pictures…'**
  String get aiImagesSearching;

  /// No description provided for @aiImagesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Pictures unavailable. Try again later.'**
  String get aiImagesUnavailable;

  /// No description provided for @aiImageShare.
  ///
  /// In en, this message translates to:
  /// **'Save or share image'**
  String get aiImageShare;

  /// No description provided for @aiImagesHelp.
  ///
  /// In en, this message translates to:
  /// **'Image searches run on this device. You can also attach up to 4 images to a voice message from Camera, Photos or Files. Attached images and voice are sent through Bantera to the AI for processing; Bantera does not store these images on its servers. Copies stay in this device’s chat history. Tap an image to enlarge it. Web images include source links for usage rights.'**
  String get aiImagesHelp;

  /// No description provided for @aiImagesRights.
  ///
  /// In en, this message translates to:
  /// **'Check source for usage rights'**
  String get aiImagesRights;

  /// No description provided for @vocabTitle.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get vocabTitle;

  /// No description provided for @vocabAdd.
  ///
  /// In en, this message translates to:
  /// **'Add a word'**
  String get vocabAdd;

  /// No description provided for @vocabEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit word'**
  String get vocabEdit;

  /// No description provided for @vocabRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove this word?'**
  String get vocabRemove;

  /// No description provided for @vocabWord.
  ///
  /// In en, this message translates to:
  /// **'Word or phrase'**
  String get vocabWord;

  /// No description provided for @vocabMeaning.
  ///
  /// In en, this message translates to:
  /// **'Short meaning'**
  String get vocabMeaning;

  /// No description provided for @vocabExample.
  ///
  /// In en, this message translates to:
  /// **'Example (optional)'**
  String get vocabExample;

  /// No description provided for @vocabRequired.
  ///
  /// In en, this message translates to:
  /// **'Please fill in this field.'**
  String get vocabRequired;

  /// No description provided for @vocabSaved.
  ///
  /// In en, this message translates to:
  /// **'words saved'**
  String get vocabSaved;

  /// No description provided for @vocabDue.
  ///
  /// In en, this message translates to:
  /// **'Due for review'**
  String get vocabDue;

  /// No description provided for @vocabAll.
  ///
  /// In en, this message translates to:
  /// **'All words'**
  String get vocabAll;

  /// No description provided for @vocabNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get vocabNewest;

  /// No description provided for @vocabOldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get vocabOldest;

  /// No description provided for @vocabLearned.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get vocabLearned;

  /// No description provided for @vocabReviewed.
  ///
  /// In en, this message translates to:
  /// **'Reviewed'**
  String get vocabReviewed;

  /// No description provided for @vocabMarkReviewed.
  ///
  /// In en, this message translates to:
  /// **'Mark as reviewed'**
  String get vocabMarkReviewed;

  /// No description provided for @vocabSearch.
  ///
  /// In en, this message translates to:
  /// **'Search words or meanings'**
  String get vocabSearch;

  /// No description provided for @vocabEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your next word starts here'**
  String get vocabEmpty;

  /// No description provided for @vocabNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No matching words'**
  String get vocabNoMatches;

  /// No description provided for @vocabDuplicate.
  ///
  /// In en, this message translates to:
  /// **'This word is already saved.'**
  String get vocabDuplicate;

  /// No description provided for @vocabHelp.
  ///
  /// In en, this message translates to:
  /// **'Ask Bantera AI to save a word, explain your latest word or revise your vocabulary. You can also add and edit words here.'**
  String get vocabHelp;

  /// No description provided for @vocabPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Saved only on this device. Requested vocabulary is shared with AI to help it reply. Clearing chat history keeps your vocabulary.'**
  String get vocabPrivacy;

  /// No description provided for @aiKeysTitle.
  ///
  /// In en, this message translates to:
  /// **'AI key preference'**
  String get aiKeysTitle;

  /// No description provided for @aiKeysDescription.
  ///
  /// In en, this message translates to:
  /// **'Applies to Google lessons and voice chats. Changes affect new requests. Your administrator manages access and the key.'**
  String get aiKeysDescription;

  /// No description provided for @aiKeysRegular.
  ///
  /// In en, this message translates to:
  /// **'Regular keys only'**
  String get aiKeysRegular;

  /// No description provided for @aiKeysFallback.
  ///
  /// In en, this message translates to:
  /// **'Use paid key as fallback'**
  String get aiKeysFallback;

  /// No description provided for @aiKeysPaidOnly.
  ///
  /// In en, this message translates to:
  /// **'Paid key only'**
  String get aiKeysPaidOnly;

  /// No description provided for @aiAttachImages.
  ///
  /// In en, this message translates to:
  /// **'Attach images'**
  String get aiAttachImages;

  /// No description provided for @aiAttachmentHint.
  ///
  /// In en, this message translates to:
  /// **'Add up to 4 images, then record a voice message.'**
  String get aiAttachmentHint;

  /// No description provided for @aiAttachmentLocked.
  ///
  /// In en, this message translates to:
  /// **'Images are locked while recording. Cancel to change them.'**
  String get aiAttachmentLocked;

  /// No description provided for @aiAttachmentError.
  ///
  /// In en, this message translates to:
  /// **'Could not add this image. Try a smaller photo or another image.'**
  String get aiAttachmentError;

  /// No description provided for @aiCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get aiCamera;

  /// No description provided for @aiPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get aiPhotos;

  /// No description provided for @aiFiles.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get aiFiles;

  /// No description provided for @aiRemoveImage.
  ///
  /// In en, this message translates to:
  /// **'Remove image'**
  String get aiRemoveImage;

  /// No description provided for @aiConsentTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow AI data sharing?'**
  String get aiConsentTitle;

  /// No description provided for @aiConsentIntro.
  ///
  /// In en, this message translates to:
  /// **'With your permission, Bantera sends the following data through its servers to these AI providers for the features you use.'**
  String get aiConsentIntro;

  /// No description provided for @aiConsentGoogle.
  ///
  /// In en, this message translates to:
  /// **'For conversations, lessons and reminders: your voice audio, transcripts, attached images, prompts, relevant chat history and summaries, name, language and level preferences, practice activity, saved lessons and phrases, requested vocabulary, time zone, and reminder details. Google uses this data to understand your input and generate personalised replies, lesson text and speech. Google may also use data from unpaid processing for product improvement and human review. Do not share sensitive or confidential information.'**
  String get aiConsentGoogle;

  /// No description provided for @aiConsentCloudflare.
  ///
  /// In en, this message translates to:
  /// **'For avatars: your name, selected gender and language preferences. For lesson covers: the lesson title and language. Cloudflare uses this data to generate images.'**
  String get aiConsentCloudflare;

  /// No description provided for @aiConsentChoice.
  ///
  /// In en, this message translates to:
  /// **'Only the data needed for the feature is sent. Choose Not now to keep using features that do not need AI. You can turn off future sharing on this device in Settings > AI data sharing.'**
  String get aiConsentChoice;

  /// No description provided for @aiConsentPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get aiConsentPolicy;

  /// No description provided for @aiConsentDecline.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get aiConsentDecline;

  /// No description provided for @aiConsentAgree.
  ///
  /// In en, this message translates to:
  /// **'Agree and continue'**
  String get aiConsentAgree;

  /// No description provided for @aiConsentSettings.
  ///
  /// In en, this message translates to:
  /// **'AI data sharing'**
  String get aiConsentSettings;

  /// No description provided for @aiConsentEnabled.
  ///
  /// In en, this message translates to:
  /// **'AI data sharing is allowed on this device.'**
  String get aiConsentEnabled;

  /// No description provided for @aiConsentDisabled.
  ///
  /// In en, this message translates to:
  /// **'AI data sharing is off on this device.'**
  String get aiConsentDisabled;

  /// No description provided for @aiConsentRevoke.
  ///
  /// In en, this message translates to:
  /// **'Turn off AI sharing'**
  String get aiConsentRevoke;

  /// No description provided for @aiConsentExistingRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests already sent may finish. Scheduled reminders may still run; manage and cancel them below. Turning off sharing does not delete data already sent.'**
  String get aiConsentExistingRequests;

  /// No description provided for @aiConsentSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Your choice could not be saved. Please try again.'**
  String get aiConsentSaveFailed;

  /// No description provided for @aiConsentSearch.
  ///
  /// In en, this message translates to:
  /// **'If you use AI web or image search, queries are also sent to Microsoft Bing, DuckDuckGo or Wikimedia Commons, and results may be shared with Google.'**
  String get aiConsentSearch;

  /// No description provided for @navPractice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get navPractice;

  /// No description provided for @quickInstruction.
  ///
  /// In en, this message translates to:
  /// **'Listen, then say your reply.'**
  String get quickInstruction;

  /// No description provided for @quickPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing your practice…'**
  String get quickPreparing;

  /// No description provided for @quickPreparingHint.
  ///
  /// In en, this message translates to:
  /// **'A short conversation is on its way. We’ll prepare the next ones while you practise.'**
  String get quickPreparingHint;

  /// No description provided for @quickCue1.
  ///
  /// In en, this message translates to:
  /// **'Cue 1 · Listen'**
  String get quickCue1;

  /// No description provided for @quickCue2.
  ///
  /// In en, this message translates to:
  /// **'Cue 2 · Your reply'**
  String get quickCue2;

  /// No description provided for @quickSpeakHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to start and tap again to check, or hold while speaking and release to check.'**
  String get quickSpeakHint;

  /// No description provided for @quickSpeak.
  ///
  /// In en, this message translates to:
  /// **'Tap or hold to speak'**
  String get quickSpeak;

  /// No description provided for @quickChecking.
  ///
  /// In en, this message translates to:
  /// **'Listening to your answer…'**
  String get quickChecking;

  /// No description provided for @quickCorrect.
  ///
  /// In en, this message translates to:
  /// **'That reply fits. Nicely done.'**
  String get quickCorrect;

  /// No description provided for @quickIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Try the other reply.'**
  String get quickIncorrect;

  /// No description provided for @quickUnclear.
  ///
  /// In en, this message translates to:
  /// **'I couldn’t hear clearly. Please try again.'**
  String get quickUnclear;

  /// No description provided for @quickNext.
  ///
  /// In en, this message translates to:
  /// **'Next practice'**
  String get quickNext;

  /// No description provided for @quickAgain.
  ///
  /// In en, this message translates to:
  /// **'Say it again'**
  String get quickAgain;

  /// No description provided for @quickUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Practice is taking a little longer. Please try again.'**
  String get quickUnavailable;

  /// No description provided for @quickStart.
  ///
  /// In en, this message translates to:
  /// **'Start practising'**
  String get quickStart;

  /// No description provided for @quickChooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose a learning language in Edit Profile.'**
  String get quickChooseLanguage;

  /// No description provided for @quickCallActive.
  ///
  /// In en, this message translates to:
  /// **'Finish your call before practising.'**
  String get quickCallActive;

  /// No description provided for @goalCelebrationMessage.
  ///
  /// In en, this message translates to:
  /// **'You made time for your language today. Every word counts.'**
  String get goalCelebrationMessage;

  /// No description provided for @goalCelebrationContinue.
  ///
  /// In en, this message translates to:
  /// **'Keep practising'**
  String get goalCelebrationContinue;

  /// No description provided for @quickHeard.
  ///
  /// In en, this message translates to:
  /// **'What we heard'**
  String get quickHeard;

  /// No description provided for @quickCompareReply.
  ///
  /// In en, this message translates to:
  /// **'Compare with this reply'**
  String get quickCompareReply;

  /// No description provided for @quickDifferenceHint.
  ///
  /// In en, this message translates to:
  /// **'Highlights show differences or uncertain words, not proven pronunciation errors.'**
  String get quickDifferenceHint;

  /// No description provided for @quickRecognitionNote.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition can make mistakes.'**
  String get quickRecognitionNote;

  /// No description provided for @quickLevelsLink.
  ///
  /// In en, this message translates to:
  /// **'How levels work?'**
  String get quickLevelsLink;

  /// No description provided for @quickLevelsIntro.
  ///
  /// In en, this message translates to:
  /// **'Each language starts at A0. Your level adjusts automatically as you practise.'**
  String get quickLevelsIntro;

  /// No description provided for @quickLevelsWindow.
  ///
  /// In en, this message translates to:
  /// **'After 12 scored exercises at your current level, we review your latest 12 results.'**
  String get quickLevelsWindow;

  /// No description provided for @quickLevelsUp.
  ///
  /// In en, this message translates to:
  /// **'10–12 correct: pass this level.'**
  String get quickLevelsUp;

  /// No description provided for @quickLevelsStay.
  ///
  /// In en, this message translates to:
  /// **'5–9 correct: stay at this level.'**
  String get quickLevelsStay;

  /// No description provided for @quickLevelsDown.
  ///
  /// In en, this message translates to:
  /// **'0–4 correct: move down one level.'**
  String get quickLevelsDown;

  /// No description provided for @quickLevelsScoring.
  ///
  /// In en, this message translates to:
  /// **'Only your first clear answer to each exercise counts. Unclear recordings and skipped exercises do not count.\n\nA1–C2: Exercises with translation do not count toward level changes. Unassisted results count when you move to the next practice.'**
  String get quickLevelsScoring;

  /// No description provided for @quickLevelsReset.
  ///
  /// In en, this message translates to:
  /// **'After a level change, a new set of 12 begins. A0 is the lowest level and C2 the highest.'**
  String get quickLevelsReset;

  /// No description provided for @quickSkipTitle.
  ///
  /// In en, this message translates to:
  /// **'Skip this practice?'**
  String get quickSkipTitle;

  /// No description provided for @quickSkipMessage.
  ///
  /// In en, this message translates to:
  /// **'You haven’t completed this exercise correctly yet. Move to the next one?'**
  String get quickSkipMessage;

  /// No description provided for @quickSkipAction.
  ///
  /// In en, this message translates to:
  /// **'Skip practice'**
  String get quickSkipAction;

  /// No description provided for @quickSetGoal.
  ///
  /// In en, this message translates to:
  /// **'Set goal'**
  String get quickSetGoal;

  /// No description provided for @quickShowTranslation.
  ///
  /// In en, this message translates to:
  /// **'Show translation'**
  String get quickShowTranslation;

  /// No description provided for @quickTranslationHint.
  ///
  /// In en, this message translates to:
  /// **'Showing translation excludes this exercise from level changes.'**
  String get quickTranslationHint;

  /// No description provided for @quickTranslationExcluded.
  ///
  /// In en, this message translates to:
  /// **'Translation used · This exercise won’t change your level.'**
  String get quickTranslationExcluded;

  /// No description provided for @quickCompletedToday.
  ///
  /// In en, this message translates to:
  /// **'Completed today'**
  String get quickCompletedToday;

  /// No description provided for @quickChooseLevel.
  ///
  /// In en, this message translates to:
  /// **'Choose practice level'**
  String get quickChooseLevel;

  /// No description provided for @quickCurrentLevel.
  ///
  /// In en, this message translates to:
  /// **'Current level: {level}'**
  String quickCurrentLevel(String level);

  /// No description provided for @quickLevelLocked.
  ///
  /// In en, this message translates to:
  /// **'Level not reached yet'**
  String get quickLevelLocked;

  /// No description provided for @quickSwitchLevel.
  ///
  /// In en, this message translates to:
  /// **'Practise at {level}?'**
  String quickSwitchLevel(String level);

  /// No description provided for @quickLevelLockedBody.
  ///
  /// In en, this message translates to:
  /// **'Reach {level} through practice to unlock it. Your current level is {current}.'**
  String quickLevelLockedBody(String level, String current);

  /// No description provided for @quickReviewLevelBody.
  ///
  /// In en, this message translates to:
  /// **'Your {current} level and progress stay saved. Easier practice does not affect level changes. You can return to {current} at any time.'**
  String quickReviewLevelBody(String current);

  /// No description provided for @quickReturnLevelBody.
  ///
  /// In en, this message translates to:
  /// **'Continue at your current level. Answers without translation will count towards level changes again.'**
  String get quickReturnLevelBody;

  /// No description provided for @quickReviewMode.
  ///
  /// In en, this message translates to:
  /// **'Review · Current level: {level}'**
  String quickReviewMode(String level);

  /// No description provided for @quickA0Label.
  ///
  /// In en, this message translates to:
  /// **'Starting from zero'**
  String get quickA0Label;

  /// No description provided for @quickA0Description.
  ///
  /// In en, this message translates to:
  /// **'A0 is Bantera’s beginner stage before A1, inspired by Pre-A1. It is not an official CEFR level. Start with single words and short everyday expressions.'**
  String get quickA0Description;

  /// No description provided for @quickA0Hint.
  ///
  /// In en, this message translates to:
  /// **'Listen to the examples and their meanings, then try a reply. A0 includes learning support; your first clear answer counts.'**
  String get quickA0Hint;

  /// No description provided for @quickSave.
  ///
  /// In en, this message translates to:
  /// **'Save practice'**
  String get quickSave;

  /// No description provided for @quickUnsave.
  ///
  /// In en, this message translates to:
  /// **'Remove from saved'**
  String get quickUnsave;

  /// No description provided for @quickSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved practice'**
  String get quickSaved;

  /// No description provided for @quickSavedEmpty.
  ///
  /// In en, this message translates to:
  /// **'No saved practice yet. Choose “Save practice” from the … menu during practice.'**
  String get quickSavedEmpty;

  /// No description provided for @quickSavedDeviceNote.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device for your account. Listen to the question and replies again. Audio requires an internet connection.'**
  String get quickSavedDeviceNote;

  /// No description provided for @quickSavedError.
  ///
  /// In en, this message translates to:
  /// **'Could not update saved practice. Please try again.'**
  String get quickSavedError;

  /// No description provided for @leaderboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Speaking leaderboard'**
  String get leaderboardTitle;

  /// No description provided for @leaderboardScope.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get leaderboardScope;

  /// No description provided for @leaderboardYourPosition.
  ///
  /// In en, this message translates to:
  /// **'Your position'**
  String get leaderboardYourPosition;

  /// No description provided for @leaderboardSpokenWords.
  ///
  /// In en, this message translates to:
  /// **'spoken words'**
  String get leaderboardSpokenWords;

  /// No description provided for @leaderboardOpen.
  ///
  /// In en, this message translates to:
  /// **'View leaderboard'**
  String get leaderboardOpen;

  /// No description provided for @leaderboardError.
  ///
  /// In en, this message translates to:
  /// **'Could not refresh rankings. Try again.'**
  String get leaderboardError;

  /// No description provided for @leaderboardLearner.
  ///
  /// In en, this message translates to:
  /// **'Learner'**
  String get leaderboardLearner;

  /// No description provided for @leaderboardYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get leaderboardYou;

  /// No description provided for @leaderboardRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get leaderboardRefresh;

  /// No description provided for @leaderboardLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading rankings'**
  String get leaderboardLoading;

  /// No description provided for @leaderboardEncouragement.
  ///
  /// In en, this message translates to:
  /// **'Every conversation counts. Keep growing at your own pace.'**
  String get leaderboardEncouragement;

  /// No description provided for @leaderboardUpdate.
  ///
  /// In en, this message translates to:
  /// **'Updated rankings are ready. Refresh when you’re ready.'**
  String get leaderboardUpdate;

  /// No description provided for @leaderboardEmpty.
  ///
  /// In en, this message translates to:
  /// **'No speaking activity yet. A conversation is a great place to start.'**
  String get leaderboardEmpty;

  /// No description provided for @leaderboardNoActivity.
  ///
  /// In en, this message translates to:
  /// **'Speak in Practice or Chats to earn a position.'**
  String get leaderboardNoActivity;

  /// No description provided for @leaderboardFootnote.
  ///
  /// In en, this message translates to:
  /// **'Equal totals share a rank. Today and the previous 29 days, in UTC. Offline words appear after syncing.'**
  String get leaderboardFootnote;

  /// No description provided for @leaderboardLegacy.
  ///
  /// In en, this message translates to:
  /// **'Earlier activity keeps its originally recorded calendar date. New activity uses UTC.'**
  String get leaderboardLegacy;

  /// No description provided for @leaderboardLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get leaderboardLoadMore;

  /// No description provided for @quickLevelUpTitle.
  ///
  /// In en, this message translates to:
  /// **'You reached {level}'**
  String quickLevelUpTitle(String level);

  /// No description provided for @quickLevelUpBody.
  ///
  /// In en, this message translates to:
  /// **'Your listening and speaking practice is paying off. Keep building your confidence, one conversation at a time.'**
  String get quickLevelUpBody;

  /// No description provided for @quickTranslationLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Translation language'**
  String get quickTranslationLanguageLabel;

  /// No description provided for @quickTranslationLanguageBody.
  ///
  /// In en, this message translates to:
  /// **'Choose the translation language for this learning language. We’ll remember your choice on this device.'**
  String get quickTranslationLanguageBody;

  /// No description provided for @quickTranslationFallbackBody.
  ///
  /// In en, this message translates to:
  /// **'Translation into your native language is unavailable for this learning language. Choose another language. We’ll remember it for this learning language on this device.'**
  String get quickTranslationFallbackBody;

  /// No description provided for @quickTranslationDownloadTitle.
  ///
  /// In en, this message translates to:
  /// **'Download translation languages?'**
  String get quickTranslationDownloadTitle;

  /// No description provided for @quickTranslationDownloadBody.
  ///
  /// In en, this message translates to:
  /// **'Your phone needs translation language files. An internet connection is required to download them.'**
  String get quickTranslationDownloadBody;

  /// No description provided for @quickTranslationPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing translation languages…'**
  String get quickTranslationPreparing;

  /// No description provided for @quickTranslationChoosePrompt.
  ///
  /// In en, this message translates to:
  /// **'Choose a translation language to continue.'**
  String get quickTranslationChoosePrompt;

  /// No description provided for @quickTranslationDownloadNeeded.
  ///
  /// In en, this message translates to:
  /// **'Download translation languages to continue.'**
  String get quickTranslationDownloadNeeded;

  /// Confirmation title containing the tapped word or character.
  ///
  /// In en, this message translates to:
  /// **'Explain “{word}” with Bantera AI?'**
  String practiceExplainTitle(String word);

  /// No description provided for @practiceExplainAction.
  ///
  /// In en, this message translates to:
  /// **'Ask AI'**
  String get practiceExplainAction;

  /// No description provided for @practiceExplainMessage.
  ///
  /// In en, this message translates to:
  /// **'Explain “{word}” in this sentence: {sentence}'**
  String practiceExplainMessage(String word, String sentence);

  /// No description provided for @aiVideosSearching.
  ///
  /// In en, this message translates to:
  /// **'Finding videos…'**
  String get aiVideosSearching;

  /// No description provided for @aiVideosUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No videos found. Try again later.'**
  String get aiVideosUnavailable;

  /// No description provided for @aiPlayVideo.
  ///
  /// In en, this message translates to:
  /// **'Play video'**
  String get aiPlayVideo;

  /// No description provided for @aiVideoEmbedUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This video cannot play here. Open it in the browser.'**
  String get aiVideoEmbedUnavailable;

  /// No description provided for @aiOpenVideoBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open in browser'**
  String get aiOpenVideoBrowser;

  /// No description provided for @quickPlaybackSpeed.
  ///
  /// In en, this message translates to:
  /// **'Playback speed: {speed}×. Tap to change.'**
  String quickPlaybackSpeed(String speed);

  /// No description provided for @quickPauseAudio.
  ///
  /// In en, this message translates to:
  /// **'Pause audio'**
  String get quickPauseAudio;

  /// No description provided for @quickResumeAudio.
  ///
  /// In en, this message translates to:
  /// **'Resume audio'**
  String get quickResumeAudio;

  /// No description provided for @quickClearSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all saved practice?'**
  String get quickClearSavedTitle;

  /// No description provided for @quickClearSavedBody.
  ///
  /// In en, this message translates to:
  /// **'Remove all saved practices for this account from this device?'**
  String get quickClearSavedBody;

  /// No description provided for @practicePronunciation.
  ///
  /// In en, this message translates to:
  /// **'Pronunciation'**
  String get practicePronunciation;

  /// No description provided for @practicePronunciationPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing pronunciation…'**
  String get practicePronunciationPreparing;

  /// No description provided for @practicePronunciationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Pronunciation is unavailable right now.'**
  String get practicePronunciationUnavailable;

  /// No description provided for @practicePronunciationSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the pronunciation setting.'**
  String get practicePronunciationSaveFailed;

  /// No description provided for @practiceReleaseToCheck.
  ///
  /// In en, this message translates to:
  /// **'Release to check'**
  String get practiceReleaseToCheck;

  /// No description provided for @practiceTapToCheck.
  ///
  /// In en, this message translates to:
  /// **'Tap to check'**
  String get practiceTapToCheck;

  /// No description provided for @practiceMicStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting microphone…'**
  String get practiceMicStarting;

  /// No description provided for @quickLevelStateLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get quickLevelStateLocked;

  /// No description provided for @quickLevelPracticing.
  ///
  /// In en, this message translates to:
  /// **'Practicing'**
  String get quickLevelPracticing;

  /// No description provided for @quickLevelPassed.
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get quickLevelPassed;

  /// No description provided for @quickLevelStatesExplanation.
  ///
  /// In en, this message translates to:
  /// **'Start at A0. Pass a level with at least 10 correct answers in your latest 12 scored exercises to unlock the next level. Reaching C2 unlocks it; pass the same 10-out-of-12 test to complete C2. Passed levels stay passed, even when an easier level is recommended for review.'**
  String get quickLevelStatesExplanation;

  /// No description provided for @storageTitle.
  ///
  /// In en, this message translates to:
  /// **'Storage & Cache'**
  String get storageTitle;

  /// No description provided for @storageMeasured.
  ///
  /// In en, this message translates to:
  /// **'Stored on this device'**
  String get storageMeasured;

  /// No description provided for @storageClearable.
  ///
  /// In en, this message translates to:
  /// **'Safe to clear'**
  String get storageClearable;

  /// No description provided for @storageClear.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get storageClear;

  /// No description provided for @storageKeep.
  ///
  /// In en, this message translates to:
  /// **'Kept on device'**
  String get storageKeep;

  /// No description provided for @storageImages.
  ///
  /// In en, this message translates to:
  /// **'Photos & images'**
  String get storageImages;

  /// No description provided for @storageSnapshots.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard & last Practice'**
  String get storageSnapshots;

  /// No description provided for @storageTemporaryAudio.
  ///
  /// In en, this message translates to:
  /// **'Temporary Practice audio'**
  String get storageTemporaryAudio;

  /// No description provided for @storageAiChats.
  ///
  /// In en, this message translates to:
  /// **'AI chats & recordings'**
  String get storageAiChats;

  /// No description provided for @storageDm.
  ///
  /// In en, this message translates to:
  /// **'Direct messages & recordings'**
  String get storageDm;

  /// No description provided for @storagePractice.
  ///
  /// In en, this message translates to:
  /// **'Saved Practice & downloads'**
  String get storagePractice;

  /// No description provided for @storageOther.
  ///
  /// In en, this message translates to:
  /// **'Settings & other local files'**
  String get storageOther;

  /// No description provided for @storageScope.
  ///
  /// In en, this message translates to:
  /// **'Measured app files only. App installation and system-managed language models are not included. Files in use may remain cached.'**
  String get storageScope;

  /// No description provided for @storageClearExplanation.
  ///
  /// In en, this message translates to:
  /// **'Remove replaceable cached files? Images and Practice content can download again. Your recordings, conversations, saved practices, downloads and settings will be kept.'**
  String get storageClearExplanation;

  /// No description provided for @storagePrivacy.
  ///
  /// In en, this message translates to:
  /// **'We store data on your device where possible. AI requests, messaging, uploads and progress sync still send the data needed for those features. Clearing cache does not delete your account or server data.'**
  String get storagePrivacy;

  /// No description provided for @storageError.
  ///
  /// In en, this message translates to:
  /// **'Some storage could not be read or cleared. Please try again.'**
  String get storageError;

  /// No description provided for @storageManageAi.
  ///
  /// In en, this message translates to:
  /// **'To clear these, open the AI chat menu and choose “{action}”.'**
  String storageManageAi(String action);

  /// No description provided for @storageManageDm.
  ///
  /// In en, this message translates to:
  /// **'To remove these, open the conversation menu and choose “{action}”.'**
  String storageManageDm(String action);

  /// No description provided for @storageManagePractice.
  ///
  /// In en, this message translates to:
  /// **'To remove saved practices or downloads, delete the corresponding saved items.'**
  String get storageManagePractice;

  /// No description provided for @aiClearAudioTitle.
  ///
  /// In en, this message translates to:
  /// **'Audio only'**
  String get aiClearAudioTitle;

  /// No description provided for @aiClearAudioBody.
  ///
  /// In en, this message translates to:
  /// **'Remove your recordings and AI audio. Keep messages, transcripts and images.'**
  String get aiClearAudioBody;

  /// No description provided for @aiClearAllTitle.
  ///
  /// In en, this message translates to:
  /// **'All messages and audio'**
  String get aiClearAllTitle;

  /// No description provided for @aiClearAllBody.
  ///
  /// In en, this message translates to:
  /// **'Remove this chat’s messages, transcripts, recordings and attachments.'**
  String get aiClearAllBody;

  /// No description provided for @aiKeepSummary.
  ///
  /// In en, this message translates to:
  /// **'Keep the last summary'**
  String get aiKeepSummary;

  /// No description provided for @aiKeepSummaryBody.
  ///
  /// In en, this message translates to:
  /// **'Keep the latest saved summary as AI memory. Recent messages may not be included.'**
  String get aiKeepSummaryBody;

  /// No description provided for @aiNoSummary.
  ///
  /// In en, this message translates to:
  /// **'No saved summary yet.'**
  String get aiNoSummary;

  /// No description provided for @aiClearFreed.
  ///
  /// In en, this message translates to:
  /// **'Estimated space freed: {size}'**
  String aiClearFreed(String size);

  /// No description provided for @aiClearNotice.
  ///
  /// In en, this message translates to:
  /// **'This ends any current AI call. Vocabulary and scheduled reminders stay unchanged.'**
  String get aiClearNotice;

  /// No description provided for @clearAllLabel.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAllLabel;

  /// No description provided for @aiRemindersClearBody.
  ///
  /// In en, this message translates to:
  /// **'Remove all reminders, including scheduled ones? Pending reminders will be cancelled on the server.'**
  String get aiRemindersClearBody;

  /// No description provided for @aiRemindersRetained.
  ///
  /// In en, this message translates to:
  /// **'Some reminders could not be removed and remain here. A call already ringing cannot be cancelled here.'**
  String get aiRemindersRetained;

  /// No description provided for @vocabClearBody.
  ///
  /// In en, this message translates to:
  /// **'Delete all saved vocabulary words and their review progress, including words hidden by your current filter? This cannot be undone.'**
  String get vocabClearBody;

  /// No description provided for @vocabReviewHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Why are words due for review?'**
  String get vocabReviewHelpTitle;

  /// No description provided for @vocabReviewHelpBody.
  ///
  /// In en, this message translates to:
  /// **'Bantera uses spaced repetition: reviewing a word again after a gap can help you remember it longer. This relates to the forgetting curve, which describes how memory can fade over time.\n\nOur schedule:\n• First review: 1 day after saving.\n• After successive reviews: 3, 7, 14, then 30 days.\n• Later reviews stay 30 days apart.\n\nA word is due when its scheduled date arrives. Marking it reviewed starts the next interval from that review. This is a fixed schedule, not a measurement of your memory or a prediction that you have forgotten the word.'**
  String get vocabReviewHelpBody;

  /// No description provided for @leaderboardRollingFootnote.
  ///
  /// In en, this message translates to:
  /// **'Periods end at the latest refresh. Times are local. Offline words appear after syncing. Older app versions may omit activity near the start and end of the period because exact times were not recorded.'**
  String get leaderboardRollingFootnote;

  /// No description provided for @leaderboardPeriodFootnote.
  ///
  /// In en, this message translates to:
  /// **'Equal totals share a rank. Dates are in UTC. Offline words appear after syncing.'**
  String get leaderboardPeriodFootnote;

  /// No description provided for @leaderboardOpenChat.
  ///
  /// In en, this message translates to:
  /// **'Open a direct chat with {name}?'**
  String leaderboardOpenChat(String name);

  /// No description provided for @chatDeleteReceivedBody.
  ///
  /// In en, this message translates to:
  /// **'This message will be removed from this device only. The other person’s copy will stay.'**
  String get chatDeleteReceivedBody;

  /// No description provided for @adminDeletePractice.
  ///
  /// In en, this message translates to:
  /// **'Delete practice'**
  String get adminDeletePractice;

  /// No description provided for @adminDeleteDialogue.
  ///
  /// In en, this message translates to:
  /// **'Delete dialogue'**
  String get adminDeleteDialogue;

  /// No description provided for @adminDeleteContentBody.
  ///
  /// In en, this message translates to:
  /// **'Delete this content from the server for everyone? This cannot be undone. Previously downloaded copies may remain on devices.'**
  String get adminDeleteContentBody;

  /// No description provided for @widgetAdd.
  ///
  /// In en, this message translates to:
  /// **'Add a widget'**
  String get widgetAdd;

  /// No description provided for @widgetSuggestionTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep your progress in sight'**
  String get widgetSuggestionTitle;

  /// No description provided for @widgetSuggestionBody.
  ///
  /// In en, this message translates to:
  /// **'See your daily goal and leaderboard position on your Home Screen.'**
  String get widgetSuggestionBody;

  /// No description provided for @widgetHowTo.
  ///
  /// In en, this message translates to:
  /// **'How to add a widget'**
  String get widgetHowTo;

  /// No description provided for @widgetNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get widgetNotNow;

  /// No description provided for @widgetHideTitle.
  ///
  /// In en, this message translates to:
  /// **'Hide widget suggestion?'**
  String get widgetHideTitle;

  /// No description provided for @widgetHideBody.
  ///
  /// In en, this message translates to:
  /// **'You can still find widget instructions in Settings.'**
  String get widgetHideBody;

  /// No description provided for @widgetDontShowAgain.
  ///
  /// In en, this message translates to:
  /// **'Don’t show again'**
  String get widgetDontShowAgain;

  /// No description provided for @widgetSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save your choice. Please try again.'**
  String get widgetSaveFailed;

  /// No description provided for @widgetSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get widgetSmall;

  /// No description provided for @widgetMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get widgetMedium;

  /// No description provided for @widgetLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get widgetLarge;

  /// No description provided for @widgetExtraLarge.
  ///
  /// In en, this message translates to:
  /// **'Extra large'**
  String get widgetExtraLarge;

  /// No description provided for @widgetStepHold.
  ///
  /// In en, this message translates to:
  /// **'On your Home Screen, touch and hold an empty area until the apps jiggle.'**
  String get widgetStepHold;

  /// No description provided for @widgetStepEdit.
  ///
  /// In en, this message translates to:
  /// **'Choose Edit → Add Widget. On earlier iOS or iPadOS versions, tap the + button instead.'**
  String get widgetStepEdit;

  /// No description provided for @widgetStepSearch.
  ///
  /// In en, this message translates to:
  /// **'Search for Bantera and choose the Daily practice widget.'**
  String get widgetStepSearch;

  /// No description provided for @widgetStepAdd.
  ///
  /// In en, this message translates to:
  /// **'Swipe to select a size, tap Add Widget, then tap Done.'**
  String get widgetStepAdd;

  /// No description provided for @widgetPreviewDescription.
  ///
  /// In en, this message translates to:
  /// **'Actual widget preview with example progress.'**
  String get widgetPreviewDescription;

  /// No description provided for @widgetPreviewRetry.
  ///
  /// In en, this message translates to:
  /// **'Reload preview'**
  String get widgetPreviewRetry;

  /// No description provided for @widgetLocalNote.
  ///
  /// In en, this message translates to:
  /// **'You add the widget from your Home Screen. Bantera checks its configuration when you return; it does not track how often you view it.'**
  String get widgetLocalNote;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'id',
    'it',
    'ja',
    'ko',
    'pl',
    'pt',
    'ru',
    'th',
    'tr',
    'uk',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'th':
      return AppLocalizationsTh();
    case 'tr':
      return AppLocalizationsTr();
    case 'uk':
      return AppLocalizationsUk();
    case 'vi':
      return AppLocalizationsVi();
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
