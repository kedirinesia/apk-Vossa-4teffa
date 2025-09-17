import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/observer_data.dart';
import '../services/ai_suggestion_service.dart';
import 'finish_page.dart';

class ClassAnalysisPage extends StatefulWidget {
  final Map<String, Map<String, double>> studentScores;
  final Map<String, Map<String, String>> answers;
  final String classLevel;
  final String programKeahlian;
  final ObserverData observerData;
  final String schoolName;

  const ClassAnalysisPage({
    super.key,
    required this.studentScores,
    required this.answers,
    required this.classLevel,
    required this.programKeahlian,
    required this.observerData,
    required this.schoolName,
  });

  @override
  State<ClassAnalysisPage> createState() => _ClassAnalysisPageState();
}

class _ClassAnalysisPageState extends State<ClassAnalysisPage> {
  bool isLoadingAI = true;
  bool isUploading = false;
  List<String> classSuggestions = [];

  @override
  void initState() {
    super.initState();
    _loadClassAnalysis();
  }

  Future<void> _loadClassAnalysis() async {
    try {
      final suggestions = await AISuggestionService.getClassAnalysis(
        widget.studentScores,
        '${widget.classLevel} ${widget.programKeahlian}',
      );
      setState(() {
        classSuggestions = suggestions;
        isLoadingAI = false;
      });
    } catch (e) {
      print('Error loading class analysis: $e');
      setState(() {
        isLoadingAI = false;
      });
    }
  }

  List<StudentScore> _convertToStudentScores() {
    final aspects = ["KOM", "KS", "TJ", "FS", "PS", "KP"];
    final fullNames = ["Komunikasi", "Kerja Sama", "Tanggung Jawab", "Fleksibilitas", "Problem Solving", "Kepemimpinan"];
    final result = <StudentScore>[];
    
    for (var studentName in widget.studentScores.keys) {
      final scores = widget.studentScores[studentName]!;
      final scoreMap = <String, String>{};
      
      for (int i = 0; i < aspects.length; i++) {
        final aspect = aspects[i];
        final fullName = fullNames[i];
        final value = _getScoreForAspect(aspect, scores);
        final category = _getCategory(value);
        scoreMap[fullName] = category;
      }
      
      result.add(StudentScore(name: studentName, scores: scoreMap));
    }
    
    return result;
  }

  double _getScoreForAspect(String aspect, Map<String, double> studentScoreData) {
    final aspectMapping = {
      "KOM": "Komunikasi",
      "KS": "Kerja Sama", 
      "TJ": "Tanggung Jawab",
      "FS": "Fleksibilitas",
      "PS": "Problem Solving",
      "KP": "Kepemimpinan"
    };
    
    final fullAspect = aspectMapping[aspect] ?? aspect;
    final scores = <double>[];
    
    for (var entry in studentScoreData.entries) {
      if (entry.key.contains('($fullAspect)')) {
        scores.add(entry.value);
      }
    }
    
    if (scores.isEmpty) return 0.0;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  String _getCategory(double score) {
    if (score >= 4.5) return 'Sangat Baik';
    if (score >= 3.5) return 'Baik';
    if (score >= 2.5) return 'Cukup';
    if (score >= 1.5) return 'Kurang';
    return 'Sangat Kurang';
  }

  Future<void> _uploadExcelToFirestore() async {
    setState(() {
      isUploading = true;
    });

    try {
      // Prepare data for Firestore
      final documentId = '${widget.schoolName}_${widget.classLevel}_${widget.programKeahlian}'
          .replaceAll(' ', '_')
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .toLowerCase();
      
      final docRef = FirebaseFirestore.instance
          .collection('assessment_reports')
          .doc(documentId);
      
      // Convert answers to a more Firestore-friendly format
      final answersData = <String, Map<String, String>>{};
      widget.answers.forEach((student, answers) {
        answersData[student] = Map<String, String>.from(answers);
      });
      
      // Convert student scores to a more Firestore-friendly format
      final scoresData = <String, Map<String, double>>{};
      widget.studentScores.forEach((student, scores) {
        scoresData[student] = Map<String, double>.from(scores);
      });
      
      // Save all data to Firestore
      await docRef.set({
        // Basic info
        'schoolName': widget.schoolName,
        'classLevel': widget.classLevel,
        'programKeahlian': widget.programKeahlian,
        'observerName': widget.observerData.observerName,
        'observerRole': widget.observerData.role,
        
        // Assessment data
        'answers': answersData,
        'studentScores': scoresData,
        'studentCount': widget.studentScores.length,
        
        // AI suggestions
        'aiSuggestions': classSuggestions,
        
        // Timestamps
        'createdAt': DateTime.now().toIso8601String(),
        'uploadedAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
        
        // Additional metadata
        'dataType': 'assessment_report',
        'version': '1.0',
      }, SetOptions(merge: false));
      
      print('Data saved to Firestore successfully');
      print('Document ID: $documentId');
      print('Student count: ${widget.studentScores.length}');
      print('AI suggestions count: ${classSuggestions.length}');
      
      // Show success message
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text('Data berhasil disimpan ke Firestore Database!'),
      //       backgroundColor: Colors.green,
      //     ),
      //   );
      // }
      
    } catch (e) {
      print('Error saving to Firestore: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error menyimpan data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analisa Kelas by AI'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.blue.shade50,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header info
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.school, color: Colors.blue.shade600, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Informasi Kelas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Kelas: ${widget.classLevel}'),
                    Text('Program: ${widget.programKeahlian}'),
                    Text('Observer: ${widget.observerData.observerName} (${widget.observerData.role})'),
                    Text('Sekolah: ${widget.schoolName}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // AI Analysis Section
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header yang tetap statis
                      Row(
                        children: [
                          Icon(Icons.analytics, color: Colors.blue.shade600, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Saran Untuk Kelas Dari AI',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Konten yang bisa di-scroll
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isLoadingAI) ...[
                                const Center(
                                  child: Column(
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(height: 16),
                                      Text('AI sedang menganalisis data kelas...'),
                                    ],
                                  ),
                                ),
                              ] else if (classSuggestions.isNotEmpty) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.blue.shade200),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Saran Pengembangan Kelas:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade700,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ...classSuggestions.map((suggestion) => Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '• ',
                                              style: TextStyle(
                                                color: Colors.blue.shade600,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                suggestion,
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )).toList(),
                                    ],
                                  ),
                                ),
                              ] else ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: const Text(
                                    'Tidak ada saran yang tersedia saat ini.',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Navigation buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Kembali'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isUploading ? null : () async {
                      // Upload Excel to Firestore first
                      await _uploadExcelToFirestore();
                      
                      // Then navigate to FinishPage
                      if (mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FinishPage(
                              studentScores: _convertToStudentScores(),
                              answers: widget.answers,
                              aspects: const ['Komunikasi', 'Kerja Sama', 'Tanggung Jawab', 'Fleksibilitas', 'Problem Solving', 'Kepemimpinan'],
                              schoolName: widget.schoolName,
                              className: widget.classLevel,
                              programName: widget.programKeahlian,
                              observerName: widget.observerData.observerName,
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isUploading ? Colors.grey : Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: isUploading 
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Loading...'),
                          ],
                        )
                      : const Text('Selanjutnya'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}