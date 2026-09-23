// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'Bantera';

  @override
  String get appTagline => 'Luyện ngôn ngữ, từng câu một.';

  @override
  String get authContinueWithApple => 'Tiếp tục với Apple';

  @override
  String get authContinueWithGoogle => 'Tiếp tục với Google';

  @override
  String get authAppleUnavailable =>
      'Đăng nhập bằng Apple không khả dụng trên thiết bị này.';

  @override
  String get authOrSignInEmail => 'hoặc đăng nhập bằng email';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Mật khẩu';

  @override
  String get authSigningIn => 'Đang đăng nhập...';

  @override
  String get authSignIn => 'Đăng nhập';

  @override
  String get authSignInWithEmail => 'Đăng nhập bằng email';

  @override
  String get validationEnterEmail => 'Nhập email của bạn.';

  @override
  String get validationValidEmail => 'Nhập email hợp lệ.';

  @override
  String get validationEnterPassword => 'Nhập mật khẩu của bạn.';

  @override
  String get onboardingTitle => 'Thiết lập hồ sơ';

  @override
  String get onboardingSubtitle =>
      'Giúp Bantera cá nhân hóa bài luyện và trò chuyện cho bạn.';

  @override
  String get onboardingNameTitle => 'Mọi người nên gọi bạn là gì?';

  @override
  String get onboardingNameSubtitle =>
      'Tên này được lấy từ tài khoản Apple của bạn (nếu có). Bạn có thể đổi ngay bây giờ.';

  @override
  String get onboardingClearName => 'Xóa tên';

  @override
  String get onboardingNativeLanguageTitle => 'Tiếng mẹ đẻ của bạn là gì?';

  @override
  String get onboardingNativeLanguageSubtitle =>
      'Bantera dùng thông tin này để dịch và xếp nhóm ngôn ngữ.';

  @override
  String get onboardingLearningLanguageTitle => 'Bạn đang học ngôn ngữ nào?';

  @override
  String get onboardingLearningLanguageSubtitle =>
      'Quyết định nội dung luyện tập và nhóm học của bạn.';

  @override
  String get onboardingAvatarTitle => 'Thêm ảnh hồ sơ';

  @override
  String get onboardingAvatarSubtitle =>
      'Chọn một ảnh, hoặc tiếp tục để Bantera tạo ảnh cho bạn.';

  @override
  String get onboardingAvatarGenderTitle => 'Tạo ảnh hồ sơ';

  @override
  String get onboardingAvatarGenderBody =>
      'Chọn cách Bantera tạo ảnh hồ sơ cho bạn. Lựa chọn này không được lưu lại mà chỉ dùng để tạo ảnh này.';

  @override
  String get onboardingAvatarGenderMale => 'Nam';

  @override
  String get onboardingAvatarGenderFemale => 'Nữ';

  @override
  String get onboardingChoosePhoto => 'Chọn ảnh';

  @override
  String get onboardingChangePhoto => 'Đổi ảnh';

  @override
  String get onboardingUseGeneratedAvatar => 'Dùng ảnh đại diện được tạo';

  @override
  String get onboardingUseCurrentPhoto => 'Dùng ảnh hiện tại';

  @override
  String get onboardingChooseLanguage => 'Chọn ngôn ngữ';

  @override
  String get onboardingBack => 'Quay lại';

  @override
  String get onboardingFinish => 'Hoàn tất';

  @override
  String get onboardingLoadingProfile => 'Đang tải hồ sơ...';

  @override
  String get onboardingSavingProfile => 'Đang lưu hồ sơ...';

  @override
  String get onboardingLoadFailed => 'Đã xảy ra lỗi. Vui lòng thử lại.';

  @override
  String get onboardingSearchHint => 'Tìm ngôn ngữ…';

  @override
  String get onboardingRetry => 'Thử lại';

  @override
  String get onboardingNoMatching => 'Không có ngôn ngữ phù hợp.';

  @override
  String get onboardingFailedSave => 'Không lưu được.';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get sectionAppearance => 'Giao diện';

  @override
  String get sectionAccount => 'Tài khoản';

  @override
  String get sectionRateAndShare => 'Đánh giá & Chia sẻ';

  @override
  String get sectionLanguage => 'Ngôn ngữ hiển thị';

  @override
  String get sectionPermissions => 'Quyền truy cập';

  @override
  String get sectionNotifications => 'Thông báo';

  @override
  String get languageSectionSubtitle =>
      'Chọn ngôn ngữ hiển thị của ứng dụng. Chọn Hệ thống để theo cài đặt thiết bị.';

  @override
  String get themeLabel => 'Chủ đề';

  @override
  String get themeLight => 'Sáng';

  @override
  String get themeDark => 'Tối';

  @override
  String get themeSystem => 'Hệ thống';

  @override
  String get languageEnglish => 'Tiếng Anh';

  @override
  String get languageChineseSimplified => 'Tiếng Trung (Giản thể)';

  @override
  String get languageKorean => 'Tiếng Hàn';

  @override
  String get languageJapanese => 'Tiếng Nhật';

  @override
  String get signedOutLabel => 'Đã đăng xuất';

  @override
  String get noActiveSession => 'Không có phiên Bantera nào đang hoạt động';

  @override
  String signedInWith(String provider) {
    return 'Đã đăng nhập bằng $provider';
  }

  @override
  String get editProfile => 'Sửa hồ sơ';

  @override
  String get more => 'Thêm';

  @override
  String get appPermissionsTitle => 'Quyền của ứng dụng';

  @override
  String get appPermissionsSubtitle =>
      'Xem các quyền Bantera sử dụng trên thiết bị này.';

  @override
  String get permissionsIntro =>
      'Bantera dùng các cài đặt thiết bị này để ghi âm, so sánh giọng nói và truy cập mạng.';

  @override
  String get permissionsOpenSettings => 'Mở Cài đặt iPhone';

  @override
  String get permissionsRefresh => 'Làm mới';

  @override
  String get permissionMicrophoneTitle => 'Micrô';

  @override
  String get permissionMicrophoneDescription =>
      'Ghi âm bài luyện và tin nhắn thoại.';

  @override
  String get permissionSpeechTitle => 'Nhận dạng lời nói';

  @override
  String get permissionSpeechDescription =>
      'Chép lời bản ghi luyện tập và tin nhắn thoại.';

  @override
  String get permissionMobileDataTitle => 'Dữ liệu di động';

  @override
  String get permissionMobileDataDescription =>
      'Dùng Bantera khi iPhone này không kết nối Wi-Fi.';

  @override
  String get permissionStatusAllowed => 'Đã cho phép';

  @override
  String get permissionStatusLimited => 'Giới hạn';

  @override
  String get permissionStatusNotAllowed => 'Không cho phép';

  @override
  String get permissionStatusUnknown => 'Không xác định';

  @override
  String get signOut => 'Đăng xuất';

  @override
  String get signOutDialogTitle => 'Đăng xuất?';

  @override
  String get signOutDialogBody =>
      'Bạn sẽ cần đăng nhập lại để sử dụng tài khoản.';

  @override
  String get cancel => 'Hủy';

  @override
  String get closeLabel => 'Đóng';

  @override
  String get navDiscover => 'Khám phá';

  @override
  String get navCreate => 'Tạo';

  @override
  String get navProfile => 'Hồ sơ';

  @override
  String get chatsTitle => 'Trò chuyện';

  @override
  String get chatNoChatsYet => 'Chưa có cuộc trò chuyện nào.';

  @override
  String get chatOnlineSection => 'Trực tuyến';

  @override
  String get chatDirectMessagesSection => 'Tin nhắn riêng';

  @override
  String chatAudioDuration(String duration) {
    return 'Âm thanh $duration';
  }

  @override
  String get chatEnableNotifications => 'Bật thông báo';

  @override
  String get chatMuteNotifications => 'Tắt thông báo';

  @override
  String get chatBlockUser => 'Chặn người dùng';

  @override
  String get chatDeleteDm => 'Xóa tin nhắn riêng';

  @override
  String get chatCall => 'Gọi';

  @override
  String get chatStartAudioCall => 'Gọi thoại';

  @override
  String get chatStartVideoCall => 'Gọi video';

  @override
  String get chatAudioCalling => 'Đang gọi thoại...';

  @override
  String get chatVideoCalling => 'Đang gọi video...';

  @override
  String get chatAudioIncoming => 'Cuộc gọi thoại đến';

  @override
  String get chatVideoIncoming => 'Cuộc gọi video đến';

  @override
  String get chatCallConnecting => 'Đang kết nối...';

  @override
  String get chatCallAccept => 'Chấp nhận';

  @override
  String get chatCallDecline => 'Từ chối';

  @override
  String get chatCallEnd => 'Kết thúc';

  @override
  String get chatCallMute => 'Tắt tiếng';

  @override
  String get chatCallUnmute => 'Bật tiếng';

  @override
  String get chatCallSpeaker => 'Loa ngoài';

  @override
  String get chatCallCamera => 'Camera';

  @override
  String get chatCallSwitchCamera => 'Đổi camera';

  @override
  String get chatCallIssueTitle => 'Sự cố cuộc gọi';

  @override
  String get chatCallMicrophoneDenied =>
      'Bantera cần quyền truy cập micrô để bắt đầu cuộc gọi.';

  @override
  String get chatCallMicrophoneSettings =>
      'Quyền truy cập micrô của Bantera đang tắt. Hãy mở Cài đặt và bật quyền này để gọi.';

  @override
  String get chatCallCameraDenied =>
      'Bantera cần quyền truy cập camera để bắt đầu cuộc gọi video.';

  @override
  String get chatCallCameraSettings =>
      'Quyền truy cập camera của Bantera đang tắt. Hãy mở Cài đặt và bật quyền này để gọi video.';

  @override
  String get chatCallBusy => 'Người dùng này đang trong một cuộc gọi khác.';

  @override
  String get chatCallUnavailable =>
      'Người dùng này hiện không thể nhận cuộc gọi.';

  @override
  String get chatCallNetworkRestricted =>
      'Mạng này không thể kết nối cuộc gọi. Hãy thử Wi-Fi hoặc mạng khác.';

  @override
  String get chatCallFailed => 'Không thể bắt đầu cuộc gọi. Vui lòng thử lại.';

  @override
  String get chatGroupReady => 'Nhóm này đã sẵn sàng nhận tin nhắn thoại.';

  @override
  String get chatHoldToStartDm =>
      'Nhấn giữ để ghi âm và bắt đầu nhắn tin riêng.';

  @override
  String get chatNoGroupAudio => 'Nhóm chưa có tin nhắn thoại nào.';

  @override
  String get chatNoDmAudio => 'Cuộc trò chuyện này chưa có tin nhắn thoại nào.';

  @override
  String get chatSendingAudio => 'Đang gửi âm thanh...';

  @override
  String get chatRecordingReleaseToSend => 'Đang ghi âm... thả tay để gửi';

  @override
  String get chatHoldToRecordAudio => 'Nhấn giữ để ghi âm';

  @override
  String get chatRecordingStatus => 'Đang ghi âm...';

  @override
  String get chatGroupLabel => 'Nhóm';

  @override
  String get chatNotificationsEnabledForDm =>
      'Đã bật thông báo cho cuộc trò chuyện này.';

  @override
  String get chatNotificationsMutedForDm =>
      'Đã tắt thông báo cho cuộc trò chuyện này.';

  @override
  String chatBlockUserTitle(String user) {
    return 'Chặn $user?';
  }

  @override
  String get chatBlockUserBody =>
      'Hai bạn sẽ không còn thấy nhau trong tin nhắn riêng và tin nhắn nhóm chung cho đến khi bỏ chặn.';

  @override
  String chatBlockUserSuccess(String user) {
    return 'Đã chặn $user.';
  }

  @override
  String get chatBlockUserFailed =>
      'Không thể chặn người dùng này. Vui lòng thử lại.';

  @override
  String get chatDeleteMessage => 'Xóa tin nhắn';

  @override
  String get chatDeleteMessageTitle => 'Xóa tin nhắn này?';

  @override
  String get chatDeleteMessageBody =>
      'Tin nhắn này sẽ bị xóa với mọi người trong cuộc trò chuyện. Không thể hoàn tác thao tác này.';

  @override
  String get chatDeleteMessageSuccess => 'Đã xóa tin nhắn';

  @override
  String get chatDeleteMessageFailed =>
      'Không thể xóa tin nhắn. Vui lòng thử lại.';

  @override
  String get chatDeleteDmTitle => 'Xóa cuộc trò chuyện này?';

  @override
  String get chatDeleteDmBody =>
      'Thao tác này chỉ xóa khỏi danh sách của bạn. Cuộc trò chuyện có thể xuất hiện lại khi có tin nhắn mới.';

  @override
  String get chatMicrophoneRequiredTitle => 'Cần quyền micrô';

  @override
  String get chatMicrophoneRequiredSettings =>
      'Bantera cần quyền truy cập micrô để ghi âm tin nhắn thoại. Hãy bật quyền này trong Cài đặt.';

  @override
  String get chatMicrophoneRequiredBody =>
      'Bantera cần quyền truy cập micrô để ghi âm tin nhắn thoại.';

  @override
  String get chatGroupNotReady => 'Nhóm này chưa sẵn sàng.';

  @override
  String get chatMessageAction => 'Nhắn tin';

  @override
  String get chatRetranscribe => 'Chép lời lại';

  @override
  String get chatTranscribe => 'Chép lời';

  @override
  String get chatTranscribingOnDevice => 'Đang chép lời trên iPhone này...';

  @override
  String get chatTranscriptionFailed => 'Chép lời thất bại. Hãy thử lại.';

  @override
  String get chatTranslate => 'Dịch';

  @override
  String get chatRetranslate => 'Dịch lại';

  @override
  String get chatTranslating => 'Đang dịch trên iPhone này...';

  @override
  String get chatTranslationFailed => 'Dịch thất bại. Vui lòng thử lại.';

  @override
  String get chatGroupSettingsTitle => 'Cài đặt nhóm';

  @override
  String get chatNotifications => 'Thông báo';

  @override
  String get chatBlockedUsersMenu => 'Người dùng bị chặn';

  @override
  String get chatBlockedUsersTitle => 'Người dùng bị chặn';

  @override
  String get chatBlockedPeople => 'Người bị chặn';

  @override
  String get chatNoBlockedUsers => 'Chưa chặn người dùng nào.';

  @override
  String get chatNoBlockedPeople => 'Chưa chặn ai.';

  @override
  String get chatUnblock => 'Bỏ chặn';

  @override
  String chatUnblockUserTitle(String user) {
    return 'Bỏ chặn $user?';
  }

  @override
  String get chatUnblockUserBody =>
      'Hai bạn có thể thấy lại nhau trong tin nhắn riêng và tin nhắn nhóm chung.';

  @override
  String get chatUnblockFailed =>
      'Không thể bỏ chặn người dùng này. Vui lòng thử lại.';

  @override
  String get chatNotificationsTitle => 'Thông báo trò chuyện';

  @override
  String get chatNotificationsSubtitle =>
      'Một công tắc chung cho tài khoản trên mọi thiết bị của bạn.';

  @override
  String get chatNotificationsDisabledTitle => 'Thông báo đang tắt';

  @override
  String get chatNotificationsDisabledSettings =>
      'Bật thông báo trong Cài đặt để nhận thông báo trò chuyện từ Bantera.';

  @override
  String get chatNotificationsDisabledBody =>
      'Bantera cần quyền gửi thông báo trước khi bật thông báo trò chuyện.';

  @override
  String get chatNotificationUpdateFailed =>
      'Không thể cập nhật thông báo trò chuyện. Vui lòng thử lại.';

  @override
  String get savedTitle => 'Nội dung đã lưu';

  @override
  String get generateWithAiTitle => 'Tạo bằng AI';

  @override
  String get practiceLocalVideoTitle => 'Luyện với video trên máy';

  @override
  String get uploadVideoTitle => 'Tải video lên';

  @override
  String get lessonDetailsTitle => 'Chi tiết bài học';

  @override
  String get accountMoreTitle => 'Thêm';

  @override
  String get deleteAccount => 'Xóa tài khoản';

  @override
  String get deleteAccountSubtitle =>
      'Xóa vĩnh viễn tài khoản và dữ liệu trên máy chủ';

  @override
  String get confirmDeletionTitle => 'Xác nhận xóa';

  @override
  String get deleteAccountImmediateBody =>
      'Tài khoản của bạn sẽ bị xóa ngay lập tức. Bạn sẽ cần tạo tài khoản mới để dùng lại Bantera.';

  @override
  String get deleteAccountConfirm => 'Xóa tài khoản';

  @override
  String get couldNotDeleteAccount =>
      'Không thể xóa tài khoản. Vui lòng thử lại.';

  @override
  String get deleteAccountQuestionTitle => 'Xóa tài khoản?';

  @override
  String get deleteAccountQuestionBody =>
      'Toàn bộ thông tin cá nhân và dữ liệu của bạn sẽ bị xóa vĩnh viễn khỏi máy chủ và không thể khôi phục.';

  @override
  String get typeDeleteLabel => 'Nhập \"DELETE\" để tiếp tục';

  @override
  String get continueLabel => 'Tiếp tục';

  @override
  String get confirmLabel => 'Xác nhận';

  @override
  String get deleteLabel => 'Xóa';

  @override
  String get removeFromListLabel => 'Xóa khỏi danh sách';

  @override
  String get startLabel => 'Bắt đầu';

  @override
  String get doneLabel => 'Xong';

  @override
  String get discoverSearchHint => 'Tìm tiêu đề hoặc lời thoại…';

  @override
  String get discoverNoMoreResults => 'Không còn kết quả';

  @override
  String get discoverSetLearningLanguagePrompt =>
      'Đặt ngôn ngữ đang học để xem nội dung tại đây';

  @override
  String discoverNoPublicContentInLanguage(String language) {
    return 'Chưa có nội dung công khai bằng $language';
  }

  @override
  String get discoverSetLanguageToDiscover =>
      'Đặt ngôn ngữ đang học để khám phá nội dung';

  @override
  String get mediaStartPractice => 'Bắt đầu luyện tập';

  @override
  String get mediaTranscript => 'Lời thoại';

  @override
  String mediaTranscriptLineCount(int count) {
    return '($count dòng)';
  }

  @override
  String get mediaShow => 'Hiện';

  @override
  String get mediaHide => 'Ẩn';

  @override
  String get mediaNoTranscriptAvailable => 'Không có lời thoại.';

  @override
  String get lessonSaveTooltip => 'Lưu';

  @override
  String get lessonUnsaveTooltip => 'Bỏ lưu';

  @override
  String get mediaKindAudio => 'Âm thanh';

  @override
  String get mediaKindVideo => 'Video';

  @override
  String get practiceNoCues => 'Không có câu nào';

  @override
  String get practiceTranslating => 'Đang dịch…';

  @override
  String get practiceShowTranscript => 'Hiện lời thoại';

  @override
  String get practiceTranslate => 'Dịch';

  @override
  String get practiceHideText => 'Ẩn chữ';

  @override
  String get practiceTextLabel => 'Chữ';

  @override
  String get practiceStop => 'Dừng';

  @override
  String get practicePlayAll => 'Nói đuổi';

  @override
  String get practiceCompare => 'So sánh';

  @override
  String get practiceRecord => 'Ghi âm';

  @override
  String get practiceStopRecording => 'Dừng';

  @override
  String get practiceRecords => 'Bản ghi';

  @override
  String get practiceRecordsLocalOnlyFooter =>
      'Các lượt thử chỉ được lưu trên thiết bị này và không được tải lên.';

  @override
  String get practiceRecordsEmpty =>
      'Chưa có lượt thử nào được lưu cho câu này.';

  @override
  String get practiceRecordingProcessError =>
      'Đã xảy ra lỗi khi xử lý bản ghi âm của bạn.';

  @override
  String get practiceStartOver => 'Bắt đầu lại';

  @override
  String get practiceTranscriptHidden => 'Đã ẩn lời thoại';

  @override
  String get practiceListenCarefully => 'Hãy nghe kỹ…';

  @override
  String get practiceTranslationUnavailableForCue =>
      'Hiện chưa có bản dịch cho câu này.';

  @override
  String get practiceChooseTranslationLanguageTitle => 'Chọn ngôn ngữ dịch';

  @override
  String get practiceChooseTranslationLanguageDescription =>
      'Bantera sẽ dịch bài luyện nghe sang ngôn ngữ này và lưu vào hồ sơ của bạn cho các lần sau.';

  @override
  String get practiceChangeTranslationLanguageTitle => 'Đổi ngôn ngữ dịch';

  @override
  String get practiceChangeTranslationLanguageDescription =>
      'Chọn ngôn ngữ mà Bantera sẽ dịch sang. Lựa chọn mới sẽ được lưu vào hồ sơ của bạn.';

  @override
  String get practiceConfirmTranslationLanguageTitle =>
      'Xác nhận ngôn ngữ dịch';

  @override
  String get practiceConfirmTranslationLanguageBody =>
      'Bantera sẽ lưu ngôn ngữ này vào hồ sơ của bạn và dùng làm ngôn ngữ dịch mặc định cho các bài luyện nghe sau này.';

  @override
  String get practiceCouldNotSaveTranslationLanguage =>
      'Bantera không thể lưu ngôn ngữ dịch của bạn.';

  @override
  String get practiceNoTranslationLanguagesFound =>
      'Bantera không tìm thấy ngôn ngữ dịch nào cho lời thoại này.';

  @override
  String get practicePlayAllTitle => 'Nói đuổi';

  @override
  String get practicePlayAllDescription =>
      'Khoảng dừng giữa các câu để nói đuổi:';

  @override
  String get practicePlayAllPauseZeroSeconds => '0 giây';

  @override
  String get practicePlayAllPauseOneSecondLabel => '1 giây';

  @override
  String get practicePlayAllPauseOneCuePlusOneSecond => '1 câu + 1 giây';

  @override
  String get practicePlayAllPauseOneCuePlusTwoSeconds => '1 câu + 2 giây';

  @override
  String get practicePlayAllTimesPerCueTitle => 'Số lần mỗi câu';

  @override
  String get practicePlayAllTimesOnce => '1×';

  @override
  String get practicePlayAllTimesTwice => '2×';

  @override
  String get practicePlayAllTimesThrice => '3×';

  @override
  String get practiceSearchLanguagesHint => 'Tìm ngôn ngữ';

  @override
  String get practiceTranslationInstalled => 'Đã cài đặt';

  @override
  String get practiceTranslationDownload => 'Tải về';

  @override
  String get practiceStartOverTitle => 'Bắt đầu lại?';

  @override
  String get practiceStartOverBody => 'Quay về câu đầu tiên?';

  @override
  String get practiceNextFromLastTitle => 'Đến câu đầu tiên?';

  @override
  String get practiceNextFromLastBody =>
      'Bạn đang ở câu cuối. Quay về câu đầu tiên?';

  @override
  String get practiceGoToFirstCue => 'Đến câu đầu tiên';

  @override
  String get practiceVideoOpenError =>
      'Không thể mở video đã chọn để luyện tập.';

  @override
  String get practiceAudioLoading => 'Đang tải âm thanh…';

  @override
  String practiceAudioLoadingPercent(int percent) {
    return 'Đang tải âm thanh $percent%';
  }

  @override
  String get practiceAudioError => 'Không thể tải âm thanh. Vui lòng thử lại.';

  @override
  String get compareRecordYourVersion => 'Ghi âm phiên bản của bạn';

  @override
  String compareTranscriptionLanguage(String locale) {
    return 'Ngôn ngữ chép lời: $locale';
  }

  @override
  String get compareOpenIphoneSettings => 'Mở Cài đặt iPhone';

  @override
  String get comparePauseAttempt => 'Tạm dừng lượt thử';

  @override
  String get comparePlayAttempt => 'Phát lượt thử';

  @override
  String get compareYourTranscribedAttempt => 'Lời chép từ lượt thử của bạn';

  @override
  String get compareHighlightHint =>
      'Những từ Bantera nhận dạng khác đi sẽ được tô sáng.';

  @override
  String get compareUncertainHint =>
      'Từ gạch chấm là từ Bantera nhận dạng được nhưng chưa chắc chắn — hãy kiểm tra lại phát âm.';

  @override
  String get compareTryAgain => 'Thử lại';

  @override
  String get compareDone => 'Xong';

  @override
  String get compareStatusTranscribing =>
      'Đang chép lời lượt thử của bạn trên iPhone…';

  @override
  String get compareStatusRecording => 'Đang ghi âm… Chạm lần nữa để dừng.';

  @override
  String get compareStatusSavedAttempt =>
      'Đang hiển thị lượt thử đã lưu của câu này. Bạn có thể phát lại hoặc thử lại.';

  @override
  String get compareStatusReplayOrRetry =>
      'Bạn có thể phát lại lượt thử này hoặc thử lại câu này.';

  @override
  String get compareStatusTapToRecord =>
      'Chạm để bắt đầu ghi âm phiên bản của bạn cho câu này.';

  @override
  String get compareCouldNotStartRecording =>
      'Bantera hiện không thể bắt đầu ghi âm.';

  @override
  String get compareCouldNotAccessRecording =>
      'Bantera không thể truy cập âm thanh đã ghi.';

  @override
  String get compareNoTranscriptGenerated =>
      'Không thể chép lời lượt thử này. Hãy thử lại gần micrô hơn.';

  @override
  String get compareRecentAttempts => 'Lượt thử gần đây';

  @override
  String get compareAttemptsFooterNote =>
      'Bantera lưu các lượt thử trên iPhone này để bạn theo dõi tiến bộ với cùng một câu.';

  @override
  String compareMatchedCount(int count) {
    return '$count khớp';
  }

  @override
  String compareDifferentCount(int count) {
    return '$count khác';
  }

  @override
  String compareMissingCount(int count) {
    return '$count thiếu';
  }

  @override
  String compareUncertainCount(int count) {
    return '$count chưa rõ';
  }

  @override
  String get compareMicrophoneDeniedPermanent =>
      'Quyền truy cập micrô của Bantera đang tắt. Mở Cài đặt iPhone > Bantera > Micrô và bật quyền này để ghi âm phiên bản của bạn.';

  @override
  String get compareMicrophoneDeniedRestricted =>
      'iPhone này đang hạn chế quyền truy cập micrô của Bantera. Hãy kiểm tra Thời gian sử dụng, quản lý thiết bị hoặc cài đặt hệ thống để bật quyền này.';

  @override
  String get compareMicrophoneDeniedDefault =>
      'Cần quyền micrô để ghi âm phiên bản của bạn. Nếu trước đó bạn đã bỏ qua lời nhắc, hãy mở Cài đặt iPhone > Bantera > Micrô và bật quyền này.';

  @override
  String get compareSpeechRecognitionDeniedPermanent =>
      'Quyền Nhận dạng lời nói của Bantera đang tắt. Mở Cài đặt iPhone > Bantera > Nhận dạng lời nói và bật quyền này để so sánh bản ghi âm.';

  @override
  String get compareSpeechRecognitionDeniedRestricted =>
      'iPhone này đang hạn chế Nhận dạng lời nói của Bantera. Hãy kiểm tra Thời gian sử dụng, quản lý thiết bị hoặc cài đặt hệ thống để bật quyền này.';

  @override
  String get compareSpeechRecognitionUnavailable =>
      'Nhận dạng lời nói hiện không khả dụng trên iPhone này.';

  @override
  String get compareSpeechRecognitionUnsupportedLocale =>
      'Nhận dạng lời nói không hỗ trợ ngôn ngữ luyện tập này trên iPhone này.';

  @override
  String get comparePlayAttemptTooltip => 'Phát lượt thử';

  @override
  String get comparePauseAttemptTooltip => 'Tạm dừng lượt thử';

  @override
  String get createWhatToday => 'Hôm nay bạn muốn làm gì?';

  @override
  String get createPracticeVideo => 'Luyện với video';

  @override
  String get createYourMedia => 'Nội dung của bạn';

  @override
  String get createTryAgain => 'Thử lại';

  @override
  String get createUploadedVideosEmptyHint =>
      'Video bạn tải lên sẽ hiển thị tại đây để bạn mở lại và luyện từng câu.';

  @override
  String get createUploadingTips => 'Mẹo tải lên';

  @override
  String get createUploadingTipsBody =>
      'Giữ âm thanh dưới 3 phút để đạt hiệu quả tốt nhất. Phụ đề rõ ràng được tạo tự động!';

  @override
  String get createOnThisIphone => 'Trên iPhone này';

  @override
  String get createLocalVideosEmptyHint =>
      'Video bạn luyện trên máy sẽ được lưu trên iPhone này để bạn mở lại sau mà không cần chép lời lại.';

  @override
  String get createOnDeviceBadge => 'Trên máy';

  @override
  String get createSignInToLoadVideos =>
      'Đăng nhập lại để tải các video bạn đã tải lên.';

  @override
  String createVideoMetaCues(int count) {
    return '$count câu';
  }

  @override
  String get createPublicBadge => 'Công khai';

  @override
  String get createPrivateBadge => 'Riêng tư';

  @override
  String get createAiBadge => 'AI';

  @override
  String get createDeleteSavedVideoTitle => 'Xóa video đã lưu?';

  @override
  String createDeleteSavedVideoBody(String title) {
    return 'Bantera sẽ xóa \"$title\" khỏi iPhone này cùng các câu lời thoại đã lưu.';
  }

  @override
  String get createDeleteMediaTitle => 'Xóa nội dung?';

  @override
  String createDeleteMediaBody(String title) {
    return 'Thao tác này sẽ xóa vĩnh viễn \"$title\" cùng lời thoại. Không thể hoàn tác.';
  }

  @override
  String get removeFromListTitle => 'Xóa khỏi danh sách?';

  @override
  String get removeFromListBody =>
      'Mục này sẽ bị xóa khỏi danh sách và không thể hoàn tác.';

  @override
  String get editProfileChangeImage => 'Đổi ảnh hồ sơ';

  @override
  String get editProfileUploading => 'Đang tải lên…';

  @override
  String get editProfileNameLabel => 'Tên';

  @override
  String get editProfileNameHint => 'Bantera nên hiển thị tên bạn thế nào?';

  @override
  String get editProfileSaveNameButton => 'Lưu tên';

  @override
  String get editProfileSaving => 'Đang lưu…';

  @override
  String get editProfileLanguagesSection => 'Ngôn ngữ';

  @override
  String get editProfileMyNativeLanguage => 'Tiếng mẹ đẻ';

  @override
  String get editProfileMyNativeLanguageSubtitle =>
      'Tiếng mẹ đẻ hoặc ngôn ngữ đầu tiên của bạn';

  @override
  String get editProfileLearningLanguage => 'Ngôn ngữ đang học';

  @override
  String get editProfileLearningLanguageSubtitle =>
      'Ngôn ngữ bạn muốn luyện tập';

  @override
  String get editProfileImageUpdated => 'Đã cập nhật ảnh hồ sơ.';

  @override
  String get editProfileNameUpdated => 'Đã cập nhật tên.';

  @override
  String get editProfileEnterName => 'Nhập tên.';

  @override
  String get editProfileNameMaxLength => 'Tối đa 80 ký tự.';

  @override
  String get editProfileCouldNotLoadLanguages =>
      'Không thể tải danh sách ngôn ngữ.';

  @override
  String get languagePickerNone => 'Không có';

  @override
  String get languagePickerClearSelection => 'Bỏ chọn';

  @override
  String get languagePickerNoMatchingLanguages =>
      'Không tìm thấy ngôn ngữ nào.';

  @override
  String get languagePickerMoreComingSoon => 'Sắp có thêm ngôn ngữ';

  @override
  String get editProfileNativeLanguageCleared => 'Đã xóa tiếng mẹ đẻ.';

  @override
  String get editProfileLearningLanguageCleared => 'Đã xóa ngôn ngữ đang học.';

  @override
  String editProfileNativeLanguageSetTo(String language) {
    return 'Đã đặt tiếng mẹ đẻ là $language.';
  }

  @override
  String editProfileLearningLanguageSetTo(String language) {
    return 'Đã đặt ngôn ngữ đang học là $language.';
  }

  @override
  String get profileLanguageSettings => 'Cài đặt ngôn ngữ';

  @override
  String get profileLearningLabel => 'Đang học';

  @override
  String get profileNotSet => 'Chưa đặt';

  @override
  String get uploadedDetailYourAudio => 'Âm thanh của bạn';

  @override
  String get uploadedDetailYourVideo => 'Video của bạn';

  @override
  String get uploadedDetailDeleteAudioTitle => 'Xóa âm thanh?';

  @override
  String get uploadedDetailDeleteAudioBody =>
      'Thao tác này sẽ xóa vĩnh viễn âm thanh cùng lời thoại. Không thể hoàn tác.';

  @override
  String get uploadedDetailDeleteVideoTitle => 'Xóa video?';

  @override
  String get uploadedDetailDeleteVideoBody =>
      'Thao tác này sẽ xóa vĩnh viễn video cùng lời thoại. Không thể hoàn tác.';

  @override
  String get uploadedDetailAiGenerated => 'Do AI tạo';

  @override
  String get uploadedDetailFileSize => 'Kích thước tệp';

  @override
  String get uploadedDetailResolution => 'Độ phân giải';

  @override
  String get uploadedDetailResolutionUnknown => 'Không xác định';

  @override
  String get uploadedDetailTranscribing => 'Đang chép lời…';

  @override
  String get uploadedDetailNoTranscriptCuesYet => 'Chưa có câu lời thoại nào.';

  @override
  String uploadedDetailMediaDescription(int count) {
    return 'Đoạn luyện tập bạn đã tải lên với $count câu lời thoại.';
  }

  @override
  String get uploadedDetailTranscriptionFailedFallback =>
      'Chép lời thất bại. Đang dùng các câu ước tính.';

  @override
  String get uploadedDetailTranscriptionNoCues =>
      'Kết quả chép lời không có câu nào.';

  @override
  String get uploadedDetailTranscriptionSourceYourUpload => 'Bạn tải lên';

  @override
  String get aiGenLeaveTitle => 'Rời khỏi trang này?';

  @override
  String get aiGenLeaveBody =>
      'Âm thanh vẫn đang được tạo. Rời đi bây giờ sẽ hủy quá trình này.';

  @override
  String get aiGenStay => 'Ở lại';

  @override
  String get aiGenLeave => 'Rời đi';

  @override
  String get aiGenLoadingTitle => 'Đang tạo âm thanh cho bạn…';

  @override
  String get aiGenLoadingSubtitle =>
      'Quá trình này có thể mất đến một phút.\nVui lòng ở lại trang này trong khi tạo.';

  @override
  String get aiGenStepPreparingSpeechModel =>
      'Chuẩn bị mô hình giọng nói trên máy';

  @override
  String get aiGenStepWritingDialogue => 'Viết hội thoại';

  @override
  String get aiGenStepGeneratingAudio => 'Tạo âm thanh';

  @override
  String get aiGenStepAligningAudio => 'Căn chỉnh âm thanh';

  @override
  String get aiGenStepTranscribing => 'Chép lời';

  @override
  String get aiGenStepCorrectingTranscript => 'Chỉnh sửa lời thoại';

  @override
  String get aiGenLanguageSection => 'Ngôn ngữ';

  @override
  String get aiGenSetLearningLanguagePrompt =>
      'Đặt ngôn ngữ đang học để bật tính năng tạo';

  @override
  String get aiGenLoadingLanguage => 'Đang tải ngôn ngữ…';

  @override
  String aiGenLanguageUnsupported(String language) {
    return 'Chưa hỗ trợ tạo nội dung bằng \"$language\".';
  }

  @override
  String get aiGenScenarioSection => 'Tình huống';

  @override
  String get aiGenScenarioOptionalHint =>
      'Không bắt buộc — để trống để chọn tình huống ngẫu nhiên.';

  @override
  String get aiGenCustomScenarioHint => 'Mô tả tình huống của bạn…';

  @override
  String get aiGenDurationSection => 'Thời lượng';

  @override
  String aiGenDurationMinutes(int minutes) {
    return '$minutes phút';
  }

  @override
  String get aiGenGenerateButton => 'Tạo';

  @override
  String get aiGenOwnershipNotice =>
      'Âm thanh bạn tạo tại đây sẽ trở thành nội dung cộng đồng Bantera — được chia sẻ công khai làm tài liệu luyện tập cho mọi người học.';

  @override
  String get aiGenOwnershipCheckbox =>
      'Chia sẻ âm thanh này làm nội dung cộng đồng Bantera';

  @override
  String get aiGenOwnershipConfirmTitle => 'Chia sẻ làm nội dung cộng đồng?';

  @override
  String get aiGenOwnershipConfirmCancel => 'Hủy';

  @override
  String get aiGenOwnershipConfirmGenerate => 'Tạo';

  @override
  String get aiGenFooterNotice =>
      'AI sẽ viết một đoạn hội thoại hai người và chuyển thành âm thanh. Kết quả sẽ được lưu thành âm thanh luyện tập công khai.';

  @override
  String get aiScenarioCoffeeShop => 'Quán cà phê';

  @override
  String get aiScenarioLatestNews => 'Tin tức mới nhất';

  @override
  String get aiScenarioAirportReunion => 'Đoàn tụ ở sân bay';

  @override
  String get aiScenarioGroceryStore => 'Cửa hàng tạp hóa';

  @override
  String get aiScenarioDoctorVisit => 'Đi khám bác sĩ';

  @override
  String get aiScenarioJobInterview => 'Phỏng vấn xin việc';

  @override
  String get aiScenarioNewNeighbour => 'Hàng xóm mới';

  @override
  String get aiScenarioTechSupport => 'Hỗ trợ kỹ thuật';

  @override
  String get aiScenarioBirthdaySurprise => 'Bất ngờ sinh nhật';

  @override
  String get aiScenarioGymTips => 'Mẹo tập gym';

  @override
  String get aiScenarioWeatherSmalltalk => 'Chuyện phiếm về thời tiết';

  @override
  String get aiScenarioRestaurantOrder => 'Gọi món ở nhà hàng';

  @override
  String get aiScenarioBookRecommendation => 'Gợi ý sách';

  @override
  String get aiScenarioBusDelay => 'Xe buýt đến trễ';

  @override
  String get aiScenarioMovieDebate => 'Tranh luận về phim';

  @override
  String get aiScenarioCustom => 'Tùy chỉnh…';

  @override
  String get errorNetworkUnreachable =>
      'Không thể kết nối với Bantera. Hãy kiểm tra kết nối Internet.';

  @override
  String get errorNetworkCellularBlocked =>
      'Dữ liệu di động đang tắt cho Bantera. Trong Cài đặt, hãy mở Bantera và bật Dữ liệu di động, hoặc kết nối Wi-Fi.';

  @override
  String get errorTlsConnection => 'Không thể thiết lập kết nối bảo mật.';

  @override
  String get settingsRateAppPrompt =>
      'Bạn thích Bantera? Một đánh giá nhanh trên App Store sẽ có ý nghĩa rất lớn với chúng tôi.';

  @override
  String get settingsRateAppButton => 'Đánh giá trên App Store';

  @override
  String get settingsSharePrompt =>
      'Bạn biết ai đang học ngoại ngữ? Hãy chia sẻ Bantera với họ.';

  @override
  String get settingsShareButton => 'Chia sẻ Bantera';

  @override
  String get settingsContactButton => 'Liên hệ với chúng tôi';

  @override
  String get localVideoDescription =>
      'Chọn video từ Ảnh, chọn ngôn ngữ nói, rồi để iPhone chép lời trong nền trước khi luyện từng câu.';

  @override
  String get localVideoStep1Title => '1. Chọn video';

  @override
  String get localVideoChooseFromPhotos => 'Chọn từ Ảnh';

  @override
  String get localVideoChooseDifferent => 'Chọn video khác';

  @override
  String get localVideoSelectedFileLabel => 'Tệp đã chọn';

  @override
  String get localVideoSizeLabel => 'Kích thước';

  @override
  String get localVideoDurationLabel => 'Thời lượng';

  @override
  String get localVideoLongVideoWarning =>
      'Video này dài hơn 3 phút nên Bantera có thể cần thêm thời gian để chuẩn bị lời thoại và bản dịch.';

  @override
  String get localVideoStep2Title => '2. Ngôn ngữ chép lời';

  @override
  String get localVideoChooseLanguagePlaceholder => 'Chọn ngôn ngữ nói';

  @override
  String get localVideoLanguageHint =>
      'Bantera ghi nhớ lựa chọn ngôn ngữ gần nhất của bạn và mặc định ẩn lời thoại khi bắt đầu luyện tập.';

  @override
  String get localVideoStep3Title => '3. Luyện tập';

  @override
  String get localVideoPreparing => 'Đang chuẩn bị...';

  @override
  String get localVideoPracticeHint =>
      'Bantera chép lời trên máy trước, rồi mở trang luyện nghe từng câu mà không tải lên bất cứ thứ gì.';

  @override
  String get localVideoStatusLongVideo =>
      'Đây là video dài nên Bantera có thể cần thêm thời gian để chép lời và chuẩn bị.';

  @override
  String get localVideoStatusTranscribing =>
      'Đang chép lời trên máy và chuẩn bị các câu luyện tập...';

  @override
  String get localVideoStatusSaving =>
      'Đang lưu video này vào thư viện luyện tập trên máy...';

  @override
  String get localVideoStatusTranslationLong =>
      'Đã chép lời xong. Bantera cũng đang chuẩn bị bản dịch sang ngôn ngữ bạn đã lưu, nên video dài này có thể mất thêm chút thời gian.';

  @override
  String get localVideoStatusTranslation =>
      'Đã chép lời xong. Đang chuẩn bị bản dịch sang ngôn ngữ bạn đã lưu...';

  @override
  String get localVideoPickerTitle => 'Chọn ngôn ngữ âm thanh';

  @override
  String get savedCuesTitle => 'Câu đã lưu';

  @override
  String get savedCuesEmpty =>
      'Chưa có câu nào được lưu. Chạm vào biểu tượng dấu trang khi luyện tập để lưu câu.';

  @override
  String get savedCuesDeleteTooltip => 'Xóa câu đã lưu';

  @override
  String get savedCuesDeleteConfirmTitle => 'Xóa câu này?';

  @override
  String get savedCuesDeleteConfirmBody =>
      'Câu này sẽ bị xóa khỏi danh sách đã lưu.';

  @override
  String get savedCuesDeleteAllTooltip => 'Xóa tất cả câu đã lưu';

  @override
  String get savedCuesDeleteAllConfirmTitle => 'Xóa tất cả câu đã lưu?';

  @override
  String get savedCuesDeleteAllConfirmBody =>
      'Tất cả câu đã lưu sẽ bị xóa vĩnh viễn.';

  @override
  String get updateAlertTitle => 'Có bản cập nhật';

  @override
  String get updateAlertMessage =>
      'Đã có phiên bản Bantera mới. Cập nhật ngay để dùng các tính năng và cải tiến mới nhất.';

  @override
  String get updateCurrentVersionLabel => 'Phiên bản hiện tại';

  @override
  String get updateAppStoreVersionLabel => 'Phiên bản trên App Store';

  @override
  String get updateAlertUpdate => 'Cập nhật';

  @override
  String get updateAlertLater => 'Để sau';

  @override
  String get checkForUpdateButton => 'Kiểm tra cập nhật';

  @override
  String get upToDateAlertTitle => 'Đã cập nhật';

  @override
  String upToDateAlertMessage(Object version) {
    return 'Bantera $version là phiên bản mới nhất.';
  }

  @override
  String get sectionSupport => 'Hỗ trợ';

  @override
  String get permissionActionAllow => 'Cho phép';
}
