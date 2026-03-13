import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @steps.
  ///
  /// In en, this message translates to:
  /// **'STEPS'**
  String get steps;

  /// No description provided for @startRun.
  ///
  /// In en, this message translates to:
  /// **'Start Run'**
  String get startRun;

  /// No description provided for @syncHealthConnect.
  ///
  /// In en, this message translates to:
  /// **'Sync Health Connect'**
  String get syncHealthConnect;

  /// No description provided for @todayYouTook.
  ///
  /// In en, this message translates to:
  /// **'today you took:'**
  String get todayYouTook;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @credits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get credits;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @lastSyncOn.
  ///
  /// In en, this message translates to:
  /// **'Last cloud sync on'**
  String get lastSyncOn;

  /// No description provided for @unlockPremium.
  ///
  /// In en, this message translates to:
  /// **'Unlock Premium Charts'**
  String get unlockPremium;

  /// No description provided for @premiumDesc.
  ///
  /// In en, this message translates to:
  /// **'Get access to detailed weekly and monthly averages. Track your progress in calories, steps, distance, and running time visually and reach your goals faster!'**
  String get premiumDesc;

  /// No description provided for @buyFor.
  ///
  /// In en, this message translates to:
  /// **'Buy for'**
  String get buyFor;

  /// No description provided for @buyNow.
  ///
  /// In en, this message translates to:
  /// **'Buy Now'**
  String get buyNow;

  /// No description provided for @maybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get maybeLater;

  /// No description provided for @syncSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data synced to cloud successfully!'**
  String get syncSuccess;

  /// No description provided for @hcSyncSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data synced! Runs added to history.'**
  String get hcSyncSuccess;

  /// No description provided for @hcNoData.
  ///
  /// In en, this message translates to:
  /// **'No health data found for today.'**
  String get hcNoData;

  /// No description provided for @hcPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied to access Health data.'**
  String get hcPermissionDenied;

  /// No description provided for @capturedByHealthConnect.
  ///
  /// In en, this message translates to:
  /// **'Captured by Health Connect'**
  String get capturedByHealthConnect;

  /// No description provided for @activityAverages.
  ///
  /// In en, this message translates to:
  /// **'Activity Averages'**
  String get activityAverages;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get last7Days;

  /// No description provided for @monthlyAverages.
  ///
  /// In en, this message translates to:
  /// **'Monthly Averages'**
  String get monthlyAverages;

  /// No description provided for @chartSteps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get chartSteps;

  /// No description provided for @chartCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories (kcal)'**
  String get chartCalories;

  /// No description provided for @chartDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance (km)'**
  String get chartDistance;

  /// No description provided for @chartDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration (min)'**
  String get chartDuration;

  /// No description provided for @locationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to track your run.'**
  String get locationPermissionRequired;

  /// No description provided for @runHistory.
  ///
  /// In en, this message translates to:
  /// **'Run History'**
  String get runHistory;

  /// No description provided for @authenticationRequired.
  ///
  /// In en, this message translates to:
  /// **'Authentication required'**
  String get authenticationRequired;

  /// No description provided for @noRunsRecorded.
  ///
  /// In en, this message translates to:
  /// **'No runs recorded yet.'**
  String get noRunsRecorded;

  /// No description provided for @shareRunMessage.
  ///
  /// In en, this message translates to:
  /// **'Check out my run on AnotherRunner on {date}!'**
  String shareRunMessage(String date);

  /// No description provided for @dailyActivity.
  ///
  /// In en, this message translates to:
  /// **'Daily Activity'**
  String get dailyActivity;

  /// No description provided for @noDailyRecords.
  ///
  /// In en, this message translates to:
  /// **'No daily records yet.'**
  String get noDailyRecords;

  /// No description provided for @unknownDate.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownDate;

  /// No description provided for @currentRun.
  ///
  /// In en, this message translates to:
  /// **'Current Run'**
  String get currentRun;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'TIME'**
  String get timeLabel;

  /// No description provided for @paceLabel.
  ///
  /// In en, this message translates to:
  /// **'PACE'**
  String get paceLabel;

  /// No description provided for @distanceLabel.
  ///
  /// In en, this message translates to:
  /// **'DISTANCE'**
  String get distanceLabel;

  /// No description provided for @caloriesLabel.
  ///
  /// In en, this message translates to:
  /// **'CALORIES'**
  String get caloriesLabel;

  /// No description provided for @runningTracker.
  ///
  /// In en, this message translates to:
  /// **'Running Tracker'**
  String get runningTracker;

  /// No description provided for @activeRunMetrics.
  ///
  /// In en, this message translates to:
  /// **'Active run metrics'**
  String get activeRunMetrics;

  /// No description provided for @runInProgress.
  ///
  /// In en, this message translates to:
  /// **'Run in progress'**
  String get runInProgress;

  /// No description provided for @starting.
  ///
  /// In en, this message translates to:
  /// **'Starting...'**
  String get starting;

  /// No description provided for @notificationBody.
  ///
  /// In en, this message translates to:
  /// **'Time: {time}  |  Dist: {dist} km  |  Pace: {pace}/km'**
  String notificationBody(String time, String dist, String pace);

  /// No description provided for @developedBy.
  ///
  /// In en, this message translates to:
  /// **'Developed by'**
  String get developedBy;

  /// No description provided for @contactMe.
  ///
  /// In en, this message translates to:
  /// **'Contact Me'**
  String get contactMe;

  /// No description provided for @githubProfile.
  ///
  /// In en, this message translates to:
  /// **'GitHub Profile'**
  String get githubProfile;

  /// No description provided for @visitPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Visit my Portfolio'**
  String get visitPortfolio;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
