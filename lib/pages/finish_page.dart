// lib/pages/finish_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

// Model sederhana untuk siswa dan nilai
class StudentScore {
  final String name;
  final Map<String, String> scores; // aspek -> nilai ('Sangat Kurang' sampai 'Sangat Baik')

  StudentScore({required this.name, required this.scores});
}

class FinishPage extends StatefulWidget {
  final List<StudentScore> studentScores;
  final List<String> aspects; // misal ['Fleksibilitas', 'Tanggung Jawab', 'Problem Solving', 'Komunikasi', 'Kerja Sama', 'Kepemimpinan']

  const FinishPage({Key? key, required this.studentScores, required this.aspects}) : super(key: key);

  @override
  State<FinishPage> createState() => _FinishPageState();
}

class _FinishPageState extends State<FinishPage> {
  bool _isExporting = false;

  // Method untuk export ke Excel
  Future<void> _exportToExcel() async {
    setState(() {
      _isExporting = true;
    });

    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Penilaian Soft Skills'];
      
      // Header
      List<String> headers = ['Nama Siswa', ...widget.aspects];
      for (int i = 0; i < headers.length; i++) {
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).value = TextCellValue(headers[i]);
      }
      
      // Data siswa
      for (int i = 0; i < widget.studentScores.length; i++) {
        final student = widget.studentScores[i];
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1)).value = TextCellValue(student.name);
        
        for (int j = 0; j < widget.aspects.length; j++) {
          final aspect = widget.aspects[j];
          final score = student.scores[aspect] ?? '-';
          sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: j + 1, rowIndex: i + 1)).value = TextCellValue(score);
        }
      }
      
      // Simpan file
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'penilaian_soft_skills_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(excel.encode()!);
      
      // Coba buka file
      try {
        final result = await OpenFile.open(file.path);
        if (result.type == ResultType.done) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ File Excel berhasil diekspor dan dibuka!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ File Excel berhasil diekspor!\nLokasi: ${file.path}'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ File Excel berhasil diekspor!\nLokasi: ${file.path}\nError buka file: $e'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error export Excel: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  // Method untuk export ke PDF
  Future<void> _exportToPDF() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Laporan Penilaian Soft Skills',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Tanggal: ${DateTime.now().toString().split(' ')[0]}',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FixedColumnWidth(100),
                  ...Map.fromIterable(
                    List.generate(widget.aspects.length, (index) => index + 1),
                    key: (i) => i,
                    value: (i) => const pw.FixedColumnWidth(80),
                  ),
                },
                children: [
                  // Header row
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Nama Siswa', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      ...widget.aspects.map((aspect) => pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(aspect, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      )),
                    ],
                  ),
                  // Data rows
                  ...widget.studentScores.map((student) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(student.name),
                      ),
                      ...widget.aspects.map((aspect) => pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(student.scores[aspect] ?? '-'),
                      )),
                    ],
                  )),
                ],
              ),
            ];
          },
        ),
      );
      
      // Simpan file
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'penilaian_soft_skills_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(await pdf.save());
      
      // Coba buka file
      try {
        final result = await OpenFile.open(file.path);
        if (result.type == ResultType.done) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ File PDF berhasil diekspor dan dibuka!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ File PDF berhasil diekspor!\nLokasi: ${file.path}'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ File PDF berhasil diekspor!\nLokasi: ${file.path}\nError buka file: $e'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error export PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  // Method untuk share Excel
  Future<void> _shareExcel() async {
    setState(() {
      _isExporting = true;
    });

    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Penilaian Soft Skills'];
      
      // Header
      List<String> headers = ['Nama Siswa', ...widget.aspects];
      for (int i = 0; i < headers.length; i++) {
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).value = TextCellValue(headers[i]);
      }
      
      // Data siswa
      for (int i = 0; i < widget.studentScores.length; i++) {
        final student = widget.studentScores[i];
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1)).value = TextCellValue(student.name);
        
        for (int j = 0; j < widget.aspects.length; j++) {
          final aspect = widget.aspects[j];
          final score = student.scores[aspect] ?? '-';
          sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: j + 1, rowIndex: i + 1)).value = TextCellValue(score);
        }
      }
      
      // Simpan file
      final directory = await getTemporaryDirectory();
      final fileName = 'penilaian_soft_skills_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(excel.encode()!);
      
      // Share file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Laporan Penilaian Soft Skills - Excel',
        subject: 'Penilaian Soft Skills',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ File Excel berhasil dibagikan!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error share Excel: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  // Method untuk share PDF
  Future<void> _sharePDF() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Laporan Penilaian Soft Skills',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Tanggal: ${DateTime.now().toString().split(' ')[0]}',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FixedColumnWidth(100),
                  ...Map.fromIterable(
                    List.generate(widget.aspects.length, (index) => index + 1),
                    key: (i) => i,
                    value: (i) => const pw.FixedColumnWidth(80),
                  ),
                },
                children: [
                  // Header row
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Nama Siswa', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      ...widget.aspects.map((aspect) => pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(aspect, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      )),
                    ],
                  ),
                  // Data rows
                  ...widget.studentScores.map((student) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(student.name),
                      ),
                      ...widget.aspects.map((aspect) => pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(student.scores[aspect] ?? '-'),
                      )),
                    ],
                  )),
                ],
              ),
            ];
          },
        ),
      );
      
      // Simpan file
      final directory = await getTemporaryDirectory();
      final fileName = 'penilaian_soft_skills_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(await pdf.save());
      
      // Share file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Laporan Penilaian Soft Skills - PDF',
        subject: 'Penilaian Soft Skills',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ File PDF berhasil dibagikan!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error share PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

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
                    ...widget.aspects.map((a) => DataColumn(label: Text(a))).toList(),
                  ],
                  rows: widget.studentScores.map((student) {
                    return DataRow(
                      cells: [
                        DataCell(Text(student.name)),
                        ...widget.aspects.map((aspect) => DataCell(Text(student.scores[aspect] ?? '-'))).toList(),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Tombol Export
            const Text(
              'Export Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            // Tombol Export
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isExporting ? null : _exportToExcel,
                    icon: _isExporting 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.table_chart),
                    label: const Text('Export Excel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isExporting ? null : _exportToPDF,
                    icon: _isExporting 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.picture_as_pdf),
                    label: const Text('Export PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Tombol Share
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isExporting ? null : _shareExcel,
                    icon: _isExporting 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.share),
                    label: const Text('Share Excel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isExporting ? null : _sharePDF,
                    icon: _isExporting 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.share),
                    label: const Text('Share PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Tombol Navigasi
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
