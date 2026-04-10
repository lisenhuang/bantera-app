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

  @override
  String get confirmLabel => '确认';

  @override
  String get deleteLabel => '删除';

  @override
  String get startLabel => '开始';

  @override
  String get doneLabel => '完成';

  @override
  String get discoverSearchHint => '搜索标题或字幕…';

  @override
  String get discoverNoMoreResults => '没有更多了';

  @override
  String get discoverSetLearningLanguagePrompt => '设置学习语言以在此查看内容';

  @override
  String discoverNoPublicContentInLanguage(String language) {
    return '暂无 $language 的公开内容';
  }

  @override
  String get discoverSetLanguageToDiscover => '设置学习语言以发现内容';

  @override
  String get mediaStartPractice => '开始练习';

  @override
  String get mediaTranscript => '字幕稿';

  @override
  String mediaTranscriptLineCount(int count) {
    return '（$count 行）';
  }

  @override
  String get mediaShow => '显示';

  @override
  String get mediaHide => '隐藏';

  @override
  String get mediaNoTranscriptAvailable => '暂无字幕稿。';

  @override
  String get lessonSaveTooltip => '保存';

  @override
  String get lessonUnsaveTooltip => '取消保存';

  @override
  String get mediaKindAudio => '音频';

  @override
  String get mediaKindVideo => '视频';

  @override
  String get practiceNoCues => '没有分句';

  @override
  String get practiceTranslating => '翻译中…';

  @override
  String get practiceShowTranscript => '显示字幕稿';

  @override
  String get practiceTranslate => '翻译';

  @override
  String get practiceHideText => '隐藏文字';

  @override
  String get practiceStop => '停止';

  @override
  String get practicePlayAll => '连续播放';

  @override
  String get practiceCompare => '对比';

  @override
  String get practiceStartOver => '重新开始';

  @override
  String get practiceTranscriptHidden => '字幕稿已隐藏';

  @override
  String get practiceListenCarefully => '请仔细听…';

  @override
  String get practiceTranslationUnavailableForCue => '暂时无法翻译此句。';

  @override
  String get practiceChooseTranslationLanguageTitle => '选择翻译语言';

  @override
  String get practiceChooseTranslationLanguageDescription =>
      'Bantera 会将听力练习翻译为所选语言，并保存到你的资料以便下次使用。';

  @override
  String get practiceChangeTranslationLanguageTitle => '更改翻译语言';

  @override
  String get practiceChangeTranslationLanguageDescription =>
      '选择 Bantera 应翻译成的语言。新选择将保存到你的资料。';

  @override
  String get practiceConfirmTranslationLanguageTitle => '确认翻译语言';

  @override
  String get practiceConfirmTranslationLanguageBody =>
      'Bantera 会将此语言保存到你的资料，并作为今后听力练习的默认翻译语言。';

  @override
  String get practiceCouldNotSaveTranslationLanguage => '无法保存翻译语言。';

  @override
  String get practiceNoTranslationLanguagesFound => '找不到可用于此字幕稿的翻译语言。';

  @override
  String get practicePlayAllTitle => '连续播放';

  @override
  String get practicePlayAllDescription => '分句之间暂停，便于跟读（无需重复点击）：';

  @override
  String get practicePlayAllPauseNoneTitle => '无额外暂停（0 秒）';

  @override
  String get practicePlayAllPauseNoneSubtitle => '连续播放整段音频';

  @override
  String get practicePlayAllPauseOneSecond => '1 秒';

  @override
  String get practicePlayAllPauseOneCueTitle => '1× 分句时长';

  @override
  String get practicePlayAllPauseOneCueSubtitle => '暂停时长与刚播放的分句相同';

  @override
  String get practicePlayAllPauseTwoCuesTitle => '2× 分句时长';

  @override
  String get practicePlayAllPauseTwoCuesSubtitle => '暂停时长为刚播放分句的两倍';

  @override
  String get practiceSearchLanguagesHint => '搜索语言';

  @override
  String get practiceTranslationInstalled => '已安装';

  @override
  String get practiceTranslationDownload => '下载';

  @override
  String get practiceStartOverTitle => '重新开始？';

  @override
  String get practiceStartOverBody => '返回第一句？';

  @override
  String get practiceVideoOpenError => '无法打开所选视频进行练习。';

  @override
  String practiceAudioError(String message) {
    return '音频错误：$message';
  }

  @override
  String get compareRecordYourVersion => '录制你的版本';

  @override
  String compareTranscriptionLanguage(String locale) {
    return '转写语言：$locale';
  }

  @override
  String get compareOpenIphoneSettings => '打开 iPhone 设置';

  @override
  String get comparePauseAttempt => '暂停录音';

  @override
  String get comparePlayAttempt => '播放录音';

  @override
  String get compareYourTranscribedAttempt => '你的转写结果';

  @override
  String get compareHighlightHint => 'Bantera 识别不同的词会高亮显示。';

  @override
  String get compareTryAgain => '重试';

  @override
  String get compareDone => '完成';

  @override
  String get compareStatusTranscribing => '正在本机转写你的录音…';

  @override
  String get compareStatusRecording => '录音中…再次点击停止。';

  @override
  String get compareStatusSavedAttempt => '正在显示本句已保存的尝试。可重播或再试一次。';

  @override
  String get compareStatusReplayOrRetry => '可重播此次录音或再练本句。';

  @override
  String get compareStatusTapToRecord => '点击开始录制本句。';

  @override
  String get compareCouldNotStartRecording => '暂时无法开始录音。';

  @override
  String get compareCouldNotAccessRecording => '无法访问已录制的音频。';

  @override
  String get compareNoTranscriptGenerated => '无法为此尝试生成转写。请靠近麦克风再试。';

  @override
  String get compareRecentAttempts => '最近尝试';

  @override
  String get compareAttemptsFooterNote => 'Bantera 在本机保存你的尝试，便于在同一分句上查看进步。';

  @override
  String compareMatchedCount(int count) {
    return '$count 处匹配';
  }

  @override
  String compareDifferentCount(int count) {
    return '$count 处不同';
  }

  @override
  String compareMissingCount(int count) {
    return '$count 处缺失';
  }

  @override
  String get compareMicrophoneDeniedPermanent =>
      '已关闭 Bantera 的麦克风权限。请打开 iPhone 设置 > Bantera > 麦克风并开启，以录制你的版本。';

  @override
  String get compareMicrophoneDeniedRestricted =>
      '本机正在限制 Bantera 使用麦克风。请检查屏幕使用时间、设备管理或系统设置。';

  @override
  String get compareMicrophoneDeniedDefault =>
      '需要麦克风权限才能录制你的版本。若之前关闭了提示，请打开 iPhone 设置 > Bantera > 麦克风并开启。';

  @override
  String get comparePlayAttemptTooltip => '播放录音';

  @override
  String get comparePauseAttemptTooltip => '暂停录音';

  @override
  String get createWhatToday => '今天想做些什么？';

  @override
  String get createPracticeVideo => '练习视频';

  @override
  String get createYourMedia => '我的媒体';

  @override
  String get createTryAgain => '重试';

  @override
  String get createUploadedVideosEmptyHint => '你上传的视频会显示在这里，可随时打开并逐句练习。';

  @override
  String get createUploadingTips => '上传提示';

  @override
  String get createUploadingTipsBody => '为获得更好效果，请将音频控制在 3 分钟以内。系统会自动生成清晰字幕！';

  @override
  String get createOnThisIphone => '本机上的视频';

  @override
  String get createLocalVideosEmptyHint =>
      '在本机练习的视频会保存在此 iPhone，之后可再次打开而无需重新转写。';

  @override
  String get createOnDeviceBadge => '本机';

  @override
  String get createSignInToLoadVideos => '请重新登录以加载已上传的视频。';

  @override
  String createVideoMetaCues(int count) {
    return '$count 句';
  }

  @override
  String get createPublicBadge => '公开';

  @override
  String get createPrivateBadge => '非公开';

  @override
  String get createAiBadge => 'AI';

  @override
  String get createDeleteSavedVideoTitle => '删除已保存的视频？';

  @override
  String createDeleteSavedVideoBody(String title) {
    return 'Bantera 将从本机移除「$title」并删除已保存的字幕分句。';
  }

  @override
  String get createDeleteMediaTitle => '删除媒体？';

  @override
  String createDeleteMediaBody(String title) {
    return '将永久删除「$title」及其字幕稿，此操作无法撤销。';
  }

  @override
  String get editProfileChangeImage => '更换头像';

  @override
  String get editProfileUploading => '上传中…';

  @override
  String get editProfileNameLabel => '姓名';

  @override
  String get editProfileNameHint => 'Bantera 应如何显示你的姓名？';

  @override
  String get editProfileSaveNameButton => '保存姓名';

  @override
  String get editProfileSaving => '保存中…';

  @override
  String get editProfileLanguagesSection => '语言';

  @override
  String get editProfileMyNativeLanguage => '我的母语';

  @override
  String get editProfileMyNativeLanguageSubtitle => '你的母语或第一语言';

  @override
  String get editProfileLearningLanguage => '学习语言';

  @override
  String get editProfileLearningLanguageSubtitle => '你想练习的语言';

  @override
  String get editProfileImageUpdated => '头像已更新。';

  @override
  String get editProfileNameUpdated => '姓名已更新。';

  @override
  String get editProfileEnterName => '请输入姓名。';

  @override
  String get editProfileNameMaxLength => '请使用不超过 80 个字符。';

  @override
  String get editProfileCouldNotLoadLanguages => '无法加载语言列表。';

  @override
  String get languagePickerNone => '无';

  @override
  String get languagePickerClearSelection => '清除选择';

  @override
  String get languagePickerNoMatchingLanguages => '未找到语言。';

  @override
  String get editProfileNativeLanguageCleared => '已清除母语。';

  @override
  String get editProfileLearningLanguageCleared => '已清除学习语言。';

  @override
  String editProfileNativeLanguageSetTo(String language) {
    return '母语已设为 $language。';
  }

  @override
  String editProfileLearningLanguageSetTo(String language) {
    return '学习语言已设为 $language。';
  }

  @override
  String get profileLanguageSettings => '语言设置';

  @override
  String get profileLearningLabel => '学习';

  @override
  String get profileNotSet => '未设置';

  @override
  String get uploadedDetailYourAudio => '你的音频';

  @override
  String get uploadedDetailYourVideo => '你的视频';

  @override
  String get uploadedDetailDeleteAudioTitle => '删除音频？';

  @override
  String get uploadedDetailDeleteAudioBody => '将永久删除此音频及其字幕稿，无法撤销。';

  @override
  String get uploadedDetailDeleteVideoTitle => '删除视频？';

  @override
  String get uploadedDetailDeleteVideoBody => '将永久删除此视频及其字幕稿，无法撤销。';

  @override
  String get uploadedDetailAiGenerated => 'AI 生成';

  @override
  String get uploadedDetailFileSize => '文件大小';

  @override
  String get uploadedDetailResolution => '分辨率';

  @override
  String get uploadedDetailResolutionUnknown => '未知';

  @override
  String get uploadedDetailTranscribing => '转写中…';

  @override
  String get uploadedDetailNoTranscriptCuesYet => '暂无字幕分句。';

  @override
  String uploadedDetailMediaDescription(int count) {
    return '你上传的练习片段，包含 $count 条字幕分句。';
  }

  @override
  String get uploadedDetailTranscriptionFailedFallback => '转写失败，正使用估算分句。';

  @override
  String get uploadedDetailTranscriptionNoCues => '转写未返回任何分句。';

  @override
  String get uploadedDetailTranscriptionSourceYourUpload => '你的上传';
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

  @override
  String get confirmLabel => '确认';

  @override
  String get deleteLabel => '删除';

  @override
  String get startLabel => '开始';

  @override
  String get doneLabel => '完成';

  @override
  String get discoverSearchHint => '搜索标题或字幕…';

  @override
  String get discoverNoMoreResults => '没有更多了';

  @override
  String get discoverSetLearningLanguagePrompt => '设置学习语言以在此查看内容';

  @override
  String discoverNoPublicContentInLanguage(String language) {
    return '暂无 $language 的公开内容';
  }

  @override
  String get discoverSetLanguageToDiscover => '设置学习语言以发现内容';

  @override
  String get mediaStartPractice => '开始练习';

  @override
  String get mediaTranscript => '字幕稿';

  @override
  String mediaTranscriptLineCount(int count) {
    return '（$count 行）';
  }

  @override
  String get mediaShow => '显示';

  @override
  String get mediaHide => '隐藏';

  @override
  String get mediaNoTranscriptAvailable => '暂无字幕稿。';

  @override
  String get lessonSaveTooltip => '保存';

  @override
  String get lessonUnsaveTooltip => '取消保存';

  @override
  String get mediaKindAudio => '音频';

  @override
  String get mediaKindVideo => '视频';

  @override
  String get practiceNoCues => '没有分句';

  @override
  String get practiceTranslating => '翻译中…';

  @override
  String get practiceShowTranscript => '显示字幕稿';

  @override
  String get practiceTranslate => '翻译';

  @override
  String get practiceHideText => '隐藏文字';

  @override
  String get practiceStop => '停止';

  @override
  String get practicePlayAll => '连续播放';

  @override
  String get practiceCompare => '对比';

  @override
  String get practiceStartOver => '重新开始';

  @override
  String get practiceTranscriptHidden => '字幕稿已隐藏';

  @override
  String get practiceListenCarefully => '请仔细听…';

  @override
  String get practiceTranslationUnavailableForCue => '暂时无法翻译此句。';

  @override
  String get practiceChooseTranslationLanguageTitle => '选择翻译语言';

  @override
  String get practiceChooseTranslationLanguageDescription =>
      'Bantera 会将听力练习翻译为所选语言，并保存到你的资料以便下次使用。';

  @override
  String get practiceChangeTranslationLanguageTitle => '更改翻译语言';

  @override
  String get practiceChangeTranslationLanguageDescription =>
      '选择 Bantera 应翻译成的语言。新选择将保存到你的资料。';

  @override
  String get practiceConfirmTranslationLanguageTitle => '确认翻译语言';

  @override
  String get practiceConfirmTranslationLanguageBody =>
      'Bantera 会将此语言保存到你的资料，并作为今后听力练习的默认翻译语言。';

  @override
  String get practiceCouldNotSaveTranslationLanguage => '无法保存翻译语言。';

  @override
  String get practiceNoTranslationLanguagesFound => '找不到可用于此字幕稿的翻译语言。';

  @override
  String get practicePlayAllTitle => '连续播放';

  @override
  String get practicePlayAllDescription => '分句之间暂停，便于跟读（无需重复点击）：';

  @override
  String get practicePlayAllPauseNoneTitle => '无额外暂停（0 秒）';

  @override
  String get practicePlayAllPauseNoneSubtitle => '连续播放整段音频';

  @override
  String get practicePlayAllPauseOneSecond => '1 秒';

  @override
  String get practicePlayAllPauseOneCueTitle => '1× 分句时长';

  @override
  String get practicePlayAllPauseOneCueSubtitle => '暂停时长与刚播放的分句相同';

  @override
  String get practicePlayAllPauseTwoCuesTitle => '2× 分句时长';

  @override
  String get practicePlayAllPauseTwoCuesSubtitle => '暂停时长为刚播放分句的两倍';

  @override
  String get practiceSearchLanguagesHint => '搜索语言';

  @override
  String get practiceTranslationInstalled => '已安装';

  @override
  String get practiceTranslationDownload => '下载';

  @override
  String get practiceStartOverTitle => '重新开始？';

  @override
  String get practiceStartOverBody => '返回第一句？';

  @override
  String get practiceVideoOpenError => '无法打开所选视频进行练习。';

  @override
  String practiceAudioError(String message) {
    return '音频错误：$message';
  }

  @override
  String get compareRecordYourVersion => '录制你的版本';

  @override
  String compareTranscriptionLanguage(String locale) {
    return '转写语言：$locale';
  }

  @override
  String get compareOpenIphoneSettings => '打开 iPhone 设置';

  @override
  String get comparePauseAttempt => '暂停录音';

  @override
  String get comparePlayAttempt => '播放录音';

  @override
  String get compareYourTranscribedAttempt => '你的转写结果';

  @override
  String get compareHighlightHint => 'Bantera 识别不同的词会高亮显示。';

  @override
  String get compareTryAgain => '重试';

  @override
  String get compareDone => '完成';

  @override
  String get compareStatusTranscribing => '正在本机转写你的录音…';

  @override
  String get compareStatusRecording => '录音中…再次点击停止。';

  @override
  String get compareStatusSavedAttempt => '正在显示本句已保存的尝试。可重播或再试一次。';

  @override
  String get compareStatusReplayOrRetry => '可重播此次录音或再练本句。';

  @override
  String get compareStatusTapToRecord => '点击开始录制本句。';

  @override
  String get compareCouldNotStartRecording => '暂时无法开始录音。';

  @override
  String get compareCouldNotAccessRecording => '无法访问已录制的音频。';

  @override
  String get compareNoTranscriptGenerated => '无法为此尝试生成转写。请靠近麦克风再试。';

  @override
  String get compareRecentAttempts => '最近尝试';

  @override
  String get compareAttemptsFooterNote => 'Bantera 在本机保存你的尝试，便于在同一分句上查看进步。';

  @override
  String compareMatchedCount(int count) {
    return '$count 处匹配';
  }

  @override
  String compareDifferentCount(int count) {
    return '$count 处不同';
  }

  @override
  String compareMissingCount(int count) {
    return '$count 处缺失';
  }

  @override
  String get compareMicrophoneDeniedPermanent =>
      '已关闭 Bantera 的麦克风权限。请打开 iPhone 设置 > Bantera > 麦克风并开启，以录制你的版本。';

  @override
  String get compareMicrophoneDeniedRestricted =>
      '本机正在限制 Bantera 使用麦克风。请检查屏幕使用时间、设备管理或系统设置。';

  @override
  String get compareMicrophoneDeniedDefault =>
      '需要麦克风权限才能录制你的版本。若之前关闭了提示，请打开 iPhone 设置 > Bantera > 麦克风并开启。';

  @override
  String get comparePlayAttemptTooltip => '播放录音';

  @override
  String get comparePauseAttemptTooltip => '暂停录音';

  @override
  String get createWhatToday => '今天想做些什么？';

  @override
  String get createPracticeVideo => '练习视频';

  @override
  String get createYourMedia => '我的媒体';

  @override
  String get createTryAgain => '重试';

  @override
  String get createUploadedVideosEmptyHint => '你上传的视频会显示在这里，可随时打开并逐句练习。';

  @override
  String get createUploadingTips => '上传提示';

  @override
  String get createUploadingTipsBody => '为获得更好效果，请将音频控制在 3 分钟以内。系统会自动生成清晰字幕！';

  @override
  String get createOnThisIphone => '本机上的视频';

  @override
  String get createLocalVideosEmptyHint =>
      '在本机练习的视频会保存在此 iPhone，之后可再次打开而无需重新转写。';

  @override
  String get createOnDeviceBadge => '本机';

  @override
  String get createSignInToLoadVideos => '请重新登录以加载已上传的视频。';

  @override
  String createVideoMetaCues(int count) {
    return '$count 句';
  }

  @override
  String get createPublicBadge => '公开';

  @override
  String get createPrivateBadge => '非公开';

  @override
  String get createAiBadge => 'AI';

  @override
  String get createDeleteSavedVideoTitle => '删除已保存的视频？';

  @override
  String createDeleteSavedVideoBody(String title) {
    return 'Bantera 将从本机移除「$title」并删除已保存的字幕分句。';
  }

  @override
  String get createDeleteMediaTitle => '删除媒体？';

  @override
  String createDeleteMediaBody(String title) {
    return '将永久删除「$title」及其字幕稿，此操作无法撤销。';
  }

  @override
  String get editProfileChangeImage => '更换头像';

  @override
  String get editProfileUploading => '上传中…';

  @override
  String get editProfileNameLabel => '姓名';

  @override
  String get editProfileNameHint => 'Bantera 应如何显示你的姓名？';

  @override
  String get editProfileSaveNameButton => '保存姓名';

  @override
  String get editProfileSaving => '保存中…';

  @override
  String get editProfileLanguagesSection => '语言';

  @override
  String get editProfileMyNativeLanguage => '我的母语';

  @override
  String get editProfileMyNativeLanguageSubtitle => '你的母语或第一语言';

  @override
  String get editProfileLearningLanguage => '学习语言';

  @override
  String get editProfileLearningLanguageSubtitle => '你想练习的语言';

  @override
  String get editProfileImageUpdated => '头像已更新。';

  @override
  String get editProfileNameUpdated => '姓名已更新。';

  @override
  String get editProfileEnterName => '请输入姓名。';

  @override
  String get editProfileNameMaxLength => '请使用不超过 80 个字符。';

  @override
  String get editProfileCouldNotLoadLanguages => '无法加载语言列表。';

  @override
  String get languagePickerNone => '无';

  @override
  String get languagePickerClearSelection => '清除选择';

  @override
  String get languagePickerNoMatchingLanguages => '未找到语言。';

  @override
  String get editProfileNativeLanguageCleared => '已清除母语。';

  @override
  String get editProfileLearningLanguageCleared => '已清除学习语言。';

  @override
  String editProfileNativeLanguageSetTo(String language) {
    return '母语已设为 $language。';
  }

  @override
  String editProfileLearningLanguageSetTo(String language) {
    return '学习语言已设为 $language。';
  }

  @override
  String get profileLanguageSettings => '语言设置';

  @override
  String get profileLearningLabel => '学习';

  @override
  String get profileNotSet => '未设置';

  @override
  String get uploadedDetailYourAudio => '你的音频';

  @override
  String get uploadedDetailYourVideo => '你的视频';

  @override
  String get uploadedDetailDeleteAudioTitle => '删除音频？';

  @override
  String get uploadedDetailDeleteAudioBody => '将永久删除此音频及其字幕稿，无法撤销。';

  @override
  String get uploadedDetailDeleteVideoTitle => '删除视频？';

  @override
  String get uploadedDetailDeleteVideoBody => '将永久删除此视频及其字幕稿，无法撤销。';

  @override
  String get uploadedDetailAiGenerated => 'AI 生成';

  @override
  String get uploadedDetailFileSize => '文件大小';

  @override
  String get uploadedDetailResolution => '分辨率';

  @override
  String get uploadedDetailResolutionUnknown => '未知';

  @override
  String get uploadedDetailTranscribing => '转写中…';

  @override
  String get uploadedDetailNoTranscriptCuesYet => '暂无字幕分句。';

  @override
  String uploadedDetailMediaDescription(int count) {
    return '你上传的练习片段，包含 $count 条字幕分句。';
  }

  @override
  String get uploadedDetailTranscriptionFailedFallback => '转写失败，正使用估算分句。';

  @override
  String get uploadedDetailTranscriptionNoCues => '转写未返回任何分句。';

  @override
  String get uploadedDetailTranscriptionSourceYourUpload => '你的上传';
}
