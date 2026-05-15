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
  String get steps => 'steps';

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

  @override
  String get myCommunity => 'My Community';

  @override
  String get errorLoadingUser => 'Error loading user';

  @override
  String get loading => 'Loading...';

  @override
  String get usernameInUse => 'Username already in use.';

  @override
  String get invalidCode => 'Invalid code.';

  @override
  String get accessCodeUpdated => 'Access code updated!';

  @override
  String get createCommunity => 'Create Community';

  @override
  String get name => 'Name';

  @override
  String get cancel => 'Cancel';

  @override
  String get create => 'Create';

  @override
  String get joinCommunity => 'Join Community';

  @override
  String get join => 'Join';

  @override
  String get joinUsingCode => 'Join using Code';

  @override
  String get chooseUsername => 'Choose your Username';

  @override
  String get yourUsername => 'Your Username';

  @override
  String get username => 'Username';

  @override
  String get requiredField => 'Required';

  @override
  String get save => 'Save';

  @override
  String get update => 'Update';

  @override
  String get communityNotFound => 'Community not found.';

  @override
  String get code => 'Code';

  @override
  String get weeklyRanking => 'Weekly Ranking';

  @override
  String get noMembers => 'No members.';

  @override
  String get memberRole => 'Member';

  @override
  String get superiorAdminRole => 'Superior Admin';

  @override
  String get adminRole => 'Admin';

  @override
  String get you => 'You';

  @override
  String get kickMember => 'Kick';

  @override
  String get makeAdmin => 'Make Admin';

  @override
  String get removeAdmin => 'Remove Admin';

  @override
  String get transferSuperior => 'Transfer Superior Role';

  @override
  String timeLeft(int days, int hours) {
    return '$days day(s) and $hours hour(s) left';
  }

  @override
  String get editCommunity => 'Edit Community';

  @override
  String get newName => 'New Name';

  @override
  String get editUsername => 'Edit Username';

  @override
  String get newUsername => 'New Username';

  @override
  String get usernameUpdated => 'Username updated successfully!';

  @override
  String get updateCodeTitle => 'Update Code';

  @override
  String get updateCodeDesc =>
      'Are you sure you want to generate a new access code? The old code will no longer work for new members.';

  @override
  String get attention => 'Attention';

  @override
  String get transferSuperiorBeforeLeaving =>
      'You need to pass the Superior Admin role to another member before leaving the community.';

  @override
  String get ok => 'OK';

  @override
  String get leaveCommunityTitle => 'Leave Community';

  @override
  String get leaveCommunityLastMember =>
      'You are the last member. If you leave, the community will be permanently deleted. Are you sure?';

  @override
  String get leaveCommunityConfirm =>
      'Are you sure you want to leave the community?';

  @override
  String get leave => 'Leave';

  @override
  String get setRewardsTitle => 'Set Rewards';

  @override
  String get firstPlace => '1st Place';

  @override
  String get secondPlace => '2nd Place';

  @override
  String get thirdPlace => '3rd Place';

  @override
  String get weekDescription => 'Week Description';

  @override
  String get rankingHistoryTitle => 'Ranking History';

  @override
  String get noHistoryYet => 'No history available yet.';

  @override
  String get unknownWeek => 'Unknown Week';

  @override
  String get winner => 'Winner';

  @override
  String get prize => 'Prize';

  @override
  String get close => 'Close';

  @override
  String get weeklyRewards => 'Weekly Rewards';

  @override
  String get noRewardsDefined => 'No rewards defined.';

  @override
  String get history => 'History';

  @override
  String get noWinner => 'No Winner';

  @override
  String get firstPlacePrefix => '🥇 1st: ';

  @override
  String get secondPlacePrefix => '🥈 2nd: ';

  @override
  String get thirdPlacePrefix => '🥉 3rd: ';

  @override
  String get locationPermissionTitle => 'Location Permission';

  @override
  String get locationPermissionDesc =>
      'YARA collects location data to enable tracking of your route, calculating speed and distance during your runs, even when the app is closed or not in use.';

  @override
  String get decline => 'Decline';

  @override
  String get understood => 'Got it';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountTitle => 'Delete account?';

  @override
  String get deleteAccountContent =>
      'This will delete all your data. Are you sure?';

  @override
  String get continueAction => 'Continue';

  @override
  String get finalWarningTitle => 'Final Warning';

  @override
  String get finalWarningContent =>
      'This action is irreversible. All your runs, step history, and profile will be permanently deleted from the server.';

  @override
  String get deletePermanently => 'Delete Permanently';

  @override
  String get deleteAccountError =>
      'Error deleting account. Please log in again and try again.';
}
