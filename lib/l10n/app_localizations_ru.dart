// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Bantera';

  @override
  String get appTagline => 'Практика языка — фраза за фразой.';

  @override
  String get authContinueWithApple => 'Продолжить с Apple';

  @override
  String get authContinueWithGoogle => 'Продолжить с Google';

  @override
  String get authAppleUnavailable =>
      'Вход с Apple недоступен на этом устройстве.';

  @override
  String get authOrSignInEmail => 'или войди по email';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Пароль';

  @override
  String get authSigningIn => 'Вход...';

  @override
  String get authSignIn => 'Войти';

  @override
  String get authSignInWithEmail => 'Войти по email';

  @override
  String get validationEnterEmail => 'Введи email.';

  @override
  String get validationValidEmail => 'Введи корректный email.';

  @override
  String get validationEnterPassword => 'Введи пароль.';

  @override
  String get onboardingTitle => 'Настрой профиль';

  @override
  String get onboardingSubtitle =>
      'Так Bantera сможет подстроить практику и чаты под тебя.';

  @override
  String get onboardingNameTitle => 'Как тебя называть?';

  @override
  String get onboardingNameSubtitle =>
      'Мы взяли имя из твоего аккаунта Apple. Можешь изменить его прямо сейчас.';

  @override
  String get onboardingClearName => 'Очистить имя';

  @override
  String get onboardingNativeLanguageTitle => 'Какой у тебя родной язык?';

  @override
  String get onboardingNativeLanguageSubtitle =>
      'Bantera использует его для перевода и языковых групп.';

  @override
  String get onboardingLearningLanguageTitle => 'Какой язык ты изучаешь?';

  @override
  String get onboardingLearningLanguageSubtitle =>
      'От него зависят материалы для практики и учебные группы.';

  @override
  String get onboardingAvatarTitle => 'Добавь фото профиля';

  @override
  String get onboardingAvatarSubtitle =>
      'Выбери фото или продолжи — Bantera создаст аватар за тебя.';

  @override
  String get onboardingAvatarGenderTitle => 'Создание фото профиля';

  @override
  String get onboardingAvatarGenderBody =>
      'Выбери, каким Bantera создаст твой аватар. Мы не сохраняем этот выбор — он нужен только для этого изображения.';

  @override
  String get onboardingAvatarGenderMale => 'Мужской';

  @override
  String get onboardingAvatarGenderFemale => 'Женский';

  @override
  String get onboardingChoosePhoto => 'Выбрать фото';

  @override
  String get onboardingChangePhoto => 'Сменить фото';

  @override
  String get onboardingUseGeneratedAvatar => 'Использовать созданный аватар';

  @override
  String get onboardingUseCurrentPhoto => 'Оставить текущее фото';

  @override
  String get onboardingChooseLanguage => 'Выбери язык';

  @override
  String get onboardingBack => 'Назад';

  @override
  String get onboardingFinish => 'Готово';

  @override
  String get onboardingLoadingProfile => 'Загрузка профиля...';

  @override
  String get onboardingSavingProfile => 'Сохранение профиля...';

  @override
  String get onboardingLoadFailed => 'Что-то пошло не так. Попробуй ещё раз.';

  @override
  String get onboardingSearchHint => 'Поиск языков…';

  @override
  String get onboardingRetry => 'Повторить';

  @override
  String get onboardingNoMatching => 'Языки не найдены.';

  @override
  String get onboardingFailedSave => 'Не удалось сохранить.';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get sectionAppearance => 'Оформление';

  @override
  String get sectionAccount => 'Аккаунт';

  @override
  String get sectionRateAndShare => 'Оценить и поделиться';

  @override
  String get sectionLanguage => 'Язык интерфейса';

  @override
  String get sectionPermissions => 'Разрешения';

  @override
  String get sectionNotifications => 'Уведомления';

  @override
  String get languageSectionSubtitle =>
      'Выбери язык приложения. «Системный» — как в настройках устройства.';

  @override
  String get themeLabel => 'Тема';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get themeSystem => 'Системная';

  @override
  String get languageEnglish => 'Английский';

  @override
  String get languageChineseSimplified => 'Китайский (упрощённый)';

  @override
  String get languageKorean => 'Корейский';

  @override
  String get languageJapanese => 'Японский';

  @override
  String get signedOutLabel => 'Вход не выполнен';

  @override
  String get noActiveSession => 'Нет активного сеанса Bantera';

  @override
  String signedInWith(String provider) {
    return 'Вход через $provider';
  }

  @override
  String get editProfile => 'Редактировать профиль';

  @override
  String get more => 'Ещё';

  @override
  String get appPermissionsTitle => 'Разрешения приложения';

  @override
  String get appPermissionsSubtitle =>
      'Проверь, к чему Bantera имеет доступ на этом устройстве.';

  @override
  String get permissionsIntro =>
      'Bantera использует эти настройки устройства для записи, сравнения речи и доступа к сети.';

  @override
  String get permissionsOpenSettings => 'Открыть настройки iPhone';

  @override
  String get permissionsRefresh => 'Обновить';

  @override
  String get permissionMicrophoneTitle => 'Микрофон';

  @override
  String get permissionMicrophoneDescription =>
      'Запись попыток и голосовых сообщений.';

  @override
  String get permissionSpeechTitle => 'Распознавание речи';

  @override
  String get permissionSpeechDescription =>
      'Расшифровка записей и голосовых сообщений.';

  @override
  String get permissionMobileDataTitle => 'Сотовые данные';

  @override
  String get permissionMobileDataDescription =>
      'Использовать Bantera, когда iPhone не подключён к Wi-Fi.';

  @override
  String get permissionStatusAllowed => 'Разрешено';

  @override
  String get permissionStatusLimited => 'Ограничено';

  @override
  String get permissionStatusNotAllowed => 'Не разрешено';

  @override
  String get permissionStatusUnknown => 'Неизвестно';

  @override
  String get signOut => 'Выйти';

  @override
  String get signOutDialogTitle => 'Выйти?';

  @override
  String get signOutDialogBody =>
      'Чтобы пользоваться аккаунтом, нужно будет войти снова.';

  @override
  String get cancel => 'Отмена';

  @override
  String get closeLabel => 'Закрыть';

  @override
  String get navDiscover => 'Обзор';

  @override
  String get navCreate => 'Создать';

  @override
  String get navProfile => 'Профиль';

  @override
  String get chatsTitle => 'Чаты';

  @override
  String get chatNoChatsYet => 'Чатов пока нет.';

  @override
  String get chatOnlineSection => 'В сети';

  @override
  String get chatDirectMessagesSection => 'Личные';

  @override
  String chatAudioDuration(String duration) {
    return 'Аудио $duration';
  }

  @override
  String get chatEnableNotifications => 'Включить уведомления';

  @override
  String get chatMuteNotifications => 'Выключить уведомления';

  @override
  String get chatBlockUser => 'Заблокировать';

  @override
  String get chatDeleteDm => 'Удалить чат';

  @override
  String get chatCall => 'Звонок';

  @override
  String get chatStartAudioCall => 'Аудиозвонок';

  @override
  String get chatStartVideoCall => 'Видеозвонок';

  @override
  String get chatAudioCalling => 'Аудиовызов...';

  @override
  String get chatVideoCalling => 'Видеовызов...';

  @override
  String get chatAudioIncoming => 'Входящий аудиозвонок';

  @override
  String get chatVideoIncoming => 'Входящий видеозвонок';

  @override
  String get chatCallConnecting => 'Соединение...';

  @override
  String get chatCallAccept => 'Принять';

  @override
  String get chatCallDecline => 'Отклонить';

  @override
  String get chatCallEnd => 'Завершить';

  @override
  String get chatCallMute => 'Выкл. звук';

  @override
  String get chatCallUnmute => 'Вкл. звук';

  @override
  String get chatCallSpeaker => 'Динамик';

  @override
  String get chatCallCamera => 'Камера';

  @override
  String get chatCallSwitchCamera => 'Сменить';

  @override
  String get chatCallIssueTitle => 'Проблема со звонком';

  @override
  String get chatCallMicrophoneDenied =>
      'Чтобы позвонить, Bantera нужен доступ к микрофону.';

  @override
  String get chatCallMicrophoneSettings =>
      'Доступ к микрофону для Bantera выключен. Открой Настройки и включи его для звонков.';

  @override
  String get chatCallCameraDenied =>
      'Для видеозвонка Bantera нужен доступ к камере.';

  @override
  String get chatCallCameraSettings =>
      'Доступ к камере для Bantera выключен. Открой Настройки и включи его для видеозвонков.';

  @override
  String get chatCallBusy => 'Этот пользователь уже разговаривает.';

  @override
  String get chatCallUnavailable =>
      'Этот пользователь сейчас не может ответить.';

  @override
  String get chatCallNetworkRestricted =>
      'В этой сети звонок не соединяется. Попробуй Wi-Fi или другую сеть.';

  @override
  String get chatCallFailed => 'Не удалось начать звонок. Попробуй ещё раз.';

  @override
  String get chatGroupReady => 'Группа готова к голосовым сообщениям.';

  @override
  String get chatHoldToStartDm => 'Удерживай, чтобы записать и начать чат.';

  @override
  String get chatNoGroupAudio => 'В группе пока нет аудио.';

  @override
  String get chatNoDmAudio => 'В этом чате пока нет аудио.';

  @override
  String get chatSendingAudio => 'Отправка аудио...';

  @override
  String get chatRecordingReleaseToSend => 'Запись... отпусти, чтобы отправить';

  @override
  String get chatHoldToRecordAudio => 'Удерживай для записи';

  @override
  String get chatRecordingStatus => 'Запись...';

  @override
  String get chatGroupLabel => 'Группа';

  @override
  String get chatNotificationsEnabledForDm =>
      'Уведомления для этого чата включены.';

  @override
  String get chatNotificationsMutedForDm =>
      'Уведомления для этого чата выключены.';

  @override
  String chatBlockUserTitle(String user) {
    return 'Заблокировать $user?';
  }

  @override
  String get chatBlockUserBody =>
      'Вы перестанете видеть друг друга в личных и общих групповых сообщениях, пока ты не разблокируешь пользователя.';

  @override
  String chatBlockUserSuccess(String user) {
    return 'Пользователь $user заблокирован.';
  }

  @override
  String get chatBlockUserFailed =>
      'Не удалось заблокировать пользователя. Попробуй ещё раз.';

  @override
  String get chatDeleteMessage => 'Удалить сообщение';

  @override
  String get chatDeleteMessageTitle => 'Удалить сообщение?';

  @override
  String get chatDeleteMessageBody =>
      'Сообщение будет удалено у всех участников чата. Это действие нельзя отменить.';

  @override
  String get chatDeleteMessageSuccess => 'Сообщение удалено';

  @override
  String get chatDeleteMessageFailed =>
      'Не удалось удалить сообщение. Попробуй ещё раз.';

  @override
  String get chatDeleteDmTitle => 'Удалить этот чат?';

  @override
  String get chatDeleteDmBody =>
      'Чат исчезнет только из твоего списка. Новое сообщение может вернуть его.';

  @override
  String get chatMicrophoneRequiredTitle => 'Нужен микрофон';

  @override
  String get chatMicrophoneRequiredSettings =>
      'Для записи аудио в чате Bantera нужен доступ к микрофону. Включи его в Настройках.';

  @override
  String get chatMicrophoneRequiredBody =>
      'Для записи аудио в чате Bantera нужен доступ к микрофону.';

  @override
  String get chatGroupNotReady => 'Группа ещё не готова.';

  @override
  String get chatMessageAction => 'Написать';

  @override
  String get chatRetranscribe => 'Расшифровать заново';

  @override
  String get chatTranscribe => 'Расшифровать';

  @override
  String get chatTranscribingOnDevice => 'Расшифровка на iPhone...';

  @override
  String get chatTranscriptionFailed =>
      'Не удалось расшифровать. Попробуй ещё раз.';

  @override
  String get chatTranslate => 'Перевести';

  @override
  String get chatRetranslate => 'Перевести заново';

  @override
  String get chatTranslating => 'Перевод на iPhone...';

  @override
  String get chatTranslationFailed => 'Не удалось перевести. Попробуй ещё раз.';

  @override
  String get chatGroupSettingsTitle => 'Настройки группы';

  @override
  String get chatNotifications => 'Уведомления';

  @override
  String get chatBlockedUsersMenu => 'Заблокированные';

  @override
  String get chatBlockedUsersTitle => 'Заблокированные';

  @override
  String get chatBlockedPeople => 'Заблокированные пользователи';

  @override
  String get chatNoBlockedUsers => 'Заблокированных пользователей нет.';

  @override
  String get chatNoBlockedPeople => 'Заблокированных пользователей нет.';

  @override
  String get chatUnblock => 'Разблокировать';

  @override
  String chatUnblockUserTitle(String user) {
    return 'Разблокировать $user?';
  }

  @override
  String get chatUnblockUserBody =>
      'Вы снова сможете видеть друг друга в личных и общих групповых сообщениях.';

  @override
  String get chatUnblockFailed =>
      'Не удалось разблокировать пользователя. Попробуй ещё раз.';

  @override
  String get chatNotificationsTitle => 'Уведомления чатов';

  @override
  String get chatNotificationsSubtitle =>
      'Один переключатель для всего аккаунта на всех устройствах.';

  @override
  String get chatNotificationsDisabledTitle => 'Уведомления выключены';

  @override
  String get chatNotificationsDisabledSettings =>
      'Включи уведомления в Настройках, чтобы получать оповещения чатов Bantera.';

  @override
  String get chatNotificationsDisabledBody =>
      'Чтобы включить оповещения чатов, Bantera нужно разрешение на уведомления.';

  @override
  String get chatNotificationUpdateFailed =>
      'Не удалось изменить уведомления чатов. Попробуй ещё раз.';

  @override
  String get savedTitle => 'Сохранённое';

  @override
  String get generateWithAiTitle => 'Создать с ИИ';

  @override
  String get practiceLocalVideoTitle => 'Практика с видео на iPhone';

  @override
  String get uploadVideoTitle => 'Загрузить видео';

  @override
  String get lessonDetailsTitle => 'Об уроке';

  @override
  String get accountMoreTitle => 'Ещё';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get deleteAccountSubtitle =>
      'Навсегда удалить аккаунт и данные на сервере';

  @override
  String get confirmDeletionTitle => 'Подтверди удаление';

  @override
  String get deleteAccountImmediateBody =>
      'Аккаунт будет удалён сразу. Чтобы снова пользоваться Bantera, придётся создать новый.';

  @override
  String get deleteAccountConfirm => 'Удалить аккаунт';

  @override
  String get couldNotDeleteAccount =>
      'Не удалось удалить аккаунт. Попробуй ещё раз.';

  @override
  String get deleteAccountQuestionTitle => 'Удалить аккаунт?';

  @override
  String get deleteAccountQuestionBody =>
      'Вся твоя личная информация и данные будут навсегда удалены с наших серверов без возможности восстановления.';

  @override
  String get typeDeleteLabel => 'Введи «DELETE», чтобы продолжить';

  @override
  String get continueLabel => 'Продолжить';

  @override
  String get confirmLabel => 'Подтвердить';

  @override
  String get deleteLabel => 'Удалить';

  @override
  String get removeFromListLabel => 'Убрать из списка';

  @override
  String get startLabel => 'Начать';

  @override
  String get doneLabel => 'Готово';

  @override
  String get discoverSearchHint => 'Поиск по названию или тексту…';

  @override
  String get discoverNoMoreResults => 'Больше ничего нет';

  @override
  String get discoverSetLearningLanguagePrompt =>
      'Выбери изучаемый язык, чтобы видеть материалы';

  @override
  String discoverNoPublicContentInLanguage(String language) {
    return 'Общедоступных материалов на языке «$language» пока нет';
  }

  @override
  String get discoverSetLanguageToDiscover =>
      'Выбери изучаемый язык, чтобы находить материалы';

  @override
  String get mediaStartPractice => 'Начать практику';

  @override
  String get mediaTranscript => 'Текст';

  @override
  String mediaTranscriptLineCount(int count) {
    return '(строк: $count)';
  }

  @override
  String get mediaShow => 'Показать';

  @override
  String get mediaHide => 'Скрыть';

  @override
  String get mediaNoTranscriptAvailable => 'Текст недоступен.';

  @override
  String get lessonSaveTooltip => 'Сохранить';

  @override
  String get lessonUnsaveTooltip => 'Убрать из сохранённого';

  @override
  String get mediaKindAudio => 'Аудио';

  @override
  String get mediaKindVideo => 'Видео';

  @override
  String get practiceNoCues => 'Нет фраз';

  @override
  String get practiceTranslating => 'Перевод…';

  @override
  String get practiceShowTranscript => 'Показать текст';

  @override
  String get practiceTranslate => 'Перевести';

  @override
  String get practiceHideText => 'Скрыть текст';

  @override
  String get practiceTextLabel => 'Текст';

  @override
  String get practiceStop => 'Стоп';

  @override
  String get practicePlayAll => 'Шэдоуинг';

  @override
  String get practiceCompare => 'Сравнить';

  @override
  String get practiceRecord => 'Запись';

  @override
  String get practiceStopRecording => 'Стоп';

  @override
  String get practiceRecords => 'Записи';

  @override
  String get practiceRecordsLocalOnlyFooter =>
      'Попытки хранятся только на этом устройстве и никуда не загружаются.';

  @override
  String get practiceRecordsEmpty =>
      'Для этой фразы пока нет сохранённых попыток.';

  @override
  String get practiceRecordingProcessError =>
      'При обработке записи что-то пошло не так.';

  @override
  String get practiceStartOver => 'Сначала';

  @override
  String get practiceTranscriptHidden => 'Текст скрыт';

  @override
  String get practiceListenCarefully => 'Слушай внимательно…';

  @override
  String get practiceTranslationUnavailableForCue =>
      'Перевод этой фразы сейчас недоступен.';

  @override
  String get practiceChooseTranslationLanguageTitle => 'Язык перевода';

  @override
  String get practiceChooseTranslationLanguageDescription =>
      'Bantera будет переводить аудирование на этот язык и сохранит его в твоём профиле для следующих занятий.';

  @override
  String get practiceChangeTranslationLanguageTitle => 'Сменить язык перевода';

  @override
  String get practiceChangeTranslationLanguageDescription =>
      'Выбери язык, на который Bantera будет переводить. Новый выбор сохранится в профиле.';

  @override
  String get practiceConfirmTranslationLanguageTitle =>
      'Подтверди язык перевода';

  @override
  String get practiceConfirmTranslationLanguageBody =>
      'Bantera сохранит этот язык в профиле и будет использовать его для перевода по умолчанию в следующих занятиях по аудированию.';

  @override
  String get practiceCouldNotSaveTranslationLanguage =>
      'Bantera не удалось сохранить язык перевода.';

  @override
  String get practiceNoTranslationLanguagesFound =>
      'Bantera не нашла доступных языков перевода для этого текста.';

  @override
  String get practicePlayAllTitle => 'Шэдоуинг';

  @override
  String get practicePlayAllDescription =>
      'Пауза между фразами для повторения:';

  @override
  String get practicePlayAllPauseZeroSeconds => '0 с';

  @override
  String get practicePlayAllPauseOneSecondLabel => '1 с';

  @override
  String get practicePlayAllPauseOneCuePlusOneSecond => '1 фраза + 1 с';

  @override
  String get practicePlayAllPauseOneCuePlusTwoSeconds => '1 фраза + 2 с';

  @override
  String get practicePlayAllTimesPerCueTitle => 'Повторов на фразу';

  @override
  String get practicePlayAllTimesOnce => '1×';

  @override
  String get practicePlayAllTimesTwice => '2×';

  @override
  String get practicePlayAllTimesThrice => '3×';

  @override
  String get practiceSearchLanguagesHint => 'Поиск языков';

  @override
  String get practiceTranslationInstalled => 'Установлен';

  @override
  String get practiceTranslationDownload => 'Загрузить';

  @override
  String get practiceStartOverTitle => 'Начать сначала?';

  @override
  String get practiceStartOverBody => 'Вернуться к первой фразе?';

  @override
  String get practiceNextFromLastTitle => 'К первой фразе?';

  @override
  String get practiceNextFromLastBody =>
      'Это последняя фраза. Вернуться к первой?';

  @override
  String get practiceGoToFirstCue => 'К первой фразе';

  @override
  String get practiceVideoOpenError =>
      'Не удалось открыть выбранное видео для практики.';

  @override
  String get practiceAudioLoading => 'Загрузка аудио…';

  @override
  String practiceAudioLoadingPercent(int percent) {
    return 'Загрузка аудио: $percent%';
  }

  @override
  String get practiceAudioError =>
      'Не удалось загрузить аудио. Попробуй ещё раз.';

  @override
  String get compareRecordYourVersion => 'Запиши свою версию';

  @override
  String compareTranscriptionLanguage(String locale) {
    return 'Язык расшифровки: $locale';
  }

  @override
  String get compareOpenIphoneSettings => 'Открыть настройки iPhone';

  @override
  String get comparePauseAttempt => 'Пауза';

  @override
  String get comparePlayAttempt => 'Прослушать попытку';

  @override
  String get compareYourTranscribedAttempt => 'Расшифровка твоей попытки';

  @override
  String get compareHighlightHint =>
      'Слова, которые Bantera распознала иначе, выделены.';

  @override
  String get compareUncertainHint =>
      'Слова с пунктиром распознаны неуверенно — проверь произношение.';

  @override
  String get compareTryAgain => 'Ещё раз';

  @override
  String get compareDone => 'Готово';

  @override
  String get compareStatusTranscribing => 'Расшифровка попытки на iPhone…';

  @override
  String get compareStatusRecording =>
      'Запись… Нажми ещё раз, чтобы остановить.';

  @override
  String get compareStatusSavedAttempt =>
      'Это сохранённая попытка для этой фразы. Можно прослушать её или попробовать снова.';

  @override
  String get compareStatusReplayOrRetry =>
      'Прослушай эту попытку или попробуй фразу ещё раз.';

  @override
  String get compareStatusTapToRecord =>
      'Нажми, чтобы записать свою версию этой фразы.';

  @override
  String get compareCouldNotStartRecording =>
      'Bantera не удалось начать запись.';

  @override
  String get compareCouldNotAccessRecording =>
      'Bantera не удалось получить доступ к записи.';

  @override
  String get compareNoTranscriptGenerated =>
      'Не удалось расшифровать эту попытку. Попробуй ещё раз, поближе к микрофону.';

  @override
  String get compareRecentAttempts => 'Недавние попытки';

  @override
  String get compareAttemptsFooterNote =>
      'Bantera хранит твои попытки на этом iPhone — так удобно следить за прогрессом по каждой фразе.';

  @override
  String compareMatchedCount(int count) {
    return 'Совпало: $count';
  }

  @override
  String compareDifferentCount(int count) {
    return 'Отличается: $count';
  }

  @override
  String compareMissingCount(int count) {
    return 'Пропущено: $count';
  }

  @override
  String compareUncertainCount(int count) {
    return 'Неясно: $count';
  }

  @override
  String get compareMicrophoneDeniedPermanent =>
      'Доступ к микрофону для Bantera выключен. Открой Настройки iPhone > Bantera > Микрофон и включи его, чтобы записать свою версию.';

  @override
  String get compareMicrophoneDeniedRestricted =>
      'На этом iPhone доступ к микрофону для Bantera сейчас ограничен. Проверь Экранное время, управление устройством или системные настройки.';

  @override
  String get compareMicrophoneDeniedDefault =>
      'Чтобы записать свою версию, нужен доступ к микрофону. Если запрос был отклонён, открой Настройки iPhone > Bantera > Микрофон и включи его.';

  @override
  String get compareSpeechRecognitionDeniedPermanent =>
      'Распознавание речи для Bantera выключено. Открой Настройки iPhone > Bantera > Распознавание речи и включи его, чтобы сравнить запись.';

  @override
  String get compareSpeechRecognitionDeniedRestricted =>
      'На этом iPhone распознавание речи для Bantera сейчас ограничено. Проверь Экранное время, управление устройством или системные настройки.';

  @override
  String get compareSpeechRecognitionUnavailable =>
      'Распознавание речи на этом iPhone сейчас недоступно.';

  @override
  String get compareSpeechRecognitionUnsupportedLocale =>
      'На этом iPhone распознавание речи недоступно для этого языка.';

  @override
  String get comparePlayAttemptTooltip => 'Прослушать попытку';

  @override
  String get comparePauseAttemptTooltip => 'Приостановить попытку';

  @override
  String get createWhatToday => 'Чем займёмся сегодня?';

  @override
  String get createPracticeVideo => 'Практика по видео';

  @override
  String get createYourMedia => 'Твои материалы';

  @override
  String get createTryAgain => 'Повторить';

  @override
  String get createUploadedVideosEmptyHint =>
      'Здесь появятся загруженные видео — открывай их снова и тренируйся фраза за фразой.';

  @override
  String get createUploadingTips => 'Советы по загрузке';

  @override
  String get createUploadingTipsBody =>
      'Лучше всего работает аудио короче 3 минут. Чёткие субтитры создаются автоматически!';

  @override
  String get createOnThisIphone => 'На этом iPhone';

  @override
  String get createLocalVideosEmptyHint =>
      'Видео для локальной практики сохраняются на этом iPhone — открывай их позже без повторной расшифровки.';

  @override
  String get createOnDeviceBadge => 'На устройстве';

  @override
  String get createSignInToLoadVideos =>
      'Войди снова, чтобы загрузить свои видео.';

  @override
  String createVideoMetaCues(int count) {
    return 'Фраз: $count';
  }

  @override
  String get createPublicBadge => 'Общедоступно';

  @override
  String get createPrivateBadge => 'Приватно';

  @override
  String get createAiBadge => 'ИИ';

  @override
  String get createDeleteSavedVideoTitle => 'Удалить сохранённое видео?';

  @override
  String createDeleteSavedVideoBody(String title) {
    return 'Bantera удалит «$title» с этого iPhone вместе с сохранёнными фразами текста.';
  }

  @override
  String get createDeleteMediaTitle => 'Удалить материал?';

  @override
  String createDeleteMediaBody(String title) {
    return '«$title» и его текст будут удалены навсегда. Это действие нельзя отменить.';
  }

  @override
  String get removeFromListTitle => 'Убрать из списка?';

  @override
  String get removeFromListBody =>
      'Элемент будет убран из списка. Это действие нельзя отменить.';

  @override
  String get editProfileChangeImage => 'Сменить фото профиля';

  @override
  String get editProfileUploading => 'Загрузка…';

  @override
  String get editProfileNameLabel => 'Имя';

  @override
  String get editProfileNameHint => 'Как Bantera показывать твоё имя?';

  @override
  String get editProfileSaveNameButton => 'Сохранить имя';

  @override
  String get editProfileSaving => 'Сохранение…';

  @override
  String get editProfileLanguagesSection => 'Языки';

  @override
  String get editProfileMyNativeLanguage => 'Мой родной язык';

  @override
  String get editProfileMyNativeLanguageSubtitle =>
      'Твой родной или первый язык';

  @override
  String get editProfileLearningLanguage => 'Изучаемый язык';

  @override
  String get editProfileLearningLanguageSubtitle =>
      'Язык, который ты хочешь практиковать';

  @override
  String get editProfileImageUpdated => 'Фото профиля обновлено.';

  @override
  String get editProfileNameUpdated => 'Имя обновлено.';

  @override
  String get editProfileEnterName => 'Введи имя.';

  @override
  String get editProfileNameMaxLength => 'Не больше 80 символов.';

  @override
  String get editProfileCouldNotLoadLanguages =>
      'Не удалось загрузить список языков.';

  @override
  String get languagePickerNone => 'Не выбран';

  @override
  String get languagePickerClearSelection => 'Сбросить выбор';

  @override
  String get languagePickerNoMatchingLanguages => 'Языки не найдены.';

  @override
  String get languagePickerMoreComingSoon => 'Скоро будет больше языков';

  @override
  String get editProfileNativeLanguageCleared => 'Родной язык сброшен.';

  @override
  String get editProfileLearningLanguageCleared => 'Изучаемый язык сброшен.';

  @override
  String editProfileNativeLanguageSetTo(String language) {
    return 'Родной язык: $language.';
  }

  @override
  String editProfileLearningLanguageSetTo(String language) {
    return 'Изучаемый язык: $language.';
  }

  @override
  String get profileLanguageSettings => 'Настройки языка';

  @override
  String get profileLearningLabel => 'Изучаю';

  @override
  String get profileNotSet => 'Не задан';

  @override
  String get uploadedDetailYourAudio => 'Твоё аудио';

  @override
  String get uploadedDetailYourVideo => 'Твоё видео';

  @override
  String get uploadedDetailDeleteAudioTitle => 'Удалить аудио?';

  @override
  String get uploadedDetailDeleteAudioBody =>
      'Аудио и его текст будут удалены навсегда. Это действие нельзя отменить.';

  @override
  String get uploadedDetailDeleteVideoTitle => 'Удалить видео?';

  @override
  String get uploadedDetailDeleteVideoBody =>
      'Видео и его текст будут удалены навсегда. Это действие нельзя отменить.';

  @override
  String get uploadedDetailAiGenerated => 'Создано ИИ';

  @override
  String get uploadedDetailFileSize => 'Размер файла';

  @override
  String get uploadedDetailResolution => 'Разрешение';

  @override
  String get uploadedDetailResolutionUnknown => 'Неизвестно';

  @override
  String get uploadedDetailTranscribing => 'Расшифровка…';

  @override
  String get uploadedDetailNoTranscriptCuesYet => 'Фраз текста пока нет.';

  @override
  String uploadedDetailMediaDescription(int count) {
    return 'Твой загруженный клип для практики. Фраз в тексте: $count.';
  }

  @override
  String get uploadedDetailTranscriptionFailedFallback =>
      'Не удалось расшифровать. Используются примерные фразы.';

  @override
  String get uploadedDetailTranscriptionNoCues =>
      'Расшифровка не вернула ни одной фразы.';

  @override
  String get uploadedDetailTranscriptionSourceYourUpload => 'Твоя загрузка';

  @override
  String get aiGenLeaveTitle => 'Уйти со страницы?';

  @override
  String get aiGenLeaveBody =>
      'Аудио ещё создаётся. Если уйти сейчас, процесс будет отменён.';

  @override
  String get aiGenStay => 'Остаться';

  @override
  String get aiGenLeave => 'Уйти';

  @override
  String get aiGenLoadingTitle => 'Создаём аудио…';

  @override
  String get aiGenLoadingSubtitle =>
      'Это может занять до минуты.\nНе уходи с этой страницы, пока идёт создание.';

  @override
  String get aiGenStepPreparingSpeechModel =>
      'Подготовка речевой модели на устройстве';

  @override
  String get aiGenStepWritingDialogue => 'Пишем диалог';

  @override
  String get aiGenStepGeneratingAudio => 'Создаём аудио';

  @override
  String get aiGenStepAligningAudio => 'Синхронизируем аудио';

  @override
  String get aiGenStepTranscribing => 'Расшифровываем';

  @override
  String get aiGenStepCorrectingTranscript => 'Исправляем текст';

  @override
  String get aiGenLanguageSection => 'Язык';

  @override
  String get aiGenSetLearningLanguagePrompt =>
      'Выбери изучаемый язык, чтобы создавать аудио';

  @override
  String get aiGenLoadingLanguage => 'Загрузка языка…';

  @override
  String aiGenLanguageUnsupported(String language) {
    return 'Язык «$language» пока не поддерживается для создания аудио.';
  }

  @override
  String get aiGenScenarioSection => 'Сценарий';

  @override
  String get aiGenScenarioOptionalHint =>
      'Необязательно — без выбора сценарий будет случайным.';

  @override
  String get aiGenCustomScenarioHint => 'Опиши свой сценарий…';

  @override
  String get aiGenDurationSection => 'Длительность';

  @override
  String aiGenDurationMinutes(int minutes) {
    return '$minutes мин';
  }

  @override
  String get aiGenGenerateButton => 'Создать';

  @override
  String get aiGenOwnershipNotice =>
      'Созданное здесь аудио становится материалом сообщества Bantera и публикуется для практики всех учащихся.';

  @override
  String get aiGenOwnershipCheckbox =>
      'Поделиться аудио как материалом сообщества Bantera';

  @override
  String get aiGenOwnershipConfirmTitle => 'Поделиться с сообществом?';

  @override
  String get aiGenOwnershipConfirmCancel => 'Отмена';

  @override
  String get aiGenOwnershipConfirmGenerate => 'Создать';

  @override
  String get aiGenFooterNotice =>
      'ИИ напишет диалог для двух собеседников и озвучит его. Результат сохранится как общедоступное аудио для практики.';

  @override
  String get aiScenarioCoffeeShop => 'Кофейня';

  @override
  String get aiScenarioLatestNews => 'Последние новости';

  @override
  String get aiScenarioAirportReunion => 'Встреча в аэропорту';

  @override
  String get aiScenarioGroceryStore => 'Продуктовый магазин';

  @override
  String get aiScenarioDoctorVisit => 'У врача';

  @override
  String get aiScenarioJobInterview => 'Собеседование';

  @override
  String get aiScenarioNewNeighbour => 'Новый сосед';

  @override
  String get aiScenarioTechSupport => 'Техподдержка';

  @override
  String get aiScenarioBirthdaySurprise => 'Сюрприз на день рождения';

  @override
  String get aiScenarioGymTips => 'Советы в спортзале';

  @override
  String get aiScenarioWeatherSmalltalk => 'Разговор о погоде';

  @override
  String get aiScenarioRestaurantOrder => 'Заказ в ресторане';

  @override
  String get aiScenarioBookRecommendation => 'Совет по книге';

  @override
  String get aiScenarioBusDelay => 'Автобус задерживается';

  @override
  String get aiScenarioMovieDebate => 'Спор о фильме';

  @override
  String get aiScenarioCustom => 'Свой…';

  @override
  String get errorNetworkUnreachable =>
      'Не удалось подключиться к Bantera. Проверь подключение к интернету.';

  @override
  String get errorNetworkCellularBlocked =>
      'Сотовые данные для Bantera выключены. Открой Настройки > Bantera и включи «Сотовые данные» или подключись к Wi-Fi.';

  @override
  String get errorTlsConnection =>
      'Не удалось установить защищённое соединение.';

  @override
  String get settingsRateAppPrompt =>
      'Нравится Bantera? Быстрая оценка в App Store очень нам поможет.';

  @override
  String get settingsRateAppButton => 'Оценить в App Store';

  @override
  String get settingsSharePrompt =>
      'Знаешь кого-то, кто учит язык? Расскажи им о Bantera.';

  @override
  String get settingsShareButton => 'Поделиться Bantera';

  @override
  String get settingsContactButton => 'Связаться с нами';

  @override
  String get localVideoDescription =>
      'Выбери видео в Фото, укажи язык речи — iPhone расшифрует его в фоне, и можно тренироваться фраза за фразой.';

  @override
  String get localVideoStep1Title => '1. Выбери видео';

  @override
  String get localVideoChooseFromPhotos => 'Выбрать в Фото';

  @override
  String get localVideoChooseDifferent => 'Выбрать другое видео';

  @override
  String get localVideoSelectedFileLabel => 'Выбранный файл';

  @override
  String get localVideoSizeLabel => 'Размер';

  @override
  String get localVideoDurationLabel => 'Длительность';

  @override
  String get localVideoLongVideoWarning =>
      'Видео длиннее 3 минут, поэтому Bantera может понадобиться больше времени на подготовку текста и перевода.';

  @override
  String get localVideoStep2Title => '2. Язык расшифровки';

  @override
  String get localVideoChooseLanguagePlaceholder => 'Выбери язык речи';

  @override
  String get localVideoLanguageHint =>
      'Bantera запоминает последний выбранный язык и по умолчанию скрывает текст во время практики.';

  @override
  String get localVideoStep3Title => '3. Практика';

  @override
  String get localVideoPreparing => 'Подготовка...';

  @override
  String get localVideoPracticeHint =>
      'Bantera сначала расшифровывает видео на устройстве, а затем открывает практику по фразам — ничего не загружая.';

  @override
  String get localVideoStatusLongVideo =>
      'Видео довольно длинное, поэтому на расшифровку и подготовку может понадобиться больше времени.';

  @override
  String get localVideoStatusTranscribing =>
      'Расшифровка на устройстве и подготовка фраз...';

  @override
  String get localVideoStatusSaving =>
      'Сохраняем видео в библиотеку практики на устройстве...';

  @override
  String get localVideoStatusTranslationLong =>
      'Расшифровка готова. Bantera также готовит перевод на твой язык, поэтому для длинного видео может понадобиться чуть больше времени.';

  @override
  String get localVideoStatusTranslation =>
      'Расшифровка готова. Готовим перевод на твой язык...';

  @override
  String get localVideoPickerTitle => 'Язык аудио';

  @override
  String get savedCuesTitle => 'Сохранённые фразы';

  @override
  String get savedCuesEmpty =>
      'Сохранённых фраз пока нет. Во время практики нажми на значок закладки, чтобы сохранить фразу.';

  @override
  String get savedCuesDeleteTooltip => 'Удалить из сохранённых';

  @override
  String get savedCuesDeleteConfirmTitle => 'Удалить эту фразу?';

  @override
  String get savedCuesDeleteConfirmBody =>
      'Фраза будет удалена из списка сохранённых.';

  @override
  String get savedCuesDeleteAllTooltip => 'Удалить все сохранённые фразы';

  @override
  String get savedCuesDeleteAllConfirmTitle => 'Удалить все сохранённые фразы?';

  @override
  String get savedCuesDeleteAllConfirmBody =>
      'Все сохранённые фразы будут удалены навсегда.';

  @override
  String get updateAlertTitle => 'Доступно обновление';

  @override
  String get updateAlertMessage =>
      'Вышла новая версия Bantera. Обнови приложение, чтобы получить новые функции и улучшения.';

  @override
  String get updateCurrentVersionLabel => 'Текущая версия';

  @override
  String get updateAppStoreVersionLabel => 'Версия в App Store';

  @override
  String get updateAlertUpdate => 'Обновить';

  @override
  String get updateAlertLater => 'Позже';

  @override
  String get checkForUpdateButton => 'Проверить обновления';

  @override
  String get upToDateAlertTitle => 'Обновлений нет';

  @override
  String upToDateAlertMessage(Object version) {
    return 'Bantera $version — последняя версия.';
  }

  @override
  String get sectionSupport => 'Поддержка';

  @override
  String get permissionActionAllow => 'Разрешить';
}
