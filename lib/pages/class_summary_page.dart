import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'class_analysis_page.dart';
import '../models/observer_data.dart';

class ClassSummaryPage extends StatelessWidget {
  final Map<String, Map<String, double>> studentScores;
  final Map<String, Map<String, String>> answers;
  final String? schoolName;
  final String? className;
  final String? programName;
  final String? observerName;

  const ClassSummaryPage({
    Key? key, 
    required this.studentScores,
    required this.answers,
    this.schoolName,
    this.className,
    this.programName,
    this.observerName,
  }) : super(key: key);


  double average(List<double?> values) {
    final nonNullValues = values.map((v) => v ?? 0).toList();
    if (nonNullValues.isEmpty) return 0.0;
    final sum = nonNullValues.reduce((a, b) => a + b);
    return sum / nonNullValues.length;
  }

  String getCategory(double value) {
    if (value < 2.0) return "Sangat Kurang";
    if (value < 3.0) return "Kurang";
    if (value < 4.0) return "Cukup";
    if (value < 4.5) return "Baik";
    return "Sangat Baik";
  }


  // Fungsi untuk mencari nilai berdasarkan aspek dalam key yang panjang
  double getScoreForAspect(String aspect, Map<String, double> studentScoreData) {
    // Mapping singkatan ke nama lengkap
    final aspectMapping = {
      "KOM": "Komunikasi",
      "KS": "Kerja Sama", 
      "TJ": "Tanggung Jawab",
      "FS": "Fleksibilitas",
      "PS": "Problem Solving",
      "KP": "Kepemimpinan",
    };
    
    final fullAspect = aspectMapping[aspect] ?? aspect;
    
    // Kumpulkan semua nilai untuk aspek ini dari semua tahap
    final scores = <double>[];
    for (var entry in studentScoreData.entries) {
      if (entry.key.contains('($fullAspect)')) {
        scores.add(entry.value);
      }
    }
    
    // Hitung rata-rata dari semua tahap
    if (scores.isEmpty) return 0.0;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  @override
  Widget build(BuildContext context) {
    final aspects = ["KOM", "KS", "TJ", "FS", "PS", "KP"];
    final fullNames = ["Komunikasi", "Kerja Sama", "Tanggung Jawab", "Fleksibilitas", "Problem Solving", "Kepemimpinan"];
    
    final aspectAverages = <String, double>{};
    for (var aspect in aspects) {
      double total = 0;
      int count = 0;
      for (var studentName in studentScores.keys) {
        final scores = studentScores[studentName]!;
        final value = getScoreForAspect(aspect, scores);
        if (value > 0) {
          total += value;
          count++;
        }
      }
      aspectAverages[aspect] = count > 0 ? total / count : 0.0;
    }
    
    // Debug: Print data untuk troubleshooting
    print('=== DEBUG CLASS SUMMARY ===');
    print('StudentScores keys: ${studentScores.keys}');
    if (studentScores.isNotEmpty) {
      final firstStudent = studentScores.keys.first;
      print('First student data keys: ${studentScores[firstStudent]?.keys}');
    }
    print('AspectAverages: $aspectAverages');
    print('========================');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ringkasan Kelas"),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔹 Logo Vossa4TeFa
            SizedBox(
              height: 80,
              child: Image.asset('assets/images/vossa4tefa.png', fit: BoxFit.contain),
            ),
            const SizedBox(height: 16),

            // 🔹 Bar Chart
            Expanded(
              flex: 2,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: aspectAverages.entries.map((entry) {
                    return BarChartGroupData(
                      x: aspectAverages.keys.toList().indexOf(entry.key),
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(),
                          color: Colors.blue.shade400,
                          width: 18,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= aspectAverages.length) return const Text('');
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              aspectAverages.keys.elementAt(index),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: true),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 🔹 Tabel dengan kategori
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Table(
                      border: TableBorder.all(color: Colors.blue.shade300),
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(2),
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(color: Colors.blue.shade100),
                          children: const [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Aspek Soft Skill",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, color: Colors.blue),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Rata-rata",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, color: Colors.blue),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Kategori",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                        ...aspectAverages.entries.toList().asMap().entries.map((entry) {
                          final index = entry.key;
                          final aspectEntry = entry.value;
                          final value = aspectEntry.value;
                          final category = getCategory(value);
                          final fullName = fullNames[index];
                          return TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(fullName),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(value.toStringAsFixed(2)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(category),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 🔹 Keterangan kategori
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Keterangan kategori:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                        Text("1.0 – 1.99 : Sangat Kurang"),
                        Text("2.0 – 2.99 : Kurang"),
                        Text("3.0 – 3.99 : Cukup"),
                        Text("4.0 – 4.49 : Baik"),
                        Text("4.5 – 5.0 : Sangat Baik"),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 🔹 Tombol Finish / Export
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClassAnalysisPage(
                                  studentScores: studentScores,
                                  answers: answers,
                                  classLevel: className ?? 'Kelas',
                                  programKeahlian: programName ?? 'Program',
                                  observerData: ObserverData(
                                    observerName: observerName ?? 'Observer',
                                    schoolName: schoolName ?? 'Sekolah',
                                    mitraName: 'Mitra',
                                    role: 'Guru',
                                  ),
                                  schoolName: schoolName ?? 'Sekolah',
                                ),
                              ),
                            );
                          },
                          child: const Text('Selanjutnya'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.popUntil(context, (route) => route.isFirst);
                          },
                          child: const Text('Kembali ke CoverPage'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}



