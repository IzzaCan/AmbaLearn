// import 'package:capstone_layout/pages/exam_score_page.dart';
// import 'package:flutter/material.dart';

// class ExamPage extends StatefulWidget {
//   const ExamPage({super.key});

//   @override
//   State<ExamPage> createState() => _ExamPageState();
// }

// class _ExamPageState extends State<ExamPage> {
//   bool camReady = false;

//   int currentQuestion = 0;

//   // =========================== EXAMPLE QUESTIONS ===========================
//   final List<Map<String, dynamic>> questions = [
//     {
//       "question": "Apa tujuan utama dari regresi linear?",
//       "options": [
//         "Memprediksi nilai berbasis hubungan linier.",
//         "Mengelompokkan data.",
//         "Mengacak data.",
//         "Mengukur error.",
//       ],
//       "answer": 0,
//     },
//     {
//       "question":
//           "Manakah yang termasuk variabel independen dalam model regresi?",
//       "options": [
//         "Nilai yang diprediksi.",
//         "Faktor yang mempengaruhi nilai prediksi.",
//         "Error model.",
//         "Semua salah.",
//       ],
//       "answer": 1,
//     },
//     {
//       "question": "Contoh penerapan regresi linear adalah?",
//       "options": [
//         "Prediksi harga rumah.",
//         "Clustering pelanggan.",
//         "Klasifikasi email.",
//         "Pengenalan wajah.",
//       ],
//       "answer": 0,
//     },
//   ];

//   // menyimpan jawaban user
//   List<int?> userAnswers = [];

//   @override
//   void initState() {
//     super.initState();
//     userAnswers = List.filled(questions.length, null);
//   }

//   @override
//   Widget build(BuildContext context) {
//     const Color redTheme = Color(0xFF8B0000);

//     return Scaffold(
//       backgroundColor: const Color(0xFF1E1E1E),

//       // ========================= APP BAR =========================
//       appBar: AppBar(
//         backgroundColor: redTheme,
//         centerTitle: true,
//         title: const Text(
//           "Final Exam",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//       ),

//       body: Column(
//         children: [
//           // ========================= CAMERA SECTION =========================
//           Container(
//             height: 200,
//             color: Colors.black,
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.videocam, size: 40, color: Colors.white70),
//                   const SizedBox(height: 8),
//                   Text(
//                     camReady
//                         ? "Camera Active – Monitoring..."
//                         : "Starting Camera...",
//                     style: const TextStyle(color: Colors.white70),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // ========================= WARNING BAR =========================
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(10),
//             color: Colors.red,
//             child: const Text(
//               "⚠ Camera should detect your face at all times.",
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.white),
//             ),
//           ),

//           const SizedBox(height: 20),

//           // ========================= QUESTION NUMBER =========================
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Text(
//               "Question ${currentQuestion + 1}/${questions.length}",
//               style: const TextStyle(color: Colors.white70, fontSize: 16),
//             ),
//           ),

//           // ========================= QUESTION TEXT =========================
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Text(
//               questions[currentQuestion]["question"],
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 20,
//                 height: 1.5,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),

//           const SizedBox(height: 20),

//           // ========================= MULTIPLE CHOICE OPTIONS =========================
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               itemCount: questions[currentQuestion]["options"].length,
//               itemBuilder: (context, index) {
//                 final option = questions[currentQuestion]["options"][index];

//                 return Container(
//                   margin: const EdgeInsets.only(bottom: 14),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF2E2E2E),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: userAnswers[currentQuestion] == index
//                           ? redTheme
//                           : Colors.transparent,
//                       width: 1.5,
//                     ),
//                   ),
//                   child: RadioListTile<int>(
//                     value: index,
//                     groupValue: userAnswers[currentQuestion],
//                     activeColor: redTheme,
//                     title: Text(
//                       option,
//                       style: const TextStyle(color: Colors.white),
//                     ),
//                     onChanged: (value) {
//                       setState(() {
//                         userAnswers[currentQuestion] = value;
//                       });
//                     },
//                   ),
//                 );
//               },
//             ),
//           ),

//           // ========================= NAV BUTTONS =========================
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // PREVIOUS BUTTON
//               if (currentQuestion > 0)
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.grey[700],
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 12,
//                     ),
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       currentQuestion--;
//                     });
//                   },
//                   child: const Text("Previous"),
//                 ),

//               const SizedBox(width: 20),

//               // NEXT / SUBMIT
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: currentQuestion == questions.length - 1
//                       ? Colors.green
//                       : redTheme,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 20,
//                     vertical: 12,
//                   ),
//                 ),
//                 onPressed: () {
//                   if (currentQuestion < questions.length - 1) {
//                     setState(() {
//                       currentQuestion++;
//                     });
//                   } else {
//                     _submitExam(context);
//                   }
//                 },
//                 child: Text(
//                   currentQuestion == questions.length - 1 ? "Submit" : "Next",
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }

//   // ========================= SUBMIT DIALOG =========================
//   void _submitExam(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: const Color(0xFF2E2E2E),
//         title: const Text(
//           "Submit Exam?",
//           style: TextStyle(color: Colors.white),
//         ),
//         content: const Text(
//           "Are you sure you want to submit your answers?",
//           style: TextStyle(color: Colors.white70),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text(
//               "Cancel",
//               style: TextStyle(color: Colors.white70),
//             ),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//             onPressed: () {
//               Navigator.pop(context);
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                   // Mengirimkan placeholder skor: 2 benar dari 3 soal
//                   builder: (context) => const ExamScorePage(
//                     correctAnswers: 2,
//                     totalQuestions: 3,
//                   ),
//                 ),
//               );
//             },
//             child: const Text("Submit"),
//           ),
//         ],
//       ),
//     );
//   }
// }
