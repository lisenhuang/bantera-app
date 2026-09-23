// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appName => 'Bantera';

  @override
  String get appTagline => 'Мовна практика фраза за фразою.';

  @override
  String get authContinueWithApple => 'Продовжити з Apple';

  @override
  String get authContinueWithGoogle => 'Продовжити з Google';

  @override
  String get authAppleUnavailable =>
      'Вхід з Apple недоступний на цьому пристрої.';

  @override
  String get authOrSignInEmail => 'або увійди через email';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Пароль';

  @override
  String get authSigningIn => 'Вхід...';

  @override
  String get authSignIn => 'Увійти';

  @override
  String get authSignInWithEmail => 'Увійти через email';

  @override
  String get validationEnterEmail => 'Введи свій email.';

  @override
  String get validationValidEmail => 'Введи коректний email.';

  @override
  String get validationEnterPassword => 'Введи пароль.';

  @override
  String get onboardingTitle => 'Налаштуй свій профіль';

  @override
  String get onboardingSubtitle =>
      'Це допоможе Bantera персоналізувати практику й чати.';

  @override
  String get onboardingNameTitle => 'Як до тебе звертатися?';

  @override
  String get onboardingNameSubtitle =>
      'Ми взяли ім’я з твого акаунта, коли Apple його надав. Можеш змінити його зараз.';

  @override
  String get onboardingClearName => 'Очистити ім’я';

  @override
  String get onboardingNativeLanguageTitle => 'Яка твоя рідна мова?';

  @override
  String get onboardingNativeLanguageSubtitle =>
      'Bantera використовує її для перекладу й мовних груп.';

  @override
  String get onboardingLearningLanguageTitle => 'Яку мову ти вивчаєш?';

  @override
  String get onboardingLearningLanguageSubtitle =>
      'Від цього залежать матеріали для практики й навчальні групи.';

  @override
  String get onboardingAvatarTitle => 'Додай фото профілю';

  @override
  String get onboardingAvatarSubtitle =>
      'Вибери фото або продовж — і Bantera згенерує його для тебе.';

  @override
  String get onboardingAvatarGenderTitle => 'Згенеруй фото профілю';

  @override
  String get onboardingAvatarGenderBody =>
      'Вибери, як Bantera має згенерувати фото профілю. Ми не зберігаємо цей вибір — він потрібен лише для цього зображення.';

  @override
  String get onboardingAvatarGenderMale => 'Чоловік';

  @override
  String get onboardingAvatarGenderFemale => 'Жінка';

  @override
  String get onboardingChoosePhoto => 'Вибрати фото';

  @override
  String get onboardingChangePhoto => 'Змінити фото';

  @override
  String get onboardingUseGeneratedAvatar => 'Використати згенерований аватар';

  @override
  String get onboardingUseCurrentPhoto => 'Використати поточне фото';

  @override
  String get onboardingChooseLanguage => 'Вибрати мову';

  @override
  String get onboardingBack => 'Назад';

  @override
  String get onboardingFinish => 'Готово';

  @override
  String get onboardingLoadingProfile => 'Завантаження профілю...';

  @override
  String get onboardingSavingProfile => 'Збереження профілю...';

  @override
  String get onboardingLoadFailed => 'Щось пішло не так. Спробуй ще раз.';

  @override
  String get onboardingSearchHint => 'Пошук мов…';

  @override
  String get onboardingRetry => 'Повторити';

  @override
  String get onboardingNoMatching => 'Немає відповідних мов.';

  @override
  String get onboardingFailedSave => 'Не вдалося зберегти.';

  @override
  String get settingsTitle => 'Параметри';

  @override
  String get sectionAppearance => 'Вигляд';

  @override
  String get sectionAccount => 'Акаунт';

  @override
  String get sectionRateAndShare => 'Оцінити й поділитися';

  @override
  String get sectionLanguage => 'Мова інтерфейсу';

  @override
  String get sectionPermissions => 'Дозволи';

  @override
  String get sectionNotifications => 'Сповіщення';

  @override
  String get languageSectionSubtitle =>
      'Вибери мову інтерфейсу. «Системна» відповідає налаштуванням пристрою.';

  @override
  String get themeLabel => 'Тема';

  @override
  String get themeLight => 'Світла';

  @override
  String get themeDark => 'Темна';

  @override
  String get themeSystem => 'Системна';

  @override
  String get languageEnglish => 'Англійська';

  @override
  String get languageChineseSimplified => 'Китайська (спрощена)';

  @override
  String get languageKorean => 'Корейська';

  @override
  String get languageJapanese => 'Японська';

  @override
  String get signedOutLabel => 'Вихід виконано';

  @override
  String get noActiveSession => 'Немає активного сеансу Bantera';

  @override
  String signedInWith(String provider) {
    return 'Вхід через $provider';
  }

  @override
  String get editProfile => 'Редагувати профіль';

  @override
  String get more => 'Більше';

  @override
  String get appPermissionsTitle => 'Дозволи програми';

  @override
  String get appPermissionsSubtitle =>
      'Переглянь, до чого Bantera має доступ на цьому пристрої.';

  @override
  String get permissionsIntro =>
      'Bantera використовує ці налаштування пристрою для запису, порівняння мовлення й доступу до мережі.';

  @override
  String get permissionsOpenSettings => 'Відкрити Параметри iPhone';

  @override
  String get permissionsRefresh => 'Оновити';

  @override
  String get permissionMicrophoneTitle => 'Мікрофон';

  @override
  String get permissionMicrophoneDescription =>
      'Запис спроб і голосових повідомлень.';

  @override
  String get permissionSpeechTitle => 'Розпізнавання мовлення';

  @override
  String get permissionSpeechDescription =>
      'Перетворення записів і голосових повідомлень на текст.';

  @override
  String get permissionMobileDataTitle => 'Мобільні дані';

  @override
  String get permissionMobileDataDescription =>
      'Користуйся Bantera, коли iPhone не підключено до Wi-Fi.';

  @override
  String get permissionStatusAllowed => 'Дозволено';

  @override
  String get permissionStatusLimited => 'Обмежено';

  @override
  String get permissionStatusNotAllowed => 'Не дозволено';

  @override
  String get permissionStatusUnknown => 'Невідомо';

  @override
  String get signOut => 'Вийти';

  @override
  String get signOutDialogTitle => 'Вийти?';

  @override
  String get signOutDialogBody =>
      'Щоб користуватися акаунтом, доведеться увійти знову.';

  @override
  String get cancel => 'Скасувати';

  @override
  String get closeLabel => 'Закрити';

  @override
  String get navDiscover => 'Огляд';

  @override
  String get navCreate => 'Створити';

  @override
  String get navProfile => 'Профіль';

  @override
  String get chatsTitle => 'Чати';

  @override
  String get chatNoChatsYet => 'Чатів ще немає.';

  @override
  String get chatOnlineSection => 'Онлайн';

  @override
  String get chatDirectMessagesSection => 'Особисті';

  @override
  String chatAudioDuration(String duration) {
    return 'Аудіо $duration';
  }

  @override
  String get chatEnableNotifications => 'Увімкнути сповіщення';

  @override
  String get chatMuteNotifications => 'Вимкнути сповіщення';

  @override
  String get chatBlockUser => 'Заблокувати користувача';

  @override
  String get chatDeleteDm => 'Видалити чат';

  @override
  String get chatCall => 'Дзвінок';

  @override
  String get chatStartAudioCall => 'Аудіодзвінок';

  @override
  String get chatStartVideoCall => 'Відеодзвінок';

  @override
  String get chatAudioCalling => 'Аудіодзвінок...';

  @override
  String get chatVideoCalling => 'Відеодзвінок...';

  @override
  String get chatAudioIncoming => 'Вхідний аудіодзвінок';

  @override
  String get chatVideoIncoming => 'Вхідний відеодзвінок';

  @override
  String get chatCallConnecting => 'З’єднання...';

  @override
  String get chatCallAccept => 'Прийняти';

  @override
  String get chatCallDecline => 'Відхилити';

  @override
  String get chatCallEnd => 'Завершити';

  @override
  String get chatCallMute => 'Вимк. звук';

  @override
  String get chatCallUnmute => 'Увімк. звук';

  @override
  String get chatCallSpeaker => 'Динамік';

  @override
  String get chatCallCamera => 'Камера';

  @override
  String get chatCallSwitchCamera => 'Змінити';

  @override
  String get chatCallIssueTitle => 'Проблема з дзвінком';

  @override
  String get chatCallMicrophoneDenied =>
      'Щоб почати дзвінок, Bantera потрібен доступ до мікрофона.';

  @override
  String get chatCallMicrophoneSettings =>
      'Доступ до мікрофона для Bantera вимкнено. Відкрий Параметри й увімкни його для дзвінків.';

  @override
  String get chatCallCameraDenied =>
      'Щоб почати відеодзвінок, Bantera потрібен доступ до камери.';

  @override
  String get chatCallCameraSettings =>
      'Доступ до камери для Bantera вимкнено. Відкрий Параметри й увімкни його для відеодзвінків.';

  @override
  String get chatCallBusy => 'Цей користувач уже розмовляє по іншій лінії.';

  @override
  String get chatCallUnavailable =>
      'Цей користувач зараз недоступний для дзвінка.';

  @override
  String get chatCallNetworkRestricted =>
      'У цій мережі не вдається з’єднати дзвінок. Спробуй Wi-Fi або іншу мережу.';

  @override
  String get chatCallFailed => 'Не вдалося почати дзвінок. Спробуй ще раз.';

  @override
  String get chatGroupReady => 'Ця група готова до аудіоповідомлень.';

  @override
  String get chatHoldToStartDm => 'Утримуй, щоб записати й почати чат.';

  @override
  String get chatNoGroupAudio => 'У групі ще немає аудіо.';

  @override
  String get chatNoDmAudio => 'У цьому чаті ще немає аудіо.';

  @override
  String get chatSendingAudio => 'Надсилання аудіо...';

  @override
  String get chatRecordingReleaseToSend => 'Запис... відпусти, щоб надіслати';

  @override
  String get chatHoldToRecordAudio => 'Утримуй, щоб записати аудіо';

  @override
  String get chatRecordingStatus => 'Запис...';

  @override
  String get chatGroupLabel => 'Група';

  @override
  String get chatNotificationsEnabledForDm =>
      'Сповіщення для цього чату ввімкнено.';

  @override
  String get chatNotificationsMutedForDm =>
      'Сповіщення для цього чату вимкнено.';

  @override
  String chatBlockUserTitle(String user) {
    return 'Заблокувати $user?';
  }

  @override
  String get chatBlockUserBody =>
      'Ви не бачитимете повідомлень одне одного в особистих чатах і спільних групах, доки не розблокуєте.';

  @override
  String chatBlockUserSuccess(String user) {
    return '$user заблоковано.';
  }

  @override
  String get chatBlockUserFailed =>
      'Не вдалося заблокувати користувача. Спробуй ще раз.';

  @override
  String get chatDeleteMessage => 'Видалити повідомлення';

  @override
  String get chatDeleteMessageTitle => 'Видалити це повідомлення?';

  @override
  String get chatDeleteMessageBody =>
      'Повідомлення буде видалено для всіх учасників розмови. Цю дію не можна скасувати.';

  @override
  String get chatDeleteMessageSuccess => 'Повідомлення видалено';

  @override
  String get chatDeleteMessageFailed =>
      'Не вдалося видалити повідомлення. Спробуй ще раз.';

  @override
  String get chatDeleteDmTitle => 'Видалити цей чат?';

  @override
  String get chatDeleteDmBody =>
      'Чат зникне лише з твого списку. Нове повідомлення може повернути його.';

  @override
  String get chatMicrophoneRequiredTitle => 'Потрібен мікрофон';

  @override
  String get chatMicrophoneRequiredSettings =>
      'Щоб записувати аудіо в чаті, Bantera потрібен доступ до мікрофона. Увімкни його в Параметрах.';

  @override
  String get chatMicrophoneRequiredBody =>
      'Щоб записувати аудіо в чаті, Bantera потрібен доступ до мікрофона.';

  @override
  String get chatGroupNotReady => 'Ця група ще не готова.';

  @override
  String get chatMessageAction => 'Написати';

  @override
  String get chatRetranscribe => 'Розпізнати знову';

  @override
  String get chatTranscribe => 'Розпізнати текст';

  @override
  String get chatTranscribingOnDevice =>
      'Розпізнавання тексту на цьому iPhone...';

  @override
  String get chatTranscriptionFailed =>
      'Не вдалося розпізнати текст. Спробуй ще раз.';

  @override
  String get chatTranslate => 'Перекласти';

  @override
  String get chatRetranslate => 'Перекласти знову';

  @override
  String get chatTranslating => 'Переклад на цьому iPhone...';

  @override
  String get chatTranslationFailed => 'Не вдалося перекласти. Спробуй ще раз.';

  @override
  String get chatGroupSettingsTitle => 'Налаштування групи';

  @override
  String get chatNotifications => 'Сповіщення';

  @override
  String get chatBlockedUsersMenu => 'Заблоковані';

  @override
  String get chatBlockedUsersTitle => 'Заблоковані користувачі';

  @override
  String get chatBlockedPeople => 'Заблоковані люди';

  @override
  String get chatNoBlockedUsers => 'Заблокованих користувачів немає.';

  @override
  String get chatNoBlockedPeople => 'Заблокованих людей немає.';

  @override
  String get chatUnblock => 'Розблокувати';

  @override
  String chatUnblockUserTitle(String user) {
    return 'Розблокувати $user?';
  }

  @override
  String get chatUnblockUserBody =>
      'Ви знову зможете бачити одне одного в особистих чатах і спільних групах.';

  @override
  String get chatUnblockFailed =>
      'Не вдалося розблокувати користувача. Спробуй ще раз.';

  @override
  String get chatNotificationsTitle => 'Сповіщення чатів';

  @override
  String get chatNotificationsSubtitle =>
      'Один перемикач для акаунта на всіх твоїх пристроях.';

  @override
  String get chatNotificationsDisabledTitle => 'Сповіщення вимкнено';

  @override
  String get chatNotificationsDisabledSettings =>
      'Увімкни сповіщення в Параметрах, щоб отримувати сповіщення чатів Bantera.';

  @override
  String get chatNotificationsDisabledBody =>
      'Щоб увімкнути сповіщення чатів, Bantera потрібен дозвіл на сповіщення.';

  @override
  String get chatNotificationUpdateFailed =>
      'Не вдалося оновити сповіщення чатів. Спробуй ще раз.';

  @override
  String get savedTitle => 'Збережені медіа';

  @override
  String get generateWithAiTitle => 'Створити за допомогою ШІ';

  @override
  String get practiceLocalVideoTitle => 'Практика з власним відео';

  @override
  String get uploadVideoTitle => 'Завантажити відео';

  @override
  String get lessonDetailsTitle => 'Про урок';

  @override
  String get accountMoreTitle => 'Більше';

  @override
  String get deleteAccount => 'Видалити акаунт';

  @override
  String get deleteAccountSubtitle =>
      'Назавжди видалити акаунт і дані на сервері';

  @override
  String get confirmDeletionTitle => 'Підтвердь видалення';

  @override
  String get deleteAccountImmediateBody =>
      'Твій акаунт буде видалено негайно. Щоб знову користуватися Bantera, доведеться створити новий.';

  @override
  String get deleteAccountConfirm => 'Видалити акаунт';

  @override
  String get couldNotDeleteAccount =>
      'Не вдалося видалити акаунт. Спробуй ще раз.';

  @override
  String get deleteAccountQuestionTitle => 'Видалити акаунт?';

  @override
  String get deleteAccountQuestionBody =>
      'Усю твою особисту інформацію й дані буде назавжди видалено з наших серверів без можливості відновлення.';

  @override
  String get typeDeleteLabel => 'Введи «DELETE», щоб продовжити';

  @override
  String get continueLabel => 'Продовжити';

  @override
  String get confirmLabel => 'Підтвердити';

  @override
  String get deleteLabel => 'Видалити';

  @override
  String get removeFromListLabel => 'Прибрати зі списку';

  @override
  String get startLabel => 'Почати';

  @override
  String get doneLabel => 'Готово';

  @override
  String get discoverSearchHint => 'Пошук за назвою або текстом…';

  @override
  String get discoverNoMoreResults => 'Більше результатів немає';

  @override
  String get discoverSetLearningLanguagePrompt =>
      'Вкажи мову, яку вивчаєш, щоб побачити матеріали';

  @override
  String discoverNoPublicContentInLanguage(String language) {
    return 'Публічних матеріалів мовою «$language» поки немає';
  }

  @override
  String get discoverSetLanguageToDiscover =>
      'Вкажи мову, яку вивчаєш, щоб знаходити матеріали';

  @override
  String get mediaStartPractice => 'Почати практику';

  @override
  String get mediaTranscript => 'Текст';

  @override
  String mediaTranscriptLineCount(int count) {
    return '(рядків: $count)';
  }

  @override
  String get mediaShow => 'Показати';

  @override
  String get mediaHide => 'Сховати';

  @override
  String get mediaNoTranscriptAvailable => 'Текст недоступний.';

  @override
  String get lessonSaveTooltip => 'Зберегти';

  @override
  String get lessonUnsaveTooltip => 'Прибрати зі збережених';

  @override
  String get mediaKindAudio => 'Аудіо';

  @override
  String get mediaKindVideo => 'Відео';

  @override
  String get practiceNoCues => 'Немає фраз';

  @override
  String get practiceTranslating => 'Переклад…';

  @override
  String get practiceShowTranscript => 'Показати текст';

  @override
  String get practiceTranslate => 'Перекласти';

  @override
  String get practiceHideText => 'Сховати текст';

  @override
  String get practiceTextLabel => 'Текст';

  @override
  String get practiceStop => 'Стоп';

  @override
  String get practicePlayAll => 'Шедоуінг';

  @override
  String get practiceCompare => 'Порівняти';

  @override
  String get practiceRecord => 'Записати';

  @override
  String get practiceStopRecording => 'Стоп';

  @override
  String get practiceRecords => 'Записи';

  @override
  String get practiceRecordsLocalOnlyFooter =>
      'Спроби зберігаються лише на цьому пристрої й нікуди не завантажуються.';

  @override
  String get practiceRecordsEmpty =>
      'Для цієї фрази ще немає збережених спроб.';

  @override
  String get practiceRecordingProcessError =>
      'Під час обробки запису щось пішло не так.';

  @override
  String get practiceStartOver => 'Почати спочатку';

  @override
  String get practiceTranscriptHidden => 'Текст приховано';

  @override
  String get practiceListenCarefully => 'Слухай уважно…';

  @override
  String get practiceTranslationUnavailableForCue =>
      'Переклад цієї фрази зараз недоступний.';

  @override
  String get practiceChooseTranslationLanguageTitle => 'Вибери мову перекладу';

  @override
  String get practiceChooseTranslationLanguageDescription =>
      'Bantera перекладатиме практику слухання цією мовою й збереже її у твоєму профілі для наступних занять.';

  @override
  String get practiceChangeTranslationLanguageTitle => 'Змінити мову перекладу';

  @override
  String get practiceChangeTranslationLanguageDescription =>
      'Вибери мову, якою Bantera має перекладати. Новий вибір буде збережено у твоєму профілі.';

  @override
  String get practiceConfirmTranslationLanguageTitle =>
      'Підтвердь мову перекладу';

  @override
  String get practiceConfirmTranslationLanguageBody =>
      'Bantera збереже цю мову у твоєму профілі й використовуватиме її як мову перекладу за замовчуванням у наступних практиках слухання.';

  @override
  String get practiceCouldNotSaveTranslationLanguage =>
      'Bantera не вдалося зберегти мову перекладу.';

  @override
  String get practiceNoTranslationLanguagesFound =>
      'Bantera не знайшла жодної мови перекладу для цього тексту.';

  @override
  String get practicePlayAllTitle => 'Шедоуінг';

  @override
  String get practicePlayAllDescription => 'Пауза між фразами для шедоуінгу:';

  @override
  String get practicePlayAllPauseZeroSeconds => '0 с';

  @override
  String get practicePlayAllPauseOneSecondLabel => '1 с';

  @override
  String get practicePlayAllPauseOneCuePlusOneSecond => '1 фраза + 1 с';

  @override
  String get practicePlayAllPauseOneCuePlusTwoSeconds => '1 фраза + 2 с';

  @override
  String get practicePlayAllTimesPerCueTitle => 'Повторів на фразу';

  @override
  String get practicePlayAllTimesOnce => '1×';

  @override
  String get practicePlayAllTimesTwice => '2×';

  @override
  String get practicePlayAllTimesThrice => '3×';

  @override
  String get practiceSearchLanguagesHint => 'Пошук мов';

  @override
  String get practiceTranslationInstalled => 'Встановлено';

  @override
  String get practiceTranslationDownload => 'Завантажити';

  @override
  String get practiceStartOverTitle => 'Почати спочатку?';

  @override
  String get practiceStartOverBody => 'Повернутися до першої фрази?';

  @override
  String get practiceNextFromLastTitle => 'Перейти до першої фрази?';

  @override
  String get practiceNextFromLastBody =>
      'Це остання фраза. Повернутися до першої?';

  @override
  String get practiceGoToFirstCue => 'До першої фрази';

  @override
  String get practiceVideoOpenError =>
      'Не вдалося відкрити вибране відео для практики.';

  @override
  String get practiceAudioLoading => 'Завантаження аудіо…';

  @override
  String practiceAudioLoadingPercent(int percent) {
    return 'Завантаження аудіо $percent%';
  }

  @override
  String get practiceAudioError =>
      'Не вдалося завантажити аудіо. Спробуй ще раз.';

  @override
  String get compareRecordYourVersion => 'Запиши свою версію';

  @override
  String compareTranscriptionLanguage(String locale) {
    return 'Мова розпізнавання: $locale';
  }

  @override
  String get compareOpenIphoneSettings => 'Відкрити Параметри iPhone';

  @override
  String get comparePauseAttempt => 'Пауза';

  @override
  String get comparePlayAttempt => 'Прослухати спробу';

  @override
  String get compareYourTranscribedAttempt => 'Розпізнаний текст твоєї спроби';

  @override
  String get compareHighlightHint =>
      'Слова, які Bantera розпізнала інакше, виділено.';

  @override
  String get compareUncertainHint =>
      'Слова з пунктиром розпізнано, але Bantera не впевнена — перевір свою вимову.';

  @override
  String get compareTryAgain => 'Ще раз';

  @override
  String get compareDone => 'Готово';

  @override
  String get compareStatusTranscribing =>
      'Розпізнавання твоєї спроби на iPhone…';

  @override
  String get compareStatusRecording => 'Запис… Торкнись ще раз, щоб зупинити.';

  @override
  String get compareStatusSavedAttempt =>
      'Показано збережену спробу для цієї фрази. Можеш прослухати її або спробувати ще раз.';

  @override
  String get compareStatusReplayOrRetry =>
      'Можеш прослухати цю спробу або повторити фразу ще раз.';

  @override
  String get compareStatusTapToRecord =>
      'Торкнись, щоб записати свою версію цієї фрази.';

  @override
  String get compareCouldNotStartRecording =>
      'Bantera зараз не може почати запис.';

  @override
  String get compareCouldNotAccessRecording =>
      'Bantera не вдалося отримати доступ до запису.';

  @override
  String get compareNoTranscriptGenerated =>
      'Не вдалося розпізнати текст цієї спроби. Спробуй ще раз ближче до мікрофона.';

  @override
  String get compareRecentAttempts => 'Останні спроби';

  @override
  String get compareAttemptsFooterNote =>
      'Bantera зберігає твої спроби на цьому iPhone — так легше стежити за прогресом у тій самій фразі.';

  @override
  String compareMatchedCount(int count) {
    return 'Збіглося: $count';
  }

  @override
  String compareDifferentCount(int count) {
    return 'Інакше: $count';
  }

  @override
  String compareMissingCount(int count) {
    return 'Пропущено: $count';
  }

  @override
  String compareUncertainCount(int count) {
    return 'Нечітко: $count';
  }

  @override
  String get compareMicrophoneDeniedPermanent =>
      'Доступ до мікрофона для Bantera вимкнено. Відкрий Параметри iPhone > Bantera > Мікрофон і ввімкни його, щоб записати свою версію.';

  @override
  String get compareMicrophoneDeniedRestricted =>
      'Цей iPhone зараз обмежує доступ Bantera до мікрофона. Перевір Екранний час, керування пристроєм або системні параметри, щоб увімкнути його.';

  @override
  String get compareMicrophoneDeniedDefault =>
      'Щоб записати свою версію, потрібен дозвіл на мікрофон. Якщо запит раніше було відхилено, відкрий Параметри iPhone > Bantera > Мікрофон і ввімкни його.';

  @override
  String get compareSpeechRecognitionDeniedPermanent =>
      'Доступ до розпізнавання мовлення для Bantera вимкнено. Відкрий Параметри iPhone > Bantera > Розпізнавання мовлення й увімкни його, щоб порівняти свій запис.';

  @override
  String get compareSpeechRecognitionDeniedRestricted =>
      'Цей iPhone зараз обмежує розпізнавання мовлення для Bantera. Перевір Екранний час, керування пристроєм або системні параметри, щоб увімкнути його.';

  @override
  String get compareSpeechRecognitionUnavailable =>
      'Розпізнавання мовлення зараз недоступне на цьому iPhone.';

  @override
  String get compareSpeechRecognitionUnsupportedLocale =>
      'На цьому iPhone розпізнавання мовлення недоступне для цієї мови практики.';

  @override
  String get comparePlayAttemptTooltip => 'Прослухати спробу';

  @override
  String get comparePauseAttemptTooltip => 'Призупинити спробу';

  @override
  String get createWhatToday => 'Чим займемося сьогодні?';

  @override
  String get createPracticeVideo => 'Практика з відео';

  @override
  String get createYourMedia => 'Твої медіа';

  @override
  String get createTryAgain => 'Спробувати ще раз';

  @override
  String get createUploadedVideosEmptyHint =>
      'Тут з’являться завантажені тобою відео, щоб відкривати їх знову й практикуватися фраза за фразою.';

  @override
  String get createUploadingTips => 'Поради щодо завантаження';

  @override
  String get createUploadingTipsBody =>
      'Для найкращого результату аудіо має бути коротшим за 3 хвилини. Чіткі субтитри створюються автоматично!';

  @override
  String get createOnThisIphone => 'На цьому iPhone';

  @override
  String get createLocalVideosEmptyHint =>
      'Відео, з якими ти практикуєшся локально, зберігаються на цьому iPhone — їх можна відкрити знову без повторного розпізнавання.';

  @override
  String get createOnDeviceBadge => 'На пристрої';

  @override
  String get createSignInToLoadVideos =>
      'Увійди знову, щоб завантажити свої відео.';

  @override
  String createVideoMetaCues(int count) {
    return 'Фраз: $count';
  }

  @override
  String get createPublicBadge => 'Публічне';

  @override
  String get createPrivateBadge => 'Приватне';

  @override
  String get createAiBadge => 'ШІ';

  @override
  String get createDeleteSavedVideoTitle => 'Видалити збережене відео?';

  @override
  String createDeleteSavedVideoBody(String title) {
    return 'Bantera видалить «$title» з цього iPhone разом зі збереженими фразами тексту.';
  }

  @override
  String get createDeleteMediaTitle => 'Видалити медіа?';

  @override
  String createDeleteMediaBody(String title) {
    return '«$title» і його текст буде видалено назавжди. Цю дію не можна скасувати.';
  }

  @override
  String get removeFromListTitle => 'Прибрати зі списку?';

  @override
  String get removeFromListBody =>
      'Елемент буде прибрано зі списку. Цю дію не можна скасувати.';

  @override
  String get editProfileChangeImage => 'Змінити фото профілю';

  @override
  String get editProfileUploading => 'Завантаження…';

  @override
  String get editProfileNameLabel => 'Ім’я';

  @override
  String get editProfileNameHint => 'Як Bantera має показувати твоє ім’я?';

  @override
  String get editProfileSaveNameButton => 'Зберегти ім’я';

  @override
  String get editProfileSaving => 'Збереження…';

  @override
  String get editProfileLanguagesSection => 'Мови';

  @override
  String get editProfileMyNativeLanguage => 'Моя рідна мова';

  @override
  String get editProfileMyNativeLanguageSubtitle => 'Твоя рідна або перша мова';

  @override
  String get editProfileLearningLanguage => 'Мова навчання';

  @override
  String get editProfileLearningLanguageSubtitle =>
      'Мова, яку ти хочеш практикувати';

  @override
  String get editProfileImageUpdated => 'Фото профілю оновлено.';

  @override
  String get editProfileNameUpdated => 'Ім’я оновлено.';

  @override
  String get editProfileEnterName => 'Введи ім’я.';

  @override
  String get editProfileNameMaxLength => 'Не більше 80 символів.';

  @override
  String get editProfileCouldNotLoadLanguages =>
      'Не вдалося завантажити список мов.';

  @override
  String get languagePickerNone => 'Немає';

  @override
  String get languagePickerClearSelection => 'Скинути вибір';

  @override
  String get languagePickerNoMatchingLanguages => 'Мов не знайдено.';

  @override
  String get languagePickerMoreComingSoon => 'Незабаром більше мов';

  @override
  String get editProfileNativeLanguageCleared => 'Рідну мову скинуто.';

  @override
  String get editProfileLearningLanguageCleared => 'Мову навчання скинуто.';

  @override
  String editProfileNativeLanguageSetTo(String language) {
    return 'Рідна мова: $language.';
  }

  @override
  String editProfileLearningLanguageSetTo(String language) {
    return 'Мова навчання: $language.';
  }

  @override
  String get profileLanguageSettings => 'Мовні налаштування';

  @override
  String get profileLearningLabel => 'Вивчаю';

  @override
  String get profileNotSet => 'Не вказано';

  @override
  String get uploadedDetailYourAudio => 'Твоє аудіо';

  @override
  String get uploadedDetailYourVideo => 'Твоє відео';

  @override
  String get uploadedDetailDeleteAudioTitle => 'Видалити аудіо?';

  @override
  String get uploadedDetailDeleteAudioBody =>
      'Аудіо та його текст буде видалено назавжди. Цю дію не можна скасувати.';

  @override
  String get uploadedDetailDeleteVideoTitle => 'Видалити відео?';

  @override
  String get uploadedDetailDeleteVideoBody =>
      'Відео та його текст буде видалено назавжди. Цю дію не можна скасувати.';

  @override
  String get uploadedDetailAiGenerated => 'Створено ШІ';

  @override
  String get uploadedDetailFileSize => 'Розмір файлу';

  @override
  String get uploadedDetailResolution => 'Роздільність';

  @override
  String get uploadedDetailResolutionUnknown => 'Невідомо';

  @override
  String get uploadedDetailTranscribing => 'Розпізнавання тексту…';

  @override
  String get uploadedDetailNoTranscriptCuesYet => 'Фраз тексту поки немає.';

  @override
  String uploadedDetailMediaDescription(int count) {
    return 'Твій завантажений кліп для практики. Фраз у тексті: $count.';
  }

  @override
  String get uploadedDetailTranscriptionFailedFallback =>
      'Не вдалося розпізнати текст. Використано приблизні фрази.';

  @override
  String get uploadedDetailTranscriptionNoCues =>
      'Розпізнавання не повернуло жодної фрази.';

  @override
  String get uploadedDetailTranscriptionSourceYourUpload => 'Твоє завантаження';

  @override
  String get aiGenLeaveTitle => 'Залишити сторінку?';

  @override
  String get aiGenLeaveBody =>
      'Аудіо ще генерується. Якщо вийти зараз, процес буде скасовано.';

  @override
  String get aiGenStay => 'Залишитися';

  @override
  String get aiGenLeave => 'Вийти';

  @override
  String get aiGenLoadingTitle => 'Створюємо твоє аудіо…';

  @override
  String get aiGenLoadingSubtitle =>
      'Це може тривати до хвилини.\nНе залишай цю сторінку під час генерації.';

  @override
  String get aiGenStepPreparingSpeechModel =>
      'Підготовка моделі мовлення на пристрої';

  @override
  String get aiGenStepWritingDialogue => 'Написання діалогу';

  @override
  String get aiGenStepGeneratingAudio => 'Генерування аудіо';

  @override
  String get aiGenStepAligningAudio => 'Синхронізація аудіо';

  @override
  String get aiGenStepTranscribing => 'Розпізнавання тексту';

  @override
  String get aiGenStepCorrectingTranscript => 'Виправлення тексту';

  @override
  String get aiGenLanguageSection => 'Мова';

  @override
  String get aiGenSetLearningLanguagePrompt =>
      'Вкажи мову, яку вивчаєш, щоб увімкнути генерацію';

  @override
  String get aiGenLoadingLanguage => 'Завантаження мови…';

  @override
  String aiGenLanguageUnsupported(String language) {
    return 'Мова «$language» не підтримується для генерації.';
  }

  @override
  String get aiGenScenarioSection => 'Сценарій';

  @override
  String get aiGenScenarioOptionalHint =>
      'Необов’язково — нічого не вибирай, щоб отримати випадковий сценарій.';

  @override
  String get aiGenCustomScenarioHint => 'Опиши свій сценарій…';

  @override
  String get aiGenDurationSection => 'Тривалість';

  @override
  String aiGenDurationMinutes(int minutes) {
    return '$minutes хв';
  }

  @override
  String get aiGenGenerateButton => 'Згенерувати';

  @override
  String get aiGenOwnershipNotice =>
      'Аудіо, яке ти тут створюєш, стає частиною спільноти Bantera — його публічно поширюють як матеріал для практики всім, хто вчиться.';

  @override
  String get aiGenOwnershipCheckbox =>
      'Поширити це аудіо як матеріал спільноти Bantera';

  @override
  String get aiGenOwnershipConfirmTitle => 'Поширити як матеріал спільноти?';

  @override
  String get aiGenOwnershipConfirmCancel => 'Скасувати';

  @override
  String get aiGenOwnershipConfirmGenerate => 'Згенерувати';

  @override
  String get aiGenFooterNotice =>
      'ШІ напише діалог для двох осіб і озвучить його. Результат буде збережено як публічне аудіо для практики.';

  @override
  String get aiScenarioCoffeeShop => 'У кав’ярні';

  @override
  String get aiScenarioLatestNews => 'Останні новини';

  @override
  String get aiScenarioAirportReunion => 'Зустріч в аеропорту';

  @override
  String get aiScenarioGroceryStore => 'У продуктовому';

  @override
  String get aiScenarioDoctorVisit => 'У лікаря';

  @override
  String get aiScenarioJobInterview => 'Співбесіда';

  @override
  String get aiScenarioNewNeighbour => 'Новий сусід';

  @override
  String get aiScenarioTechSupport => 'Техпідтримка';

  @override
  String get aiScenarioBirthdaySurprise => 'Сюрприз на день народження';

  @override
  String get aiScenarioGymTips => 'Поради в спортзалі';

  @override
  String get aiScenarioWeatherSmalltalk => 'Розмова про погоду';

  @override
  String get aiScenarioRestaurantOrder => 'Замовлення в ресторані';

  @override
  String get aiScenarioBookRecommendation => 'Порада щодо книжки';

  @override
  String get aiScenarioBusDelay => 'Автобус запізнюється';

  @override
  String get aiScenarioMovieDebate => 'Суперечка про фільм';

  @override
  String get aiScenarioCustom => 'Власний…';

  @override
  String get errorNetworkUnreachable =>
      'Не вдалося підключитися до Bantera. Перевір інтернет-з’єднання.';

  @override
  String get errorNetworkCellularBlocked =>
      'Мобільні дані для Bantera вимкнено. У Параметрах відкрий Bantera й увімкни «Мобільні дані» або підключися до Wi-Fi.';

  @override
  String get errorTlsConnection => 'Не вдалося встановити захищене з’єднання.';

  @override
  String get settingsRateAppPrompt =>
      'Подобається Bantera? Коротка оцінка в App Store дуже важлива для нас.';

  @override
  String get settingsRateAppButton => 'Оцінити в App Store';

  @override
  String get settingsSharePrompt =>
      'Знаєш когось, хто вивчає мову? Поділися з ним Bantera.';

  @override
  String get settingsShareButton => 'Поділитися Bantera';

  @override
  String get settingsContactButton => 'Зв’язатися з нами';

  @override
  String get localVideoDescription =>
      'Вибери відео з Фото, вкажи мову мовлення — і iPhone розпізнає текст у фоні, перш ніж ти почнеш практику фраза за фразою.';

  @override
  String get localVideoStep1Title => '1. Вибери відео';

  @override
  String get localVideoChooseFromPhotos => 'Вибрати з Фото';

  @override
  String get localVideoChooseDifferent => 'Вибрати інше відео';

  @override
  String get localVideoSelectedFileLabel => 'Вибраний файл';

  @override
  String get localVideoSizeLabel => 'Розмір';

  @override
  String get localVideoDurationLabel => 'Тривалість';

  @override
  String get localVideoLongVideoWarning =>
      'Це відео довше за 3 хвилини, тому Bantera може знадобитися більше часу, щоб підготувати текст і переклад.';

  @override
  String get localVideoStep2Title => '2. Мова розпізнавання';

  @override
  String get localVideoChooseLanguagePlaceholder => 'Вибери мову мовлення';

  @override
  String get localVideoLanguageHint =>
      'Bantera запам’ятовує твій останній вибір мови й за замовчуванням приховує текст, коли починається практика.';

  @override
  String get localVideoStep3Title => '3. Практика';

  @override
  String get localVideoPreparing => 'Підготовка...';

  @override
  String get localVideoPracticeHint =>
      'Bantera спершу розпізнає текст на пристрої, а потім відкриває сторінку слухання фраза за фразою — нічого не завантажуючи.';

  @override
  String get localVideoStatusLongVideo =>
      'Це довше відео, тож Bantera може знадобитися додатковий час, щоб розпізнати й підготувати його.';

  @override
  String get localVideoStatusTranscribing =>
      'Розпізнавання тексту на пристрої й підготовка фраз для практики...';

  @override
  String get localVideoStatusSaving =>
      'Збереження відео в бібліотеці практики на пристрої...';

  @override
  String get localVideoStatusTranslationLong =>
      'Розпізнавання завершено. Bantera також готує переклад збереженою мовою, тож для довшого відео це може зайняти трохи більше часу.';

  @override
  String get localVideoStatusTranslation =>
      'Розпізнавання завершено. Готуємо переклад збереженою мовою...';

  @override
  String get localVideoPickerTitle => 'Вибери мову аудіо';

  @override
  String get savedCuesTitle => 'Збережені фрази';

  @override
  String get savedCuesEmpty =>
      'Збережених фраз ще немає. Під час практики торкнись значка закладки, щоб зберегти фразу.';

  @override
  String get savedCuesDeleteTooltip => 'Прибрати збережену фразу';

  @override
  String get savedCuesDeleteConfirmTitle => 'Прибрати цю фразу?';

  @override
  String get savedCuesDeleteConfirmBody =>
      'Фразу буде прибрано зі списку збережених.';

  @override
  String get savedCuesDeleteAllTooltip => 'Видалити всі збережені фрази';

  @override
  String get savedCuesDeleteAllConfirmTitle => 'Видалити всі збережені фрази?';

  @override
  String get savedCuesDeleteAllConfirmBody =>
      'Усі збережені фрази буде видалено назавжди.';

  @override
  String get updateAlertTitle => 'Доступне оновлення';

  @override
  String get updateAlertMessage =>
      'Доступна нова версія Bantera. Онови зараз, щоб отримати нові функції та покращення.';

  @override
  String get updateCurrentVersionLabel => 'Поточна версія';

  @override
  String get updateAppStoreVersionLabel => 'Версія в App Store';

  @override
  String get updateAlertUpdate => 'Оновити';

  @override
  String get updateAlertLater => 'Пізніше';

  @override
  String get checkForUpdateButton => 'Перевірити оновлення';

  @override
  String get upToDateAlertTitle => 'Актуальна версія';

  @override
  String upToDateAlertMessage(Object version) {
    return 'Bantera $version — це остання версія.';
  }

  @override
  String get sectionSupport => 'Підтримка';

  @override
  String get permissionActionAllow => 'Дозволити';
}
