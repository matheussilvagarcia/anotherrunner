// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get dashboard => 'Painel';

  @override
  String get steps => 'passos';

  @override
  String get startRun => 'Iniciar Corrida';

  @override
  String get syncHealthConnect => 'Sincronizar Health Connect';

  @override
  String get todayYouTook => 'hoje você andou';

  @override
  String get goodMorning => 'Bom dia';

  @override
  String get goodAfternoon => 'Boa tarde';

  @override
  String get goodEvening => 'Boa noite';

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String get credits => 'Créditos';

  @override
  String get language => 'Idioma';

  @override
  String get lastSyncOn => 'Última sincronização na nuvem em';

  @override
  String get unlockPremium => 'Desbloquear Gráficos Premium';

  @override
  String get premiumDesc =>
      'Tenha acesso a médias semanais e mensais detalhadas. Acompanhe seu progresso em calorias, passos, distância e tempo de corrida visualmente e alcance seus objetivos mais rápido!';

  @override
  String get buyFor => 'Comprar por';

  @override
  String get buyNow => 'Comprar Agora';

  @override
  String get maybeLater => 'Talvez mais tarde';

  @override
  String get syncSuccess => 'Dados sincronizados na nuvem com sucesso!';

  @override
  String get hcSyncSuccess =>
      'Dados sincronizados! Corridas adicionadas ao histórico.';

  @override
  String get hcNoData => 'Nenhum dado de saúde encontrado para hoje.';

  @override
  String get hcPermissionDenied =>
      'Permissão negada para acessar dados de saúde.';

  @override
  String get capturedByHealthConnect => 'Capturado pelo Health Connect';

  @override
  String get activityAverages => 'Médias de Atividade';

  @override
  String get last7Days => 'Últimos 7 Dias';

  @override
  String get monthlyAverages => 'Médias Mensais';

  @override
  String get chartSteps => 'Passos';

  @override
  String get chartCalories => 'Calorias (kcal)';

  @override
  String get chartDistance => 'Distância (km)';

  @override
  String get chartDuration => 'Duração (min)';

  @override
  String get locationPermissionRequired =>
      'A permissão de localização é necessária para rastrear sua corrida.';

  @override
  String get runHistory => 'Histórico de Corridas';

  @override
  String get authenticationRequired => 'Autenticação necessária';

  @override
  String get noRunsRecorded => 'Nenhuma corrida registrada ainda.';

  @override
  String shareRunMessage(String date) {
    return 'Confira minha corrida no AnotherRunner em $date!';
  }

  @override
  String get dailyActivity => 'Atividade Diária';

  @override
  String get noDailyRecords => 'Nenhum registro diário ainda.';

  @override
  String get unknownDate => 'Desconhecido';

  @override
  String get currentRun => 'Corrida Atual';

  @override
  String get timeLabel => 'TEMPO';

  @override
  String get paceLabel => 'RITMO';

  @override
  String get distanceLabel => 'DISTÂNCIA';

  @override
  String get caloriesLabel => 'CALORIAS';

  @override
  String get runningTracker => 'Rastreador de Corrida';

  @override
  String get activeRunMetrics => 'Métricas da corrida ativa';

  @override
  String get runInProgress => 'Corrida em andamento';

  @override
  String get starting => 'Iniciando...';

  @override
  String notificationBody(String time, String dist, String pace) {
    return 'Tempo: $time  |  Dist: $dist km  |  Ritmo: $pace/km';
  }

  @override
  String get developedBy => 'Desenvolvido por';

  @override
  String get contactMe => 'Entrar em Contato';

  @override
  String get githubProfile => 'Perfil no GitHub';

  @override
  String get visitPortfolio => 'Visite meu Portfólio';

  @override
  String get fillAllFields => 'Por favor, preencha todos os campos';

  @override
  String get passwordsNotMatch => 'As senhas não coincidem!';

  @override
  String get passwordTooShort => 'A senha deve ter pelo menos 6 caracteres';

  @override
  String get errorSendingOtp => 'Erro ao enviar código de verificação.';

  @override
  String get confirmEmailTitle => 'Confirme seu E-mail';

  @override
  String otpSentMessage(String email) {
    return 'Enviamos um código de 6 dígitos para $email.';
  }

  @override
  String get otpCodeLabel => 'Código OTP';

  @override
  String get cancelBtn => 'Cancelar';

  @override
  String get confirmBtn => 'Confirmar';

  @override
  String get invalidOtp => 'Código inválido.';

  @override
  String get welcomeTo => 'Bem vindo ao:';

  @override
  String get chooseLoginMethod => 'Escolha sua forma de login';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Senha';

  @override
  String get confirmPasswordLabel => 'Confirmar Senha';

  @override
  String get createAccountBtn => 'Criar Conta';

  @override
  String get signInBtn => 'Entrar';

  @override
  String get alreadyHaveAccount => 'Já tem uma conta? Entrar';

  @override
  String get dontHaveAccount => 'Não tem uma conta? Criar Conta';

  @override
  String get signInWithGoogleBtn => 'Entrar com o Google';

  @override
  String get emailInUseGoogle =>
      'Este e-mail está vinculado ao Google. Faça login com o Google.';

  @override
  String get emailInUsePassword =>
      'E-mail já cadastrado. Faça login ou redefina sua senha.';

  @override
  String get forgotPasswordBtn => 'Esqueci a senha';

  @override
  String get fillEmailToReset =>
      'Preencha o campo de e-mail para redefinir a senha.';

  @override
  String get passwordResetSent =>
      'Link de redefinição enviado para o seu e-mail!';

  @override
  String get myCommunity => 'Minha Comunidade';

  @override
  String get errorLoadingUser => 'Erro ao carregar usuário';

  @override
  String get loading => 'Carregando...';

  @override
  String get usernameInUse => 'Nome de usuário já em uso.';

  @override
  String get invalidCode => 'Código inválido.';

  @override
  String get accessCodeUpdated => 'Código de acesso atualizado!';

  @override
  String get createCommunity => 'Criar Comunidade';

  @override
  String get name => 'Nome';

  @override
  String get cancel => 'Cancelar';

  @override
  String get create => 'Criar';

  @override
  String get joinCommunity => 'Entrar em Comunidade';

  @override
  String get join => 'Entrar';

  @override
  String get joinUsingCode => 'Entrar usando Código';

  @override
  String get chooseUsername => 'Escolha seu Username';

  @override
  String get yourUsername => 'Seu Username';

  @override
  String get username => 'Username';

  @override
  String get requiredField => 'Obrigatório';

  @override
  String get save => 'Salvar';

  @override
  String get update => 'Atualizar';

  @override
  String get communityNotFound => 'Comunidade não encontrada.';

  @override
  String get code => 'Código';

  @override
  String get weeklyRanking => 'Ranking da Semana';

  @override
  String get noMembers => 'Nenhum membro.';

  @override
  String get memberRole => 'Membro';

  @override
  String get superiorAdminRole => 'Administrador Superior';

  @override
  String get adminRole => 'Administrador';

  @override
  String get you => 'Você';

  @override
  String get kickMember => 'Expulsar';

  @override
  String get makeAdmin => 'Tornar Administrador';

  @override
  String get removeAdmin => 'Remover Administrador';

  @override
  String get transferSuperior => 'Passar cargo de Superior';

  @override
  String timeLeft(int days, int hours) {
    return 'Faltam $days dia(s) e $hours hora(s)';
  }

  @override
  String get editCommunity => 'Editar Comunidade';

  @override
  String get newName => 'Novo Nome';

  @override
  String get editUsername => 'Editar Username';

  @override
  String get newUsername => 'Novo Username';

  @override
  String get usernameUpdated => 'Username atualizado com sucesso!';

  @override
  String get updateCodeTitle => 'Atualizar Código';

  @override
  String get updateCodeDesc =>
      'Tem certeza que deseja gerar um novo código de acesso? O código antigo não funcionará mais para novos membros.';

  @override
  String get attention => 'Atenção';

  @override
  String get transferSuperiorBeforeLeaving =>
      'Você precisa passar o cargo de Administrador Superior para outro membro antes de sair da comunidade.';

  @override
  String get ok => 'OK';

  @override
  String get leaveCommunityTitle => 'Sair da Comunidade';

  @override
  String get leaveCommunityLastMember =>
      'Você é o último membro. Se sair, a comunidade será apagada definitivamente. Tem certeza?';

  @override
  String get leaveCommunityConfirm =>
      'Tem certeza que deseja sair da comunidade?';

  @override
  String get leave => 'Sair';

  @override
  String get setRewardsTitle => 'Definir Premiação';

  @override
  String get firstPlace => '1º Lugar';

  @override
  String get secondPlace => '2º Lugar';

  @override
  String get thirdPlace => '3º Lugar';

  @override
  String get weekDescription => 'Descrição da Semana';

  @override
  String get rankingHistoryTitle => 'Histórico de Classificação';

  @override
  String get noHistoryYet => 'Nenhum histórico disponível ainda.';

  @override
  String get unknownWeek => 'Semana Desconhecida';

  @override
  String get winner => 'Vencedor';

  @override
  String get prize => 'Prêmio';

  @override
  String get close => 'Fechar';

  @override
  String get weeklyRewards => 'Premiação da Semana';

  @override
  String get noRewardsDefined => 'Nenhuma premiação definida.';

  @override
  String get history => 'Histórico';

  @override
  String get noWinner => 'Sem Vencedor';

  @override
  String get firstPlacePrefix => '🥇 1º: ';

  @override
  String get secondPlacePrefix => '🥈 2º: ';

  @override
  String get thirdPlacePrefix => '🥉 3º: ';
}
