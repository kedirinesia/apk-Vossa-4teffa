// lib/pages/class_summary_page.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'finish_page.dart';

class ClassSummaryPage extends StatelessWidget {
  final Map<String, Map<String, double>> studentScores;

  const ClassSummaryPage({Key? key, required this.studentScores})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Kelompokkan data berdasarkan aspek soft skills
    final aspects = ['Fleksibilitas', 'Tanggung Jawab', 'Komunikasi', 'Kerja Sama', 'Problem Solving', 'Kepemimpinan'];
    
    // Hitung rata-rata per aspek dengan mengelompokkan berdasarkan nama aspek
    Map<String, double> averageScores = {};
    for (var aspect in aspects) {
      double total = 0.0;
      int count = 0;
      
      for (var studentEntry in studentScores.entries) {
        final scores = studentEntry.value;
        
        // Cari semua key yang mengandung nama aspek
        for (var key in scores.keys) {
          if (key.contains('($aspect)')) {
            total += scores[key]!;
            count++;
          }
        }
      }
      
      averageScores[aspect] = count > 0 ? total / count : 0.0;
    }

    // Jika nilai minimum = 0, fl_chart kadang tampil aneh; kita set minimum jadi >=1
    // (atau Anda bisa set RadarChartData.isMinValueAtCenter = true di versi yang mendukung).
    final dataValues = aspects.map((a) => averageScores[a] ?? 0.0).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ringkasan Kelas'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Ringkasan Kelas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Total Siswa: ${studentScores.length}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Rata-rata Keseluruhan: ${(averageScores.values.reduce((a, b) => a + b) / averageScores.length).toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue),
            ),
            const SizedBox(height: 20),
            Container(
              height: 300,
              child: RadarChart(
                RadarChartData(
                  // Dataset tunggal yang menampilkan rata-rata tiap aspek
                  dataSets: [
                    RadarDataSet(
                      fillColor: Colors.blue.withOpacity(0.4),
                      borderColor: Colors.blue,
                      entryRadius: 3,
                      dataEntries:
                          dataValues.map((v) => RadarEntry(value: v)).toList(),
                    ),
                  ],
                  // Atur style judul secara global di sini (jangan pakai textStyle pada RadarChartTitle)
                  titleTextStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  // Jarak judul dari chart (0..1)
                  titlePositionPercentageOffset: 0.25,
                  // jumlah ticks (skala 1..tickCount)
                  tickCount: 5,
                  ticksTextStyle:
                      const TextStyle(color: Colors.grey, fontSize: 10),
                  radarBackgroundColor: Colors.transparent,
                  borderData: FlBorderData(show: false),
                  radarBorderData: const BorderSide(color: Colors.blue),
                  // getTitle harus mengembalikan RadarChartTitle — tanpa parameter 'textStyle'
                  getTitle: (index, angle) {
                    return RadarChartTitle(
                      text: aspects[index],
                      angle: angle,
                      // positionPercentageOffset bisa di-set per-title jika perlu
                      // positionPercentageOffset: 0.25,
                    );
                  },
                ),
                // duration/curve bisa ditambah jika mau animasi
              ),
            ),
            const SizedBox(height: 16),
            // Tabel angka rata-rata (opsional, supaya terlihat juga nilai numerik)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    const Text('Rata-rata per aspek (1–5)'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: aspects.map((a) {
                        final v = (averageScores[a] ?? 0.0).toStringAsFixed(2);
                        return Chip(label: Text('$a: $v'));
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // Konversi data ke format yang diharapkan finish_page
                final List<StudentScore> studentScoresList = [];
                for (var studentEntry in studentScores.entries) {
                  final studentName = studentEntry.key;
                  final scores = studentEntry.value;
                  
                  // Konversi Map<String, double> ke Map<String, String>
                  Map<String, String> convertedScores = {};
                  
                  // Kelompokkan berdasarkan aspek soft skills
                  final aspects = ['Fleksibilitas', 'Tanggung Jawab', 'Komunikasi', 'Kerja Sama', 'Problem Solving', 'Kepemimpinan'];
                  
                  for (var aspect in aspects) {
                    double total = 0.0;
                    int count = 0;
                    
                    // Cari semua key yang mengandung nama aspek
                    for (var key in scores.keys) {
                      if (key.contains('($aspect)')) {
                        total += scores[key]!;
                        count++;
                      }
                    }
                    
                    if (count > 0) {
                      double average = total / count;
                      String scoreText;
                      if (average >= 4.5) {
                        scoreText = 'Sangat Baik';
                      } else if (average >= 3.5) {
                        scoreText = 'Baik';
                      } else if (average >= 2.5) {
                        scoreText = 'Cukup';
                      } else if (average >= 1.5) {
                        scoreText = 'Kurang';
                      } else {
                        scoreText = 'Sangat Kurang';
                      }
                      convertedScores[aspect] = scoreText;
                    } else {
                      convertedScores[aspect] = '-';
                    }
                  }
                  
                  studentScoresList.add(StudentScore(
                    name: studentName,
                    scores: convertedScores,
                  ));
                }
                
                Navigator.pushNamed(
                  context,
                  '/finish',
                  arguments: {
                    'studentScores': studentScoresList,
                    'aspects': ['Fleksibilitas', 'Tanggung Jawab', 'Komunikasi', 'Kerja Sama', 'Problem Solving', 'Kepemimpinan'],
                  },
                );
              },
              child: const Text('Selanjutnya'),
            ),
          ],
        ),
      ),
    );
  }
}
