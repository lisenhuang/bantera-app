// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'Bantera';

  @override
  String get appTagline => 'Cümle cümle dil pratiği.';

  @override
  String get authContinueWithApple => 'Apple ile devam et';

  @override
  String get authContinueWithGoogle => 'Google ile devam et';

  @override
  String get authAppleUnavailable =>
      'Apple ile giriş bu cihazda kullanılamıyor.';

  @override
  String get authOrSignInEmail => 'veya e-postayla giriş yap';

  @override
  String get authEmail => 'E-posta';

  @override
  String get authPassword => 'Parola';

  @override
  String get authSigningIn => 'Giriş yapılıyor...';

  @override
  String get authSignIn => 'Giriş Yap';

  @override
  String get authSignInWithEmail => 'E-postayla giriş yap';

  @override
  String get validationEnterEmail => 'E-posta adresini gir.';

  @override
  String get validationValidEmail => 'Geçerli bir e-posta adresi gir.';

  @override
  String get validationEnterPassword => 'Parolanı gir.';

  @override
  String get onboardingTitle => 'Profilini oluştur';

  @override
  String get onboardingSubtitle =>
      'Bu bilgiler, Bantera\'nın pratik ve sohbeti sana göre uyarlamasına yardımcı olur.';

  @override
  String get onboardingNameTitle => 'Sana nasıl hitap edilsin?';

  @override
  String get onboardingNameSubtitle =>
      'Apple paylaştıysa bunu hesabından doldurduk. İstersen şimdi değiştirebilirsin.';

  @override
  String get onboardingClearName => 'Adı temizle';

  @override
  String get onboardingNativeLanguageTitle => 'Ana dilin ne?';

  @override
  String get onboardingNativeLanguageSubtitle =>
      'Bantera bunu çeviri ve dil grupları için kullanır.';

  @override
  String get onboardingLearningLanguageTitle => 'Hangi dili öğreniyorsun?';

  @override
  String get onboardingLearningLanguageSubtitle =>
      'Pratik içerikleri ve öğrenme grupları buna göre belirlenir.';

  @override
  String get onboardingAvatarTitle => 'Profil fotoğrafı ekle';

  @override
  String get onboardingAvatarSubtitle =>
      'Bir fotoğraf seç ya da devam et, Bantera senin için bir tane oluştursun.';

  @override
  String get onboardingAvatarGenderTitle => 'Profil görselini oluştur';

  @override
  String get onboardingAvatarGenderBody =>
      'Bantera\'nın profil görselini nasıl oluşturacağını seç. Bu seçimi saklamıyoruz; yalnızca bu görsel için kullanılır.';

  @override
  String get onboardingAvatarGenderMale => 'Erkek';

  @override
  String get onboardingAvatarGenderFemale => 'Kadın';

  @override
  String get onboardingChoosePhoto => 'Fotoğraf Seç';

  @override
  String get onboardingChangePhoto => 'Fotoğrafı Değiştir';

  @override
  String get onboardingUseGeneratedAvatar =>
      'Bunun yerine oluşturulan avatarı kullan';

  @override
  String get onboardingUseCurrentPhoto => 'Mevcut fotoğrafı kullan';

  @override
  String get onboardingChooseLanguage => 'Dil seç';

  @override
  String get onboardingBack => 'Geri';

  @override
  String get onboardingFinish => 'Bitir';

  @override
  String get onboardingLoadingProfile => 'Profil yükleniyor...';

  @override
  String get onboardingSavingProfile => 'Profil kaydediliyor...';

  @override
  String get onboardingLoadFailed =>
      'Bir şeyler ters gitti. Lütfen tekrar dene.';

  @override
  String get onboardingSearchHint => 'Dil ara…';

  @override
  String get onboardingRetry => 'Tekrar Dene';

  @override
  String get onboardingNoMatching => 'Eşleşen dil yok.';

  @override
  String get onboardingFailedSave => 'Kaydedilemedi.';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get sectionAppearance => 'Görünüm';

  @override
  String get sectionAccount => 'Hesap';

  @override
  String get sectionRateAndShare => 'Puanla ve Paylaş';

  @override
  String get sectionLanguage => 'Arayüz Dili';

  @override
  String get sectionPermissions => 'İzinler';

  @override
  String get sectionNotifications => 'Bildirimler';

  @override
  String get languageSectionSubtitle =>
      'Uygulamanın arayüz dilini seç. Sistem seçeneği cihaz ayarlarını izler.';

  @override
  String get themeLabel => 'Tema';

  @override
  String get themeLight => 'Açık';

  @override
  String get themeDark => 'Koyu';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get languageEnglish => 'İngilizce';

  @override
  String get languageChineseSimplified => 'Çince (Basitleştirilmiş)';

  @override
  String get languageKorean => 'Korece';

  @override
  String get languageJapanese => 'Japonca';

  @override
  String get signedOutLabel => 'Çıkış yapıldı';

  @override
  String get noActiveSession => 'Etkin Bantera oturumu yok';

  @override
  String signedInWith(String provider) {
    return '$provider ile giriş yapıldı';
  }

  @override
  String get editProfile => 'Profili Düzenle';

  @override
  String get more => 'Diğer';

  @override
  String get appPermissionsTitle => 'Uygulama İzinleri';

  @override
  String get appPermissionsSubtitle =>
      'Bantera\'nın bu cihazda kullandığı erişimleri gözden geçir.';

  @override
  String get permissionsIntro =>
      'Bantera bu cihaz ayarlarını kayıt, konuşma karşılaştırma ve ağ erişimi için kullanır.';

  @override
  String get permissionsOpenSettings => 'iPhone Ayarlarını Aç';

  @override
  String get permissionsRefresh => 'Yenile';

  @override
  String get permissionMicrophoneTitle => 'Mikrofon';

  @override
  String get permissionMicrophoneDescription =>
      'Pratik denemelerini ve sesli mesajları kaydet.';

  @override
  String get permissionSpeechTitle => 'Konuşma Tanıma';

  @override
  String get permissionSpeechDescription =>
      'Pratik kayıtlarını ve sesli mesajları yazıya dök.';

  @override
  String get permissionMobileDataTitle => 'Mobil Veri';

  @override
  String get permissionMobileDataDescription =>
      'Bu iPhone Wi-Fi\'ye bağlı değilken Bantera\'yı kullan.';

  @override
  String get permissionStatusAllowed => 'İzin Verildi';

  @override
  String get permissionStatusLimited => 'Sınırlı';

  @override
  String get permissionStatusNotAllowed => 'İzin Verilmedi';

  @override
  String get permissionStatusUnknown => 'Bilinmiyor';

  @override
  String get signOut => 'Çıkış Yap';

  @override
  String get signOutDialogTitle => 'Çıkış yapılsın mı?';

  @override
  String get signOutDialogBody =>
      'Hesabını kullanmak için tekrar giriş yapman gerekecek.';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get closeLabel => 'Kapat';

  @override
  String get navDiscover => 'Keşfet';

  @override
  String get navCreate => 'Oluştur';

  @override
  String get navProfile => 'Profil';

  @override
  String get chatsTitle => 'Sohbetler';

  @override
  String get chatNoChatsYet => 'Henüz sohbet yok.';

  @override
  String get chatOnlineSection => 'Çevrimiçi';

  @override
  String get chatDirectMessagesSection => 'DM';

  @override
  String chatAudioDuration(String duration) {
    return 'Ses $duration';
  }

  @override
  String get chatEnableNotifications => 'Bildirimleri aç';

  @override
  String get chatMuteNotifications => 'Bildirimleri sessize al';

  @override
  String get chatBlockUser => 'Kullanıcıyı engelle';

  @override
  String get chatDeleteDm => 'Özel sohbeti sil';

  @override
  String get chatCall => 'Ara';

  @override
  String get chatStartAudioCall => 'Sesli Arama';

  @override
  String get chatStartVideoCall => 'Görüntülü Arama';

  @override
  String get chatAudioCalling => 'Sesli arama yapılıyor...';

  @override
  String get chatVideoCalling => 'Görüntülü arama yapılıyor...';

  @override
  String get chatAudioIncoming => 'Gelen sesli arama';

  @override
  String get chatVideoIncoming => 'Gelen görüntülü arama';

  @override
  String get chatCallConnecting => 'Bağlanıyor...';

  @override
  String get chatCallAccept => 'Kabul Et';

  @override
  String get chatCallDecline => 'Reddet';

  @override
  String get chatCallEnd => 'Bitir';

  @override
  String get chatCallMute => 'Sessiz';

  @override
  String get chatCallUnmute => 'Sesi Aç';

  @override
  String get chatCallSpeaker => 'Hoparlör';

  @override
  String get chatCallCamera => 'Kamera';

  @override
  String get chatCallSwitchCamera => 'Çevir';

  @override
  String get chatCallIssueTitle => 'Arama sorunu';

  @override
  String get chatCallMicrophoneDenied =>
      'Arama başlatmak için Bantera\'nın mikrofon erişimine ihtiyacı var.';

  @override
  String get chatCallMicrophoneSettings =>
      'Bantera için mikrofon erişimi kapalı. Aramalar için Ayarlar\'dan aç.';

  @override
  String get chatCallCameraDenied =>
      'Görüntülü arama başlatmak için Bantera\'nın kamera erişimine ihtiyacı var.';

  @override
  String get chatCallCameraSettings =>
      'Bantera için kamera erişimi kapalı. Görüntülü aramalar için Ayarlar\'dan aç.';

  @override
  String get chatCallBusy => 'Bu kullanıcı şu anda başka bir aramada.';

  @override
  String get chatCallUnavailable =>
      'Bu kullanıcı şu anda arama için uygun değil.';

  @override
  String get chatCallNetworkRestricted =>
      'Bu ağ aramayı bağlayamıyor. Wi-Fi\'yi veya başka bir ağı dene.';

  @override
  String get chatCallFailed => 'Arama başlatılamadı. Lütfen tekrar dene.';

  @override
  String get chatGroupReady => 'Bu grup sesli mesajlar için hazır.';

  @override
  String get chatHoldToStartDm =>
      'Kaydetmek ve özel sohbeti başlatmak için basılı tut.';

  @override
  String get chatNoGroupAudio => 'Henüz grup sesi yok.';

  @override
  String get chatNoDmAudio => 'Bu özel sohbette henüz ses yok.';

  @override
  String get chatSendingAudio => 'Ses gönderiliyor...';

  @override
  String get chatRecordingReleaseToSend =>
      'Kaydediliyor... göndermek için bırak';

  @override
  String get chatHoldToRecordAudio => 'Ses kaydetmek için basılı tut';

  @override
  String get chatRecordingStatus => 'Kaydediliyor...';

  @override
  String get chatGroupLabel => 'Grup';

  @override
  String get chatNotificationsEnabledForDm =>
      'Bu özel sohbet için bildirimler açıldı.';

  @override
  String get chatNotificationsMutedForDm =>
      'Bu özel sohbet için bildirimler sessize alındı.';

  @override
  String chatBlockUserTitle(String user) {
    return '$user engellensin mi?';
  }

  @override
  String get chatBlockUserBody =>
      'Engeli kaldırana kadar birbirinizi özel mesajlarda ve ortak grup mesajlarında görmeyeceksiniz.';

  @override
  String chatBlockUserSuccess(String user) {
    return '$user engellendi.';
  }

  @override
  String get chatBlockUserFailed =>
      'Bu kullanıcı engellenemedi. Lütfen tekrar dene.';

  @override
  String get chatDeleteMessage => 'Mesajı sil';

  @override
  String get chatDeleteMessageTitle => 'Bu mesaj silinsin mi?';

  @override
  String get chatDeleteMessageBody =>
      'Bu mesaj, sohbetteki herkes için kaldırılacak. Bu işlem geri alınamaz.';

  @override
  String get chatDeleteMessageSuccess => 'Mesaj silindi';

  @override
  String get chatDeleteMessageFailed => 'Mesaj silinemedi. Lütfen tekrar dene.';

  @override
  String get chatDeleteDmTitle => 'Bu özel sohbet silinsin mi?';

  @override
  String get chatDeleteDmBody =>
      'Bu işlem sohbeti yalnızca listenden kaldırır. Yeni bir mesaj gelirse sohbet geri gelebilir.';

  @override
  String get chatMicrophoneRequiredTitle => 'Mikrofon gerekli';

  @override
  String get chatMicrophoneRequiredSettings =>
      'Sohbet sesi kaydetmek için Bantera\'nın mikrofon erişimine ihtiyacı var. Ayarlar\'dan aç.';

  @override
  String get chatMicrophoneRequiredBody =>
      'Sohbet sesi kaydetmek için Bantera\'nın mikrofon erişimine ihtiyacı var.';

  @override
  String get chatGroupNotReady => 'Bu grup henüz hazır değil.';

  @override
  String get chatMessageAction => 'Mesaj';

  @override
  String get chatRetranscribe => 'Yeniden Yazıya Dök';

  @override
  String get chatTranscribe => 'Yazıya Dök';

  @override
  String get chatTranscribingOnDevice => 'Bu iPhone\'da yazıya dökülüyor...';

  @override
  String get chatTranscriptionFailed => 'Yazıya dökme başarısız. Tekrar dene.';

  @override
  String get chatTranslate => 'Çevir';

  @override
  String get chatRetranslate => 'Yeniden Çevir';

  @override
  String get chatTranslating => 'Bu iPhone\'da çevriliyor...';

  @override
  String get chatTranslationFailed => 'Çeviri başarısız. Lütfen tekrar dene.';

  @override
  String get chatGroupSettingsTitle => 'Grup ayarları';

  @override
  String get chatNotifications => 'Bildirimler';

  @override
  String get chatBlockedUsersMenu => 'Engellenen Kullanıcılar';

  @override
  String get chatBlockedUsersTitle => 'Engellenen Kullanıcılar';

  @override
  String get chatBlockedPeople => 'Engellenen kişiler';

  @override
  String get chatNoBlockedUsers => 'Henüz engellenen kullanıcı yok.';

  @override
  String get chatNoBlockedPeople => 'Henüz engellenen kişi yok.';

  @override
  String get chatUnblock => 'Engeli Kaldır';

  @override
  String chatUnblockUserTitle(String user) {
    return '$user için engel kaldırılsın mı?';
  }

  @override
  String get chatUnblockUserBody =>
      'Birbirinizi özel mesajlarda ve ortak grup mesajlarında yeniden görebilirsiniz.';

  @override
  String get chatUnblockFailed => 'Engel kaldırılamadı. Lütfen tekrar dene.';

  @override
  String get chatNotificationsTitle => 'Sohbet bildirimleri';

  @override
  String get chatNotificationsSubtitle =>
      'Tüm cihazlarında geçerli tek bir hesap ayarı.';

  @override
  String get chatNotificationsDisabledTitle => 'Bildirimler kapalı';

  @override
  String get chatNotificationsDisabledSettings =>
      'Bantera sohbet uyarılarını almak için Ayarlar\'dan bildirimleri aç.';

  @override
  String get chatNotificationsDisabledBody =>
      'Sohbet uyarılarını açabilmek için Bantera\'nın bildirim iznine ihtiyacı var.';

  @override
  String get chatNotificationUpdateFailed =>
      'Sohbet bildirimleri güncellenemedi. Lütfen tekrar dene.';

  @override
  String get savedTitle => 'Kaydedilen Medya';

  @override
  String get generateWithAiTitle => 'YZ ile Oluştur';

  @override
  String get practiceLocalVideoTitle => 'Yerel Video ile Pratik';

  @override
  String get uploadVideoTitle => 'Video Yükle';

  @override
  String get lessonDetailsTitle => 'Ders Ayrıntıları';

  @override
  String get accountMoreTitle => 'Diğer';

  @override
  String get deleteAccount => 'Hesabı sil';

  @override
  String get deleteAccountSubtitle =>
      'Hesabını ve sunucudaki verilerini kalıcı olarak kaldır';

  @override
  String get confirmDeletionTitle => 'Silmeyi onayla';

  @override
  String get deleteAccountImmediateBody =>
      'Hesabın hemen silinecek. Bantera\'yı tekrar kullanmak için yeni bir hesap oluşturman gerekecek.';

  @override
  String get deleteAccountConfirm => 'Hesabı sil';

  @override
  String get couldNotDeleteAccount => 'Hesap silinemedi. Lütfen tekrar dene.';

  @override
  String get deleteAccountQuestionTitle => 'Hesap silinsin mi?';

  @override
  String get deleteAccountQuestionBody =>
      'Tüm kişisel bilgilerin ve verilerin sunucularımızdan kalıcı olarak kaldırılacak ve geri getirilemeyecek.';

  @override
  String get typeDeleteLabel => 'Devam etmek için \"DELETE\" yaz';

  @override
  String get continueLabel => 'Devam Et';

  @override
  String get confirmLabel => 'Onayla';

  @override
  String get deleteLabel => 'Sil';

  @override
  String get removeFromListLabel => 'Listeden kaldır';

  @override
  String get startLabel => 'Başla';

  @override
  String get doneLabel => 'Bitti';

  @override
  String get discoverSearchHint => 'Başlık veya transkriptte ara…';

  @override
  String get discoverNoMoreResults => 'Başka sonuç yok';

  @override
  String get discoverSetLearningLanguagePrompt =>
      'Burada içerik görmek için öğrendiğin dili ayarla';

  @override
  String discoverNoPublicContentInLanguage(String language) {
    return '$language dilinde henüz herkese açık içerik yok';
  }

  @override
  String get discoverSetLanguageToDiscover =>
      'İçerik keşfetmek için öğrendiğin dili ayarla';

  @override
  String get mediaStartPractice => 'Pratiğe Başla';

  @override
  String get mediaTranscript => 'Transkript';

  @override
  String mediaTranscriptLineCount(int count) {
    return '($count satır)';
  }

  @override
  String get mediaShow => 'Göster';

  @override
  String get mediaHide => 'Gizle';

  @override
  String get mediaNoTranscriptAvailable => 'Transkript yok.';

  @override
  String get lessonSaveTooltip => 'Kaydet';

  @override
  String get lessonUnsaveTooltip => 'Kaydedilenlerden çıkar';

  @override
  String get mediaKindAudio => 'Ses';

  @override
  String get mediaKindVideo => 'Video';

  @override
  String get practiceNoCues => 'Cümle yok';

  @override
  String get practiceTranslating => 'Çevriliyor…';

  @override
  String get practiceShowTranscript => 'Transkripti Göster';

  @override
  String get practiceTranslate => 'Çevir';

  @override
  String get practiceHideText => 'Metni Gizle';

  @override
  String get practiceTextLabel => 'Metin';

  @override
  String get practiceStop => 'Durdur';

  @override
  String get practicePlayAll => 'Gölgeleme';

  @override
  String get practiceCompare => 'Karşılaştır';

  @override
  String get practiceRecord => 'Kaydet';

  @override
  String get practiceStopRecording => 'Durdur';

  @override
  String get practiceRecords => 'Kayıtlar';

  @override
  String get practiceRecordsLocalOnlyFooter =>
      'Denemeler yalnızca bu cihazda saklanır ve yüklenmez.';

  @override
  String get practiceRecordsEmpty => 'Bu cümle için henüz kayıtlı deneme yok.';

  @override
  String get practiceRecordingProcessError =>
      'Kaydın işlenirken bir sorun oluştu.';

  @override
  String get practiceStartOver => 'Baştan Başla';

  @override
  String get practiceTranscriptHidden => 'Transkript gizli';

  @override
  String get practiceListenCarefully => 'Dikkatlice dinle…';

  @override
  String get practiceTranslationUnavailableForCue =>
      'Bu cümlenin çevirisi şu anda kullanılamıyor.';

  @override
  String get practiceChooseTranslationLanguageTitle => 'Çeviri Dilini Seç';

  @override
  String get practiceChooseTranslationLanguageDescription =>
      'Bantera dinleme pratiğini bu dile çevirecek ve sonraki oturumlar için profiline kaydedecek.';

  @override
  String get practiceChangeTranslationLanguageTitle => 'Çeviri Dilini Değiştir';

  @override
  String get practiceChangeTranslationLanguageDescription =>
      'Bantera\'nın çeviri yapacağı dili seç. Yeni seçimin profiline kaydedilecek.';

  @override
  String get practiceConfirmTranslationLanguageTitle => 'Çeviri Dilini Onayla';

  @override
  String get practiceConfirmTranslationLanguageBody =>
      'Bantera bu dili profiline kaydedecek ve sonraki dinleme pratiklerinde varsayılan çeviri dili olarak kullanacak.';

  @override
  String get practiceCouldNotSaveTranslationLanguage =>
      'Bantera çeviri dilini kaydedemedi.';

  @override
  String get practiceNoTranslationLanguagesFound =>
      'Bantera bu transkript için çeviri dili bulamadı.';

  @override
  String get practicePlayAllTitle => 'Gölgeleme';

  @override
  String get practicePlayAllDescription =>
      'Gölgeleme için cümleler arası duraklama:';

  @override
  String get practicePlayAllPauseZeroSeconds => '0 sn';

  @override
  String get practicePlayAllPauseOneSecondLabel => '1 sn';

  @override
  String get practicePlayAllPauseOneCuePlusOneSecond => '1 cümle + 1 sn';

  @override
  String get practicePlayAllPauseOneCuePlusTwoSeconds => '1 cümle + 2 sn';

  @override
  String get practicePlayAllTimesPerCueTitle => 'Cümle başına tekrar';

  @override
  String get practicePlayAllTimesOnce => '1×';

  @override
  String get practicePlayAllTimesTwice => '2×';

  @override
  String get practicePlayAllTimesThrice => '3×';

  @override
  String get practiceSearchLanguagesHint => 'Dil ara';

  @override
  String get practiceTranslationInstalled => 'Yüklü';

  @override
  String get practiceTranslationDownload => 'İndir';

  @override
  String get practiceStartOverTitle => 'Baştan başlansın mı?';

  @override
  String get practiceStartOverBody => 'İlk cümleye dönülsün mü?';

  @override
  String get practiceNextFromLastTitle => 'İlk cümleye gidilsin mi?';

  @override
  String get practiceNextFromLastBody =>
      'Son cümledesin. İlk cümleye dönmek ister misin?';

  @override
  String get practiceGoToFirstCue => 'İlk cümleye git';

  @override
  String get practiceVideoOpenError => 'Seçilen video pratik için açılamadı.';

  @override
  String get practiceAudioLoading => 'Ses yükleniyor…';

  @override
  String practiceAudioLoadingPercent(int percent) {
    return 'Ses yükleniyor %$percent';
  }

  @override
  String get practiceAudioError => 'Ses yüklenemedi. Lütfen tekrar dene.';

  @override
  String get compareRecordYourVersion => 'Kendi versiyonunu kaydet';

  @override
  String compareTranscriptionLanguage(String locale) {
    return 'Yazıya dökme dili: $locale';
  }

  @override
  String get compareOpenIphoneSettings => 'iPhone Ayarlarını Aç';

  @override
  String get comparePauseAttempt => 'Denemeyi Duraklat';

  @override
  String get comparePlayAttempt => 'Denemeyi Oynat';

  @override
  String get compareYourTranscribedAttempt => 'Yazıya dökülen denemen';

  @override
  String get compareHighlightHint =>
      'Bantera\'nın farklı tanıdığı kelimeler vurgulanır.';

  @override
  String get compareUncertainHint =>
      'Noktalı kelimeler tanındı ama Bantera emin olamadı; telaffuzunu kontrol et.';

  @override
  String get compareTryAgain => 'Tekrar Dene';

  @override
  String get compareDone => 'Bitti';

  @override
  String get compareStatusTranscribing =>
      'Denemen iPhone\'da yazıya dökülüyor…';

  @override
  String get compareStatusRecording =>
      'Kaydediliyor… Durdurmak için tekrar dokun.';

  @override
  String get compareStatusSavedAttempt =>
      'Bu cümle için kayıtlı bir deneme gösteriliyor. Tekrar dinleyebilir ya da yeniden deneyebilirsin.';

  @override
  String get compareStatusReplayOrRetry =>
      'Bu denemeyi tekrar dinleyebilir ya da cümleyi yeniden deneyebilirsin.';

  @override
  String get compareStatusTapToRecord =>
      'Bu cümleyi kendi sesinle kaydetmeye başlamak için dokun.';

  @override
  String get compareCouldNotStartRecording =>
      'Bantera şu anda kayda başlayamadı.';

  @override
  String get compareCouldNotAccessRecording =>
      'Bantera kaydedilen sese erişemedi.';

  @override
  String get compareNoTranscriptGenerated =>
      'Bu deneme için transkript oluşturulamadı. Mikrofona daha yakın konuşarak tekrar dene.';

  @override
  String get compareRecentAttempts => 'Son denemeler';

  @override
  String get compareAttemptsFooterNote =>
      'Bantera, aynı cümledeki ilerlemeni görebilmen için denemelerini bu iPhone\'da saklar.';

  @override
  String compareMatchedCount(int count) {
    return '$count eşleşti';
  }

  @override
  String compareDifferentCount(int count) {
    return '$count farklı';
  }

  @override
  String compareMissingCount(int count) {
    return '$count eksik';
  }

  @override
  String compareUncertainCount(int count) {
    return '$count belirsiz';
  }

  @override
  String get compareMicrophoneDeniedPermanent =>
      'Bantera için mikrofon erişimi kapalı. Kendi versiyonunu kaydetmek için iPhone Ayarları > Bantera > Mikrofon yolunu izleyip aç.';

  @override
  String get compareMicrophoneDeniedRestricted =>
      'Bu iPhone şu anda Bantera\'nın mikrofon erişimini kısıtlıyor. Açmak için Ekran Süresi\'ni, cihaz yönetimini veya sistem ayarlarını kontrol et.';

  @override
  String get compareMicrophoneDeniedDefault =>
      'Kendi versiyonunu kaydetmek için mikrofon izni gerekli. İzin isteğini daha önce kapattıysan iPhone Ayarları > Bantera > Mikrofon yolunu izleyip aç.';

  @override
  String get compareSpeechRecognitionDeniedPermanent =>
      'Bantera için Konuşma Tanıma erişimi kapalı. Kaydını karşılaştırmak için iPhone Ayarları > Bantera > Konuşma Tanıma yolunu izleyip aç.';

  @override
  String get compareSpeechRecognitionDeniedRestricted =>
      'Bu iPhone şu anda Bantera\'nın Konuşma Tanıma erişimini kısıtlıyor. Açmak için Ekran Süresi\'ni, cihaz yönetimini veya sistem ayarlarını kontrol et.';

  @override
  String get compareSpeechRecognitionUnavailable =>
      'Konuşma Tanıma şu anda bu iPhone\'da kullanılamıyor.';

  @override
  String get compareSpeechRecognitionUnsupportedLocale =>
      'Konuşma Tanıma bu iPhone\'da bu pratik dili için kullanılamıyor.';

  @override
  String get comparePlayAttemptTooltip => 'Denemeyi oynat';

  @override
  String get comparePauseAttemptTooltip => 'Denemeyi duraklat';

  @override
  String get createWhatToday => 'Bugün ne yapmak istersin?';

  @override
  String get createPracticeVideo => 'Video ile Pratik';

  @override
  String get createYourMedia => 'Medyan';

  @override
  String get createTryAgain => 'Tekrar Dene';

  @override
  String get createUploadedVideosEmptyHint =>
      'Yüklediğin videolar burada görünür; böylece onları yeniden açıp cümle cümle pratik yapabilirsin.';

  @override
  String get createUploadingTips => 'Yükleme İpuçları';

  @override
  String get createUploadingTipsBody =>
      'En iyi sonuç için sesini 3 dakikanın altında tut. Net altyazılar otomatik olarak oluşturulur!';

  @override
  String get createOnThisIphone => 'Bu iPhone\'da';

  @override
  String get createLocalVideosEmptyHint =>
      'Yerel olarak pratik yaptığın videolar bu iPhone\'a kaydedilir; böylece onları daha sonra yeniden yazıya dökmeden açabilirsin.';

  @override
  String get createOnDeviceBadge => 'Cihazda';

  @override
  String get createSignInToLoadVideos =>
      'Yüklediğin videoları görmek için tekrar giriş yap.';

  @override
  String createVideoMetaCues(int count) {
    return '$count cümle';
  }

  @override
  String get createPublicBadge => 'Herkese Açık';

  @override
  String get createPrivateBadge => 'Özel';

  @override
  String get createAiBadge => 'YZ';

  @override
  String get createDeleteSavedVideoTitle => 'Kayıtlı Video Silinsin mi?';

  @override
  String createDeleteSavedVideoBody(String title) {
    return 'Bantera, \"$title\" adlı videoyu bu iPhone\'dan kaldıracak ve kayıtlı transkript cümlelerini silecek.';
  }

  @override
  String get createDeleteMediaTitle => 'Medya silinsin mi?';

  @override
  String createDeleteMediaBody(String title) {
    return '\"$title\" ve transkripti kalıcı olarak silinecek. Bu işlem geri alınamaz.';
  }

  @override
  String get removeFromListTitle => 'Listeden kaldırılsın mı?';

  @override
  String get removeFromListBody =>
      'Bu öğe listeden kaldırılacak. Bu işlem geri alınamaz.';

  @override
  String get editProfileChangeImage => 'Profil Fotoğrafını Değiştir';

  @override
  String get editProfileUploading => 'Yükleniyor…';

  @override
  String get editProfileNameLabel => 'Ad';

  @override
  String get editProfileNameHint => 'Bantera adını nasıl göstersin?';

  @override
  String get editProfileSaveNameButton => 'Adı Kaydet';

  @override
  String get editProfileSaving => 'Kaydediliyor…';

  @override
  String get editProfileLanguagesSection => 'Diller';

  @override
  String get editProfileMyNativeLanguage => 'Ana Dilim';

  @override
  String get editProfileMyNativeLanguageSubtitle => 'Ana dilin ya da ilk dilin';

  @override
  String get editProfileLearningLanguage => 'Öğrendiğim Dil';

  @override
  String get editProfileLearningLanguageSubtitle =>
      'Pratik yapmak istediğin dil';

  @override
  String get editProfileImageUpdated => 'Profil fotoğrafı güncellendi.';

  @override
  String get editProfileNameUpdated => 'Ad güncellendi.';

  @override
  String get editProfileEnterName => 'Bir ad gir.';

  @override
  String get editProfileNameMaxLength => 'En fazla 80 karakter kullan.';

  @override
  String get editProfileCouldNotLoadLanguages => 'Dil listesi yüklenemedi.';

  @override
  String get languagePickerNone => 'Yok';

  @override
  String get languagePickerClearSelection => 'Seçimi temizle';

  @override
  String get languagePickerNoMatchingLanguages => 'Dil bulunamadı.';

  @override
  String get languagePickerMoreComingSoon => 'Daha fazla dil yakında';

  @override
  String get editProfileNativeLanguageCleared => 'Ana dil temizlendi.';

  @override
  String get editProfileLearningLanguageCleared => 'Öğrenilen dil temizlendi.';

  @override
  String editProfileNativeLanguageSetTo(String language) {
    return 'Ana dil $language olarak ayarlandı.';
  }

  @override
  String editProfileLearningLanguageSetTo(String language) {
    return 'Öğrenilen dil $language olarak ayarlandı.';
  }

  @override
  String get profileLanguageSettings => 'Dil Ayarları';

  @override
  String get profileLearningLabel => 'Öğrenilen';

  @override
  String get profileNotSet => 'Ayarlanmadı';

  @override
  String get uploadedDetailYourAudio => 'Sesin';

  @override
  String get uploadedDetailYourVideo => 'Videon';

  @override
  String get uploadedDetailDeleteAudioTitle => 'Ses silinsin mi?';

  @override
  String get uploadedDetailDeleteAudioBody =>
      'Ses ve transkripti kalıcı olarak silinecek. Bu işlem geri alınamaz.';

  @override
  String get uploadedDetailDeleteVideoTitle => 'Video silinsin mi?';

  @override
  String get uploadedDetailDeleteVideoBody =>
      'Video ve transkripti kalıcı olarak silinecek. Bu işlem geri alınamaz.';

  @override
  String get uploadedDetailAiGenerated => 'YZ ile Oluşturuldu';

  @override
  String get uploadedDetailFileSize => 'Dosya boyutu';

  @override
  String get uploadedDetailResolution => 'Çözünürlük';

  @override
  String get uploadedDetailResolutionUnknown => 'Bilinmiyor';

  @override
  String get uploadedDetailTranscribing => 'Yazıya dökülüyor…';

  @override
  String get uploadedDetailNoTranscriptCuesYet =>
      'Henüz transkript cümlesi yok.';

  @override
  String uploadedDetailMediaDescription(int count) {
    return 'Yüklediğin pratik klibi. Transkript cümlesi sayısı: $count.';
  }

  @override
  String get uploadedDetailTranscriptionFailedFallback =>
      'Yazıya dökme başarısız. Tahmini cümleler kullanılıyor.';

  @override
  String get uploadedDetailTranscriptionNoCues =>
      'Yazıya dökme hiç cümle döndürmedi.';

  @override
  String get uploadedDetailTranscriptionSourceYourUpload => 'Yüklemen';

  @override
  String get aiGenLeaveTitle => 'Bu sayfadan çıkılsın mı?';

  @override
  String get aiGenLeaveBody =>
      'Ses hâlâ oluşturuluyor. Şimdi çıkarsan işlem iptal edilir.';

  @override
  String get aiGenStay => 'Kal';

  @override
  String get aiGenLeave => 'Çık';

  @override
  String get aiGenLoadingTitle => 'Sesin oluşturuluyor…';

  @override
  String get aiGenLoadingSubtitle =>
      'Bu işlem bir dakika kadar sürebilir.\nOluşturma bitene kadar lütfen bu sayfada kal.';

  @override
  String get aiGenStepPreparingSpeechModel =>
      'Cihaz üzerindeki konuşma modeli hazırlanıyor';

  @override
  String get aiGenStepWritingDialogue => 'Diyalog yazılıyor';

  @override
  String get aiGenStepGeneratingAudio => 'Ses oluşturuluyor';

  @override
  String get aiGenStepAligningAudio => 'Ses hizalanıyor';

  @override
  String get aiGenStepTranscribing => 'Yazıya dökülüyor';

  @override
  String get aiGenStepCorrectingTranscript => 'Transkript düzeltiliyor';

  @override
  String get aiGenLanguageSection => 'Dil';

  @override
  String get aiGenSetLearningLanguagePrompt =>
      'Oluşturmayı etkinleştirmek için öğrendiğin dili ayarla';

  @override
  String get aiGenLoadingLanguage => 'Dil yükleniyor…';

  @override
  String aiGenLanguageUnsupported(String language) {
    return '\"$language\" dili için oluşturma desteklenmiyor.';
  }

  @override
  String get aiGenScenarioSection => 'Senaryo';

  @override
  String get aiGenScenarioOptionalHint =>
      'İsteğe bağlı; rastgele bir senaryo için seçim yapma.';

  @override
  String get aiGenCustomScenarioHint => 'Senaryonu anlat…';

  @override
  String get aiGenDurationSection => 'Süre';

  @override
  String aiGenDurationMinutes(int minutes) {
    return '$minutes dk';
  }

  @override
  String get aiGenGenerateButton => 'Oluştur';

  @override
  String get aiGenOwnershipNotice =>
      'Burada oluşturduğun sesler Bantera topluluk içeriği olur ve tüm öğrenenler için pratik materyali olarak herkese açık paylaşılır.';

  @override
  String get aiGenOwnershipCheckbox =>
      'Bu sesi Bantera topluluk içeriği olarak paylaş';

  @override
  String get aiGenOwnershipConfirmTitle =>
      'Topluluk içeriği olarak paylaşılsın mı?';

  @override
  String get aiGenOwnershipConfirmCancel => 'Vazgeç';

  @override
  String get aiGenOwnershipConfirmGenerate => 'Oluştur';

  @override
  String get aiGenFooterNotice =>
      'YZ iki kişilik bir diyalog yazıp seslendirecek. Sonuç, herkese açık bir pratik sesi olarak kaydedilecek.';

  @override
  String get aiScenarioCoffeeShop => 'Kafede';

  @override
  String get aiScenarioLatestNews => 'Son Haberler';

  @override
  String get aiScenarioAirportReunion => 'Havalimanında buluşma';

  @override
  String get aiScenarioGroceryStore => 'Markette';

  @override
  String get aiScenarioDoctorVisit => 'Doktor ziyareti';

  @override
  String get aiScenarioJobInterview => 'İş görüşmesi';

  @override
  String get aiScenarioNewNeighbour => 'Yeni komşu';

  @override
  String get aiScenarioTechSupport => 'Teknik destek';

  @override
  String get aiScenarioBirthdaySurprise => 'Doğum günü sürprizi';

  @override
  String get aiScenarioGymTips => 'Spor salonu ipuçları';

  @override
  String get aiScenarioWeatherSmalltalk => 'Hava durumu sohbeti';

  @override
  String get aiScenarioRestaurantOrder => 'Restoranda sipariş';

  @override
  String get aiScenarioBookRecommendation => 'Kitap önerisi';

  @override
  String get aiScenarioBusDelay => 'Otobüs gecikmesi';

  @override
  String get aiScenarioMovieDebate => 'Film tartışması';

  @override
  String get aiScenarioCustom => 'Özel…';

  @override
  String get errorNetworkUnreachable =>
      'Bantera\'ya bağlanılamadı. İnternet bağlantını kontrol et.';

  @override
  String get errorNetworkCellularBlocked =>
      'Bantera için mobil veri kapalı. Ayarlar\'da Bantera\'yı açıp Mobil Veri\'yi etkinleştir ya da Wi-Fi\'ye bağlan.';

  @override
  String get errorTlsConnection => 'Güvenli bağlantı kurulamadı.';

  @override
  String get settingsRateAppPrompt =>
      'Bantera\'yı beğendin mi? App Store\'da kısa bir puan bizim için çok değerli.';

  @override
  String get settingsRateAppButton => 'App Store\'da Puanla';

  @override
  String get settingsSharePrompt =>
      'Dil öğrenen birini tanıyor musun? Bantera\'yı onunla paylaş.';

  @override
  String get settingsShareButton => 'Bantera\'yı Paylaş';

  @override
  String get settingsContactButton => 'Bize ulaş';

  @override
  String get localVideoDescription =>
      'Fotoğraflar\'dan bir video seç, konuşulan dili belirle ve cümle cümle pratikten önce iPhone\'un videoyu arka planda yazıya döksün.';

  @override
  String get localVideoStep1Title => '1. Video seç';

  @override
  String get localVideoChooseFromPhotos => 'Fotoğraflar\'dan Seç';

  @override
  String get localVideoChooseDifferent => 'Başka Bir Video Seç';

  @override
  String get localVideoSelectedFileLabel => 'Seçilen dosya';

  @override
  String get localVideoSizeLabel => 'Boyut';

  @override
  String get localVideoDurationLabel => 'Süre';

  @override
  String get localVideoLongVideoWarning =>
      'Bu video 3 dakikadan uzun; Bantera\'nın transkripti ve çeviriyi hazırlaması daha uzun sürebilir.';

  @override
  String get localVideoStep2Title => '2. Yazıya dökme dili';

  @override
  String get localVideoChooseLanguagePlaceholder => 'Konuşulan dili seç';

  @override
  String get localVideoLanguageHint =>
      'Bantera son dil seçimini hatırlar ve pratik başladığında transkripti varsayılan olarak gizli tutar.';

  @override
  String get localVideoStep3Title => '3. Pratik';

  @override
  String get localVideoPreparing => 'Hazırlanıyor...';

  @override
  String get localVideoPracticeHint =>
      'Bantera önce cihazda yazıya döker, ardından hiçbir şey yüklemeden cümle cümle dinleme sayfasını açar.';

  @override
  String get localVideoStatusLongVideo =>
      'Bu video uzun olduğu için Bantera\'nın yazıya dökmesi ve hazırlaması biraz daha zaman alabilir.';

  @override
  String get localVideoStatusTranscribing =>
      'Cihazda yazıya dökülüyor ve pratik cümleleri hazırlanıyor...';

  @override
  String get localVideoStatusSaving =>
      'Bu video, cihazdaki pratik kitaplığına kaydediliyor...';

  @override
  String get localVideoStatusTranslationLong =>
      'Yazıya dökme tamamlandı. Bantera kayıtlı dilin için çeviriyi de hazırlıyor; bu uzun video biraz daha zaman alabilir.';

  @override
  String get localVideoStatusTranslation =>
      'Yazıya dökme tamamlandı. Kayıtlı dilin için çeviri hazırlanıyor...';

  @override
  String get localVideoPickerTitle => 'Ses Dilini Seç';

  @override
  String get savedCuesTitle => 'Kaydedilen Cümleler';

  @override
  String get savedCuesEmpty =>
      'Henüz kaydedilen cümle yok. Pratik yaparken bir cümleyi kaydetmek için yer işareti simgesine dokun.';

  @override
  String get savedCuesDeleteTooltip => 'Kaydedilen cümleyi kaldır';

  @override
  String get savedCuesDeleteConfirmTitle => 'Bu cümle kaldırılsın mı?';

  @override
  String get savedCuesDeleteConfirmBody =>
      'Bu cümle kaydedilenler listenden kaldırılacak.';

  @override
  String get savedCuesDeleteAllTooltip => 'Kaydedilen tüm cümleleri sil';

  @override
  String get savedCuesDeleteAllConfirmTitle =>
      'Kaydedilen tüm cümleler silinsin mi?';

  @override
  String get savedCuesDeleteAllConfirmBody =>
      'Kaydedilen tüm cümleler kalıcı olarak kaldırılacak.';

  @override
  String get updateAlertTitle => 'Güncelleme Mevcut';

  @override
  String get updateAlertMessage =>
      'Bantera\'nın yeni bir sürümü mevcut. En yeni özellikler ve iyileştirmeler için hemen güncelle.';

  @override
  String get updateCurrentVersionLabel => 'Mevcut sürüm';

  @override
  String get updateAppStoreVersionLabel => 'App Store sürümü';

  @override
  String get updateAlertUpdate => 'Güncelle';

  @override
  String get updateAlertLater => 'Sonra';

  @override
  String get checkForUpdateButton => 'Güncellemeleri Denetle';

  @override
  String get upToDateAlertTitle => 'Güncel';

  @override
  String upToDateAlertMessage(Object version) {
    return 'Bantera $version en son sürüm.';
  }

  @override
  String get sectionSupport => 'Destek';

  @override
  String get permissionActionAllow => 'İzin Ver';
}
