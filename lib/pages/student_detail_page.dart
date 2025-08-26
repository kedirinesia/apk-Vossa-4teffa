import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StudentDetailPage extends StatelessWidget {
  final String studentName;
  final Map<String, int> studentScores;

  const StudentDetailPage({
    super.key,
    required this.studentName,
    required this.studentScores,
  });

  @override
  Widget build(BuildContext context) {
    final indicators = studentScores.keys.toList();
    final values = studentScores.values.map((e) => e.toDouble()).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Penilaian - $studentName'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Grafik Radar Soft Skills',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            AspectRatio(
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
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                  getTitle: (index, angle) {
                    return RadarChartTitle(
                      text: indicators[index],
                      angle: angle,
                    );
                  },
                  dataSets: [
                    RadarDataSet(
                      dataEntries:
                          values.map((v) => RadarEntry(value: v)).toList(),
                      fillColor: Colors.green.withOpacity(0.4),
                      borderColor: Colors.green,
                      entryRadius: 3,
                      borderWidth: 2,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Rincian Skor',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: indicators.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text(indicators[index]),
                  trailing: Text(
                    '${studentScores[indicators[index]]}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
