// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'Bantera';

  @override
  String get appTagline => '言語練習を、キューごとに。';

  @override
  String get authContinueWithApple => 'Appleで続行';

  @override
  String get authAppleUnavailable => 'このデバイスではAppleでサインインを利用できません。';

  @override
  String get authOrSignInEmail => 'またはメールでサインイン';

  @override
  String get authEmail => 'メール';

  @override
  String get authPassword => 'パスワード';

  @override
  String get authSigningIn => 'サインイン中…';

  @override
  String get authSignIn => 'サインイン';

  @override
  String get authSignInWithEmail => 'メールでサインイン';

  @override
  String get validationEnterEmail => 'メールアドレスを入力してください。';

  @override
  String get validationValidEmail => '有効なメールアドレスを入力してください。';

  @override
  String get validationEnterPassword => 'パスワードを入力してください。';

  @override
  String get onboardingTitle => '学習中の言語は\n何ですか？';

  @override
  String get onboardingSubtitle => '適切なコンテンツを表示するために使います。';

  @override
  String get onboardingSearchHint => '言語を検索…';

  @override
  String get onboardingRetry => '再試行';

  @override
  String get onboardingNoMatching => '一致する言語がありません。';

  @override
  String get onboardingFailedSave => '保存に失敗しました。';

  @override
  String get settingsTitle => '設定';

  @override
  String get sectionAppearance => '外観';

  @override
  String get sectionAccount => 'アカウント';

  @override
  String get sectionLanguage => '言語';

  @override
  String get languageSectionSubtitle => 'アプリの表示言語を選びます。「システムに合わせる」は端末の設定に従います。';

  @override
  String get themeLabel => 'テーマ';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get themeSystem => 'システム';

  @override
  String get languageSystem => 'システムに合わせる';

  @override
  String get languageEnglish => '英語';

  @override
  String get languageChineseSimplified => '中国語（簡体字）';

  @override
  String get languageKorean => '韓国語';

  @override
  String get languageJapanese => '日本語';

  @override
  String get signedOutLabel => 'サインアウト済み';

  @override
  String get noActiveSession => '有効なBanteraセッションがありません';

  @override
  String signedInWith(String provider) {
    return '$providerでサインイン中';
  }

  @override
  String get editProfile => 'プロフィールを編集';

  @override
  String get more => 'その他';

  @override
  String get signOut => 'サインアウト';

  @override
  String get signOutDialogTitle => 'サインアウトしますか？';

  @override
  String get signOutDialogBody => '再度利用するにはサインインが必要です。';

  @override
  String get cancel => 'キャンセル';

  @override
  String get navDiscover => '発見';

  @override
  String get navCreate => '作成';

  @override
  String get navProfile => 'プロフィール';

  @override
  String get chatsTitle => 'チャット';

  @override
  String get savedTitle => '保存済み';

  @override
  String get generateWithAiTitle => 'AIで生成';

  @override
  String get practiceLocalVideoTitle => 'ローカル動画の練習';

  @override
  String get uploadVideoTitle => '動画をアップロード';

  @override
  String get lessonDetailsTitle => 'レッスン詳細';

  @override
  String get accountMoreTitle => 'その他';

  @override
  String get deleteAccount => 'アカウントを削除';

  @override
  String get deleteAccountSubtitle => 'アカウントとサーバーデータを完全に削除';

  @override
  String get confirmDeletionTitle => '削除の確認';

  @override
  String get deleteAccountImmediateBody =>
      'アカウントはすぐに削除されます。Banteraを再度使うには新しいアカウントが必要です。';

  @override
  String get deleteAccountConfirm => 'アカウントを削除';

  @override
  String get couldNotDeleteAccount => 'アカウントを削除できませんでした。もう一度お試しください。';

  @override
  String get deleteAccountQuestionTitle => 'アカウントを削除しますか？';

  @override
  String get deleteAccountQuestionBody => '個人情報と作成したデータはサーバーから完全に削除され、復元できません。';

  @override
  String get typeDeleteLabel => '続行するには「DELETE」と入力';

  @override
  String get continueLabel => '続行';
}
