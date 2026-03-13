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
  String get locationPermissionRequired =>
      'A permissão de localização é necessária para rastrear sua corrida.';
}
