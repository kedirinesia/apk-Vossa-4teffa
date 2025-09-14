import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StudentDetailPage extends StatelessWidget {
  final String studentName;
  final Map<String, double> studentScores;

  const StudentDetailPage({
    super.key,
    required this.studentName,
    required this.studentScores,
  });

  @override
  Widget build(BuildContext context) {
    final indicators = studentScores.keys.toList();
    final values = studentScores.values.toList();
    final maxValue = values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 5.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Penilaian - $studentName'),
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
                      'Nama Siswa: $studentName',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Indikator: ${indicators.length}',
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
                        final indicator = indicators[index];
                        final shortTitle = _getShortIndicator(indicator);
                        return RadarChartTitle(
                          text: shortTitle,
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
                  children: indicators.asMap().entries.map((entry) {
                    final index = entry.key;
                    final indicator = entry.value;
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
                                  '${index + 1}. ${_getShortIndicator(indicator)}',
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
                itemCount: indicators.length,
                itemBuilder: (context, index) {
                  final indicator = indicators[index];
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
                      _getShortIndicator(indicator),
                      style: const TextStyle(fontSize: 12),
                    ),
                    subtitle: Text(
                      _getFullIndicator(indicator),
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
  
  String _getShortIndicator(String indicator) {
    // Ambil bagian terakhir dari indicator (dalam kurung)
    final parts = indicator.split('(');
    if (parts.length > 1) {
      return parts.last.replaceAll(')', '').trim();
    }
    return indicator.length > 30 ? '${indicator.substring(0, 30)}...' : indicator;
  }
  
  String _getFullIndicator(String indicator) {
    return indicator;
  }
  
  Color _getScoreColor(double score) {
    if (score >= 4.0) return Colors.green;
    if (score >= 3.0) return Colors.orange;
    if (score >= 2.0) return Colors.red.shade300;
    return Colors.red;
  }
}
