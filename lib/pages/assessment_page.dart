import 'dart:math';
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
    'Kurang',
    'Cukup',
    'Baik',
    'Sangat Baik'
  ];

  // Deskriptor skala penilaian untuk setiap aspek soft skills
  final Map<String, Map<String, String>> scoringDescriptors = {
    'Fleksibilitas': {
      'Kurang': 'Bingung dan tidak fleksibel jika menemui hal baru.',
      'Cukup': 'Fleksibel hanya ketika diberi arahan, masih perlu bimbingan.',
      'Baik': 'Fleksibel terhadap perubahan.',
      'Sangat Baik': 'Sangat fleksibel bahkan memiliki inisiatif yang tinggi.',
    },
    'Tanggung Jawab': {
      'Kurang': 'Tidak dapat diandalkan dalam menyelesaikan tugas.',
      'Cukup': 'Hanya menyelesaikan tugas jika diingatkan, bergantung pada arahan.',
      'Baik': 'Menyelesaikan tugas dengan baik dan tepat waktu.',
      'Sangat Baik': 'Sangat andal dalam menyelesaikan tugas dan berorientasi kualitas.',
    },
    'Problem Solving': {
      'Kurang': 'Pasif dan tidak berorientasi solusi.',
      'Cukup': 'Berpotensi memecahkan masalah, tetapi belum mandiri.',
      'Baik': 'Kompeten dalam mengidentifikasi dan memecahkan masalah.',
      'Sangat Baik': 'Kompeten, aktif, dan efektif dalam mengidentifikasi masalah.',
    },
    'Komunikasi': {
      'Kurang': 'Sulit mengutarakan gagasan dan sering menimbulkan salah paham.',
      'Cukup': 'Komunikatif namun masih kurang terstruktur dan efektif.',
      'Baik': 'Komunikasi jelas, runtut, dan mudah dipahami.',
      'Sangat Baik': 'Komunikator yang efektif, sistematis, dan persuasif.',
    },
    'Kerja Sama': {
      'Kurang': 'Cenderung bekerja sendiri.',
      'Cukup': 'Kooperatif, namun kurang proaktif.',
      'Baik': 'Kolaboratif dan berkontribusi dengan baik.',
      'Sangat Baik': 'Kolaboratif, berinisiatif membantu, serta pencipta sinergi dalam tim.',
    },
    'Kepemimpinan': {
      'Kurang': 'Pasif dan tidak menunjukkan inisiatif dalam memimpin.',
      'Cukup': 'Berpotensi memimpin, tetapi masih butuh bimbingan.',
      'Baik': 'Memimpin dengan efektif dan dapat memotivasi tim.',
      'Sangat Baik': 'Memimpin dengan efektif, proaktif mengarahkan, strategis, dan memotivasi tim.',
    },
  };

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

  // Method to extract aspect name from indicator text
  String _getAspectFromIndicator(String indicator) {
    if (indicator.contains('(Fleksibilitas)')) return 'Fleksibilitas';
    if (indicator.contains('(Tanggung Jawab)')) return 'Tanggung Jawab';
    if (indicator.contains('(Problem Solving)')) return 'Problem Solving';
    if (indicator.contains('(Komunikasi)')) return 'Komunikasi';
    if (indicator.contains('(Kerja Sama)')) return 'Kerja Sama';
    if (indicator.contains('(Kepemimpinan)')) return 'Kepemimpinan';
    return 'Fleksibilitas'; // default
  }


  // Method to generate shuffled options for each question (butir) per student
  List<String> _getShuffledOptions(String studentName, String key) {
    // Use combination of student name and question key as seed for random shuffling
    final seed = (studentName + key).hashCode;
    final random = Random(seed);
    final shuffledOptions = List<String>.from(scaleOptions);
    shuffledOptions.shuffle(random);
    return shuffledOptions;
  }

  Widget _buildDropdownCell(String student, String stage, String butir) {
    final key = '$stage|$butir';
    final current = answers[student]![key];
    final isEmpty = current == '';
    final aspect = _getAspectFromIndicator(butir);
    final shuffledOptions = _getShuffledOptions(student, key);
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isEmpty ? Colors.red.shade300 : Colors.grey.shade300,
          width: isEmpty ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(4),
        color: isEmpty ? Colors.red.shade50 : Colors.white,
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        menuMaxHeight: 500,
        value: isEmpty ? null : current,
        hint: Text(
          'Pilih',
          style: TextStyle(
            color: isEmpty ? Colors.red.shade600 : Colors.grey.shade600,
            fontWeight: isEmpty ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        underline: const SizedBox(),
        onChanged: (val) {
          setState(() {
            answers[student]![key] = val ?? '';
          });
        },
        items: shuffledOptions.map((s) {
          final descriptor = scoringDescriptors[aspect]?[s] ?? '';
          return DropdownMenuItem(
            value: s,
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 300),
          //    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
              child: Text(
                descriptor,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade800,
                  height: 1.4,
                ),
                textAlign: TextAlign.left,
                maxLines: 20,
                overflow: TextOverflow.visible,
              ),
            ),
          );
        }).toList(),
      ),
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
                      0: const FixedColumnWidth(180), // Alur Pembelajaran
                      1: const FixedColumnWidth(350), // Butir Observasi
                      for (int i = 0; i < students.length; i++)
                        i + 2: const FixedColumnWidth(280),
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
                  // Validasi: Cek apakah semua field sudah diisi
                  bool allFieldsFilled = true;
                  List<String> emptyFields = [];
                  
                  for (var student in students) {
                    final studentAnswers = answers[student]!;
                    for (var entry in studentAnswers.entries) {
                      if (entry.value.isEmpty) {
                        allFieldsFilled = false;
                        final parts = entry.key.split('|');
                        final stage = parts.length > 0 ? parts[0] : '';
                        final butir = parts.length > 1 ? parts[1] : entry.key;
                        emptyFields.add('$student - $stage: $butir');
                      }
                    }
                  }
                  
                  if (!allFieldsFilled) {
                    // Tampilkan dialog error dengan daftar field yang belum diisi
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Data Belum Lengkap'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Mohon lengkapi semua field penilaian berikut:'),
                              const SizedBox(height: 12),
                              Container(
                                height: 200,
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: emptyFields.take(10).map((field) => 
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 4),
                                        child: Text(
                                          '• $field',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      )
                                    ).toList(),
                                  ),
                                ),
                              ),
                              if (emptyFields.length > 10)
                                Text(
                                  '... dan ${emptyFields.length - 10} field lainnya',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                    return;
                  }
                  
                  // Hitung skor untuk setiap siswa
                  final Map<String, Map<String, double>> studentScores = {};
                  
                  for (var student in students) {
                    studentScores[student] = {};
                    final studentAnswers = answers[student]!;
                    
                    // Hitung skor berdasarkan jawaban
                    for (var entry in studentAnswers.entries) {
                      final key = entry.key;
                      final answer = entry.value;
                      
                      // Konversi jawaban ke skor numerik
                      double score = 0;
                      switch (answer) {
                        case 'Kurang':
                          score = 1;
                          break;
                        case 'Cukup':
                          score = 2;
                          break;
                        case 'Baik':
                          score = 3;
                          break;
                        case 'Sangat Baik':
                          score = 4;
                          break;
                        default:
                          score = 0;
                      }
                      
                      studentScores[student]![key] = score;
                    }
                  }
                  
                  // Navigate ke halaman result
                  Navigator.pushNamed(
                    context,
                    '/result',
                    arguments: {
                      'observerData': widget.observerData,
                      'instrumentType': widget.instrumentType,
                      'classLevel': widget.classLevel,
                      'programKeahlian': widget.programKeahlian,
                      'students': students,
                      'answers': answers,
                      'studentScores': studentScores,
                    },
                  );
                },
                child: const Text('Selanjutnya'),
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
