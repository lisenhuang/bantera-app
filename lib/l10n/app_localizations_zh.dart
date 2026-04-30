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
  String get sectionRateAndShare => '评分与分享';

  @override
  String get sectionLanguage => '显示语言';

  @override
  String get sectionPermissions => '权限';

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
  String get appPermissionsTitle => '应用权限';

  @override
  String get appPermissionsSubtitle => '查看 Bantera 在此设备上使用的访问权限。';

  @override
  String get permissionsIntro => 'Bantera 会使用这些设备设置来录音、比较语音并访问网络。';

  @override
  String get permissionsOpenSettings => '打开 iPhone 设置';

  @override
  String get permissionsRefresh => '刷新';

  @override
  String get permissionMicrophoneTitle => '麦克风';

  @override
  String get permissionMicrophoneDescription => '用于录制练习尝试和语音消息。';

  @override
  String get permissionSpeechTitle => '语音识别';

  @override
  String get permissionSpeechDescription => '用于转写练习录音和上传的音频。';

  @override
  String get permissionMobileDataTitle => '移动数据';

  @override
  String get permissionMobileDataDescription =>
      '用于在此 iPhone 未连接 Wi‑Fi 时使用 Bantera。';

  @override
  String get permissionStatusAllowed => '已允许';

  @override
  String get permissionStatusLimited => '受限';

  @override
  String get permissionStatusNotAllowed => '未允许';

  @override
  String get permissionStatusUnknown => '未知';

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
  String get savedTitle => '已保存媒体';

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
  String get deleteAccountQuestionBody => '您的所有个人信息和数据将从我们的服务器永久删除且无法恢复。';

  @override
  String get typeDeleteLabel => '输入「DELETE」以继续';

  @override
  String get continueLabel => '继续';

  @override
  String get confirmLabel => '确认';

  @override
  String get deleteLabel => '删除';

  @override
  String get removeFromListLabel => '从列表中移除';

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
  String get practiceTextLabel => '文字';

  @override
  String get practiceStop => '停止';

  @override
  String get practicePlayAll => '连续播放';

  @override
  String get practiceCompare => '对比';

  @override
  String get practiceRecord => '录音';

  @override
  String get practiceStopRecording => '停止';

  @override
  String get practiceRecords => '记录';

  @override
  String get practiceRecordsLocalOnlyFooter => '练习尝试仅保存在本设备，不会上传。';

  @override
  String get practiceRecordsEmpty => '此句暂无保存的尝试。';

  @override
  String get practiceRecordingProcessError => '处理录音时出错，请重试。';

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
  String get practicePlayAllDescription => '分句之间暂停，便于跟读：';

  @override
  String get practicePlayAllPauseZeroSeconds => '0 秒';

  @override
  String get practicePlayAllPauseOneSecondLabel => '1 秒';

  @override
  String get practicePlayAllPauseOneCuePlusOneSecond => '1 句 + 1 秒';

  @override
  String get practicePlayAllPauseOneCuePlusTwoSeconds => '1 句 + 2 秒';

  @override
  String get practicePlayAllTimesPerCueTitle => '每条播放次数';

  @override
  String get practicePlayAllTimesOnce => '1×';

  @override
  String get practicePlayAllTimesTwice => '2×';

  @override
  String get practicePlayAllTimesThrice => '3×';

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
  String get practiceNextFromLastTitle => '前往第一句？';

  @override
  String get practiceNextFromLastBody => '当前为最后一句，是否返回第一句？';

  @override
  String get practiceGoToFirstCue => '前往第一句';

  @override
  String get practiceVideoOpenError => '无法打开所选视频进行练习。';

  @override
  String get practiceAudioLoading => '正在加载音频…';

  @override
  String practiceAudioLoadingPercent(int percent) {
    return '正在加载音频 $percent%';
  }

  @override
  String get practiceAudioError => '无法加载音频，请重试。';

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
  String get compareSpeechRecognitionDeniedPermanent =>
      '已关闭 Bantera 的语音识别权限。请打开 iPhone 设置 > Bantera > 语音识别并开启，以比较你的录音。';

  @override
  String get compareSpeechRecognitionDeniedRestricted =>
      '本机正在限制 Bantera 使用语音识别。请检查屏幕使用时间、设备管理或系统设置。';

  @override
  String get compareSpeechRecognitionUnavailable => '此 iPhone 暂时无法使用语音识别。';

  @override
  String get compareSpeechRecognitionUnsupportedLocale =>
      '此 iPhone 暂不支持当前练习语言的语音识别。';

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
  String get removeFromListTitle => '从列表中移除？';

  @override
  String get removeFromListBody => '此项目将从列表中移除，且无法撤销。';

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
  String get languagePickerMoreComingSoon => '更多语言支持即将推出';

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

  @override
  String get aiGenLeaveTitle => '离开此页面？';

  @override
  String get aiGenLeaveBody => '音频正在生成中。现在离开将取消该过程。';

  @override
  String get aiGenStay => '留在本页';

  @override
  String get aiGenLeave => '离开';

  @override
  String get aiGenLoadingTitle => '正在创建你的音频…';

  @override
  String get aiGenLoadingSubtitle => '这可能需要约一分钟。\n生成期间请保持在此页面。';

  @override
  String get aiGenStepPreparingSpeechModel => '正在准备设备端语音模型';

  @override
  String get aiGenStepWritingDialogue => '撰写对白';

  @override
  String get aiGenStepGeneratingAudio => '生成音频';

  @override
  String get aiGenStepAligningAudio => '对齐音频';

  @override
  String get aiGenStepTranscribing => '转写';

  @override
  String get aiGenStepCorrectingTranscript => '校正字幕';

  @override
  String get aiGenLanguageSection => '语言';

  @override
  String get aiGenSetLearningLanguagePrompt => '请设置学习语言以启用生成';

  @override
  String get aiGenLoadingLanguage => '正在加载语言…';

  @override
  String aiGenLanguageUnsupported(String language) {
    return '语言「$language」暂不支持生成。';
  }

  @override
  String get aiGenScenarioSection => '场景';

  @override
  String get aiGenScenarioOptionalHint => '可选 — 不选则随机场景。';

  @override
  String get aiGenCustomScenarioHint => '描述你的场景…';

  @override
  String get aiGenDurationSection => '时长';

  @override
  String aiGenDurationMinutes(int minutes) {
    return '$minutes 分钟';
  }

  @override
  String get aiGenGenerateButton => '生成';

  @override
  String get aiGenOwnershipNotice =>
      '您在此生成的音频将成为 Bantera 社区内容——作为练习素材公开共享，供所有学习者使用。';

  @override
  String get aiGenOwnershipCheckbox => '将此音频作为 Bantera 社区内容分享';

  @override
  String get aiGenOwnershipConfirmTitle => '作为社区内容分享？';

  @override
  String get aiGenOwnershipConfirmCancel => '取消';

  @override
  String get aiGenOwnershipConfirmGenerate => '生成';

  @override
  String get aiGenFooterNotice => 'AI 将创作双人对话并合成为音频。结果将保存为公开的练习音频。';

  @override
  String get aiScenarioCoffeeShop => '咖啡店';

  @override
  String get aiScenarioLatestNews => '最新新闻';

  @override
  String get aiScenarioAirportReunion => '机场重逢';

  @override
  String get aiScenarioGroceryStore => '超市';

  @override
  String get aiScenarioDoctorVisit => '看医生';

  @override
  String get aiScenarioJobInterview => '面试';

  @override
  String get aiScenarioNewNeighbour => '新邻居';

  @override
  String get aiScenarioTechSupport => '技术支持';

  @override
  String get aiScenarioBirthdaySurprise => '生日惊喜';

  @override
  String get aiScenarioGymTips => '健身建议';

  @override
  String get aiScenarioWeatherSmalltalk => '闲聊天气';

  @override
  String get aiScenarioRestaurantOrder => '餐厅点餐';

  @override
  String get aiScenarioBookRecommendation => '图书推荐';

  @override
  String get aiScenarioBusDelay => '公交延误';

  @override
  String get aiScenarioMovieDebate => '电影争论';

  @override
  String get aiScenarioCustom => '自定义…';

  @override
  String get errorNetworkUnreachable => '无法连接到 Bantera。请检查网络连接。';

  @override
  String get errorNetworkCellularBlocked =>
      '已为 Bantera 关闭蜂窝数据。请在「设置」中打开 Bantera 并开启「蜂窝数据」，或连接 Wi-Fi。';

  @override
  String get errorTlsConnection => '无法建立安全连接。';

  @override
  String get settingsRateAppPrompt =>
      '喜欢 Bantera 吗？在 App Store 给我们评个分吧，对我们意义重大。';

  @override
  String get settingsRateAppButton => '去 App Store 评分';

  @override
  String get settingsSharePrompt => '有朋友在学语言？把 Bantera 分享给他们吧。';

  @override
  String get settingsShareButton => '分享 Bantera';

  @override
  String get settingsContactButton => '联系我们';

  @override
  String get localVideoDescription => '从照片库选择视频，选择语言，让 iPhone 在后台转录后即可逐句练习。';

  @override
  String get localVideoStep1Title => '1. 选择视频';

  @override
  String get localVideoChooseFromPhotos => '从照片库选择';

  @override
  String get localVideoChooseDifferent => '选择其他视频';

  @override
  String get localVideoSelectedFileLabel => '已选文件';

  @override
  String get localVideoSizeLabel => '大小';

  @override
  String get localVideoDurationLabel => '时长';

  @override
  String get localVideoLongVideoWarning =>
      '此视频超过 3 分钟，Bantera 可能需要更多时间准备转录和翻译。';

  @override
  String get localVideoStep2Title => '2. 转录语言';

  @override
  String get localVideoChooseLanguagePlaceholder => '选择音频语言';

  @override
  String get localVideoLanguageHint => 'Bantera 会记住你上次的语言选择，练习开始后默认隐藏转录文字。';

  @override
  String get localVideoStep3Title => '3. 练习';

  @override
  String get localVideoPreparing => '准备中…';

  @override
  String get localVideoPracticeHint => 'Bantera 先在设备上转录，无需上传，然后打开逐句听力练习页。';

  @override
  String get localVideoStatusLongVideo => '视频较长，Bantera 可能需要更多时间进行转录和准备。';

  @override
  String get localVideoStatusTranscribing => '正在设备上转录并准备练习提示…';

  @override
  String get localVideoStatusSaving => '正在将视频保存到设备练习库…';

  @override
  String get localVideoStatusTranslationLong =>
      '转录完成。Bantera 还在为你保存的语言准备翻译，此较长视频可能需要更多时间。';

  @override
  String get localVideoStatusTranslation => '转录完成。正在为你保存的语言准备翻译…';

  @override
  String get localVideoPickerTitle => '选择音频语言';

  @override
  String get savedCuesTitle => '已保存的片段';

  @override
  String get savedCuesEmpty => '还没有保存的片段。在练习时点击书签图标即可保存。';

  @override
  String get savedCuesDeleteTooltip => '移除已保存片段';

  @override
  String get savedCuesDeleteConfirmTitle => '移除此片段？';

  @override
  String get savedCuesDeleteConfirmBody => '此片段将从你的保存列表中移除。';

  @override
  String get savedCuesDeleteAllTooltip => '删除所有已保存片段';

  @override
  String get savedCuesDeleteAllConfirmTitle => '删除所有已保存片段？';

  @override
  String get savedCuesDeleteAllConfirmBody => '所有已保存的片段将被永久删除。';

  @override
  String get updateAlertTitle => '有新版本可用';

  @override
  String get updateAlertMessage => 'Bantera 有新版本可用。立即更新以获取最新功能和改进。';

  @override
  String get updateAlertUpdate => '更新';

  @override
  String get updateAlertLater => '稍后';

  @override
  String get checkForUpdateButton => '检查更新';

  @override
  String get upToDateAlertTitle => '已是最新版本';

  @override
  String upToDateAlertMessage(Object version) {
    return 'Bantera $version 已是最新版本。';
  }

  @override
  String get sectionSupport => '支持';
}
