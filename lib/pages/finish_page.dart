// lib/pages/finish_page.dart
import 'package:flutter/material.dart';

// Model sederhana untuk siswa dan nilai
class StudentScore {
  final String name;
  final Map<String, String> scores; // aspek -> nilai ('Sangat Kurang' sampai 'Sangat Baik')

  StudentScore({required this.name, required this.scores});
}

class FinishPage extends StatelessWidget {
  final List<StudentScore> studentScores;
  final List<String> aspects; // misal ['Fleksibilitas', 'Tanggung Jawab', 'Problem Solving', 'Komunikasi', 'Kerja Sama', 'Kepemimpinan']

  const FinishPage({Key? key, required this.studentScores, required this.aspects}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ringkasan Penilaian'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 100,
            ),
            const SizedBox(height: 12),
            const Text(
              'Penilaian selesai!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Berikut ringkasan nilai semua siswa:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            // Tabel ringkasan nilai
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    const DataColumn(label: Text('Nama Siswa')),
                    ...aspects.map((a) => DataColumn(label: Text(a))).toList(),
                  ],
                  rows: studentScores.map((student) {
                    return DataRow(
                      cells: [
                        DataCell(Text(student.name)),
                        ...aspects.map((aspect) => DataCell(Text(student.scores[aspect] ?? '-'))).toList(),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Kembali ke halaman CoverPage
                Navigator.of(context).pushNamedAndRemoveUntil('/cover', (route) => false);
              },
              child: const Text('Kembali ke Halaman Utama'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // Alternatif keluar/login ulang
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              },
              child: const Text('Keluar / Login Ulang'),
            ),
          ],
        ),
      ),
    );
  }
}
