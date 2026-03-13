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
  String get steps => 'PASSOS';

  @override
  String get startRun => 'Iniciar Corrida';

  @override
  String get syncHealthConnect => 'Sincronizar Health Connect';

  @override
  String get todayYouTook => 'hoje você deu:';

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
}
