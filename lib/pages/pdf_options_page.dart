import 'package:flutter/material.dart';
import '../services/pdf_generation_service.dart';
import 'finish_page.dart';

class PDFOptionsPage extends StatelessWidget {
  final List<StudentScore> studentScores;
  final Map<String, Map<String, String>> answers;
  final List<String> aspects;
  final String? schoolName;
  final String? className;
  final String? programName;
  final String? observerName;

  const PDFOptionsPage({
    Key? key,
    required this.studentScores,
    required this.answers,
    required this.aspects,
    this.schoolName,
    this.className,
    this.programName,
    this.observerName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Format PDF'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.picture_as_pdf, color: Colors.blue.shade600, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Pilih Format PDF yang Diinginkan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Pilih salah satu format PDF di bawah ini sesuai kebutuhan Anda:',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // PDF Options
            _buildPDFOption(
              context,
              title: 'PDF per Siswa',
              description: 'PDF individual untuk setiap siswa dengan radar chart dan saran AI',
              icon: Icons.radar,
              color: Colors.purple,
              onTap: () => _generateStudentRadarPDFs(context),
            ),
            const SizedBox(height: 16),

            _buildPDFOption(
              context,
              title: 'PDF Ringkasan Kelas',
              description: 'PDF analisis kelas dengan statistik dan saran pengembangan',
              icon: Icons.analytics,
              color: Colors.blue,
              onTap: () => _generateClassSummaryPDF(context),
            ),
            const SizedBox(height: 16),

            _buildPDFOption(
              context,
              title: 'PDF Hasil Penilaian Soft Skills',
              description: 'PDF tabel hasil penilaian soft skills untuk semua siswa',
              icon: Icons.assessment,
              color: Colors.green,
              onTap: () => _generateSoftSkillsResultsPDF(context),
            ),
            const SizedBox(height: 16),

            _buildPDFOption(
              context,
              title: 'PDF Detail Kelas',
              description: 'PDF dengan analisis mendalam dan rekomendasi untuk kelas',
              icon: Icons.school,
              color: Colors.orange,
              onTap: () => _generateClassDetailPDF(context),
            ),
            const SizedBox(height: 16),

            _buildPDFOption(
              context,
              title: 'PDF Semua Aspek',
              description: 'PDF lengkap dengan semua format: ringkasan kelas, analisis individual, dan saran AI',
              icon: Icons.description,
              color: Colors.indigo,
              onTap: () => _generateCompletePDF(context),
            ),
            const SizedBox(height: 20),

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
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FinishPage(
                            studentScores: studentScores,
                            answers: answers,
                            aspects: aspects,
                            schoolName: schoolName,
                            className: className,
                            programName: programName,
                            observerName: observerName,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Ke Halaman Utama'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPDFOption(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color.withOpacity(0.6),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generateStudentRadarPDFs(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Generate PDF for each student
      for (final student in studentScores) {
        final scores = <String, double>{};
        for (final aspect in aspects) {
          final scoreStr = student.scores[aspect] ?? 'Cukup';
          final score = _convertScoreToNumeric(scoreStr);
          scores[aspect] = score;
        }
        
        // Generate AI suggestions for this student
        final aiSuggestions = _generateAISuggestions(student.name, scores);
        
        final filePath = await PDFGenerationService.generateStudentRadarPDF(
          studentName: student.name,
          studentScores: scores,
          aiSuggestions: aiSuggestions,
          schoolName: schoolName,
          className: className,
          programName: programName,
          observerName: observerName,
        );
        
        await PDFGenerationService.openPDF(filePath);
      }

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF berhasil dibuat untuk semua siswa!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _generateClassSummaryPDF(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Validate data first
      if (studentScores.isEmpty) {
        throw Exception('Tidak ada data siswa untuk di-generate PDF');
      }
      
      // Convert studentScores to the format needed for class summary
      final studentScoresMap = <String, Map<String, double>>{};
      
      for (final student in studentScores) {
        final scores = <String, double>{};
        for (final aspect in aspects) {
          final scoreStr = student.scores[aspect] ?? 'Cukup';
          final score = _convertScoreToNumeric(scoreStr);
          scores[aspect] = score;
        }
        studentScoresMap[student.name] = scores;
      }
      
      // Debug: Print converted data
      print('=== DEBUG PDF CONVERSION ===');
      print('Original studentScores: ${studentScores.length}');
      for (final student in studentScores) {
        print('Student: ${student.name}');
        print('Scores: ${student.scores}');
      }
      print('Converted studentScoresMap: ${studentScoresMap.length}');
      for (final entry in studentScoresMap.entries) {
        print('Student: ${entry.key}');
        print('Scores: ${entry.value}');
      }
      print('============================');
      
      // Generate class suggestions
      final classSuggestions = _generateClassSuggestions(studentScoresMap);
      
      final filePath = await PDFGenerationService.generateClassSummaryPDF(
        studentScores: studentScoresMap,
        classSuggestions: classSuggestions,
        schoolName: schoolName ?? 'Sekolah',
        className: className ?? 'Kelas',
        programName: programName ?? 'Program',
        observerName: observerName ?? 'Observer',
      );
      
      await PDFGenerationService.openPDF(filePath);

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF ringkasan kelas berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error in _generateClassSummaryPDF: $e');
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _generateSoftSkillsResultsPDF(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Convert to the format needed for soft skills results
      final studentScoresList = studentScores.map((student) => {
        'name': student.name,
        'scores': student.scores,
      }).toList();
      
      final filePath = await PDFGenerationService.generateSoftSkillsResultsPDF(
        studentScores: studentScoresList,
        aspects: aspects,
        schoolName: schoolName,
        className: className,
        programName: programName,
        observerName: observerName,
      );
      
      await PDFGenerationService.openPDF(filePath);

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF hasil penilaian soft skills berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _generateClassDetailPDF(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // This is similar to class summary but with more detailed analysis
      final studentScoresMap = <String, Map<String, double>>{};
      
      for (final student in studentScores) {
        final scores = <String, double>{};
        for (final aspect in aspects) {
          final scoreStr = student.scores[aspect] ?? 'Cukup';
          final score = _convertScoreToNumeric(scoreStr);
          scores[aspect] = score;
        }
        studentScoresMap[student.name] = scores;
      }
      
      final classSuggestions = _generateClassSuggestions(studentScoresMap);
      
      final filePath = await PDFGenerationService.generateClassSummaryPDF(
        studentScores: studentScoresMap,
        classSuggestions: classSuggestions,
        schoolName: schoolName ?? 'Sekolah',
        className: className ?? 'Kelas',
        programName: programName ?? 'Program',
        observerName: observerName ?? 'Observer',
      );
      
      await PDFGenerationService.openPDF(filePath);

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF detail kelas berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _generateCompletePDF(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Validate data first
      if (studentScores.isEmpty) {
        throw Exception('Tidak ada data siswa untuk di-generate PDF');
      }
      
      // Convert studentScores to the format needed for complete PDF
      final studentScoresMap = <String, Map<String, double>>{};
      
      for (final student in studentScores) {
        final scores = <String, double>{};
        for (final aspect in aspects) {
          final scoreStr = student.scores[aspect] ?? 'Cukup';
          final score = _convertScoreToNumeric(scoreStr);
          scores[aspect] = score;
        }
        studentScoresMap[student.name] = scores;
      }
      
      // Debug: Print converted data
      print('=== DEBUG COMPLETE PDF CONVERSION ===');
      print('Original studentScores: ${studentScores.length}');
      for (final student in studentScores) {
        print('Student: ${student.name}');
        print('Scores: ${student.scores}');
      }
      print('Converted studentScoresMap: ${studentScoresMap.length}');
      for (final entry in studentScoresMap.entries) {
        print('Student: ${entry.key}');
        print('Scores: ${entry.value}');
      }
      print('=====================================');
      
      // Generate class suggestions
      final classSuggestions = _generateClassSuggestions(studentScoresMap);
      
      final filePath = await PDFGenerationService.generateCompletePDF(
        studentScores: studentScoresMap,
        classSuggestions: classSuggestions,
        schoolName: schoolName ?? 'Sekolah',
        className: className ?? 'Kelas',
        programName: programName ?? 'Program',
        observerName: observerName ?? 'Observer',
      );
      
      await PDFGenerationService.openPDF(filePath);

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF lengkap dengan semua aspek berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error in _generateCompletePDF: $e');
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating complete PDF: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  // Helper methods
  double _convertScoreToNumeric(String scoreStr) {
    print('Converting score string: "$scoreStr"');
    double result;
    switch (scoreStr) {
      case 'Sangat Baik':
        result = 5.0;
        break;
      case 'Baik':
        result = 4.0;
        break;
      case 'Cukup':
        result = 3.0;
        break;
      case 'Kurang':
        result = 2.0;
        break;
      case 'Sangat Kurang':
        result = 1.0;
        break;
      default:
        print('Unknown score string: "$scoreStr", using default 3.0');
        result = 3.0;
    }
    print('Converted to: $result');
    return result;
  }

  List<String> _generateAISuggestions(String studentName, Map<String, double> scores) {
    final suggestions = <String>[];
    final avgScore = scores.values.reduce((a, b) => a + b) / scores.length;
    
    if (avgScore >= 4.0) {
      suggestions.add('Pertahankan performa yang sangat baik di semua aspek');
      suggestions.add('Berbagi pengalaman dengan teman sekelas');
    } else if (avgScore >= 3.0) {
      suggestions.add('Fokus pada pengembangan aspek yang masih kurang');
      suggestions.add('Berpartisipasi lebih aktif dalam kegiatan kelompok');
    } else {
      suggestions.add('Perlu bimbingan intensif untuk mengembangkan soft skills');
      suggestions.add('Mulai dengan aspek yang paling mudah ditingkatkan');
    }
    
    // Add specific suggestions based on weakest aspect
    final weakestAspect = scores.entries.reduce((a, b) => a.value < b.value ? a : b);
    suggestions.add('Khususnya untuk ${weakestAspect.key}, coba latihan:');
    
    switch (weakestAspect.key) {
      case 'Komunikasi':
        suggestions.add('- Latihan presentasi di depan cermin');
        suggestions.add('- Berpartisipasi dalam diskusi kelompok');
        break;
      case 'Kerja Sama':
        suggestions.add('- Ikut serta dalam proyek kelompok');
        suggestions.add('- Belajar mendengarkan pendapat orang lain');
        break;
      case 'Tanggung Jawab':
        suggestions.add('- Menyelesaikan tugas tepat waktu');
        suggestions.add('- Melaporkan progress secara berkala');
        break;
      case 'Fleksibilitas':
        suggestions.add('- Mencoba pendekatan baru dalam menyelesaikan masalah');
        suggestions.add('- Beradaptasi dengan perubahan situasi');
        break;
      case 'Problem Solving':
        suggestions.add('- Latihan analisis masalah secara sistematis');
        suggestions.add('- Brainstorming solusi alternatif');
        break;
      case 'Kepemimpinan':
        suggestions.add('- Memimpin proyek kecil');
        suggestions.add('- Memberikan contoh yang baik');
        break;
    }
    
    return suggestions;
  }

  List<String> _generateClassSuggestions(Map<String, Map<String, double>> studentScores) {
    final suggestions = <String>[];
    
    // Validate data
    if (studentScores.isEmpty) {
      return ['Tidak ada data siswa untuk dianalisis'];
    }
    
    // Calculate class averages for each aspect
    final classAverages = <String, double>{};
    for (final aspect in aspects) {
      final scores = <double>[];
      for (final student in studentScores.values) {
        final score = student[aspect] ?? 3.0;
        scores.add(score);
      }
      if (scores.isNotEmpty) {
        classAverages[aspect] = scores.reduce((a, b) => a + b) / scores.length;
      } else {
        classAverages[aspect] = 0.0;
      }
    }
    
    // Find weakest and strongest aspects
    final weakestAspect = classAverages.entries.reduce((a, b) => a.value < b.value ? a : b);
    final strongestAspect = classAverages.entries.reduce((a, b) => a.value > b.value ? a : b);
    
    suggestions.add('Aspek terkuat kelas: ${strongestAspect.key} (${strongestAspect.value.toStringAsFixed(1)}/5.0)');
    suggestions.add('Aspek yang perlu ditingkatkan: ${weakestAspect.key} (${weakestAspect.value.toStringAsFixed(1)}/5.0)');
    
    // Add specific recommendations
    if (weakestAspect.value < 3.0) {
      suggestions.add('Perlu program pengembangan intensif untuk ${weakestAspect.key}');
      suggestions.add('Berikan lebih banyak latihan dan praktik');
    }
    
    suggestions.add('Pertahankan performa yang baik di ${strongestAspect.key}');
    suggestions.add('Gunakan metode pembelajaran yang beragam');
    suggestions.add('Berikan proyek kolaboratif untuk meningkatkan kerja sama');
    
    return suggestions;
  }
}
