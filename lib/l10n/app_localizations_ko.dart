// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => 'Bantera';

  @override
  String get appTagline => '언어 연습, 큐마다.';

  @override
  String get authContinueWithApple => 'Apple로 계속';

  @override
  String get authAppleUnavailable => '이 기기에서는 Apple로 로그인을 사용할 수 없습니다.';

  @override
  String get authOrSignInEmail => '또는 이메일로 로그인';

  @override
  String get authEmail => '이메일';

  @override
  String get authPassword => '비밀번호';

  @override
  String get authSigningIn => '로그인 중…';

  @override
  String get authSignIn => '로그인';

  @override
  String get authSignInWithEmail => '이메일로 로그인';

  @override
  String get validationEnterEmail => '이메일을 입력하세요.';

  @override
  String get validationValidEmail => '올바른 이메일을 입력하세요.';

  @override
  String get validationEnterPassword => '비밀번호를 입력하세요.';

  @override
  String get onboardingTitle => '어떤 언어를\n배우고 있나요?';

  @override
  String get onboardingSubtitle => '맞춤 콘텐츠를 보여 드리기 위해 사용합니다.';

  @override
  String get onboardingSearchHint => '언어 검색…';

  @override
  String get onboardingRetry => '다시 시도';

  @override
  String get onboardingNoMatching => '일치하는 언어가 없습니다.';

  @override
  String get onboardingFailedSave => '저장하지 못했습니다.';

  @override
  String get settingsTitle => '설정';

  @override
  String get sectionAppearance => '모양';

  @override
  String get sectionAccount => '계정';

  @override
  String get sectionLanguage => '언어';

  @override
  String get languageSectionSubtitle => '앱 표시 언어를 선택하세요. 시스템은 기기 설정을 따릅니다.';

  @override
  String get themeLabel => '테마';

  @override
  String get themeLight => '라이트';

  @override
  String get themeDark => '다크';

  @override
  String get themeSystem => '시스템';

  @override
  String get languageSystem => '시스템 기본값';

  @override
  String get languageEnglish => '영어';

  @override
  String get languageChineseSimplified => '중국어(간체)';

  @override
  String get languageKorean => '한국어';

  @override
  String get languageJapanese => '일본어';

  @override
  String get signedOutLabel => '로그아웃됨';

  @override
  String get noActiveSession => '활성 Bantera 세션이 없습니다';

  @override
  String signedInWith(String provider) {
    return '$provider(으)로 로그인함';
  }

  @override
  String get editProfile => '프로필 편집';

  @override
  String get more => '더보기';

  @override
  String get signOut => '로그아웃';

  @override
  String get signOutDialogTitle => '로그아웃할까요?';

  @override
  String get signOutDialogBody => '다시 사용하려면 로그인해야 합니다.';

  @override
  String get cancel => '취소';

  @override
  String get navDiscover => '탐색';

  @override
  String get navCreate => '만들기';

  @override
  String get navProfile => '프로필';

  @override
  String get chatsTitle => '채팅';

  @override
  String get savedTitle => '저장됨';

  @override
  String get generateWithAiTitle => 'AI로 생성';

  @override
  String get practiceLocalVideoTitle => '로컬 동영상 연습';

  @override
  String get uploadVideoTitle => '동영상 업로드';

  @override
  String get lessonDetailsTitle => '레슨 상세';

  @override
  String get accountMoreTitle => '더보기';

  @override
  String get deleteAccount => '계정 삭제';

  @override
  String get deleteAccountSubtitle => '계정과 서버 데이터를 영구적으로 삭제';

  @override
  String get confirmDeletionTitle => '삭제 확인';

  @override
  String get deleteAccountImmediateBody =>
      '계정이 즉시 삭제됩니다. Bantera를 다시 쓰려면 새 계정을 만들어야 합니다.';

  @override
  String get deleteAccountConfirm => '계정 삭제';

  @override
  String get couldNotDeleteAccount => '계정을 삭제할 수 없습니다. 다시 시도하세요.';

  @override
  String get deleteAccountQuestionTitle => '계정을 삭제할까요?';

  @override
  String get deleteAccountQuestionBody =>
      '개인 정보와 생성한 데이터가 서버에서 영구 삭제되며 복구할 수 없습니다.';

  @override
  String get typeDeleteLabel => '계속하려면 \"DELETE\"를 입력하세요';

  @override
  String get continueLabel => '계속';
}
