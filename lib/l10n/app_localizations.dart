import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

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
    Locale('id'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'AmbaLearn'**
  String get appName;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeMessage;

  /// No description provided for @startExam.
  ///
  /// In en, this message translates to:
  /// **'Start Exam'**
  String get startExam;

  /// No description provided for @continueLearning.
  ///
  /// In en, this message translates to:
  /// **'Continue Learning'**
  String get continueLearning;

  /// No description provided for @courses.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get courses;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @examCalibration.
  ///
  /// In en, this message translates to:
  /// **'Calibration Check'**
  String get examCalibration;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera access is required for proctoring.'**
  String get cameraPermissionRequired;

  /// No description provided for @statusWaitingConnection.
  ///
  /// In en, this message translates to:
  /// **'Waiting for connection...'**
  String get statusWaitingConnection;

  /// No description provided for @statusWaitingFace.
  ///
  /// In en, this message translates to:
  /// **'Waiting for face detection...'**
  String get statusWaitingFace;

  /// No description provided for @statusFaceNotDetected.
  ///
  /// In en, this message translates to:
  /// **'Face not detected'**
  String get statusFaceNotDetected;

  /// No description provided for @statusMultipleFaces.
  ///
  /// In en, this message translates to:
  /// **'Multiple faces detected'**
  String get statusMultipleFaces;

  /// No description provided for @statusHeadAlert.
  ///
  /// In en, this message translates to:
  /// **'Please face the screen'**
  String get statusHeadAlert;

  /// No description provided for @statusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready for exam ✅'**
  String get statusReady;

  /// No description provided for @examViolationWarning.
  ///
  /// In en, this message translates to:
  /// **'⚠️ CHEATING DETECTED'**
  String get examViolationWarning;

  /// No description provided for @examViolationMessage.
  ///
  /// In en, this message translates to:
  /// **'Please keep your eyes on the screen!'**
  String get examViolationMessage;

  /// No description provided for @examTerminated.
  ///
  /// In en, this message translates to:
  /// **'Exam Terminated'**
  String get examTerminated;

  /// No description provided for @examTerminatedMessage.
  ///
  /// In en, this message translates to:
  /// **'VIOLATION LIMIT EXCEEDED.\nYour exam is being automatically submitted.'**
  String get examTerminatedMessage;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// No description provided for @signInContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInContinue;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @continueGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueGoogle;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @signUpStarted.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get you started'**
  String get signUpStarted;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get enterUsername;

  /// No description provided for @alreadyAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyAccount;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking...'**
  String get thinking;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// No description provided for @monitoringActive.
  ///
  /// In en, this message translates to:
  /// **'Monitoring Active'**
  String get monitoringActive;

  /// No description provided for @faceNotDetected.
  ///
  /// In en, this message translates to:
  /// **'Face Not Detected'**
  String get faceNotDetected;

  /// No description provided for @initializing.
  ///
  /// In en, this message translates to:
  /// **'Initializing...'**
  String get initializing;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @cameraInitialized.
  ///
  /// In en, this message translates to:
  /// **'Camera initialized'**
  String get cameraInitialized;

  /// No description provided for @noCameras.
  ///
  /// In en, this message translates to:
  /// **'No cameras available'**
  String get noCameras;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @submitExam.
  ///
  /// In en, this message translates to:
  /// **'Submit Exam'**
  String get submitExam;

  /// No description provided for @submitExamQuestion.
  ///
  /// In en, this message translates to:
  /// **'Submit Exam?'**
  String get submitExamQuestion;

  /// No description provided for @submitExamConfirmAll.
  ///
  /// In en, this message translates to:
  /// **'You have answered all questions. Submit your exam now?'**
  String get submitExamConfirmAll;

  /// No description provided for @submitExamConfirmPartial.
  ///
  /// In en, this message translates to:
  /// **'You have answered {answered} of {total} questions. Unanswered questions will be marked as incorrect. Submit anyway?'**
  String submitExamConfirmPartial(int answered, int total);

  /// No description provided for @failedToSubmit.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit exam'**
  String get failedToSubmit;

  /// No description provided for @exitExam.
  ///
  /// In en, this message translates to:
  /// **'Exit Exam?'**
  String get exitExam;

  /// No description provided for @exitExamConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit? Your progress will be lost.'**
  String get exitExamConfirm;

  /// No description provided for @stay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get stay;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @loadingExam.
  ///
  /// In en, this message translates to:
  /// **'Loading exam...'**
  String get loadingExam;

  /// No description provided for @failedToLoadExam.
  ///
  /// In en, this message translates to:
  /// **'Failed to load exam'**
  String get failedToLoadExam;

  /// No description provided for @failedToLoadExamRetry.
  ///
  /// In en, this message translates to:
  /// **'Failed to load exam. Please try again.'**
  String get failedToLoadExamRetry;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @violationStatus.
  ///
  /// In en, this message translates to:
  /// **'Violation: {count}/{max}'**
  String violationStatus(int count, int max);

  /// No description provided for @cheatingDetected.
  ///
  /// In en, this message translates to:
  /// **'⚠️ CHEATING DETECTED'**
  String get cheatingDetected;

  /// No description provided for @keepEyesOnScreen.
  ///
  /// In en, this message translates to:
  /// **'{detail}\nPlease keep your eyes on the screen!'**
  String keepEyesOnScreen(String detail);

  /// No description provided for @questionTitle.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String questionTitle(int current, int total);

  /// No description provided for @answeredStatus.
  ///
  /// In en, this message translates to:
  /// **'Answered: {answered}/{total}'**
  String answeredStatus(int answered, int total);

  /// No description provided for @questionHeader.
  ///
  /// In en, this message translates to:
  /// **'Question {number}'**
  String questionHeader(int number);

  /// No description provided for @submitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get submitting;

  /// No description provided for @calibrationCheck.
  ///
  /// In en, this message translates to:
  /// **'Calibration Check'**
  String get calibrationCheck;

  /// No description provided for @waitingForConnection.
  ///
  /// In en, this message translates to:
  /// **'Waiting for connection...'**
  String get waitingForConnection;

  /// No description provided for @waitingForFace.
  ///
  /// In en, this message translates to:
  /// **'Waiting for face detection...'**
  String get waitingForFace;

  /// No description provided for @disconnectedStart.
  ///
  /// In en, this message translates to:
  /// **'Disconnected from Anti-Cheat Service'**
  String get disconnectedStart;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @faceNotDetectedStatus.
  ///
  /// In en, this message translates to:
  /// **'Face not detected'**
  String get faceNotDetectedStatus;

  /// No description provided for @multipleFacesStatus.
  ///
  /// In en, this message translates to:
  /// **'Multiple faces detected'**
  String get multipleFacesStatus;

  /// No description provided for @faceScreenStatus.
  ///
  /// In en, this message translates to:
  /// **'Please face the screen'**
  String get faceScreenStatus;

  /// No description provided for @readyForExam.
  ///
  /// In en, this message translates to:
  /// **'Ready for exam ✅'**
  String get readyForExam;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission Denied'**
  String get permissionDenied;

  /// No description provided for @cameraPermissionMsg.
  ///
  /// In en, this message translates to:
  /// **'Camera access is required for proctoring.'**
  String get cameraPermissionMsg;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permissionRequired;

  /// No description provided for @enableCameraMsg.
  ///
  /// In en, this message translates to:
  /// **'Please enable camera access in settings.'**
  String get enableCameraMsg;

  /// No description provided for @examPermission.
  ///
  /// In en, this message translates to:
  /// **'Exam Permission'**
  String get examPermission;

  /// No description provided for @cameraAccessRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera Access Required'**
  String get cameraAccessRequired;

  /// No description provided for @grantAccess.
  ///
  /// In en, this message translates to:
  /// **'Grant Access'**
  String get grantAccess;

  /// No description provided for @examResults.
  ///
  /// In en, this message translates to:
  /// **'Exam Results'**
  String get examResults;

  /// No description provided for @noExamResults.
  ///
  /// In en, this message translates to:
  /// **'No exam results found'**
  String get noExamResults;

  /// No description provided for @yourScore.
  ///
  /// In en, this message translates to:
  /// **'Your Score'**
  String get yourScore;

  /// No description provided for @passed.
  ///
  /// In en, this message translates to:
  /// **'PASSED'**
  String get passed;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'FAILED'**
  String get failed;

  /// No description provided for @grade.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get grade;

  /// No description provided for @correct.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get correct;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @totalQuestions.
  ///
  /// In en, this message translates to:
  /// **'Total Questions'**
  String get totalQuestions;

  /// No description provided for @correctAnswers.
  ///
  /// In en, this message translates to:
  /// **'Correct Answers'**
  String get correctAnswers;

  /// No description provided for @incorrectAnswers.
  ///
  /// In en, this message translates to:
  /// **'Incorrect Answers'**
  String get incorrectAnswers;

  /// No description provided for @accuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracy;

  /// No description provided for @questionDetails.
  ///
  /// In en, this message translates to:
  /// **'Question Details'**
  String get questionDetails;

  /// No description provided for @correctStatus.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get correctStatus;

  /// No description provided for @incorrectStatus.
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get incorrectStatus;

  /// No description provided for @yourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your answer: {answer}'**
  String yourAnswer(String answer);

  /// No description provided for @correctAnswer.
  ///
  /// In en, this message translates to:
  /// **'Correct answer: {answer}'**
  String correctAnswer(String answer);

  /// No description provided for @notAnswered.
  ///
  /// In en, this message translates to:
  /// **'Not answered'**
  String get notAnswered;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @backToCourse.
  ///
  /// In en, this message translates to:
  /// **'Back to Course'**
  String get backToCourse;

  /// No description provided for @whatToLearn.
  ///
  /// In en, this message translates to:
  /// **'What do you want to learn today?'**
  String get whatToLearn;

  /// No description provided for @topicPython.
  ///
  /// In en, this message translates to:
  /// **'Python Basics'**
  String get topicPython;

  /// No description provided for @topicML.
  ///
  /// In en, this message translates to:
  /// **'Machine Learning'**
  String get topicML;

  /// No description provided for @topicWeb.
  ///
  /// In en, this message translates to:
  /// **'Web Development'**
  String get topicWeb;

  /// No description provided for @teachMeAbout.
  ///
  /// In en, this message translates to:
  /// **'Teach me about {topic}'**
  String teachMeAbout(String topic);

  /// No description provided for @voiceInput.
  ///
  /// In en, this message translates to:
  /// **'Voice input'**
  String get voiceInput;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get sendMessage;
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
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
