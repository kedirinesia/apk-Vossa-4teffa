import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/student.dart';
import '../models/observer_data.dart';
import 'class_summary_page.dart';
import 'student_detail_page.dart';

class ResultPage extends StatefulWidget {
  final List<Student> students;
  final ObserverData? observerData;
  final Map<String, Map<String, double>> studentScores;
  final Map<String, Map<String, String>> answers;
  final String? classLevel;
  final String? programKeahlian;

  const ResultPage({
    Key? key, 
    required this.students, 
    this.observerData,
    required this.studentScores,
    required this.answers,
    this.classLevel,
    this.programKeahlian,
  }) : super(key: key);

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    // Bagi siswa per halaman (9 per halaman → 3x3)
    final pages = <List<Student>>[];
    for (var i = 0; i < widget.students.length; i += 9) {
      pages.add(widget.students.sublist(
        i,
        i + 9 > widget.students.length ? widget.students.length : i + 9,
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hasil Penilaian Soft Skills"),
        backgroundColor: Colors.blue.shade700,
      ),
      backgroundColor: Colors.blue.shade50,
      body: Column(
        children: [
          // 🔹 Informasi sekolah / kelas / program / observer
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.observerData != null && widget.observerData!.schoolName.isNotEmpty)
                  Text(
                    'Sekolah: ${widget.observerData!.schoolName}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                Text(
                  'Kelas: ${widget.classLevel ?? 'Tidak tersedia'}  •  Program: ${widget.programKeahlian ?? 'Tidak tersedia'}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (widget.observerData != null)
                  Text(
                    'Observer: ${widget.observerData!.observerName} (${widget.observerData!.role})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 80,
                  child: Image.asset('assets/images/vossa4tefa.png', fit: BoxFit.contain),
                ),
              ],
            ),
          ),

          // 🔹 Grid Radar Chart tiap siswa
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemCount: pages.length,
              itemBuilder: (context, pageIndex) {
                final studentsPage = pages[pageIndex];
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Ubah dari 3 ke 2 untuk lebih responsive
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75, // Sesuaikan ratio untuk chart yang lebih baik
                  ),
                  itemCount: studentsPage.length,
                  itemBuilder: (context, index) {
                    final student = studentsPage[index];
                    return GestureDetector(
                      onTap: () {
                        // Ambil data scores untuk siswa ini
                        final studentScoreData = widget.studentScores[student.name] ?? {};
                        
                        // Navigasi ke halaman detail siswa
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StudentDetailPage(
                              studentName: student.name,
                              studentScores: studentScoreData,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.blue.shade50,
                                Colors.white,
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade700,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    student.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Expanded(child: _buildRadarChart(student)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // 🔹 Pagination Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(pages.length, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index ? Colors.blue.shade700 : Colors.grey,
                ),
              );
            }),
          ),

          // 🔹 Tombol ke Ringkasan Kelas
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClassSummaryPage(
                      studentScores: widget.studentScores,
                      answers: widget.answers,
                      schoolName: widget.observerData?.schoolName,
                      className: widget.classLevel,
                      programName: widget.programKeahlian,
                      observerName: widget.observerData?.observerName,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.bar_chart),
              label: const Text("Lihat Ringkasan Kelas"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarChart(Student student) {
    // Label pendek untuk menghindari overlap
    final shortLabels = [
      "KOM",
      "KS",
      "TJ",
      "FS",
      "PS",
      "KP",
    ];

    // Ambil data scores dari studentScores map
    // studentScores menggunakan nama siswa sebagai key (String), bukan objek Student
    final studentScoreData = widget.studentScores[student.name] ?? {};
    
    // Fungsi untuk mencari nilai berdasarkan aspek dalam key yang panjang
    double getScoreForAspect(String aspect) {
      // Kumpulkan semua nilai untuk aspek ini dari semua tahap
      final scores = <double>[];
      for (var entry in studentScoreData.entries) {
        if (entry.key.contains('($aspect)')) {
          scores.add(entry.value);
        }
      }
      
      // Hitung rata-rata dari semua tahap
      if (scores.isEmpty) return 0.0;
      return scores.reduce((a, b) => a + b) / scores.length;
    }
    
    final values = [
      getScoreForAspect("Komunikasi"),
      getScoreForAspect("Kerja Sama"),
      getScoreForAspect("Tanggung Jawab"),
      getScoreForAspect("Fleksibilitas"),
      getScoreForAspect("Problem Solving"),
      getScoreForAspect("Kepemimpinan"),
    ];

    // Debug: Print data untuk troubleshooting (bisa dihapus setelah testing)
    // print('=== DEBUG RESULT PAGE ===');
    // print('Student: ${student.name}');
    // print('Values: $values');
    // print('========================');

    // Pastikan ada data yang valid
    final hasValidData = values.any((v) => v > 0);
    
    if (!hasValidData) {
      return Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 48),
              SizedBox(height: 8),
              Text('Data penilaian belum diisi!', 
                   style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 220,
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          dataSets: [
            RadarDataSet(
              entryRadius: 6,
              borderColor: Colors.blue.shade700,
              fillColor: Colors.blue.shade300.withOpacity(0.2),
              borderWidth: 3,
              dataEntries: values.map((v) => RadarEntry(value: v)).toList(),
            ),
          ],
          radarBackgroundColor: Colors.white,
          radarBorderData: BorderSide(color: Colors.grey.shade400, width: 2),
          tickCount: 5,
          ticksTextStyle: TextStyle(
            color: Colors.transparent, // Sembunyikan angka-angka
            fontSize: 0,
          ),
          titleTextStyle: TextStyle(
            color: Colors.blue.shade800, 
            fontSize: 9, 
            fontWeight: FontWeight.w600,
          ),
          titlePositionPercentageOffset: 0.3,
          getTitle: (index, angle) {
            // Gunakan posisi yang lebih jauh untuk semua label
            return RadarChartTitle(
              text: shortLabels[index],
              positionPercentageOffset: 0.35,
            );
          },
          // Tambahkan grid untuk membuat chart lebih mudah dibaca
          gridBorderData: BorderSide(
            color: Colors.grey.shade300, 
            width: 1,
          ),
        ),
      ),
    );
  }
}


  