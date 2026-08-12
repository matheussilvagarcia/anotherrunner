// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get dashboard => 'Dashboard';

  @override
  String get steps => 'SCHRITTE';

  @override
  String get startRun => 'Lauf starten';

  @override
  String get syncHealthConnect => 'Health Connect synchronisieren';

  @override
  String get todayYouTook => 'heute bist du gelaufen';

  @override
  String get goodMorning => 'Guten Morgen';

  @override
  String get goodAfternoon => 'Guten Tag';

  @override
  String get goodEvening => 'Guten Abend';

  @override
  String get privacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get credits => 'Credits';

  @override
  String get language => 'Sprache';

  @override
  String get lastSyncOn => 'Letzte Cloud-Synchronisierung am';

  @override
  String get unlockPremium => 'Premium-Diagramme freischalten';

  @override
  String get premiumDesc =>
      'Erhalte Zugriff auf detaillierte Wochen- und Monatsdurchschnitte. Verfolge deinen Fortschritt bei Kalorien, Schritten, Distanz und Laufzeit visuell und erreiche deine Ziele schneller!';

  @override
  String get buyFor => 'Kaufen für';

  @override
  String get buyNow => 'Jetzt kaufen';

  @override
  String get maybeLater => 'Vielleicht später';

  @override
  String get syncSuccess => 'Daten erfolgreich mit der Cloud synchronisiert!';

  @override
  String get hcSyncSuccess =>
      'Daten synchronisiert! Läufe zum Verlauf hinzugefügt.';

  @override
  String get hcNoData => 'Keine Gesundheitsdaten für heute gefunden.';

  @override
  String get hcPermissionDenied =>
      'Berechtigung für den Zugriff auf Gesundheitsdaten verweigert.';

  @override
  String get capturedByHealthConnect => 'Erfasst von Health Connect';

  @override
  String get activityAverages => 'Aktivitätsdurchschnitte';

  @override
  String get last7Days => 'Letzte 7 Tage';

  @override
  String get monthlyAverages => 'Monatsdurchschnitte';

  @override
  String get chartSteps => 'Schritte';

  @override
  String get chartCalories => 'Kalorien (kcal)';

  @override
  String get chartDistance => 'Distanz (km)';

  @override
  String get chartDuration => 'Dauer (min)';

  @override
  String get locationPermissionRequired =>
      'Die Standortberechtigung ist erforderlich, um deinen Lauf zu verfolgen.';

  @override
  String get runHistory => 'Laufverlauf';

  @override
  String get authenticationRequired => 'Authentifizierung erforderlich';

  @override
  String get noRunsRecorded => 'Noch keine Läufe aufgezeichnet.';

  @override
  String shareRunMessage(String date) {
    return 'Sieh dir meinen Lauf in MovePass am $date an!';
  }

  @override
  String get dailyActivity => 'Tägliche Aktivität';

  @override
  String get noDailyRecords => 'Noch keine täglichen Aufzeichnungen.';

  @override
  String get unknownDate => 'Unbekannt';

  @override
  String get currentRun => 'Aktueller Lauf';

  @override
  String get timeLabel => 'ZEIT';

  @override
  String get paceLabel => 'PACE';

  @override
  String get distanceLabel => 'DISTANZ';

  @override
  String get caloriesLabel => 'KALORIEN';

  @override
  String get runningTracker => 'Lauf-Tracker';

  @override
  String get activeRunMetrics => 'Aktive Laufmetriken';

  @override
  String get runInProgress => 'Lauf im Gange';

  @override
  String get starting => 'Startet...';

  @override
  String notificationBody(String time, String dist, String pace) {
    return 'Zeit: $time  |  Dist: $dist km  |  Pace: $pace/km';
  }

  @override
  String get developedBy => 'Entwickelt von';

  @override
  String get contactMe => 'Kontaktiere mich';

  @override
  String get githubProfile => 'GitHub-Profil';

  @override
  String get visitPortfolio => 'Besuche mein Portfolio';

  @override
  String get fillAllFields => 'Bitte fülle alle Felder aus';

  @override
  String get passwordsNotMatch => 'Passwörter stimmen nicht überein!';

  @override
  String get passwordTooShort =>
      'Das Passwort muss mindestens 6 Zeichen lang sein';

  @override
  String get errorSendingOtp => 'Fehler beim Senden des Bestätigungscodes.';

  @override
  String get confirmEmailTitle => 'Bestätige deine E-Mail';

  @override
  String otpSentMessage(String email) {
    return 'Wir haben einen 6-stelligen Code an $email gesendet.';
  }

  @override
  String get otpCodeLabel => 'OTP-Code';

  @override
  String get cancelBtn => 'Abbrechen';

  @override
  String get confirmBtn => 'Bestätigen';

  @override
  String get invalidOtp => 'Ungültiger Code.';

  @override
  String get welcomeTo => 'Willkommen bei:';

  @override
  String get chooseLoginMethod => 'Wähle deine Anmeldemethode';

  @override
  String get emailLabel => 'E-Mail';

  @override
  String get passwordLabel => 'Passwort';

  @override
  String get confirmPasswordLabel => 'Passwort bestätigen';

  @override
  String get createAccountBtn => 'Konto erstellen';

  @override
  String get signInBtn => 'Anmelden';

  @override
  String get alreadyHaveAccount => 'Hast du bereits ein Konto? Anmelden';

  @override
  String get dontHaveAccount => 'Hast du noch kein Konto? Konto erstellen';

  @override
  String get signInWithGoogleBtn => 'Mit Google anmelden';

  @override
  String get emailInUseGoogle =>
      'Diese E-Mail ist mit Google verknüpft. Bitte melde dich mit Google an.';

  @override
  String get emailInUsePassword =>
      'E-Mail bereits registriert. Bitte melde dich an oder setze dein Passwort zurück.';

  @override
  String get forgotPasswordBtn => 'Passwort vergessen';

  @override
  String get fillEmailToReset =>
      'Gib deine E-Mail-Adresse ein, um das Passwort zurückzusetzen.';

  @override
  String get passwordResetSent =>
      'Link zum Zurücksetzen an deine E-Mail gesendet!';

  @override
  String get myCommunity => 'Meine Community';

  @override
  String get errorLoadingUser => 'Fehler beim Laden des Benutzers';

  @override
  String get loading => 'Lädt...';

  @override
  String get usernameInUse => 'Benutzername ist bereits vergeben.';

  @override
  String get invalidCode => 'Ungültiger Code.';

  @override
  String get accessCodeUpdated => 'Zugangscode aktualisiert!';

  @override
  String get createCommunity => 'Community erstellen';

  @override
  String get name => 'Name';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get create => 'Erstellen';

  @override
  String get joinCommunity => 'Community beitreten';

  @override
  String get join => 'Beitreten';

  @override
  String get joinUsingCode => 'Mit Code beitreten';

  @override
  String get chooseUsername => 'Wähle deinen Benutzernamen';

  @override
  String get yourUsername => 'Dein Benutzername';

  @override
  String get username => 'Benutzername';

  @override
  String get requiredField => 'Erforderlich';

  @override
  String get save => 'Speichern';

  @override
  String get update => 'Aktualisieren';

  @override
  String get communityNotFound => 'Community nicht gefunden.';

  @override
  String get code => 'Code';

  @override
  String get weeklyRanking => 'Wöchentliches Ranking';

  @override
  String get noMembers => 'Keine Mitglieder.';

  @override
  String get memberRole => 'Mitglied';

  @override
  String get superiorAdminRole => 'Hauptadministrator';

  @override
  String get adminRole => 'Administrator';

  @override
  String get you => 'Du';

  @override
  String get kickMember => 'Rauswerfen';

  @override
  String get makeAdmin => 'Zum Administrator machen';

  @override
  String get removeAdmin => 'Administratorrechte entfernen';

  @override
  String get transferSuperior => 'Hauptadministrator-Rolle übertragen';

  @override
  String timeLeft(int days, int hours) {
    return 'Noch $days Tag(e) und $hours Stunde(n)';
  }

  @override
  String get editCommunity => 'Community bearbeiten';

  @override
  String get newName => 'Neuer Name';

  @override
  String get editUsername => 'Benutzernamen bearbeiten';

  @override
  String get newUsername => 'Neuer Benutzername';

  @override
  String get usernameUpdated => 'Benutzername erfolgreich aktualisiert!';

  @override
  String get updateCodeTitle => 'Code aktualisieren';

  @override
  String get updateCodeDesc =>
      'Bist du sicher, dass du einen neuen Zugangscode generieren möchtest? Der alte Code funktioniert dann nicht mehr für neue Mitglieder.';

  @override
  String get attention => 'Achtung';

  @override
  String get transferSuperiorBeforeLeaving =>
      'Du musst die Hauptadministrator-Rolle an ein anderes Mitglied übertragen, bevor du die Community verlässt.';

  @override
  String get ok => 'OK';

  @override
  String get leaveCommunityTitle => 'Community verlassen';

  @override
  String get leaveCommunityLastMember =>
      'Du bist das letzte Mitglied. Wenn du gehst, wird die Community dauerhaft gelöscht. Bist du sicher?';

  @override
  String get leaveCommunityConfirm =>
      'Bist du sicher, dass du die Community verlassen möchtest?';

  @override
  String get leave => 'Verlassen';

  @override
  String get setRewardsTitle => 'Belohnung festlegen';

  @override
  String get firstPlace => '1. Platz';

  @override
  String get secondPlace => '2. Platz';

  @override
  String get thirdPlace => '3. Platz';

  @override
  String get weekDescription => 'Wochenbeschreibung';

  @override
  String get rankingHistoryTitle => 'Ranking-Verlauf';

  @override
  String get noHistoryYet => 'Noch kein Verlauf verfügbar.';

  @override
  String get unknownWeek => 'Unbekannte Woche';

  @override
  String get winner => 'Gewinner';

  @override
  String get prize => 'Preis';

  @override
  String get close => 'Schließen';

  @override
  String get weeklyRewards => 'Wöchentliche Belohnungen';

  @override
  String get noRewardsDefined => 'Keine Belohnungen festgelegt.';

  @override
  String get history => 'Verlauf';

  @override
  String get noWinner => 'Kein Gewinner';

  @override
  String get firstPlacePrefix => '🥇 1.: ';

  @override
  String get secondPlacePrefix => '🥈 2.: ';

  @override
  String get thirdPlacePrefix => '🥉 3.: ';

  @override
  String get locationPermissionTitle => 'Standortberechtigung';

  @override
  String get locationPermissionDesc =>
      'MovePass erfasst Standortdaten, um die Verfolgung deiner Route sowie die Berechnung von Geschwindigkeit und Distanz während des Laufens zu ermöglichen, auch wenn die App geschlossen ist oder nicht verwendet wird.';

  @override
  String get decline => 'Ablehnen';

  @override
  String get understood => 'Verstanden';

  @override
  String get deleteAccount => 'Konto löschen';

  @override
  String get deleteAccountTitle => 'Konto löschen?';

  @override
  String get deleteAccountContent =>
      'Dadurch werden alle deine Daten gelöscht. Bist du sicher?';

  @override
  String get continueAction => 'Weiter';

  @override
  String get finalWarningTitle => 'Letzte Warnung';

  @override
  String get finalWarningContent =>
      'Diese Aktion ist unwiderruflich. Alle deine Läufe, dein Schrittverlauf und dein Profil werden dauerhaft vom Server gelöscht.';

  @override
  String get deletePermanently => 'Dauerhaft löschen';

  @override
  String get deleteAccountError =>
      'Fehler beim Löschen des Kontos. Bitte melde dich erneut an und versuche es noch einmal.';
}
