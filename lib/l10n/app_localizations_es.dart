// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Bantera';

  @override
  String get appTagline => 'Practica idiomas, frase por frase.';

  @override
  String get authContinueWithApple => 'Continuar con Apple';

  @override
  String get authContinueWithGoogle => 'Continuar con Google';

  @override
  String get authAppleUnavailable =>
      'Iniciar sesión con Apple no está disponible en este dispositivo.';

  @override
  String get authOrSignInEmail => 'o inicia sesión con tu correo';

  @override
  String get authEmail => 'Correo electrónico';

  @override
  String get authPassword => 'Contraseña';

  @override
  String get authSigningIn => 'Iniciando sesión…';

  @override
  String get authSignIn => 'Iniciar sesión';

  @override
  String get authSignInWithEmail => 'Iniciar sesión con correo';

  @override
  String get validationEnterEmail => 'Ingresa tu correo electrónico.';

  @override
  String get validationValidEmail => 'Ingresa un correo válido.';

  @override
  String get validationEnterPassword => 'Ingresa tu contraseña.';

  @override
  String get onboardingTitle => 'Configura tu perfil';

  @override
  String get onboardingSubtitle =>
      'Esto ayuda a Bantera a personalizar tu práctica y tus chats.';

  @override
  String get onboardingNameTitle => '¿Cómo quieres que te llamen?';

  @override
  String get onboardingNameSubtitle =>
      'Lo completamos con los datos de tu cuenta que proporcionó Apple. Puedes cambiarlo ahora.';

  @override
  String get onboardingClearName => 'Borrar nombre';

  @override
  String get onboardingNativeLanguageTitle => '¿Cuál es tu idioma nativo?';

  @override
  String get onboardingNativeLanguageSubtitle =>
      'Bantera lo usa para las traducciones y los grupos de idioma.';

  @override
  String get onboardingLearningLanguageTitle =>
      '¿Qué idioma estás aprendiendo?';

  @override
  String get onboardingLearningLanguageSubtitle =>
      'Esto define el contenido de práctica y tus grupos de aprendizaje.';

  @override
  String get onboardingAvatarTitle => 'Agrega una foto de perfil';

  @override
  String get onboardingAvatarSubtitle =>
      'Elige una foto o continúa y Bantera generará una para ti.';

  @override
  String get onboardingAvatarGenderTitle => 'Genera tu foto de perfil';

  @override
  String get onboardingAvatarGenderBody =>
      'Elige cómo debe generar Bantera tu foto de perfil. No guardamos esta elección; solo se usa para esta imagen.';

  @override
  String get onboardingAvatarGenderMale => 'Hombre';

  @override
  String get onboardingAvatarGenderFemale => 'Mujer';

  @override
  String get onboardingChoosePhoto => 'Elegir foto';

  @override
  String get onboardingChangePhoto => 'Cambiar foto';

  @override
  String get onboardingUseGeneratedAvatar => 'Usar un avatar generado';

  @override
  String get onboardingUseCurrentPhoto => 'Usar la foto actual';

  @override
  String get onboardingChooseLanguage => 'Elegir idioma';

  @override
  String get onboardingBack => 'Atrás';

  @override
  String get onboardingFinish => 'Terminar';

  @override
  String get onboardingLoadingProfile => 'Cargando perfil…';

  @override
  String get onboardingSavingProfile => 'Guardando perfil…';

  @override
  String get onboardingLoadFailed => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get onboardingSearchHint => 'Buscar idiomas…';

  @override
  String get onboardingRetry => 'Reintentar';

  @override
  String get onboardingNoMatching => 'No hay idiomas que coincidan.';

  @override
  String get onboardingFailedSave => 'No se pudo guardar.';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get sectionAppearance => 'Apariencia';

  @override
  String get sectionAccount => 'Cuenta';

  @override
  String get sectionRateAndShare => 'Califica y comparte';

  @override
  String get sectionLanguage => 'Idioma de la app';

  @override
  String get sectionPermissions => 'Permisos';

  @override
  String get sectionNotifications => 'Notificaciones';

  @override
  String get languageSectionSubtitle =>
      'Elige el idioma de la app. Sistema usa la configuración de tu dispositivo.';

  @override
  String get themeLabel => 'Tema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageChineseSimplified => 'Chino (simplificado)';

  @override
  String get languageKorean => 'Coreano';

  @override
  String get languageJapanese => 'Japonés';

  @override
  String get signedOutLabel => 'Sesión cerrada';

  @override
  String get noActiveSession => 'No hay una sesión activa de Bantera';

  @override
  String signedInWith(String provider) {
    return 'Sesión iniciada con $provider';
  }

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get more => 'Más';

  @override
  String get appPermissionsTitle => 'Permisos de la app';

  @override
  String get appPermissionsSubtitle =>
      'Revisa los accesos que usa Bantera en este dispositivo.';

  @override
  String get permissionsIntro =>
      'Bantera usa estos ajustes del dispositivo para grabar, comparar tu pronunciación y conectarse a internet.';

  @override
  String get permissionsOpenSettings => 'Abrir Configuración del iPhone';

  @override
  String get permissionsRefresh => 'Actualizar';

  @override
  String get permissionMicrophoneTitle => 'Micrófono';

  @override
  String get permissionMicrophoneDescription =>
      'Graba tus intentos de práctica y mensajes de voz.';

  @override
  String get permissionSpeechTitle => 'Reconocimiento de voz';

  @override
  String get permissionSpeechDescription =>
      'Transcribe tus grabaciones de práctica y mensajes de voz.';

  @override
  String get permissionMobileDataTitle => 'Datos celulares';

  @override
  String get permissionMobileDataDescription =>
      'Usa Bantera cuando este iPhone no esté conectado a Wi-Fi.';

  @override
  String get permissionStatusAllowed => 'Permitido';

  @override
  String get permissionStatusLimited => 'Limitado';

  @override
  String get permissionStatusNotAllowed => 'No permitido';

  @override
  String get permissionStatusUnknown => 'Desconocido';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get signOutDialogTitle => '¿Cerrar sesión?';

  @override
  String get signOutDialogBody =>
      'Tendrás que volver a iniciar sesión para usar tu cuenta.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get closeLabel => 'Cerrar';

  @override
  String get navDiscover => 'Descubrir';

  @override
  String get navCreate => 'Crear';

  @override
  String get navProfile => 'Perfil';

  @override
  String get chatsTitle => 'Chats';

  @override
  String get chatNoChatsYet => 'Aún no tienes chats.';

  @override
  String get chatOnlineSection => 'En línea';

  @override
  String get chatDirectMessagesSection => 'MD';

  @override
  String chatAudioDuration(String duration) {
    return 'Audio $duration';
  }

  @override
  String get chatEnableNotifications => 'Activar notificaciones';

  @override
  String get chatMuteNotifications => 'Silenciar notificaciones';

  @override
  String get chatBlockUser => 'Bloquear usuario';

  @override
  String get chatDeleteDm => 'Eliminar MD';

  @override
  String get chatCall => 'Llamar';

  @override
  String get chatStartAudioCall => 'Llamada de voz';

  @override
  String get chatStartVideoCall => 'Videollamada';

  @override
  String get chatAudioCalling => 'Llamando…';

  @override
  String get chatVideoCalling => 'Videollamando…';

  @override
  String get chatAudioIncoming => 'Llamada de voz entrante';

  @override
  String get chatVideoIncoming => 'Videollamada entrante';

  @override
  String get chatCallConnecting => 'Conectando…';

  @override
  String get chatCallAccept => 'Aceptar';

  @override
  String get chatCallDecline => 'Rechazar';

  @override
  String get chatCallEnd => 'Colgar';

  @override
  String get chatCallMute => 'Silenciar';

  @override
  String get chatCallUnmute => 'Activar audio';

  @override
  String get chatCallSpeaker => 'Altavoz';

  @override
  String get chatCallCamera => 'Cámara';

  @override
  String get chatCallSwitchCamera => 'Cambiar';

  @override
  String get chatCallIssueTitle => 'Problema con la llamada';

  @override
  String get chatCallMicrophoneDenied =>
      'Bantera necesita acceso al micrófono para iniciar una llamada.';

  @override
  String get chatCallMicrophoneSettings =>
      'El acceso al micrófono está desactivado para Bantera. Abre Configuración y actívalo para hacer llamadas.';

  @override
  String get chatCallCameraDenied =>
      'Bantera necesita acceso a la cámara para iniciar una videollamada.';

  @override
  String get chatCallCameraSettings =>
      'El acceso a la cámara está desactivado para Bantera. Abre Configuración y actívalo para hacer videollamadas.';

  @override
  String get chatCallBusy => 'Este usuario ya está en otra llamada.';

  @override
  String get chatCallUnavailable =>
      'Este usuario no está disponible para llamadas en este momento.';

  @override
  String get chatCallNetworkRestricted =>
      'Esta red no puede conectar la llamada. Prueba con Wi-Fi u otra red.';

  @override
  String get chatCallFailed =>
      'No se pudo iniciar la llamada. Inténtalo de nuevo.';

  @override
  String get chatGroupReady => 'Este grupo está listo para mensajes de audio.';

  @override
  String get chatHoldToStartDm =>
      'Mantén presionado para grabar e iniciar el MD.';

  @override
  String get chatNoGroupAudio => 'Aún no hay audios en el grupo.';

  @override
  String get chatNoDmAudio => 'Aún no hay audios en este MD.';

  @override
  String get chatSendingAudio => 'Enviando audio…';

  @override
  String get chatRecordingReleaseToSend => 'Grabando… suelta para enviar';

  @override
  String get chatHoldToRecordAudio => 'Mantén presionado para grabar';

  @override
  String get chatRecordingStatus => 'Grabando…';

  @override
  String get chatGroupLabel => 'Grupo';

  @override
  String get chatNotificationsEnabledForDm =>
      'Notificaciones activadas para este MD.';

  @override
  String get chatNotificationsMutedForDm =>
      'Notificaciones silenciadas para este MD.';

  @override
  String chatBlockUserTitle(String user) {
    return '¿Bloquear a $user?';
  }

  @override
  String get chatBlockUserBody =>
      'Dejarán de verse en los MD y en los mensajes de grupos compartidos hasta que lo desbloquees.';

  @override
  String chatBlockUserSuccess(String user) {
    return 'Bloqueaste a $user.';
  }

  @override
  String get chatBlockUserFailed =>
      'No se pudo bloquear a este usuario. Inténtalo de nuevo.';

  @override
  String get chatDeleteMessage => 'Eliminar mensaje';

  @override
  String get chatDeleteMessageTitle => '¿Eliminar este mensaje?';

  @override
  String get chatDeleteMessageBody =>
      'Este mensaje se eliminará para todos en la conversación. Esta acción no se puede deshacer.';

  @override
  String get chatDeleteMessageSuccess => 'Mensaje eliminado';

  @override
  String get chatDeleteMessageFailed =>
      'No se pudo eliminar el mensaje. Inténtalo de nuevo.';

  @override
  String get chatDeleteDmTitle => '¿Eliminar este MD?';

  @override
  String get chatDeleteDmBody =>
      'Solo se quitará de tu lista. Un nuevo mensaje puede hacer que vuelva a aparecer.';

  @override
  String get chatMicrophoneRequiredTitle => 'Se requiere el micrófono';

  @override
  String get chatMicrophoneRequiredSettings =>
      'Bantera necesita acceso al micrófono para grabar audio en el chat. Actívalo en Configuración.';

  @override
  String get chatMicrophoneRequiredBody =>
      'Bantera necesita acceso al micrófono para grabar audio en el chat.';

  @override
  String get chatGroupNotReady => 'Este grupo aún no está listo.';

  @override
  String get chatMessageAction => 'Mensaje';

  @override
  String get chatRetranscribe => 'Volver a transcribir';

  @override
  String get chatTranscribe => 'Transcribir';

  @override
  String get chatTranscribingOnDevice => 'Transcribiendo en este iPhone…';

  @override
  String get chatTranscriptionFailed =>
      'Falló la transcripción. Inténtalo de nuevo.';

  @override
  String get chatTranslate => 'Traducir';

  @override
  String get chatRetranslate => 'Volver a traducir';

  @override
  String get chatTranslating => 'Traduciendo en este iPhone…';

  @override
  String get chatTranslationFailed =>
      'Falló la traducción. Inténtalo de nuevo.';

  @override
  String get chatGroupSettingsTitle => 'Configuración del grupo';

  @override
  String get chatNotifications => 'Notificaciones';

  @override
  String get chatBlockedUsersMenu => 'Usuarios bloqueados';

  @override
  String get chatBlockedUsersTitle => 'Usuarios bloqueados';

  @override
  String get chatBlockedPeople => 'Personas bloqueadas';

  @override
  String get chatNoBlockedUsers => 'Aún no has bloqueado a ningún usuario.';

  @override
  String get chatNoBlockedPeople => 'Aún no has bloqueado a nadie.';

  @override
  String get chatUnblock => 'Desbloquear';

  @override
  String chatUnblockUserTitle(String user) {
    return '¿Desbloquear a $user?';
  }

  @override
  String get chatUnblockUserBody =>
      'Podrán volver a verse en los MD y en los mensajes de grupos compartidos.';

  @override
  String get chatUnblockFailed =>
      'No se pudo desbloquear a este usuario. Inténtalo de nuevo.';

  @override
  String get chatNotificationsTitle => 'Notificaciones de chat';

  @override
  String get chatNotificationsSubtitle =>
      'Un solo interruptor para toda tu cuenta en todos tus dispositivos.';

  @override
  String get chatNotificationsDisabledTitle => 'Notificaciones desactivadas';

  @override
  String get chatNotificationsDisabledSettings =>
      'Activa las notificaciones en Configuración para recibir alertas de chat de Bantera.';

  @override
  String get chatNotificationsDisabledBody =>
      'Bantera necesita permiso de notificaciones para activar las alertas de chat.';

  @override
  String get chatNotificationUpdateFailed =>
      'No se pudieron actualizar las notificaciones de chat. Inténtalo de nuevo.';

  @override
  String get savedTitle => 'Contenido guardado';

  @override
  String get generateWithAiTitle => 'Generar con IA';

  @override
  String get practiceLocalVideoTitle => 'Practicar con video local';

  @override
  String get uploadVideoTitle => 'Subir video';

  @override
  String get lessonDetailsTitle => 'Detalles de la lección';

  @override
  String get accountMoreTitle => 'Más';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get deleteAccountSubtitle =>
      'Elimina permanentemente tu cuenta y tus datos del servidor';

  @override
  String get confirmDeletionTitle => 'Confirmar eliminación';

  @override
  String get deleteAccountImmediateBody =>
      'Tu cuenta se eliminará de inmediato. Tendrás que crear una cuenta nueva para volver a usar Bantera.';

  @override
  String get deleteAccountConfirm => 'Eliminar cuenta';

  @override
  String get couldNotDeleteAccount =>
      'No se pudo eliminar la cuenta. Inténtalo de nuevo.';

  @override
  String get deleteAccountQuestionTitle => '¿Eliminar cuenta?';

  @override
  String get deleteAccountQuestionBody =>
      'Toda tu información personal y tus datos se eliminarán permanentemente de nuestros servidores y no se podrán recuperar.';

  @override
  String get typeDeleteLabel => 'Escribe \"DELETE\" para continuar';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get confirmLabel => 'Confirmar';

  @override
  String get deleteLabel => 'Eliminar';

  @override
  String get removeFromListLabel => 'Quitar de la lista';

  @override
  String get startLabel => 'Empezar';

  @override
  String get doneLabel => 'Listo';

  @override
  String get discoverSearchHint => 'Buscar título o transcripción…';

  @override
  String get discoverNoMoreResults => 'No hay más resultados';

  @override
  String get discoverSetLearningLanguagePrompt =>
      'Elige el idioma que aprendes para ver contenido aquí';

  @override
  String discoverNoPublicContentInLanguage(String language) {
    return 'Aún no hay contenido público en $language';
  }

  @override
  String discoverNoPublicContentInLanguageAtLevel(
    String language,
    String level,
  ) {
    return 'Aún no hay contenido público en $language para el nivel $level';
  }

  @override
  String get discoverSetLanguageToDiscover =>
      'Elige un idioma de aprendizaje para descubrir contenido';

  @override
  String get mediaStartPractice => 'Empezar a practicar';

  @override
  String get mediaTranscript => 'Transcripción';

  @override
  String mediaTranscriptLineCount(int count) {
    return '($count líneas)';
  }

  @override
  String get mediaShow => 'Mostrar';

  @override
  String get mediaHide => 'Ocultar';

  @override
  String get mediaNoTranscriptAvailable => 'No hay transcripción disponible.';

  @override
  String get lessonSaveTooltip => 'Guardar';

  @override
  String get lessonUnsaveTooltip => 'Quitar de guardados';

  @override
  String get mediaKindAudio => 'Audio';

  @override
  String get mediaKindVideo => 'Video';

  @override
  String get practiceNoCues => 'Sin frases';

  @override
  String get practiceTranslating => 'Traduciendo…';

  @override
  String get practiceShowTranscript => 'Mostrar transcripción';

  @override
  String get practiceTranslate => 'Traducir';

  @override
  String get practiceHideText => 'Ocultar texto';

  @override
  String get practiceTextLabel => 'Texto';

  @override
  String get practiceStop => 'Detener';

  @override
  String get practicePlayAll => 'Shadowing';

  @override
  String get practiceCompare => 'Comparar';

  @override
  String get practiceRecord => 'Grabar';

  @override
  String get practiceStopRecording => 'Detener';

  @override
  String get practiceRecords => 'Grabaciones';

  @override
  String get practiceRecordsLocalOnlyFooter =>
      'Los intentos se guardan solo en este dispositivo y no se suben.';

  @override
  String get practiceRecordsEmpty =>
      'Aún no hay intentos guardados para esta frase.';

  @override
  String get practiceRecordingProcessError =>
      'Algo salió mal al procesar tu grabación.';

  @override
  String get practiceStartOver => 'Volver a empezar';

  @override
  String get practiceTranscriptHidden => 'Transcripción oculta';

  @override
  String get practiceListenCarefully => 'Escucha con atención…';

  @override
  String get practiceTranslationUnavailableForCue =>
      'La traducción de esta frase no está disponible en este momento.';

  @override
  String get practiceChooseTranslationLanguageTitle =>
      'Elige el idioma de traducción';

  @override
  String get practiceChooseTranslationLanguageDescription =>
      'Bantera traducirá la práctica de comprensión auditiva a este idioma y lo guardará en tu perfil para próximas sesiones.';

  @override
  String get practiceChangeTranslationLanguageTitle =>
      'Cambiar idioma de traducción';

  @override
  String get practiceChangeTranslationLanguageDescription =>
      'Elige el idioma al que Bantera debe traducir. Tu nueva elección se guardará en tu perfil.';

  @override
  String get practiceConfirmTranslationLanguageTitle =>
      'Confirmar idioma de traducción';

  @override
  String get practiceConfirmTranslationLanguageBody =>
      'Bantera guardará este idioma en tu perfil y lo usará como idioma de traducción predeterminado en tus próximas prácticas de comprensión auditiva.';

  @override
  String get practiceCouldNotSaveTranslationLanguage =>
      'Bantera no pudo guardar tu idioma de traducción.';

  @override
  String get practiceNoTranslationLanguagesFound =>
      'Bantera no encontró idiomas de traducción para esta transcripción.';

  @override
  String get practicePlayAllTitle => 'Shadowing';

  @override
  String get practicePlayAllDescription =>
      'Pausa entre frases para hacer shadowing:';

  @override
  String get practicePlayAllPauseZeroSeconds => '0 s';

  @override
  String get practicePlayAllPauseOneSecondLabel => '1 s';

  @override
  String get practicePlayAllPauseOneCuePlusOneSecond => '1 frase + 1 s';

  @override
  String get practicePlayAllPauseOneCuePlusTwoSeconds => '1 frase + 2 s';

  @override
  String get practicePlayAllTimesPerCueTitle => 'Veces por frase';

  @override
  String get practicePlayAllTimesOnce => '1×';

  @override
  String get practicePlayAllTimesTwice => '2×';

  @override
  String get practicePlayAllTimesThrice => '3×';

  @override
  String get practiceSearchLanguagesHint => 'Buscar idiomas';

  @override
  String get practiceTranslationInstalled => 'Instalado';

  @override
  String get practiceTranslationDownload => 'Descargar';

  @override
  String get practiceStartOverTitle => '¿Volver a empezar?';

  @override
  String get practiceStartOverBody => '¿Regresar a la primera frase?';

  @override
  String get practiceNextFromLastTitle => '¿Ir a la primera frase?';

  @override
  String get practiceNextFromLastBody =>
      'Estás en la última frase. ¿Quieres regresar a la primera?';

  @override
  String get practiceGoToFirstCue => 'Ir a la primera frase';

  @override
  String get practiceVideoOpenError =>
      'No se pudo abrir el video seleccionado para practicar.';

  @override
  String get practiceAudioLoading => 'Cargando audio…';

  @override
  String practiceAudioLoadingPercent(int percent) {
    return 'Cargando audio $percent%';
  }

  @override
  String get practiceAudioError =>
      'No se pudo cargar el audio. Inténtalo de nuevo.';

  @override
  String get compareRecordYourVersion => 'Graba tu versión';

  @override
  String compareTranscriptionLanguage(String locale) {
    return 'Idioma de transcripción: $locale';
  }

  @override
  String get compareOpenIphoneSettings => 'Abrir Configuración del iPhone';

  @override
  String get comparePauseAttempt => 'Pausar intento';

  @override
  String get comparePlayAttempt => 'Reproducir intento';

  @override
  String get compareYourTranscribedAttempt => 'Tu intento transcrito';

  @override
  String get compareHighlightHint =>
      'Las palabras que Bantera reconoció de forma distinta aparecen resaltadas.';

  @override
  String get compareUncertainHint =>
      'Las palabras punteadas se reconocieron, pero Bantera no estaba seguro: revisa tu pronunciación.';

  @override
  String get compareTryAgain => 'Reintentar';

  @override
  String get compareDone => 'Listo';

  @override
  String get compareStatusTranscribing =>
      'Transcribiendo tu intento en el iPhone…';

  @override
  String get compareStatusRecording => 'Grabando… Toca de nuevo para detener.';

  @override
  String get compareStatusSavedAttempt =>
      'Se muestra un intento guardado de esta frase. Puedes volver a escucharlo o intentarlo otra vez.';

  @override
  String get compareStatusReplayOrRetry =>
      'Puedes volver a escuchar este intento o repetir la frase.';

  @override
  String get compareStatusTapToRecord =>
      'Toca para empezar a grabar tu versión de esta frase.';

  @override
  String get compareCouldNotStartRecording =>
      'Bantera no pudo empezar a grabar en este momento.';

  @override
  String get compareCouldNotAccessRecording =>
      'Bantera no pudo acceder al audio grabado.';

  @override
  String get compareNoTranscriptGenerated =>
      'No se pudo generar una transcripción de este intento. Inténtalo de nuevo más cerca del micrófono.';

  @override
  String get compareRecentAttempts => 'Intentos recientes';

  @override
  String get compareAttemptsFooterNote =>
      'Bantera guarda tus intentos en este iPhone para que puedas ver tu progreso en la misma frase.';

  @override
  String compareMatchedCount(int count) {
    return '$count coinciden';
  }

  @override
  String compareDifferentCount(int count) {
    return '$count distintas';
  }

  @override
  String compareMissingCount(int count) {
    return '$count faltan';
  }

  @override
  String compareUncertainCount(int count) {
    return '$count poco claras';
  }

  @override
  String get compareMicrophoneDeniedPermanent =>
      'El acceso al micrófono está desactivado para Bantera. Abre Configuración del iPhone > Bantera > Micrófono y actívalo para grabar tu versión.';

  @override
  String get compareMicrophoneDeniedRestricted =>
      'Este iPhone está restringiendo el acceso al micrófono para Bantera. Revisa Tiempo en pantalla, la administración del dispositivo o la configuración del sistema para activarlo.';

  @override
  String get compareMicrophoneDeniedDefault =>
      'Se requiere permiso del micrófono para grabar tu versión. Si antes rechazaste la solicitud, abre Configuración del iPhone > Bantera > Micrófono y actívalo.';

  @override
  String get compareSpeechRecognitionDeniedPermanent =>
      'El acceso a Reconocimiento de voz está desactivado para Bantera. Abre Configuración del iPhone > Bantera > Reconocimiento de voz y actívalo para comparar tu grabación.';

  @override
  String get compareSpeechRecognitionDeniedRestricted =>
      'Este iPhone está restringiendo el Reconocimiento de voz para Bantera. Revisa Tiempo en pantalla, la administración del dispositivo o la configuración del sistema para activarlo.';

  @override
  String get compareSpeechRecognitionUnavailable =>
      'El Reconocimiento de voz no está disponible en este iPhone en este momento.';

  @override
  String get compareSpeechRecognitionUnsupportedLocale =>
      'El Reconocimiento de voz no está disponible para este idioma de práctica en este iPhone.';

  @override
  String get comparePlayAttemptTooltip => 'Reproducir intento';

  @override
  String get comparePauseAttemptTooltip => 'Pausar intento';

  @override
  String get createWhatToday => '¿Qué quieres hacer hoy?';

  @override
  String get createPracticeVideo => 'Practicar con video';

  @override
  String get createYourMedia => 'Tu contenido';

  @override
  String get createTryAgain => 'Reintentar';

  @override
  String get createUploadedVideosEmptyHint =>
      'Los videos que subas aparecerán aquí para que puedas volver a abrirlos y practicar frase por frase.';

  @override
  String get createUploadingTips => 'Consejos para subir';

  @override
  String get createUploadingTipsBody =>
      'Mantén tu audio por debajo de 3 minutos para una mejor experiencia. ¡Los subtítulos se generan automáticamente!';

  @override
  String get createOnThisIphone => 'En este iPhone';

  @override
  String get createLocalVideosEmptyHint =>
      'Los videos que practiques localmente se guardarán en este iPhone para que puedas volver a abrirlos sin transcribirlos de nuevo.';

  @override
  String get createOnDeviceBadge => 'En el dispositivo';

  @override
  String get createSignInToLoadVideos =>
      'Vuelve a iniciar sesión para cargar los videos que subiste.';

  @override
  String createVideoMetaCues(int count) {
    return '$count frases';
  }

  @override
  String get createPublicBadge => 'Público';

  @override
  String get createPrivateBadge => 'Privado';

  @override
  String get createAiBadge => 'IA';

  @override
  String get createDeleteSavedVideoTitle => '¿Eliminar video guardado?';

  @override
  String createDeleteSavedVideoBody(String title) {
    return 'Bantera quitará \"$title\" de este iPhone y eliminará las frases de su transcripción guardada.';
  }

  @override
  String get createDeleteMediaTitle => '¿Eliminar contenido?';

  @override
  String createDeleteMediaBody(String title) {
    return 'Se eliminarán permanentemente \"$title\" y su transcripción. Esta acción no se puede deshacer.';
  }

  @override
  String get removeFromListTitle => '¿Quitar de la lista?';

  @override
  String get removeFromListBody =>
      'Se quitará de la lista y esta acción no se puede deshacer.';

  @override
  String get editProfileChangeImage => 'Cambiar foto de perfil';

  @override
  String get editProfileUploading => 'Subiendo…';

  @override
  String get editProfileNameLabel => 'Nombre';

  @override
  String get editProfileNameHint => '¿Cómo debe mostrar Bantera tu nombre?';

  @override
  String get editProfileSaveNameButton => 'Guardar nombre';

  @override
  String get editProfileSaving => 'Guardando…';

  @override
  String get editProfileLanguagesSection => 'Idiomas';

  @override
  String get editProfileMyNativeLanguage => 'Mi idioma nativo';

  @override
  String get editProfileMyNativeLanguageSubtitle =>
      'Tu idioma nativo o primera lengua';

  @override
  String get editProfileLearningLanguage => 'Idioma que aprendo';

  @override
  String get editProfileLearningLanguageSubtitle =>
      'El idioma que quieres practicar';

  @override
  String get editProfileImageUpdated => 'Foto de perfil actualizada.';

  @override
  String get editProfileNameUpdated => 'Nombre actualizado.';

  @override
  String get editProfileEnterName => 'Ingresa un nombre.';

  @override
  String get editProfileNameMaxLength => 'Usa 80 caracteres o menos.';

  @override
  String get editProfileCouldNotLoadLanguages =>
      'No se pudo cargar la lista de idiomas.';

  @override
  String get languagePickerNone => 'Ninguno';

  @override
  String get languagePickerClearSelection => 'Borrar selección';

  @override
  String get languagePickerNoMatchingLanguages => 'No se encontraron idiomas.';

  @override
  String languagePickerTotals(int languages, int accents) {
    return '$languages idiomas · $accents acentos';
  }

  @override
  String get editProfileNativeLanguageCleared => 'Se borró el idioma nativo.';

  @override
  String get editProfileLearningLanguageCleared =>
      'Se borró el idioma de aprendizaje.';

  @override
  String editProfileNativeLanguageSetTo(String language) {
    return 'Idioma nativo: $language.';
  }

  @override
  String editProfileLearningLanguageSetTo(String language) {
    return 'Idioma de aprendizaje: $language.';
  }

  @override
  String get profileLanguageSettings => 'Configuración de idiomas';

  @override
  String get profileLearningLabel => 'Aprendiendo';

  @override
  String get profileNotSet => 'Sin configurar';

  @override
  String get uploadedDetailYourAudio => 'Tu audio';

  @override
  String get uploadedDetailYourVideo => 'Tu video';

  @override
  String get uploadedDetailDeleteAudioTitle => '¿Eliminar audio?';

  @override
  String get uploadedDetailDeleteAudioBody =>
      'Se eliminarán permanentemente el audio y su transcripción. Esta acción no se puede deshacer.';

  @override
  String get uploadedDetailDeleteVideoTitle => '¿Eliminar video?';

  @override
  String get uploadedDetailDeleteVideoBody =>
      'Se eliminarán permanentemente el video y su transcripción. Esta acción no se puede deshacer.';

  @override
  String get uploadedDetailAiGenerated => 'Generado con IA';

  @override
  String get uploadedDetailFileSize => 'Tamaño del archivo';

  @override
  String get uploadedDetailResolution => 'Resolución';

  @override
  String get uploadedDetailResolutionUnknown => 'Desconocida';

  @override
  String get uploadedDetailTranscribing => 'Transcribiendo…';

  @override
  String get uploadedDetailNoTranscriptCuesYet =>
      'Aún no hay frases de transcripción disponibles.';

  @override
  String uploadedDetailMediaDescription(int count) {
    return 'Tu clip de práctica subido con $count frases transcritas.';
  }

  @override
  String get uploadedDetailTranscriptionFailedFallback =>
      'Falló la transcripción. Se usarán frases estimadas.';

  @override
  String get uploadedDetailTranscriptionNoCues =>
      'La transcripción no devolvió ninguna frase.';

  @override
  String get uploadedDetailTranscriptionSourceYourUpload => 'Tu archivo subido';

  @override
  String get aiGenLeaveTitle => '¿Salir de esta página?';

  @override
  String get aiGenLeaveBody =>
      'El audio aún se está generando. Si sales ahora, se cancelará el proceso.';

  @override
  String get aiGenStay => 'Quedarme';

  @override
  String get aiGenLeave => 'Salir';

  @override
  String get aiGenLoadingTitle => 'Creando tu audio…';

  @override
  String get aiGenLoadingSubtitle => 'Esto puede tardar hasta un minuto.';

  @override
  String get aiGenStepPreparingSpeechModel =>
      'Preparando el modelo de voz en el dispositivo';

  @override
  String get aiGenStepWritingDialogue => 'Escribiendo el diálogo';

  @override
  String get aiGenStepGeneratingAudio => 'Generando el audio';

  @override
  String get aiGenStepAligningAudio => 'Sincronizando el audio';

  @override
  String get aiGenStepTranscribing => 'Transcribiendo';

  @override
  String get aiGenStepCorrectingTranscript => 'Corrigiendo la transcripción';

  @override
  String get aiGenLanguageSection => 'Idioma';

  @override
  String get aiGenSetLearningLanguagePrompt =>
      'Elige tu idioma de aprendizaje para poder generar';

  @override
  String get aiGenLoadingLanguage => 'Cargando idioma…';

  @override
  String aiGenLanguageUnsupported(String language) {
    return 'El idioma \"$language\" no es compatible con la generación.';
  }

  @override
  String get aiGenScenarioSection => 'Situación';

  @override
  String get aiGenScenarioOptionalHint =>
      'Opcional: si no eliges ninguna, se usará una situación al azar.';

  @override
  String get aiGenCustomScenarioHint => 'Describe tu situación…';

  @override
  String get aiGenDurationSection => 'Duración';

  @override
  String aiGenDurationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get aiGenGenerateButton => 'Generar';

  @override
  String get aiGenOwnershipNotice =>
      'El audio que generes aquí se convierte en contenido de la comunidad de Bantera y se comparte públicamente como material de práctica para todos.';

  @override
  String get aiGenOwnershipCheckbox =>
      'Compartir este audio como contenido de la comunidad de Bantera';

  @override
  String get aiGenOwnershipConfirmTitle =>
      '¿Compartir como contenido de la comunidad?';

  @override
  String get aiGenOwnershipConfirmCancel => 'Cancelar';

  @override
  String get aiGenOwnershipConfirmGenerate => 'Generar';

  @override
  String get aiGenFooterNotice =>
      'La IA escribirá un diálogo entre dos personas y lo convertirá en audio. El resultado se guardará como audio de práctica público.';

  @override
  String get aiScenarioCoffeeShop => 'Cafetería';

  @override
  String get aiScenarioLatestNews => 'Últimas noticias';

  @override
  String get aiScenarioAirportReunion => 'Reencuentro en el aeropuerto';

  @override
  String get aiScenarioGroceryStore => 'Supermercado';

  @override
  String get aiScenarioDoctorVisit => 'Consulta médica';

  @override
  String get aiScenarioJobInterview => 'Entrevista de trabajo';

  @override
  String get aiScenarioNewNeighbour => 'Nuevo vecino';

  @override
  String get aiScenarioTechSupport => 'Soporte técnico';

  @override
  String get aiScenarioBirthdaySurprise => 'Sorpresa de cumpleaños';

  @override
  String get aiScenarioGymTips => 'Consejos de gimnasio';

  @override
  String get aiScenarioWeatherSmalltalk => 'Charla sobre el clima';

  @override
  String get aiScenarioRestaurantOrder => 'Pedir en un restaurante';

  @override
  String get aiScenarioBookRecommendation => 'Recomendación de libros';

  @override
  String get aiScenarioBusDelay => 'Retraso del autobús';

  @override
  String get aiScenarioMovieDebate => 'Debate sobre películas';

  @override
  String get aiScenarioCustom => 'Personalizada…';

  @override
  String get errorNetworkUnreachable =>
      'No se pudo conectar con Bantera. Revisa tu conexión a internet.';

  @override
  String get errorNetworkCellularBlocked =>
      'Los datos celulares están desactivados para Bantera. En Configuración, abre Bantera y activa Datos celulares, o conéctate a una red Wi-Fi.';

  @override
  String get errorTlsConnection => 'No se pudo establecer una conexión segura.';

  @override
  String get settingsRateAppPrompt =>
      '¿Te gusta Bantera? Una calificación rápida en el App Store significa mucho para nosotros.';

  @override
  String get settingsRateAppButton => 'Calificar en el App Store';

  @override
  String get settingsSharePrompt =>
      '¿Conoces a alguien que esté aprendiendo un idioma? Comparte Bantera.';

  @override
  String get settingsShareButton => 'Compartir Bantera';

  @override
  String get settingsContactButton => 'Contáctanos';

  @override
  String get localVideoDescription =>
      'Elige un video de Fotos y el idioma hablado; el iPhone lo transcribirá en segundo plano antes de que practiques frase por frase.';

  @override
  String get localVideoStep1Title => '1. Elige un video';

  @override
  String get localVideoChooseFromPhotos => 'Elegir de Fotos';

  @override
  String get localVideoChooseDifferent => 'Elegir otro video';

  @override
  String get localVideoSelectedFileLabel => 'Archivo seleccionado';

  @override
  String get localVideoSizeLabel => 'Tamaño';

  @override
  String get localVideoDurationLabel => 'Duración';

  @override
  String get localVideoLongVideoWarning =>
      'Este video dura más de 3 minutos, así que Bantera podría tardar más en preparar la transcripción y la traducción.';

  @override
  String get localVideoStep2Title => '2. Idioma de transcripción';

  @override
  String get localVideoChooseLanguagePlaceholder => 'Elige el idioma hablado';

  @override
  String get localVideoLanguageHint =>
      'Bantera recuerda tu último idioma elegido y mantiene oculta la transcripción por defecto al empezar la práctica.';

  @override
  String get localVideoStep3Title => '3. Practica';

  @override
  String get localVideoPreparing => 'Preparando…';

  @override
  String get localVideoPracticeHint =>
      'Bantera primero transcribe en el dispositivo y luego abre la práctica de escucha frase por frase, sin subir nada.';

  @override
  String get localVideoStatusLongVideo =>
      'Este video es largo, así que Bantera podría necesitar más tiempo para transcribirlo y prepararlo.';

  @override
  String get localVideoStatusTranscribing =>
      'Transcribiendo en el dispositivo y preparando las frases de práctica…';

  @override
  String get localVideoStatusSaving =>
      'Guardando este video en tu biblioteca de práctica del dispositivo…';

  @override
  String get localVideoStatusTranslationLong =>
      'Transcripción terminada. Bantera también está preparando la traducción a tu idioma guardado, así que este video largo podría tardar un poco más.';

  @override
  String get localVideoStatusTranslation =>
      'Transcripción terminada. Preparando la traducción a tu idioma guardado…';

  @override
  String get localVideoPickerTitle => 'Elegir idioma del audio';

  @override
  String get savedCuesTitle => 'Frases guardadas';

  @override
  String get savedCuesEmpty =>
      'Aún no tienes frases guardadas. Toca el ícono de marcador mientras practicas para guardar una frase.';

  @override
  String get savedCuesDeleteTooltip => 'Quitar frase guardada';

  @override
  String get savedCuesDeleteConfirmTitle => '¿Quitar esta frase?';

  @override
  String get savedCuesDeleteConfirmBody =>
      'Esta frase se quitará de tu lista de guardados.';

  @override
  String get savedCuesDeleteAllTooltip => 'Eliminar todas las frases guardadas';

  @override
  String get savedCuesDeleteAllConfirmTitle =>
      '¿Eliminar todas las frases guardadas?';

  @override
  String get savedCuesDeleteAllConfirmBody =>
      'Todas las frases guardadas se eliminarán permanentemente.';

  @override
  String get updateAlertTitle => 'Actualización disponible';

  @override
  String get updateAlertMessage =>
      'Hay una nueva versión de Bantera disponible. Actualiza ahora para obtener las funciones y mejoras más recientes.';

  @override
  String get updateCurrentVersionLabel => 'Versión actual';

  @override
  String get updateAppStoreVersionLabel => 'Versión en el App Store';

  @override
  String get updateAlertUpdate => 'Actualizar';

  @override
  String get updateAlertLater => 'Más tarde';

  @override
  String get checkForUpdateButton => 'Buscar actualizaciones';

  @override
  String get upToDateAlertTitle => 'Todo al día';

  @override
  String upToDateAlertMessage(Object version) {
    return 'Bantera $version es la versión más reciente.';
  }

  @override
  String get sectionSupport => 'Soporte';

  @override
  String get permissionActionAllow => 'Permitir';

  @override
  String get audioLevelBeginner => 'Principiante';

  @override
  String get audioLevelIntermediate => 'Intermedio';

  @override
  String get audioLevelAdvanced => 'Avanzado';

  @override
  String get audioLevelAll => 'Todos los niveles';

  @override
  String get audioLevelSelect => 'Seleccionar nivel';

  @override
  String get audioLevelSection => 'Nivel';

  @override
  String get audioLevelRequired =>
      'Selecciona un nivel antes de generar el audio.';

  @override
  String get wordActivityTitle => 'Mis logros';

  @override
  String get wordActivityToday => 'Hoy';

  @override
  String get wordActivityThisWeek => 'Esta semana';

  @override
  String get wordActivityTotal => 'Total';

  @override
  String get wordActivityListened => 'Palabras escuchadas';

  @override
  String get wordActivitySpoken => 'Palabras habladas';

  @override
  String get wordActivityHint =>
      'Estimación basada en transcripciones. Las repeticiones vuelven a contar.';

  @override
  String get dailyGoalTitle => 'Meta diaria';

  @override
  String get dailyGoalSet => 'Establecer meta diaria';

  @override
  String get dailyGoalEdit => 'Editar meta';

  @override
  String get dailyGoalChoose => 'Elige tu meta diaria';

  @override
  String dailyGoalPreset(String minutes) {
    return '$minutes min al día';
  }

  @override
  String get dailyGoalCustom => 'Personalizada';

  @override
  String get dailyGoalListeningTarget => 'Palabras escuchadas al día';

  @override
  String get dailyGoalSpeakingTarget => 'Palabras habladas al día';

  @override
  String dailyGoalEstimate(String minutes) {
    return 'Unos $minutes min';
  }

  @override
  String dailyGoalTimeTotal(String minutes) {
    return 'Unos $minutes min en total';
  }

  @override
  String get dailyGoalTimeHint =>
      'Estimación: 120 palabras escuchadas y 60 habladas por minuto. Las pausas y tu ritmo pueden requerir más tiempo. Las metas se guardan en este dispositivo para tu cuenta.';

  @override
  String get dailyGoalValidation =>
      'Introduce un entero entre 0 y 100.000. Usa 0 para no tener meta.';

  @override
  String get dailyGoalRemove => 'Eliminar meta';

  @override
  String get dailyGoalRemoveConfirmation =>
      '¿Eliminar tu objetivo diario y sus recordatorios? Tus recuentos de palabras se conservarán.';

  @override
  String get dailyGoalReached => 'Metas de hoy alcanzadas';

  @override
  String dailyGoalProgress(String count, String target) {
    return '$count/$target palabras';
  }

  @override
  String get dailyGoalSaveFailed =>
      'No se pudo guardar la meta. Inténtalo de nuevo.';

  @override
  String get wordActivityShare => 'Compartir';

  @override
  String get wordActivityPreview => 'Vista previa';

  @override
  String wordActivityShareHeading(String language) {
    return 'Dilo.\nEn voz alta.';
  }

  @override
  String get wordActivitySavePhotos => 'Guardar en Fotos';

  @override
  String get wordActivitySaved => 'Guardado en Fotos';

  @override
  String get wordActivitySaveFailed =>
      'No se pudo guardar la imagen. Inténtalo de nuevo.';

  @override
  String get wordActivityShareFailed =>
      'No se pudo compartir la imagen. Inténtalo de nuevo.';

  @override
  String get wordActivityPhotoPermission =>
      'Permite a Bantera añadir fotos en Ajustes e inténtalo de nuevo.';

  @override
  String get wordActivityScanToJoin => 'Escanea y practica';

  @override
  String get dailyGoalNoRequirement => 'Sin requisito de meta';

  @override
  String wordActivityLearningLanguage(String language) {
    return 'Aprendiendo $language';
  }

  @override
  String get wordActivityLegacyLabel =>
      'Actividad anterior (idioma desconocido)';

  @override
  String get saveLabel => 'Guardar';

  @override
  String get wordActivityShareToNativeGroup => 'Compartir al grupo nativo';

  @override
  String get wordActivitySentToGroup => 'Compartido en el grupo';

  @override
  String get dailyGoalNotificationLabel => 'Recordatorio del objetivo diario';

  @override
  String get dailyGoalNotificationHint =>
      'Recordarme si no he completado mis objetivos diarios. Usa mi zona horaria.';

  @override
  String get dailyGoalReminderTitle => 'Practica un poco más hoy';

  @override
  String get dailyGoalReminderBody =>
      'Aún no has completado tus objetivos diarios. Sigue escuchando y hablando.';

  @override
  String get dailyGoalNotificationTime => 'Hora del recordatorio';

  @override
  String get dailyGoalRepeatLabel => 'Repetir';

  @override
  String get dailyGoalRepeatNever => 'Nunca';

  @override
  String get dailyGoalRepeatEveryDay => 'Todos los días';

  @override
  String get dailyGoalRepeatWeekdays => 'Entre semana';

  @override
  String get dailyGoalRepeatWeekends => 'Fin de semana';

  @override
  String get dailyGoalRepeatOnceHint =>
      'Un recordatorio a la próxima hora elegida, sin repetición.';

  @override
  String get discoverAllAccents => 'Todos los acentos';

  @override
  String get wordActivityShareToday => 'Práctica de hoy';

  @override
  String get wordActivityShareSpokenToday => 'Hoy dije';

  @override
  String wordActivityShareWordUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'palabras',
      one: 'palabra',
    );
    return '$_temp0';
  }

  @override
  String wordActivityShareListened(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'También escuché $countString palabras',
      one: 'También escuché $countString palabra',
    );
    return '$_temp0';
  }

  @override
  String get wordActivityShareEncouragement => 'Cada palabra que dices cuenta.';

  @override
  String get wordActivityShareInvitation => 'Practiquemos. Atrévete a hablar.';

  @override
  String wordActivityListeningSummary(
    String period,
    String progress,
    int count,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hoy escuché $progress palabras',
      one: 'Hoy escuché $progress palabra',
    );
    String _temp1 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Esta semana escuché $progress palabras',
      one: 'Esta semana escuché $progress palabra',
    );
    String _temp2 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'En total escuché $progress palabras',
      one: 'En total escuché $progress palabra',
    );
    String _temp3 = intl.Intl.selectLogic(period, {
      'today': '$_temp0',
      'week': '$_temp1',
      'other': '$_temp2',
    });
    return '$_temp3';
  }

  @override
  String wordActivitySpeakingSummary(
    String period,
    String progress,
    int count,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hoy dije $progress palabras',
      one: 'Hoy dije $progress palabra',
    );
    String _temp1 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Esta semana dije $progress palabras',
      one: 'Esta semana dije $progress palabra',
    );
    String _temp2 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'En total dije $progress palabras',
      one: 'En total dije $progress palabra',
    );
    String _temp3 = intl.Intl.selectLogic(period, {
      'today': '$_temp0',
      'week': '$_temp1',
      'other': '$_temp2',
    });
    return '$_temp3';
  }

  @override
  String get wordActivityListening => 'Escucha';

  @override
  String get wordActivitySpeaking => 'Habla';

  @override
  String get wordActivityTrend => 'Tu práctica en el tiempo';

  @override
  String get wordActivitySevenDays => '7 días';

  @override
  String get wordActivityThirtyDays => '30 días';

  @override
  String get wordActivityWords => 'Palabras';

  @override
  String get wordActivityTrendEmpty =>
      'Aún no hay práctica registrada en este período.';

  @override
  String get wordActivityAllTime => 'Todo';

  @override
  String get profileLibraryTitle => 'Tu biblioteca de práctica';

  @override
  String get practiceHistoryTitle => 'Historial de práctica';

  @override
  String get practiceHistorySubtitle =>
      'Consulta tu progreso y retoma la práctica';

  @override
  String get profileSavedMediaSubtitle => 'Tus audios y vídeos guardados';

  @override
  String get profileSavedCuesSubtitle =>
      'Repasa las frases que quieres practicar';

  @override
  String practiceHistoryProgress(String completed, String total) {
    return '$completed/$total fragmentos escuchados';
  }

  @override
  String get practiceHistoryEmpty => 'Tu próxima práctica empieza aquí';

  @override
  String get practiceHistoryDeviceNote =>
      'Practica una lección para ver tu progreso aquí. El historial se guarda en este dispositivo.';

  @override
  String get practiceHistoryRemoveBody =>
      '¿Eliminar esta lección del historial y restablecer su progreso y punto de reanudación? Se conservarán tus medios, frases guardadas y recuentos de palabras.';

  @override
  String get practiceHistoryUnavailable =>
      'Este contenido ya no está en el dispositivo. Puedes eliminarlo del historial.';

  @override
  String get aiClearHistory => 'Borrar historial';

  @override
  String get aiClearHistoryBody =>
      '¿Eliminar los mensajes, audios y recuerdos de conversación de la IA en este dispositivo? Se terminará la llamada. Tu biblioteca, perfil y llamadas programadas se conservarán.';

  @override
  String get aiLocalHistory =>
      'El historial de IA recibido queda en este dispositivo. Se envía contexto relevante a la IA para responder. Los horarios y notas de recordatorios se guardan en el servidor. El audio se conserva hasta recibirlo o cancelarlo, como máximo siete días.';

  @override
  String get aiSayingGoodbye => 'Despidiéndose';

  @override
  String get aiSend => 'Enviar';

  @override
  String get aiPlayAudio => 'Reproducir audio';

  @override
  String get aiWelcome =>
      'Tu compañero para practicar idiomas. Envía un mensaje de voz o inicia una llamada de audio de nueve minutos.';

  @override
  String get aiChatSubtitle => 'Mensajes de voz y llamadas de audio';

  @override
  String get aiRecordVoiceMessage => 'Grabar un mensaje de voz';

  @override
  String get aiPrivacyNotice => 'Aviso de privacidad';

  @override
  String get aiUsageTitle => 'Cómo usarlo';

  @override
  String get aiUsageBody =>
      'Mantén pulsado el botón de voz y suéltalo para enviar, o toca el micrófono para grabar. Se envía automáticamente a los 3 minutos. Practica conversación y comprensión oral con Bantera AI en el idioma y acento que aprendes.\n\nToca el teléfono para una llamada de 9 minutos. La IA te saluda primero. Toca Traducir en un mensaje cuando lo necesites.\n\nDi «Llámame dentro de 10 minutos para recordarme que practique inglés», o indica una hora concreta. Incluye el motivo del recordatorio. Si solo dices la hora, la IA preguntará el motivo antes de programar la llamada.\n\nActiva las notificaciones de llamadas en tu iPhone y mantén la conexión a Internet. Responde a la llamada para escuchar el recordatorio. La llamada puede retrasarse.\n\nPide que te recuerde practicar en diez minutos para recibir un mensaje de voz. Di «Llámame» solo si quieres una llamada. Las horas usan tu zona horaria actual. Los recordatorios se conservan siete días.\n\nEl historial de IA recibido queda en este dispositivo. Se envía contexto relevante a la IA para responder. Los horarios y notas de recordatorios se guardan en el servidor. El audio se conserva hasta recibirlo o cancelarlo, como máximo siete días.';

  @override
  String get aiCallConfirmTitle => '¿Iniciar una llamada de audio?';

  @override
  String get aiCallConfirmBody =>
      'Habla con Bantera AI durante un máximo de 9 minutos. La IA te saluda primero.';

  @override
  String get aiCallConfirmStart => 'Iniciar llamada';

  @override
  String get aiReplying => 'Bantera AI está respondiendo…';

  @override
  String get aiRemindersTitle => 'Recordatorios';

  @override
  String get aiReminderMessage => 'Mensaje de voz';

  @override
  String get aiReminderCall => 'Llamada de audio';

  @override
  String get aiReminderEmpty => 'Aún no hay recordatorios';

  @override
  String get aiReminderCancelTitle => '¿Cancelar este recordatorio?';

  @override
  String get aiReminderPending => 'Programado';

  @override
  String get aiReminderPreparing => 'En curso';

  @override
  String get aiReminderReady => 'Listo';

  @override
  String get aiReminderDelivered => 'Entregado';

  @override
  String get aiReminderCancelled => 'Cancelado';

  @override
  String get aiReminderFailed => 'No entregado';

  @override
  String get aiReminderScheduleHelp =>
      'Pide que te recuerde practicar en diez minutos para recibir un mensaje de voz. Di «Llámame» solo si quieres una llamada. Las horas usan tu zona horaria actual. Los recordatorios se conservan siete días.';

  @override
  String get aiReplyInterrupted => 'Respuesta interrumpida.';

  @override
  String get aiWebSearching => 'Buscando en la web…';

  @override
  String get aiWebUnavailable => 'Búsqueda no disponible';

  @override
  String get aiWebSources => 'Fuentes';

  @override
  String get aiWebSearchHelp =>
      'Puedes pedir a Bantera AI que busque en la web. Este dispositivo envía la consulta a DuckDuckGo y los extractos a la IA. Toca una fuente para abrirla. La búsqueda puede no estar disponible.';

  @override
  String get aiImages => 'Imágenes';

  @override
  String get aiImagesSearching => 'Buscando imágenes…';

  @override
  String get aiImagesUnavailable =>
      'Imágenes no disponibles. Inténtalo más tarde.';

  @override
  String get aiImageShare => 'Guardar o compartir imagen';

  @override
  String get aiImagesHelp =>
      'Pide imágenes para practicar cómo describir lo que ves. Este dispositivo busca imágenes en la web y usa Wikimedia Commons como alternativa. Se guardan aquí con tu chat. Toca una imagen para ampliarla o compartirla y su fuente para consultar los derechos de uso. Los temas se envían al buscador; los títulos y enlaces de origen, a la IA. Las imágenes no se suben a Bantera.';

  @override
  String get aiImagesRights => 'Consulta los derechos de uso en la fuente';
}
