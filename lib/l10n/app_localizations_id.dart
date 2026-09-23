// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'Bantera';

  @override
  String get appTagline => 'Latihan bahasa, kalimat demi kalimat.';

  @override
  String get authContinueWithApple => 'Lanjutkan dengan Apple';

  @override
  String get authContinueWithGoogle => 'Lanjutkan dengan Google';

  @override
  String get authAppleUnavailable =>
      'Masuk dengan Apple tidak tersedia di perangkat ini.';

  @override
  String get authOrSignInEmail => 'atau masuk dengan email';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Kata Sandi';

  @override
  String get authSigningIn => 'Sedang masuk...';

  @override
  String get authSignIn => 'Masuk';

  @override
  String get authSignInWithEmail => 'Masuk dengan email';

  @override
  String get validationEnterEmail => 'Masukkan email kamu.';

  @override
  String get validationValidEmail => 'Masukkan email yang valid.';

  @override
  String get validationEnterPassword => 'Masukkan kata sandi kamu.';

  @override
  String get onboardingTitle => 'Siapkan profil kamu';

  @override
  String get onboardingSubtitle =>
      'Ini membantu Bantera menyesuaikan latihan dan chat untukmu.';

  @override
  String get onboardingNameTitle => 'Orang lain harus memanggilmu apa?';

  @override
  String get onboardingNameSubtitle =>
      'Kami mengisinya dari akunmu saat Apple menyediakannya. Kamu bisa mengubahnya sekarang.';

  @override
  String get onboardingClearName => 'Hapus nama';

  @override
  String get onboardingNativeLanguageTitle => 'Apa bahasa ibumu?';

  @override
  String get onboardingNativeLanguageSubtitle =>
      'Bantera menggunakan ini untuk terjemahan dan grup bahasa.';

  @override
  String get onboardingLearningLanguageTitle =>
      'Bahasa apa yang sedang kamu pelajari?';

  @override
  String get onboardingLearningLanguageSubtitle =>
      'Ini menentukan konten latihan dan grup belajar.';

  @override
  String get onboardingAvatarTitle => 'Tambahkan foto profil';

  @override
  String get onboardingAvatarSubtitle =>
      'Pilih foto, atau lanjutkan dan Bantera akan membuatkannya untukmu.';

  @override
  String get onboardingAvatarGenderTitle => 'Buat foto profilmu';

  @override
  String get onboardingAvatarGenderBody =>
      'Pilih cara Bantera membuat foto profilmu. Kami tidak menyimpan pilihan ini; pilihan ini hanya digunakan untuk gambar ini.';

  @override
  String get onboardingAvatarGenderMale => 'Pria';

  @override
  String get onboardingAvatarGenderFemale => 'Wanita';

  @override
  String get onboardingChoosePhoto => 'Pilih Foto';

  @override
  String get onboardingChangePhoto => 'Ganti Foto';

  @override
  String get onboardingUseGeneratedAvatar => 'Gunakan avatar buatan saja';

  @override
  String get onboardingUseCurrentPhoto => 'Gunakan foto saat ini';

  @override
  String get onboardingChooseLanguage => 'Pilih bahasa';

  @override
  String get onboardingBack => 'Kembali';

  @override
  String get onboardingFinish => 'Selesai';

  @override
  String get onboardingLoadingProfile => 'Memuat profil...';

  @override
  String get onboardingSavingProfile => 'Menyimpan profil...';

  @override
  String get onboardingLoadFailed => 'Terjadi kesalahan. Coba lagi.';

  @override
  String get onboardingSearchHint => 'Cari bahasa…';

  @override
  String get onboardingRetry => 'Coba Lagi';

  @override
  String get onboardingNoMatching => 'Tidak ada bahasa yang cocok.';

  @override
  String get onboardingFailedSave => 'Gagal menyimpan.';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get sectionAppearance => 'Tampilan';

  @override
  String get sectionAccount => 'Akun';

  @override
  String get sectionRateAndShare => 'Beri Nilai & Bagikan';

  @override
  String get sectionLanguage => 'Bahasa Tampilan';

  @override
  String get sectionPermissions => 'Izin';

  @override
  String get sectionNotifications => 'Notifikasi';

  @override
  String get languageSectionSubtitle =>
      'Pilih bahasa tampilan app. Sistem mengikuti pengaturan perangkatmu.';

  @override
  String get themeLabel => 'Tema';

  @override
  String get themeLight => 'Terang';

  @override
  String get themeDark => 'Gelap';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get languageEnglish => 'Inggris';

  @override
  String get languageChineseSimplified => 'Mandarin (Sederhana)';

  @override
  String get languageKorean => 'Korea';

  @override
  String get languageJapanese => 'Jepang';

  @override
  String get signedOutLabel => 'Belum masuk';

  @override
  String get noActiveSession => 'Tidak ada sesi Bantera yang aktif';

  @override
  String signedInWith(String provider) {
    return 'Masuk dengan $provider';
  }

  @override
  String get editProfile => 'Edit Profil';

  @override
  String get more => 'Lainnya';

  @override
  String get appPermissionsTitle => 'Izin App';

  @override
  String get appPermissionsSubtitle =>
      'Tinjau akses yang digunakan Bantera di perangkat ini.';

  @override
  String get permissionsIntro =>
      'Bantera menggunakan pengaturan perangkat ini untuk merekam, membandingkan ucapan, dan akses jaringan.';

  @override
  String get permissionsOpenSettings => 'Buka Pengaturan iPhone';

  @override
  String get permissionsRefresh => 'Segarkan';

  @override
  String get permissionMicrophoneTitle => 'Mikrofon';

  @override
  String get permissionMicrophoneDescription =>
      'Rekam percobaan latihan dan pesan suara.';

  @override
  String get permissionSpeechTitle => 'Pengenalan Ucapan';

  @override
  String get permissionSpeechDescription =>
      'Transkripsikan rekaman latihan dan pesan suara.';

  @override
  String get permissionMobileDataTitle => 'Data Seluler';

  @override
  String get permissionMobileDataDescription =>
      'Gunakan Bantera saat iPhone ini tidak terhubung ke Wi-Fi.';

  @override
  String get permissionStatusAllowed => 'Diizinkan';

  @override
  String get permissionStatusLimited => 'Terbatas';

  @override
  String get permissionStatusNotAllowed => 'Tidak Diizinkan';

  @override
  String get permissionStatusUnknown => 'Tidak Diketahui';

  @override
  String get signOut => 'Keluar';

  @override
  String get signOutDialogTitle => 'Keluar?';

  @override
  String get signOutDialogBody =>
      'Kamu harus masuk lagi untuk menggunakan akunmu.';

  @override
  String get cancel => 'Batal';

  @override
  String get closeLabel => 'Tutup';

  @override
  String get navDiscover => 'Jelajahi';

  @override
  String get navCreate => 'Buat';

  @override
  String get navProfile => 'Profil';

  @override
  String get chatsTitle => 'Chat';

  @override
  String get chatNoChatsYet => 'Belum ada chat.';

  @override
  String get chatOnlineSection => 'Online';

  @override
  String get chatDirectMessagesSection => 'DM';

  @override
  String chatAudioDuration(String duration) {
    return 'Audio $duration';
  }

  @override
  String get chatEnableNotifications => 'Aktifkan notifikasi';

  @override
  String get chatMuteNotifications => 'Bisukan notifikasi';

  @override
  String get chatBlockUser => 'Blokir pengguna';

  @override
  String get chatDeleteDm => 'Hapus DM';

  @override
  String get chatCall => 'Panggil';

  @override
  String get chatStartAudioCall => 'Panggilan Suara';

  @override
  String get chatStartVideoCall => 'Panggilan Video';

  @override
  String get chatAudioCalling => 'Memanggil (suara)...';

  @override
  String get chatVideoCalling => 'Memanggil (video)...';

  @override
  String get chatAudioIncoming => 'Panggilan suara masuk';

  @override
  String get chatVideoIncoming => 'Panggilan video masuk';

  @override
  String get chatCallConnecting => 'Menghubungkan...';

  @override
  String get chatCallAccept => 'Terima';

  @override
  String get chatCallDecline => 'Tolak';

  @override
  String get chatCallEnd => 'Akhiri';

  @override
  String get chatCallMute => 'Bisukan';

  @override
  String get chatCallUnmute => 'Bunyikan';

  @override
  String get chatCallSpeaker => 'Speaker';

  @override
  String get chatCallCamera => 'Kamera';

  @override
  String get chatCallSwitchCamera => 'Balik';

  @override
  String get chatCallIssueTitle => 'Masalah panggilan';

  @override
  String get chatCallMicrophoneDenied =>
      'Bantera memerlukan akses mikrofon sebelum memulai panggilan.';

  @override
  String get chatCallMicrophoneSettings =>
      'Akses mikrofon untuk Bantera nonaktif. Buka Pengaturan dan aktifkan untuk panggilan.';

  @override
  String get chatCallCameraDenied =>
      'Bantera memerlukan akses kamera sebelum memulai panggilan video.';

  @override
  String get chatCallCameraSettings =>
      'Akses kamera untuk Bantera nonaktif. Buka Pengaturan dan aktifkan untuk panggilan video.';

  @override
  String get chatCallBusy => 'Pengguna ini sedang dalam panggilan lain.';

  @override
  String get chatCallUnavailable =>
      'Pengguna ini tidak dapat menerima panggilan saat ini.';

  @override
  String get chatCallNetworkRestricted =>
      'Jaringan ini tidak dapat menyambungkan panggilan. Coba Wi-Fi atau jaringan lain.';

  @override
  String get chatCallFailed => 'Panggilan tidak dapat dimulai. Coba lagi.';

  @override
  String get chatGroupReady => 'Grup ini siap untuk pesan audio.';

  @override
  String get chatHoldToStartDm => 'Tahan untuk merekam dan memulai DM.';

  @override
  String get chatNoGroupAudio => 'Belum ada audio di grup.';

  @override
  String get chatNoDmAudio => 'Belum ada audio di DM ini.';

  @override
  String get chatSendingAudio => 'Mengirim audio...';

  @override
  String get chatRecordingReleaseToSend => 'Merekam... lepaskan untuk mengirim';

  @override
  String get chatHoldToRecordAudio => 'Tahan untuk merekam audio';

  @override
  String get chatRecordingStatus => 'Merekam...';

  @override
  String get chatGroupLabel => 'Grup';

  @override
  String get chatNotificationsEnabledForDm =>
      'Notifikasi diaktifkan untuk DM ini.';

  @override
  String get chatNotificationsMutedForDm =>
      'Notifikasi dibisukan untuk DM ini.';

  @override
  String chatBlockUserTitle(String user) {
    return 'Blokir $user?';
  }

  @override
  String get chatBlockUserBody =>
      'Kalian tidak akan saling melihat di DM dan pesan grup bersama sampai kamu membuka blokir.';

  @override
  String chatBlockUserSuccess(String user) {
    return '$user telah diblokir.';
  }

  @override
  String get chatBlockUserFailed =>
      'Tidak dapat memblokir pengguna ini. Coba lagi.';

  @override
  String get chatDeleteMessage => 'Hapus pesan';

  @override
  String get chatDeleteMessageTitle => 'Hapus pesan ini?';

  @override
  String get chatDeleteMessageBody =>
      'Pesan ini akan dihapus untuk semua orang dalam percakapan. Tindakan ini tidak dapat dibatalkan.';

  @override
  String get chatDeleteMessageSuccess => 'Pesan dihapus';

  @override
  String get chatDeleteMessageFailed =>
      'Tidak dapat menghapus pesan. Coba lagi.';

  @override
  String get chatDeleteDmTitle => 'Hapus DM ini?';

  @override
  String get chatDeleteDmBody =>
      'Ini hanya menghapusnya dari daftarmu. Pesan baru dapat memunculkannya kembali nanti.';

  @override
  String get chatMicrophoneRequiredTitle => 'Perlu mikrofon';

  @override
  String get chatMicrophoneRequiredSettings =>
      'Bantera memerlukan akses mikrofon untuk merekam audio chat. Aktifkan di Pengaturan.';

  @override
  String get chatMicrophoneRequiredBody =>
      'Bantera memerlukan akses mikrofon untuk merekam audio chat.';

  @override
  String get chatGroupNotReady => 'Grup ini belum siap.';

  @override
  String get chatMessageAction => 'Kirim Pesan';

  @override
  String get chatRetranscribe => 'Transkripsi Ulang';

  @override
  String get chatTranscribe => 'Transkripsikan';

  @override
  String get chatTranscribingOnDevice => 'Mentranskripsi di iPhone ini...';

  @override
  String get chatTranscriptionFailed => 'Transkripsi gagal. Coba lagi.';

  @override
  String get chatTranslate => 'Terjemahkan';

  @override
  String get chatRetranslate => 'Terjemahkan Ulang';

  @override
  String get chatTranslating => 'Menerjemahkan di iPhone ini...';

  @override
  String get chatTranslationFailed => 'Terjemahan gagal. Coba lagi.';

  @override
  String get chatGroupSettingsTitle => 'Pengaturan grup';

  @override
  String get chatNotifications => 'Notifikasi';

  @override
  String get chatBlockedUsersMenu => 'Pengguna yang Diblokir';

  @override
  String get chatBlockedUsersTitle => 'Pengguna yang Diblokir';

  @override
  String get chatBlockedPeople => 'Orang yang diblokir';

  @override
  String get chatNoBlockedUsers => 'Belum ada pengguna yang diblokir.';

  @override
  String get chatNoBlockedPeople => 'Belum ada orang yang diblokir.';

  @override
  String get chatUnblock => 'Buka Blokir';

  @override
  String chatUnblockUserTitle(String user) {
    return 'Buka blokir $user?';
  }

  @override
  String get chatUnblockUserBody =>
      'Kalian mungkin akan saling melihat lagi di DM dan pesan grup bersama.';

  @override
  String get chatUnblockFailed =>
      'Tidak dapat membuka blokir pengguna ini. Coba lagi.';

  @override
  String get chatNotificationsTitle => 'Notifikasi chat';

  @override
  String get chatNotificationsSubtitle =>
      'Satu pengaturan untuk seluruh akun di semua perangkatmu.';

  @override
  String get chatNotificationsDisabledTitle => 'Notifikasi nonaktif';

  @override
  String get chatNotificationsDisabledSettings =>
      'Aktifkan notifikasi di Pengaturan untuk menerima pemberitahuan chat Bantera.';

  @override
  String get chatNotificationsDisabledBody =>
      'Bantera memerlukan izin notifikasi sebelum pemberitahuan chat dapat diaktifkan.';

  @override
  String get chatNotificationUpdateFailed =>
      'Tidak dapat memperbarui notifikasi chat. Coba lagi.';

  @override
  String get savedTitle => 'Media Tersimpan';

  @override
  String get generateWithAiTitle => 'Buat dengan AI';

  @override
  String get practiceLocalVideoTitle => 'Latihan Video Lokal';

  @override
  String get uploadVideoTitle => 'Unggah Video';

  @override
  String get lessonDetailsTitle => 'Detail Pelajaran';

  @override
  String get accountMoreTitle => 'Lainnya';

  @override
  String get deleteAccount => 'Hapus akun';

  @override
  String get deleteAccountSubtitle =>
      'Hapus akun dan data server kamu secara permanen';

  @override
  String get confirmDeletionTitle => 'Konfirmasi penghapusan';

  @override
  String get deleteAccountImmediateBody =>
      'Akunmu akan segera dihapus. Kamu harus membuat akun baru untuk menggunakan Bantera lagi.';

  @override
  String get deleteAccountConfirm => 'Hapus akun';

  @override
  String get couldNotDeleteAccount => 'Tidak dapat menghapus akun. Coba lagi.';

  @override
  String get deleteAccountQuestionTitle => 'Hapus akun?';

  @override
  String get deleteAccountQuestionBody =>
      'Semua informasi dan data pribadimu akan dihapus secara permanen dari server kami dan tidak dapat dipulihkan.';

  @override
  String get typeDeleteLabel => 'Ketik \"DELETE\" untuk melanjutkan';

  @override
  String get continueLabel => 'Lanjutkan';

  @override
  String get confirmLabel => 'Konfirmasi';

  @override
  String get deleteLabel => 'Hapus';

  @override
  String get removeFromListLabel => 'Hapus dari daftar';

  @override
  String get startLabel => 'Mulai';

  @override
  String get doneLabel => 'Selesai';

  @override
  String get discoverSearchHint => 'Cari judul atau transkrip…';

  @override
  String get discoverNoMoreResults => 'Tidak ada hasil lagi';

  @override
  String get discoverSetLearningLanguagePrompt =>
      'Atur bahasa yang kamu pelajari untuk melihat konten di sini';

  @override
  String discoverNoPublicContentInLanguage(String language) {
    return 'Belum ada konten publik dalam bahasa $language';
  }

  @override
  String get discoverSetLanguageToDiscover =>
      'Atur bahasa yang dipelajari untuk menjelajahi konten';

  @override
  String get mediaStartPractice => 'Mulai Latihan';

  @override
  String get mediaTranscript => 'Transkrip';

  @override
  String mediaTranscriptLineCount(int count) {
    return '($count baris)';
  }

  @override
  String get mediaShow => 'Tampilkan';

  @override
  String get mediaHide => 'Sembunyikan';

  @override
  String get mediaNoTranscriptAvailable => 'Transkrip tidak tersedia.';

  @override
  String get lessonSaveTooltip => 'Simpan';

  @override
  String get lessonUnsaveTooltip => 'Batal Simpan';

  @override
  String get mediaKindAudio => 'Audio';

  @override
  String get mediaKindVideo => 'Video';

  @override
  String get practiceNoCues => 'Tidak ada kalimat';

  @override
  String get practiceTranslating => 'Menerjemahkan…';

  @override
  String get practiceShowTranscript => 'Tampilkan Transkrip';

  @override
  String get practiceTranslate => 'Terjemahkan';

  @override
  String get practiceHideText => 'Sembunyikan Teks';

  @override
  String get practiceTextLabel => 'Teks';

  @override
  String get practiceStop => 'Berhenti';

  @override
  String get practicePlayAll => 'Shadowing';

  @override
  String get practiceCompare => 'Bandingkan';

  @override
  String get practiceRecord => 'Rekam';

  @override
  String get practiceStopRecording => 'Berhenti';

  @override
  String get practiceRecords => 'Rekaman';

  @override
  String get practiceRecordsLocalOnlyFooter =>
      'Percobaan hanya disimpan di perangkat ini dan tidak diunggah.';

  @override
  String get practiceRecordsEmpty =>
      'Belum ada percobaan tersimpan untuk kalimat ini.';

  @override
  String get practiceRecordingProcessError =>
      'Terjadi kesalahan saat memproses rekamanmu.';

  @override
  String get practiceStartOver => 'Mulai Ulang';

  @override
  String get practiceTranscriptHidden => 'Transkrip disembunyikan';

  @override
  String get practiceListenCarefully => 'Dengarkan baik-baik…';

  @override
  String get practiceTranslationUnavailableForCue =>
      'Terjemahan untuk kalimat ini belum tersedia saat ini.';

  @override
  String get practiceChooseTranslationLanguageTitle =>
      'Pilih Bahasa Terjemahan';

  @override
  String get practiceChooseTranslationLanguageDescription =>
      'Bantera akan menerjemahkan latihan mendengar ke bahasa ini dan menyimpannya ke profilmu untuk sesi berikutnya.';

  @override
  String get practiceChangeTranslationLanguageTitle => 'Ubah Bahasa Terjemahan';

  @override
  String get practiceChangeTranslationLanguageDescription =>
      'Pilih bahasa tujuan terjemahan Bantera. Pilihan baru akan disimpan ke profilmu.';

  @override
  String get practiceConfirmTranslationLanguageTitle =>
      'Konfirmasi Bahasa Terjemahan';

  @override
  String get practiceConfirmTranslationLanguageBody =>
      'Bantera akan menyimpan bahasa ini ke profilmu dan menggunakannya sebagai bahasa terjemahan default di latihan mendengar berikutnya.';

  @override
  String get practiceCouldNotSaveTranslationLanguage =>
      'Bantera tidak dapat menyimpan bahasa terjemahanmu.';

  @override
  String get practiceNoTranslationLanguagesFound =>
      'Bantera tidak menemukan bahasa terjemahan apa pun untuk transkrip ini.';

  @override
  String get practicePlayAllTitle => 'Shadowing';

  @override
  String get practicePlayAllDescription => 'Jeda antarkalimat untuk shadowing:';

  @override
  String get practicePlayAllPauseZeroSeconds => '0 dtk';

  @override
  String get practicePlayAllPauseOneSecondLabel => '1 dtk';

  @override
  String get practicePlayAllPauseOneCuePlusOneSecond => '1 kalimat + 1 dtk';

  @override
  String get practicePlayAllPauseOneCuePlusTwoSeconds => '1 kalimat + 2 dtk';

  @override
  String get practicePlayAllTimesPerCueTitle => 'Pengulangan per kalimat';

  @override
  String get practicePlayAllTimesOnce => '1×';

  @override
  String get practicePlayAllTimesTwice => '2×';

  @override
  String get practicePlayAllTimesThrice => '3×';

  @override
  String get practiceSearchLanguagesHint => 'Cari bahasa';

  @override
  String get practiceTranslationInstalled => 'Terpasang';

  @override
  String get practiceTranslationDownload => 'Unduh';

  @override
  String get practiceStartOverTitle => 'Mulai ulang?';

  @override
  String get practiceStartOverBody => 'Kembali ke kalimat pertama?';

  @override
  String get practiceNextFromLastTitle => 'Ke kalimat pertama?';

  @override
  String get practiceNextFromLastBody =>
      'Kamu berada di kalimat terakhir. Kembali ke kalimat pertama?';

  @override
  String get practiceGoToFirstCue => 'Ke kalimat pertama';

  @override
  String get practiceVideoOpenError =>
      'Video yang dipilih tidak dapat dibuka untuk latihan.';

  @override
  String get practiceAudioLoading => 'Memuat audio…';

  @override
  String practiceAudioLoadingPercent(int percent) {
    return 'Memuat audio $percent%';
  }

  @override
  String get practiceAudioError => 'Tidak dapat memuat audio. Coba lagi.';

  @override
  String get compareRecordYourVersion => 'Rekam versimu';

  @override
  String compareTranscriptionLanguage(String locale) {
    return 'Bahasa transkripsi: $locale';
  }

  @override
  String get compareOpenIphoneSettings => 'Buka Pengaturan iPhone';

  @override
  String get comparePauseAttempt => 'Jeda Percobaan';

  @override
  String get comparePlayAttempt => 'Putar Percobaan';

  @override
  String get compareYourTranscribedAttempt => 'Transkrip percobaanmu';

  @override
  String get compareHighlightHint =>
      'Kata yang dikenali berbeda oleh Bantera ditandai.';

  @override
  String get compareUncertainHint =>
      'Kata bergaris titik dikenali, tapi Bantera kurang yakin — periksa pelafalanmu.';

  @override
  String get compareTryAgain => 'Coba Lagi';

  @override
  String get compareDone => 'Selesai';

  @override
  String get compareStatusTranscribing =>
      'Mentranskripsi percobaanmu di iPhone…';

  @override
  String get compareStatusRecording => 'Merekam… Ketuk lagi untuk berhenti.';

  @override
  String get compareStatusSavedAttempt =>
      'Menampilkan percobaan tersimpan untuk kalimat ini. Kamu bisa memutarnya ulang atau mencoba lagi.';

  @override
  String get compareStatusReplayOrRetry =>
      'Kamu bisa memutar ulang percobaan ini atau mencoba kalimat ini lagi.';

  @override
  String get compareStatusTapToRecord =>
      'Ketuk untuk mulai merekam versimu dari kalimat ini.';

  @override
  String get compareCouldNotStartRecording =>
      'Bantera tidak dapat mulai merekam saat ini.';

  @override
  String get compareCouldNotAccessRecording =>
      'Bantera tidak dapat mengakses audio yang direkam.';

  @override
  String get compareNoTranscriptGenerated =>
      'Transkrip tidak dapat dibuat untuk percobaan ini. Coba lagi lebih dekat ke mikrofon.';

  @override
  String get compareRecentAttempts => 'Percobaan terbaru';

  @override
  String get compareAttemptsFooterNote =>
      'Bantera menyimpan percobaanmu di iPhone ini agar kamu bisa meninjau kemajuan pada kalimat yang sama.';

  @override
  String compareMatchedCount(int count) {
    return '$count cocok';
  }

  @override
  String compareDifferentCount(int count) {
    return '$count berbeda';
  }

  @override
  String compareMissingCount(int count) {
    return '$count terlewat';
  }

  @override
  String compareUncertainCount(int count) {
    return '$count kurang jelas';
  }

  @override
  String get compareMicrophoneDeniedPermanent =>
      'Akses mikrofon untuk Bantera nonaktif. Buka Pengaturan iPhone > Bantera > Mikrofon dan aktifkan untuk merekam versimu sendiri.';

  @override
  String get compareMicrophoneDeniedRestricted =>
      'iPhone ini sedang membatasi akses mikrofon untuk Bantera. Periksa Durasi Layar, manajemen perangkat, atau pengaturan sistem untuk mengaktifkannya.';

  @override
  String get compareMicrophoneDeniedDefault =>
      'Izin mikrofon diperlukan untuk merekam versimu sendiri. Jika sebelumnya kamu menutup permintaan izin, buka Pengaturan iPhone > Bantera > Mikrofon dan aktifkan.';

  @override
  String get compareSpeechRecognitionDeniedPermanent =>
      'Akses Pengenalan Ucapan untuk Bantera nonaktif. Buka Pengaturan iPhone > Bantera > Pengenalan Ucapan dan aktifkan untuk membandingkan rekamanmu.';

  @override
  String get compareSpeechRecognitionDeniedRestricted =>
      'iPhone ini sedang membatasi Pengenalan Ucapan untuk Bantera. Periksa Durasi Layar, manajemen perangkat, atau pengaturan sistem untuk mengaktifkannya.';

  @override
  String get compareSpeechRecognitionUnavailable =>
      'Pengenalan Ucapan tidak tersedia di iPhone ini saat ini.';

  @override
  String get compareSpeechRecognitionUnsupportedLocale =>
      'Pengenalan Ucapan tidak tersedia untuk bahasa latihan ini di iPhone ini.';

  @override
  String get comparePlayAttemptTooltip => 'Putar percobaan';

  @override
  String get comparePauseAttemptTooltip => 'Jeda percobaan';

  @override
  String get createWhatToday => 'Mau melakukan apa hari ini?';

  @override
  String get createPracticeVideo => 'Latihan Video';

  @override
  String get createYourMedia => 'Media Kamu';

  @override
  String get createTryAgain => 'Coba Lagi';

  @override
  String get createUploadedVideosEmptyHint =>
      'Video yang kamu unggah akan muncul di sini agar kamu bisa membukanya lagi dan berlatih kalimat demi kalimat.';

  @override
  String get createUploadingTips => 'Tips Mengunggah';

  @override
  String get createUploadingTipsBody =>
      'Buat audiomu di bawah 3 menit agar hasilnya maksimal. Subtitle yang jelas dibuat secara otomatis!';

  @override
  String get createOnThisIphone => 'Di iPhone Ini';

  @override
  String get createLocalVideosEmptyHint =>
      'Video yang kamu latih secara lokal akan disimpan di iPhone ini agar bisa dibuka lagi nanti tanpa transkripsi ulang.';

  @override
  String get createOnDeviceBadge => 'Di Perangkat';

  @override
  String get createSignInToLoadVideos =>
      'Masuk lagi untuk memuat video yang kamu unggah.';

  @override
  String createVideoMetaCues(int count) {
    return '$count kalimat';
  }

  @override
  String get createPublicBadge => 'Publik';

  @override
  String get createPrivateBadge => 'Pribadi';

  @override
  String get createAiBadge => 'AI';

  @override
  String get createDeleteSavedVideoTitle => 'Hapus Video Tersimpan?';

  @override
  String createDeleteSavedVideoBody(String title) {
    return 'Bantera akan menghapus \"$title\" dari iPhone ini beserta kalimat transkrip yang tersimpan.';
  }

  @override
  String get createDeleteMediaTitle => 'Hapus media?';

  @override
  String createDeleteMediaBody(String title) {
    return '\"$title\" dan transkripnya akan dihapus secara permanen. Tindakan ini tidak dapat dibatalkan.';
  }

  @override
  String get removeFromListTitle => 'Hapus dari daftar?';

  @override
  String get removeFromListBody =>
      'Item ini akan dihapus dari daftar dan tidak dapat dibatalkan.';

  @override
  String get editProfileChangeImage => 'Ganti Foto Profil';

  @override
  String get editProfileUploading => 'Mengunggah…';

  @override
  String get editProfileNameLabel => 'Nama';

  @override
  String get editProfileNameHint => 'Bagaimana Bantera menampilkan namamu?';

  @override
  String get editProfileSaveNameButton => 'Simpan Nama';

  @override
  String get editProfileSaving => 'Menyimpan…';

  @override
  String get editProfileLanguagesSection => 'Bahasa';

  @override
  String get editProfileMyNativeLanguage => 'Bahasa Ibu Saya';

  @override
  String get editProfileMyNativeLanguageSubtitle =>
      'Bahasa ibu atau bahasa pertamamu';

  @override
  String get editProfileLearningLanguage => 'Bahasa yang Dipelajari';

  @override
  String get editProfileLearningLanguageSubtitle =>
      'Bahasa yang ingin kamu latih';

  @override
  String get editProfileImageUpdated => 'Foto profil diperbarui.';

  @override
  String get editProfileNameUpdated => 'Nama diperbarui.';

  @override
  String get editProfileEnterName => 'Masukkan nama.';

  @override
  String get editProfileNameMaxLength => 'Gunakan maksimal 80 karakter.';

  @override
  String get editProfileCouldNotLoadLanguages =>
      'Tidak dapat memuat daftar bahasa.';

  @override
  String get languagePickerNone => 'Tidak ada';

  @override
  String get languagePickerClearSelection => 'Hapus pilihan';

  @override
  String get languagePickerNoMatchingLanguages => 'Bahasa tidak ditemukan.';

  @override
  String get languagePickerMoreComingSoon => 'Bahasa lainnya segera hadir';

  @override
  String get editProfileNativeLanguageCleared => 'Bahasa ibu dihapus.';

  @override
  String get editProfileLearningLanguageCleared =>
      'Bahasa yang dipelajari dihapus.';

  @override
  String editProfileNativeLanguageSetTo(String language) {
    return 'Bahasa ibu diatur ke $language.';
  }

  @override
  String editProfileLearningLanguageSetTo(String language) {
    return 'Bahasa yang dipelajari diatur ke $language.';
  }

  @override
  String get profileLanguageSettings => 'Pengaturan Bahasa';

  @override
  String get profileLearningLabel => 'Mempelajari';

  @override
  String get profileNotSet => 'Belum diatur';

  @override
  String get uploadedDetailYourAudio => 'Audio Kamu';

  @override
  String get uploadedDetailYourVideo => 'Video Kamu';

  @override
  String get uploadedDetailDeleteAudioTitle => 'Hapus audio?';

  @override
  String get uploadedDetailDeleteAudioBody =>
      'Audio dan transkripnya akan dihapus secara permanen. Tindakan ini tidak dapat dibatalkan.';

  @override
  String get uploadedDetailDeleteVideoTitle => 'Hapus video?';

  @override
  String get uploadedDetailDeleteVideoBody =>
      'Video dan transkripnya akan dihapus secara permanen. Tindakan ini tidak dapat dibatalkan.';

  @override
  String get uploadedDetailAiGenerated => 'Dibuat dengan AI';

  @override
  String get uploadedDetailFileSize => 'Ukuran file';

  @override
  String get uploadedDetailResolution => 'Resolusi';

  @override
  String get uploadedDetailResolutionUnknown => 'Tidak diketahui';

  @override
  String get uploadedDetailTranscribing => 'Mentranskripsi…';

  @override
  String get uploadedDetailNoTranscriptCuesYet =>
      'Belum ada kalimat transkrip.';

  @override
  String uploadedDetailMediaDescription(int count) {
    return 'Klip latihan unggahanmu dengan $count kalimat transkrip.';
  }

  @override
  String get uploadedDetailTranscriptionFailedFallback =>
      'Transkripsi gagal. Menggunakan kalimat perkiraan.';

  @override
  String get uploadedDetailTranscriptionNoCues =>
      'Transkripsi tidak menghasilkan kalimat apa pun.';

  @override
  String get uploadedDetailTranscriptionSourceYourUpload => 'Unggahanmu';

  @override
  String get aiGenLeaveTitle => 'Tinggalkan halaman ini?';

  @override
  String get aiGenLeaveBody =>
      'Audio masih dibuat. Jika keluar sekarang, prosesnya akan dibatalkan.';

  @override
  String get aiGenStay => 'Tetap di Sini';

  @override
  String get aiGenLeave => 'Tinggalkan';

  @override
  String get aiGenLoadingTitle => 'Membuat audiomu…';

  @override
  String get aiGenLoadingSubtitle =>
      'Ini bisa memakan waktu hingga satu menit.\nTetap di halaman ini selama proses berlangsung.';

  @override
  String get aiGenStepPreparingSpeechModel =>
      'Menyiapkan model ucapan di perangkat';

  @override
  String get aiGenStepWritingDialogue => 'Menulis dialog';

  @override
  String get aiGenStepGeneratingAudio => 'Membuat audio';

  @override
  String get aiGenStepAligningAudio => 'Menyelaraskan audio';

  @override
  String get aiGenStepTranscribing => 'Mentranskripsi';

  @override
  String get aiGenStepCorrectingTranscript => 'Mengoreksi transkrip';

  @override
  String get aiGenLanguageSection => 'Bahasa';

  @override
  String get aiGenSetLearningLanguagePrompt =>
      'Atur bahasa yang kamu pelajari untuk mengaktifkan pembuatan';

  @override
  String get aiGenLoadingLanguage => 'Memuat bahasa…';

  @override
  String aiGenLanguageUnsupported(String language) {
    return 'Bahasa \"$language\" tidak didukung untuk pembuatan.';
  }

  @override
  String get aiGenScenarioSection => 'Skenario';

  @override
  String get aiGenScenarioOptionalHint =>
      'Opsional — biarkan kosong untuk skenario acak.';

  @override
  String get aiGenCustomScenarioHint => 'Jelaskan skenariomu…';

  @override
  String get aiGenDurationSection => 'Durasi';

  @override
  String aiGenDurationMinutes(int minutes) {
    return '$minutes mnt';
  }

  @override
  String get aiGenGenerateButton => 'Buat';

  @override
  String get aiGenOwnershipNotice =>
      'Audio yang kamu buat di sini menjadi konten komunitas Bantera — dibagikan secara publik sebagai materi latihan untuk semua pelajar.';

  @override
  String get aiGenOwnershipCheckbox =>
      'Bagikan audio ini sebagai konten komunitas Bantera';

  @override
  String get aiGenOwnershipConfirmTitle => 'Bagikan sebagai konten komunitas?';

  @override
  String get aiGenOwnershipConfirmCancel => 'Batal';

  @override
  String get aiGenOwnershipConfirmGenerate => 'Buat';

  @override
  String get aiGenFooterNotice =>
      'AI akan menulis dialog dua pembicara dan mengubahnya menjadi audio. Hasilnya akan disimpan sebagai audio latihan publik.';

  @override
  String get aiScenarioCoffeeShop => 'Kedai kopi';

  @override
  String get aiScenarioLatestNews => 'Berita Terkini';

  @override
  String get aiScenarioAirportReunion => 'Bertemu lagi di bandara';

  @override
  String get aiScenarioGroceryStore => 'Toko kelontong';

  @override
  String get aiScenarioDoctorVisit => 'Periksa ke dokter';

  @override
  String get aiScenarioJobInterview => 'Wawancara kerja';

  @override
  String get aiScenarioNewNeighbour => 'Tetangga baru';

  @override
  String get aiScenarioTechSupport => 'Dukungan teknis';

  @override
  String get aiScenarioBirthdaySurprise => 'Kejutan ulang tahun';

  @override
  String get aiScenarioGymTips => 'Tips gym';

  @override
  String get aiScenarioWeatherSmalltalk => 'Obrolan soal cuaca';

  @override
  String get aiScenarioRestaurantOrder => 'Memesan di restoran';

  @override
  String get aiScenarioBookRecommendation => 'Rekomendasi buku';

  @override
  String get aiScenarioBusDelay => 'Bus terlambat';

  @override
  String get aiScenarioMovieDebate => 'Debat film';

  @override
  String get aiScenarioCustom => 'Kustom…';

  @override
  String get errorNetworkUnreachable =>
      'Tidak dapat terhubung ke Bantera. Periksa koneksi internetmu.';

  @override
  String get errorNetworkCellularBlocked =>
      'Data seluler untuk Bantera nonaktif. Di Pengaturan, buka Bantera dan aktifkan Data Seluler, atau sambungkan ke Wi-Fi.';

  @override
  String get errorTlsConnection => 'Tidak dapat membuat koneksi aman.';

  @override
  String get settingsRateAppPrompt =>
      'Suka dengan Bantera? Beri kami nilai di App Store, itu sangat berarti bagi kami.';

  @override
  String get settingsRateAppButton => 'Beri Nilai di App Store';

  @override
  String get settingsSharePrompt =>
      'Kenal seseorang yang sedang belajar bahasa? Bagikan Bantera kepada mereka.';

  @override
  String get settingsShareButton => 'Bagikan Bantera';

  @override
  String get settingsContactButton => 'Hubungi kami';

  @override
  String get localVideoDescription =>
      'Pilih video dari Foto, pilih bahasa yang diucapkan, lalu biarkan iPhone mentranskripsinya di latar belakang sebelum latihan kalimat demi kalimat.';

  @override
  String get localVideoStep1Title => '1. Pilih video';

  @override
  String get localVideoChooseFromPhotos => 'Pilih dari Foto';

  @override
  String get localVideoChooseDifferent => 'Pilih Video Lain';

  @override
  String get localVideoSelectedFileLabel => 'File yang dipilih';

  @override
  String get localVideoSizeLabel => 'Ukuran';

  @override
  String get localVideoDurationLabel => 'Durasi';

  @override
  String get localVideoLongVideoWarning =>
      'Video ini lebih dari 3 menit, jadi Bantera mungkin perlu waktu lebih lama untuk menyiapkan transkrip dan terjemahan.';

  @override
  String get localVideoStep2Title => '2. Bahasa transkripsi';

  @override
  String get localVideoChooseLanguagePlaceholder =>
      'Pilih bahasa yang diucapkan';

  @override
  String get localVideoLanguageHint =>
      'Bantera mengingat pilihan bahasa terakhirmu dan menyembunyikan transkripsi secara default saat latihan dimulai.';

  @override
  String get localVideoStep3Title => '3. Latihan';

  @override
  String get localVideoPreparing => 'Menyiapkan...';

  @override
  String get localVideoPracticeHint =>
      'Bantera mentranskripsi di perangkat terlebih dahulu, lalu membuka halaman latihan mendengar kalimat demi kalimat tanpa mengunggah apa pun.';

  @override
  String get localVideoStatusLongVideo =>
      'Video ini cukup panjang, jadi Bantera mungkin perlu waktu tambahan untuk mentranskripsi dan menyiapkannya.';

  @override
  String get localVideoStatusTranscribing =>
      'Mentranskripsi di perangkat dan menyiapkan kalimat latihan...';

  @override
  String get localVideoStatusSaving =>
      'Menyimpan video ini ke pustaka latihan di perangkatmu...';

  @override
  String get localVideoStatusTranslationLong =>
      'Transkripsi selesai. Bantera juga sedang menyiapkan terjemahan ke bahasa tersimpanmu, jadi video yang lebih panjang ini mungkin perlu sedikit waktu tambahan.';

  @override
  String get localVideoStatusTranslation =>
      'Transkripsi selesai. Menyiapkan terjemahan ke bahasa tersimpanmu...';

  @override
  String get localVideoPickerTitle => 'Pilih Bahasa Audio';

  @override
  String get savedCuesTitle => 'Kalimat Tersimpan';

  @override
  String get savedCuesEmpty =>
      'Belum ada kalimat tersimpan. Ketuk ikon penanda saat berlatih untuk menyimpan kalimat.';

  @override
  String get savedCuesDeleteTooltip => 'Hapus kalimat tersimpan';

  @override
  String get savedCuesDeleteConfirmTitle => 'Hapus kalimat ini?';

  @override
  String get savedCuesDeleteConfirmBody =>
      'Kalimat ini akan dihapus dari daftar tersimpanmu.';

  @override
  String get savedCuesDeleteAllTooltip => 'Hapus semua kalimat tersimpan';

  @override
  String get savedCuesDeleteAllConfirmTitle => 'Hapus semua kalimat tersimpan?';

  @override
  String get savedCuesDeleteAllConfirmBody =>
      'Semua kalimat tersimpan akan dihapus secara permanen.';

  @override
  String get updateAlertTitle => 'Pembaruan Tersedia';

  @override
  String get updateAlertMessage =>
      'Versi baru Bantera telah tersedia. Perbarui sekarang untuk mendapatkan fitur dan penyempurnaan terbaru.';

  @override
  String get updateCurrentVersionLabel => 'Versi saat ini';

  @override
  String get updateAppStoreVersionLabel => 'Versi App Store';

  @override
  String get updateAlertUpdate => 'Perbarui';

  @override
  String get updateAlertLater => 'Nanti';

  @override
  String get checkForUpdateButton => 'Periksa Pembaruan';

  @override
  String get upToDateAlertTitle => 'Sudah Terbaru';

  @override
  String upToDateAlertMessage(Object version) {
    return 'Bantera $version adalah versi terbaru.';
  }

  @override
  String get sectionSupport => 'Dukungan';

  @override
  String get permissionActionAllow => 'Izinkan';
}
