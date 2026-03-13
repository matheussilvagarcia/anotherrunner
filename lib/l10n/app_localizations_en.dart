// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get dashboard => 'Dashboard';

  @override
  String get steps => 'STEPS';

  @override
  String get startRun => 'Start Run';

  @override
  String get syncHealthConnect => 'Sync Health Connect';

  @override
  String get todayYouTook => 'today you took:';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get credits => 'Credits';

  @override
  String get language => 'Language';

  @override
  String get lastSyncOn => 'Last cloud sync on';

  @override
  String get unlockPremium => 'Unlock Premium Charts';

  @override
  String get premiumDesc =>
      'Get access to detailed weekly and monthly averages. Track your progress in calories, steps, distance, and running time visually and reach your goals faster!';

  @override
  String get buyFor => 'Buy for';

  @override
  String get buyNow => 'Buy Now';

  @override
  String get maybeLater => 'Maybe later';

  @override
  String get syncSuccess => 'Data synced to cloud successfully!';

  @override
  String get hcSyncSuccess => 'Data synced! Runs added to history.';

  @override
  String get hcNoData => 'No health data found for today.';

  @override
  String get hcPermissionDenied => 'Permission denied to access Health data.';

  @override
  String get locationPermissionRequired =>
      'Location permission is required to track your run.';
}
