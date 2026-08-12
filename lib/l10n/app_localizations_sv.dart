// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get dashboard => 'Översikt';

  @override
  String get steps => 'STEG';

  @override
  String get startRun => 'Starta löpning';

  @override
  String get syncHealthConnect => 'Synkronisera Health Connect';

  @override
  String get todayYouTook => 'idag har du gått';

  @override
  String get goodMorning => 'God morgon';

  @override
  String get goodAfternoon => 'God eftermiddag';

  @override
  String get goodEvening => 'God kväll';

  @override
  String get privacyPolicy => 'Integritetspolicy';

  @override
  String get credits => 'Krediter';

  @override
  String get language => 'Språk';

  @override
  String get lastSyncOn => 'Senaste molnsynkronisering den';

  @override
  String get unlockPremium => 'Lås upp Premium-diagram';

  @override
  String get premiumDesc =>
      'Få tillgång till detaljerade vecko- och månadsgenomsnitt. Följ dina framsteg inom kalorier, steg, distans och löptid visuellt och nå dina mål snabbare!';

  @override
  String get buyFor => 'Köp för';

  @override
  String get buyNow => 'Köp nu';

  @override
  String get maybeLater => 'Kanske senare';

  @override
  String get syncSuccess => 'Data har synkroniserats till molnet!';

  @override
  String get hcSyncSuccess =>
      'Data synkroniserad! Löprundor har lagts till i historiken.';

  @override
  String get hcNoData => 'Inga hälsodata hittades för idag.';

  @override
  String get hcPermissionDenied => 'Åtkomst nekad till hälsodata.';

  @override
  String get capturedByHealthConnect => 'Registrerat av Health Connect';

  @override
  String get activityAverages => 'Aktivitetsgenomsnitt';

  @override
  String get last7Days => 'Senaste 7 dagarna';

  @override
  String get monthlyAverages => 'Månadsgenomsnitt';

  @override
  String get chartSteps => 'Steg';

  @override
  String get chartCalories => 'Kalorier (kcal)';

  @override
  String get chartDistance => 'Distans (km)';

  @override
  String get chartDuration => 'Varaktighet (min)';

  @override
  String get locationPermissionRequired =>
      'Platsbehörighet krävs för att spåra din löprunda.';

  @override
  String get runHistory => 'Löphistorik';

  @override
  String get authenticationRequired => 'Autentisering krävs';

  @override
  String get noRunsRecorded => 'Inga löprundor registrerade ännu.';

  @override
  String shareRunMessage(String date) {
    return 'Kolla in min löprunda på MovePass den $date!';
  }

  @override
  String get dailyActivity => 'Daglig aktivitet';

  @override
  String get noDailyRecords => 'Inga dagliga registreringar ännu.';

  @override
  String get unknownDate => 'Okänt';

  @override
  String get currentRun => 'Aktuell löprunda';

  @override
  String get timeLabel => 'TID';

  @override
  String get paceLabel => 'TEMPO';

  @override
  String get distanceLabel => 'DISTANS';

  @override
  String get caloriesLabel => 'KALORIER';

  @override
  String get runningTracker => 'Löpspårare';

  @override
  String get activeRunMetrics => 'Aktiva löpmetriker';

  @override
  String get runInProgress => 'Löpning pågår';

  @override
  String get starting => 'Startar...';

  @override
  String notificationBody(String time, String dist, String pace) {
    return 'Tid: $time  |  Dist: $dist km  |  Tempo: $pace/km';
  }

  @override
  String get developedBy => 'Utvecklad av';

  @override
  String get contactMe => 'Kontakta mig';

  @override
  String get githubProfile => 'GitHub-profil';

  @override
  String get visitPortfolio => 'Besök min portfolio';

  @override
  String get fillAllFields => 'Vänligen fyll i alla fält';

  @override
  String get passwordsNotMatch => 'Lösenorden matchar inte!';

  @override
  String get passwordTooShort => 'Lösenordet måste vara minst 6 tecken';

  @override
  String get errorSendingOtp => 'Fel vid sändning av verifieringskod.';

  @override
  String get confirmEmailTitle => 'Bekräfta din e-post';

  @override
  String otpSentMessage(String email) {
    return 'Vi har skickat en 6-siffrig kod till $email.';
  }

  @override
  String get otpCodeLabel => 'OTP-kod';

  @override
  String get cancelBtn => 'Avbryt';

  @override
  String get confirmBtn => 'Bekräfta';

  @override
  String get invalidOtp => 'Ogiltig kod.';

  @override
  String get welcomeTo => 'Välkommen till:';

  @override
  String get chooseLoginMethod => 'Välj inloggningsmetod';

  @override
  String get emailLabel => 'E-post';

  @override
  String get passwordLabel => 'Lösenord';

  @override
  String get confirmPasswordLabel => 'Bekräfta lösenord';

  @override
  String get createAccountBtn => 'Skapa konto';

  @override
  String get signInBtn => 'Logga in';

  @override
  String get alreadyHaveAccount => 'Har du redan ett konto? Logga in';

  @override
  String get dontHaveAccount => 'Har du inget konto? Skapa konto';

  @override
  String get signInWithGoogleBtn => 'Logga in med Google';

  @override
  String get emailInUseGoogle =>
      'Den här e-postadressen är kopplad till Google. Vänligen logga in med Google.';

  @override
  String get emailInUsePassword =>
      'E-postadressen är redan registrerad. Logga in eller återställ ditt lösenord.';

  @override
  String get forgotPasswordBtn => 'Glömt lösenord';

  @override
  String get fillEmailToReset =>
      'Fyll i din e-postadress för att återställa lösenordet.';

  @override
  String get passwordResetSent => 'Återställningslänk skickad till din e-post!';

  @override
  String get myCommunity => 'Min gemenskap';

  @override
  String get errorLoadingUser => 'Fel vid inläsning av användare';

  @override
  String get loading => 'Laddar...';

  @override
  String get usernameInUse => 'Användarnamnet används redan.';

  @override
  String get invalidCode => 'Ogiltig kod.';

  @override
  String get accessCodeUpdated => 'Åtkomstkoden har uppdaterats!';

  @override
  String get createCommunity => 'Skapa gemenskap';

  @override
  String get name => 'Namn';

  @override
  String get cancel => 'Avbryt';

  @override
  String get create => 'Skapa';

  @override
  String get joinCommunity => 'Gå med i gemenskap';

  @override
  String get join => 'Gå med';

  @override
  String get joinUsingCode => 'Gå med via kod';

  @override
  String get chooseUsername => 'Välj ditt användarnamn';

  @override
  String get yourUsername => 'Ditt användarnamn';

  @override
  String get username => 'Användarnamn';

  @override
  String get requiredField => 'Obligatoriskt';

  @override
  String get save => 'Spara';

  @override
  String get update => 'Uppdatera';

  @override
  String get communityNotFound => 'Gemenskapen hittades inte.';

  @override
  String get code => 'Kod';

  @override
  String get weeklyRanking => 'Veckans ranking';

  @override
  String get noMembers => 'Inga medlemmar.';

  @override
  String get memberRole => 'Medlem';

  @override
  String get superiorAdminRole => 'Huvudadministratör';

  @override
  String get adminRole => 'Administratör';

  @override
  String get you => 'Du';

  @override
  String get kickMember => 'Kasta ut';

  @override
  String get makeAdmin => 'Gör till administratör';

  @override
  String get removeAdmin => 'Ta bort administratör';

  @override
  String get transferSuperior => 'Överför huvudadministratör';

  @override
  String timeLeft(int days, int hours) {
    return 'Det är $days dag(ar) och $hours timme/timmar kvar';
  }

  @override
  String get editCommunity => 'Redigera gemenskap';

  @override
  String get newName => 'Nytt namn';

  @override
  String get editUsername => 'Redigera användarnamn';

  @override
  String get newUsername => 'Nytt användarnamn';

  @override
  String get usernameUpdated => 'Användarnamn uppdaterat!';

  @override
  String get updateCodeTitle => 'Uppdatera kod';

  @override
  String get updateCodeDesc =>
      'Är du säker på att du vill generera en ny åtkomstkod? Den gamla koden kommer inte längre att fungera för nya medlemmar.';

  @override
  String get attention => 'Observera';

  @override
  String get transferSuperiorBeforeLeaving =>
      'Du måste överföra huvudadministratörsrollen till en annan medlem innan du lämnar gemenskapen.';

  @override
  String get ok => 'OK';

  @override
  String get leaveCommunityTitle => 'Lämna gemenskap';

  @override
  String get leaveCommunityLastMember =>
      'Du är den sista medlemmen. Om du lämnar kommer gemenskapen att raderas permanent. Är du säker?';

  @override
  String get leaveCommunityConfirm =>
      'Är du säker på att du vill lämna gemenskapen?';

  @override
  String get leave => 'Lämna';

  @override
  String get setRewardsTitle => 'Ange belöning';

  @override
  String get firstPlace => '1:a plats';

  @override
  String get secondPlace => '2:a plats';

  @override
  String get thirdPlace => '3:e plats';

  @override
  String get weekDescription => 'Veckobeskrivning';

  @override
  String get rankingHistoryTitle => 'Rankinghistorik';

  @override
  String get noHistoryYet => 'Ingen historik tillgänglig ännu.';

  @override
  String get unknownWeek => 'Okänd vecka';

  @override
  String get winner => 'Vinnare';

  @override
  String get prize => 'Pris';

  @override
  String get close => 'Stäng';

  @override
  String get weeklyRewards => 'Veckans belöningar';

  @override
  String get noRewardsDefined => 'Inga belöningar definierade.';

  @override
  String get history => 'Historik';

  @override
  String get noWinner => 'Ingen vinnare';

  @override
  String get firstPlacePrefix => '🥇 1:a: ';

  @override
  String get secondPlacePrefix => '🥈 2:a: ';

  @override
  String get thirdPlacePrefix => '🥉 3:a: ';

  @override
  String get locationPermissionTitle => 'Platsbehörighet';

  @override
  String get locationPermissionDesc =>
      'MovePass samlar in platsdata för att möjliggöra spårning av din rutt, beräkning av hastighet och distans under löprundor, även när appen är stängd eller inte används.';

  @override
  String get decline => 'Neka';

  @override
  String get understood => 'Förstått';

  @override
  String get deleteAccount => 'Radera konto';

  @override
  String get deleteAccountTitle => 'Radera konto?';

  @override
  String get deleteAccountContent =>
      'Detta kommer att radera alla dina data. Är du säker?';

  @override
  String get continueAction => 'Fortsätt';

  @override
  String get finalWarningTitle => 'Sista varningen';

  @override
  String get finalWarningContent =>
      'Denna åtgärd är oåterkallelig. Alla dina löprundor, din steghistorik och din profil kommer att raderas permanent från servern.';

  @override
  String get deletePermanently => 'Radera permanent';

  @override
  String get deleteAccountError =>
      'Fel vid radering av konto. Vänligen logga in igen och försök på nytt.';
}
