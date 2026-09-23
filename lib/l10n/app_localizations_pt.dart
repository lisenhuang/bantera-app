// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Bantera';

  @override
  String get appTagline => 'Pratique idiomas, frase por frase.';

  @override
  String get authContinueWithApple => 'Continuar com a Apple';

  @override
  String get authContinueWithGoogle => 'Continuar com o Google';

  @override
  String get authAppleUnavailable =>
      'Iniciar sessão com a Apple não está disponível neste dispositivo.';

  @override
  String get authOrSignInEmail => 'ou entre com e-mail';

  @override
  String get authEmail => 'E-mail';

  @override
  String get authPassword => 'Senha';

  @override
  String get authSigningIn => 'Entrando...';

  @override
  String get authSignIn => 'Entrar';

  @override
  String get authSignInWithEmail => 'Entrar com e-mail';

  @override
  String get validationEnterEmail => 'Digite seu e-mail.';

  @override
  String get validationValidEmail => 'Digite um e-mail válido.';

  @override
  String get validationEnterPassword => 'Digite sua senha.';

  @override
  String get onboardingTitle => 'Configure seu perfil';

  @override
  String get onboardingSubtitle =>
      'Isso ajuda o Bantera a personalizar a prática e o chat.';

  @override
  String get onboardingNameTitle => 'Como você quer ser chamado?';

  @override
  String get onboardingNameSubtitle =>
      'Preenchemos com os dados da sua conta fornecidos pela Apple. Você pode alterar agora.';

  @override
  String get onboardingClearName => 'Limpar nome';

  @override
  String get onboardingNativeLanguageTitle => 'Qual é o seu idioma nativo?';

  @override
  String get onboardingNativeLanguageSubtitle =>
      'O Bantera usa isso para traduções e grupos de idioma.';

  @override
  String get onboardingLearningLanguageTitle =>
      'Qual idioma você está aprendendo?';

  @override
  String get onboardingLearningLanguageSubtitle =>
      'Isso define o conteúdo de prática e os grupos de aprendizado.';

  @override
  String get onboardingAvatarTitle => 'Adicione uma foto de perfil';

  @override
  String get onboardingAvatarSubtitle =>
      'Escolha uma foto ou continue e o Bantera vai gerar uma para você.';

  @override
  String get onboardingAvatarGenderTitle => 'Gerar sua foto de perfil';

  @override
  String get onboardingAvatarGenderBody =>
      'Escolha como o Bantera deve gerar sua foto de perfil. Não armazenamos essa escolha; ela é usada apenas para esta imagem.';

  @override
  String get onboardingAvatarGenderMale => 'Masculino';

  @override
  String get onboardingAvatarGenderFemale => 'Feminino';

  @override
  String get onboardingChoosePhoto => 'Escolher Foto';

  @override
  String get onboardingChangePhoto => 'Alterar Foto';

  @override
  String get onboardingUseGeneratedAvatar => 'Usar avatar gerado';

  @override
  String get onboardingUseCurrentPhoto => 'Usar foto atual';

  @override
  String get onboardingChooseLanguage => 'Escolher idioma';

  @override
  String get onboardingBack => 'Voltar';

  @override
  String get onboardingFinish => 'Concluir';

  @override
  String get onboardingLoadingProfile => 'Carregando perfil...';

  @override
  String get onboardingSavingProfile => 'Salvando perfil...';

  @override
  String get onboardingLoadFailed => 'Algo deu errado. Tente novamente.';

  @override
  String get onboardingSearchHint => 'Buscar idiomas…';

  @override
  String get onboardingRetry => 'Tentar Novamente';

  @override
  String get onboardingNoMatching => 'Nenhum idioma encontrado.';

  @override
  String get onboardingFailedSave => 'Falha ao salvar.';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get sectionAppearance => 'Aparência';

  @override
  String get sectionAccount => 'Conta';

  @override
  String get sectionRateAndShare => 'Avaliar e Compartilhar';

  @override
  String get sectionLanguage => 'Idioma do App';

  @override
  String get sectionPermissions => 'Permissões';

  @override
  String get sectionNotifications => 'Notificações';

  @override
  String get languageSectionSubtitle =>
      'Escolha o idioma do app. \"Sistema\" segue os ajustes do seu dispositivo.';

  @override
  String get themeLabel => 'Tema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get languageEnglish => 'Inglês';

  @override
  String get languageChineseSimplified => 'Chinês (Simplificado)';

  @override
  String get languageKorean => 'Coreano';

  @override
  String get languageJapanese => 'Japonês';

  @override
  String get signedOutLabel => 'Sessão encerrada';

  @override
  String get noActiveSession => 'Nenhuma sessão ativa no Bantera';

  @override
  String signedInWith(String provider) {
    return 'Conectado com $provider';
  }

  @override
  String get editProfile => 'Editar Perfil';

  @override
  String get more => 'Mais';

  @override
  String get appPermissionsTitle => 'Permissões do App';

  @override
  String get appPermissionsSubtitle =>
      'Revise os acessos que o Bantera usa neste dispositivo.';

  @override
  String get permissionsIntro =>
      'O Bantera usa estes ajustes do dispositivo para gravação, comparação de fala e acesso à rede.';

  @override
  String get permissionsOpenSettings => 'Abrir Ajustes do iPhone';

  @override
  String get permissionsRefresh => 'Atualizar';

  @override
  String get permissionMicrophoneTitle => 'Microfone';

  @override
  String get permissionMicrophoneDescription =>
      'Gravar tentativas de prática e mensagens de voz.';

  @override
  String get permissionSpeechTitle => 'Reconhecimento de Fala';

  @override
  String get permissionSpeechDescription =>
      'Transcrever gravações de prática e mensagens de voz.';

  @override
  String get permissionMobileDataTitle => 'Dados Celulares';

  @override
  String get permissionMobileDataDescription =>
      'Usar o Bantera quando este iPhone não estiver conectado ao Wi-Fi.';

  @override
  String get permissionStatusAllowed => 'Permitido';

  @override
  String get permissionStatusLimited => 'Limitado';

  @override
  String get permissionStatusNotAllowed => 'Não Permitido';

  @override
  String get permissionStatusUnknown => 'Desconhecido';

  @override
  String get signOut => 'Sair';

  @override
  String get signOutDialogTitle => 'Sair?';

  @override
  String get signOutDialogBody =>
      'Você precisará entrar novamente para usar sua conta.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get closeLabel => 'Fechar';

  @override
  String get navDiscover => 'Descobrir';

  @override
  String get navCreate => 'Criar';

  @override
  String get navProfile => 'Perfil';

  @override
  String get chatsTitle => 'Conversas';

  @override
  String get chatNoChatsYet => 'Nenhuma conversa ainda.';

  @override
  String get chatOnlineSection => 'Online';

  @override
  String get chatDirectMessagesSection => 'DM';

  @override
  String chatAudioDuration(String duration) {
    return 'Áudio $duration';
  }

  @override
  String get chatEnableNotifications => 'Ativar notificações';

  @override
  String get chatMuteNotifications => 'Silenciar notificações';

  @override
  String get chatBlockUser => 'Bloquear usuário';

  @override
  String get chatDeleteDm => 'Apagar DM';

  @override
  String get chatCall => 'Ligar';

  @override
  String get chatStartAudioCall => 'Chamada de Áudio';

  @override
  String get chatStartVideoCall => 'Chamada de Vídeo';

  @override
  String get chatAudioCalling => 'Chamada de áudio...';

  @override
  String get chatVideoCalling => 'Chamada de vídeo...';

  @override
  String get chatAudioIncoming => 'Chamada de áudio recebida';

  @override
  String get chatVideoIncoming => 'Chamada de vídeo recebida';

  @override
  String get chatCallConnecting => 'Conectando...';

  @override
  String get chatCallAccept => 'Aceitar';

  @override
  String get chatCallDecline => 'Recusar';

  @override
  String get chatCallEnd => 'Encerrar';

  @override
  String get chatCallMute => 'Silenciar';

  @override
  String get chatCallUnmute => 'Ativar Som';

  @override
  String get chatCallSpeaker => 'Alto-falante';

  @override
  String get chatCallCamera => 'Câmera';

  @override
  String get chatCallSwitchCamera => 'Alternar';

  @override
  String get chatCallIssueTitle => 'Problema na chamada';

  @override
  String get chatCallMicrophoneDenied =>
      'O Bantera precisa de acesso ao microfone para iniciar uma chamada.';

  @override
  String get chatCallMicrophoneSettings =>
      'O acesso ao microfone está desativado para o Bantera. Abra os Ajustes e ative-o para fazer chamadas.';

  @override
  String get chatCallCameraDenied =>
      'O Bantera precisa de acesso à câmera para iniciar uma chamada de vídeo.';

  @override
  String get chatCallCameraSettings =>
      'O acesso à câmera está desativado para o Bantera. Abra os Ajustes e ative-o para chamadas de vídeo.';

  @override
  String get chatCallBusy => 'Este usuário já está em outra chamada.';

  @override
  String get chatCallUnavailable =>
      'Este usuário não está disponível para chamadas no momento.';

  @override
  String get chatCallNetworkRestricted =>
      'Esta rede não consegue conectar a chamada. Tente o Wi-Fi ou outra rede.';

  @override
  String get chatCallFailed =>
      'Não foi possível iniciar a chamada. Tente novamente.';

  @override
  String get chatGroupReady =>
      'Este grupo está pronto para mensagens de áudio.';

  @override
  String get chatHoldToStartDm =>
      'Mantenha pressionado para gravar e iniciar a DM.';

  @override
  String get chatNoGroupAudio => 'Nenhum áudio no grupo ainda.';

  @override
  String get chatNoDmAudio => 'Nenhum áudio nesta DM ainda.';

  @override
  String get chatSendingAudio => 'Enviando áudio...';

  @override
  String get chatRecordingReleaseToSend => 'Gravando... solte para enviar';

  @override
  String get chatHoldToRecordAudio => 'Mantenha pressionado para gravar';

  @override
  String get chatRecordingStatus => 'Gravando...';

  @override
  String get chatGroupLabel => 'Grupo';

  @override
  String get chatNotificationsEnabledForDm =>
      'Notificações ativadas para esta DM.';

  @override
  String get chatNotificationsMutedForDm =>
      'Notificações silenciadas para esta DM.';

  @override
  String chatBlockUserTitle(String user) {
    return 'Bloquear $user?';
  }

  @override
  String get chatBlockUserBody =>
      'Vocês deixarão de ver um ao outro em DMs e mensagens de grupos em comum até que você desbloqueie.';

  @override
  String chatBlockUserSuccess(String user) {
    return '$user foi bloqueado.';
  }

  @override
  String get chatBlockUserFailed =>
      'Não foi possível bloquear este usuário. Tente novamente.';

  @override
  String get chatDeleteMessage => 'Apagar mensagem';

  @override
  String get chatDeleteMessageTitle => 'Apagar esta mensagem?';

  @override
  String get chatDeleteMessageBody =>
      'Esta mensagem será removida para todos na conversa. Essa ação não pode ser desfeita.';

  @override
  String get chatDeleteMessageSuccess => 'Mensagem apagada';

  @override
  String get chatDeleteMessageFailed =>
      'Não foi possível apagar a mensagem. Tente novamente.';

  @override
  String get chatDeleteDmTitle => 'Apagar esta DM?';

  @override
  String get chatDeleteDmBody =>
      'Isso apenas a remove da sua lista. Uma nova mensagem pode trazê-la de volta.';

  @override
  String get chatMicrophoneRequiredTitle => 'Microfone necessário';

  @override
  String get chatMicrophoneRequiredSettings =>
      'O Bantera precisa de acesso ao microfone para gravar áudios no chat. Ative-o nos Ajustes.';

  @override
  String get chatMicrophoneRequiredBody =>
      'O Bantera precisa de acesso ao microfone para gravar áudios no chat.';

  @override
  String get chatGroupNotReady => 'Este grupo ainda não está pronto.';

  @override
  String get chatMessageAction => 'Mensagem';

  @override
  String get chatRetranscribe => 'Transcrever de Novo';

  @override
  String get chatTranscribe => 'Transcrever';

  @override
  String get chatTranscribingOnDevice => 'Transcrevendo neste iPhone...';

  @override
  String get chatTranscriptionFailed =>
      'Falha na transcrição. Tente novamente.';

  @override
  String get chatTranslate => 'Traduzir';

  @override
  String get chatRetranslate => 'Traduzir de Novo';

  @override
  String get chatTranslating => 'Traduzindo neste iPhone...';

  @override
  String get chatTranslationFailed => 'Falha na tradução. Tente novamente.';

  @override
  String get chatGroupSettingsTitle => 'Ajustes do grupo';

  @override
  String get chatNotifications => 'Notificações';

  @override
  String get chatBlockedUsersMenu => 'Usuários Bloqueados';

  @override
  String get chatBlockedUsersTitle => 'Usuários Bloqueados';

  @override
  String get chatBlockedPeople => 'Pessoas bloqueadas';

  @override
  String get chatNoBlockedUsers => 'Nenhum usuário bloqueado.';

  @override
  String get chatNoBlockedPeople => 'Nenhuma pessoa bloqueada.';

  @override
  String get chatUnblock => 'Desbloquear';

  @override
  String chatUnblockUserTitle(String user) {
    return 'Desbloquear $user?';
  }

  @override
  String get chatUnblockUserBody =>
      'Vocês poderão ver um ao outro novamente em DMs e mensagens de grupos em comum.';

  @override
  String get chatUnblockFailed =>
      'Não foi possível desbloquear este usuário. Tente novamente.';

  @override
  String get chatNotificationsTitle => 'Notificações do chat';

  @override
  String get chatNotificationsSubtitle =>
      'Uma única opção para a conta em todos os seus dispositivos.';

  @override
  String get chatNotificationsDisabledTitle => 'Notificações desativadas';

  @override
  String get chatNotificationsDisabledSettings =>
      'Ative as notificações nos Ajustes para receber alertas de chat do Bantera.';

  @override
  String get chatNotificationsDisabledBody =>
      'O Bantera precisa de permissão de notificações para ativar os alertas de chat.';

  @override
  String get chatNotificationUpdateFailed =>
      'Não foi possível atualizar as notificações do chat. Tente novamente.';

  @override
  String get savedTitle => 'Mídias Salvas';

  @override
  String get generateWithAiTitle => 'Gerar com IA';

  @override
  String get practiceLocalVideoTitle => 'Praticar Vídeo Local';

  @override
  String get uploadVideoTitle => 'Enviar Vídeo';

  @override
  String get lessonDetailsTitle => 'Detalhes da Lição';

  @override
  String get accountMoreTitle => 'Mais';

  @override
  String get deleteAccount => 'Apagar conta';

  @override
  String get deleteAccountSubtitle =>
      'Remover permanentemente sua conta e seus dados do servidor';

  @override
  String get confirmDeletionTitle => 'Confirmar exclusão';

  @override
  String get deleteAccountImmediateBody =>
      'Sua conta será apagada imediatamente. Você precisará criar uma nova conta para usar o Bantera de novo.';

  @override
  String get deleteAccountConfirm => 'Apagar conta';

  @override
  String get couldNotDeleteAccount =>
      'Não foi possível apagar a conta. Tente novamente.';

  @override
  String get deleteAccountQuestionTitle => 'Apagar conta?';

  @override
  String get deleteAccountQuestionBody =>
      'Todas as suas informações pessoais e dados serão removidos permanentemente dos nossos servidores e não poderão ser recuperados.';

  @override
  String get typeDeleteLabel => 'Digite \"DELETE\" para continuar';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get confirmLabel => 'Confirmar';

  @override
  String get deleteLabel => 'Apagar';

  @override
  String get removeFromListLabel => 'Remover da lista';

  @override
  String get startLabel => 'Começar';

  @override
  String get doneLabel => 'OK';

  @override
  String get discoverSearchHint => 'Buscar título ou transcrição…';

  @override
  String get discoverNoMoreResults => 'Não há mais resultados';

  @override
  String get discoverSetLearningLanguagePrompt =>
      'Defina o idioma que você está aprendendo para ver conteúdo aqui';

  @override
  String discoverNoPublicContentInLanguage(String language) {
    return 'Ainda não há conteúdo público em $language';
  }

  @override
  String get discoverSetLanguageToDiscover =>
      'Defina um idioma de aprendizado para descobrir conteúdo';

  @override
  String get mediaStartPractice => 'Começar a Praticar';

  @override
  String get mediaTranscript => 'Transcrição';

  @override
  String mediaTranscriptLineCount(int count) {
    return '($count linhas)';
  }

  @override
  String get mediaShow => 'Mostrar';

  @override
  String get mediaHide => 'Ocultar';

  @override
  String get mediaNoTranscriptAvailable => 'Nenhuma transcrição disponível.';

  @override
  String get lessonSaveTooltip => 'Salvar';

  @override
  String get lessonUnsaveTooltip => 'Remover dos salvos';

  @override
  String get mediaKindAudio => 'Áudio';

  @override
  String get mediaKindVideo => 'Vídeo';

  @override
  String get practiceNoCues => 'Nenhuma frase';

  @override
  String get practiceTranslating => 'Traduzindo…';

  @override
  String get practiceShowTranscript => 'Mostrar Transcrição';

  @override
  String get practiceTranslate => 'Traduzir';

  @override
  String get practiceHideText => 'Ocultar Texto';

  @override
  String get practiceTextLabel => 'Texto';

  @override
  String get practiceStop => 'Parar';

  @override
  String get practicePlayAll => 'Shadowing';

  @override
  String get practiceCompare => 'Comparar';

  @override
  String get practiceRecord => 'Gravar';

  @override
  String get practiceStopRecording => 'Parar';

  @override
  String get practiceRecords => 'Gravações';

  @override
  String get practiceRecordsLocalOnlyFooter =>
      'As tentativas ficam salvas apenas neste dispositivo e não são enviadas.';

  @override
  String get practiceRecordsEmpty =>
      'Nenhuma tentativa salva para esta frase ainda.';

  @override
  String get practiceRecordingProcessError =>
      'Algo deu errado ao processar sua gravação.';

  @override
  String get practiceStartOver => 'Recomeçar';

  @override
  String get practiceTranscriptHidden => 'Transcrição oculta';

  @override
  String get practiceListenCarefully => 'Ouça com atenção…';

  @override
  String get practiceTranslationUnavailableForCue =>
      'Tradução indisponível para esta frase no momento.';

  @override
  String get practiceChooseTranslationLanguageTitle =>
      'Escolher Idioma da Tradução';

  @override
  String get practiceChooseTranslationLanguageDescription =>
      'O Bantera vai traduzir a prática de escuta para este idioma e salvá-lo no seu perfil para as próximas sessões.';

  @override
  String get practiceChangeTranslationLanguageTitle =>
      'Alterar Idioma da Tradução';

  @override
  String get practiceChangeTranslationLanguageDescription =>
      'Escolha o idioma para o qual o Bantera deve traduzir. A nova escolha será salva no seu perfil.';

  @override
  String get practiceConfirmTranslationLanguageTitle =>
      'Confirmar Idioma da Tradução';

  @override
  String get practiceConfirmTranslationLanguageBody =>
      'O Bantera vai salvar este idioma no seu perfil e usá-lo como idioma de tradução padrão nas próximas práticas de escuta.';

  @override
  String get practiceCouldNotSaveTranslationLanguage =>
      'O Bantera não conseguiu salvar seu idioma de tradução.';

  @override
  String get practiceNoTranslationLanguagesFound =>
      'O Bantera não encontrou idiomas de tradução para esta transcrição.';

  @override
  String get practicePlayAllTitle => 'Shadowing';

  @override
  String get practicePlayAllDescription => 'Pausa entre frases para shadowing:';

  @override
  String get practicePlayAllPauseZeroSeconds => '0 s';

  @override
  String get practicePlayAllPauseOneSecondLabel => '1 s';

  @override
  String get practicePlayAllPauseOneCuePlusOneSecond => '1 frase + 1 s';

  @override
  String get practicePlayAllPauseOneCuePlusTwoSeconds => '1 frase + 2 s';

  @override
  String get practicePlayAllTimesPerCueTitle => 'Vezes por frase';

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
  String get practiceTranslationDownload => 'Baixar';

  @override
  String get practiceStartOverTitle => 'Recomeçar?';

  @override
  String get practiceStartOverBody => 'Voltar para a primeira frase?';

  @override
  String get practiceNextFromLastTitle => 'Ir para a primeira frase?';

  @override
  String get practiceNextFromLastBody =>
      'Você está na última frase. Voltar para a primeira?';

  @override
  String get practiceGoToFirstCue => 'Ir para a primeira frase';

  @override
  String get practiceVideoOpenError =>
      'Não foi possível abrir o vídeo selecionado para prática.';

  @override
  String get practiceAudioLoading => 'Carregando áudio…';

  @override
  String practiceAudioLoadingPercent(int percent) {
    return 'Carregando áudio $percent%';
  }

  @override
  String get practiceAudioError =>
      'Não foi possível carregar o áudio. Tente novamente.';

  @override
  String get compareRecordYourVersion => 'Grave a sua versão';

  @override
  String compareTranscriptionLanguage(String locale) {
    return 'Idioma da transcrição: $locale';
  }

  @override
  String get compareOpenIphoneSettings => 'Abrir Ajustes do iPhone';

  @override
  String get comparePauseAttempt => 'Pausar Tentativa';

  @override
  String get comparePlayAttempt => 'Reproduzir Tentativa';

  @override
  String get compareYourTranscribedAttempt => 'Sua tentativa transcrita';

  @override
  String get compareHighlightHint =>
      'As palavras que o Bantera reconheceu de forma diferente estão destacadas.';

  @override
  String get compareUncertainHint =>
      'As palavras pontilhadas foram reconhecidas, mas o Bantera não teve certeza — confira sua pronúncia.';

  @override
  String get compareTryAgain => 'Tentar de Novo';

  @override
  String get compareDone => 'OK';

  @override
  String get compareStatusTranscribing =>
      'Transcrevendo sua tentativa no iPhone…';

  @override
  String get compareStatusRecording => 'Gravando… Toque de novo para parar.';

  @override
  String get compareStatusSavedAttempt =>
      'Mostrando uma tentativa salva para esta frase. Você pode ouvi-la de novo ou tentar outra vez.';

  @override
  String get compareStatusReplayOrRetry =>
      'Você pode ouvir esta tentativa de novo ou repetir a frase.';

  @override
  String get compareStatusTapToRecord =>
      'Toque para começar a gravar sua versão desta frase.';

  @override
  String get compareCouldNotStartRecording =>
      'O Bantera não conseguiu iniciar a gravação agora.';

  @override
  String get compareCouldNotAccessRecording =>
      'O Bantera não conseguiu acessar o áudio gravado.';

  @override
  String get compareNoTranscriptGenerated =>
      'Não foi possível gerar uma transcrição para esta tentativa. Tente de novo mais perto do microfone.';

  @override
  String get compareRecentAttempts => 'Tentativas recentes';

  @override
  String get compareAttemptsFooterNote =>
      'O Bantera mantém suas tentativas neste iPhone para que você acompanhe seu progresso na mesma frase.';

  @override
  String compareMatchedCount(int count) {
    return '$count corretas';
  }

  @override
  String compareDifferentCount(int count) {
    return '$count diferentes';
  }

  @override
  String compareMissingCount(int count) {
    return '$count faltando';
  }

  @override
  String compareUncertainCount(int count) {
    return '$count incertas';
  }

  @override
  String get compareMicrophoneDeniedPermanent =>
      'O acesso ao microfone está desativado para o Bantera. Abra Ajustes do iPhone > Bantera > Microfone e ative-o para gravar sua versão.';

  @override
  String get compareMicrophoneDeniedRestricted =>
      'Este iPhone está restringindo o acesso ao microfone para o Bantera. Verifique o Tempo de Uso, o gerenciamento do dispositivo ou os ajustes do sistema para ativá-lo.';

  @override
  String get compareMicrophoneDeniedDefault =>
      'É necessária a permissão do microfone para gravar sua versão. Se você recusou o pedido antes, abra Ajustes do iPhone > Bantera > Microfone e ative-o.';

  @override
  String get compareSpeechRecognitionDeniedPermanent =>
      'O acesso ao Reconhecimento de Fala está desativado para o Bantera. Abra Ajustes do iPhone > Bantera > Reconhecimento de Fala e ative-o para comparar sua gravação.';

  @override
  String get compareSpeechRecognitionDeniedRestricted =>
      'Este iPhone está restringindo o Reconhecimento de Fala para o Bantera. Verifique o Tempo de Uso, o gerenciamento do dispositivo ou os ajustes do sistema para ativá-lo.';

  @override
  String get compareSpeechRecognitionUnavailable =>
      'O Reconhecimento de Fala não está disponível neste iPhone no momento.';

  @override
  String get compareSpeechRecognitionUnsupportedLocale =>
      'O Reconhecimento de Fala não está disponível para este idioma de prática neste iPhone.';

  @override
  String get comparePlayAttemptTooltip => 'Reproduzir tentativa';

  @override
  String get comparePauseAttemptTooltip => 'Pausar tentativa';

  @override
  String get createWhatToday => 'O que você quer fazer hoje?';

  @override
  String get createPracticeVideo => 'Praticar Vídeo';

  @override
  String get createYourMedia => 'Suas Mídias';

  @override
  String get createTryAgain => 'Tentar de Novo';

  @override
  String get createUploadedVideosEmptyHint =>
      'Os vídeos que você enviar aparecerão aqui para você reabri-los e praticar frase por frase.';

  @override
  String get createUploadingTips => 'Dicas de Envio';

  @override
  String get createUploadingTipsBody =>
      'Mantenha seu áudio com menos de 3 minutos para melhores resultados. As legendas são geradas automaticamente!';

  @override
  String get createOnThisIphone => 'Neste iPhone';

  @override
  String get createLocalVideosEmptyHint =>
      'Os vídeos que você praticar localmente ficam salvos neste iPhone para você reabri-los depois sem precisar transcrever de novo.';

  @override
  String get createOnDeviceBadge => 'No Dispositivo';

  @override
  String get createSignInToLoadVideos =>
      'Entre novamente para carregar seus vídeos enviados.';

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
  String get createDeleteSavedVideoTitle => 'Apagar Vídeo Salvo?';

  @override
  String createDeleteSavedVideoBody(String title) {
    return 'O Bantera vai remover \"$title\" deste iPhone e apagar as frases da transcrição salva.';
  }

  @override
  String get createDeleteMediaTitle => 'Apagar mídia?';

  @override
  String createDeleteMediaBody(String title) {
    return 'Isso vai apagar permanentemente \"$title\" e sua transcrição. Essa ação não pode ser desfeita.';
  }

  @override
  String get removeFromListTitle => 'Remover da lista?';

  @override
  String get removeFromListBody =>
      'Este item será removido da lista. Essa ação não pode ser desfeita.';

  @override
  String get editProfileChangeImage => 'Alterar Foto de Perfil';

  @override
  String get editProfileUploading => 'Enviando…';

  @override
  String get editProfileNameLabel => 'Nome';

  @override
  String get editProfileNameHint => 'Como o Bantera deve mostrar seu nome?';

  @override
  String get editProfileSaveNameButton => 'Salvar Nome';

  @override
  String get editProfileSaving => 'Salvando…';

  @override
  String get editProfileLanguagesSection => 'Idiomas';

  @override
  String get editProfileMyNativeLanguage => 'Meu Idioma Nativo';

  @override
  String get editProfileMyNativeLanguageSubtitle =>
      'Seu idioma nativo ou primeiro idioma';

  @override
  String get editProfileLearningLanguage => 'Idioma de Aprendizado';

  @override
  String get editProfileLearningLanguageSubtitle =>
      'O idioma que você quer praticar';

  @override
  String get editProfileImageUpdated => 'Foto de perfil atualizada.';

  @override
  String get editProfileNameUpdated => 'Nome atualizado.';

  @override
  String get editProfileEnterName => 'Digite um nome.';

  @override
  String get editProfileNameMaxLength => 'Use no máximo 80 caracteres.';

  @override
  String get editProfileCouldNotLoadLanguages =>
      'Não foi possível carregar a lista de idiomas.';

  @override
  String get languagePickerNone => 'Nenhum';

  @override
  String get languagePickerClearSelection => 'Limpar seleção';

  @override
  String get languagePickerNoMatchingLanguages => 'Nenhum idioma encontrado.';

  @override
  String get languagePickerMoreComingSoon => 'Mais idiomas em breve';

  @override
  String get editProfileNativeLanguageCleared => 'Idioma nativo removido.';

  @override
  String get editProfileLearningLanguageCleared =>
      'Idioma de aprendizado removido.';

  @override
  String editProfileNativeLanguageSetTo(String language) {
    return 'Idioma nativo definido como $language.';
  }

  @override
  String editProfileLearningLanguageSetTo(String language) {
    return 'Idioma de aprendizado definido como $language.';
  }

  @override
  String get profileLanguageSettings => 'Ajustes de Idioma';

  @override
  String get profileLearningLabel => 'Aprendendo';

  @override
  String get profileNotSet => 'Não definido';

  @override
  String get uploadedDetailYourAudio => 'Seu Áudio';

  @override
  String get uploadedDetailYourVideo => 'Seu Vídeo';

  @override
  String get uploadedDetailDeleteAudioTitle => 'Apagar áudio?';

  @override
  String get uploadedDetailDeleteAudioBody =>
      'Isso vai apagar permanentemente o áudio e sua transcrição. Essa ação não pode ser desfeita.';

  @override
  String get uploadedDetailDeleteVideoTitle => 'Apagar vídeo?';

  @override
  String get uploadedDetailDeleteVideoBody =>
      'Isso vai apagar permanentemente o vídeo e sua transcrição. Essa ação não pode ser desfeita.';

  @override
  String get uploadedDetailAiGenerated => 'Gerado por IA';

  @override
  String get uploadedDetailFileSize => 'Tamanho do arquivo';

  @override
  String get uploadedDetailResolution => 'Resolução';

  @override
  String get uploadedDetailResolutionUnknown => 'Desconhecida';

  @override
  String get uploadedDetailTranscribing => 'Transcrevendo…';

  @override
  String get uploadedDetailNoTranscriptCuesYet =>
      'Ainda não há frases de transcrição disponíveis.';

  @override
  String uploadedDetailMediaDescription(int count) {
    return 'Seu clipe de prática enviado com $count frases na transcrição.';
  }

  @override
  String get uploadedDetailTranscriptionFailedFallback =>
      'Falha na transcrição. Usando frases estimadas.';

  @override
  String get uploadedDetailTranscriptionNoCues =>
      'A transcrição não retornou nenhuma frase.';

  @override
  String get uploadedDetailTranscriptionSourceYourUpload => 'Seu Envio';

  @override
  String get aiGenLeaveTitle => 'Sair desta página?';

  @override
  String get aiGenLeaveBody =>
      'O áudio ainda está sendo gerado. Se você sair agora, o processo será cancelado.';

  @override
  String get aiGenStay => 'Ficar';

  @override
  String get aiGenLeave => 'Sair';

  @override
  String get aiGenLoadingTitle => 'Criando seu áudio…';

  @override
  String get aiGenLoadingSubtitle =>
      'Isso pode levar até um minuto.\nPermaneça nesta página durante a geração.';

  @override
  String get aiGenStepPreparingSpeechModel =>
      'Preparando o modelo de fala no dispositivo';

  @override
  String get aiGenStepWritingDialogue => 'Escrevendo o diálogo';

  @override
  String get aiGenStepGeneratingAudio => 'Gerando o áudio';

  @override
  String get aiGenStepAligningAudio => 'Sincronizando o áudio';

  @override
  String get aiGenStepTranscribing => 'Transcrevendo';

  @override
  String get aiGenStepCorrectingTranscript => 'Corrigindo a transcrição';

  @override
  String get aiGenLanguageSection => 'Idioma';

  @override
  String get aiGenSetLearningLanguagePrompt =>
      'Defina o idioma que você está aprendendo para ativar a geração';

  @override
  String get aiGenLoadingLanguage => 'Carregando idioma…';

  @override
  String aiGenLanguageUnsupported(String language) {
    return 'O idioma \"$language\" não é compatível com a geração.';
  }

  @override
  String get aiGenScenarioSection => 'Cenário';

  @override
  String get aiGenScenarioOptionalHint =>
      'Opcional — deixe sem seleção para um cenário aleatório.';

  @override
  String get aiGenCustomScenarioHint => 'Descreva seu cenário…';

  @override
  String get aiGenDurationSection => 'Duração';

  @override
  String aiGenDurationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get aiGenGenerateButton => 'Gerar';

  @override
  String get aiGenOwnershipNotice =>
      'O áudio que você gerar aqui se torna conteúdo da comunidade Bantera — compartilhado publicamente como material de prática para todos os estudantes.';

  @override
  String get aiGenOwnershipCheckbox =>
      'Compartilhar este áudio como conteúdo da comunidade Bantera';

  @override
  String get aiGenOwnershipConfirmTitle =>
      'Compartilhar como conteúdo da comunidade?';

  @override
  String get aiGenOwnershipConfirmCancel => 'Cancelar';

  @override
  String get aiGenOwnershipConfirmGenerate => 'Gerar';

  @override
  String get aiGenFooterNotice =>
      'A IA vai escrever um diálogo entre duas pessoas e transformá-lo em áudio. O resultado será salvo como um áudio de prática público.';

  @override
  String get aiScenarioCoffeeShop => 'Cafeteria';

  @override
  String get aiScenarioLatestNews => 'Últimas Notícias';

  @override
  String get aiScenarioAirportReunion => 'Reencontro no aeroporto';

  @override
  String get aiScenarioGroceryStore => 'Supermercado';

  @override
  String get aiScenarioDoctorVisit => 'Consulta médica';

  @override
  String get aiScenarioJobInterview => 'Entrevista de emprego';

  @override
  String get aiScenarioNewNeighbour => 'Novo vizinho';

  @override
  String get aiScenarioTechSupport => 'Suporte técnico';

  @override
  String get aiScenarioBirthdaySurprise => 'Aniversário surpresa';

  @override
  String get aiScenarioGymTips => 'Dicas de academia';

  @override
  String get aiScenarioWeatherSmalltalk => 'Papo sobre o tempo';

  @override
  String get aiScenarioRestaurantOrder => 'Pedido no restaurante';

  @override
  String get aiScenarioBookRecommendation => 'Indicação de livro';

  @override
  String get aiScenarioBusDelay => 'Ônibus atrasado';

  @override
  String get aiScenarioMovieDebate => 'Debate sobre filmes';

  @override
  String get aiScenarioCustom => 'Personalizado…';

  @override
  String get errorNetworkUnreachable =>
      'Não foi possível conectar ao Bantera. Verifique sua conexão com a internet.';

  @override
  String get errorNetworkCellularBlocked =>
      'Os dados celulares estão desativados para o Bantera. Em Ajustes, abra Bantera e ative Dados Celulares, ou conecte-se a uma rede Wi-Fi.';

  @override
  String get errorTlsConnection =>
      'Não foi possível estabelecer uma conexão segura.';

  @override
  String get settingsRateAppPrompt =>
      'Está gostando do Bantera? Uma avaliação rápida na App Store significa muito para nós.';

  @override
  String get settingsRateAppButton => 'Avaliar na App Store';

  @override
  String get settingsSharePrompt =>
      'Conhece alguém aprendendo um idioma? Compartilhe o Bantera.';

  @override
  String get settingsShareButton => 'Compartilhar o Bantera';

  @override
  String get settingsContactButton => 'Fale conosco';

  @override
  String get localVideoDescription =>
      'Escolha um vídeo do app Fotos, selecione o idioma falado e deixe o iPhone transcrevê-lo em segundo plano antes da prática frase por frase.';

  @override
  String get localVideoStep1Title => '1. Escolha o vídeo';

  @override
  String get localVideoChooseFromPhotos => 'Escolher do Fotos';

  @override
  String get localVideoChooseDifferent => 'Escolher Outro Vídeo';

  @override
  String get localVideoSelectedFileLabel => 'Arquivo selecionado';

  @override
  String get localVideoSizeLabel => 'Tamanho';

  @override
  String get localVideoDurationLabel => 'Duração';

  @override
  String get localVideoLongVideoWarning =>
      'Este vídeo tem mais de 3 minutos, então o Bantera pode demorar mais para preparar a transcrição e a tradução.';

  @override
  String get localVideoStep2Title => '2. Idioma da transcrição';

  @override
  String get localVideoChooseLanguagePlaceholder => 'Escolha o idioma falado';

  @override
  String get localVideoLanguageHint =>
      'O Bantera lembra sua última escolha de idioma e mantém a transcrição oculta por padrão quando a prática começa.';

  @override
  String get localVideoStep3Title => '3. Prática';

  @override
  String get localVideoPreparing => 'Preparando...';

  @override
  String get localVideoPracticeHint =>
      'O Bantera transcreve primeiro no dispositivo e depois abre a página de escuta frase por frase, sem enviar nada.';

  @override
  String get localVideoStatusLongVideo =>
      'Este vídeo é mais longo, então o Bantera pode precisar de mais tempo para transcrevê-lo e prepará-lo.';

  @override
  String get localVideoStatusTranscribing =>
      'Transcrevendo no dispositivo e preparando as frases de prática...';

  @override
  String get localVideoStatusSaving =>
      'Salvando este vídeo na sua biblioteca de prática no dispositivo...';

  @override
  String get localVideoStatusTranslationLong =>
      'Transcrição concluída. O Bantera também está preparando a tradução para o seu idioma salvo, então este vídeo mais longo pode demorar um pouco mais.';

  @override
  String get localVideoStatusTranslation =>
      'Transcrição concluída. Preparando a tradução para o seu idioma salvo...';

  @override
  String get localVideoPickerTitle => 'Escolher Idioma do Áudio';

  @override
  String get savedCuesTitle => 'Frases Salvas';

  @override
  String get savedCuesEmpty =>
      'Nenhuma frase salva ainda. Toque no ícone de marcador durante a prática para salvar uma frase.';

  @override
  String get savedCuesDeleteTooltip => 'Remover frase salva';

  @override
  String get savedCuesDeleteConfirmTitle => 'Remover esta frase?';

  @override
  String get savedCuesDeleteConfirmBody =>
      'Esta frase será removida da sua lista de salvos.';

  @override
  String get savedCuesDeleteAllTooltip => 'Apagar todas as frases salvas';

  @override
  String get savedCuesDeleteAllConfirmTitle => 'Apagar todas as frases salvas?';

  @override
  String get savedCuesDeleteAllConfirmBody =>
      'Todas as frases salvas serão removidas permanentemente.';

  @override
  String get updateAlertTitle => 'Atualização Disponível';

  @override
  String get updateAlertMessage =>
      'Uma nova versão do Bantera está disponível. Atualize agora para ter os recursos e melhorias mais recentes.';

  @override
  String get updateCurrentVersionLabel => 'Versão atual';

  @override
  String get updateAppStoreVersionLabel => 'Versão na App Store';

  @override
  String get updateAlertUpdate => 'Atualizar';

  @override
  String get updateAlertLater => 'Mais Tarde';

  @override
  String get checkForUpdateButton => 'Verificar Atualizações';

  @override
  String get upToDateAlertTitle => 'Tudo Atualizado';

  @override
  String upToDateAlertMessage(Object version) {
    return 'O Bantera $version é a versão mais recente.';
  }

  @override
  String get sectionSupport => 'Suporte';

  @override
  String get permissionActionAllow => 'Permitir';
}
