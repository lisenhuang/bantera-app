// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appName => 'Bantera';

  @override
  String get appTagline => 'Nauka języka fraza po frazie.';

  @override
  String get authContinueWithApple => 'Kontynuuj z Apple';

  @override
  String get authContinueWithGoogle => 'Kontynuuj z Google';

  @override
  String get authAppleUnavailable =>
      'Logowanie przez Apple jest niedostępne na tym urządzeniu.';

  @override
  String get authOrSignInEmail => 'lub zaloguj się e-mailem';

  @override
  String get authEmail => 'E-mail';

  @override
  String get authPassword => 'Hasło';

  @override
  String get authSigningIn => 'Logowanie...';

  @override
  String get authSignIn => 'Zaloguj się';

  @override
  String get authSignInWithEmail => 'Zaloguj się e-mailem';

  @override
  String get validationEnterEmail => 'Podaj adres e-mail.';

  @override
  String get validationValidEmail => 'Podaj prawidłowy adres e-mail.';

  @override
  String get validationEnterPassword => 'Podaj hasło.';

  @override
  String get onboardingTitle => 'Skonfiguruj profil';

  @override
  String get onboardingSubtitle =>
      'Dzięki temu Bantera dopasuje ćwiczenia i czat do Ciebie.';

  @override
  String get onboardingNameTitle => 'Jak mamy się do Ciebie zwracać?';

  @override
  String get onboardingNameSubtitle =>
      'Uzupełniliśmy to danymi z Twojego konta Apple. Możesz to teraz zmienić.';

  @override
  String get onboardingClearName => 'Wyczyść imię';

  @override
  String get onboardingNativeLanguageTitle => 'Jaki jest Twój język ojczysty?';

  @override
  String get onboardingNativeLanguageSubtitle =>
      'Bantera używa go do tłumaczeń i grup językowych.';

  @override
  String get onboardingLearningLanguageTitle => 'Jakiego języka się uczysz?';

  @override
  String get onboardingLearningLanguageSubtitle =>
      'Od tego zależą materiały do ćwiczeń i grupy nauki.';

  @override
  String get onboardingAvatarTitle => 'Dodaj zdjęcie profilowe';

  @override
  String get onboardingAvatarSubtitle =>
      'Wybierz zdjęcie lub przejdź dalej, a Bantera wygeneruje je dla Ciebie.';

  @override
  String get onboardingAvatarGenderTitle => 'Wygeneruj zdjęcie profilowe';

  @override
  String get onboardingAvatarGenderBody =>
      'Wybierz, jak Bantera ma wygenerować Twoje zdjęcie profilowe. Nie zapisujemy tego wyboru – służy tylko do utworzenia tego obrazu.';

  @override
  String get onboardingAvatarGenderMale => 'Mężczyzna';

  @override
  String get onboardingAvatarGenderFemale => 'Kobieta';

  @override
  String get onboardingChoosePhoto => 'Wybierz zdjęcie';

  @override
  String get onboardingChangePhoto => 'Zmień zdjęcie';

  @override
  String get onboardingUseGeneratedAvatar => 'Użyj wygenerowanego awatara';

  @override
  String get onboardingUseCurrentPhoto => 'Użyj obecnego zdjęcia';

  @override
  String get onboardingChooseLanguage => 'Wybierz język';

  @override
  String get onboardingBack => 'Wstecz';

  @override
  String get onboardingFinish => 'Zakończ';

  @override
  String get onboardingLoadingProfile => 'Wczytywanie profilu...';

  @override
  String get onboardingSavingProfile => 'Zapisywanie profilu...';

  @override
  String get onboardingLoadFailed => 'Coś poszło nie tak. Spróbuj ponownie.';

  @override
  String get onboardingSearchHint => 'Szukaj języków…';

  @override
  String get onboardingRetry => 'Ponów';

  @override
  String get onboardingNoMatching => 'Brak pasujących języków.';

  @override
  String get onboardingFailedSave => 'Nie udało się zapisać.';

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String get sectionAppearance => 'Wygląd';

  @override
  String get sectionAccount => 'Konto';

  @override
  String get sectionRateAndShare => 'Oceń i poleć';

  @override
  String get sectionLanguage => 'Język aplikacji';

  @override
  String get sectionPermissions => 'Uprawnienia';

  @override
  String get sectionNotifications => 'Powiadomienia';

  @override
  String get languageSectionSubtitle =>
      'Wybierz język aplikacji. Opcja „Systemowy” korzysta z ustawień urządzenia.';

  @override
  String get themeLabel => 'Motyw';

  @override
  String get themeLight => 'Jasny';

  @override
  String get themeDark => 'Ciemny';

  @override
  String get themeSystem => 'Systemowy';

  @override
  String get languageEnglish => 'Angielski';

  @override
  String get languageChineseSimplified => 'Chiński (uproszczony)';

  @override
  String get languageKorean => 'Koreański';

  @override
  String get languageJapanese => 'Japoński';

  @override
  String get signedOutLabel => 'Wylogowano';

  @override
  String get noActiveSession => 'Brak aktywnej sesji Bantera';

  @override
  String signedInWith(String provider) {
    return 'Zalogowano przez $provider';
  }

  @override
  String get editProfile => 'Edytuj profil';

  @override
  String get more => 'Więcej';

  @override
  String get appPermissionsTitle => 'Uprawnienia aplikacji';

  @override
  String get appPermissionsSubtitle =>
      'Sprawdź, z czego Bantera korzysta na tym urządzeniu.';

  @override
  String get permissionsIntro =>
      'Bantera korzysta z tych ustawień urządzenia do nagrywania, porównywania wymowy i dostępu do sieci.';

  @override
  String get permissionsOpenSettings => 'Otwórz Ustawienia iPhone’a';

  @override
  String get permissionsRefresh => 'Odśwież';

  @override
  String get permissionMicrophoneTitle => 'Mikrofon';

  @override
  String get permissionMicrophoneDescription =>
      'Nagrywaj próby wymowy i wiadomości głosowe.';

  @override
  String get permissionSpeechTitle => 'Rozpoznawanie mowy';

  @override
  String get permissionSpeechDescription =>
      'Transkrybuj nagrania z ćwiczeń i wiadomości głosowe.';

  @override
  String get permissionMobileDataTitle => 'Dane komórkowe';

  @override
  String get permissionMobileDataDescription =>
      'Korzystaj z aplikacji Bantera, gdy iPhone nie jest połączony z Wi-Fi.';

  @override
  String get permissionStatusAllowed => 'Dozwolony';

  @override
  String get permissionStatusLimited => 'Ograniczony';

  @override
  String get permissionStatusNotAllowed => 'Niedozwolony';

  @override
  String get permissionStatusUnknown => 'Nieznany';

  @override
  String get signOut => 'Wyloguj się';

  @override
  String get signOutDialogTitle => 'Wylogować się?';

  @override
  String get signOutDialogBody =>
      'Aby korzystać z konta, musisz zalogować się ponownie.';

  @override
  String get cancel => 'Anuluj';

  @override
  String get closeLabel => 'Zamknij';

  @override
  String get navDiscover => 'Odkrywaj';

  @override
  String get navCreate => 'Twórz';

  @override
  String get navProfile => 'Profil';

  @override
  String get chatsTitle => 'Czaty';

  @override
  String get chatNoChatsYet => 'Nie masz jeszcze czatów.';

  @override
  String get chatOnlineSection => 'Online';

  @override
  String get chatDirectMessagesSection => 'Prywatne';

  @override
  String chatAudioDuration(String duration) {
    return 'Nagranie $duration';
  }

  @override
  String get chatEnableNotifications => 'Włącz powiadomienia';

  @override
  String get chatMuteNotifications => 'Wycisz powiadomienia';

  @override
  String get chatBlockUser => 'Zablokuj użytkownika';

  @override
  String get chatDeleteDm => 'Usuń rozmowę';

  @override
  String get chatCall => 'Zadzwoń';

  @override
  String get chatStartAudioCall => 'Połączenie głosowe';

  @override
  String get chatStartVideoCall => 'Połączenie wideo';

  @override
  String get chatAudioCalling => 'Połączenie głosowe...';

  @override
  String get chatVideoCalling => 'Połączenie wideo...';

  @override
  String get chatAudioIncoming => 'Przychodzące połączenie głosowe';

  @override
  String get chatVideoIncoming => 'Przychodzące połączenie wideo';

  @override
  String get chatCallConnecting => 'Łączenie...';

  @override
  String get chatCallAccept => 'Odbierz';

  @override
  String get chatCallDecline => 'Odrzuć';

  @override
  String get chatCallEnd => 'Zakończ';

  @override
  String get chatCallMute => 'Wycisz';

  @override
  String get chatCallUnmute => 'Wyłącz wyciszenie';

  @override
  String get chatCallSpeaker => 'Głośnik';

  @override
  String get chatCallCamera => 'Kamera';

  @override
  String get chatCallSwitchCamera => 'Przełącz';

  @override
  String get chatCallIssueTitle => 'Problem z połączeniem';

  @override
  String get chatCallMicrophoneDenied =>
      'Bantera potrzebuje dostępu do mikrofonu, aby rozpocząć połączenie.';

  @override
  String get chatCallMicrophoneSettings =>
      'Dostęp aplikacji Bantera do mikrofonu jest wyłączony. Otwórz Ustawienia i włącz go, aby dzwonić.';

  @override
  String get chatCallCameraDenied =>
      'Bantera potrzebuje dostępu do kamery, aby rozpocząć połączenie wideo.';

  @override
  String get chatCallCameraSettings =>
      'Dostęp aplikacji Bantera do kamery jest wyłączony. Otwórz Ustawienia i włącz go, aby prowadzić połączenia wideo.';

  @override
  String get chatCallBusy => 'Ten użytkownik prowadzi już inną rozmowę.';

  @override
  String get chatCallUnavailable => 'Ten użytkownik jest teraz niedostępny.';

  @override
  String get chatCallNetworkRestricted =>
      'W tej sieci nie można nawiązać połączenia. Spróbuj przez Wi-Fi lub inną sieć.';

  @override
  String get chatCallFailed =>
      'Nie udało się rozpocząć połączenia. Spróbuj ponownie.';

  @override
  String get chatGroupReady => 'Ta grupa jest gotowa na wiadomości głosowe.';

  @override
  String get chatHoldToStartDm =>
      'Przytrzymaj, aby nagrać wiadomość i rozpocząć rozmowę.';

  @override
  String get chatNoGroupAudio => 'W grupie nie ma jeszcze nagrań.';

  @override
  String get chatNoDmAudio => 'W tej rozmowie nie ma jeszcze nagrań.';

  @override
  String get chatSendingAudio => 'Wysyłanie nagrania...';

  @override
  String get chatRecordingReleaseToSend => 'Nagrywanie... puść, aby wysłać';

  @override
  String get chatHoldToRecordAudio => 'Przytrzymaj, aby nagrać';

  @override
  String get chatRecordingStatus => 'Nagrywanie...';

  @override
  String get chatGroupLabel => 'Grupa';

  @override
  String get chatNotificationsEnabledForDm =>
      'Powiadomienia dla tej rozmowy są włączone.';

  @override
  String get chatNotificationsMutedForDm =>
      'Powiadomienia dla tej rozmowy są wyciszone.';

  @override
  String chatBlockUserTitle(String user) {
    return 'Zablokować użytkownika $user?';
  }

  @override
  String get chatBlockUserBody =>
      'Do czasu odblokowania nie będziecie widzieć swoich wiadomości prywatnych ani wiadomości we wspólnych grupach.';

  @override
  String chatBlockUserSuccess(String user) {
    return 'Zablokowano użytkownika $user.';
  }

  @override
  String get chatBlockUserFailed =>
      'Nie udało się zablokować użytkownika. Spróbuj ponownie.';

  @override
  String get chatDeleteMessage => 'Usuń wiadomość';

  @override
  String get chatDeleteMessageTitle => 'Usunąć tę wiadomość?';

  @override
  String get chatDeleteMessageBody =>
      'Wiadomość zostanie usunięta dla wszystkich uczestników rozmowy. Tej operacji nie można cofnąć.';

  @override
  String get chatDeleteMessageSuccess => 'Wiadomość usunięta';

  @override
  String get chatDeleteMessageFailed =>
      'Nie udało się usunąć wiadomości. Spróbuj ponownie.';

  @override
  String get chatDeleteDmTitle => 'Usunąć tę rozmowę?';

  @override
  String get chatDeleteDmBody =>
      'Rozmowa zniknie tylko z Twojej listy. Nowa wiadomość może ją później przywrócić.';

  @override
  String get chatMicrophoneRequiredTitle => 'Wymagany mikrofon';

  @override
  String get chatMicrophoneRequiredSettings =>
      'Bantera potrzebuje dostępu do mikrofonu, aby nagrywać wiadomości głosowe. Włącz go w Ustawieniach.';

  @override
  String get chatMicrophoneRequiredBody =>
      'Bantera potrzebuje dostępu do mikrofonu, aby nagrywać wiadomości głosowe.';

  @override
  String get chatGroupNotReady => 'Ta grupa nie jest jeszcze gotowa.';

  @override
  String get chatMessageAction => 'Napisz';

  @override
  String get chatRetranscribe => 'Transkrybuj ponownie';

  @override
  String get chatTranscribe => 'Transkrybuj';

  @override
  String get chatTranscribingOnDevice => 'Transkrypcja na tym iPhonie...';

  @override
  String get chatTranscriptionFailed =>
      'Transkrypcja nie powiodła się. Spróbuj ponownie.';

  @override
  String get chatTranslate => 'Przetłumacz';

  @override
  String get chatRetranslate => 'Przetłumacz ponownie';

  @override
  String get chatTranslating => 'Tłumaczenie na tym iPhonie...';

  @override
  String get chatTranslationFailed =>
      'Tłumaczenie nie powiodło się. Spróbuj ponownie.';

  @override
  String get chatGroupSettingsTitle => 'Ustawienia grupy';

  @override
  String get chatNotifications => 'Powiadomienia';

  @override
  String get chatBlockedUsersMenu => 'Zablokowani użytkownicy';

  @override
  String get chatBlockedUsersTitle => 'Zablokowani użytkownicy';

  @override
  String get chatBlockedPeople => 'Zablokowane osoby';

  @override
  String get chatNoBlockedUsers => 'Brak zablokowanych użytkowników.';

  @override
  String get chatNoBlockedPeople => 'Brak zablokowanych osób.';

  @override
  String get chatUnblock => 'Odblokuj';

  @override
  String chatUnblockUserTitle(String user) {
    return 'Odblokować użytkownika $user?';
  }

  @override
  String get chatUnblockUserBody =>
      'Znów możecie widzieć swoje wiadomości prywatne i wiadomości we wspólnych grupach.';

  @override
  String get chatUnblockFailed =>
      'Nie udało się odblokować użytkownika. Spróbuj ponownie.';

  @override
  String get chatNotificationsTitle => 'Powiadomienia czatu';

  @override
  String get chatNotificationsSubtitle =>
      'Jeden przełącznik dla całego konta na wszystkich Twoich urządzeniach.';

  @override
  String get chatNotificationsDisabledTitle => 'Powiadomienia wyłączone';

  @override
  String get chatNotificationsDisabledSettings =>
      'Włącz powiadomienia w Ustawieniach, aby otrzymywać alerty czatu Bantera.';

  @override
  String get chatNotificationsDisabledBody =>
      'Aby włączyć alerty czatu, Bantera potrzebuje zgody na powiadomienia.';

  @override
  String get chatNotificationUpdateFailed =>
      'Nie udało się zmienić powiadomień czatu. Spróbuj ponownie.';

  @override
  String get savedTitle => 'Zapisane materiały';

  @override
  String get generateWithAiTitle => 'Generuj z AI';

  @override
  String get practiceLocalVideoTitle => 'Ćwicz z lokalnym wideo';

  @override
  String get uploadVideoTitle => 'Prześlij wideo';

  @override
  String get lessonDetailsTitle => 'Szczegóły lekcji';

  @override
  String get accountMoreTitle => 'Więcej';

  @override
  String get deleteAccount => 'Usuń konto';

  @override
  String get deleteAccountSubtitle => 'Trwale usuń konto i dane z serwera';

  @override
  String get confirmDeletionTitle => 'Potwierdź usunięcie';

  @override
  String get deleteAccountImmediateBody =>
      'Twoje konto zostanie natychmiast usunięte. Aby znów korzystać z aplikacji Bantera, musisz założyć nowe konto.';

  @override
  String get deleteAccountConfirm => 'Usuń konto';

  @override
  String get couldNotDeleteAccount =>
      'Nie udało się usunąć konta. Spróbuj ponownie.';

  @override
  String get deleteAccountQuestionTitle => 'Usunąć konto?';

  @override
  String get deleteAccountQuestionBody =>
      'Wszystkie Twoje dane osobowe i pozostałe dane zostaną trwale usunięte z naszych serwerów i nie będzie można ich odzyskać.';

  @override
  String get typeDeleteLabel => 'Wpisz „DELETE”, aby kontynuować';

  @override
  String get continueLabel => 'Dalej';

  @override
  String get confirmLabel => 'Potwierdź';

  @override
  String get deleteLabel => 'Usuń';

  @override
  String get removeFromListLabel => 'Usuń z listy';

  @override
  String get startLabel => 'Rozpocznij';

  @override
  String get doneLabel => 'Gotowe';

  @override
  String get discoverSearchHint => 'Szukaj w tytułach i transkrypcjach…';

  @override
  String get discoverNoMoreResults => 'Brak kolejnych wyników';

  @override
  String get discoverSetLearningLanguagePrompt =>
      'Ustaw język nauki, aby zobaczyć tu materiały';

  @override
  String discoverNoPublicContentInLanguage(String language) {
    return 'Brak jeszcze publicznych materiałów w języku: $language';
  }

  @override
  String get discoverSetLanguageToDiscover =>
      'Ustaw język nauki, aby odkrywać materiały';

  @override
  String get mediaStartPractice => 'Zacznij ćwiczyć';

  @override
  String get mediaTranscript => 'Transkrypcja';

  @override
  String mediaTranscriptLineCount(int count) {
    return '(wiersze: $count)';
  }

  @override
  String get mediaShow => 'Pokaż';

  @override
  String get mediaHide => 'Ukryj';

  @override
  String get mediaNoTranscriptAvailable => 'Brak transkrypcji.';

  @override
  String get lessonSaveTooltip => 'Zapisz';

  @override
  String get lessonUnsaveTooltip => 'Usuń z zapisanych';

  @override
  String get mediaKindAudio => 'Audio';

  @override
  String get mediaKindVideo => 'Wideo';

  @override
  String get practiceNoCues => 'Brak fraz';

  @override
  String get practiceTranslating => 'Tłumaczenie…';

  @override
  String get practiceShowTranscript => 'Pokaż transkrypcję';

  @override
  String get practiceTranslate => 'Przetłumacz';

  @override
  String get practiceHideText => 'Ukryj tekst';

  @override
  String get practiceTextLabel => 'Tekst';

  @override
  String get practiceStop => 'Zatrzymaj';

  @override
  String get practicePlayAll => 'Shadowing';

  @override
  String get practiceCompare => 'Porównaj';

  @override
  String get practiceRecord => 'Nagraj';

  @override
  String get practiceStopRecording => 'Zatrzymaj';

  @override
  String get practiceRecords => 'Nagrania';

  @override
  String get practiceRecordsLocalOnlyFooter =>
      'Próby są przechowywane tylko na tym urządzeniu i nie są przesyłane.';

  @override
  String get practiceRecordsEmpty => 'Brak zapisanych prób dla tej frazy.';

  @override
  String get practiceRecordingProcessError =>
      'Podczas przetwarzania nagrania coś poszło nie tak.';

  @override
  String get practiceStartOver => 'Od początku';

  @override
  String get practiceTranscriptHidden => 'Transkrypcja ukryta';

  @override
  String get practiceListenCarefully => 'Słuchaj uważnie…';

  @override
  String get practiceTranslationUnavailableForCue =>
      'Tłumaczenie tej frazy jest teraz niedostępne.';

  @override
  String get practiceChooseTranslationLanguageTitle =>
      'Wybierz język tłumaczenia';

  @override
  String get practiceChooseTranslationLanguageDescription =>
      'Bantera przetłumaczy ćwiczenia ze słuchania na ten język i zapisze go w Twoim profilu na kolejne sesje.';

  @override
  String get practiceChangeTranslationLanguageTitle =>
      'Zmień język tłumaczenia';

  @override
  String get practiceChangeTranslationLanguageDescription =>
      'Wybierz język, na który Bantera ma tłumaczyć. Nowy wybór zostanie zapisany w Twoim profilu.';

  @override
  String get practiceConfirmTranslationLanguageTitle =>
      'Potwierdź język tłumaczenia';

  @override
  String get practiceConfirmTranslationLanguageBody =>
      'Bantera zapisze ten język w Twoim profilu i będzie go domyślnie używać do tłumaczeń w kolejnych ćwiczeniach ze słuchania.';

  @override
  String get practiceCouldNotSaveTranslationLanguage =>
      'Nie udało się zapisać języka tłumaczenia.';

  @override
  String get practiceNoTranslationLanguagesFound =>
      'Nie znaleziono języków tłumaczenia dla tej transkrypcji.';

  @override
  String get practicePlayAllTitle => 'Shadowing';

  @override
  String get practicePlayAllDescription =>
      'Przerwa między frazami podczas shadowingu:';

  @override
  String get practicePlayAllPauseZeroSeconds => '0 s';

  @override
  String get practicePlayAllPauseOneSecondLabel => '1 s';

  @override
  String get practicePlayAllPauseOneCuePlusOneSecond => '1 fraza + 1 s';

  @override
  String get practicePlayAllPauseOneCuePlusTwoSeconds => '1 fraza + 2 s';

  @override
  String get practicePlayAllTimesPerCueTitle => 'Powtórzenia każdej frazy';

  @override
  String get practicePlayAllTimesOnce => '1×';

  @override
  String get practicePlayAllTimesTwice => '2×';

  @override
  String get practicePlayAllTimesThrice => '3×';

  @override
  String get practiceSearchLanguagesHint => 'Szukaj języków';

  @override
  String get practiceTranslationInstalled => 'Zainstalowany';

  @override
  String get practiceTranslationDownload => 'Pobierz';

  @override
  String get practiceStartOverTitle => 'Zacząć od początku?';

  @override
  String get practiceStartOverBody => 'Wrócić do pierwszej frazy?';

  @override
  String get practiceNextFromLastTitle => 'Przejść do pierwszej frazy?';

  @override
  String get practiceNextFromLastBody =>
      'To ostatnia fraza. Wrócić do pierwszej?';

  @override
  String get practiceGoToFirstCue => 'Przejdź do pierwszej frazy';

  @override
  String get practiceVideoOpenError =>
      'Nie udało się otworzyć wybranego wideo do ćwiczeń.';

  @override
  String get practiceAudioLoading => 'Wczytywanie audio…';

  @override
  String practiceAudioLoadingPercent(int percent) {
    return 'Wczytywanie audio $percent%';
  }

  @override
  String get practiceAudioError =>
      'Nie udało się wczytać audio. Spróbuj ponownie.';

  @override
  String get compareRecordYourVersion => 'Nagraj swoją wersję';

  @override
  String compareTranscriptionLanguage(String locale) {
    return 'Język transkrypcji: $locale';
  }

  @override
  String get compareOpenIphoneSettings => 'Otwórz Ustawienia iPhone’a';

  @override
  String get comparePauseAttempt => 'Wstrzymaj próbę';

  @override
  String get comparePlayAttempt => 'Odtwórz próbę';

  @override
  String get compareYourTranscribedAttempt => 'Transkrypcja Twojej próby';

  @override
  String get compareHighlightHint =>
      'Wyróżnione są słowa, które Bantera rozpoznała inaczej.';

  @override
  String get compareUncertainHint =>
      'Słowa podkreślone kropkami zostały rozpoznane, ale Bantera nie miała pewności — sprawdź swoją wymowę.';

  @override
  String get compareTryAgain => 'Spróbuj ponownie';

  @override
  String get compareDone => 'Gotowe';

  @override
  String get compareStatusTranscribing =>
      'Transkrypcja Twojej próby na iPhonie…';

  @override
  String get compareStatusRecording =>
      'Nagrywanie… Stuknij ponownie, aby zatrzymać.';

  @override
  String get compareStatusSavedAttempt =>
      'Wyświetlana jest zapisana próba tej frazy. Możesz ją odtworzyć lub spróbować ponownie.';

  @override
  String get compareStatusReplayOrRetry =>
      'Możesz odtworzyć tę próbę lub powtórzyć frazę.';

  @override
  String get compareStatusTapToRecord =>
      'Stuknij, aby nagrać swoją wersję tej frazy.';

  @override
  String get compareCouldNotStartRecording =>
      'Bantera nie może teraz rozpocząć nagrywania.';

  @override
  String get compareCouldNotAccessRecording =>
      'Bantera nie ma dostępu do nagrania.';

  @override
  String get compareNoTranscriptGenerated =>
      'Nie udało się utworzyć transkrypcji tej próby. Spróbuj ponownie bliżej mikrofonu.';

  @override
  String get compareRecentAttempts => 'Ostatnie próby';

  @override
  String get compareAttemptsFooterNote =>
      'Bantera przechowuje Twoje próby na tym iPhonie, dzięki czemu możesz śledzić postępy w tej samej frazie.';

  @override
  String compareMatchedCount(int count) {
    return 'Zgodne: $count';
  }

  @override
  String compareDifferentCount(int count) {
    return 'Inne: $count';
  }

  @override
  String compareMissingCount(int count) {
    return 'Brakujące: $count';
  }

  @override
  String compareUncertainCount(int count) {
    return 'Niepewne: $count';
  }

  @override
  String get compareMicrophoneDeniedPermanent =>
      'Dostęp aplikacji Bantera do mikrofonu jest wyłączony. Otwórz Ustawienia iPhone’a > Bantera > Mikrofon i włącz go, aby nagrać swoją wersję.';

  @override
  String get compareMicrophoneDeniedRestricted =>
      'Ten iPhone ogranicza obecnie dostęp aplikacji Bantera do mikrofonu. Aby go włączyć, sprawdź Czas przed ekranem, zarządzanie urządzeniem lub ustawienia systemowe.';

  @override
  String get compareMicrophoneDeniedDefault =>
      'Aby nagrać swoją wersję, potrzebny jest dostęp do mikrofonu. Jeśli prośba została wcześniej odrzucona, otwórz Ustawienia iPhone’a > Bantera > Mikrofon i włącz dostęp.';

  @override
  String get compareSpeechRecognitionDeniedPermanent =>
      'Dostęp aplikacji Bantera do rozpoznawania mowy jest wyłączony. Otwórz Ustawienia iPhone’a > Bantera > Rozpoznawanie mowy i włącz go, aby porównać nagranie.';

  @override
  String get compareSpeechRecognitionDeniedRestricted =>
      'Ten iPhone ogranicza obecnie rozpoznawanie mowy w aplikacji Bantera. Aby je włączyć, sprawdź Czas przed ekranem, zarządzanie urządzeniem lub ustawienia systemowe.';

  @override
  String get compareSpeechRecognitionUnavailable =>
      'Rozpoznawanie mowy jest teraz niedostępne na tym iPhonie.';

  @override
  String get compareSpeechRecognitionUnsupportedLocale =>
      'Rozpoznawanie mowy nie jest dostępne na tym iPhonie dla tego języka ćwiczeń.';

  @override
  String get comparePlayAttemptTooltip => 'Odtwórz próbę';

  @override
  String get comparePauseAttemptTooltip => 'Wstrzymaj próbę';

  @override
  String get createWhatToday => 'Co chcesz dziś robić?';

  @override
  String get createPracticeVideo => 'Ćwicz z wideo';

  @override
  String get createYourMedia => 'Twoje materiały';

  @override
  String get createTryAgain => 'Spróbuj ponownie';

  @override
  String get createUploadedVideosEmptyHint =>
      'Tu pojawią się Twoje przesłane filmy — otwieraj je ponownie i ćwicz fraza po frazie.';

  @override
  String get createUploadingTips => 'Wskazówki dotyczące przesyłania';

  @override
  String get createUploadingTipsBody =>
      'Najlepiej sprawdza się audio krótsze niż 3 minuty. Czytelne napisy tworzą się automatycznie!';

  @override
  String get createOnThisIphone => 'Na tym iPhonie';

  @override
  String get createLocalVideosEmptyHint =>
      'Filmy, z którymi ćwiczysz lokalnie, zostaną zapisane na tym iPhonie, więc możesz je później otworzyć bez ponownej transkrypcji.';

  @override
  String get createOnDeviceBadge => 'Na urządzeniu';

  @override
  String get createSignInToLoadVideos =>
      'Zaloguj się ponownie, aby wczytać przesłane filmy.';

  @override
  String createVideoMetaCues(int count) {
    return 'Frazy: $count';
  }

  @override
  String get createPublicBadge => 'Publiczne';

  @override
  String get createPrivateBadge => 'Prywatne';

  @override
  String get createAiBadge => 'AI';

  @override
  String get createDeleteSavedVideoTitle => 'Usunąć zapisane wideo?';

  @override
  String createDeleteSavedVideoBody(String title) {
    return 'Bantera usunie „$title” z tego iPhone’a wraz z zapisanymi frazami transkrypcji.';
  }

  @override
  String get createDeleteMediaTitle => 'Usunąć materiał?';

  @override
  String createDeleteMediaBody(String title) {
    return 'Materiał „$title” zostanie trwale usunięty wraz z transkrypcją. Tej operacji nie można cofnąć.';
  }

  @override
  String get removeFromListTitle => 'Usunąć z listy?';

  @override
  String get removeFromListBody =>
      'Ten element zostanie usunięty z listy. Tej operacji nie można cofnąć.';

  @override
  String get editProfileChangeImage => 'Zmień zdjęcie profilowe';

  @override
  String get editProfileUploading => 'Przesyłanie…';

  @override
  String get editProfileNameLabel => 'Imię';

  @override
  String get editProfileNameHint => 'Jak Bantera ma wyświetlać Twoje imię?';

  @override
  String get editProfileSaveNameButton => 'Zapisz imię';

  @override
  String get editProfileSaving => 'Zapisywanie…';

  @override
  String get editProfileLanguagesSection => 'Języki';

  @override
  String get editProfileMyNativeLanguage => 'Mój język ojczysty';

  @override
  String get editProfileMyNativeLanguageSubtitle =>
      'Twój język ojczysty lub pierwszy';

  @override
  String get editProfileLearningLanguage => 'Język nauki';

  @override
  String get editProfileLearningLanguageSubtitle =>
      'Język, który chcesz ćwiczyć';

  @override
  String get editProfileImageUpdated => 'Zaktualizowano zdjęcie profilowe.';

  @override
  String get editProfileNameUpdated => 'Zaktualizowano imię.';

  @override
  String get editProfileEnterName => 'Wpisz imię.';

  @override
  String get editProfileNameMaxLength => 'Użyj maksymalnie 80 znaków.';

  @override
  String get editProfileCouldNotLoadLanguages =>
      'Nie udało się wczytać listy języków.';

  @override
  String get languagePickerNone => 'Brak';

  @override
  String get languagePickerClearSelection => 'Wyczyść wybór';

  @override
  String get languagePickerNoMatchingLanguages => 'Nie znaleziono języków.';

  @override
  String get languagePickerMoreComingSoon => 'Więcej języków wkrótce';

  @override
  String get editProfileNativeLanguageCleared => 'Usunięto język ojczysty.';

  @override
  String get editProfileLearningLanguageCleared => 'Usunięto język nauki.';

  @override
  String editProfileNativeLanguageSetTo(String language) {
    return 'Ustawiono język ojczysty: $language.';
  }

  @override
  String editProfileLearningLanguageSetTo(String language) {
    return 'Ustawiono język nauki: $language.';
  }

  @override
  String get profileLanguageSettings => 'Ustawienia języka';

  @override
  String get profileLearningLabel => 'Uczę się';

  @override
  String get profileNotSet => 'Nie ustawiono';

  @override
  String get uploadedDetailYourAudio => 'Twoje audio';

  @override
  String get uploadedDetailYourVideo => 'Twoje wideo';

  @override
  String get uploadedDetailDeleteAudioTitle => 'Usunąć audio?';

  @override
  String get uploadedDetailDeleteAudioBody =>
      'Audio i jego transkrypcja zostaną trwale usunięte. Tej operacji nie można cofnąć.';

  @override
  String get uploadedDetailDeleteVideoTitle => 'Usunąć wideo?';

  @override
  String get uploadedDetailDeleteVideoBody =>
      'Wideo i jego transkrypcja zostaną trwale usunięte. Tej operacji nie można cofnąć.';

  @override
  String get uploadedDetailAiGenerated => 'Wygenerowane przez AI';

  @override
  String get uploadedDetailFileSize => 'Rozmiar pliku';

  @override
  String get uploadedDetailResolution => 'Rozdzielczość';

  @override
  String get uploadedDetailResolutionUnknown => 'Nieznana';

  @override
  String get uploadedDetailTranscribing => 'Transkrypcja…';

  @override
  String get uploadedDetailNoTranscriptCuesYet =>
      'Brak jeszcze fraz transkrypcji.';

  @override
  String uploadedDetailMediaDescription(int count) {
    return 'Twój przesłany klip do ćwiczeń. Liczba fraz w transkrypcji: $count.';
  }

  @override
  String get uploadedDetailTranscriptionFailedFallback =>
      'Transkrypcja nie powiodła się. Używane są szacunkowe frazy.';

  @override
  String get uploadedDetailTranscriptionNoCues =>
      'Transkrypcja nie zwróciła żadnych fraz.';

  @override
  String get uploadedDetailTranscriptionSourceYourUpload => 'Twój plik';

  @override
  String get aiGenLeaveTitle => 'Opuścić tę stronę?';

  @override
  String get aiGenLeaveBody =>
      'Audio wciąż się generuje. Jeśli teraz wyjdziesz, proces zostanie anulowany.';

  @override
  String get aiGenStay => 'Zostań';

  @override
  String get aiGenLeave => 'Wyjdź';

  @override
  String get aiGenLoadingTitle => 'Tworzymy Twoje audio…';

  @override
  String get aiGenLoadingSubtitle =>
      'Może to potrwać do minuty.\nNie opuszczaj tej strony podczas generowania.';

  @override
  String get aiGenStepPreparingSpeechModel =>
      'Przygotowywanie modelu mowy na urządzeniu';

  @override
  String get aiGenStepWritingDialogue => 'Pisanie dialogu';

  @override
  String get aiGenStepGeneratingAudio => 'Generowanie audio';

  @override
  String get aiGenStepAligningAudio => 'Synchronizowanie audio';

  @override
  String get aiGenStepTranscribing => 'Transkrypcja';

  @override
  String get aiGenStepCorrectingTranscript => 'Poprawianie transkrypcji';

  @override
  String get aiGenLanguageSection => 'Język';

  @override
  String get aiGenSetLearningLanguagePrompt =>
      'Ustaw język nauki, aby włączyć generowanie';

  @override
  String get aiGenLoadingLanguage => 'Wczytywanie języka…';

  @override
  String aiGenLanguageUnsupported(String language) {
    return 'Język „$language” nie jest obsługiwany przy generowaniu.';
  }

  @override
  String get aiGenScenarioSection => 'Scenariusz';

  @override
  String get aiGenScenarioOptionalHint =>
      'Opcjonalnie — nic nie zaznaczaj, aby wylosować scenariusz.';

  @override
  String get aiGenCustomScenarioHint => 'Opisz swój scenariusz…';

  @override
  String get aiGenDurationSection => 'Długość';

  @override
  String aiGenDurationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get aiGenGenerateButton => 'Generuj';

  @override
  String get aiGenOwnershipNotice =>
      'Wygenerowane tu audio staje się treścią społeczności Bantera — jest publicznie udostępniane jako materiał do ćwiczeń dla wszystkich uczących się.';

  @override
  String get aiGenOwnershipCheckbox =>
      'Udostępnij to audio jako treść społeczności Bantera';

  @override
  String get aiGenOwnershipConfirmTitle =>
      'Udostępnić jako treść społeczności?';

  @override
  String get aiGenOwnershipConfirmCancel => 'Anuluj';

  @override
  String get aiGenOwnershipConfirmGenerate => 'Generuj';

  @override
  String get aiGenFooterNotice =>
      'AI napisze dialog dla dwóch osób i zamieni go w audio. Wynik zostanie zapisany jako publiczne audio do ćwiczeń.';

  @override
  String get aiScenarioCoffeeShop => 'Kawiarnia';

  @override
  String get aiScenarioLatestNews => 'Najnowsze wiadomości';

  @override
  String get aiScenarioAirportReunion => 'Spotkanie na lotnisku';

  @override
  String get aiScenarioGroceryStore => 'Sklep spożywczy';

  @override
  String get aiScenarioDoctorVisit => 'Wizyta u lekarza';

  @override
  String get aiScenarioJobInterview => 'Rozmowa o pracę';

  @override
  String get aiScenarioNewNeighbour => 'Nowy sąsiad';

  @override
  String get aiScenarioTechSupport => 'Pomoc techniczna';

  @override
  String get aiScenarioBirthdaySurprise => 'Urodzinowa niespodzianka';

  @override
  String get aiScenarioGymTips => 'Porady na siłowni';

  @override
  String get aiScenarioWeatherSmalltalk => 'Rozmowa o pogodzie';

  @override
  String get aiScenarioRestaurantOrder => 'Zamówienie w restauracji';

  @override
  String get aiScenarioBookRecommendation => 'Polecenie książki';

  @override
  String get aiScenarioBusDelay => 'Opóźniony autobus';

  @override
  String get aiScenarioMovieDebate => 'Dyskusja o filmie';

  @override
  String get aiScenarioCustom => 'Własny…';

  @override
  String get errorNetworkUnreachable =>
      'Nie można połączyć się z Bantera. Sprawdź połączenie z internetem.';

  @override
  String get errorNetworkCellularBlocked =>
      'Dane komórkowe są wyłączone dla aplikacji Bantera. W Ustawieniach otwórz Bantera i włącz Dane komórkowe albo połącz się z Wi-Fi.';

  @override
  String get errorTlsConnection =>
      'Nie udało się nawiązać bezpiecznego połączenia.';

  @override
  String get settingsRateAppPrompt =>
      'Podoba Ci się Bantera? Szybka ocena w App Store wiele dla nas znaczy.';

  @override
  String get settingsRateAppButton => 'Oceń w App Store';

  @override
  String get settingsSharePrompt =>
      'Znasz kogoś, kto uczy się języka? Poleć mu aplikację Bantera.';

  @override
  String get settingsShareButton => 'Poleć Bantera';

  @override
  String get settingsContactButton => 'Kontakt';

  @override
  String get localVideoDescription =>
      'Wybierz wideo ze Zdjęć i język, w którym mówią nagrane osoby, a iPhone przetranskrybuje je w tle, zanim zaczniesz ćwiczyć fraza po frazie.';

  @override
  String get localVideoStep1Title => '1. Wybierz wideo';

  @override
  String get localVideoChooseFromPhotos => 'Wybierz ze Zdjęć';

  @override
  String get localVideoChooseDifferent => 'Wybierz inne wideo';

  @override
  String get localVideoSelectedFileLabel => 'Wybrany plik';

  @override
  String get localVideoSizeLabel => 'Rozmiar';

  @override
  String get localVideoDurationLabel => 'Czas trwania';

  @override
  String get localVideoLongVideoWarning =>
      'To wideo trwa ponad 3 minuty, więc przygotowanie transkrypcji i tłumaczenia może potrwać dłużej.';

  @override
  String get localVideoStep2Title => '2. Język transkrypcji';

  @override
  String get localVideoChooseLanguagePlaceholder => 'Wybierz język nagrania';

  @override
  String get localVideoLanguageHint =>
      'Bantera zapamiętuje ostatnio wybrany język, a po rozpoczęciu ćwiczeń domyślnie ukrywa transkrypcję.';

  @override
  String get localVideoStep3Title => '3. Ćwicz';

  @override
  String get localVideoPreparing => 'Przygotowywanie...';

  @override
  String get localVideoPracticeHint =>
      'Bantera najpierw transkrybuje wideo na urządzeniu, a potem otwiera ćwiczenie ze słuchania fraza po frazie — bez przesyłania czegokolwiek.';

  @override
  String get localVideoStatusLongVideo =>
      'To dłuższe wideo, więc transkrypcja i przygotowanie mogą potrwać dłużej.';

  @override
  String get localVideoStatusTranscribing =>
      'Transkrypcja na urządzeniu i przygotowywanie fraz do ćwiczeń...';

  @override
  String get localVideoStatusSaving =>
      'Zapisywanie wideo w bibliotece ćwiczeń na urządzeniu...';

  @override
  String get localVideoStatusTranslationLong =>
      'Transkrypcja zakończona. Bantera przygotowuje też tłumaczenie na zapisany język, więc przy dłuższym wideo może to chwilę potrwać.';

  @override
  String get localVideoStatusTranslation =>
      'Transkrypcja zakończona. Przygotowywanie tłumaczenia na zapisany język...';

  @override
  String get localVideoPickerTitle => 'Wybierz język audio';

  @override
  String get savedCuesTitle => 'Zapisane frazy';

  @override
  String get savedCuesEmpty =>
      'Nie masz jeszcze zapisanych fraz. Podczas ćwiczeń stuknij ikonę zakładki, aby zapisać frazę.';

  @override
  String get savedCuesDeleteTooltip => 'Usuń zapisaną frazę';

  @override
  String get savedCuesDeleteConfirmTitle => 'Usunąć tę frazę?';

  @override
  String get savedCuesDeleteConfirmBody =>
      'Ta fraza zostanie usunięta z listy zapisanych.';

  @override
  String get savedCuesDeleteAllTooltip => 'Usuń wszystkie zapisane frazy';

  @override
  String get savedCuesDeleteAllConfirmTitle =>
      'Usunąć wszystkie zapisane frazy?';

  @override
  String get savedCuesDeleteAllConfirmBody =>
      'Wszystkie zapisane frazy zostaną trwale usunięte.';

  @override
  String get updateAlertTitle => 'Dostępna aktualizacja';

  @override
  String get updateAlertMessage =>
      'Dostępna jest nowa wersja aplikacji Bantera. Zaktualizuj ją teraz, aby korzystać z najnowszych funkcji i ulepszeń.';

  @override
  String get updateCurrentVersionLabel => 'Obecna wersja';

  @override
  String get updateAppStoreVersionLabel => 'Wersja w App Store';

  @override
  String get updateAlertUpdate => 'Aktualizuj';

  @override
  String get updateAlertLater => 'Później';

  @override
  String get checkForUpdateButton => 'Sprawdź aktualizacje';

  @override
  String get upToDateAlertTitle => 'Wszystko aktualne';

  @override
  String upToDateAlertMessage(Object version) {
    return 'Bantera $version to najnowsza wersja.';
  }

  @override
  String get sectionSupport => 'Pomoc';

  @override
  String get permissionActionAllow => 'Zezwól';
}
