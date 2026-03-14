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
  String get todayYouTook => 'today you walked';

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
  String get capturedByHealthConnect => 'Captured by Health Connect';

  @override
  String get activityAverages => 'Activity Averages';

  @override
  String get last7Days => 'Last 7 Days';

  @override
  String get monthlyAverages => 'Monthly Averages';

  @override
  String get chartSteps => 'Steps';

  @override
  String get chartCalories => 'Calories (kcal)';

  @override
  String get chartDistance => 'Distance (km)';

  @override
  String get chartDuration => 'Duration (min)';

  @override
  String get locationPermissionRequired =>
      'Location permission is required to track your run.';

  @override
  String get runHistory => 'Run History';

  @override
  String get authenticationRequired => 'Authentication required';

  @override
  String get noRunsRecorded => 'No runs recorded yet.';

  @override
  String shareRunMessage(String date) {
    return 'Check out my run on AnotherRunner on $date!';
  }

  @override
  String get dailyActivity => 'Daily Activity';

  @override
  String get noDailyRecords => 'No daily records yet.';

  @override
  String get unknownDate => 'Unknown';

  @override
  String get currentRun => 'Current Run';

  @override
  String get timeLabel => 'TIME';

  @override
  String get paceLabel => 'PACE';

  @override
  String get distanceLabel => 'DISTANCE';

  @override
  String get caloriesLabel => 'CALORIES';

  @override
  String get runningTracker => 'Running Tracker';

  @override
  String get activeRunMetrics => 'Active run metrics';

  @override
  String get runInProgress => 'Run in progress';

  @override
  String get starting => 'Starting...';

  @override
  String notificationBody(String time, String dist, String pace) {
    return 'Time: $time  |  Dist: $dist km  |  Pace: $pace/km';
  }

  @override
  String get developedBy => 'Developed by';

  @override
  String get contactMe => 'Contact Me';

  @override
  String get githubProfile => 'GitHub Profile';

  @override
  String get visitPortfolio => 'Visit my Portfolio';

  @override
  String get fillAllFields => 'Please fill all fields';

  @override
  String get passwordsNotMatch => 'Passwords do not match!';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get errorSendingOtp => 'Error sending verification code to email.';

  @override
  String get confirmEmailTitle => 'Confirm your Email';

  @override
  String otpSentMessage(String email) {
    return 'We sent a 6-digit code to $email.';
  }

  @override
  String get otpCodeLabel => 'OTP Code';

  @override
  String get cancelBtn => 'Cancel';

  @override
  String get confirmBtn => 'Confirm';

  @override
  String get invalidOtp => 'Invalid Code.';

  @override
  String get welcomeTo => 'Welcome to:';

  @override
  String get chooseLoginMethod => 'Choose your login method';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get createAccountBtn => 'Create Account';

  @override
  String get signInBtn => 'Sign In';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign In';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Create Account';

  @override
  String get signInWithGoogleBtn => 'Sign in with Google';

  @override
  String get emailInUseGoogle =>
      'This email is registered with Google. Please Sign in with Google.';

  @override
  String get emailInUsePassword =>
      'Email already in use. Please sign in or reset your password.';

  @override
  String get forgotPasswordBtn => 'Forgot Password?';

  @override
  String get fillEmailToReset => 'Enter your email to reset the password.';

  @override
  String get passwordResetSent => 'Password reset link sent to your email!';
}
