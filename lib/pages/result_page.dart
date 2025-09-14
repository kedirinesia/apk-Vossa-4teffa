import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/firebase_service.dart';
import '../models/observer_data.dart';

class ResultPage extends StatefulWidget {
  final Map<String, Map<String, double>> studentScores;
  final ObserverData? observerData;
  final String? instrumentType;
  final String? classLevel;
  final String? programKeahlian;
  final List<String>? students;
  final Map<String, Map<String, String>>? answers;

  const ResultPage({
    super.key, 
    required this.studentScores,
    this.observerData,
    this.instrumentType,
    this.classLevel,
    this.programKeahlian,
    this.students,
    this.answers,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool _isSaving = false;
  bool _isSaved = false;

  Future<void> _saveToFirebase() async {
    if (widget.observerData == null || 
        widget.instrumentType == null || 
        widget.students == null || 
        widget.answers == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data tidak lengkap untuk disimpan')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await FirebaseService.saveAssessmentData(
        observerData: widget.observerData!,
        instrumentType: widget.instrumentType!,
        classLevel: widget.classLevel ?? '',
        programKeahlian: widget.programKeahlian ?? '',
        students: widget.students!,
        answers: widget.answers!,
        studentScores: widget.studentScores,
      );

      setState(() {
        _isSaved = true;
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Data berhasil disimpan ke Firebase!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error menyimpan data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final students = widget.studentScores.keys.toList();
    final pages = (students.length / 12).ceil();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Penilaian Soft Skills'),
        backgroundColor: Colors.blueAccent,
        actions: [
          if (!_isSaved)
            IconButton(
              onPressed: _isSaving ? null : _saveToFirebase,
              icon: _isSaving 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
              tooltip: 'Simpan ke Firebase',
            ),
          if (_isSaved)
            const Icon(
              Icons.check_circle,
              color: Colors.green,
            ),
        ],
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
