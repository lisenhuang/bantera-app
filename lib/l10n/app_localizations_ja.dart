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
  String get sectionRateAndShare => '評価とシェア';

  @override
  String get sectionLanguage => '表示言語';

  @override
  String get sectionPermissions => '権限';

  @override
  String get sectionNotifications => '通知';

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
  String get appPermissionsTitle => 'アプリの権限';

  @override
  String get appPermissionsSubtitle => 'このデバイスでBanteraが使うアクセスを確認します。';

  @override
  String get permissionsIntro => 'Banteraは録音、発音比較、ネットワーク接続のためにこれらのデバイス設定を使います。';

  @override
  String get permissionsOpenSettings => 'iPhoneの設定を開く';

  @override
  String get permissionsRefresh => '更新';

  @override
  String get permissionMicrophoneTitle => 'マイク';

  @override
  String get permissionMicrophoneDescription => '練習の録音とボイスメッセージに使います。';

  @override
  String get permissionSpeechTitle => '音声認識';

  @override
  String get permissionSpeechDescription => '練習録音とボイスメッセージの書き起こしに使います。';

  @override
  String get permissionMobileDataTitle => 'モバイルデータ通信';

  @override
  String get permissionMobileDataDescription =>
      'このiPhoneがWi-Fiに接続されていないときにBanteraを使います。';

  @override
  String get permissionStatusAllowed => '許可済み';

  @override
  String get permissionStatusLimited => '制限あり';

  @override
  String get permissionStatusNotAllowed => '未許可';

  @override
  String get permissionStatusUnknown => '不明';

  @override
  String get signOut => 'サインアウト';

  @override
  String get signOutDialogTitle => 'サインアウトしますか？';

  @override
  String get signOutDialogBody => '再度利用するにはサインインが必要です。';

  @override
  String get cancel => 'キャンセル';

  @override
  String get closeLabel => '閉じる';

  @override
  String get navDiscover => '発見';

  @override
  String get navCreate => '作成';

  @override
  String get navProfile => 'プロフィール';

  @override
  String get chatsTitle => 'チャット';

  @override
  String get chatNoChatsYet => 'まだチャットがありません。';

  @override
  String get chatOnlineSection => 'オンライン';

  @override
  String get chatDirectMessagesSection => 'DM';

  @override
  String chatAudioDuration(String duration) {
    return 'オーディオ $duration';
  }

  @override
  String get chatEnableNotifications => '通知をオンにする';

  @override
  String get chatMuteNotifications => '通知をミュート';

  @override
  String get chatBlockUser => 'ユーザーをブロック';

  @override
  String get chatDeleteDm => 'DMを削除';

  @override
  String get chatGroupReady => 'このグループは音声メッセージを送信できます。';

  @override
  String get chatHoldToStartDm => '長押しして録音し、DMを始めます。';

  @override
  String get chatNoGroupAudio => 'グループ音声はまだありません。';

  @override
  String get chatNoDmAudio => 'このDMにはまだ音声がありません。';

  @override
  String get chatSendingAudio => '音声を送信中...';

  @override
  String get chatRecordingReleaseToSend => '録音中...離すと送信';

  @override
  String get chatHoldToRecordAudio => '長押しして音声を録音';

  @override
  String get chatRecordingStatus => '録音中...';

  @override
  String get chatGroupLabel => 'グループ';

  @override
  String get chatNotificationsEnabledForDm => 'このDMの通知をオンにしました。';

  @override
  String get chatNotificationsMutedForDm => 'このDMの通知をミュートしました。';

  @override
  String chatBlockUserTitle(String user) {
    return '$userをブロックしますか？';
  }

  @override
  String get chatBlockUserBody => 'ブロックを解除するまで、DM送信や共有グループメッセージで互いに表示されなくなります。';

  @override
  String get chatDeleteDmTitle => 'このDMを削除しますか？';

  @override
  String get chatDeleteDmBody => 'これはリストから削除するだけです。新しいメッセージで後から戻ることがあります。';

  @override
  String get chatMicrophoneRequiredTitle => 'マイクが必要です';

  @override
  String get chatMicrophoneRequiredSettings =>
      'チャット音声を録音するにはBanteraにマイクアクセスが必要です。設定で有効にしてください。';

  @override
  String get chatMicrophoneRequiredBody => 'チャット音声を録音するにはBanteraにマイクアクセスが必要です。';

  @override
  String get chatGroupNotReady => 'このグループはまだ準備できていません。';

  @override
  String get chatMessageAction => 'メッセージ';

  @override
  String get chatRetranscribe => '再文字起こし';

  @override
  String get chatTranscribe => '文字起こし';

  @override
  String get chatTranscribingOnDevice => 'このiPhoneで文字起こし中...';

  @override
  String get chatTranscriptionFailed => '文字起こしに失敗しました。もう一度お試しください。';

  @override
  String get chatGroupSettingsTitle => 'グループ設定';

  @override
  String get chatNotifications => '通知';

  @override
  String get chatBlockedUsersMenu => 'ブロック中のユーザー';

  @override
  String get chatBlockedUsersTitle => 'ブロック中のユーザー';

  @override
  String get chatBlockedPeople => 'ブロックした人';

  @override
  String get chatNoBlockedUsers => 'ブロック中のユーザーはいません。';

  @override
  String get chatNoBlockedPeople => 'ブロックした人はいません。';

  @override
  String get chatUnblock => 'ブロック解除';

  @override
  String chatUnblockUserTitle(String user) {
    return '$userのブロックを解除しますか？';
  }

  @override
  String get chatUnblockUserBody => 'DMや共有グループメッセージで再び互いに表示されることがあります。';

  @override
  String get chatUnblockFailed => 'このユーザーのブロックを解除できませんでした。もう一度お試しください。';

  @override
  String get chatNotificationsTitle => 'チャット通知';

  @override
  String get chatNotificationsSubtitle => 'アカウント共通の切り替えをすべてのデバイスで使います。';

  @override
  String get chatNotificationsDisabledTitle => '通知が無効です';

  @override
  String get chatNotificationsDisabledSettings =>
      'Banteraのチャット通知を受け取るには、設定で通知を有効にしてください。';

  @override
  String get chatNotificationsDisabledBody => 'チャット通知を有効にするには通知の許可が必要です。';

  @override
  String get chatNotificationUpdateFailed => 'チャット通知を更新できませんでした。もう一度お試しください。';

  @override
  String get savedTitle => '保存済みメディア';

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
  String get deleteAccountQuestionBody =>
      'お客様の個人情報とデータはすべて、当社のサーバーから永久に削除され、復元することはできません。';

  @override
  String get typeDeleteLabel => '続行するには「DELETE」と入力';

  @override
  String get continueLabel => '続行';

  @override
  String get confirmLabel => '確認';

  @override
  String get deleteLabel => '削除';

  @override
  String get removeFromListLabel => 'リストから削除';

  @override
  String get startLabel => '開始';

  @override
  String get doneLabel => '完了';

  @override
  String get discoverSearchHint => 'タイトルまたは書き起こしを検索…';

  @override
  String get discoverNoMoreResults => 'これ以上結果はありません';

  @override
  String get discoverSetLearningLanguagePrompt => '学習言語を設定するとここにコンテンツが表示されます';

  @override
  String discoverNoPublicContentInLanguage(String language) {
    return '$language の公開コンテンツはまだありません';
  }

  @override
  String get discoverSetLanguageToDiscover => '学習言語を設定してコンテンツを見つけましょう';

  @override
  String get mediaStartPractice => '練習を開始';

  @override
  String get mediaTranscript => '書き起こし';

  @override
  String mediaTranscriptLineCount(int count) {
    return '（$count 行）';
  }

  @override
  String get mediaShow => '表示';

  @override
  String get mediaHide => '非表示';

  @override
  String get mediaNoTranscriptAvailable => '書き起こしはありません。';

  @override
  String get lessonSaveTooltip => '保存';

  @override
  String get lessonUnsaveTooltip => '保存解除';

  @override
  String get mediaKindAudio => '音声';

  @override
  String get mediaKindVideo => '動画';

  @override
  String get practiceNoCues => 'キューがありません';

  @override
  String get practiceTranslating => '翻訳中…';

  @override
  String get practiceShowTranscript => '書き起こしを表示';

  @override
  String get practiceTranslate => '翻訳';

  @override
  String get practiceHideText => 'テキストを隠す';

  @override
  String get practiceTextLabel => 'テキスト';

  @override
  String get practiceStop => '停止';

  @override
  String get practicePlayAll => 'すべて再生';

  @override
  String get practiceCompare => '比較';

  @override
  String get practiceRecord => '録音';

  @override
  String get practiceStopRecording => '停止';

  @override
  String get practiceRecords => '記録';

  @override
  String get practiceRecordsLocalOnlyFooter => '試行はこのデバイスにのみ保存され、アップロードされません。';

  @override
  String get practiceRecordsEmpty => 'この文にはまだ保存された試行がありません。';

  @override
  String get practiceRecordingProcessError => '録音の処理中に問題が発生しました。';

  @override
  String get practiceStartOver => '最初から';

  @override
  String get practiceTranscriptHidden => '書き起こしを非表示';

  @override
  String get practiceListenCarefully => 'よく聞いてください…';

  @override
  String get practiceTranslationUnavailableForCue => 'このキューは今は翻訳できません。';

  @override
  String get practiceChooseTranslationLanguageTitle => '翻訳言語を選択';

  @override
  String get practiceChooseTranslationLanguageDescription =>
      'Banteraはリスニング練習をこの言語に翻訳し、プロフィールに保存して次回以降も使います。';

  @override
  String get practiceChangeTranslationLanguageTitle => '翻訳言語を変更';

  @override
  String get practiceChangeTranslationLanguageDescription =>
      'Banteraが翻訳する言語を選んでください。新しい選択はプロフィールに保存されます。';

  @override
  String get practiceConfirmTranslationLanguageTitle => '翻訳言語の確認';

  @override
  String get practiceConfirmTranslationLanguageBody =>
      'この言語がプロフィールに保存され、今後のリスニング練習の既定の翻訳言語になります。';

  @override
  String get practiceCouldNotSaveTranslationLanguage => '翻訳言語を保存できませんでした。';

  @override
  String get practiceNoTranslationLanguagesFound => 'この書き起こしに使える翻訳言語が見つかりません。';

  @override
  String get practicePlayAllTitle => 'すべて再生';

  @override
  String get practicePlayAllDescription => 'キュー間に一時停止（シャドーイング）：';

  @override
  String get practicePlayAllPauseZeroSeconds => '0秒';

  @override
  String get practicePlayAllPauseOneSecondLabel => '1秒';

  @override
  String get practicePlayAllPauseOneCuePlusOneSecond => '1キュー + 1秒';

  @override
  String get practicePlayAllPauseOneCuePlusTwoSeconds => '1キュー + 2秒';

  @override
  String get practicePlayAllTimesPerCueTitle => '各キューの再生回数';

  @override
  String get practicePlayAllTimesOnce => '1×';

  @override
  String get practicePlayAllTimesTwice => '2×';

  @override
  String get practicePlayAllTimesThrice => '3×';

  @override
  String get practiceSearchLanguagesHint => '言語を検索';

  @override
  String get practiceTranslationInstalled => 'インストール済み';

  @override
  String get practiceTranslationDownload => 'ダウンロード';

  @override
  String get practiceStartOverTitle => '最初からやり直しますか？';

  @override
  String get practiceStartOverBody => '最初のキューに戻りますか？';

  @override
  String get practiceNextFromLastTitle => '最初のキューに移動しますか？';

  @override
  String get practiceNextFromLastBody => '最後のキューです。最初のキューに戻りますか？';

  @override
  String get practiceGoToFirstCue => '最初のキューへ';

  @override
  String get practiceVideoOpenError => '選択した動画を開けませんでした。';

  @override
  String get practiceAudioLoading => '音声を読み込み中…';

  @override
  String practiceAudioLoadingPercent(int percent) {
    return '音声を読み込み中 $percent%';
  }

  @override
  String get practiceAudioError => '音声を読み込めませんでした。もう一度お試しください。';

  @override
  String get compareRecordYourVersion => '自分のバージョンを録音';

  @override
  String compareTranscriptionLanguage(String locale) {
    return '書き起こし言語: $locale';
  }

  @override
  String get compareOpenIphoneSettings => 'iPhoneの設定を開く';

  @override
  String get comparePauseAttempt => '試行を一時停止';

  @override
  String get comparePlayAttempt => '試行を再生';

  @override
  String get compareYourTranscribedAttempt => '書き起こされた試行';

  @override
  String get compareHighlightHint => 'Banteraが異なると認識した語は強調表示されます。';

  @override
  String get compareTryAgain => 'やり直す';

  @override
  String get compareDone => '完了';

  @override
  String get compareStatusTranscribing => 'iPhoneで試行を書き起こし中…';

  @override
  String get compareStatusRecording => '録音中…もう一度タップで停止します。';

  @override
  String get compareStatusSavedAttempt => 'このキューに保存した試行を表示中です。再生するか、もう一度試せます。';

  @override
  String get compareStatusReplayOrRetry => 'この試行を再生するか、キューをやり直せます。';

  @override
  String get compareStatusTapToRecord => 'タップしてこのキューの自分のバージョンを録音します。';

  @override
  String get compareCouldNotStartRecording => '今は録音を開始できません。';

  @override
  String get compareCouldNotAccessRecording => '録音された音声にアクセスできません。';

  @override
  String get compareNoTranscriptGenerated =>
      'この試行の書き起こしを生成できませんでした。マイクに近づいてやり直してください。';

  @override
  String get compareRecentAttempts => '最近の試行';

  @override
  String get compareAttemptsFooterNote =>
      'Banteraは同じキューでの進捗を確認できるよう、このiPhoneに試行を保存します。';

  @override
  String compareMatchedCount(int count) {
    return '一致 $count';
  }

  @override
  String compareDifferentCount(int count) {
    return '相違 $count';
  }

  @override
  String compareMissingCount(int count) {
    return '欠落 $count';
  }

  @override
  String get compareMicrophoneDeniedPermanent =>
      'Banteraのマイクがオフです。iPhoneの設定 > Bantera > マイクでオンにしてください。';

  @override
  String get compareMicrophoneDeniedRestricted =>
      'このiPhoneがBanteraのマイクを制限しています。スクリーンタイムや管理設定を確認してください。';

  @override
  String get compareMicrophoneDeniedDefault =>
      '自分のバージョンを録音するにはマイクの許可が必要です。以前に拒否した場合は、iPhoneの設定 > Bantera > マイクでオンにしてください。';

  @override
  String get compareSpeechRecognitionDeniedPermanent =>
      'Banteraの音声認識がオフです。iPhoneの設定 > Bantera > 音声認識でオンにしてください。';

  @override
  String get compareSpeechRecognitionDeniedRestricted =>
      'このiPhoneがBanteraの音声認識を制限しています。スクリーンタイムや管理設定を確認してください。';

  @override
  String get compareSpeechRecognitionUnavailable =>
      'このiPhoneでは現在、音声認識を利用できません。';

  @override
  String get compareSpeechRecognitionUnsupportedLocale =>
      'このiPhoneでは、この練習言語の音声認識を利用できません。';

  @override
  String get comparePlayAttemptTooltip => '試行を再生';

  @override
  String get comparePauseAttemptTooltip => '試行を一時停止';

  @override
  String get createWhatToday => '今日は何をしますか？';

  @override
  String get createPracticeVideo => '動画で練習';

  @override
  String get createYourMedia => '自分のメディア';

  @override
  String get createTryAgain => '再試行';

  @override
  String get createUploadedVideosEmptyHint =>
      'アップロードした動画がここに表示され、いつでも開いてキューごとに練習できます。';

  @override
  String get createUploadingTips => 'アップロードのヒント';

  @override
  String get createUploadingTipsBody =>
      'エンゲージメントのため音声は3分以内がおすすめです。字幕は自動で生成されます！';

  @override
  String get createOnThisIphone => 'このiPhone上の動画';

  @override
  String get createLocalVideosEmptyHint =>
      'ローカルで練習した動画はこのiPhoneに保存され、後から再び開けます（再書き起こし不要）。';

  @override
  String get createOnDeviceBadge => '端末内';

  @override
  String get createSignInToLoadVideos => 'アップロードした動画を読み込むには再度サインインしてください。';

  @override
  String createVideoMetaCues(int count) {
    return 'キュー $count件';
  }

  @override
  String get createPublicBadge => '公開';

  @override
  String get createPrivateBadge => '非公開';

  @override
  String get createAiBadge => 'AI';

  @override
  String get createDeleteSavedVideoTitle => '保存した動画を削除しますか？';

  @override
  String createDeleteSavedVideoBody(String title) {
    return 'BanteraはこのiPhoneから「$title」を削除し、保存した書き起こしキューも削除します。';
  }

  @override
  String get createDeleteMediaTitle => 'メディアを削除しますか？';

  @override
  String createDeleteMediaBody(String title) {
    return '「$title」と書き起こしが完全に削除されます。元に戻せません。';
  }

  @override
  String get removeFromListTitle => 'リストから削除しますか？';

  @override
  String get removeFromListBody => 'この項目はリストから削除され、元に戻せません。';

  @override
  String get editProfileChangeImage => 'プロフィール写真を変更';

  @override
  String get editProfileUploading => 'アップロード中…';

  @override
  String get editProfileNameLabel => '名前';

  @override
  String get editProfileNameHint => 'Banteraにどのように表示しますか？';

  @override
  String get editProfileSaveNameButton => '名前を保存';

  @override
  String get editProfileSaving => '保存中…';

  @override
  String get editProfileLanguagesSection => '言語';

  @override
  String get editProfileMyNativeLanguage => '母語';

  @override
  String get editProfileMyNativeLanguageSubtitle => '母語または第一言語';

  @override
  String get editProfileLearningLanguage => '学習言語';

  @override
  String get editProfileLearningLanguageSubtitle => '練習したい言語';

  @override
  String get editProfileImageUpdated => 'プロフィール写真を更新しました。';

  @override
  String get editProfileNameUpdated => '名前を更新しました。';

  @override
  String get editProfileEnterName => '名前を入力してください。';

  @override
  String get editProfileNameMaxLength => '80文字以内にしてください。';

  @override
  String get editProfileCouldNotLoadLanguages => '言語リストを読み込めませんでした。';

  @override
  String get languagePickerNone => 'なし';

  @override
  String get languagePickerClearSelection => '選択をクリア';

  @override
  String get languagePickerNoMatchingLanguages => '該当する言語がありません。';

  @override
  String get languagePickerMoreComingSoon => '対応言語は順次拡大予定';

  @override
  String get editProfileNativeLanguageCleared => '母語をクリアしました。';

  @override
  String get editProfileLearningLanguageCleared => '学習言語をクリアしました。';

  @override
  String editProfileNativeLanguageSetTo(String language) {
    return '母語を$languageに設定しました。';
  }

  @override
  String editProfileLearningLanguageSetTo(String language) {
    return '学習言語を$languageに設定しました。';
  }

  @override
  String get profileLanguageSettings => '言語設定';

  @override
  String get profileLearningLabel => '学習';

  @override
  String get profileNotSet => '未設定';

  @override
  String get uploadedDetailYourAudio => 'あなたの音声';

  @override
  String get uploadedDetailYourVideo => 'あなたの動画';

  @override
  String get uploadedDetailDeleteAudioTitle => '音声を削除しますか？';

  @override
  String get uploadedDetailDeleteAudioBody => '音声と書き起こしが永久に削除されます。元に戻せません。';

  @override
  String get uploadedDetailDeleteVideoTitle => '動画を削除しますか？';

  @override
  String get uploadedDetailDeleteVideoBody => '動画と書き起こしが永久に削除されます。元に戻せません。';

  @override
  String get uploadedDetailAiGenerated => 'AI生成';

  @override
  String get uploadedDetailFileSize => 'ファイルサイズ';

  @override
  String get uploadedDetailResolution => '解像度';

  @override
  String get uploadedDetailResolutionUnknown => '不明';

  @override
  String get uploadedDetailTranscribing => '書き起こし中…';

  @override
  String get uploadedDetailNoTranscriptCuesYet => '書き起こしのキューはまだありません。';

  @override
  String uploadedDetailMediaDescription(int count) {
    return 'アップロードした練習クリップ。書き起こしキューは$count件。';
  }

  @override
  String get uploadedDetailTranscriptionFailedFallback =>
      '書き起こしに失敗しました。推定キューを使用します。';

  @override
  String get uploadedDetailTranscriptionNoCues => '書き起こし結果にキューがありません。';

  @override
  String get uploadedDetailTranscriptionSourceYourUpload => 'あなたのアップロード';

  @override
  String get aiGenLeaveTitle => 'このページを離れますか？';

  @override
  String get aiGenLeaveBody => '音声を生成中です。今離れると処理がキャンセルされます。';

  @override
  String get aiGenStay => '留まる';

  @override
  String get aiGenLeave => '離れる';

  @override
  String get aiGenLoadingTitle => '音声を作成しています…';

  @override
  String get aiGenLoadingSubtitle =>
      '最大で1分ほどかかることがあります。\n生成中はこのページを開いたままにしてください。';

  @override
  String get aiGenStepPreparingSpeechModel => '端末内音声モデルを準備中';

  @override
  String get aiGenStepWritingDialogue => '台本を作成中';

  @override
  String get aiGenStepGeneratingAudio => '音声を生成中';

  @override
  String get aiGenStepAligningAudio => '音声を調整中';

  @override
  String get aiGenStepTranscribing => '書き起こし中';

  @override
  String get aiGenStepCorrectingTranscript => '書き起こしを校正';

  @override
  String get aiGenLanguageSection => '言語';

  @override
  String get aiGenSetLearningLanguagePrompt => '生成を使うには学習言語を設定してください';

  @override
  String get aiGenLoadingLanguage => '言語を読み込み中…';

  @override
  String aiGenLanguageUnsupported(String language) {
    return '「$language」は生成に対応していません。';
  }

  @override
  String get aiGenScenarioSection => 'シナリオ';

  @override
  String get aiGenScenarioOptionalHint => '任意 — 選ばない場合はランダムなシナリオになります。';

  @override
  String get aiGenCustomScenarioHint => 'シナリオを説明…';

  @override
  String get aiGenDurationSection => '長さ';

  @override
  String aiGenDurationMinutes(int minutes) {
    return '$minutes分';
  }

  @override
  String get aiGenGenerateButton => '生成';

  @override
  String get aiGenOwnershipNotice =>
      'ここで生成した音声は Bantera のコミュニティコンテンツとなり、すべての学習者向けの練習素材として公開共有されます。';

  @override
  String get aiGenOwnershipCheckbox => 'この音声を Bantera コミュニティコンテンツとして共有する';

  @override
  String get aiGenOwnershipConfirmTitle => 'コミュニティコンテンツとして共有しますか？';

  @override
  String get aiGenOwnershipConfirmCancel => 'キャンセル';

  @override
  String get aiGenOwnershipConfirmGenerate => '生成';

  @override
  String get aiGenFooterNotice =>
      'AIが2人の会話を書き起こし、音声に合成します。結果は公開の練習用音声として保存されます。';

  @override
  String get aiScenarioCoffeeShop => 'コーヒーショップ';

  @override
  String get aiScenarioLatestNews => '最新ニュース';

  @override
  String get aiScenarioAirportReunion => '空港の再会';

  @override
  String get aiScenarioGroceryStore => 'スーパー';

  @override
  String get aiScenarioDoctorVisit => '診察';

  @override
  String get aiScenarioJobInterview => '就職面接';

  @override
  String get aiScenarioNewNeighbour => '新しいご近所さん';

  @override
  String get aiScenarioTechSupport => 'テックサポート';

  @override
  String get aiScenarioBirthdaySurprise => '誕生日サプライズ';

  @override
  String get aiScenarioGymTips => 'ジムのアドバイス';

  @override
  String get aiScenarioWeatherSmalltalk => '天気の雑談';

  @override
  String get aiScenarioRestaurantOrder => 'レストランで注文';

  @override
  String get aiScenarioBookRecommendation => '本のおすすめ';

  @override
  String get aiScenarioBusDelay => 'バスの遅延';

  @override
  String get aiScenarioMovieDebate => '映画の議論';

  @override
  String get aiScenarioCustom => 'カスタム…';

  @override
  String get errorNetworkUnreachable => 'Bantera に接続できません。インターネット接続を確認してください。';

  @override
  String get errorNetworkCellularBlocked =>
      'Bantera のモバイルデータ通信がオフです。「設定」で Bantera を開き「モバイルデータ通信」をオンにするか、Wi-Fi に接続してください。';

  @override
  String get errorTlsConnection => '安全な接続を確立できませんでした。';

  @override
  String get settingsRateAppPrompt =>
      'Bantera を気に入っていただけましたか？App Store でご評価いただけると、大変励みになります。';

  @override
  String get settingsRateAppButton => 'App Store で評価する';

  @override
  String get settingsSharePrompt => '語学学習中の友人はいますか？Bantera をシェアしてみましょう。';

  @override
  String get settingsShareButton => 'Bantera をシェア';

  @override
  String get settingsContactButton => 'お問い合わせ';

  @override
  String get localVideoDescription =>
      '写真から動画を選択し、言語を選んだ後、iPhone がバックグラウンドで文字起こしをして、キューごとの練習が始まります。';

  @override
  String get localVideoStep1Title => '1. 動画を選択';

  @override
  String get localVideoChooseFromPhotos => '写真から選択';

  @override
  String get localVideoChooseDifferent => '別の動画を選択';

  @override
  String get localVideoSelectedFileLabel => '選択したファイル';

  @override
  String get localVideoSizeLabel => 'サイズ';

  @override
  String get localVideoDurationLabel => '再生時間';

  @override
  String get localVideoLongVideoWarning =>
      'この動画は3分以上あるため、Bantera が文字起こしと翻訳を準備するのに時間がかかる場合があります。';

  @override
  String get localVideoStep2Title => '2. 文字起こし言語';

  @override
  String get localVideoChooseLanguagePlaceholder => '音声言語を選択';

  @override
  String get localVideoLanguageHint =>
      'Bantera は最後に選択した言語を記憶し、練習開始時はデフォルトで文字起こしを非表示にします。';

  @override
  String get localVideoStep3Title => '3. 練習';

  @override
  String get localVideoPreparing => '準備中...';

  @override
  String get localVideoPracticeHint =>
      'Bantera はまずデバイスで文字起こしを行い、アップロードなしでキューごとのリスニングページを開きます。';

  @override
  String get localVideoStatusLongVideo =>
      '動画が長いため、Bantera が文字起こしと準備に時間がかかる場合があります。';

  @override
  String get localVideoStatusTranscribing => 'デバイスで文字起こしし、練習キューを準備しています...';

  @override
  String get localVideoStatusSaving => '動画をデバイスの練習ライブラリに保存しています...';

  @override
  String get localVideoStatusTranslationLong =>
      '文字起こし完了。長い動画のため、保存した言語の翻訳準備にもう少し時間がかかる場合があります。';

  @override
  String get localVideoStatusTranslation => '文字起こし完了。保存した言語の翻訳を準備しています...';

  @override
  String get localVideoPickerTitle => '音声言語を選択';

  @override
  String get savedCuesTitle => '保存したキュー';

  @override
  String get savedCuesEmpty => 'まだ保存したキューはありません。練習中にブックマークアイコンをタップして保存できます。';

  @override
  String get savedCuesDeleteTooltip => '保存したキューを削除';

  @override
  String get savedCuesDeleteConfirmTitle => 'このキューを削除しますか？';

  @override
  String get savedCuesDeleteConfirmBody => 'このキューが保存リストから削除されます。';

  @override
  String get savedCuesDeleteAllTooltip => '保存したキューをすべて削除';

  @override
  String get savedCuesDeleteAllConfirmTitle => 'すべての保存したキューを削除しますか？';

  @override
  String get savedCuesDeleteAllConfirmBody => '保存したキューがすべて完全に削除されます。';

  @override
  String get updateAlertTitle => 'アップデートがあります';

  @override
  String get updateAlertMessage =>
      'Bantera の新しいバージョンが利用可能です。今すぐアップデートして最新の機能と改善をお楽しみください。';

  @override
  String get updateAlertUpdate => 'アップデート';

  @override
  String get updateAlertLater => '後で';

  @override
  String get checkForUpdateButton => 'アップデートを確認';

  @override
  String get upToDateAlertTitle => '最新版です';

  @override
  String upToDateAlertMessage(Object version) {
    return 'Bantera $version は最新バージョンです。';
  }

  @override
  String get sectionSupport => 'サポート';

  @override
  String get permissionActionAllow => '許可';
}
