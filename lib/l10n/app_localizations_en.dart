// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'AmbaLearn';

  @override
  String get welcomeMessage => 'Welcome back!';

  @override
  String get startExam => 'Start Exam';

  @override
  String get continueLearning => 'Continue Learning';

  @override
  String get courses => 'Courses';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get logout => 'Log Out';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get submit => 'Submit';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get examCalibration => 'Calibration Check';

  @override
  String get cameraPermissionRequired =>
      'Camera access is required for proctoring.';

  @override
  String get statusWaitingConnection => 'Waiting for connection...';

  @override
  String get statusWaitingFace => 'Waiting for face detection...';

  @override
  String get statusFaceNotDetected => 'Face not detected';

  @override
  String get statusMultipleFaces => 'Multiple faces detected';

  @override
  String get statusHeadAlert => 'Please face the screen';

  @override
  String get statusReady => 'Ready for exam ✅';

  @override
  String get examViolationWarning => '⚠️ CHEATING DETECTED';

  @override
  String get examViolationMessage => 'Please keep your eyes on the screen!';

  @override
  String get examTerminated => 'Exam Terminated';

  @override
  String get examTerminatedMessage =>
      'VIOLATION LIMIT EXCEEDED.\nYour exam is being automatically submitted.';

  @override
  String get welcomeBack => 'Welcome Back!';

  @override
  String get signInContinue => 'Sign in to continue';

  @override
  String get email => 'Email';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get password => 'Password';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get signIn => 'Sign In';

  @override
  String get or => 'OR';

  @override
  String get continueGoogle => 'Continue with Google';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get signUp => 'Sign Up';

  @override
  String get createAccount => 'Create Account';

  @override
  String get signUpStarted => 'Let\'s get you started';

  @override
  String get username => 'Username';

  @override
  String get enterUsername => 'Enter your username';

  @override
  String get alreadyAccount => 'Already have an account?';

  @override
  String get appearance => 'Appearance';

  @override
  String get account => 'Account';

  @override
  String get notifications => 'Notifications';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get about => 'About';

  @override
  String get thinking => 'Thinking...';

  @override
  String get typeMessage => 'Type a message...';

  @override
  String get monitoringActive => 'Monitoring Active';

  @override
  String get faceNotDetected => 'Face Not Detected';

  @override
  String get initializing => 'Initializing...';

  @override
  String get normal => 'Normal';

  @override
  String get cameraInitialized => 'Camera initialized';

  @override
  String get noCameras => 'No cameras available';

  @override
  String get ok => 'OK';

  @override
  String get submitExam => 'Submit Exam';

  @override
  String get submitExamQuestion => 'Submit Exam?';

  @override
  String get submitExamConfirmAll =>
      'You have answered all questions. Submit your exam now?';

  @override
  String submitExamConfirmPartial(int answered, int total) {
    return 'You have answered $answered of $total questions. Unanswered questions will be marked as incorrect. Submit anyway?';
  }

  @override
  String get failedToSubmit => 'Failed to submit exam';

  @override
  String get exitExam => 'Exit Exam?';

  @override
  String get exitExamConfirm =>
      'Are you sure you want to exit? Your progress will be lost.';

  @override
  String get stay => 'Stay';

  @override
  String get exit => 'Exit';

  @override
  String get loadingExam => 'Loading exam...';

  @override
  String get failedToLoadExam => 'Failed to load exam';

  @override
  String get failedToLoadExamRetry => 'Failed to load exam. Please try again.';

  @override
  String get goBack => 'Go Back';

  @override
  String violationStatus(int count, int max) {
    return 'Violation: $count/$max';
  }

  @override
  String get cheatingDetected => '⚠️ CHEATING DETECTED';

  @override
  String keepEyesOnScreen(String detail) {
    return '$detail\nPlease keep your eyes on the screen!';
  }

  @override
  String questionTitle(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String answeredStatus(int answered, int total) {
    return 'Answered: $answered/$total';
  }

  @override
  String questionHeader(int number) {
    return 'Question $number';
  }

  @override
  String get submitting => 'Submitting...';

  @override
  String get calibrationCheck => 'Calibration Check';

  @override
  String get waitingForConnection => 'Waiting for connection...';

  @override
  String get waitingForFace => 'Waiting for face detection...';

  @override
  String get disconnectedStart => 'Disconnected from Anti-Cheat Service';

  @override
  String get unknown => 'Unknown';

  @override
  String get faceNotDetectedStatus => 'Face not detected';

  @override
  String get multipleFacesStatus => 'Multiple faces detected';

  @override
  String get faceScreenStatus => 'Please face the screen';

  @override
  String get readyForExam => 'Ready for exam ✅';

  @override
  String get permissionDenied => 'Permission Denied';

  @override
  String get cameraPermissionMsg => 'Camera access is required for proctoring.';

  @override
  String get permissionRequired => 'Permission Required';

  @override
  String get enableCameraMsg => 'Please enable camera access in settings.';

  @override
  String get examPermission => 'Exam Permission';

  @override
  String get cameraAccessRequired => 'Camera Access Required';

  @override
  String get grantAccess => 'Grant Access';

  @override
  String get examResults => 'Exam Results';

  @override
  String get noExamResults => 'No exam results found';

  @override
  String get yourScore => 'Your Score';

  @override
  String get passed => 'PASSED';

  @override
  String get failed => 'FAILED';

  @override
  String get grade => 'Grade';

  @override
  String get correct => 'Correct';

  @override
  String get statistics => 'Statistics';

  @override
  String get totalQuestions => 'Total Questions';

  @override
  String get correctAnswers => 'Correct Answers';

  @override
  String get incorrectAnswers => 'Incorrect Answers';

  @override
  String get accuracy => 'Accuracy';

  @override
  String get questionDetails => 'Question Details';

  @override
  String get correctStatus => 'Correct';

  @override
  String get incorrectStatus => 'Incorrect';

  @override
  String yourAnswer(String answer) {
    return 'Your answer: $answer';
  }

  @override
  String correctAnswer(String answer) {
    return 'Correct answer: $answer';
  }

  @override
  String get notAnswered => 'Not answered';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get backToCourse => 'Back to Course';

  @override
  String get whatToLearn => 'What do you want to learn today?';

  @override
  String get topicPython => 'Python Basics';

  @override
  String get topicML => 'Machine Learning';

  @override
  String get topicWeb => 'Web Development';

  @override
  String teachMeAbout(String topic) {
    return 'Teach me about $topic';
  }

  @override
  String get voiceInput => 'Voice input';

  @override
  String get sendMessage => 'Send message';
}
