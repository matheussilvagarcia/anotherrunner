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
  /// **'steps'**
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
  /// **'today you walked'**
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

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get fillAllFields;

  /// No description provided for @passwordsNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match!'**
  String get passwordsNotMatch;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @errorSendingOtp.
  ///
  /// In en, this message translates to:
  /// **'Error sending verification code to email.'**
  String get errorSendingOtp;

  /// No description provided for @confirmEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your Email'**
  String get confirmEmailTitle;

  /// No description provided for @otpSentMessage.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to {email}.'**
  String otpSentMessage(String email);

  /// No description provided for @otpCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'OTP Code'**
  String get otpCodeLabel;

  /// No description provided for @cancelBtn.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelBtn;

  /// No description provided for @confirmBtn.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmBtn;

  /// No description provided for @invalidOtp.
  ///
  /// In en, this message translates to:
  /// **'Invalid Code.'**
  String get invalidOtp;

  /// No description provided for @welcomeTo.
  ///
  /// In en, this message translates to:
  /// **'Welcome to:'**
  String get welcomeTo;

  /// No description provided for @chooseLoginMethod.
  ///
  /// In en, this message translates to:
  /// **'Choose your login method'**
  String get chooseLoginMethod;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @createAccountBtn.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountBtn;

  /// No description provided for @signInBtn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInBtn;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign In'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Create Account'**
  String get dontHaveAccount;

  /// No description provided for @signInWithGoogleBtn.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogleBtn;

  /// No description provided for @emailInUseGoogle.
  ///
  /// In en, this message translates to:
  /// **'This email is registered with Google. Please Sign in with Google.'**
  String get emailInUseGoogle;

  /// No description provided for @emailInUsePassword.
  ///
  /// In en, this message translates to:
  /// **'Email already in use. Please sign in or reset your password.'**
  String get emailInUsePassword;

  /// No description provided for @forgotPasswordBtn.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordBtn;

  /// No description provided for @fillEmailToReset.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to reset the password.'**
  String get fillEmailToReset;

  /// No description provided for @passwordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent to your email!'**
  String get passwordResetSent;

  /// No description provided for @myCommunity.
  ///
  /// In en, this message translates to:
  /// **'My Community'**
  String get myCommunity;

  /// No description provided for @errorLoadingUser.
  ///
  /// In en, this message translates to:
  /// **'Error loading user'**
  String get errorLoadingUser;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @usernameInUse.
  ///
  /// In en, this message translates to:
  /// **'Username already in use.'**
  String get usernameInUse;

  /// No description provided for @invalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid code.'**
  String get invalidCode;

  /// No description provided for @accessCodeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Access code updated!'**
  String get accessCodeUpdated;

  /// No description provided for @createCommunity.
  ///
  /// In en, this message translates to:
  /// **'Create Community'**
  String get createCommunity;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @joinCommunity.
  ///
  /// In en, this message translates to:
  /// **'Join Community'**
  String get joinCommunity;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @joinUsingCode.
  ///
  /// In en, this message translates to:
  /// **'Join using Code'**
  String get joinUsingCode;

  /// No description provided for @chooseUsername.
  ///
  /// In en, this message translates to:
  /// **'Choose your Username'**
  String get chooseUsername;

  /// No description provided for @yourUsername.
  ///
  /// In en, this message translates to:
  /// **'Your Username'**
  String get yourUsername;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @communityNotFound.
  ///
  /// In en, this message translates to:
  /// **'Community not found.'**
  String get communityNotFound;

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// No description provided for @weeklyRanking.
  ///
  /// In en, this message translates to:
  /// **'Weekly Ranking'**
  String get weeklyRanking;

  /// No description provided for @noMembers.
  ///
  /// In en, this message translates to:
  /// **'No members.'**
  String get noMembers;

  /// No description provided for @memberRole.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get memberRole;

  /// No description provided for @superiorAdminRole.
  ///
  /// In en, this message translates to:
  /// **'Superior Admin'**
  String get superiorAdminRole;

  /// No description provided for @adminRole.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get adminRole;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @kickMember.
  ///
  /// In en, this message translates to:
  /// **'Kick'**
  String get kickMember;

  /// No description provided for @makeAdmin.
  ///
  /// In en, this message translates to:
  /// **'Make Admin'**
  String get makeAdmin;

  /// No description provided for @removeAdmin.
  ///
  /// In en, this message translates to:
  /// **'Remove Admin'**
  String get removeAdmin;

  /// No description provided for @transferSuperior.
  ///
  /// In en, this message translates to:
  /// **'Transfer Superior Role'**
  String get transferSuperior;

  /// No description provided for @timeLeft.
  ///
  /// In en, this message translates to:
  /// **'{days} day(s) and {hours} hour(s) left'**
  String timeLeft(int days, int hours);

  /// No description provided for @editCommunity.
  ///
  /// In en, this message translates to:
  /// **'Edit Community'**
  String get editCommunity;

  /// No description provided for @newName.
  ///
  /// In en, this message translates to:
  /// **'New Name'**
  String get newName;

  /// No description provided for @editUsername.
  ///
  /// In en, this message translates to:
  /// **'Edit Username'**
  String get editUsername;

  /// No description provided for @newUsername.
  ///
  /// In en, this message translates to:
  /// **'New Username'**
  String get newUsername;

  /// No description provided for @usernameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Username updated successfully!'**
  String get usernameUpdated;

  /// No description provided for @updateCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Code'**
  String get updateCodeTitle;

  /// No description provided for @updateCodeDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to generate a new access code? The old code will no longer work for new members.'**
  String get updateCodeDesc;

  /// No description provided for @attention.
  ///
  /// In en, this message translates to:
  /// **'Attention'**
  String get attention;

  /// No description provided for @transferSuperiorBeforeLeaving.
  ///
  /// In en, this message translates to:
  /// **'You need to pass the Superior Admin role to another member before leaving the community.'**
  String get transferSuperiorBeforeLeaving;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @leaveCommunityTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave Community'**
  String get leaveCommunityTitle;

  /// No description provided for @leaveCommunityLastMember.
  ///
  /// In en, this message translates to:
  /// **'You are the last member. If you leave, the community will be permanently deleted. Are you sure?'**
  String get leaveCommunityLastMember;

  /// No description provided for @leaveCommunityConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave the community?'**
  String get leaveCommunityConfirm;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @setRewardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Rewards'**
  String get setRewardsTitle;

  /// No description provided for @firstPlace.
  ///
  /// In en, this message translates to:
  /// **'1st Place'**
  String get firstPlace;

  /// No description provided for @secondPlace.
  ///
  /// In en, this message translates to:
  /// **'2nd Place'**
  String get secondPlace;

  /// No description provided for @thirdPlace.
  ///
  /// In en, this message translates to:
  /// **'3rd Place'**
  String get thirdPlace;

  /// No description provided for @weekDescription.
  ///
  /// In en, this message translates to:
  /// **'Week Description'**
  String get weekDescription;

  /// No description provided for @rankingHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Ranking History'**
  String get rankingHistoryTitle;

  /// No description provided for @noHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No history available yet.'**
  String get noHistoryYet;

  /// No description provided for @unknownWeek.
  ///
  /// In en, this message translates to:
  /// **'Unknown Week'**
  String get unknownWeek;

  /// No description provided for @winner.
  ///
  /// In en, this message translates to:
  /// **'Winner'**
  String get winner;

  /// No description provided for @prize.
  ///
  /// In en, this message translates to:
  /// **'Prize'**
  String get prize;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @weeklyRewards.
  ///
  /// In en, this message translates to:
  /// **'Weekly Rewards'**
  String get weeklyRewards;

  /// No description provided for @noRewardsDefined.
  ///
  /// In en, this message translates to:
  /// **'No rewards defined.'**
  String get noRewardsDefined;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @noWinner.
  ///
  /// In en, this message translates to:
  /// **'No Winner'**
  String get noWinner;

  /// No description provided for @firstPlacePrefix.
  ///
  /// In en, this message translates to:
  /// **'🥇 1st: '**
  String get firstPlacePrefix;

  /// No description provided for @secondPlacePrefix.
  ///
  /// In en, this message translates to:
  /// **'🥈 2nd: '**
  String get secondPlacePrefix;

  /// No description provided for @thirdPlacePrefix.
  ///
  /// In en, this message translates to:
  /// **'🥉 3rd: '**
  String get thirdPlacePrefix;

  /// No description provided for @locationPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Permission'**
  String get locationPermissionTitle;

  /// No description provided for @locationPermissionDesc.
  ///
  /// In en, this message translates to:
  /// **'YARA collects location data to enable tracking of your route, calculating speed and distance during your runs, even when the app is closed or not in use.'**
  String get locationPermissionDesc;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @understood.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get understood;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountContent.
  ///
  /// In en, this message translates to:
  /// **'This will delete all your data. Are you sure?'**
  String get deleteAccountContent;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @finalWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Final Warning'**
  String get finalWarningTitle;

  /// No description provided for @finalWarningContent.
  ///
  /// In en, this message translates to:
  /// **'This action is irreversible. All your runs, step history, and profile will be permanently deleted from the server.'**
  String get finalWarningContent;

  /// No description provided for @deletePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete Permanently'**
  String get deletePermanently;

  /// No description provided for @deleteAccountError.
  ///
  /// In en, this message translates to:
  /// **'Error deleting account. Please log in again and try again.'**
  String get deleteAccountError;
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
