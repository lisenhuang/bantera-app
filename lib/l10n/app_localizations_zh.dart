// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Bantera';

  @override
  String get appTagline => '语言练习，逐句进行。';

  @override
  String get authContinueWithApple => '通过 Apple 继续';

  @override
  String get authAppleUnavailable => '此设备无法使用“通过 Apple 登录”。';

  @override
  String get authOrSignInEmail => '或使用邮箱登录';

  @override
  String get authEmail => '邮箱';

  @override
  String get authPassword => '密码';

  @override
  String get authSigningIn => '正在登录…';

  @override
  String get authSignIn => '登录';

  @override
  String get authSignInWithEmail => '使用邮箱登录';

  @override
  String get validationEnterEmail => '请输入邮箱。';

  @override
  String get validationValidEmail => '请输入有效的邮箱地址。';

  @override
  String get validationEnterPassword => '请输入密码。';

  @override
  String get onboardingTitle => '你在学习\n哪种语言？';

  @override
  String get onboardingSubtitle => '我们将据此为你展示合适的内容。';

  @override
  String get onboardingSearchHint => '搜索语言…';

  @override
  String get onboardingRetry => '重试';

  @override
  String get onboardingNoMatching => '没有匹配的语言。';

  @override
  String get onboardingFailedSave => '保存失败。';

  @override
  String get settingsTitle => '设置';

  @override
  String get sectionAppearance => '外观';

  @override
  String get sectionAccount => '账户';

  @override
  String get sectionLanguage => '语言';

  @override
  String get languageSectionSubtitle => '选择应用显示语言。“跟随系统”将使用设备的语言设置。';

  @override
  String get themeLabel => '主题';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get languageEnglish => '英语';

  @override
  String get languageChineseSimplified => '中文（简体）';

  @override
  String get languageKorean => '韩语';

  @override
  String get languageJapanese => '日语';

  @override
  String get signedOutLabel => '未登录';

  @override
  String get noActiveSession => '没有有效的 Bantera 会话';

  @override
  String signedInWith(String provider) {
    return '已通过 $provider 登录';
  }

  @override
  String get editProfile => '编辑资料';

  @override
  String get more => '更多';

  @override
  String get signOut => '退出登录';

  @override
  String get signOutDialogTitle => '退出登录？';

  @override
  String get signOutDialogBody => '你需要重新登录才能使用账户。';

  @override
  String get cancel => '取消';

  @override
  String get navDiscover => '发现';

  @override
  String get navCreate => '创作';

  @override
  String get navProfile => '我的';

  @override
  String get chatsTitle => '聊天';

  @override
  String get savedTitle => '已保存';

  @override
  String get generateWithAiTitle => 'AI 生成';

  @override
  String get practiceLocalVideoTitle => '本地视频练习';

  @override
  String get uploadVideoTitle => '上传视频';

  @override
  String get lessonDetailsTitle => '课程详情';

  @override
  String get accountMoreTitle => '更多';

  @override
  String get deleteAccount => '删除账户';

  @override
  String get deleteAccountSubtitle => '永久删除你的账户与服务器数据';

  @override
  String get confirmDeletionTitle => '确认删除';

  @override
  String get deleteAccountImmediateBody => '你的账户将立即被删除。若要再次使用 Bantera，需要重新注册。';

  @override
  String get deleteAccountConfirm => '删除账户';

  @override
  String get couldNotDeleteAccount => '无法删除账户，请稍后重试。';

  @override
  String get deleteAccountQuestionTitle => '删除账户？';

  @override
  String get deleteAccountQuestionBody => '你的个人信息以及你生成的所有数据将从我们的服务器永久删除且无法恢复。';

  @override
  String get typeDeleteLabel => '输入「DELETE」以继续';

  @override
  String get continueLabel => '继续';
}

/// The translations for Chinese, as used in China (`zh_CN`).
class AppLocalizationsZhCn extends AppLocalizationsZh {
  AppLocalizationsZhCn() : super('zh_CN');

  @override
  String get appName => 'Bantera';

  @override
  String get appTagline => '语言练习，逐句进行。';

  @override
  String get authContinueWithApple => '通过 Apple 继续';

  @override
  String get authAppleUnavailable => '此设备无法使用“通过 Apple 登录”。';

  @override
  String get authOrSignInEmail => '或使用邮箱登录';

  @override
  String get authEmail => '邮箱';

  @override
  String get authPassword => '密码';

  @override
  String get authSigningIn => '正在登录…';

  @override
  String get authSignIn => '登录';

  @override
  String get authSignInWithEmail => '使用邮箱登录';

  @override
  String get validationEnterEmail => '请输入邮箱。';

  @override
  String get validationValidEmail => '请输入有效的邮箱地址。';

  @override
  String get validationEnterPassword => '请输入密码。';

  @override
  String get onboardingTitle => '你在学习\n哪种语言？';

  @override
  String get onboardingSubtitle => '我们将据此为你展示合适的内容。';

  @override
  String get onboardingSearchHint => '搜索语言…';

  @override
  String get onboardingRetry => '重试';

  @override
  String get onboardingNoMatching => '没有匹配的语言。';

  @override
  String get onboardingFailedSave => '保存失败。';

  @override
  String get settingsTitle => '设置';

  @override
  String get sectionAppearance => '外观';

  @override
  String get sectionAccount => '账户';

  @override
  String get sectionLanguage => '语言';

  @override
  String get languageSectionSubtitle => '选择应用显示语言。“跟随系统”将使用设备的语言设置。';

  @override
  String get themeLabel => '主题';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get languageEnglish => '英语';

  @override
  String get languageChineseSimplified => '中文（简体）';

  @override
  String get languageKorean => '韩语';

  @override
  String get languageJapanese => '日语';

  @override
  String get signedOutLabel => '未登录';

  @override
  String get noActiveSession => '没有有效的 Bantera 会话';

  @override
  String signedInWith(String provider) {
    return '已通过 $provider 登录';
  }

  @override
  String get editProfile => '编辑资料';

  @override
  String get more => '更多';

  @override
  String get signOut => '退出登录';

  @override
  String get signOutDialogTitle => '退出登录？';

  @override
  String get signOutDialogBody => '你需要重新登录才能使用账户。';

  @override
  String get cancel => '取消';

  @override
  String get navDiscover => '发现';

  @override
  String get navCreate => '创作';

  @override
  String get navProfile => '我的';

  @override
  String get chatsTitle => '聊天';

  @override
  String get savedTitle => '已保存';

  @override
  String get generateWithAiTitle => 'AI 生成';

  @override
  String get practiceLocalVideoTitle => '本地视频练习';

  @override
  String get uploadVideoTitle => '上传视频';

  @override
  String get lessonDetailsTitle => '课程详情';

  @override
  String get accountMoreTitle => '更多';

  @override
  String get deleteAccount => '删除账户';

  @override
  String get deleteAccountSubtitle => '永久删除你的账户与服务器数据';

  @override
  String get confirmDeletionTitle => '确认删除';

  @override
  String get deleteAccountImmediateBody => '你的账户将立即被删除。若要再次使用 Bantera，需要重新注册。';

  @override
  String get deleteAccountConfirm => '删除账户';

  @override
  String get couldNotDeleteAccount => '无法删除账户，请稍后重试。';

  @override
  String get deleteAccountQuestionTitle => '删除账户？';

  @override
  String get deleteAccountQuestionBody => '你的个人信息以及你生成的所有数据将从我们的服务器永久删除且无法恢复。';

  @override
  String get typeDeleteLabel => '输入「DELETE」以继续';

  @override
  String get continueLabel => '继续';
}
