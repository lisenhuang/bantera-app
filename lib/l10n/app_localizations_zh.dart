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
  String get authContinueWithGoogle => '通过 Google 继续';

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
  String get onboardingTitle => '设置你的资料';

  @override
  String get onboardingSubtitle => '这会帮助 Bantera 个性化练习和聊天体验。';

  @override
  String get onboardingNameTitle => '别人应该怎么称呼你？';

  @override
  String get onboardingNameSubtitle => '如果 Apple 提供了姓名，我们已经为你填好。你现在可以修改。';

  @override
  String get onboardingClearName => '清空姓名';

  @override
  String get onboardingNativeLanguageTitle => '你的母语是什么？';

  @override
  String get onboardingNativeLanguageSubtitle => 'Bantera 会用它来处理翻译和语言群组。';

  @override
  String get onboardingLearningLanguageTitle => '你正在学习哪种语言？';

  @override
  String get onboardingLearningLanguageSubtitle => '这会决定练习内容和学习群组。';

  @override
  String get onboardingAvatarTitle => '添加头像';

  @override
  String get onboardingAvatarSubtitle => '你可以选择照片，也可以继续，让 Bantera 为你生成一个头像。';

  @override
  String get onboardingAvatarGenderTitle => '生成你的头像';

  @override
  String get onboardingAvatarGenderBody =>
      '请选择 Bantera 生成头像的方式。我们不会保存这个选择，它只用于生成这张头像。';

  @override
  String get onboardingAvatarGenderMale => '男';

  @override
  String get onboardingAvatarGenderFemale => '女';

  @override
  String get onboardingChoosePhoto => '选择照片';

  @override
  String get onboardingChangePhoto => '更换照片';

  @override
  String get onboardingUseGeneratedAvatar => '改用生成头像';

  @override
  String get onboardingUseCurrentPhoto => '使用当前照片';

  @override
  String get onboardingChooseLanguage => '选择语言';

  @override
  String get onboardingBack => '返回';

  @override
  String get onboardingFinish => '完成';

  @override
  String get onboardingLoadingProfile => '正在加载资料...';

  @override
  String get onboardingSavingProfile => '正在保存资料...';

  @override
  String get onboardingLoadFailed => '出了点问题，请重试。';

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
  String get sectionNotifications => '通知';

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
  String get closeLabel => '关闭';

  @override
  String get navDiscover => '发现';

  @override
  String get navCreate => '创作';

  @override
  String get navProfile => '我的';

  @override
  String get chatsTitle => '聊天';

  @override
  String get chatNoChatsYet => '还没有聊天。';

  @override
  String get chatOnlineSection => '在线';

  @override
  String get chatDirectMessagesSection => '私信';

  @override
  String chatAudioDuration(String duration) {
    return '音频 $duration';
  }

  @override
  String get chatEnableNotifications => '开启通知';

  @override
  String get chatMuteNotifications => '静音通知';

  @override
  String get chatBlockUser => '屏蔽用户';

  @override
  String get chatDeleteDm => '删除私信';

  @override
  String get chatCall => '通话';

  @override
  String get chatStartAudioCall => '语音通话';

  @override
  String get chatStartVideoCall => '视频通话';

  @override
  String get chatAudioCalling => '正在语音呼叫...';

  @override
  String get chatVideoCalling => '正在视频呼叫...';

  @override
  String get chatAudioIncoming => '语音来电';

  @override
  String get chatVideoIncoming => '视频来电';

  @override
  String get chatCallConnecting => '连接中...';

  @override
  String get chatCallAccept => '接听';

  @override
  String get chatCallDecline => '拒绝';

  @override
  String get chatCallEnd => '结束';

  @override
  String get chatCallMute => '静音';

  @override
  String get chatCallUnmute => '取消静音';

  @override
  String get chatCallSpeaker => '扬声器';

  @override
  String get chatCallCamera => '摄像头';

  @override
  String get chatCallSwitchCamera => '切换';

  @override
  String get chatCallIssueTitle => '通话问题';

  @override
  String get chatCallMicrophoneDenied => '开始通话前，Bantera 需要麦克风权限。';

  @override
  String get chatCallMicrophoneSettings => 'Bantera 的麦克风权限已关闭。请打开设置并允许通话使用。';

  @override
  String get chatCallCameraDenied => '开始视频通话前，Bantera 需要摄像头权限。';

  @override
  String get chatCallCameraSettings => 'Bantera 的摄像头权限已关闭。请打开设置并允许视频通话使用。';

  @override
  String get chatCallBusy => '对方正在进行其他通话。';

  @override
  String get chatCallUnavailable => '对方当前无法接听通话。';

  @override
  String get chatCallNetworkRestricted => '当前网络无法建立通话，请尝试 Wi-Fi 或其他网络。';

  @override
  String get chatCallFailed => '无法开始通话，请重试。';

  @override
  String get chatGroupReady => '这个群组可以发送语音消息。';

  @override
  String get chatHoldToStartDm => '长按录音并开始私信。';

  @override
  String get chatNoGroupAudio => '还没有群组语音。';

  @override
  String get chatNoDmAudio => '这条私信里还没有语音。';

  @override
  String get chatSendingAudio => '正在发送音频...';

  @override
  String get chatRecordingReleaseToSend => '正在录音...松开发送';

  @override
  String get chatHoldToRecordAudio => '长按录制音频';

  @override
  String get chatRecordingStatus => '正在录音...';

  @override
  String get chatGroupLabel => '群组';

  @override
  String get chatNotificationsEnabledForDm => '已开启这条私信的通知。';

  @override
  String get chatNotificationsMutedForDm => '已静音这条私信的通知。';

  @override
  String chatBlockUserTitle(String user) {
    return '屏蔽 $user？';
  }

  @override
  String get chatBlockUserBody => '在解除屏蔽前，你们不会在私信发送和共享群组消息中看到彼此。';

  @override
  String chatBlockUserSuccess(String user) {
    return '已屏蔽 $user。';
  }

  @override
  String get chatBlockUserFailed => '无法屏蔽此用户，请重试。';

  @override
  String get chatDeleteMessage => '删除消息';

  @override
  String get chatDeleteMessageTitle => '删除这条消息？';

  @override
  String get chatDeleteMessageBody => '此消息将对所有人删除，且无法撤销。';

  @override
  String get chatDeleteMessageSuccess => '消息已删除';

  @override
  String get chatDeleteMessageFailed => '消息删除失败，请重试。';

  @override
  String get chatDeleteDmTitle => '删除这条私信？';

  @override
  String get chatDeleteDmBody => '这只会把它从列表中移除。之后有新消息时可能会重新出现。';

  @override
  String get chatMicrophoneRequiredTitle => '需要麦克风';

  @override
  String get chatMicrophoneRequiredSettings =>
      'Bantera 需要麦克风权限来录制聊天音频。请在设置中开启。';

  @override
  String get chatMicrophoneRequiredBody => 'Bantera 需要麦克风权限来录制聊天音频。';

  @override
  String get chatGroupNotReady => '这个群组还没准备好。';

  @override
  String get chatMessageAction => '发消息';

  @override
  String get chatRetranscribe => '重新转写';

  @override
  String get chatTranscribe => '转写';

  @override
  String get chatTranscribingOnDevice => '正在此 iPhone 上转写...';

  @override
  String get chatTranscriptionFailed => '转写失败，请重试。';

  @override
  String get chatTranslate => '翻译';

  @override
  String get chatRetranslate => '重新翻译';

  @override
  String get chatTranslating => '正在此 iPhone 上翻译...';

  @override
  String get chatTranslationFailed => '翻译失败，请重试。';

  @override
  String get chatGroupSettingsTitle => '群组设置';

  @override
  String get chatNotifications => '通知';

  @override
  String get chatBlockedUsersMenu => '已屏蔽用户';

  @override
  String get chatBlockedUsersTitle => '已屏蔽用户';

  @override
  String get chatBlockedPeople => '已屏蔽的人';

  @override
  String get chatNoBlockedUsers => '还没有屏蔽任何用户。';

  @override
  String get chatNoBlockedPeople => '还没有屏蔽任何人。';

  @override
  String get chatUnblock => '解除屏蔽';

  @override
  String chatUnblockUserTitle(String user) {
    return '解除屏蔽 $user？';
  }

  @override
  String get chatUnblockUserBody => '你们可能会再次在私信和共享群组消息中看到彼此。';

  @override
  String get chatUnblockFailed => '无法解除屏蔽此用户，请重试。';

  @override
  String get chatNotificationsTitle => '聊天通知';

  @override
  String get chatNotificationsSubtitle => '在所有设备上使用同一个账户级开关。';

  @override
  String get chatNotificationsDisabledTitle => '通知已关闭';

  @override
  String get chatNotificationsDisabledSettings => '请在设置中开启通知，以接收 Bantera 聊天提醒。';

  @override
  String get chatNotificationsDisabledBody => '开启聊天提醒前，Bantera 需要通知权限。';

  @override
  String get chatNotificationUpdateFailed => '无法更新聊天通知，请重试。';

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
  String get practicePlayAll => '影子跟读';

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
  String get practicePlayAllTitle => '影子跟读';

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
  String get compareUncertainHint => '虚线词已识别但不太确定 — 请检查你的发音。';

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
  String compareUncertainCount(int count) {
    return '$count 处不确定';
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
  String get updateCurrentVersionLabel => '当前版本';

  @override
  String get updateAppStoreVersionLabel => 'App Store 版本';

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

  @override
  String get permissionActionAllow => '允许';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appName => 'Bantera';

  @override
  String get appTagline => '語言練習，逐句進行。';

  @override
  String get authContinueWithApple => '透過 Apple 繼續';

  @override
  String get authContinueWithGoogle => '透過 Google 繼續';

  @override
  String get authAppleUnavailable => '此裝置無法使用「透過 Apple 登入」。';

  @override
  String get authOrSignInEmail => '或使用電郵登入';

  @override
  String get authEmail => '電郵';

  @override
  String get authPassword => '密碼';

  @override
  String get authSigningIn => '正在登入…';

  @override
  String get authSignIn => '登入';

  @override
  String get authSignInWithEmail => '使用電郵登入';

  @override
  String get validationEnterEmail => '請輸入電郵。';

  @override
  String get validationValidEmail => '請輸入有效的電郵地址。';

  @override
  String get validationEnterPassword => '請輸入密碼。';

  @override
  String get onboardingTitle => '設定你的個人資料';

  @override
  String get onboardingSubtitle => '這有助 Bantera 為你提供個人化的練習和聊天體驗。';

  @override
  String get onboardingNameTitle => '別人應該怎樣稱呼你？';

  @override
  String get onboardingNameSubtitle => '如果 Apple 提供了姓名，我們已為你填好。你現在可以修改。';

  @override
  String get onboardingClearName => '清除姓名';

  @override
  String get onboardingNativeLanguageTitle => '你的母語是甚麼？';

  @override
  String get onboardingNativeLanguageSubtitle => 'Bantera 會用它來處理翻譯和語言群組。';

  @override
  String get onboardingLearningLanguageTitle => '你正在學習哪種語言？';

  @override
  String get onboardingLearningLanguageSubtitle => '這會決定練習內容和學習群組。';

  @override
  String get onboardingAvatarTitle => '加入頭像';

  @override
  String get onboardingAvatarSubtitle => '你可以選擇相片，或直接繼續，讓 Bantera 為你生成頭像。';

  @override
  String get onboardingAvatarGenderTitle => '生成你的頭像';

  @override
  String get onboardingAvatarGenderBody =>
      '請選擇 Bantera 生成頭像的方式。我們不會儲存這個選擇，它只會用於生成這張頭像。';

  @override
  String get onboardingAvatarGenderMale => '男';

  @override
  String get onboardingAvatarGenderFemale => '女';

  @override
  String get onboardingChoosePhoto => '選擇相片';

  @override
  String get onboardingChangePhoto => '更換相片';

  @override
  String get onboardingUseGeneratedAvatar => '改用生成的頭像';

  @override
  String get onboardingUseCurrentPhoto => '使用目前的相片';

  @override
  String get onboardingChooseLanguage => '選擇語言';

  @override
  String get onboardingBack => '返回';

  @override
  String get onboardingFinish => '完成';

  @override
  String get onboardingLoadingProfile => '正在載入個人資料…';

  @override
  String get onboardingSavingProfile => '正在儲存個人資料…';

  @override
  String get onboardingLoadFailed => '發生錯誤，請重試。';

  @override
  String get onboardingSearchHint => '搜尋語言…';

  @override
  String get onboardingRetry => '重試';

  @override
  String get onboardingNoMatching => '沒有相符的語言。';

  @override
  String get onboardingFailedSave => '儲存失敗。';

  @override
  String get settingsTitle => '設定';

  @override
  String get sectionAppearance => '外觀';

  @override
  String get sectionAccount => '帳戶';

  @override
  String get sectionRateAndShare => '評分與分享';

  @override
  String get sectionLanguage => '顯示語言';

  @override
  String get sectionPermissions => '權限';

  @override
  String get sectionNotifications => '通知';

  @override
  String get languageSectionSubtitle => '選擇 App 的顯示語言。「跟隨系統」會使用裝置的語言設定。';

  @override
  String get themeLabel => '主題';

  @override
  String get themeLight => '淺色';

  @override
  String get themeDark => '深色';

  @override
  String get themeSystem => '跟隨系統';

  @override
  String get languageEnglish => '英文';

  @override
  String get languageChineseSimplified => '中文（簡體）';

  @override
  String get languageKorean => '韓文';

  @override
  String get languageJapanese => '日文';

  @override
  String get signedOutLabel => '已登出';

  @override
  String get noActiveSession => '沒有有效的 Bantera 登入狀態';

  @override
  String signedInWith(String provider) {
    return '已透過 $provider 登入';
  }

  @override
  String get editProfile => '編輯個人資料';

  @override
  String get more => '更多';

  @override
  String get appPermissionsTitle => 'App 權限';

  @override
  String get appPermissionsSubtitle => '查看 Bantera 在此裝置上使用的存取權限。';

  @override
  String get permissionsIntro => 'Bantera 會使用這些裝置設定來錄音、比較語音及連接網絡。';

  @override
  String get permissionsOpenSettings => '打開 iPhone 設定';

  @override
  String get permissionsRefresh => '重新整理';

  @override
  String get permissionMicrophoneTitle => '麥克風';

  @override
  String get permissionMicrophoneDescription => '用於錄製練習和語音訊息。';

  @override
  String get permissionSpeechTitle => '語音辨識';

  @override
  String get permissionSpeechDescription => '用於轉錄練習錄音和語音訊息。';

  @override
  String get permissionMobileDataTitle => '流動數據';

  @override
  String get permissionMobileDataDescription =>
      '在此 iPhone 未連接 Wi-Fi 時使用 Bantera。';

  @override
  String get permissionStatusAllowed => '已允許';

  @override
  String get permissionStatusLimited => '受限';

  @override
  String get permissionStatusNotAllowed => '未允許';

  @override
  String get permissionStatusUnknown => '不明';

  @override
  String get signOut => '登出';

  @override
  String get signOutDialogTitle => '要登出嗎？';

  @override
  String get signOutDialogBody => '你需要重新登入才能使用帳戶。';

  @override
  String get cancel => '取消';

  @override
  String get closeLabel => '關閉';

  @override
  String get navDiscover => '探索';

  @override
  String get navCreate => '創作';

  @override
  String get navProfile => '我的';

  @override
  String get chatsTitle => '聊天';

  @override
  String get chatNoChatsYet => '暫時沒有聊天。';

  @override
  String get chatOnlineSection => '在線';

  @override
  String get chatDirectMessagesSection => '私訊';

  @override
  String chatAudioDuration(String duration) {
    return '音訊 $duration';
  }

  @override
  String get chatEnableNotifications => '開啟通知';

  @override
  String get chatMuteNotifications => '將通知靜音';

  @override
  String get chatBlockUser => '封鎖用戶';

  @override
  String get chatDeleteDm => '刪除私訊';

  @override
  String get chatCall => '通話';

  @override
  String get chatStartAudioCall => '語音通話';

  @override
  String get chatStartVideoCall => '視像通話';

  @override
  String get chatAudioCalling => '正在語音通話…';

  @override
  String get chatVideoCalling => '正在視像通話…';

  @override
  String get chatAudioIncoming => '語音來電';

  @override
  String get chatVideoIncoming => '視像來電';

  @override
  String get chatCallConnecting => '正在連接…';

  @override
  String get chatCallAccept => '接聽';

  @override
  String get chatCallDecline => '拒絕';

  @override
  String get chatCallEnd => '結束';

  @override
  String get chatCallMute => '靜音';

  @override
  String get chatCallUnmute => '取消靜音';

  @override
  String get chatCallSpeaker => '揚聲器';

  @override
  String get chatCallCamera => '相機';

  @override
  String get chatCallSwitchCamera => '切換';

  @override
  String get chatCallIssueTitle => '通話問題';

  @override
  String get chatCallMicrophoneDenied => '開始通話前，Bantera 需要麥克風權限。';

  @override
  String get chatCallMicrophoneSettings => 'Bantera 的麥克風權限已關閉。請打開「設定」並允許用於通話。';

  @override
  String get chatCallCameraDenied => '開始視像通話前，Bantera 需要相機權限。';

  @override
  String get chatCallCameraSettings => 'Bantera 的相機權限已關閉。請打開「設定」並允許用於視像通話。';

  @override
  String get chatCallBusy => '對方正在進行另一個通話。';

  @override
  String get chatCallUnavailable => '對方目前無法接聽通話。';

  @override
  String get chatCallNetworkRestricted => '此網絡無法接通通話，請嘗試 Wi-Fi 或其他網絡。';

  @override
  String get chatCallFailed => '無法開始通話，請重試。';

  @override
  String get chatGroupReady => '此群組已可傳送語音訊息。';

  @override
  String get chatHoldToStartDm => '按住錄音以開始私訊。';

  @override
  String get chatNoGroupAudio => '群組暫時沒有語音。';

  @override
  String get chatNoDmAudio => '此私訊暫時沒有語音。';

  @override
  String get chatSendingAudio => '正在傳送音訊…';

  @override
  String get chatRecordingReleaseToSend => '正在錄音…放開即可傳送';

  @override
  String get chatHoldToRecordAudio => '按住錄音';

  @override
  String get chatRecordingStatus => '正在錄音…';

  @override
  String get chatGroupLabel => '群組';

  @override
  String get chatNotificationsEnabledForDm => '已開啟此私訊的通知。';

  @override
  String get chatNotificationsMutedForDm => '已將此私訊的通知靜音。';

  @override
  String chatBlockUserTitle(String user) {
    return '要封鎖 $user 嗎？';
  }

  @override
  String get chatBlockUserBody => '解除封鎖前，你們在私訊及共同群組的訊息中將不會再看到對方。';

  @override
  String chatBlockUserSuccess(String user) {
    return '已封鎖 $user。';
  }

  @override
  String get chatBlockUserFailed => '無法封鎖此用戶，請重試。';

  @override
  String get chatDeleteMessage => '刪除訊息';

  @override
  String get chatDeleteMessageTitle => '要刪除此訊息嗎？';

  @override
  String get chatDeleteMessageBody => '此訊息將從對話中為所有人刪除，且無法復原。';

  @override
  String get chatDeleteMessageSuccess => '已刪除訊息';

  @override
  String get chatDeleteMessageFailed => '無法刪除訊息，請重試。';

  @override
  String get chatDeleteDmTitle => '要刪除此私訊嗎？';

  @override
  String get chatDeleteDmBody => '這只會將它從你的列表中移除。日後有新訊息時可能會再次出現。';

  @override
  String get chatMicrophoneRequiredTitle => '需要麥克風';

  @override
  String get chatMicrophoneRequiredSettings =>
      'Bantera 需要麥克風權限來錄製聊天音訊。請在「設定」中開啟。';

  @override
  String get chatMicrophoneRequiredBody => 'Bantera 需要麥克風權限來錄製聊天音訊。';

  @override
  String get chatGroupNotReady => '此群組尚未準備好。';

  @override
  String get chatMessageAction => '傳送訊息';

  @override
  String get chatRetranscribe => '重新轉錄';

  @override
  String get chatTranscribe => '轉錄';

  @override
  String get chatTranscribingOnDevice => '正在此 iPhone 上轉錄…';

  @override
  String get chatTranscriptionFailed => '轉錄失敗，請重試。';

  @override
  String get chatTranslate => '翻譯';

  @override
  String get chatRetranslate => '重新翻譯';

  @override
  String get chatTranslating => '正在此 iPhone 上翻譯…';

  @override
  String get chatTranslationFailed => '翻譯失敗，請重試。';

  @override
  String get chatGroupSettingsTitle => '群組設定';

  @override
  String get chatNotifications => '通知';

  @override
  String get chatBlockedUsersMenu => '已封鎖的用戶';

  @override
  String get chatBlockedUsersTitle => '已封鎖的用戶';

  @override
  String get chatBlockedPeople => '已封鎖的人';

  @override
  String get chatNoBlockedUsers => '尚未封鎖任何用戶。';

  @override
  String get chatNoBlockedPeople => '尚未封鎖任何人。';

  @override
  String get chatUnblock => '解除封鎖';

  @override
  String chatUnblockUserTitle(String user) {
    return '要解除封鎖 $user 嗎？';
  }

  @override
  String get chatUnblockUserBody => '你們可能會再次在私訊及共同群組的訊息中看到對方。';

  @override
  String get chatUnblockFailed => '無法解除封鎖此用戶，請重試。';

  @override
  String get chatNotificationsTitle => '聊天通知';

  @override
  String get chatNotificationsSubtitle => '所有裝置共用同一個帳戶層級的開關。';

  @override
  String get chatNotificationsDisabledTitle => '通知已關閉';

  @override
  String get chatNotificationsDisabledSettings =>
      '請在「設定」中開啟通知，以接收 Bantera 的聊天提示。';

  @override
  String get chatNotificationsDisabledBody => '開啟聊天提示前，Bantera 需要通知權限。';

  @override
  String get chatNotificationUpdateFailed => '無法更新聊天通知，請重試。';

  @override
  String get savedTitle => '已儲存的媒體';

  @override
  String get generateWithAiTitle => '以 AI 生成';

  @override
  String get practiceLocalVideoTitle => '練習本機影片';

  @override
  String get uploadVideoTitle => '上載影片';

  @override
  String get lessonDetailsTitle => '課堂詳情';

  @override
  String get accountMoreTitle => '更多';

  @override
  String get deleteAccount => '刪除帳戶';

  @override
  String get deleteAccountSubtitle => '永久刪除你的帳戶及伺服器上的資料';

  @override
  String get confirmDeletionTitle => '確認刪除';

  @override
  String get deleteAccountImmediateBody =>
      '你的帳戶將會立即刪除。如要再次使用 Bantera，需要重新建立帳戶。';

  @override
  String get deleteAccountConfirm => '刪除帳戶';

  @override
  String get couldNotDeleteAccount => '無法刪除帳戶，請重試。';

  @override
  String get deleteAccountQuestionTitle => '要刪除帳戶嗎？';

  @override
  String get deleteAccountQuestionBody => '你所有的個人資料和數據將從我們的伺服器永久刪除，且無法復原。';

  @override
  String get typeDeleteLabel => '輸入「DELETE」以繼續';

  @override
  String get continueLabel => '繼續';

  @override
  String get confirmLabel => '確認';

  @override
  String get deleteLabel => '刪除';

  @override
  String get removeFromListLabel => '從列表中移除';

  @override
  String get startLabel => '開始';

  @override
  String get doneLabel => '完成';

  @override
  String get discoverSearchHint => '搜尋標題或文字稿…';

  @override
  String get discoverNoMoreResults => '沒有更多結果';

  @override
  String get discoverSetLearningLanguagePrompt => '設定學習語言後即可在此查看內容';

  @override
  String discoverNoPublicContentInLanguage(String language) {
    return '暫時沒有$language的公開內容';
  }

  @override
  String get discoverSetLanguageToDiscover => '設定學習語言以探索內容';

  @override
  String get mediaStartPractice => '開始練習';

  @override
  String get mediaTranscript => '文字稿';

  @override
  String mediaTranscriptLineCount(int count) {
    return '（$count 行）';
  }

  @override
  String get mediaShow => '顯示';

  @override
  String get mediaHide => '隱藏';

  @override
  String get mediaNoTranscriptAvailable => '暫時沒有文字稿。';

  @override
  String get lessonSaveTooltip => '儲存';

  @override
  String get lessonUnsaveTooltip => '取消儲存';

  @override
  String get mediaKindAudio => '音訊';

  @override
  String get mediaKindVideo => '影片';

  @override
  String get practiceNoCues => '沒有句子';

  @override
  String get practiceTranslating => '正在翻譯…';

  @override
  String get practiceShowTranscript => '顯示文字稿';

  @override
  String get practiceTranslate => '翻譯';

  @override
  String get practiceHideText => '隱藏文字';

  @override
  String get practiceTextLabel => '文字';

  @override
  String get practiceStop => '停止';

  @override
  String get practicePlayAll => '影子跟讀';

  @override
  String get practiceCompare => '比較';

  @override
  String get practiceRecord => '錄音';

  @override
  String get practiceStopRecording => '停止';

  @override
  String get practiceRecords => '記錄';

  @override
  String get practiceRecordsLocalOnlyFooter => '練習錄音只會儲存在此裝置，不會上載。';

  @override
  String get practiceRecordsEmpty => '此句暫時沒有已儲存的練習。';

  @override
  String get practiceRecordingProcessError => '處理錄音時發生錯誤。';

  @override
  String get practiceStartOver => '重新開始';

  @override
  String get practiceTranscriptHidden => '已隱藏文字稿';

  @override
  String get practiceListenCarefully => '請留心聆聽…';

  @override
  String get practiceTranslationUnavailableForCue => '目前無法翻譯此句。';

  @override
  String get practiceChooseTranslationLanguageTitle => '選擇翻譯語言';

  @override
  String get practiceChooseTranslationLanguageDescription =>
      'Bantera 會將聆聽練習翻譯成此語言，並儲存到你的個人資料，供日後使用。';

  @override
  String get practiceChangeTranslationLanguageTitle => '更改翻譯語言';

  @override
  String get practiceChangeTranslationLanguageDescription =>
      '選擇 Bantera 要翻譯成的語言。新選擇將儲存到你的個人資料。';

  @override
  String get practiceConfirmTranslationLanguageTitle => '確認翻譯語言';

  @override
  String get practiceConfirmTranslationLanguageBody =>
      'Bantera 會將此語言儲存到你的個人資料，並在日後的聆聽練習中作為預設翻譯語言。';

  @override
  String get practiceCouldNotSaveTranslationLanguage => 'Bantera 無法儲存你的翻譯語言。';

  @override
  String get practiceNoTranslationLanguagesFound => 'Bantera 找不到適用於此文字稿的翻譯語言。';

  @override
  String get practicePlayAllTitle => '影子跟讀';

  @override
  String get practicePlayAllDescription => '句子之間的停頓，方便跟讀：';

  @override
  String get practicePlayAllPauseZeroSeconds => '0 秒';

  @override
  String get practicePlayAllPauseOneSecondLabel => '1 秒';

  @override
  String get practicePlayAllPauseOneCuePlusOneSecond => '1 句 + 1 秒';

  @override
  String get practicePlayAllPauseOneCuePlusTwoSeconds => '1 句 + 2 秒';

  @override
  String get practicePlayAllTimesPerCueTitle => '每句播放次數';

  @override
  String get practicePlayAllTimesOnce => '1×';

  @override
  String get practicePlayAllTimesTwice => '2×';

  @override
  String get practicePlayAllTimesThrice => '3×';

  @override
  String get practiceSearchLanguagesHint => '搜尋語言';

  @override
  String get practiceTranslationInstalled => '已安裝';

  @override
  String get practiceTranslationDownload => '下載';

  @override
  String get practiceStartOverTitle => '要重新開始嗎？';

  @override
  String get practiceStartOverBody => '返回第一句？';

  @override
  String get practiceNextFromLastTitle => '前往第一句？';

  @override
  String get practiceNextFromLastBody => '這已是最後一句，要返回第一句嗎？';

  @override
  String get practiceGoToFirstCue => '前往第一句';

  @override
  String get practiceVideoOpenError => '無法打開所選影片進行練習。';

  @override
  String get practiceAudioLoading => '正在載入音訊…';

  @override
  String practiceAudioLoadingPercent(int percent) {
    return '正在載入音訊 $percent%';
  }

  @override
  String get practiceAudioError => '無法載入音訊，請重試。';

  @override
  String get compareRecordYourVersion => '錄製你的版本';

  @override
  String compareTranscriptionLanguage(String locale) {
    return '轉錄語言：$locale';
  }

  @override
  String get compareOpenIphoneSettings => '打開 iPhone 設定';

  @override
  String get comparePauseAttempt => '暫停錄音';

  @override
  String get comparePlayAttempt => '播放錄音';

  @override
  String get compareYourTranscribedAttempt => '你的轉錄結果';

  @override
  String get compareHighlightHint => 'Bantera 辨識出不同的字詞會以醒目標示顯示。';

  @override
  String get compareUncertainHint => '虛線字詞已辨識，但 Bantera 不太確定 — 請檢查你的發音。';

  @override
  String get compareTryAgain => '再試一次';

  @override
  String get compareDone => '完成';

  @override
  String get compareStatusTranscribing => '正在 iPhone 上轉錄你的錄音…';

  @override
  String get compareStatusRecording => '正在錄音…再點按一次即可停止。';

  @override
  String get compareStatusSavedAttempt => '正在顯示此句已儲存的錄音。你可以重播或再試一次。';

  @override
  String get compareStatusReplayOrRetry => '你可以重播此錄音或再練習此句。';

  @override
  String get compareStatusTapToRecord => '點按以開始錄製此句。';

  @override
  String get compareCouldNotStartRecording => 'Bantera 目前無法開始錄音。';

  @override
  String get compareCouldNotAccessRecording => 'Bantera 無法存取已錄製的音訊。';

  @override
  String get compareNoTranscriptGenerated => '無法為此錄音生成文字稿。請靠近麥克風再試一次。';

  @override
  String get compareRecentAttempts => '最近的錄音';

  @override
  String get compareAttemptsFooterNote =>
      'Bantera 會將你的錄音保留在此 iPhone，方便你查看同一句的進步。';

  @override
  String compareMatchedCount(int count) {
    return '$count 處相符';
  }

  @override
  String compareDifferentCount(int count) {
    return '$count 處不同';
  }

  @override
  String compareMissingCount(int count) {
    return '$count 處遺漏';
  }

  @override
  String compareUncertainCount(int count) {
    return '$count 處不清楚';
  }

  @override
  String get compareMicrophoneDeniedPermanent =>
      'Bantera 的麥克風權限已關閉。請前往 iPhone「設定」> Bantera >「麥克風」並開啟，以錄製你的版本。';

  @override
  String get compareMicrophoneDeniedRestricted =>
      '此 iPhone 目前限制 Bantera 使用麥克風。請檢查「螢幕使用時間」、裝置管理或系統設定。';

  @override
  String get compareMicrophoneDeniedDefault =>
      '需要麥克風權限才能錄製你的版本。如之前已關閉提示，請前往 iPhone「設定」> Bantera >「麥克風」並開啟。';

  @override
  String get compareSpeechRecognitionDeniedPermanent =>
      'Bantera 的語音辨識權限已關閉。請前往 iPhone「設定」> Bantera >「語音辨識」並開啟，以比較你的錄音。';

  @override
  String get compareSpeechRecognitionDeniedRestricted =>
      '此 iPhone 目前限制 Bantera 使用語音辨識。請檢查「螢幕使用時間」、裝置管理或系統設定。';

  @override
  String get compareSpeechRecognitionUnavailable => '此 iPhone 目前無法使用語音辨識。';

  @override
  String get compareSpeechRecognitionUnsupportedLocale =>
      '此 iPhone 不支援以目前的練習語言進行語音辨識。';

  @override
  String get comparePlayAttemptTooltip => '播放錄音';

  @override
  String get comparePauseAttemptTooltip => '暫停錄音';

  @override
  String get createWhatToday => '今天想做甚麼？';

  @override
  String get createPracticeVideo => '練習影片';

  @override
  String get createYourMedia => '我的媒體';

  @override
  String get createTryAgain => '再試一次';

  @override
  String get createUploadedVideosEmptyHint => '你上載的影片會顯示在這裏，方便你隨時打開並逐句練習。';

  @override
  String get createUploadingTips => '上載貼士';

  @override
  String get createUploadingTipsBody => '音訊保持在 3 分鐘以內效果最好。系統會自動生成清晰字幕！';

  @override
  String get createOnThisIphone => '此 iPhone 上的影片';

  @override
  String get createLocalVideosEmptyHint =>
      '在本機練習的影片會儲存在此 iPhone，日後可直接打開，無需重新轉錄。';

  @override
  String get createOnDeviceBadge => '本機';

  @override
  String get createSignInToLoadVideos => '請重新登入以載入已上載的影片。';

  @override
  String createVideoMetaCues(int count) {
    return '$count 句';
  }

  @override
  String get createPublicBadge => '公開';

  @override
  String get createPrivateBadge => '私人';

  @override
  String get createAiBadge => 'AI';

  @override
  String get createDeleteSavedVideoTitle => '要刪除已儲存的影片嗎？';

  @override
  String createDeleteSavedVideoBody(String title) {
    return 'Bantera 將從此 iPhone 移除「$title」，並刪除已儲存的文字稿句子。';
  }

  @override
  String get createDeleteMediaTitle => '要刪除媒體嗎？';

  @override
  String createDeleteMediaBody(String title) {
    return '這將永久刪除「$title」及其文字稿，且無法復原。';
  }

  @override
  String get removeFromListTitle => '要從列表中移除嗎？';

  @override
  String get removeFromListBody => '此項目將從列表中移除，且無法復原。';

  @override
  String get editProfileChangeImage => '更換頭像';

  @override
  String get editProfileUploading => '正在上載…';

  @override
  String get editProfileNameLabel => '姓名';

  @override
  String get editProfileNameHint => 'Bantera 應如何顯示你的姓名？';

  @override
  String get editProfileSaveNameButton => '儲存姓名';

  @override
  String get editProfileSaving => '正在儲存…';

  @override
  String get editProfileLanguagesSection => '語言';

  @override
  String get editProfileMyNativeLanguage => '我的母語';

  @override
  String get editProfileMyNativeLanguageSubtitle => '你的母語或第一語言';

  @override
  String get editProfileLearningLanguage => '學習語言';

  @override
  String get editProfileLearningLanguageSubtitle => '你想練習的語言';

  @override
  String get editProfileImageUpdated => '已更新頭像。';

  @override
  String get editProfileNameUpdated => '已更新姓名。';

  @override
  String get editProfileEnterName => '請輸入姓名。';

  @override
  String get editProfileNameMaxLength => '請使用不超過 80 個字元。';

  @override
  String get editProfileCouldNotLoadLanguages => '無法載入語言列表。';

  @override
  String get languagePickerNone => '無';

  @override
  String get languagePickerClearSelection => '清除選擇';

  @override
  String get languagePickerNoMatchingLanguages => '找不到語言。';

  @override
  String get languagePickerMoreComingSoon => '更多語言即將推出';

  @override
  String get editProfileNativeLanguageCleared => '已清除母語。';

  @override
  String get editProfileLearningLanguageCleared => '已清除學習語言。';

  @override
  String editProfileNativeLanguageSetTo(String language) {
    return '母語已設定為$language。';
  }

  @override
  String editProfileLearningLanguageSetTo(String language) {
    return '學習語言已設定為$language。';
  }

  @override
  String get profileLanguageSettings => '語言設定';

  @override
  String get profileLearningLabel => '學習中';

  @override
  String get profileNotSet => '未設定';

  @override
  String get uploadedDetailYourAudio => '你的音訊';

  @override
  String get uploadedDetailYourVideo => '你的影片';

  @override
  String get uploadedDetailDeleteAudioTitle => '要刪除音訊嗎？';

  @override
  String get uploadedDetailDeleteAudioBody => '這將永久刪除此音訊及其文字稿，且無法復原。';

  @override
  String get uploadedDetailDeleteVideoTitle => '要刪除影片嗎？';

  @override
  String get uploadedDetailDeleteVideoBody => '這將永久刪除此影片及其文字稿，且無法復原。';

  @override
  String get uploadedDetailAiGenerated => 'AI 生成';

  @override
  String get uploadedDetailFileSize => '檔案大小';

  @override
  String get uploadedDetailResolution => '解像度';

  @override
  String get uploadedDetailResolutionUnknown => '不明';

  @override
  String get uploadedDetailTranscribing => '正在轉錄…';

  @override
  String get uploadedDetailNoTranscriptCuesYet => '暫時沒有文字稿句子。';

  @override
  String uploadedDetailMediaDescription(int count) {
    return '你上載的練習片段，共有 $count 句文字稿。';
  }

  @override
  String get uploadedDetailTranscriptionFailedFallback => '轉錄失敗，正使用估算的分句。';

  @override
  String get uploadedDetailTranscriptionNoCues => '轉錄沒有傳回任何句子。';

  @override
  String get uploadedDetailTranscriptionSourceYourUpload => '你的上載';

  @override
  String get aiGenLeaveTitle => '要離開此頁面嗎？';

  @override
  String get aiGenLeaveBody => '音訊仍在生成中。現在離開將會取消生成。';

  @override
  String get aiGenStay => '留在此頁';

  @override
  String get aiGenLeave => '離開';

  @override
  String get aiGenLoadingTitle => '正在建立你的音訊…';

  @override
  String get aiGenLoadingSubtitle => '這可能需時約一分鐘。\n生成期間請留在此頁面。';

  @override
  String get aiGenStepPreparingSpeechModel => '正在準備裝置上的語音模型';

  @override
  String get aiGenStepWritingDialogue => '撰寫對話';

  @override
  String get aiGenStepGeneratingAudio => '生成音訊';

  @override
  String get aiGenStepAligningAudio => '對齊音訊';

  @override
  String get aiGenStepTranscribing => '轉錄';

  @override
  String get aiGenStepCorrectingTranscript => '校正文字稿';

  @override
  String get aiGenLanguageSection => '語言';

  @override
  String get aiGenSetLearningLanguagePrompt => '請設定學習語言以啟用生成功能';

  @override
  String get aiGenLoadingLanguage => '正在載入語言…';

  @override
  String aiGenLanguageUnsupported(String language) {
    return '暫不支援以「$language」生成。';
  }

  @override
  String get aiGenScenarioSection => '場景';

  @override
  String get aiGenScenarioOptionalHint => '可選 — 不選擇則隨機產生場景。';

  @override
  String get aiGenCustomScenarioHint => '描述你的場景…';

  @override
  String get aiGenDurationSection => '長度';

  @override
  String aiGenDurationMinutes(int minutes) {
    return '$minutes 分鐘';
  }

  @override
  String get aiGenGenerateButton => '生成';

  @override
  String get aiGenOwnershipNotice =>
      '你在此生成的音訊將成為 Bantera 社群內容，作為練習素材公開分享給所有學習者。';

  @override
  String get aiGenOwnershipCheckbox => '將此音訊作為 Bantera 社群內容分享';

  @override
  String get aiGenOwnershipConfirmTitle => '要作為社群內容分享嗎？';

  @override
  String get aiGenOwnershipConfirmCancel => '取消';

  @override
  String get aiGenOwnershipConfirmGenerate => '生成';

  @override
  String get aiGenFooterNotice => 'AI 會撰寫一段雙人對話並合成為音訊。結果將儲存為公開的練習音訊。';

  @override
  String get aiScenarioCoffeeShop => '咖啡店';

  @override
  String get aiScenarioLatestNews => '最新新聞';

  @override
  String get aiScenarioAirportReunion => '機場重聚';

  @override
  String get aiScenarioGroceryStore => '超級市場';

  @override
  String get aiScenarioDoctorVisit => '看醫生';

  @override
  String get aiScenarioJobInterview => '求職面試';

  @override
  String get aiScenarioNewNeighbour => '新鄰居';

  @override
  String get aiScenarioTechSupport => '技術支援';

  @override
  String get aiScenarioBirthdaySurprise => '生日驚喜';

  @override
  String get aiScenarioGymTips => '健身貼士';

  @override
  String get aiScenarioWeatherSmalltalk => '閒聊天氣';

  @override
  String get aiScenarioRestaurantOrder => '餐廳點菜';

  @override
  String get aiScenarioBookRecommendation => '好書推介';

  @override
  String get aiScenarioBusDelay => '巴士延誤';

  @override
  String get aiScenarioMovieDebate => '電影辯論';

  @override
  String get aiScenarioCustom => '自訂…';

  @override
  String get errorNetworkUnreachable => '無法連接 Bantera。請檢查你的網絡連線。';

  @override
  String get errorNetworkCellularBlocked =>
      'Bantera 的流動數據已關閉。請在「設定」中打開 Bantera 並開啟「流動數據」，或連接 Wi-Fi。';

  @override
  String get errorTlsConnection => '無法建立安全連線。';

  @override
  String get settingsRateAppPrompt => '喜歡 Bantera 嗎？在 App Store 為我們評分，對我們意義重大。';

  @override
  String get settingsRateAppButton => '在 App Store 評分';

  @override
  String get settingsSharePrompt => '有朋友在學語言嗎？將 Bantera 分享給他們吧。';

  @override
  String get settingsShareButton => '分享 Bantera';

  @override
  String get settingsContactButton => '聯絡我們';

  @override
  String get localVideoDescription =>
      '從「相片」選擇影片並選擇語音語言，iPhone 會在背景轉錄，完成後即可逐句練習。';

  @override
  String get localVideoStep1Title => '1. 選擇影片';

  @override
  String get localVideoChooseFromPhotos => '從「相片」選擇';

  @override
  String get localVideoChooseDifferent => '選擇其他影片';

  @override
  String get localVideoSelectedFileLabel => '已選檔案';

  @override
  String get localVideoSizeLabel => '大小';

  @override
  String get localVideoDurationLabel => '長度';

  @override
  String get localVideoLongVideoWarning =>
      '此影片超過 3 分鐘，Bantera 可能需要更多時間準備文字稿和翻譯。';

  @override
  String get localVideoStep2Title => '2. 轉錄語言';

  @override
  String get localVideoChooseLanguagePlaceholder => '選擇語音語言';

  @override
  String get localVideoLanguageHint => 'Bantera 會記住你上次選擇的語言，練習開始後會預設隱藏轉錄文字。';

  @override
  String get localVideoStep3Title => '3. 練習';

  @override
  String get localVideoPreparing => '正在準備…';

  @override
  String get localVideoPracticeHint =>
      'Bantera 會先在裝置上轉錄，無需上載任何內容，然後打開逐句聆聽練習頁面。';

  @override
  String get localVideoStatusLongVideo => '影片較長，Bantera 可能需要更多時間轉錄和準備。';

  @override
  String get localVideoStatusTranscribing => '正在裝置上轉錄並準備練習句子…';

  @override
  String get localVideoStatusSaving => '正在將影片儲存到裝置上的練習庫…';

  @override
  String get localVideoStatusTranslationLong =>
      '轉錄完成。Bantera 亦正在為你儲存的語言準備翻譯，此較長的影片可能需要多一點時間。';

  @override
  String get localVideoStatusTranslation => '轉錄完成。正在為你儲存的語言準備翻譯…';

  @override
  String get localVideoPickerTitle => '選擇音訊語言';

  @override
  String get savedCuesTitle => '已儲存的句子';

  @override
  String get savedCuesEmpty => '暫時沒有已儲存的句子。練習時點按書籤圖示即可儲存。';

  @override
  String get savedCuesDeleteTooltip => '移除已儲存的句子';

  @override
  String get savedCuesDeleteConfirmTitle => '要移除此句子嗎？';

  @override
  String get savedCuesDeleteConfirmBody => '此句子將從你的儲存列表中移除。';

  @override
  String get savedCuesDeleteAllTooltip => '刪除所有已儲存的句子';

  @override
  String get savedCuesDeleteAllConfirmTitle => '要刪除所有已儲存的句子嗎？';

  @override
  String get savedCuesDeleteAllConfirmBody => '所有已儲存的句子將被永久刪除。';

  @override
  String get updateAlertTitle => '有可用更新';

  @override
  String get updateAlertMessage => 'Bantera 有新版本。立即更新以獲取最新功能和改進。';

  @override
  String get updateCurrentVersionLabel => '目前版本';

  @override
  String get updateAppStoreVersionLabel => 'App Store 版本';

  @override
  String get updateAlertUpdate => '更新';

  @override
  String get updateAlertLater => '稍後';

  @override
  String get checkForUpdateButton => '檢查更新';

  @override
  String get upToDateAlertTitle => '已是最新版本';

  @override
  String upToDateAlertMessage(Object version) {
    return 'Bantera $version 已是最新版本。';
  }

  @override
  String get sectionSupport => '支援';

  @override
  String get permissionActionAllow => '允許';
}
