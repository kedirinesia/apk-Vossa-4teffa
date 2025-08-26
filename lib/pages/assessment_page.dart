import 'package:flutter/material.dart';
import '../models/observer_data.dart';
import '../data/instrument_data.dart';

class AssessmentPage extends StatefulWidget {
  final List<String> students;
  final String instrumentType;
  final String classLevel;
  final String programKeahlian;
  final ObserverData observerData;

  const AssessmentPage({
    super.key,
    required this.students,
    required this.instrumentType,
    required this.classLevel,
    required this.programKeahlian,
    required this.observerData,
  });

  @override
  State<AssessmentPage> createState() => _AssessmentPageState();
}

class _AssessmentPageState extends State<AssessmentPage> {
  final List<String> scaleOptions = [
    'Sangat Kurang',
    'Kurang',
    'Cukup',
    'Baik',
    'Sangat Baik'
  ];

  final Map<String, Map<String, String>> answers = {};
  late final List<Map<String, String>> indicatorData;
  late final String instrumentKey;

  @override
  void initState() {
    super.initState();

    instrumentKey = _findInstrumentKey(widget.instrumentType);

    indicatorData = <Map<String, String>>[];
    final instrument = instrumentIndicators[instrumentKey];

    if (instrument != null) {
      instrument.forEach((stage, aspects) {
        aspects.forEach((aspect, indicators) {
          for (var ind in indicators) {
            indicatorData.add({
              'stage': stage, // Alur Pembelajaran
              'butir': '$ind ($aspect)', // Pernyataan + (Kategori)
            });
          }
        });
      });
    }

    for (var s in widget.students) {
      answers[s] = {};
      for (var data in indicatorData) {
        final key = '${data['stage']}|${data['butir']}';
        answers[s]![key] = '';
      }
    }
  }

  String _findInstrumentKey(String input) {
    if (instrumentIndicators.containsKey(input)) return input;
    final lower = input.toLowerCase();
    for (var k in instrumentIndicators.keys) {
      final kl = k.toLowerCase();
      if (kl.contains(lower) || lower.contains(kl)) return k;
    }
    return instrumentIndicators.keys.first;
  }

  Widget _buildDropdownCell(String student, String stage, String butir) {
    final key = '$stage|$butir';
    final current = answers[student]![key];
    return DropdownButton<String>(
      value: (current == '') ? null : current,
      hint: const Text('Pilih'),
      underline: const SizedBox(),
      onChanged: (val) {
        setState(() {
          answers[student]![key] = val ?? '';
        });
      },
      items: scaleOptions
          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final students = widget.students;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Penilaian Soft Skills'),
        backgroundColor: Colors.blueAccent,
      ),
      backgroundColor: Colors.blue.shade50,
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Kelas: ${widget.classLevel}   •   Program: ${widget.programKeahlian}'),
            Text(
                'Observer: ${widget.observerData.observerName} (${widget.observerData.role})'),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: Table(
                    border: TableBorder.all(color: Colors.grey.shade300),
                    columnWidths: {
                      0: const FixedColumnWidth(160), // Alur Pembelajaran
                      1: const FixedColumnWidth(320), // Butir Observasi
                      for (int i = 0; i < students.length; i++)
                        i + 2: const FixedColumnWidth(180),
                    },
                    children: _buildTableRows(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  debugPrint('=== Hasil Penilaian ===');
                  for (var s in students) {
                    debugPrint('Siswa: $s');
                    answers[s]!.forEach((ind, val) {
                      debugPrint('  $ind => ${val.isEmpty ? "-" : val}');
                    });
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Data penilaian disimpan (sementara).')),
                  );
                },
                child: const Text('Simpan Penilaian'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<TableRow> _buildTableRows() {
    final rows = <TableRow>[];

    // Header
    rows.add(
      TableRow(
        decoration: BoxDecoration(color: Colors.blue.shade100),
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Alur Pembelajaran',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Butir Observasi',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ...widget.students.map((s) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(s,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              )),
        ],
      ),
    );

    // Data rows
    for (var data in indicatorData) {
      rows.add(
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(data['stage'] ?? ''),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(data['butir'] ?? ''),
            ),
            ...widget.students.map(
              (s) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildDropdownCell(
                    s, data['stage'] ?? '', data['butir'] ?? ''),
              ),
            ),
          ],
        ),
      );
    }

    return rows;
  }
}
