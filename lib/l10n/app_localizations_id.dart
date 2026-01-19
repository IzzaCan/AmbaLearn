// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'AmbaLearn';

  @override
  String get welcomeMessage => 'Selamat datang kembali!';

  @override
  String get startExam => 'Mulai Ujian';

  @override
  String get continueLearning => 'Lanjut Belajar';

  @override
  String get courses => 'Kursus';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Pengaturan';

  @override
  String get language => 'Bahasa';

  @override
  String get theme => 'Tema';

  @override
  String get darkMode => 'Mode Gelap';

  @override
  String get lightMode => 'Mode Terang';

  @override
  String get logout => 'Keluar';

  @override
  String get cancel => 'Batal';

  @override
  String get confirm => 'Konfirmasi';

  @override
  String get submit => 'Kirim';

  @override
  String get next => 'Lanjut';

  @override
  String get previous => 'Sebelumnya';

  @override
  String get loading => 'Memuat...';

  @override
  String get error => 'Kesalahan';

  @override
  String get success => 'Berhasil';

  @override
  String get examCalibration => 'Cek Kalibrasi';

  @override
  String get cameraPermissionRequired =>
      'Akses kamera diperlukan untuk pengawasan.';

  @override
  String get statusWaitingConnection => 'Menunggu koneksi...';

  @override
  String get statusWaitingFace => 'Menunggu deteksi wajah...';

  @override
  String get statusFaceNotDetected => 'Wajah tidak terdeteksi';

  @override
  String get statusMultipleFaces => 'Terdeteksi lebih dari 1 wajah';

  @override
  String get statusHeadAlert => 'Tolong menghadap ke layar';

  @override
  String get statusReady => 'Siap untuk ujian ✅';

  @override
  String get examViolationWarning => '⚠️ TERDETEKSI KECURANGAN';

  @override
  String get examViolationMessage => 'Mohon tetap melihat layar!';

  @override
  String get examTerminated => 'Ujian Dihentikan';

  @override
  String get examTerminatedMessage =>
      'BATAS PELANGGARAN TERLAMPAUI.\nUjian Anda dikirim otomatis.';

  @override
  String get welcomeBack => 'Selamat Datang Kembali!';

  @override
  String get signInContinue => 'Masuk untuk melanjutkan';

  @override
  String get email => 'Email';

  @override
  String get enterEmail => 'Masukkan email Anda';

  @override
  String get password => 'Kata Sandi';

  @override
  String get enterPassword => 'Masukkan kata sandi';

  @override
  String get signIn => 'Masuk';

  @override
  String get or => 'ATAU';

  @override
  String get continueGoogle => 'Lanjut dengan Google';

  @override
  String get noAccount => 'Belum punya akun?';

  @override
  String get signUp => 'Daftar';

  @override
  String get createAccount => 'Buat Akun';

  @override
  String get signUpStarted => 'Mari kita mulai';

  @override
  String get username => 'Nama Pengguna';

  @override
  String get enterUsername => 'Masukkan nama pengguna';

  @override
  String get alreadyAccount => 'Sudah punya akun?';

  @override
  String get appearance => 'Tampilan';

  @override
  String get account => 'Akun';

  @override
  String get notifications => 'Notifikasi';

  @override
  String get helpSupport => 'Bantuan & Dukungan';

  @override
  String get about => 'Tentang';

  @override
  String get thinking => 'Sedang berpikir...';

  @override
  String get typeMessage => 'Ketik pesan...';

  @override
  String get monitoringActive => 'Monitoring Aktif';

  @override
  String get faceNotDetected => 'Wajah Tidak Terdeteksi';

  @override
  String get initializing => 'Memuat...';

  @override
  String get normal => 'Normal';

  @override
  String get cameraInitialized => 'Kamera aktif';

  @override
  String get noCameras => 'Tidak ada kamera';

  @override
  String get ok => 'OK';

  @override
  String get submitExam => 'Kirim Ujian';

  @override
  String get submitExamQuestion => 'Kirim Ujian?';

  @override
  String get submitExamConfirmAll =>
      'Anda telah menjawab semua soal. Kirim ujian sekarang?';

  @override
  String submitExamConfirmPartial(int answered, int total) {
    return 'Anda menjawab $answered dari $total soal. Soal kosong akan dianggap salah. Tetap kirim?';
  }

  @override
  String get failedToSubmit => 'Gagal mengirim ujian';

  @override
  String get exitExam => 'Keluar Ujian?';

  @override
  String get exitExamConfirm => 'Yakin ingin keluar? Progres Anda akan hilang.';

  @override
  String get stay => 'Tetap';

  @override
  String get exit => 'Keluar';

  @override
  String get loadingExam => 'Memuat ujian...';

  @override
  String get failedToLoadExam => 'Gagal memuat ujian';

  @override
  String get failedToLoadExamRetry => 'Gagal memuat ujian. Silakan coba lagi.';

  @override
  String get goBack => 'Kembali';

  @override
  String violationStatus(int count, int max) {
    return 'Pelanggaran: $count/$max';
  }

  @override
  String get cheatingDetected => '⚠️ TERDETEKSI KECURANGAN';

  @override
  String keepEyesOnScreen(String detail) {
    return '$detail\nMohon tetap melihat layar!';
  }

  @override
  String questionTitle(int current, int total) {
    return 'Soal $current dari $total';
  }

  @override
  String answeredStatus(int answered, int total) {
    return 'Terjawab: $answered/$total';
  }

  @override
  String questionHeader(int number) {
    return 'Soal $number';
  }

  @override
  String get submitting => 'Mengirim...';

  @override
  String get calibrationCheck => 'Cek Kalibrasi';

  @override
  String get waitingForConnection => 'Menunggu koneksi...';

  @override
  String get waitingForFace => 'Menunggu deteksi wajah...';

  @override
  String get disconnectedStart => 'Terputus dari layanan Anti-Cheat';

  @override
  String get unknown => 'Tidak diketahui';

  @override
  String get faceNotDetectedStatus => 'Wajah tidak terdeteksi';

  @override
  String get multipleFacesStatus => 'Terdeteksi lebih dari 1 wajah';

  @override
  String get faceScreenStatus => 'Tolong menghadap ke layar';

  @override
  String get readyForExam => 'Siap untuk ujian ✅';

  @override
  String get permissionDenied => 'Izin Ditolak';

  @override
  String get cameraPermissionMsg => 'Akses kamera diperlukan untuk pengawasan.';

  @override
  String get permissionRequired => 'Izin Diperlukan';

  @override
  String get enableCameraMsg => 'Mohon aktifkan akses kamera di pengaturan.';

  @override
  String get examPermission => 'Izin Ujian';

  @override
  String get cameraAccessRequired => 'Akses Kamera Diperlukan';

  @override
  String get grantAccess => 'Berikan Akses';

  @override
  String get examResults => 'Hasil Ujian';

  @override
  String get noExamResults => 'Hasil ujian tidak ditemukan';

  @override
  String get yourScore => 'Nilai Anda';

  @override
  String get passed => 'LULUS';

  @override
  String get failed => 'GAGAL';

  @override
  String get grade => 'Nilai';

  @override
  String get correct => 'Benar';

  @override
  String get statistics => 'Statistik';

  @override
  String get totalQuestions => 'Total Soal';

  @override
  String get correctAnswers => 'Jawaban Benar';

  @override
  String get incorrectAnswers => 'Jawaban Salah';

  @override
  String get accuracy => 'Akurasi';

  @override
  String get questionDetails => 'Detail Soal';

  @override
  String get correctStatus => 'Benar';

  @override
  String get incorrectStatus => 'Salah';

  @override
  String yourAnswer(String answer) {
    return 'Jawaban Anda: $answer';
  }

  @override
  String correctAnswer(String answer) {
    return 'Jawaban Benar: $answer';
  }

  @override
  String get notAnswered => 'Tidak dijawab';

  @override
  String get backToHome => 'Kembali ke Beranda';

  @override
  String get backToCourse => 'Kembali ke Kursus';

  @override
  String get whatToLearn => 'Mau belajar apa hari ini?';

  @override
  String get topicPython => 'Dasar Python';

  @override
  String get topicML => 'Machine Learning';

  @override
  String get topicWeb => 'Web Development';

  @override
  String teachMeAbout(String topic) {
    return 'Ajarkan saya tentang $topic';
  }

  @override
  String get voiceInput => 'Input suara';

  @override
  String get sendMessage => 'Kirim pesan';
}
