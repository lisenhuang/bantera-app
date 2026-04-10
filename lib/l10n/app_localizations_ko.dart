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

  @override
  String get confirmLabel => '확인';

  @override
  String get deleteLabel => '삭제';

  @override
  String get startLabel => '시작';

  @override
  String get doneLabel => '완료';

  @override
  String get discoverSearchHint => '제목이나 자막 검색…';

  @override
  String get discoverNoMoreResults => '더 이상 결과 없음';

  @override
  String get discoverSetLearningLanguagePrompt => '학습 언어를 설정하면 여기에 콘텐츠가 표시됩니다';

  @override
  String discoverNoPublicContentInLanguage(String language) {
    return '$language 공개 콘텐츠가 아직 없습니다';
  }

  @override
  String get discoverSetLanguageToDiscover => '학습 언어를 설정해 콘텐츠를 찾아보세요';

  @override
  String get mediaStartPractice => '연습 시작';

  @override
  String get mediaTranscript => '대본';

  @override
  String mediaTranscriptLineCount(int count) {
    return '($count줄)';
  }

  @override
  String get mediaShow => '펼치기';

  @override
  String get mediaHide => '접기';

  @override
  String get mediaNoTranscriptAvailable => '대본이 없습니다.';

  @override
  String get lessonSaveTooltip => '저장';

  @override
  String get lessonUnsaveTooltip => '저장 취소';

  @override
  String get mediaKindAudio => '오디오';

  @override
  String get mediaKindVideo => '동영상';

  @override
  String get practiceNoCues => '큐가 없습니다';

  @override
  String get practiceTranslating => '번역 중…';

  @override
  String get practiceShowTranscript => '대본 보기';

  @override
  String get practiceTranslate => '번역';

  @override
  String get practiceHideText => '글 숨기기';

  @override
  String get practiceStop => '정지';

  @override
  String get practicePlayAll => '전체 재생';

  @override
  String get practiceCompare => '비교';

  @override
  String get practiceRecord => '녹음';

  @override
  String get practiceStopRecording => '중지';

  @override
  String get practiceRecords => '기록';

  @override
  String get practiceRecordsLocalOnlyFooter => '시도는 이 기기에만 저장되며 업로드되지 않습니다.';

  @override
  String get practiceRecordsEmpty => '이 문장에 저장된 시도가 없습니다.';

  @override
  String get practiceRecordingProcessError => '녹음을 처리하는 중 문제가 발생했습니다.';

  @override
  String get practiceStartOver => '처음부터';

  @override
  String get practiceTranscriptHidden => '대본 숨김';

  @override
  String get practiceListenCarefully => '잘 들어보세요…';

  @override
  String get practiceTranslationUnavailableForCue => '이 큐는 지금 번역할 수 없습니다.';

  @override
  String get practiceChooseTranslationLanguageTitle => '번역 언어 선택';

  @override
  String get practiceChooseTranslationLanguageDescription =>
      'Bantera가 듣기 연습을 이 언어로 번역하고 프로필에 저장해 다음에도 사용합니다.';

  @override
  String get practiceChangeTranslationLanguageTitle => '번역 언어 변경';

  @override
  String get practiceChangeTranslationLanguageDescription =>
      'Bantera가 번역할 언어를 선택하세요. 새 선택이 프로필에 저장됩니다.';

  @override
  String get practiceConfirmTranslationLanguageTitle => '번역 언어 확인';

  @override
  String get practiceConfirmTranslationLanguageBody =>
      '이 언어가 프로필에 저장되어 앞으로 듣기 연습의 기본 번역 언어로 사용됩니다.';

  @override
  String get practiceCouldNotSaveTranslationLanguage => '번역 언어를 저장할 수 없습니다.';

  @override
  String get practiceNoTranslationLanguagesFound =>
      '이 대본에 사용할 수 있는 번역 언어를 찾을 수 없습니다.';

  @override
  String get practicePlayAllTitle => '전체 재생';

  @override
  String get practicePlayAllDescription => '큐 사이에 멈춤(따라 말하기):';

  @override
  String get practicePlayAllPauseNoneTitle => '추가 멈춤 없음 (0초)';

  @override
  String get practicePlayAllPauseNoneSubtitle => '끊김 없이 재생';

  @override
  String get practicePlayAllPauseOneSecond => '1초';

  @override
  String get practicePlayAllPauseOneCueTitle => '1× 큐 길이';

  @override
  String get practicePlayAllPauseOneCueSubtitle => '방금 재생한 큐만큼 멈춤';

  @override
  String get practicePlayAllPauseTwoCuesTitle => '2× 큐 길이';

  @override
  String get practicePlayAllPauseTwoCuesSubtitle => '방금 재생한 큐의 두 배만큼 멈춤';

  @override
  String get practicePlayAllTimesPerCueTitle => '큐당 재생 횟수';

  @override
  String get practicePlayAllTimesOnce => '1×';

  @override
  String get practicePlayAllTimesTwice => '2×';

  @override
  String get practicePlayAllTimesThrice => '3×';

  @override
  String get practiceSearchLanguagesHint => '언어 검색';

  @override
  String get practiceTranslationInstalled => '설치됨';

  @override
  String get practiceTranslationDownload => '다운로드';

  @override
  String get practiceStartOverTitle => '처음부터?';

  @override
  String get practiceStartOverBody => '첫 번째 큐로 돌아갈까요?';

  @override
  String get practiceNextFromLastTitle => '첫 큐로 이동할까요?';

  @override
  String get practiceNextFromLastBody => '마지막 큐입니다. 첫 큐로 돌아갈까요?';

  @override
  String get practiceGoToFirstCue => '첫 큐로 이동';

  @override
  String get practiceVideoOpenError => '선택한 동영상을 열 수 없습니다.';

  @override
  String practiceAudioError(String message) {
    return '오디오 오류: $message';
  }

  @override
  String get compareRecordYourVersion => '내 버전 녹음';

  @override
  String compareTranscriptionLanguage(String locale) {
    return '전사 언어: $locale';
  }

  @override
  String get compareOpenIphoneSettings => 'iPhone 설정 열기';

  @override
  String get comparePauseAttempt => '시도 일시정지';

  @override
  String get comparePlayAttempt => '시도 재생';

  @override
  String get compareYourTranscribedAttempt => '전사된 시도';

  @override
  String get compareHighlightHint => 'Bantera가 다르게 인식한 단어는 강조됩니다.';

  @override
  String get compareTryAgain => '다시 시도';

  @override
  String get compareDone => '완료';

  @override
  String get compareStatusTranscribing => 'iPhone에서 시도 전사 중…';

  @override
  String get compareStatusRecording => '녹음 중… 다시 탭하면 중지합니다.';

  @override
  String get compareStatusSavedAttempt =>
      '이 큐에 저장된 시도를 표시 중입니다. 다시 재생하거나 다시 시도하세요.';

  @override
  String get compareStatusReplayOrRetry => '이 시도를 다시 재생하거나 큐를 다시 연습할 수 있습니다.';

  @override
  String get compareStatusTapToRecord => '탭하여 이 큐의 버전을 녹음하세요.';

  @override
  String get compareCouldNotStartRecording => '지금은 녹음을 시작할 수 없습니다.';

  @override
  String get compareCouldNotAccessRecording => '녹음된 오디오에 접근할 수 없습니다.';

  @override
  String get compareNoTranscriptGenerated =>
      '이 시도에 대한 전사를 만들 수 없습니다. 마이크에 더 가까이서 다시 시도하세요.';

  @override
  String get compareRecentAttempts => '최근 시도';

  @override
  String get compareAttemptsFooterNote =>
      'Bantera는 같은 큐에서 진행 상황을 볼 수 있도록 이 iPhone에 시도를 저장합니다.';

  @override
  String compareMatchedCount(int count) {
    return '일치 $count개';
  }

  @override
  String compareDifferentCount(int count) {
    return '다름 $count개';
  }

  @override
  String compareMissingCount(int count) {
    return '누락 $count개';
  }

  @override
  String get compareMicrophoneDeniedPermanent =>
      'Bantera의 마이크 접근이 꺼져 있습니다. iPhone 설정 > Bantera > 마이크에서 켜 주세요.';

  @override
  String get compareMicrophoneDeniedRestricted =>
      '이 iPhone이 Bantera의 마이크 사용을 제한하고 있습니다. 스크린 타임·기기 관리·시스템 설정을 확인하세요.';

  @override
  String get compareMicrophoneDeniedDefault =>
      '내 버전을 녹음하려면 마이크 권한이 필요합니다. 이전에 요청을 닫았다면 iPhone 설정 > Bantera > 마이크에서 켜 주세요.';

  @override
  String get comparePlayAttemptTooltip => '시도 재생';

  @override
  String get comparePauseAttemptTooltip => '시도 일시정지';

  @override
  String get createWhatToday => '오늘 무엇을 하시겠어요?';

  @override
  String get createPracticeVideo => '동영상 연습';

  @override
  String get createYourMedia => '내 미디어';

  @override
  String get createTryAgain => '다시 시도';

  @override
  String get createUploadedVideosEmptyHint =>
      '업로드한 동영상이 여기에 표시되며, 언제든 열어 큐별로 연습할 수 있습니다.';

  @override
  String get createUploadingTips => '업로드 팁';

  @override
  String get createUploadingTipsBody =>
      '참여도를 위해 오디오는 3분 이내로 유지하세요. 자막은 자동으로 생성됩니다!';

  @override
  String get createOnThisIphone => '이 iPhone에 있는 동영상';

  @override
  String get createLocalVideosEmptyHint =>
      '로컬로 연습한 동영상은 이 iPhone에 저장되어 나중에 다시 열 수 있으며 다시 전사할 필요가 없습니다.';

  @override
  String get createOnDeviceBadge => '기기 내';

  @override
  String get createSignInToLoadVideos => '업로드한 동영상을 불러오려면 다시 로그인하세요.';

  @override
  String createVideoMetaCues(int count) {
    return '큐 $count개';
  }

  @override
  String get createPublicBadge => '공개';

  @override
  String get createPrivateBadge => '비공개';

  @override
  String get createAiBadge => 'AI';

  @override
  String get createDeleteSavedVideoTitle => '저장한 동영상을 삭제할까요?';

  @override
  String createDeleteSavedVideoBody(String title) {
    return 'Bantera가 이 iPhone에서 \"$title\"을(를) 제거하고 저장된 대본 큐를 삭제합니다.';
  }

  @override
  String get createDeleteMediaTitle => '미디어를 삭제할까요?';

  @override
  String createDeleteMediaBody(String title) {
    return '\"$title\"과(와) 대본이 영구 삭제됩니다. 되돌릴 수 없습니다.';
  }

  @override
  String get editProfileChangeImage => '프로필 사진 변경';

  @override
  String get editProfileUploading => '업로드 중…';

  @override
  String get editProfileNameLabel => '이름';

  @override
  String get editProfileNameHint => 'Bantera에 어떻게 표시할까요?';

  @override
  String get editProfileSaveNameButton => '이름 저장';

  @override
  String get editProfileSaving => '저장 중…';

  @override
  String get editProfileLanguagesSection => '언어';

  @override
  String get editProfileMyNativeLanguage => '모국어';

  @override
  String get editProfileMyNativeLanguageSubtitle => '모국어 또는 첫 언어';

  @override
  String get editProfileLearningLanguage => '학습 언어';

  @override
  String get editProfileLearningLanguageSubtitle => '연습하고 싶은 언어';

  @override
  String get editProfileImageUpdated => '프로필 사진이 업데이트되었습니다.';

  @override
  String get editProfileNameUpdated => '이름이 업데이트되었습니다.';

  @override
  String get editProfileEnterName => '이름을 입력하세요.';

  @override
  String get editProfileNameMaxLength => '80자 이하여야 합니다.';

  @override
  String get editProfileCouldNotLoadLanguages => '언어 목록을 불러올 수 없습니다.';

  @override
  String get languagePickerNone => '없음';

  @override
  String get languagePickerClearSelection => '선택 해제';

  @override
  String get languagePickerNoMatchingLanguages => '언어를 찾을 수 없습니다.';

  @override
  String get editProfileNativeLanguageCleared => '모국어가 지워졌습니다.';

  @override
  String get editProfileLearningLanguageCleared => '학습 언어가 지워졌습니다.';

  @override
  String editProfileNativeLanguageSetTo(String language) {
    return '모국어가 $language(으)로 설정되었습니다.';
  }

  @override
  String editProfileLearningLanguageSetTo(String language) {
    return '학습 언어가 $language(으)로 설정되었습니다.';
  }

  @override
  String get profileLanguageSettings => '언어 설정';

  @override
  String get profileLearningLabel => '학습';

  @override
  String get profileNotSet => '미설정';

  @override
  String get uploadedDetailYourAudio => '내 오디오';

  @override
  String get uploadedDetailYourVideo => '내 동영상';

  @override
  String get uploadedDetailDeleteAudioTitle => '오디오를 삭제할까요?';

  @override
  String get uploadedDetailDeleteAudioBody => '오디오와 대본이 영구 삭제됩니다. 되돌릴 수 없습니다.';

  @override
  String get uploadedDetailDeleteVideoTitle => '동영상을 삭제할까요?';

  @override
  String get uploadedDetailDeleteVideoBody => '동영상과 대본이 영구 삭제됩니다. 되돌릴 수 없습니다.';

  @override
  String get uploadedDetailAiGenerated => 'AI 생성';

  @override
  String get uploadedDetailFileSize => '파일 크기';

  @override
  String get uploadedDetailResolution => '해상도';

  @override
  String get uploadedDetailResolutionUnknown => '알 수 없음';

  @override
  String get uploadedDetailTranscribing => '전사 중…';

  @override
  String get uploadedDetailNoTranscriptCuesYet => '아직 전사 큐가 없습니다.';

  @override
  String uploadedDetailMediaDescription(int count) {
    return '업로드한 연습 클립, 전사 큐 $count개.';
  }

  @override
  String get uploadedDetailTranscriptionFailedFallback =>
      '전사에 실패했습니다. 추정 큐를 사용합니다.';

  @override
  String get uploadedDetailTranscriptionNoCues => '전사 결과에 큐가 없습니다.';

  @override
  String get uploadedDetailTranscriptionSourceYourUpload => '내 업로드';

  @override
  String get aiGenLeaveTitle => '이 페이지에서 나갈까요?';

  @override
  String get aiGenLeaveBody => '오디오를 생성 중입니다. 지금 나가면 작업이 취소됩니다.';

  @override
  String get aiGenStay => '머무르기';

  @override
  String get aiGenLeave => '나가기';

  @override
  String get aiGenLoadingTitle => '오디오를 만드는 중…';

  @override
  String get aiGenLoadingSubtitle =>
      '최대 1분 정도 걸릴 수 있습니다.\n생성 중에는 이 페이지에 머물러 주세요.';

  @override
  String get aiGenStepPreparingSpeechModel => '온디바이스 음성 모델 준비 중';

  @override
  String get aiGenStepWritingDialogue => '대화 작성 중';

  @override
  String get aiGenStepGeneratingAudio => '오디오 생성 중';

  @override
  String get aiGenStepTranscribing => '전사 중';

  @override
  String get aiGenStepCorrectingTranscript => '대본 교정 중';

  @override
  String get aiGenLanguageSection => '언어';

  @override
  String get aiGenSetLearningLanguagePrompt => '생성을 켜려면 학습 언어를 설정하세요';

  @override
  String get aiGenLoadingLanguage => '언어 불러오는 중…';

  @override
  String aiGenLanguageUnsupported(String language) {
    return '\"$language\" 언어는 생성을 지원하지 않습니다.';
  }

  @override
  String get aiGenScenarioSection => '시나리오';

  @override
  String get aiGenScenarioOptionalHint => '선택 사항 — 비워 두면 무작위 시나리오가 사용됩니다.';

  @override
  String get aiGenCustomScenarioHint => '시나리오를 설명하세요…';

  @override
  String get aiGenDurationSection => '길이';

  @override
  String aiGenDurationMinutes(int minutes) {
    return '$minutes분';
  }

  @override
  String get aiGenGenerateButton => '생성';

  @override
  String get aiGenFooterNotice =>
      'AI가 두 명의 대화를 쓰고 오디오로 합성합니다. 결과는 공개 연습 오디오로 저장됩니다.';

  @override
  String get aiScenarioCoffeeShop => '카페';

  @override
  String get aiScenarioAirportReunion => '공항에서 재회';

  @override
  String get aiScenarioGroceryStore => '마트';

  @override
  String get aiScenarioDoctorVisit => '병원 진료';

  @override
  String get aiScenarioJobInterview => '취업 면접';

  @override
  String get aiScenarioNewNeighbour => '새 이웃';

  @override
  String get aiScenarioTechSupport => '기술 지원';

  @override
  String get aiScenarioBirthdaySurprise => '깜짝 생일 파티';

  @override
  String get aiScenarioGymTips => '헬스 팁';

  @override
  String get aiScenarioWeatherSmalltalk => '날씨 잡담';

  @override
  String get aiScenarioRestaurantOrder => '레스토랑 주문';

  @override
  String get aiScenarioBookRecommendation => '책 추천';

  @override
  String get aiScenarioBusDelay => '버스 지연';

  @override
  String get aiScenarioMovieDebate => '영화 토론';

  @override
  String get aiScenarioCustom => '사용자 지정…';
}
