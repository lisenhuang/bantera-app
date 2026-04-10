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
}
