import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/ai_suggestion_service.dart';

class StudentDetailPage extends StatefulWidget {
  final String studentName;
  final Map<String, double> studentScores;

  const StudentDetailPage({
    super.key,
    required this.studentName,
    required this.studentScores,
  });

  @override
  State<StudentDetailPage> createState() => _StudentDetailPageState();
}

class _StudentDetailPageState extends State<StudentDetailPage> {
  List<String> aiSuggestions = [];
  bool isLoadingAI = true;
  String? aiAnalysis;

  @override
  void initState() {
    super.initState();
    _loadAISuggestions();
  }

  Future<void> _loadAISuggestions() async {
    try {
      print('=== LOADING AI SUGGESTIONS ===');
      print('Student Name: ${widget.studentName}');
      print('Raw Student Scores: ${widget.studentScores}');
      
      final aspectScores = _getAspectScores();
      print('Processed Aspect Scores: $aspectScores');
      
      final suggestions = await AISuggestionService.getIndividualSuggestions(
        studentName: widget.studentName,
        aspectScores: aspectScores,
      );
      
      print('Received suggestions: $suggestions');
      
      setState(() {
        aiSuggestions = suggestions;
        isLoadingAI = false;
      });
      
      print('AI suggestions loaded successfully');
      print('===============================');
    } catch (e) {
      print('Error in _loadAISuggestions: $e');
      setState(() {
        aiSuggestions = ['Gagal memuat saran AI. Silakan coba lagi.'];
        isLoadingAI = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Gabungkan indikator per aspek untuk menghindari duplikasi
    final aspectScores = _getAspectScores();
    final aspects = aspectScores.keys.toList();
    final values = aspectScores.values.toList();
    final maxValue = values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 5.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Penilaian - ${widget.studentName}'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ringkasan Penilaian',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nama Siswa: ${widget.studentName}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Aspek: ${aspects.length}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rata-rata Skor: ${(values.reduce((a, b) => a + b) / values.length).toStringAsFixed(1)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Radar Chart Section
            Text(
              'Grafik Radar Soft Skills',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AspectRatio(
                  aspectRatio: 1.2,
                  child: RadarChart(
                    RadarChartData(
                      radarShape: RadarShape.polygon,
                      radarBorderData: const BorderSide(color: Colors.grey),
                      gridBorderData: const BorderSide(color: Colors.grey),
                      tickBorderData: const BorderSide(color: Colors.grey),
                      ticksTextStyle: const TextStyle(fontSize: 10),
                      tickCount: 5,
                      titlePositionPercentageOffset: 0.2,
                      titleTextStyle: const TextStyle(
                        fontSize: 10,
                        color: Colors.black87,
                      ),
                      getTitle: (index, angle) {
                        final aspect = aspects[index];
                        return RadarChartTitle(
                          text: aspect,
                          angle: angle,
                        );
                      },
                      dataSets: [
                        RadarDataSet(
                          dataEntries: values.map((v) => RadarEntry(value: v)).toList(),
                          fillColor: Colors.blue.withOpacity(0.3),
                          borderColor: Colors.blue,
                          entryRadius: 3,
                          borderWidth: 2,
                        ),
                        // Add invisible reference dataset to set proper scale
                        RadarDataSet(
                          dataEntries: List.generate(aspects.length, (index) => RadarEntry(value: 5.0)),
                          fillColor: Colors.transparent,
                          borderColor: Colors.transparent,
                          entryRadius: 0,
                          borderWidth: 0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Bar Chart Section
            Text(
              'Grafik Bar Soft Skills',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: aspects.asMap().entries.map((entry) {
                    final index = entry.key;
                    final aspect = entry.value;
                    final value = values[index];
                    final percentage = (value / maxValue).clamp(0.0, 1.0);
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${index + 1}. $aspect',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Text(
                                value.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.grey.shade300,
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: percentage,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.shade300,
                                      Colors.blue.shade600,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // AI Suggestion Section
            Text(
              'Saran AI untuk Perbaikan',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.psychology,
                          color: Colors.purple.shade600,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Analisis AI',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildAISuggestions(),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Detailed List Section
            Text(
              'Rincian Lengkap Skor',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Card(
              elevation: 4,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: aspects.length,
                itemBuilder: (context, index) {
                  final aspect = aspects[index];
                  final value = values[index];
                  
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      aspect,
                      style: const TextStyle(fontSize: 12),
                    ),
                    subtitle: Text(
                      'Rata-rata dari semua indikator',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getScoreColor(value),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        value.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  
  
  // Fungsi untuk menentukan warna container
  Color _getContainerColor(double avgScore) {
    if (avgScore <= 3.0) return Colors.red.shade50; // Merah untuk skor rendah
    return Colors.blue.shade50; // Biru untuk skor tinggi
  }
  
  // Fungsi untuk menentukan warna border
  Color _getBorderColor(double avgScore) {
    if (avgScore <= 3.0) return Colors.red.shade200; // Merah untuk skor rendah
    return Colors.blue.shade200; // Biru untuk skor tinggi
  }
  
  // Fungsi untuk menentukan icon
  IconData _getIcon(double avgScore) {
    if (avgScore <= 3.0) return Icons.warning; // Warning untuk skor rendah
    return Icons.balance; // Balance untuk skor tinggi
  }
  
  // Fungsi untuk menentukan warna icon
  Color _getIconColor(double avgScore) {
    if (avgScore <= 3.0) return Colors.red.shade600; // Merah untuk skor rendah
    return Colors.blue.shade600; // Biru untuk skor tinggi
  }
  
  // Fungsi untuk menentukan warna text
  Color _getTextColor(double avgScore) {
    if (avgScore <= 3.0) return Colors.red.shade700; // Merah untuk skor rendah
    return Colors.blue.shade700; // Biru untuk skor tinggi
  }
  
  // Fungsi untuk menampilkan saran AI
  Widget _buildAISuggestions() {
    final aspectScores = _getAspectScores();
    
    // Cek rata-rata skor
    final scores = aspectScores.values.toList();
    final avgScore = scores.reduce((a, b) => a + b) / scores.length;
    
    // Cek apakah semua data masih kosong (skor 0.0)
    final isDataEmpty = scores.every((score) => score == 0.0);
    
    if (isDataEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Data belum diisi',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    if (isLoadingAI) {
      return Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'AI sedang menganalisis data ${widget.studentName}...',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ringkasan kondisi siswa
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getContainerColor(avgScore),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _getBorderColor(avgScore)),
          ),
          child: Row(
            children: [
              Icon(
                _getIcon(avgScore), 
                color: _getIconColor(avgScore), 
                size: 20
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  avgScore < 3.0
                    ? 'Perbaiki aspek aspek yang nilainya dibawah 3.0'
                    : 'Teruskan performa mu dan selalu luangkan waktu untuk meningkatkan performa',
                  style: TextStyle(
                    color: _getTextColor(avgScore),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Saran perbaikan
        Text(
          avgScore < 3.0 ? 'Saran Perbaikan:' : 'Saran Pengembangan:',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        
        ...aiSuggestions.map((suggestion) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  suggestion,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        )).toList(),
        
        const SizedBox(height: 16),
        
        // Motivasi
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.blue.shade600, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Setiap perbaikan kecil akan membawa dampak besar pada perkembangan soft skills Anda!',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  
  // Fungsi untuk menggabungkan skor per aspek
  Map<String, double> _getAspectScores() {
    final aspectScores = <String, List<double>>{};
    
    // Kumpulkan semua skor per aspek
    for (var entry in widget.studentScores.entries) {
      final key = entry.key;
      final score = entry.value;
      
      // Ekstrak nama aspek dari key (dalam kurung)
      final parts = key.split('(');
      if (parts.length > 1) {
        final aspect = parts.last.replaceAll(')', '').trim();
        aspectScores.putIfAbsent(aspect, () => []).add(score);
      }
    }
    
    // Hitung rata-rata untuk setiap aspek
    final result = <String, double>{};
    aspectScores.forEach((aspect, scores) {
      if (scores.isNotEmpty) {
        result[aspect] = scores.reduce((a, b) => a + b) / scores.length;
      }
    });
    
    return result;
  }
  
  Color _getScoreColor(double score) {
    if (score >= 4.0) return Colors.green;
    if (score >= 3.0) return Colors.orange;
    if (score >= 2.0) return Colors.red.shade300;
    return Colors.red;
  }
}
