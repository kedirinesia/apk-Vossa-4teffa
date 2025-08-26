import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ResultPage extends StatelessWidget {
  final Map<String, Map<String, double>> studentScores;

  const ResultPage({super.key, required this.studentScores});

  @override
  Widget build(BuildContext context) {
    final students = studentScores.keys.toList();
    final pages = (students.length / 12).ceil();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Penilaian Soft Skills'),
        backgroundColor: Colors.blueAccent,
      ),
      body: PageView.builder(
        itemCount: pages,
        itemBuilder: (context, pageIndex) {
          final pageStudents = students.skip(pageIndex * 12).take(12).toList();
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 kolom
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: pageStudents.length,
              itemBuilder: (context, index) {
                final studentName = pageStudents[index];
                final scores = studentScores[studentName] ?? {};
                return _buildRadarChartCard(studentName, scores);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildRadarChartCard(String studentName, Map<String, double> scores) {
    final aspects = [
      'Fleksibilitas',
      'Tanggung jawab',
      'Komunikasi',
      'Kerja sama',
      'Problem-solving',
      'Kepemimpinan'
    ];

    final values = aspects.map((a) => scores[a] ?? 0).toList();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              studentName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: RadarChart(
                RadarChartData(
                  dataSets: [
                    RadarDataSet(
                      entryRadius: 2,
                      dataEntries: values.map((v) => RadarEntry(value: v)).toList(),
                      borderColor: Colors.blue,
                      fillColor: Colors.blue.withOpacity(0.3),
                      borderWidth: 2,
                    ),
                  ],
                  radarBackgroundColor: Colors.transparent,
                  borderData: FlBorderData(show: false),
                  radarShape: RadarShape.polygon,
                  tickCount: 5,
                  ticksTextStyle: const TextStyle(fontSize: 10, color: Colors.grey),
                  titlePositionPercentageOffset: 0.15,
                  getTitle: (index, angle) {
                    return RadarChartTitle(
                      text: aspects[index % aspects.length],
                    );
                  },
                  radarBorderData: BorderSide(color: Colors.blueAccent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
